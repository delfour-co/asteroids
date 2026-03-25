# Design System — Delfour.co Apps

> Guide de référence pour reproduire le look & feel des applications Delfour.co.
> Basé sur l'app **Git Hero** (Flutter). Applicable à toute app mobile, jeu ou web.

---

## 1. Identité visuelle

### Philosophie

L'esthétique est inspirée du film **TRON** et de l'univers cyberpunk/terminal :

- Fond **noir pur** avec accents **cyan néon**
- Typographie **monospace** pour les éléments techniques ou de marque
- Pas d'ombres classiques — des **halos lumineux** (glows) à la place
- Minimalisme radical : peu de couleurs, pas de gradients complexes
- **Dark mode uniquement** — pas de thème clair

### Mots-clés

`Néon` · `Terminal` · `Cyberpunk` · `Monospace` · `Minimal` · `Noir profond` · `Glow`

---

## 2. Palette de couleurs

### Couleurs principales

| Rôle | Hex | Aperçu | Usage |
|------|-----|--------|-------|
| **Background** | `#000000` | Noir pur | Fond principal de l'app |
| **Surface** | `#0A0A0A` | Gris très foncé | Cartes, champs, éléments surélevés |
| **Surface élevée** | `#111111` | Gris foncé | Éléments au-dessus des cartes |
| **Primary (Cyan)** | `#00FFFF` | Cyan néon | Accent principal, boutons, icônes, liens |
| **Secondary (Blue)** | `#1E90FF` | Bleu électrique | Accent secondaire |
| **Error** | `#FF3333` | Rouge vif | Erreurs, actions destructives |

### Couleurs de texte

| Rôle | Hex | Usage |
|------|-----|-------|
| **Texte principal** | `#FFFFFF` | Titres, corps de texte |
| **Texte secondaire** | `#B0B0B0` | Sous-titres, métadonnées |
| **Texte atténué** | `#666666` | Labels discrets, hints |
| **Texte accent** | `#00FFFF` | Éléments interactifs, éléments de marque |
| **Texte sur primary** | `#0A1A1A` | Texte foncé sur fond cyan |

### Bordures et effets

| Rôle | Hex | Opacité |
|------|-----|---------|
| **Bordure standard** | `#00FFFF` | 20% (`#3300FFFF`) |
| **Halo / Glow** | `#00FFFF` | 40% (`#6600FFFF`) |
| **Overlay modal** | `#000000` | 80% (`#CC000000`) |

### Couleurs sémantiques (badges, tags)

Utiliser des couleurs vives sur fond quasi transparent pour les badges :

| Catégorie | Hex | Exemple d'usage |
|-----------|-----|-----------------|
| Bleu profond | `#00BFFF` | Feature, nouveauté |
| Rouge | `#FF3333` | Urgence, hotfix |
| Orange | `#FF8C00` | Avertissement, correction |
| Or | `#FFD700` | Premium, release |
| Vert | `#00CC66` | Succès, tout public |
| Jaune | `#FFCC00` | Attention modérée |
| Cyan | `#00FFFF` | Défaut, neutre |

**Règle pour les badges** : fond = couleur à ~10% d'opacité, bordure = couleur à ~30%, texte = couleur pleine.

---

## 3. Typographie

### Polices

