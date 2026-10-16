class ExperimentQuestion {
  const ExperimentQuestion({
    required this.prompt,
    required this.options,
    required this.correctOption,
  });

  final String prompt;
  final List<String> options;
  final int correctOption;
}

const Map<String, List<ExperimentQuestion>> experimentQuestions = {
  '1': [
    ExperimentQuestion(
      prompt: 'What gas causes the foam in elephant toothpaste?',
      options: ['Carbon dioxide', 'Oxygen', 'Hydrogen', 'Nitrogen'],
      correctOption: 1,
    ),
    ExperimentQuestion(
      prompt: 'What role does yeast play in the reaction?',
      options: ['Indicator', 'Catalyst', 'Acid', 'Product'],
      correctOption: 1,
    ),
  ],
  '2': [
    ExperimentQuestion(
      prompt: 'What observation indicates chloride ions are present?',
      options: ['Blue flame', 'White precipitate', 'Bubbles', 'Clear solution'],
      correctOption: 1,
    ),
    ExperimentQuestion(
      prompt: 'Which reagent produces the precipitate in this test?',
      options: ['Silver nitrate', 'Vinegar', 'Limewater', 'Indicator'],
      correctOption: 0,
    ),
  ],
  '3': [
    ExperimentQuestion(
      prompt: 'What happens to limewater when carbon dioxide is present?',
      options: ['It turns milky', 'It turns blue', 'It freezes', 'It glows'],
      correctOption: 0,
    ),
    ExperimentQuestion(
      prompt: 'What type of test is the limewater test?',
      options: [
        'Quantitative mass test',
        'Qualitative gas test',
        'Flame test',
        'Electrical test',
      ],
      correctOption: 1,
    ),
  ],
  '4': [
    ExperimentQuestion(
      prompt: 'Why do metal ions produce characteristic flame colors?',
      options: [
        'Electrons emit specific light',
        'The wire melts',
        'Oxygen becomes colored',
        'The salt boils',
      ],
      correctOption: 0,
    ),
    ExperimentQuestion(
      prompt: 'Which observation is used to identify the metal ion?',
      options: ['Flame color', 'Solution mass', 'Bubble size', 'Wire length'],
      correctOption: 0,
    ),
  ],
  '5': [
    ExperimentQuestion(
      prompt: 'Why does salt solution conduct electricity?',
      options: [
        'It contains moving ions',
        'It is transparent',
        'It is cold',
        'It contains sugar',
      ],
      correctOption: 0,
    ),
    ExperimentQuestion(
      prompt: 'What indicates that the circuit is conducting?',
      options: [
        'The bulb lights',
        'The water freezes',
        'The beaker moves',
        'The salt disappears',
      ],
      correctOption: 0,
    ),
  ],
  '6': [
    ExperimentQuestion(
      prompt: 'What should happen to the total mass in the closed system?',
      options: [
        'It increases',
        'It decreases',
        'It stays the same',
        'It becomes zero',
      ],
      correctOption: 2,
    ),
    ExperimentQuestion(
      prompt: 'Why does inflating the balloon not increase the total mass?',
      options: [
        'Gas has no mass',
        'The gas remains inside the closed system',
        'The scale ignores gas',
        'The balloon removes vinegar',
      ],
      correctOption: 1,
    ),
  ],
  '7': [
    ExperimentQuestion(
      prompt: 'What does a pH indicator show?',
      options: [
        'Acidity or alkalinity',
        'Electrical current',
        'Atomic mass',
        'Gas pressure',
      ],
      correctOption: 0,
    ),
    ExperimentQuestion(
      prompt: 'A neutral solution is closest to which pH?',
      options: ['0', '3', '7', '14'],
      correctOption: 2,
    ),
  ],
  '8': [
    ExperimentQuestion(
      prompt: 'What does an element’s atomic number represent?',
      options: [
        'Number of protons',
        'Atomic mass only',
        'Number of compounds',
        'Melting point',
      ],
      correctOption: 0,
    ),
    ExperimentQuestion(
      prompt: 'Which symbol identifies an element on the periodic table?',
      options: ['Chemical symbol', 'pH value', 'Voltage', 'Temperature'],
      correctOption: 0,
    ),
  ],
};

List<ExperimentQuestion> questionsForExperiment(String experimentId) {
  final id = experimentId.replaceAll(RegExp(r'[^0-9]'), '');
  return experimentQuestions[id] ?? const [];
}
