#!/usr/bin/env bash
# Update Google Play store listing (titles, descriptions) via Play Developer API v3.
# Dependencies: curl, jq, openssl (all available on ubuntu-latest)
# Usage: PACKAGE_NAME=... SERVICE_ACCOUNT_JSON=path/to/sa.json METADATA_DIR=path/to/metadata ./update-play-listing.sh

set -euo pipefail

: "${PACKAGE_NAME:?PACKAGE_NAME is required}"
: "${SERVICE_ACCOUNT_JSON:?SERVICE_ACCOUNT_JSON is required}"
: "${METADATA_DIR:?METADATA_DIR is required}"

API_BASE="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}"

# --- Step 1: Get an access token from the service account JSON via JWT ---
SA_EMAIL=$(jq -r '.client_email' "$SERVICE_ACCOUNT_JSON")
SA_KEY=$(jq -r '.private_key' "$SERVICE_ACCOUNT_JSON")

NOW=$(date +%s)
EXP=$((NOW + 3600))

HEADER=$(printf '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
PAYLOAD=$(printf '{"iss":"%s","scope":"https://www.googleapis.com/auth/androidpublisher","aud":"https://oauth2.googleapis.com/token","iat":%d,"exp":%d}' \
  "$SA_EMAIL" "$NOW" "$EXP" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

SIGNATURE=$(printf '%s.%s' "$HEADER" "$PAYLOAD" | \
  openssl dgst -sha256 -sign <(printf '%s' "$SA_KEY") -binary | \
  openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

JWT="${HEADER}.${PAYLOAD}.${SIGNATURE}"

ACCESS_TOKEN=$(curl -sf -X POST https://oauth2.googleapis.com/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${JWT}" | jq -r '.access_token')

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
  echo "::error::Failed to obtain access token"
  exit 1
fi

echo "Access token obtained."

# --- Step 2: Create an edit ---
EDIT_RESPONSE=$(curl -sf -X POST "${API_BASE}/edits" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{}')

EDIT_ID=$(echo "$EDIT_RESPONSE" | jq -r '.id')

if [ -z "$EDIT_ID" ] || [ "$EDIT_ID" = "null" ]; then
  echo "::error::Failed to create edit"
  exit 1
fi

echo "Edit created: ${EDIT_ID}"

# --- Step 3: Update listings for each locale ---
for LOCALE_DIR in "${METADATA_DIR}"/*/; do
  LOCALE=$(basename "$LOCALE_DIR")

  TITLE_FILE="${LOCALE_DIR}title.txt"
  SHORT_FILE="${LOCALE_DIR}short_description.txt"
  FULL_FILE="${LOCALE_DIR}full_description.txt"

  # Skip if no metadata files
  [ -f "$TITLE_FILE" ] || continue

  TITLE=$(cat "$TITLE_FILE")
  SHORT_DESC=$(cat "$SHORT_FILE")
  FULL_DESC=$(cat "$FULL_FILE")

  LISTING_JSON=$(jq -n \
    --arg title "$TITLE" \
    --arg short "$SHORT_DESC" \
    --arg full "$FULL_DESC" \
    --arg lang "$LOCALE" \
    '{language: $lang, title: $title, shortDescription: $short, fullDescription: $full}')

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    "${API_BASE}/edits/${EDIT_ID}/listings/${LOCALE}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$LISTING_JSON")

  if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "Listing updated for ${LOCALE} (HTTP ${HTTP_CODE})"
  else
    echo "::error::Failed to update listing for ${LOCALE} (HTTP ${HTTP_CODE})"
    exit 1
  fi
done

# --- Step 4: Commit the edit ---
COMMIT_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  "${API_BASE}/edits/${EDIT_ID}:commit" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")

if [ "$COMMIT_CODE" -ge 200 ] && [ "$COMMIT_CODE" -lt 300 ]; then
  echo "Edit committed successfully (HTTP ${COMMIT_CODE})"
else
  echo "::error::Failed to commit edit (HTTP ${COMMIT_CODE})"
  exit 1
fi
