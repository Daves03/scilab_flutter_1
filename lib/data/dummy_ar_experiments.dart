import '../models/ar_experiment_model.dart';

const List<Map<String, dynamic>> _experimentMaps = [
    {
      'id': 'ar1',
      'title': 'Limewater Test for Carbon Dioxide',
      'topic': 'Gas Testing',
      'category': 'Chemical Reactions',
      'backgroundInfo':
          'Limewater (calcium hydroxide solution) turns milky white when carbon dioxide is bubbled through it. This classic test detects CO₂ by forming insoluble calcium carbonate (CaCO₃) as a white precipitate, demonstrating a simple and reliable qualitative gas test used in chemistry labs worldwide.',
      'safetyNote':
          'Limewater is mildly alkaline (pH ~12). Avoid contact with eyes and skin. Wear safety goggles and gloves. Do not ingest. Ensure adequate ventilation when generating CO₂ from acid-carbonate reactions.',
      'relatedConcepts': [
        'Carbon Dioxide',
        'Calcium Hydroxide',
        'Precipitation Reactions',
        'Qualitative Analysis',
        'Carbonates',
      ],
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_159a809cd-1767041982810.png',
      'iconName': 'bubble_chart',
      'tintColorValue': 0xFF0D2E1F,
      'semanticLabel':
          'Clear glass flask with milky white liquid showing carbon dioxide limewater test',
    },
    {
      'id': 'ar2',
      'title': 'Silver Nitrate Precipitation Test',
      'topic': 'Halide Ion Testing',
      'category': 'Precipitation',
      'backgroundInfo':
          'Silver nitrate (AgNO₃) is used to identify halide ions (Cl⁻, Br⁻, I⁻) in solution. Adding AgNO₃ produces characteristic colored precipitates: white for chloride, cream for bromide, and pale yellow for iodide. This test is a cornerstone of qualitative inorganic analysis.',
      'safetyNote':
          'Silver nitrate is corrosive and will stain skin and clothing dark brown/black. Wear gloves and goggles at all times. Avoid contact with organic materials. Dispose of silver waste in designated containers — do not pour down the drain.',
      'relatedConcepts': [
        'Halide Ions',
        'Ionic Precipitation',
        'Qualitative Analysis',
        'Solubility Rules',
        'Silver Compounds',
      ],
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_173eec5f9-1784971684687.png',
      'iconName': 'science',
      'tintColorValue': 0xFF1E1535,
      'semanticLabel':
          'Test tubes showing white cream and yellow precipitates from silver nitrate halide tests',
    },
    {
      'id': 'ar3',
      'title': 'Conductivity Test',
      'topic': 'Electrical Conductivity',
      'category': 'Electrochemistry',
      'backgroundInfo':
          'The conductivity test determines whether a substance conducts electricity by completing a circuit with a light bulb or LED. Ionic compounds in solution and metals conduct electricity, while covalent compounds and distilled water do not. This experiment distinguishes electrolytes from non-electrolytes.',
      'safetyNote':
          'Use low-voltage power sources (batteries, 6V max). Never use mains electricity for conductivity tests. Keep water away from electrical connections. Dry hands before handling equipment. Dispose of solutions properly after testing.',
      'relatedConcepts': [
        'Electrolytes',
        'Ionic Compounds',
        'Electric Current',
        'Free Ions',
        'Metallic Bonding',
      ],
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_14f381e2d-1784971685298.png',
      'iconName': 'bolt',
      'tintColorValue': 0xFF0D2A2E,
      'semanticLabel':
          'Conductivity apparatus with electrodes in solution connected to a light bulb',
    },
    {
      'id': 'ar4',
      'title': 'Law of Conservation of Mass',
      'topic': 'Stoichiometry',
      'category': 'Chemical Reactions',
      'backgroundInfo':
          'The Law of Conservation of Mass states that mass is neither created nor destroyed in a chemical reaction. By measuring the total mass of reactants before and after a reaction in a closed system, students verify that the total mass remains constant, confirming Lavoisier\'s foundational principle of chemistry.',
      'safetyNote':
          'Use sealed containers when performing reactions that produce gases to prevent mass loss. Handle chemicals carefully to avoid spills. Wear goggles and gloves. Ensure the balance is calibrated and on a stable surface before measuring.',
      'relatedConcepts': [
        'Stoichiometry',
        'Balanced Equations',
        'Closed Systems',
        'Antoine Lavoisier',
        'Mole Concept',
      ],
      'thumbnailUrl':
          'https://images.pexels.com/photos/3735747/pexels-photo-3735747.jpeg',
      'iconName': 'balance',
      'tintColorValue': 0xFF2E1510,
      'semanticLabel':
          'Laboratory balance scale with chemical flasks demonstrating conservation of mass',
    },
    {
      'id': 'ar5',
      'title': 'pH Indicator Acid and Base',
      'topic': 'Acid-Base Chemistry',
      'category': 'Chemical Reactions',
      'backgroundInfo':
          'pH indicators are substances that change color depending on the acidity or alkalinity of a solution. Natural indicators like red cabbage juice and universal indicator paper display a spectrum of colors from red (acidic) to purple (alkaline), allowing students to classify common household substances on the pH scale.',
      'safetyNote':
          'Some acids and bases are corrosive. Always wear goggles and gloves. Avoid skin contact with strong acids (HCl, H₂SO₄) or strong bases (NaOH). Neutralize spills with sodium bicarbonate (for acids) or dilute acid (for bases) before cleaning.',
      'relatedConcepts': [
        'pH Scale',
        'Acids and Bases',
        'Neutralization',
        'Indicators',
        'Hydrogen Ion Concentration',
      ],
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d0d8b59b-1772367719711.png',
      'iconName': 'colorize',
      'tintColorValue': 0xFF0D2E3F,
      'semanticLabel':
          'Row of test tubes showing rainbow of colors from pH indicator acid base test',
    },
    {
      'id': 'ar6',
      'title': 'Elephant Toothpaste',
      'topic': 'Decomposition Reactions',
      'category': 'Chemical Reactions',
      'backgroundInfo':
          'Elephant Toothpaste is a dramatic decomposition reaction where hydrogen peroxide rapidly breaks down into water and oxygen gas, catalyzed by potassium iodide or yeast. The rapid release of oxygen creates a large foam eruption. This experiment demonstrates catalysis, decomposition reactions, and exothermic processes in a visually spectacular way.',
      'safetyNote':
          'Use only 3–6% hydrogen peroxide for classroom demonstrations. High-concentration H₂O₂ (30%+) causes severe burns and must only be handled by trained instructors with full PPE. The reaction is exothermic — the foam will be hot. Do not touch immediately after the reaction.',
      'relatedConcepts': [
        'Catalysis',
        'Decomposition Reactions',
        'Exothermic Reactions',
        'Hydrogen Peroxide',
        'Oxygen Gas',
      ],
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1ee613807-1784971685914.png',
      'iconName': 'waves',
      'tintColorValue': 0xFF1A2E0D,
      'semanticLabel':
          'Large colorful foam eruption from cylinder demonstrating elephant toothpaste reaction',
    },
    {
      'id': 'ar7',
      'title': 'Flame Test',
      'topic': 'Atomic Emission Spectra',
      'category': 'Spectroscopy',
      'backgroundInfo':
          'The flame test identifies metal ions by the characteristic colors they produce when heated in a flame. Each metal emits a unique color due to electrons jumping to higher energy levels and releasing photons of specific wavelengths when they return to ground state. Lithium burns red, sodium yellow, potassium lilac, copper green-blue, and barium pale green.',
      'safetyNote':
          'Always work near a fume hood or in a well-ventilated area. Tie back hair and avoid loose clothing near open flames. Use nichrome wire loops cleaned with hydrochloric acid between tests. Some metal salts (barium compounds) are toxic — wash hands thoroughly after handling.',
      'relatedConcepts': [
        'Atomic Emission Spectra',
        'Electron Energy Levels',
        'Photon Emission',
        'Metal Ion Identification',
        'Spectroscopy',
      ],
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1817773a0-1784320962469.png',
      'iconName': 'local_fire_department',
      'tintColorValue': 0xFF2E1A00,
      'semanticLabel':
          'Colorful flame test showing bright orange yellow and green flames from metal salts',
    },
  ];

final List<ArExperimentModel> dummyArExperiments = _experimentMaps
    .map((data) => ArExperimentModel.fromMap(data['id'] as String, data))
    .toList();
