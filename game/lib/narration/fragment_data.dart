/// Narrative memory fragments unlocked every 10 waves.
///
/// The story of the last human pilot, awakened from cryo-sleep
/// to find humanity gone, told through fragmented inner thoughts.
class FragmentData {
  static const List<NarrativeFragment> fragments = [
    NarrativeFragment(
      id: -1,
      title: 'AWAKENING',
      text: 'Where am I?\n'
          'Everything is... cold.\n'
          'My hands won\'t stop shaking.\n\n'
          'The console says I\'ve been asleep.\n'
          'It doesn\'t say for how long.',
      waveRequired: 0,
    ),
    NarrativeFragment(
      id: 0,
      title: 'FIRST THOUGHTS',
      text: 'The engines hum. Good.\n'
          'At least something still works.\n\n'
          'I remember training. I remember\n'
          'a launch. I remember... nothing else.\n\n'
          'Why is no one answering my calls?',
      waveRequired: 10,
    ),
    NarrativeFragment(
      id: 1,
      title: 'SILENCE',
      text: 'I\'ve been scanning for hours.\n'
          'Every frequency. Every channel.\n'
          'Earth. Moon. Mars. Nothing.\n\n'
          'Not even static. Just...\n'
          'silence. The worst kind.',
      waveRequired: 20,
    ),
    NarrativeFragment(
      id: 2,
      title: 'WRECKAGE',
      text: 'There are pieces of ships\n'
          'mixed in with the rocks.\n'
          'Human ships.\n\n'
          'I found a name plate today.\n'
          '"USS Challenger". I think I\n'
          'knew someone on that crew.',
      waveRequired: 30,
    ),
    NarrativeFragment(
      id: 3,
      title: 'GHOSTS',
      text: 'A Tesla drifted past today.\n'
          'Still playing Bowie on loop.\n'
          'A Starlink satellite blinked\n'
          'at me like an old friend.\n\n'
          'Pieces of a world that moved on\n'
          'without telling me.',
      waveRequired: 40,
    ),
    NarrativeFragment(
      id: 4,
      title: 'THEM',
      text: 'The UFOs aren\'t just machines.\n'
          'They react. They adapt.\n'
          'Today one hesitated before firing.\n\n'
          'And their hull plating...\n'
          'it\'s grafted onto human alloys.\n'
          'Who built these things?',
      waveRequired: 50,
    ),
    NarrativeFragment(
      id: 5,
      title: 'A VOICE',
      text: 'Caught a fragment. A human voice.\n'
          'Looping for 347 years:\n\n'
          '"...all ships to the Gate...\n'
          '...this is not a drill..."\n\n'
          'She sounded scared.\n'
          'I would have been too.',
      waveRequired: 60,
    ),
    NarrativeFragment(
      id: 6,
      title: 'THE GATE',
      text: 'They found something.\n'
          'Beyond the belt. A structure.\n'
          'Not ours. Not theirs.\n'
          'Something older.\n\n'
          'Everyone walked through it.\n'
          'Everyone except me.',
      waveRequired: 70,
    ),
    NarrativeFragment(
      id: 7,
      title: 'LAST WORDS',
      text: 'Found the final broadcast:\n\n'
          '"To whoever hears this:\n'
          'we chose to leave. All of us.\n'
          'Don\'t be afraid.\n'
          'You are not forgotten."\n\n'
          'I read it three times.\n'
          'It doesn\'t help.',
      waveRequired: 80,
    ),
    NarrativeFragment(
      id: 8,
      title: 'STAYING',
      text: 'I could look for the Gate.\n'
          'Follow them. See what\'s\n'
          'on the other side.\n\n'
          'But these rocks won\'t\n'
          'clear themselves.\n'
          'And someone has to keep watch.',
      waveRequired: 90,
    ),
    NarrativeFragment(
      id: 9,
      title: 'NOT ALONE',
      text: 'Something pinged my scanner.\n'
          'Not rock. Not human. Not UFO.\n'
          'Something new.\n\n'
          'It\'s been there a while.\n'
          'Watching.\n\n'
          'And now it\'s moving closer.',
      waveRequired: 100,
    ),
  ];
}

class NarrativeFragment {
  final int id;
  final String title;
  final String text;
  final int waveRequired;

  const NarrativeFragment({
    required this.id,
    required this.title,
    required this.text,
    required this.waveRequired,
  });
}