| Usage | Police | Téléchargement |
|-------|--------|----------------|
| **Corps de texte** | Roboto (défaut système) | Intégrée à Flutter/Android |
| **Éléments de marque / techniques** | JetBrains Mono | [jetbrains.com/lp/mono](https://www.jetbrains.com/lp/mono/) |

### Échelle typographique

| Style | Taille | Poids | Interligne | Usage |
|-------|--------|-------|------------|-------|
| **Headline Large** | 28px | Bold (700) | 1.3 | Titres principaux |
| **Headline Medium** | 22px | Bold (700) | 1.3 | Titres d'écran |
| **Headline Small** | 18px | Semi-Bold (600) | 1.3 | Sous-titres |
| **Body Large** | 17px | Regular (400) | 1.6 | Texte de lecture long |
| **Body Medium** | 15px | Regular (400) | 1.5 | Texte standard |
| **Body Small** | 13px | Regular (400) | 1.4 | Texte secondaire |
| **Label Large** | 15px | Semi-Bold (600) | 1.0 | Boutons, CTA |
| **Label Medium** | 13px | Medium (500) | 1.0 | Labels moyens |
| **Label Small** | 12px | Medium (500) | 1.0 | Petits labels, métadonnées |

### Espacement des lettres (letter-spacing)

| Contexte | Valeur |
|----------|--------|
| Titre AppBar (monospace) | `1.2` |
| Bouton principal | `1.5` |
| Label Large | `1.0` |
| Label Small | `0.5` |

### Règle monospace

Tout ce qui relève de l'identité technique ou de la marque utilise **JetBrains Mono** :
titres de barre d'app, identifiants, commandes, badges techniques, noms de niveaux, scores, etc.

---

## 4. Espacement

### Échelle de spacing

| Nom | Valeur | Usage typique |
|-----|--------|---------------|
| **2xs** | 2px | Gaps minimaux |
| **xs** | 4px | Petits gaps internes |
| **sm** | 6px | Labels, badges |
| **md** | 8px | Padding liste, marge carte verticale |
| **lg** | 12px | Padding interne de carte |
| **xl** | 16px | Padding horizontal standard (écrans, cartes) |
| **2xl** | 20px | Espacement de section |
| **3xl** | 24px | Grands espacements, boutons larges |
| **4xl** | 32px | Padding écran (grands écrans) |

### Rayons de bordure (border-radius)

| Composant | Rayon |
|-----------|-------|
| Badges / tags | 4–6px |
| Boutons | 8px |
| Champs de saisie | 8px |
| Cartes | 12px |
| Dialogs | 16px |
| Bottom sheets | 20px (haut uniquement) |

---

## 5. Composants

### Boutons

#### Bouton principal (Elevated)

```
Fond         : cyan à 10% d'opacité
Texte        : cyan (#00FFFF)
Police       : JetBrains Mono, 14px, bold
Letter-spacing: 1.5
Bordure      : 1.2px solid cyan
Rayon        : 8px
Padding      : 24px horizontal × 14px vertical
Élévation    : 0
Ombre        : halo cyan (blur 16, spread 2)
Press        : overlay cyan 15%
```

#### Bouton secondaire (Outlined)

```
Fond         : transparent
Texte        : cyan
Police       : JetBrains Mono, 13px, semi-bold
Letter-spacing: 1.0
Bordure      : 1px solid borderCyan (cyan 20%)
Rayon        : 8px
Padding      : 20px horizontal × 12px vertical
```

#### Bouton texte (Text)

```
Texte        : cyan
Police       : 14px, semi-bold
Letter-spacing: 0.5
Press        : overlay cyan 20%
```

### Cartes

```
Fond         : surface (#0A0A0A)
Bordure      : 1px solid borderCyan (cyan 20%)
Rayon        : 12px
Élévation    : 0
Marge        : 16px horizontal × 8px vertical
Padding      : 16px

État actif   : halo cyan (blur 12, spread 1, alpha 40%)
Transition   : 150ms
```

### Champs de saisie (Input)

```
Fond         : surface (#0A0A0A), rempli
Bordure      : 1px borderCyan, rayon 8px
Bordure focus: 1.5px cyan
Bordure erreur: 1px rouge
Padding      : 16px horizontal × 14px vertical
Hint         : textDimmed (#666666)
Label        : textSecondary (#B0B0B0)
Icône préfixe: cyan
```

### Chips / Tags

```
Fond         : surface (#0A0A0A)
Texte        : cyan, JetBrains Mono, 12px
Bordure      : 1px borderCyan, rayon 6px
Padding      : 8px horizontal × 2px vertical
```

Pour les tags colorés : remplacer cyan par la couleur sémantique, fond à 10% d'opacité.

### Dialogs

```
Fond         : surface (#0A0A0A)
Bordure      : 1px borderCyan
Rayon        : 16px
Titre        : 18px, bold, blanc
Boutons      : texte cyan
```

### Bottom Sheets

```
Fond         : surface (#0A0A0A)
Rayon        : 20px (coins supérieurs)
Drag handle  : 40px × 4px, #666666, rayon 2px
```

### Snackbars / Toasts

```
Fond         : surfaceElevated (#111111)
Comportement : flottant
Accent gauche: barre rouge 3px
Préfixe      : "fatal:" bold rouge, monospace
Message      : orange (#FFAB00), monospace
Durée        : 4 secondes
```

### Barres d'app (AppBar)

```
Fond         : transparent ou noir
Titre        : JetBrains Mono, 18px, bold, cyan, letter-spacing 1.2
Icônes       : cyan, 22px
Élévation    : 0
```

---

## 6. Effets et animations

### Halo néon (Neon Glow)

L'effet signature. Remplace les ombres portées classiques.

```
BoxShadow:
  color   : cyan (ou couleur contextuelle) à ~40% alpha
  blur    : 16px
  spread  : 2px
  offset  : (0, 0)
```

| Contexte | Blur | Spread | Opacité |
|----------|------|--------|---------|
| Bouton principal | 16 | 2 | 40% |
| Carte active | 12 | 1 | 40% |
| Particule (background) | 3 | 0 | variable |

### Effet machine à écrire (Typewriter)

Pour les textes narratifs ou les messages importants :

```
Délai par caractère : 30ms
Curseur             : bloc plein (█)
Clignotement        : 530ms
Opacité curseur     : alternance entre visible et invisible
```

### Fond animé (Tron Grid)

Grille animée en arrière-plan des écrans principaux :

```
Espacement grille   : 60px
Épaisseur lignes    : 0.3px
Couleur lignes      : borderCyan à ~5% opacité
Particules          : 5 points lumineux
Vitesse particules  : 0.3–1.0 px/frame
Opacité particules  : 10–30%
Traînée             : 15px, gradient vers transparent
Direction           : verticale (descendante)
Durée animation     : 1s (boucle)
```

### Transitions générales

| Élément | Durée | Courbe |
|---------|-------|--------|
| Carte hover/tap | 150ms | ease |
| Scroll vers élément | 500ms | easeOut |
| Apparition modale | 300ms | ease (défaut Material) |

---

## 7. Iconographie

- **Set** : Material Icons (intégré à Flutter)
- **Taille par défaut** : 22px
- **Couleur** : cyan (#00FFFF)
- **Taille petite** (dans texte/badges) : 13–14px
- **Taille grande** (états vides) : 40px, couleur borderCyan

Pas d'icônes custom — tout repose sur le set Material.

---

## 8. Images et assets

### Règles

- Les images de contenu (couvertures, avatars) sont chargées depuis le réseau
- **Fallback** : icône Material sur fond surface avec bordure cyan
- **Ratio couverture** : 3:2
- Coins arrondis sur les images : même rayon que le composant parent

### Polices à embarquer

| Fichier | Poids |
|---------|-------|
| `JetBrainsMono-Regular.ttf` | Regular (400) |
| `JetBrainsMono-Bold.ttf` | Bold (700) |

---

## 9. Patterns de layout

### Structure d'écran type

```
Scaffold (fond noir)
├── AppBar (transparent, titre mono cyan)
├── Body
│   ├── SafeArea
│   ├── [Fond animé optionnel — TronGrid]
│   └── Contenu (ListView ou Column)
│       ├── Section header (headlineSmall, blanc)
│       ├── Cartes ou listes
│       └── Espacement vertical (24px entre sections)
└── [Bottom bar fixe optionnel]
    └── Fond surface, bordure top cyan, SafeArea bottom
```

### Responsive

| Taille d'écran | Padding horizontal | Gap entre sections |
|----------------|--------------------|--------------------|
| Petit (< 360px) | 16px | 16px |
| Standard | 24px | 24px |
| Large (tablette) | 32px | 32px |

### Listes

- **Espacement entre items** : 8px vertical
- **Padding horizontal** : 16px
- **Séparateurs** : bordure cyan 20%, épaisseur 0.5px

### Scrollbar

```
Couleur pouce : cyan à 30% alpha
Rayon         : 2px
Épaisseur     : 4px
```

### Indicateurs de progression

```
Couleur       : cyan
Track         : surface (#0A0A0A)
```

---

## 10. Accessibilité

- **Retour haptique** : léger sur actions standard, moyen sur choix importants
- **Labels sémantiques** : sur tous les boutons et éléments interactifs
- **Contraste** : cyan sur noir = ratio > 10:1 (excellent)
- **SafeArea** : toujours appliqué dans les bottom sheets et zones d'action fixes
- **Texte décoratif** : exclu des lecteurs d'écran (`ExcludeSemantics`)

---

## 11. Barre de statut et navigation système

```
Icônes status bar     : claires (Brightness.light)
Fond navigation bar   : noir (#000000)
Style navigation bar  : dark (icônes claires)
```

---

## 12. Checklist d'implémentation

Pour démarrer une nouvelle app avec ce design system :

- [ ] Définir le thème sombre unique (pas de thème clair)
- [ ] Configurer la palette de couleurs (section 2)
- [ ] Embarquer JetBrains Mono (Regular + Bold)
- [ ] Configurer l'échelle typographique (section 3)
- [ ] Implémenter le composant de halo néon réutilisable
- [ ] Créer les composants de base : bouton, carte, input, chip, dialog
- [ ] Implémenter le fond animé TronGrid (optionnel mais recommandé)
- [ ] Implémenter l'effet typewriter pour les textes narratifs (si applicable)
- [ ] Configurer la barre de statut et navigation système
- [ ] Vérifier les contrastes et l'accessibilité

---

## 13. Tokens de design (résumé)

Pour les développeurs qui utilisent des systèmes de tokens :

```json
{
  "color": {
    "background": "#000000",
    "surface": "#0A0A0A",
    "surfaceElevated": "#111111",
    "primary": "#00FFFF",
    "secondary": "#1E90FF",
    "error": "#FF3333",
    "textPrimary": "#FFFFFF",
    "textSecondary": "#B0B0B0",
    "textDimmed": "#666666",
    "textAccent": "#00FFFF",
    "textOnPrimary": "#0A1A1A",
    "borderCyan": "rgba(0, 255, 255, 0.2)",
    "glowCyan": "rgba(0, 255, 255, 0.4)",
    "overlay": "rgba(0, 0, 0, 0.8)"
  },
  "font": {
    "body": "Roboto",
    "mono": "JetBrains Mono"
  },
  "spacing": {
    "2xs": 2,
    "xs": 4,
    "sm": 6,
    "md": 8,
    "lg": 12,
    "xl": 16,
    "2xl": 20,
    "3xl": 24,
    "4xl": 32
  },
  "radius": {
    "badge": 4,
    "tag": 6,
    "button": 8,
    "input": 8,
    "card": 12,
    "dialog": 16,
    "sheet": 20
  },
  "glow": {
    "button": { "blur": 16, "spread": 2, "alpha": 0.4 },
    "card": { "blur": 12, "spread": 1, "alpha": 0.4 },
    "particle": { "blur": 3, "spread": 0 }
  }
}
```

---

*Document généré depuis le code source de Git Hero — Mars 2025*
