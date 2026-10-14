// Periodic Table Data with exact 120-box mapping for AR Scanner
//
// Box Mapping:
// - Box 1 - 56: Elements 1 (H) to 56 (Ba)
// - Box 57: Lanthanide Series placeholder (La-Lu, 57-71)
// - Box 58 - 72: Elements 72 (Hf) to 86 (Rn)
// - Box 73: Element 87 (Fr)
// - Box 74: Element 88 (Ra)
// - Box 75: Actinide Series placeholder (Ac-Lr, 89-103)
// - Box 76 - 90: Elements 104 (Rf) to 118 (Og)
// - Box 91 - 105: Elements 57 (La) to 71 (Lu)
// - Box 106 - 120: Elements 89 (Ac) to 103 (Lr)

class ElementData {
  final int atomicNumber;
  final String symbol;
  final String name;
  final String category;
  final double atomicMass;
  final String funFact;
  final int? boxIndex;

  const ElementData({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.category,
    required this.atomicMass,
    required this.funFact,
    this.boxIndex,
  });
}

// ---------------------------------------------------------
// Standalone Placeholders for Series Markers (Boxes 57 & 75)
// ---------------------------------------------------------
const ElementData lanthanideSeriesPlaceholder = ElementData(
  boxIndex: 57,
  atomicNumber: 57,
  symbol: "57-71",
  name: "Lanthanide Series",
  category: "Rare Earth Elements (57-71)",
  atomicMass: 0,
  funFact:
      "The Lanthanide series comprises 15 metallic chemical elements with atomic numbers 57 through 71, from Lanthanum to Lutetium. They are commonly known as rare earth elements and are displayed in the row below the main table (Boxes 91 to 105).",
);

const ElementData actinideSeriesPlaceholder = ElementData(
  boxIndex: 75,
  atomicNumber: 89,
  symbol: "89-103",
  name: "Actinide Series",
  category: "Radioactive Elements (89-103)",
  atomicMass: 0,
  funFact:
      "The Actinide series encompasses 15 metallic chemical elements with atomic numbers 89 through 103, from Actinium to Lawrencium. All actinides are radioactive heavy metals and are displayed in the bottom row (Boxes 106 to 120).",
);

// Familiar objects and applications shown with elements 1-50 in the AR lab.
// These are examples of the element itself or of materials/compounds that
// contain or use it.
const Map<int, String> realWorldUsesByAtomicNumber = {
  1: "Rocket fuel — Hydrogen releases a large amount of energy when it reacts with oxygen, while producing water as exhaust.",
  2: "Balloons — Helium is lighter than air and does not burn, so it provides lift more safely than hydrogen.",
  3: "Rechargeable batteries — Lithium is very light and readily moves electrons, helping batteries store lots of energy for their weight.",
  4: "Nonmagnetic screwdrivers — Beryllium-copper alloys are strong, nonmagnetic, and resist sparking around sensitive equipment.",
  5: "Heat-resistant glass — Boron compounds reduce thermal expansion, so borosilicate glass is less likely to crack when heated.",
  6: "Graphite pencils — Carbon atoms in graphite form soft layers that slide off and leave a dark mark on paper.",
  7: "Plant fertilizer — Nitrogen is needed to make proteins and chlorophyll, so crops need nitrogen compounds for healthy growth.",
  8: "Scuba-diving tanks — Compressed oxygen-containing breathing gas supplies the oxygen a diver's body needs underwater.",
  9: "Fluoride toothpaste — Fluorine in fluoride compounds strengthens tooth enamel and makes it more resistant to acid decay.",
  10: "Glowing signs — Electrified neon gas emits a distinctive bright reddish-orange light.",
  11: "Table salt — Sodium ions combine with chloride ions to form sodium chloride, the salt used to season food.",
  12: "Emergency flares — Burning magnesium produces an extremely bright white light that is easy to see from far away.",
  13: "Drink cans — Aluminum is lightweight, corrosion-resistant, and easy to shape and recycle.",
  14: "Silicone spatulas — Silicon-based polymers can be flexible, nonstick, and resistant to cooking temperatures.",
  15: "Safety matches — Phosphorus on the striking surface helps ignite the match through friction.",
  16: "Gunpowder — Sulfur lowers the mixture's ignition temperature and helps it burn rapidly and consistently.",
  17: "Swimming-pool sanitizer — Chlorine compounds kill many harmful microorganisms in the water.",
  18: "Light bulbs — Inert argon protects the hot filament from reacting with oxygen and slows its evaporation.",
  19: "Bananas — Bananas naturally contain potassium, an electrolyte used by nerves and muscles.",
  20: "Milk — Milk supplies calcium, which the body uses to build and maintain bones and teeth.",
  21: "High-end bicycle frames — Scandium added to aluminum can produce a lighter, stronger alloy.",
  22: "Phone frames — Titanium combines high strength, low weight, and excellent corrosion resistance.",
  23: "Steel tools — Vanadium strengthens steel and improves its resistance to wear and fatigue.",
  24: "Stainless-steel knives — Chromium forms a thin protective oxide layer that helps stop steel from rusting.",
  25: "Alkaline batteries — Manganese dioxide helps accept electrons in the battery's chemical reaction.",
  26: "Magnets — Iron's magnetic domains can align, producing strong permanent or electromagnets.",
  27: "Lithium-ion batteries — Cobalt oxides can form stable, energy-dense cathodes that repeatedly store and release lithium ions.",
  28: "Coins — Nickel is hard and corrosion-resistant, helping coins survive years of handling.",
  29: "Electrical wire coils — Copper carries electricity very well and can be drawn into flexible wire.",
  30: "Anti-dandruff shampoo — Zinc compounds help control the yeast and scalp irritation associated with dandruff.",
  31: "LED light bulbs — Gallium-based semiconductors emit light efficiently when electric current passes through them.",
  32: "Camera lenses — Germanium transmits infrared light, making it useful in thermal-imaging lenses.",
  33: "Spacecraft electronics — Gallium arsenide performs reliably in efficient solar cells and high-frequency electronics used in space.",
  34: "Traffic signals — Selenium's light-sensitive and semiconductor properties have been used in sensors and lighting electronics.",
  35: "Fire extinguishers — Bromine compounds can interrupt the chemical chain reactions that keep a fire burning.",
  36: "High-performance flashlights — Krypton gas can help a filament lamp burn brighter than a similar ordinary bulb.",
  37: "Night-vision equipment — Rubidium can emit electrons when exposed to light, making it useful in photoelectric devices.",
  38: "Red fireworks — Heated strontium salts emit a vivid red light.",
  39: "Lasers — Yttrium crystals can host light-producing ions and withstand the heat generated inside solid-state lasers.",
  40: "Antiperspirant — Zirconium salts combine with aluminum salts to form temporary plugs that reduce sweat flow.",
  41: "Rings and jewelry — Niobium resists corrosion, is skin-friendly for many wearers, and can be anodized into bright colors.",
  42: "Multivitamins — Molybdenum is a trace nutrient that helps several enzymes process sulfur-containing compounds.",
  43: "Medical tracers — Technetium-99m emits detectable gamma rays and has a short half-life, making it useful for diagnostic scans.",
  44: "Telecommunications electronics — Ruthenium is used in durable electrical contacts and specialized resistors in electronic hardware.",
  45: "Dental mirrors — Rhodium provides a bright, hard, corrosion-resistant reflective coating.",
  46: "Professional flutes — Palladium-containing alloys resist tarnish and can provide a durable, polished finish.",
  47: "Necklaces — Silver is lustrous, easy to shape, and capable of taking a fine polish.",
  48: "Older rechargeable batteries — Nickel-cadmium cells use cadmium in an electrode because its reactions can be reversed during charging.",
  49: "Touchscreens — Indium tin oxide forms a transparent layer that conducts electricity and detects touch input.",
  50: "Food cans — Tin coatings protect steel from corrosion and help keep it from contacting the food.",
};

// ---------------------------------------------------------
// Elements by Atomic Number (1 - 118)
// ---------------------------------------------------------
final Map<int, ElementData> elementsByAtomicNumber = {
  1: const ElementData(
    atomicNumber: 1,
    symbol: "H",
    name: "Hydrogen",
    category: "Diatomic Nonmetal",
    atomicMass: 1.008,
    funFact:
        "Hydrogen is a chemical element with chemical symbol H and atomic number 1. With an atomic weight of 1.00794 u, hydrogen is the lightest element on the periodic table. Its monatomic form (H) is the most abundant chemical substance in the Universe, constituting roughly 75% of all baryonic mass.",
  ),
  2: const ElementData(
    atomicNumber: 2,
    symbol: "He",
    name: "Helium",
    category: "Noble Gas",
    atomicMass: 4.0026022,
    funFact:
        "Helium is a chemical element with symbol He and atomic number 2. It is a colorless, odorless, tasteless, non-toxic, inert, monatomic gas that heads the noble gas group in the periodic table. Its boiling and melting points are the lowest among all the elements.",
  ),
  3: const ElementData(
    atomicNumber: 3,
    symbol: "Li",
    name: "Lithium",
    category: "Alkali Metal",
    atomicMass: 6.94,
    funFact:
        "Lithium (from Greek:λίθος lithos, \"stone\") is a chemical element with the symbol Li and atomic number 3. It is a soft, silver-white metal belonging to the alkali metal group of chemical elements. Under standard conditions it is the lightest metal and the least dense solid element.",
  ),
  4: const ElementData(
    atomicNumber: 4,
    symbol: "Be",
    name: "Beryllium",
    category: "Alkaline Earth Metal",
    atomicMass: 9.01218315,
    funFact:
        "Beryllium is a chemical element with symbol Be and atomic number 4. It is created through stellar nucleosynthesis and is a relatively rare element in the universe. It is a divalent element which occurs naturally only in combination with other elements in minerals.",
  ),
  5: const ElementData(
    atomicNumber: 5,
    symbol: "B",
    name: "Boron",
    category: "Metalloid",
    atomicMass: 10.81,
    funFact:
        "Boron is a metalloid chemical element with symbol B and atomic number 5. Produced entirely by cosmic ray spallation and supernovae and not by stellar nucleosynthesis, it is a low-abundance element in both the Solar system and the Earth's crust. Boron is concentrated on Earth by the water-solubility of its more common naturally occurring compounds, the borate minerals.",
  ),
  6: const ElementData(
    atomicNumber: 6,
    symbol: "C",
    name: "Carbon",
    category: "Polyatomic Nonmetal",
    atomicMass: 12.011,
    funFact:
        "Carbon (from Latin:carbo \"coal\") is a chemical element with symbol C and atomic number 6. On the periodic table, it is the first (row 2) of six elements in column (group) 14, which have in common the composition of their outer electron shell. It is nonmetallic and tetravalent—making four electrons available to form covalent chemical bonds.",
  ),
  7: const ElementData(
    atomicNumber: 7,
    symbol: "N",
    name: "Nitrogen",
    category: "Diatomic Nonmetal",
    atomicMass: 14.007,
    funFact:
        "Nitrogen is a chemical element with symbol N and atomic number 7. It is the lightest pnictogen and at room temperature, it is a transparent, odorless diatomic gas. Nitrogen is a common element in the universe, estimated at about seventh in total abundance in the Milky Way and the Solar System.",
  ),
  8: const ElementData(
    atomicNumber: 8,
    symbol: "O",
    name: "Oxygen",
    category: "Diatomic Nonmetal",
    atomicMass: 15.999,
    funFact:
        "Oxygen is a chemical element with symbol O and atomic number 8. It is a member of the chalcogen group on the periodic table and is a highly reactive nonmetal and oxidizing agent that readily forms compounds (notably oxides) with most elements. By mass, oxygen is the third-most abundant element in the universe, after hydrogen and helium.",
  ),
  9: const ElementData(
    atomicNumber: 9,
    symbol: "F",
    name: "Fluorine",
    category: "Diatomic Nonmetal",
    atomicMass: 18.9984031636,
    funFact:
        "Fluorine is a chemical element with symbol F and atomic number 9. It is the lightest halogen and exists as a highly toxic pale yellow diatomic gas at standard conditions. As the most electronegative element, it is extremely reactive:almost all other elements, including some noble gases, form compounds with fluorine.",
  ),
  10: const ElementData(
    atomicNumber: 10,
    symbol: "Ne",
    name: "Neon",
    category: "Noble Gas",
    atomicMass: 20.17976,
    funFact:
        "Neon is a chemical element with symbol Ne and atomic number 10. It is in group 18 (noble gases) of the periodic table. Neon is a colorless, odorless, inert monatomic gas under standard conditions, with about two-thirds the density of air.",
  ),
  11: const ElementData(
    atomicNumber: 11,
    symbol: "Na",
    name: "Sodium",
    category: "Alkali Metal",
    atomicMass: 22.989769282,
    funFact:
        "Sodium /ˈsoʊdiəm/ is a chemical element with symbol Na (from Ancient Greek Νάτριο) and atomic number 11. It is a soft, silver-white, highly reactive metal. In the Periodic table it is in column 1 (alkali metals), and shares with the other six elements in that column that it has a single electron in its outer shell, which it readily donates, creating a positively charged atom - a cation.",
  ),
  12: const ElementData(
    atomicNumber: 12,
    symbol: "Mg",
    name: "Magnesium",
    category: "Alkaline Earth Metal",
    atomicMass: 24.305,
    funFact:
        "Magnesium is a chemical element with symbol Mg and atomic number 12. It is a shiny gray solid which bears a close physical resemblance to the other five elements in the second column (Group 2, or alkaline earth metals) of the periodic table:they each have the same electron configuration in their outer electron shell producing a similar crystal structure. Magnesium is the ninth most abundant element in the universe.",
  ),
  13: const ElementData(
    atomicNumber: 13,
    symbol: "Al",
    name: "Aluminium",
    category: "Post-Transition Metal",
    atomicMass: 26.98153857,
    funFact:
        "Aluminium (or aluminum; see different endings) is a chemical element in the boron group with symbol Al and atomic number 13. It is a silvery-white, soft, nonmagnetic, ductile metal. Aluminium is the third most abundant element (after oxygen and silicon), and the most abundant metal, in the Earth's crust.",
  ),
  14: const ElementData(
    atomicNumber: 14,
    symbol: "Si",
    name: "Silicon",
    category: "Metalloid",
    atomicMass: 28.085,
    funFact:
        "Silicon is a chemical element with symbol Si and atomic number 14. It is a tetravalent metalloid, more reactive than germanium, the metalloid directly below it in the table. Controversy about silicon's character dates to its discovery.",
  ),
  15: const ElementData(
    atomicNumber: 15,
    symbol: "P",
    name: "Phosphorus",
    category: "Polyatomic Nonmetal",
    atomicMass: 30.9737619985,
    funFact:
        "Phosphorus is a chemical element with symbol P and atomic number 15. As an element, phosphorus exists in two major forms—white phosphorus and red phosphorus—but due to its high reactivity, phosphorus is never found as a free element on Earth. Instead phosphorus-containing minerals are almost always present in their maximally oxidised state, as inorganic phosphate rocks.",
  ),
  16: const ElementData(
    atomicNumber: 16,
    symbol: "S",
    name: "Sulfur",
    category: "Polyatomic Nonmetal",
    atomicMass: 32.06,
    funFact:
        "Sulfur or sulphur (see spelling differences) is a chemical element with symbol S and atomic number 16. It is an abundant, multivalent non-metal. Under normal conditions, sulfur atoms form cyclic octatomic molecules with chemical formula S8.",
  ),
  17: const ElementData(
    atomicNumber: 17,
    symbol: "Cl",
    name: "Chlorine",
    category: "Diatomic Nonmetal",
    atomicMass: 35.45,
    funFact:
        "Chlorine is a chemical element with symbol Cl and atomic number 17. It also has a relative atomic mass of 35.5. Chlorine is in the halogen group (17) and is the second lightest halogen following fluorine.",
  ),
  18: const ElementData(
    atomicNumber: 18,
    symbol: "Ar",
    name: "Argon",
    category: "Noble Gas",
    atomicMass: 39.9481,
    funFact:
        "Argon is a chemical element with symbol Ar and atomic number 18. It is in group 18 of the periodic table and is a noble gas. Argon is the third most common gas in the Earth's atmosphere, at 0.934% (9,340 ppmv), making it over twice as abundant as the next most common atmospheric gas, water vapor (which averages about 4000 ppmv, but varies greatly), and 23 times as abundant as the next most common non-condensing atmospheric gas, carbon dioxide (400 ppmv), and more than 500 times as abundant as the next most common noble gas, neon (18 ppmv).",
  ),
  19: const ElementData(
    atomicNumber: 19,
    symbol: "K",
    name: "Potassium",
    category: "Alkali Metal",
    atomicMass: 39.09831,
    funFact:
        "Potassium is a chemical element with symbol K (derived from Neo-Latin, kalium) and atomic number 19. It was first isolated from potash, the ashes of plants, from which its name is derived. In the Periodic table, potassium is one of seven elements in column (group) 1 (alkali metals):they all have a single valence electron in their outer electron shell, which they readily give up to create an atom with a positive charge - a cation, and combine with anions to form salts.",
  ),
  20: const ElementData(
    atomicNumber: 20,
    symbol: "Ca",
    name: "Calcium",
    category: "Alkaline Earth Metal",
    atomicMass: 40.0784,
    funFact:
        "Calcium is a chemical element with symbol Ca and atomic number 20. Calcium is a soft gray alkaline earth metal, fifth-most-abundant element by mass in the Earth's crust. The ion Ca2+ is also the fifth-most-abundant dissolved ion in seawater by both molarity and mass, after sodium, chloride, magnesium, and sulfate.",
  ),
  21: const ElementData(
    atomicNumber: 21,
    symbol: "Sc",
    name: "Scandium",
    category: "Transition Metal",
    atomicMass: 44.9559085,
    funFact:
        "Scandium is a chemical element with symbol Sc and atomic number 21. A silvery-white metallic d-block element, it has historically been sometimes classified as a rare earth element, together with yttrium and the lanthanoids. It was discovered in 1879 by spectral analysis of the minerals euxenite and gadolinite from Scandinavia.",
  ),
  22: const ElementData(
    atomicNumber: 22,
    symbol: "Ti",
    name: "Titanium",
    category: "Transition Metal",
    atomicMass: 47.8671,
    funFact:
        "Titanium is a chemical element with symbol Ti and atomic number 22. It is a lustrous transition metal with a silver color, low density and high strength. It is highly resistant to corrosion in sea water, aqua regia and chlorine.",
  ),
  23: const ElementData(
    atomicNumber: 23,
    symbol: "V",
    name: "Vanadium",
    category: "Transition Metal",
    atomicMass: 50.94151,
    funFact:
        "Vanadium is a chemical element with symbol V and atomic number 23. It is a hard, silvery grey, ductile and malleable transition metal. The element is found only in chemically combined form in nature, but once isolated artificially, the formation of an oxide layer stabilizes the free metal somewhat against further oxidation.",
  ),
  24: const ElementData(
    atomicNumber: 24,
    symbol: "Cr",
    name: "Chromium",
    category: "Transition Metal",
    atomicMass: 51.99616,
    funFact:
        "Chromium is a chemical element with symbol Cr and atomic number 24. It is the first element in Group 6. It is a steely-gray, lustrous, hard and brittle metal which takes a high polish, resists tarnishing, and has a high melting point.",
  ),
  25: const ElementData(
    atomicNumber: 25,
    symbol: "Mn",
    name: "Manganese",
    category: "Transition Metal",
    atomicMass: 54.9380443,
    funFact:
        "Manganese is a chemical element with symbol Mn and atomic number 25. It is not found as a free element in nature; it is often found in combination with iron, and in many minerals. Manganese is a metal with important industrial metal alloy uses, particularly in stainless steels.",
  ),
  26: const ElementData(
    atomicNumber: 26,
    symbol: "Fe",
    name: "Iron",
    category: "Transition Metal",
    atomicMass: 55.8452,
    funFact:
        "Iron is a chemical element with symbol Fe (from Latin:ferrum) and atomic number 26. It is a metal in the first transition series. It is by mass the most common element on Earth, forming much of Earth's outer and inner core.",
  ),
  27: const ElementData(
    atomicNumber: 27,
    symbol: "Co",
    name: "Cobalt",
    category: "Transition Metal",
    atomicMass: 58.9331944,
    funFact:
        "Cobalt is a chemical element with symbol Co and atomic number 27. Like nickel, cobalt in the Earth's crust is found only in chemically combined form, save for small deposits found in alloys of natural meteoric iron. The free element, produced by reductive smelting, is a hard, lustrous, silver-gray metal.",
  ),
  28: const ElementData(
    atomicNumber: 28,
    symbol: "Ni",
    name: "Nickel",
    category: "Transition Metal",
    atomicMass: 58.69344,
    funFact:
        "Nickel is a chemical element with symbol Ni and atomic number 28. It is a silvery-white lustrous metal with a slight golden tinge. Nickel belongs to the transition metals and is hard and ductile.",
  ),
  29: const ElementData(
    atomicNumber: 29,
    symbol: "Cu",
    name: "Copper",
    category: "Transition Metal",
    atomicMass: 63.5463,
    funFact:
        "Copper is a chemical element with symbol Cu (from Latin:cuprum) and atomic number 29. It is a soft, malleable and ductile metal with very high thermal and electrical conductivity. A freshly exposed surface of pure copper has a reddish-orange color.",
  ),
  30: const ElementData(
    atomicNumber: 30,
    symbol: "Zn",
    name: "Zinc",
    category: "Transition Metal",
    atomicMass: 65.382,
    funFact:
        "Zinc, in commerce also spelter, is a chemical element with symbol Zn and atomic number 30. It is the first element of group 12 of the periodic table. In some respects zinc is chemically similar to magnesium:its ion is of similar size and its only common oxidation state is +2.",
  ),
  31: const ElementData(
    atomicNumber: 31,
    symbol: "Ga",
    name: "Gallium",
    category: "Post-Transition Metal",
    atomicMass: 69.7231,
    funFact:
        "Gallium is a chemical element with symbol Ga and atomic number 31. Elemental gallium does not occur in free form in nature, but as the gallium(III) compounds that are in trace amounts in zinc ores and in bauxite. Gallium is a soft, silvery metal, and elemental gallium is a brittle solid at low temperatures, and melts at 29.76 °C (85.57 °F) (slightly above room temperature).",
  ),
  32: const ElementData(
    atomicNumber: 32,
    symbol: "Ge",
    name: "Germanium",
    category: "Metalloid",
    atomicMass: 72.6308,
    funFact:
        "Germanium is a chemical element with symbol Ge and atomic number 32. It is a lustrous, hard, grayish-white metalloid in the carbon group, chemically similar to its group neighbors tin and silicon. Purified germanium is a semiconductor, with an appearance most similar to elemental silicon.",
  ),
  33: const ElementData(
    atomicNumber: 33,
    symbol: "As",
    name: "Arsenic",
    category: "Metalloid",
    atomicMass: 74.9215956,
    funFact:
        "Arsenic is a chemical element with symbol As and atomic number 33. Arsenic occurs in many minerals, usually in conjunction with sulfur and metals, and also as a pure elemental crystal. Arsenic is a metalloid.",
  ),
  34: const ElementData(
    atomicNumber: 34,
    symbol: "Se",
    name: "Selenium",
    category: "Polyatomic Nonmetal",
    atomicMass: 78.9718,
    funFact:
        "Selenium is a chemical element with symbol Se and atomic number 34. It is a nonmetal with properties that are intermediate between those of its periodic table column-adjacent chalcogen elements sulfur and tellurium. It rarely occurs in its elemental state in nature, or as pure ore compounds.",
  ),
  35: const ElementData(
    atomicNumber: 35,
    symbol: "Br",
    name: "Bromine",
    category: "Diatomic Nonmetal",
    atomicMass: 79.904,
    funFact:
        "Bromine (from Ancient Greek:βρῶμος, brómos, meaning \"stench\") is a chemical element with symbol Br, and atomic number 35. It is a halogen. The element was isolated independently by two chemists, Carl Jacob Löwig and Antoine Jerome Balard, in 1825–1826.",
  ),
  36: const ElementData(
    atomicNumber: 36,
    symbol: "Kr",
    name: "Krypton",
    category: "Noble Gas",
    atomicMass: 83.7982,
    funFact:
        "Krypton (from Greek:κρυπτός kryptos \"the hidden one\") is a chemical element with symbol Kr and atomic number 36. It is a member of group 18 (noble gases) elements. A colorless, odorless, tasteless noble gas, krypton occurs in trace amounts in the atmosphere, is isolated by fractionally distilling liquefied air, and is often used with other rare gases in fluorescent lamps.",
  ),
  37: const ElementData(
    atomicNumber: 37,
    symbol: "Rb",
    name: "Rubidium",
    category: "Alkali Metal",
    atomicMass: 85.46783,
    funFact:
        "Rubidium is a chemical element with symbol Rb and atomic number 37. Rubidium is a soft, silvery-white metallic element of the alkali metal group, with an atomic mass of 85.4678. Elemental rubidium is highly reactive, with properties similar to those of other alkali metals, such as very rapid oxidation in air.",
  ),
  38: const ElementData(
    atomicNumber: 38,
    symbol: "Sr",
    name: "Strontium",
    category: "Alkaline Earth Metal",
    atomicMass: 87.621,
    funFact:
        "Strontium is a chemical element with symbol Sr and atomic number 38. An alkaline earth metal, strontium is a soft silver-white or yellowish metallic element that is highly reactive chemically. The metal turns yellow when it is exposed to air.",
  ),
  39: const ElementData(
    atomicNumber: 39,
    symbol: "Y",
    name: "Yttrium",
    category: "Transition Metal",
    atomicMass: 88.905842,
    funFact:
        "Yttrium is a chemical element with symbol Y and atomic number 39. It is a silvery-metallic transition metal chemically similar to the lanthanides and it has often been classified as a \"rare earth element\". Yttrium is almost always found combined with the lanthanides in rare earth minerals and is never found in nature as a free element.",
  ),
  40: const ElementData(
    atomicNumber: 40,
    symbol: "Zr",
    name: "Zirconium",
    category: "Transition Metal",
    atomicMass: 91.2242,
    funFact:
        "Zirconium is a chemical element with symbol Zr and atomic number 40. The name of zirconium is taken from the name of the mineral zircon, the most important source of zirconium. The word zircon comes from the Persian word zargun زرگون, meaning \"gold-colored\".",
  ),
  41: const ElementData(
    atomicNumber: 41,
    symbol: "Nb",
    name: "Niobium",
    category: "Transition Metal",
    atomicMass: 92.906372,
    funFact:
        "Niobium, formerly columbium, is a chemical element with symbol Nb (formerly Cb) and atomic number 41. It is a soft, grey, ductile transition metal, which is often found in the pyrochlore mineral, the main commercial source for niobium, and columbite. The name comes from Greek mythology:Niobe, daughter of Tantalus since it is so similar to tantalum.",
  ),
  42: const ElementData(
    atomicNumber: 42,
    symbol: "Mo",
    name: "Molybdenum",
    category: "Transition Metal",
    atomicMass: 95.951,
    funFact:
        "Molybdenum is a chemical element with symbol Mo and atomic number 42. The name is from Neo-Latin molybdaenum, from Ancient Greek Μόλυβδος molybdos, meaning lead, since its ores were confused with lead ores. Molybdenum minerals have been known throughout history, but the element was discovered (in the sense of differentiating it as a new entity from the mineral salts of other metals) in 1778 by Carl Wilhelm Scheele.",
  ),
  43: const ElementData(
    atomicNumber: 43,
    symbol: "Tc",
    name: "Technetium",
    category: "Transition Metal",
    atomicMass: 98.0,
    funFact:
        "Technetium (/tɛkˈniːʃiəm/) is a chemical element with symbol Tc and atomic number 43. It is the element with the lowest atomic number in the periodic table that has no stable isotopes:every form of it is radioactive. Nearly all technetium is produced synthetically, and only minute amounts are found in nature.",
  ),
  44: const ElementData(
    atomicNumber: 44,
    symbol: "Ru",
    name: "Ruthenium",
    category: "Transition Metal",
    atomicMass: 101.072,
    funFact:
        "Ruthenium is a chemical element with symbol Ru and atomic number 44. It is a rare transition metal belonging to the platinum group of the periodic table. Like the other metals of the platinum group, ruthenium is inert to most other chemicals.",
  ),
  45: const ElementData(
    atomicNumber: 45,
    symbol: "Rh",
    name: "Rhodium",
    category: "Transition Metal",
    atomicMass: 102.905502,
    funFact:
        "Rhodium is a chemical element with symbol Rh and atomic number 45. It is a rare, silvery-white, hard, and chemically inert transition metal. It is a member of the platinum group.",
  ),
  46: const ElementData(
    atomicNumber: 46,
    symbol: "Pd",
    name: "Palladium",
    category: "Transition Metal",
    atomicMass: 106.421,
    funFact:
        "Palladium is a chemical element with symbol Pd and atomic number 46. It is a rare and lustrous silvery-white metal discovered in 1803 by William Hyde Wollaston. He named it after the asteroid Pallas, which was itself named after the epithet of the Greek goddess Athena, acquired by her when she slew Pallas.",
  ),
  47: const ElementData(
    atomicNumber: 47,
    symbol: "Ag",
    name: "Silver",
    category: "Transition Metal",
    atomicMass: 107.86822,
    funFact:
        "Silver is a chemical element with symbol Ag (Greek:άργυρος árguros, Latin:argentum, both from the Indo-European root *h₂erǵ- for \"grey\" or \"shining\") and atomic number 47. A soft, white, lustrous transition metal, it possesses the highest electrical conductivity, thermal conductivity and reflectivity of any metal. The metal occurs naturally in its pure, free form (native silver), as an alloy with gold and other metals, and in minerals such as argentite and chlorargyrite.",
  ),
  48: const ElementData(
    atomicNumber: 48,
    symbol: "Cd",
    name: "Cadmium",
    category: "Transition Metal",
    atomicMass: 112.4144,
    funFact:
        "Cadmium is a chemical element with symbol Cd and atomic number 48. This soft, bluish-white metal is chemically similar to the two other stable metals in group 12, zinc and mercury. Like zinc, it prefers oxidation state +2 in most of its compounds and like mercury it shows a low melting point compared to transition metals.",
  ),
  49: const ElementData(
    atomicNumber: 49,
    symbol: "In",
    name: "Indium",
    category: "Post-Transition Metal",
    atomicMass: 114.8181,
    funFact:
        "Indium is a chemical element with symbol In and atomic number 49. It is a post-transition metallic element that is rare in Earth's crust. The metal is very soft, malleable and easily fusible, with a melting point higher than sodium, but lower than lithium or tin.",
  ),
  50: const ElementData(
    atomicNumber: 50,
    symbol: "Sn",
    name: "Tin",
    category: "Post-Transition Metal",
    atomicMass: 118.7107,
    funFact:
        "Tin is a chemical element with the symbol Sn (for Latin:stannum) and atomic number 50. It is a main group metal in group 14 of the periodic table. Tin shows a chemical similarity to both neighboring group-14 elements, germanium and lead, and has two possible oxidation states, +2 and the slightly more stable +4.",
  ),
  51: const ElementData(
    atomicNumber: 51,
    symbol: "Sb",
    name: "Antimony",
    category: "Metalloid",
    atomicMass: 121.7601,
    funFact:
        "Antimony is a chemical element with symbol Sb (from Latin:stibium) and atomic number 51. A lustrous gray metalloid, it is found in nature mainly as the sulfide mineral stibnite (Sb2S3). Antimony compounds have been known since ancient times and were used for cosmetics; metallic antimony was also known, but it was erroneously identified as lead upon its discovery.",
  ),
  52: const ElementData(
    atomicNumber: 52,
    symbol: "Te",
    name: "Tellurium",
    category: "Metalloid",
    atomicMass: 127.603,
    funFact:
        "Tellurium is a chemical element with symbol Te and atomic number 52. It is a brittle, mildly toxic, rare, silver-white metalloid. Tellurium is chemically related to selenium and sulfur.",
  ),
  53: const ElementData(
    atomicNumber: 53,
    symbol: "I",
    name: "Iodine",
    category: "Diatomic Nonmetal",
    atomicMass: 126.904473,
    funFact:
        "Iodine is a chemical element with symbol I and atomic number 53. The name is from Greek ἰοειδής ioeidēs, meaning violet or purple, due to the color of iodine vapor. Iodine and its compounds are primarily used in nutrition, and industrially in the production of acetic acid and certain polymers.",
  ),
  54: const ElementData(
    atomicNumber: 54,
    symbol: "Xe",
    name: "Xenon",
    category: "Noble Gas",
    atomicMass: 131.2936,
    funFact:
        "Xenon is a chemical element with symbol Xe and atomic number 54. It is a colorless, dense, odorless noble gas, that occurs in the Earth's atmosphere in trace amounts. Although generally unreactive, xenon can undergo a few chemical reactions such as the formation of xenon hexafluoroplatinate, the first noble gas compound to be synthesized.",
  ),
  55: const ElementData(
    atomicNumber: 55,
    symbol: "Cs",
    name: "Cesium",
    category: "Alkali Metal",
    atomicMass: 132.905451966,
    funFact:
        "Caesium or cesium is a chemical element with symbol Cs and atomic number 55. It is a soft, silvery-gold alkali metal with a melting point of 28 °C (82 °F), which makes it one of only five elemental metals that are liquid at or near room temperature. Caesium is an alkali metal and has physical and chemical properties similar to those of rubidium and potassium.",
  ),
  56: const ElementData(
    atomicNumber: 56,
    symbol: "Ba",
    name: "Barium",
    category: "Alkaline Earth Metal",
    atomicMass: 137.3277,
    funFact:
        "Barium is a chemical element with symbol Ba and atomic number 56. It is the fifth element in Group 2, a soft silvery metallic alkaline earth metal. Because of its high chemical reactivity barium is never found in nature as a free element.",
  ),
  57: const ElementData(
    atomicNumber: 57,
    symbol: "La",
    name: "Lanthanum",
    category: "Lanthanide",
    atomicMass: 138.905477,
    funFact:
        "Lanthanum is a soft, ductile, silvery-white metallic chemical element with symbol La and atomic number 57. It tarnishes rapidly when exposed to air and is soft enough to be cut with a knife. It gave its name to the lanthanide series, a group of 15 similar elements between lanthanum and lutetium in the periodic table:it is also sometimes considered the first element of the 6th-period transition metals.",
  ),
  58: const ElementData(
    atomicNumber: 58,
    symbol: "Ce",
    name: "Cerium",
    category: "Lanthanide",
    atomicMass: 140.1161,
    funFact:
        "Cerium is a chemical element with symbol Ce and atomic number 58. It is a soft, silvery, ductile metal which easily oxidizes in air. Cerium was named after the dwarf planet Ceres (itself named after the Roman goddess of agriculture).",
  ),
  59: const ElementData(
    atomicNumber: 59,
    symbol: "Pr",
    name: "Praseodymium",
    category: "Lanthanide",
    atomicMass: 140.907662,
    funFact:
        "Praseodymium is a chemical element with symbol Pr and atomic number 59. Praseodymium is a soft, silvery, malleable and ductile metal in the lanthanide group. It is valued for its magnetic, electrical, chemical, and optical properties.",
  ),
  60: const ElementData(
    atomicNumber: 60,
    symbol: "Nd",
    name: "Neodymium",
    category: "Lanthanide",
    atomicMass: 144.2423,
    funFact:
        "Neodymium is a chemical element with symbol Nd and atomic number 60. It is a soft silvery metal that tarnishes in air. Neodymium was discovered in 1885 by the Austrian chemist Carl Auer von Welsbach.",
  ),
  61: const ElementData(
    atomicNumber: 61,
    symbol: "Pm",
    name: "Promethium",
    category: "Lanthanide",
    atomicMass: 145.0,
    funFact:
        "Promethium, originally prometheum, is a chemical element with the symbol Pm and atomic number 61. All of its isotopes are radioactive; it is one of only two such elements that are followed in the periodic table by elements with stable forms, a distinction shared with technetium. Chemically, promethium is a lanthanide, which forms salts when combined with other elements.",
  ),
  62: const ElementData(
    atomicNumber: 62,
    symbol: "Sm",
    name: "Samarium",
    category: "Lanthanide",
    atomicMass: 150.362,
    funFact:
        "Samarium is a chemical element with symbol Sm and atomic number 62. It is a moderately hard silvery metal that readily oxidizes in air. Being a typical member of the lanthanide series, samarium usually assumes the oxidation state +3.",
  ),
  63: const ElementData(
    atomicNumber: 63,
    symbol: "Eu",
    name: "Europium",
    category: "Lanthanide",
    atomicMass: 151.9641,
    funFact:
        "Europium is a chemical element with symbol Eu and atomic number 63. It was isolated in 1901 and is named after the continent of Europe. It is a moderately hard, silvery metal which readily oxidizes in air and water.",
  ),
  64: const ElementData(
    atomicNumber: 64,
    symbol: "Gd",
    name: "Gadolinium",
    category: "Lanthanide",
    atomicMass: 157.253,
    funFact:
        "Gadolinium is a chemical element with symbol Gd and atomic number 64. It is a silvery-white, malleable and ductile rare-earth metal. It is found in nature only in combined (salt) form.",
  ),
  65: const ElementData(
    atomicNumber: 65,
    symbol: "Tb",
    name: "Terbium",
    category: "Lanthanide",
    atomicMass: 158.925352,
    funFact:
        "Terbium is a chemical element with symbol Tb and atomic number 65. It is a silvery-white rare earth metal that is malleable, ductile and soft enough to be cut with a knife. Terbium is never found in nature as a free element, but it is contained in many minerals, including cerite, gadolinite, monazite, xenotime and euxenite.",
  ),
  66: const ElementData(
    atomicNumber: 66,
    symbol: "Dy",
    name: "Dysprosium",
    category: "Lanthanide",
    atomicMass: 162.5001,
    funFact:
        "Dysprosium is a chemical element with the symbol Dy and atomic number 66. It is a rare earth element with a metallic silver luster. Dysprosium is never found in nature as a free element, though it is found in various minerals, such as xenotime.",
  ),
  67: const ElementData(
    atomicNumber: 67,
    symbol: "Ho",
    name: "Holmium",
    category: "Lanthanide",
    atomicMass: 164.930332,
    funFact:
        "Holmium is a chemical element with symbol Ho and atomic number 67. Part of the lanthanide series, holmium is a rare earth element. Holmium was discovered by Swedish chemist Per Theodor Cleve.",
  ),
  68: const ElementData(
    atomicNumber: 68,
    symbol: "Er",
    name: "Erbium",
    category: "Lanthanide",
    atomicMass: 167.2593,
    funFact:
        "Erbium is a chemical element in the lanthanide series, with symbol Er and atomic number 68. A silvery-white solid metal when artificially isolated, natural erbium is always found in chemical combination with other elements on Earth. As such, it is a rare earth element which is associated with several other rare elements in the mineral gadolinite from Ytterby in Sweden, where yttrium, ytterbium, and terbium were discovered.",
  ),
  69: const ElementData(
    atomicNumber: 69,
    symbol: "Tm",
    name: "Thulium",
    category: "Lanthanide",
    atomicMass: 168.934222,
    funFact:
        "Thulium is a chemical element with symbol Tm and atomic number 69. It is the thirteenth and antepenultimate (third-last) element in the lanthanide series. Like the other lanthanides, the most common oxidation state is +3, seen in its oxide, halides and other compounds.",
  ),
  70: const ElementData(
    atomicNumber: 70,
    symbol: "Yb",
    name: "Ytterbium",
    category: "Lanthanide",
    atomicMass: 173.0451,
    funFact:
        "Ytterbium is a chemical element with symbol Yb and atomic number 70. It is the fourteenth and penultimate element in the lanthanide series, which is the basis of the relative stability of its +2 oxidation state. However, like the other lanthanides, its most common oxidation state is +3, seen in its oxide, halides and other compounds.",
  ),
  71: const ElementData(
    atomicNumber: 71,
    symbol: "Lu",
    name: "Lutetium",
    category: "Lanthanide",
    atomicMass: 174.96681,
    funFact:
        "Lutetium is a chemical element with symbol Lu and atomic number 71. It is a silvery white metal, which resists corrosion in dry, but not in moist air. It is considered the first element of the 6th-period transition metals and the last element in the lanthanide series, and is traditionally counted among the rare earths.",
  ),
  72: const ElementData(
    atomicNumber: 72,
    symbol: "Hf",
    name: "Hafnium",
    category: "Transition Metal",
    atomicMass: 178.492,
    funFact:
        "Hafnium is a chemical element with symbol Hf and atomic number 72. A lustrous, silvery gray, tetravalent transition metal, hafnium chemically resembles zirconium and is found in zirconium minerals. Its existence was predicted by Dmitri Mendeleev in 1869, though it was not identified until 1923, making it the penultimate stable element to be discovered (rhenium was identified two years later).",
  ),
  73: const ElementData(
    atomicNumber: 73,
    symbol: "Ta",
    name: "Tantalum",
    category: "Transition Metal",
    atomicMass: 180.947882,
    funFact:
        "Tantalum is a chemical element with symbol Ta and atomic number 73. Previously known as tantalium, its name comes from Tantalus, an antihero from Greek mythology. Tantalum is a rare, hard, blue-gray, lustrous transition metal that is highly corrosion-resistant.",
  ),
  74: const ElementData(
    atomicNumber: 74,
    symbol: "W",
    name: "Tungsten",
    category: "Transition Metal",
    atomicMass: 183.841,
    funFact:
        "Tungsten, also known as wolfram, is a chemical element with symbol W and atomic number 74. The word tungsten comes from the Swedish language tung sten, which directly translates to heavy stone. Its name in Swedish is volfram, however, in order to distinguish it from scheelite, which in Swedish is alternatively named tungsten.",
  ),
  75: const ElementData(
    atomicNumber: 75,
    symbol: "Re",
    name: "Rhenium",
    category: "Transition Metal",
    atomicMass: 186.2071,
    funFact:
        "Rhenium is a chemical element with symbol Re and atomic number 75. It is a silvery-white, heavy, third-row transition metal in group 7 of the periodic table. With an estimated average concentration of 1 part per billion (ppb), rhenium is one of the rarest elements in the Earth's crust.",
  ),
  76: const ElementData(
    atomicNumber: 76,
    symbol: "Os",
    name: "Osmium",
    category: "Transition Metal",
    atomicMass: 190.233,
    funFact:
        "Osmium (from Greek osme (ὀσμή) meaning \"smell\") is a chemical element with symbol Os and atomic number 76. It is a hard, brittle, bluish-white transition metal in the platinum group that is found as a trace element in alloys, mostly in platinum ores. Osmium is the densest naturally occurring element, with a density of 22.59 g/cm3.",
  ),
  77: const ElementData(
    atomicNumber: 77,
    symbol: "Ir",
    name: "Iridium",
    category: "Transition Metal",
    atomicMass: 192.2173,
    funFact:
        "Iridium is a chemical element with symbol Ir and atomic number 77. A very hard, brittle, silvery-white transition metal of the platinum group, iridium is generally credited with being the second densest element (after osmium) based on measured density, although calculations involving the space lattices of the elements show that iridium is denser. It is also the most corrosion-resistant metal, even at temperatures as high as 2000 °C. Although only certain molten salts and halogens are corrosive to solid iridium, finely divided iridium dust is much more reactive and can be flammable.",
  ),
  78: const ElementData(
    atomicNumber: 78,
    symbol: "Pt",
    name: "Platinum",
    category: "Transition Metal",
    atomicMass: 195.0849,
    funFact:
        "Platinum is a chemical element with symbol Pt and atomic number 78. It is a dense, malleable, ductile, highly unreactive, precious, gray-white transition metal. Its name is derived from the Spanish term platina, which is literally translated into \"little silver\".",
  ),
  79: const ElementData(
    atomicNumber: 79,
    symbol: "Au",
    name: "Gold",
    category: "Transition Metal",
    atomicMass: 196.9665695,
    funFact:
        "Gold is a chemical element with symbol Au (from Latin:aurum) and atomic number 79. In its purest form, it is a bright, slightly reddish yellow, dense, soft, malleable and ductile metal. Chemically, gold is a transition metal and a group 11 element.",
  ),
  80: const ElementData(
    atomicNumber: 80,
    symbol: "Hg",
    name: "Mercury",
    category: "Transition Metal",
    atomicMass: 200.5923,
    funFact:
        "Mercury is a chemical element with symbol Hg and atomic number 80. It is commonly known as quicksilver and was formerly named hydrargyrum (/haɪˈdrɑːrdʒərəm/). A heavy, silvery d-block element, mercury is the only metallic element that is liquid at standard conditions for temperature and pressure; the only other element that is liquid under these conditions is bromine, though metals such as caesium, gallium, and rubidium melt just above room temperature.",
  ),
  81: const ElementData(
    atomicNumber: 81,
    symbol: "Tl",
    name: "Thallium",
    category: "Post-Transition Metal",
    atomicMass: 204.38,
    funFact:
        "Thallium is a chemical element with symbol Tl and atomic number 81. This soft gray post-transition metal is not found free in nature. When isolated, it resembles tin, but discolors when exposed to air.",
  ),
  82: const ElementData(
    atomicNumber: 82,
    symbol: "Pb",
    name: "Lead",
    category: "Post-Transition Metal",
    atomicMass: 207.21,
    funFact:
        "Lead (/lɛd/) is a chemical element in the carbon group with symbol Pb (from Latin:plumbum) and atomic number 82. Lead is a soft, malleable and heavy post-transition metal. Metallic lead has a bluish-white color after being freshly cut, but it soon tarnishes to a dull grayish color when exposed to air.",
  ),
  83: const ElementData(
    atomicNumber: 83,
    symbol: "Bi",
    name: "Bismuth",
    category: "Post-Transition Metal",
    atomicMass: 208.980401,
    funFact:
        "Bismuth is a chemical element with symbol Bi and atomic number 83. Bismuth, a pentavalent post-transition metal, chemically resembles arsenic and antimony. Elemental bismuth may occur naturally, although its sulfide and oxide form important commercial ores.",
  ),
  84: const ElementData(
    atomicNumber: 84,
    symbol: "Po",
    name: "Polonium",
    category: "Post-Transition Metal",
    atomicMass: 209.0,
    funFact:
        "Polonium is a chemical element with symbol Po and atomic number 84, discovered in 1898 by Marie Curie and Pierre Curie. A rare and highly radioactive element with no stable isotopes, polonium is chemically similar to bismuth and tellurium, and it occurs in uranium ores. Applications of polonium are few.",
  ),
  85: const ElementData(
    atomicNumber: 85,
    symbol: "At",
    name: "Astatine",
    category: "Metalloid",
    atomicMass: 210.0,
    funFact:
        "Astatine is a very rare radioactive chemical element with the chemical symbol At and atomic number 85. It occurs on Earth as the decay product of various heavier elements. All its isotopes are short-lived; the most stable is astatine-210, with a half-life of 8.1 hours.",
  ),
  86: const ElementData(
    atomicNumber: 86,
    symbol: "Rn",
    name: "Radon",
    category: "Noble Gas",
    atomicMass: 222.0,
    funFact:
        "Radon is a chemical element with symbol Rn and atomic number 86. It is a radioactive, colorless, odorless, tasteless noble gas, occurring naturally as a decay product of radium. Its most stable isotope, 222Rn, has a half-life of 3.8 days.",
  ),
  87: const ElementData(
    atomicNumber: 87,
    symbol: "Fr",
    name: "Francium",
    category: "Alkali Metal",
    atomicMass: 223.0,
    funFact:
        "Francium is a chemical element with symbol Fr and atomic number 87. It used to be known as eka-caesium and actinium K. It is the second-least electronegative element, behind only caesium. Francium is a highly radioactive metal that decays into astatine, radium, and radon.",
  ),
  88: const ElementData(
    atomicNumber: 88,
    symbol: "Ra",
    name: "Radium",
    category: "Alkaline Earth Metal",
    atomicMass: 226.0,
    funFact:
        "Radium is a chemical element with symbol Ra and atomic number 88. It is the sixth element in group 2 of the periodic table, also known as the alkaline earth metals. Pure radium is almost colorless, but it readily combines with nitrogen (rather than oxygen) on exposure to air, forming a black surface layer of radium nitride (Ra3N2).",
  ),
  89: const ElementData(
    atomicNumber: 89,
    symbol: "Ac",
    name: "Actinium",
    category: "Actinide",
    atomicMass: 227.0,
    funFact:
        "Actinium is a radioactive chemical element with symbol Ac (not to be confused with the abbreviation for an acetyl group) and atomic number 89, which was discovered in 1899. It was the first non-primordial radioactive element to be isolated. Polonium, radium and radon were observed before actinium, but they were not isolated until 1902.",
  ),
  90: const ElementData(
    atomicNumber: 90,
    symbol: "Th",
    name: "Thorium",
    category: "Actinide",
    atomicMass: 232.03774,
    funFact:
        "Thorium is a chemical element with symbol Th and atomic number 90. A radioactive actinide metal, thorium is one of only two significantly radioactive elements that still occur naturally in large quantities as a primordial element (the other being uranium). It was discovered in 1828 by the Norwegian Reverend and amateur mineralogist Morten Thrane Esmark and identified by the Swedish chemist Jöns Jakob Berzelius, who named it after Thor, the Norse god of thunder.",
  ),
  91: const ElementData(
    atomicNumber: 91,
    symbol: "Pa",
    name: "Protactinium",
    category: "Actinide",
    atomicMass: 231.035882,
    funFact:
        "Protactinium is a chemical element with symbol Pa and atomic number 91. It is a dense, silvery-gray metal which readily reacts with oxygen, water vapor and inorganic acids. It forms various chemical compounds where protactinium is usually present in the oxidation state +5, but can also assume +4 and even +2 or +3 states.",
  ),
  92: const ElementData(
    atomicNumber: 92,
    symbol: "U",
    name: "Uranium",
    category: "Actinide",
    atomicMass: 238.028913,
    funFact:
        "Uranium is a chemical element with symbol U and atomic number 92. It is a silvery-white metal in the actinide series of the periodic table. A uranium atom has 92 protons and 92 electrons, of which 6 are valence electrons.",
  ),
  93: const ElementData(
    atomicNumber: 93,
    symbol: "Np",
    name: "Neptunium",
    category: "Actinide",
    atomicMass: 237.0,
    funFact:
        "Neptunium is a chemical element with symbol Np and atomic number 93. A radioactive actinide metal, neptunium is the first transuranic element. Its position in the periodic table just after uranium, named after the planet Uranus, led to it being named after Neptune, the next planet beyond Uranus.",
  ),
  94: const ElementData(
    atomicNumber: 94,
    symbol: "Pu",
    name: "Plutonium",
    category: "Actinide",
    atomicMass: 244.0,
    funFact:
        "Plutonium is a transuranic radioactive chemical element with symbol Pu and atomic number 94. It is an actinide metal of silvery-gray appearance that tarnishes when exposed to air, and forms a dull coating when oxidized. The element normally exhibits six allotropes and four oxidation states.",
  ),
  95: const ElementData(
    atomicNumber: 95,
    symbol: "Am",
    name: "Americium",
    category: "Actinide",
    atomicMass: 243.0,
    funFact:
        "Americium is a radioactive transuranic chemical element with symbol Am and atomic number 95. This member of the actinide series is located in the periodic table under the lanthanide element europium, and thus by analogy was named after the Americas. Americium was first produced in 1944 by the group of Glenn T.Seaborg from Berkeley, California, at the metallurgical laboratory of University of Chicago.",
  ),
  96: const ElementData(
    atomicNumber: 96,
    symbol: "Cm",
    name: "Curium",
    category: "Actinide",
    atomicMass: 247.0,
    funFact:
        "Curium is a transuranic radioactive chemical element with symbol Cm and atomic number 96. This element of the actinide series was named after Marie and Pierre Curie – both were known for their research on radioactivity. Curium was first intentionally produced and identified in July 1944 by the group of Glenn T. Seaborg at the University of California, Berkeley.",
  ),
  97: const ElementData(
    atomicNumber: 97,
    symbol: "Bk",
    name: "Berkelium",
    category: "Actinide",
    atomicMass: 247.0,
    funFact:
        "Berkelium is a transuranic radioactive chemical element with symbol Bk and atomic number 97. It is a member of the actinide and transuranium element series. It is named after the city of Berkeley, California, the location of the University of California Radiation Laboratory where it was discovered in December 1949.",
  ),
  98: const ElementData(
    atomicNumber: 98,
    symbol: "Cf",
    name: "Californium",
    category: "Actinide",
    atomicMass: 251.0,
    funFact:
        "Californium is a radioactive metallic chemical element with symbol Cf and atomic number 98. The element was first made in 1950 at the University of California Radiation Laboratory in Berkeley, by bombarding curium with alpha particles (helium-4 ions). It is an actinide element, the sixth transuranium element to be synthesized, and has the second-highest atomic mass of all the elements that have been produced in amounts large enough to see with the unaided eye (after einsteinium).",
  ),
  99: const ElementData(
    atomicNumber: 99,
    symbol: "Es",
    name: "Einsteinium",
    category: "Actinide",
    atomicMass: 252.0,
    funFact:
        "Einsteinium is a synthetic element with symbol Es and atomic number 99. It is the seventh transuranic element, and an actinide. Einsteinium was discovered as a component of the debris of the first hydrogen bomb explosion in 1952, and named after Albert Einstein.",
  ),
  100: const ElementData(
    atomicNumber: 100,
    symbol: "Fm",
    name: "Fermium",
    category: "Actinide",
    atomicMass: 257.0,
    funFact:
        "Fermium is a synthetic element with symbol Fm and atomic number 100. It is a member of the actinide series. It is the heaviest element that can be formed by neutron bombardment of lighter elements, and hence the last element that can be prepared in macroscopic quantities, although pure fermium metal has not yet been prepared.",
  ),
  101: const ElementData(
    atomicNumber: 101,
    symbol: "Md",
    name: "Mendelevium",
    category: "Actinide",
    atomicMass: 258.0,
    funFact:
        "Mendelevium is a synthetic element with chemical symbol Md (formerly Mv) and atomic number 101. A metallic radioactive transuranic element in the actinide series, it is the first element that currently cannot be produced in macroscopic quantities through neutron bombardment of lighter elements. It is the antepenultimate actinide and the ninth transuranic element.",
  ),
  102: const ElementData(
    atomicNumber: 102,
    symbol: "No",
    name: "Nobelium",
    category: "Actinide",
    atomicMass: 259.0,
    funFact:
        "Nobelium is a synthetic chemical element with symbol No and atomic number 102. It is named in honor of Alfred Nobel, the inventor of dynamite and benefactor of science. A radioactive metal, it is the tenth transuranic element and is the penultimate member of the actinide series.",
  ),
  103: const ElementData(
    atomicNumber: 103,
    symbol: "Lr",
    name: "Lawrencium",
    category: "Actinide",
    atomicMass: 266.0,
    funFact:
        "Lawrencium is a synthetic chemical element with chemical symbol Lr (formerly Lw) and atomic number 103. It is named in honor of Ernest Lawrence, inventor of the cyclotron, a device that was used to discover many artificial radioactive elements. A radioactive metal, lawrencium is the eleventh transuranic element and is also the final member of the actinide series.",
  ),
  104: const ElementData(
    atomicNumber: 104,
    symbol: "Rf",
    name: "Rutherfordium",
    category: "Transition Metal",
    atomicMass: 267.0,
    funFact:
        "Rutherfordium is a chemical element with symbol Rf and atomic number 104, named in honor of physicist Ernest Rutherford. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, 267Rf, has a half-life of approximately 1.3 hours. In the periodic table of the elements, it is a d - block element and the second of the fourth - row transition elements.",
  ),
  105: const ElementData(
    atomicNumber: 105,
    symbol: "Db",
    name: "Dubnium",
    category: "Transition Metal",
    atomicMass: 268.0,
    funFact:
        "Dubnium is a chemical element with symbol Db and atomic number 105. It is named after the town of Dubna in Russia (north of Moscow), where it was first produced. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, dubnium-268, has a half-life of approximately 28 hours.",
  ),
  106: const ElementData(
    atomicNumber: 106,
    symbol: "Sg",
    name: "Seaborgium",
    category: "Transition Metal",
    atomicMass: 269.0,
    funFact:
        "Seaborgium is a synthetic element with symbol Sg and atomic number 106. Its most stable isotope 271Sg has a half-life of 1.9 minutes. A more recently discovered isotope 269Sg has a potentially slightly longer half-life (ca.",
  ),
  107: const ElementData(
    atomicNumber: 107,
    symbol: "Bh",
    name: "Bohrium",
    category: "Transition Metal",
    atomicMass: 270.0,
    funFact:
        "Bohrium is a chemical element with symbol Bh and atomic number 107. It is named after Danish physicist Niels Bohr. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, 270Bh, has a half-life of approximately 61 seconds.",
  ),
  108: const ElementData(
    atomicNumber: 108,
    symbol: "Hs",
    name: "Hassium",
    category: "Transition Metal",
    atomicMass: 269.0,
    funFact:
        "Hassium is a chemical element with symbol Hs and atomic number 108, named after the German state of Hesse. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, 269Hs, has a half-life of approximately 9.7 seconds, although an unconfirmed metastable state, 277mHs, may have a longer half-life of about 130 seconds. More than 100 atoms of hassium have been synthesized to date.",
  ),
  109: const ElementData(
    atomicNumber: 109,
    symbol: "Mt",
    name: "Meitnerium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 278.0,
    funFact:
        "Meitnerium is a chemical element with symbol Mt and atomic number 109. It is an extremely radioactive synthetic element (an element not found in nature that can be created in a laboratory). The most stable known isotope, meitnerium-278, has a half-life of 7.6 seconds.",
  ),
  110: const ElementData(
    atomicNumber: 110,
    symbol: "Ds",
    name: "Darmstadtium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 281.0,
    funFact:
        "Darmstadtium is a chemical element with symbol Ds and atomic number 110. It is an extremely radioactive synthetic element. The most stable known isotope, darmstadtium-281, has a half-life of approximately 10 seconds.",
  ),
  111: const ElementData(
    atomicNumber: 111,
    symbol: "Rg",
    name: "Roentgenium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 282.0,
    funFact:
        "Roentgenium is a chemical element with symbol Rg and atomic number 111. It is an extremely radioactive synthetic element (an element that can be created in a laboratory but is not found in nature); the most stable known isotope, roentgenium-282, has a half-life of 2.1 minutes. Roentgenium was first created in 1994 by the GSI Helmholtz Centre for Heavy Ion Research near Darmstadt, Germany.",
  ),
  112: const ElementData(
    atomicNumber: 112,
    symbol: "Cn",
    name: "Copernicium",
    category: "Transition Metal",
    atomicMass: 285.0,
    funFact:
        "Copernicium is a chemical element with symbol Cn and atomic number 112. It is an extremely radioactive synthetic element that can only be created in a laboratory. The most stable known isotope, copernicium-285, has a half-life of approximately 29 seconds, but it is possible that this copernicium isotope may have a nuclear isomer with a longer half-life, 8.9 min.",
  ),
  113: const ElementData(
    atomicNumber: 113,
    symbol: "Nh",
    name: "Nihonium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 286.0,
    funFact:
        "Nihonium is a chemical element with atomic number 113. It has a symbol Nh. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and is extremely radioactive; its most stable known isotope, nihonium-286, has a half-life of 20 seconds.",
  ),
  114: const ElementData(
    atomicNumber: 114,
    symbol: "Fl",
    name: "Flerovium",
    category: "Post-Transition Metal",
    atomicMass: 289.0,
    funFact:
        "Flerovium is a superheavy artificial chemical element with symbol Fl and atomic number 114. It is an extremely radioactive synthetic element. The element is named after the Flerov Laboratory of Nuclear Reactions of the Joint Institute for Nuclear Research in Dubna, Russia, where the element was discovered in 1998.",
  ),
  115: const ElementData(
    atomicNumber: 115,
    symbol: "Mc",
    name: "Moscovium",
    category: "Unknown, Probably Post-Transition Metal",
    atomicMass: 289.0,
    funFact:
        "Moscovium is the name of a synthetic superheavy element in the periodic table that has the symbol Mc and has the atomic number 115. It is an extremely radioactive element; its most stable known isotope, moscovium-289, has a half-life of only 220 milliseconds. It is also known as eka-bismuth or simply element 115.",
  ),
  116: const ElementData(
    atomicNumber: 116,
    symbol: "Lv",
    name: "Livermorium",
    category: "Unknown, Probably Post-Transition Metal",
    atomicMass: 293.0,
    funFact:
        "Livermorium is a synthetic superheavy element with symbol Lv and atomic number 116. It is an extremely radioactive element that has only been created in the laboratory and has not been observed in nature. The element is named after the Lawrence Livermore National Laboratory in the United States, which collaborated with the Joint Institute for Nuclear Research in Dubna, Russia to discover livermorium in 2000.",
  ),
  117: const ElementData(
    atomicNumber: 117,
    symbol: "Ts",
    name: "Tennessine",
    category: "Unknown, Probably Metalloid",
    atomicMass: 294.0,
    funFact:
        "Tennessine is a superheavy artificial chemical element with an atomic number of 117 and a symbol of Ts. Also known as eka-astatine or element 117, it is the second-heaviest known element and penultimate element of the 7th period of the periodic table. As of 2016, fifteen tennessine atoms have been observed: six when it was first synthesized in 2010, seven in 2012, and two in 2014.",
  ),
  118: const ElementData(
    atomicNumber: 118,
    symbol: "Og",
    name: "Oganesson",
    category: "Unknown, Predicted To Be Noble Gas",
    atomicMass: 294.0,
    funFact:
        "Oganesson is IUPAC's name for the transactinide element with the atomic number 118 and element symbol Og. It is also known as eka-radon or element 118, and on the periodic table of the elements it is a p-block element and the last one of the 7th period. Oganesson is currently the only synthetic member of group 18.",
  ),
};

// ---------------------------------------------------------
// Box-to-Atomic Number Resolver
// ---------------------------------------------------------
int? getAtomicNumberForBox(int box) {
  if (box >= 1 && box <= 56) return box;
  if (box >= 58 && box <= 72) return box + 14; // Hf (72) to Rn (86)
  if (box == 73) return 87; // Fr
  if (box == 74) return 88; // Ra
  if (box >= 76 && box <= 90) return box + 28; // Rf (104) to Og (118)
  if (box >= 91 && box <= 105) return box - 34; // La (57) to Lu (71)
  if (box >= 106 && box <= 120) return box - 17; // Ac (89) to Lr (103)
  return null; // 57 and 75
}

// ---------------------------------------------------------
// Primary Periodic Table Map (Keyed by 120 Box Numbers 1-120)
// ---------------------------------------------------------
final Map<String, ElementData> periodicTable = {
  // Box 1: Element 1 (H - Hydrogen)
  "1": const ElementData(
    boxIndex: 1,
    atomicNumber: 1,
    symbol: "H",
    name: "Hydrogen",
    category: "Diatomic Nonmetal",
    atomicMass: 1.008,
    funFact:
        "Hydrogen is a chemical element with chemical symbol H and atomic number 1. With an atomic weight of 1.00794 u, hydrogen is the lightest element on the periodic table. Its monatomic form (H) is the most abundant chemical substance in the Universe, constituting roughly 75% of all baryonic mass.",
  ),
  // Box 2: Element 2 (He - Helium)
  "2": const ElementData(
    boxIndex: 2,
    atomicNumber: 2,
    symbol: "He",
    name: "Helium",
    category: "Noble Gas",
    atomicMass: 4.0026022,
    funFact:
        "Helium is a chemical element with symbol He and atomic number 2. It is a colorless, odorless, tasteless, non-toxic, inert, monatomic gas that heads the noble gas group in the periodic table. Its boiling and melting points are the lowest among all the elements.",
  ),
  // Box 3: Element 3 (Li - Lithium)
  "3": const ElementData(
    boxIndex: 3,
    atomicNumber: 3,
    symbol: "Li",
    name: "Lithium",
    category: "Alkali Metal",
    atomicMass: 6.94,
    funFact:
        "Lithium (from Greek:λίθος lithos, \"stone\") is a chemical element with the symbol Li and atomic number 3. It is a soft, silver-white metal belonging to the alkali metal group of chemical elements. Under standard conditions it is the lightest metal and the least dense solid element.",
  ),
  // Box 4: Element 4 (Be - Beryllium)
  "4": const ElementData(
    boxIndex: 4,
    atomicNumber: 4,
    symbol: "Be",
    name: "Beryllium",
    category: "Alkaline Earth Metal",
    atomicMass: 9.01218315,
    funFact:
        "Beryllium is a chemical element with symbol Be and atomic number 4. It is created through stellar nucleosynthesis and is a relatively rare element in the universe. It is a divalent element which occurs naturally only in combination with other elements in minerals.",
  ),
  // Box 5: Element 5 (B - Boron)
  "5": const ElementData(
    boxIndex: 5,
    atomicNumber: 5,
    symbol: "B",
    name: "Boron",
    category: "Metalloid",
    atomicMass: 10.81,
    funFact:
        "Boron is a metalloid chemical element with symbol B and atomic number 5. Produced entirely by cosmic ray spallation and supernovae and not by stellar nucleosynthesis, it is a low-abundance element in both the Solar system and the Earth's crust. Boron is concentrated on Earth by the water-solubility of its more common naturally occurring compounds, the borate minerals.",
  ),
  // Box 6: Element 6 (C - Carbon)
  "6": const ElementData(
    boxIndex: 6,
    atomicNumber: 6,
    symbol: "C",
    name: "Carbon",
    category: "Polyatomic Nonmetal",
    atomicMass: 12.011,
    funFact:
        "Carbon (from Latin:carbo \"coal\") is a chemical element with symbol C and atomic number 6. On the periodic table, it is the first (row 2) of six elements in column (group) 14, which have in common the composition of their outer electron shell. It is nonmetallic and tetravalent—making four electrons available to form covalent chemical bonds.",
  ),
  // Box 7: Element 7 (N - Nitrogen)
  "7": const ElementData(
    boxIndex: 7,
    atomicNumber: 7,
    symbol: "N",
    name: "Nitrogen",
    category: "Diatomic Nonmetal",
    atomicMass: 14.007,
    funFact:
        "Nitrogen is a chemical element with symbol N and atomic number 7. It is the lightest pnictogen and at room temperature, it is a transparent, odorless diatomic gas. Nitrogen is a common element in the universe, estimated at about seventh in total abundance in the Milky Way and the Solar System.",
  ),
  // Box 8: Element 8 (O - Oxygen)
  "8": const ElementData(
    boxIndex: 8,
    atomicNumber: 8,
    symbol: "O",
    name: "Oxygen",
    category: "Diatomic Nonmetal",
    atomicMass: 15.999,
    funFact:
        "Oxygen is a chemical element with symbol O and atomic number 8. It is a member of the chalcogen group on the periodic table and is a highly reactive nonmetal and oxidizing agent that readily forms compounds (notably oxides) with most elements. By mass, oxygen is the third-most abundant element in the universe, after hydrogen and helium.",
  ),
  // Box 9: Element 9 (F - Fluorine)
  "9": const ElementData(
    boxIndex: 9,
    atomicNumber: 9,
    symbol: "F",
    name: "Fluorine",
    category: "Diatomic Nonmetal",
    atomicMass: 18.9984031636,
    funFact:
        "Fluorine is a chemical element with symbol F and atomic number 9. It is the lightest halogen and exists as a highly toxic pale yellow diatomic gas at standard conditions. As the most electronegative element, it is extremely reactive:almost all other elements, including some noble gases, form compounds with fluorine.",
  ),
  // Box 10: Element 10 (Ne - Neon)
  "10": const ElementData(
    boxIndex: 10,
    atomicNumber: 10,
    symbol: "Ne",
    name: "Neon",
    category: "Noble Gas",
    atomicMass: 20.17976,
    funFact:
        "Neon is a chemical element with symbol Ne and atomic number 10. It is in group 18 (noble gases) of the periodic table. Neon is a colorless, odorless, inert monatomic gas under standard conditions, with about two-thirds the density of air.",
  ),
  // Box 11: Element 11 (Na - Sodium)
  "11": const ElementData(
    boxIndex: 11,
    atomicNumber: 11,
    symbol: "Na",
    name: "Sodium",
    category: "Alkali Metal",
    atomicMass: 22.989769282,
    funFact:
        "Sodium /ˈsoʊdiəm/ is a chemical element with symbol Na (from Ancient Greek Νάτριο) and atomic number 11. It is a soft, silver-white, highly reactive metal. In the Periodic table it is in column 1 (alkali metals), and shares with the other six elements in that column that it has a single electron in its outer shell, which it readily donates, creating a positively charged atom - a cation.",
  ),
  // Box 12: Element 12 (Mg - Magnesium)
  "12": const ElementData(
    boxIndex: 12,
    atomicNumber: 12,
    symbol: "Mg",
    name: "Magnesium",
    category: "Alkaline Earth Metal",
    atomicMass: 24.305,
    funFact:
        "Magnesium is a chemical element with symbol Mg and atomic number 12. It is a shiny gray solid which bears a close physical resemblance to the other five elements in the second column (Group 2, or alkaline earth metals) of the periodic table:they each have the same electron configuration in their outer electron shell producing a similar crystal structure. Magnesium is the ninth most abundant element in the universe.",
  ),
  // Box 13: Element 13 (Al - Aluminium)
  "13": const ElementData(
    boxIndex: 13,
    atomicNumber: 13,
    symbol: "Al",
    name: "Aluminium",
    category: "Post-Transition Metal",
    atomicMass: 26.98153857,
    funFact:
        "Aluminium (or aluminum; see different endings) is a chemical element in the boron group with symbol Al and atomic number 13. It is a silvery-white, soft, nonmagnetic, ductile metal. Aluminium is the third most abundant element (after oxygen and silicon), and the most abundant metal, in the Earth's crust.",
  ),
  // Box 14: Element 14 (Si - Silicon)
  "14": const ElementData(
    boxIndex: 14,
    atomicNumber: 14,
    symbol: "Si",
    name: "Silicon",
    category: "Metalloid",
    atomicMass: 28.085,
    funFact:
        "Silicon is a chemical element with symbol Si and atomic number 14. It is a tetravalent metalloid, more reactive than germanium, the metalloid directly below it in the table. Controversy about silicon's character dates to its discovery.",
  ),
  // Box 15: Element 15 (P - Phosphorus)
  "15": const ElementData(
    boxIndex: 15,
    atomicNumber: 15,
    symbol: "P",
    name: "Phosphorus",
    category: "Polyatomic Nonmetal",
    atomicMass: 30.9737619985,
    funFact:
        "Phosphorus is a chemical element with symbol P and atomic number 15. As an element, phosphorus exists in two major forms—white phosphorus and red phosphorus—but due to its high reactivity, phosphorus is never found as a free element on Earth. Instead phosphorus-containing minerals are almost always present in their maximally oxidised state, as inorganic phosphate rocks.",
  ),
  // Box 16: Element 16 (S - Sulfur)
  "16": const ElementData(
    boxIndex: 16,
    atomicNumber: 16,
    symbol: "S",
    name: "Sulfur",
    category: "Polyatomic Nonmetal",
    atomicMass: 32.06,
    funFact:
        "Sulfur or sulphur (see spelling differences) is a chemical element with symbol S and atomic number 16. It is an abundant, multivalent non-metal. Under normal conditions, sulfur atoms form cyclic octatomic molecules with chemical formula S8.",
  ),
  // Box 17: Element 17 (Cl - Chlorine)
  "17": const ElementData(
    boxIndex: 17,
    atomicNumber: 17,
    symbol: "Cl",
    name: "Chlorine",
    category: "Diatomic Nonmetal",
    atomicMass: 35.45,
    funFact:
        "Chlorine is a chemical element with symbol Cl and atomic number 17. It also has a relative atomic mass of 35.5. Chlorine is in the halogen group (17) and is the second lightest halogen following fluorine.",
  ),
  // Box 18: Element 18 (Ar - Argon)
  "18": const ElementData(
    boxIndex: 18,
    atomicNumber: 18,
    symbol: "Ar",
    name: "Argon",
    category: "Noble Gas",
    atomicMass: 39.9481,
    funFact:
        "Argon is a chemical element with symbol Ar and atomic number 18. It is in group 18 of the periodic table and is a noble gas. Argon is the third most common gas in the Earth's atmosphere, at 0.934% (9,340 ppmv), making it over twice as abundant as the next most common atmospheric gas, water vapor (which averages about 4000 ppmv, but varies greatly), and 23 times as abundant as the next most common non-condensing atmospheric gas, carbon dioxide (400 ppmv), and more than 500 times as abundant as the next most common noble gas, neon (18 ppmv).",
  ),
  // Box 19: Element 19 (K - Potassium)
  "19": const ElementData(
    boxIndex: 19,
    atomicNumber: 19,
    symbol: "K",
    name: "Potassium",
    category: "Alkali Metal",
    atomicMass: 39.09831,
    funFact:
        "Potassium is a chemical element with symbol K (derived from Neo-Latin, kalium) and atomic number 19. It was first isolated from potash, the ashes of plants, from which its name is derived. In the Periodic table, potassium is one of seven elements in column (group) 1 (alkali metals):they all have a single valence electron in their outer electron shell, which they readily give up to create an atom with a positive charge - a cation, and combine with anions to form salts.",
  ),
  // Box 20: Element 20 (Ca - Calcium)
  "20": const ElementData(
    boxIndex: 20,
    atomicNumber: 20,
    symbol: "Ca",
    name: "Calcium",
    category: "Alkaline Earth Metal",
    atomicMass: 40.0784,
    funFact:
        "Calcium is a chemical element with symbol Ca and atomic number 20. Calcium is a soft gray alkaline earth metal, fifth-most-abundant element by mass in the Earth's crust. The ion Ca2+ is also the fifth-most-abundant dissolved ion in seawater by both molarity and mass, after sodium, chloride, magnesium, and sulfate.",
  ),
  // Box 21: Element 21 (Sc - Scandium)
  "21": const ElementData(
    boxIndex: 21,
    atomicNumber: 21,
    symbol: "Sc",
    name: "Scandium",
    category: "Transition Metal",
    atomicMass: 44.9559085,
    funFact:
        "Scandium is a chemical element with symbol Sc and atomic number 21. A silvery-white metallic d-block element, it has historically been sometimes classified as a rare earth element, together with yttrium and the lanthanoids. It was discovered in 1879 by spectral analysis of the minerals euxenite and gadolinite from Scandinavia.",
  ),
  // Box 22: Element 22 (Ti - Titanium)
  "22": const ElementData(
    boxIndex: 22,
    atomicNumber: 22,
    symbol: "Ti",
    name: "Titanium",
    category: "Transition Metal",
    atomicMass: 47.8671,
    funFact:
        "Titanium is a chemical element with symbol Ti and atomic number 22. It is a lustrous transition metal with a silver color, low density and high strength. It is highly resistant to corrosion in sea water, aqua regia and chlorine.",
  ),
  // Box 23: Element 23 (V - Vanadium)
  "23": const ElementData(
    boxIndex: 23,
    atomicNumber: 23,
    symbol: "V",
    name: "Vanadium",
    category: "Transition Metal",
    atomicMass: 50.94151,
    funFact:
        "Vanadium is a chemical element with symbol V and atomic number 23. It is a hard, silvery grey, ductile and malleable transition metal. The element is found only in chemically combined form in nature, but once isolated artificially, the formation of an oxide layer stabilizes the free metal somewhat against further oxidation.",
  ),
  // Box 24: Element 24 (Cr - Chromium)
  "24": const ElementData(
    boxIndex: 24,
    atomicNumber: 24,
    symbol: "Cr",
    name: "Chromium",
    category: "Transition Metal",
    atomicMass: 51.99616,
    funFact:
        "Chromium is a chemical element with symbol Cr and atomic number 24. It is the first element in Group 6. It is a steely-gray, lustrous, hard and brittle metal which takes a high polish, resists tarnishing, and has a high melting point.",
  ),
  // Box 25: Element 25 (Mn - Manganese)
  "25": const ElementData(
    boxIndex: 25,
    atomicNumber: 25,
    symbol: "Mn",
    name: "Manganese",
    category: "Transition Metal",
    atomicMass: 54.9380443,
    funFact:
        "Manganese is a chemical element with symbol Mn and atomic number 25. It is not found as a free element in nature; it is often found in combination with iron, and in many minerals. Manganese is a metal with important industrial metal alloy uses, particularly in stainless steels.",
  ),
  // Box 26: Element 26 (Fe - Iron)
  "26": const ElementData(
    boxIndex: 26,
    atomicNumber: 26,
    symbol: "Fe",
    name: "Iron",
    category: "Transition Metal",
    atomicMass: 55.8452,
    funFact:
        "Iron is a chemical element with symbol Fe (from Latin:ferrum) and atomic number 26. It is a metal in the first transition series. It is by mass the most common element on Earth, forming much of Earth's outer and inner core.",
  ),
  // Box 27: Element 27 (Co - Cobalt)
  "27": const ElementData(
    boxIndex: 27,
    atomicNumber: 27,
    symbol: "Co",
    name: "Cobalt",
    category: "Transition Metal",
    atomicMass: 58.9331944,
    funFact:
        "Cobalt is a chemical element with symbol Co and atomic number 27. Like nickel, cobalt in the Earth's crust is found only in chemically combined form, save for small deposits found in alloys of natural meteoric iron. The free element, produced by reductive smelting, is a hard, lustrous, silver-gray metal.",
  ),
  // Box 28: Element 28 (Ni - Nickel)
  "28": const ElementData(
    boxIndex: 28,
    atomicNumber: 28,
    symbol: "Ni",
    name: "Nickel",
    category: "Transition Metal",
    atomicMass: 58.69344,
    funFact:
        "Nickel is a chemical element with symbol Ni and atomic number 28. It is a silvery-white lustrous metal with a slight golden tinge. Nickel belongs to the transition metals and is hard and ductile.",
  ),
  // Box 29: Element 29 (Cu - Copper)
  "29": const ElementData(
    boxIndex: 29,
    atomicNumber: 29,
    symbol: "Cu",
    name: "Copper",
    category: "Transition Metal",
    atomicMass: 63.5463,
    funFact:
        "Copper is a chemical element with symbol Cu (from Latin:cuprum) and atomic number 29. It is a soft, malleable and ductile metal with very high thermal and electrical conductivity. A freshly exposed surface of pure copper has a reddish-orange color.",
  ),
  // Box 30: Element 30 (Zn - Zinc)
  "30": const ElementData(
    boxIndex: 30,
    atomicNumber: 30,
    symbol: "Zn",
    name: "Zinc",
    category: "Transition Metal",
    atomicMass: 65.382,
    funFact:
        "Zinc, in commerce also spelter, is a chemical element with symbol Zn and atomic number 30. It is the first element of group 12 of the periodic table. In some respects zinc is chemically similar to magnesium:its ion is of similar size and its only common oxidation state is +2.",
  ),
  // Box 31: Element 31 (Ga - Gallium)
  "31": const ElementData(
    boxIndex: 31,
    atomicNumber: 31,
    symbol: "Ga",
    name: "Gallium",
    category: "Post-Transition Metal",
    atomicMass: 69.7231,
    funFact:
        "Gallium is a chemical element with symbol Ga and atomic number 31. Elemental gallium does not occur in free form in nature, but as the gallium(III) compounds that are in trace amounts in zinc ores and in bauxite. Gallium is a soft, silvery metal, and elemental gallium is a brittle solid at low temperatures, and melts at 29.76 °C (85.57 °F) (slightly above room temperature).",
  ),
  // Box 32: Element 32 (Ge - Germanium)
  "32": const ElementData(
    boxIndex: 32,
    atomicNumber: 32,
    symbol: "Ge",
    name: "Germanium",
    category: "Metalloid",
    atomicMass: 72.6308,
    funFact:
        "Germanium is a chemical element with symbol Ge and atomic number 32. It is a lustrous, hard, grayish-white metalloid in the carbon group, chemically similar to its group neighbors tin and silicon. Purified germanium is a semiconductor, with an appearance most similar to elemental silicon.",
  ),
  // Box 33: Element 33 (As - Arsenic)
  "33": const ElementData(
    boxIndex: 33,
    atomicNumber: 33,
    symbol: "As",
    name: "Arsenic",
    category: "Metalloid",
    atomicMass: 74.9215956,
    funFact:
        "Arsenic is a chemical element with symbol As and atomic number 33. Arsenic occurs in many minerals, usually in conjunction with sulfur and metals, and also as a pure elemental crystal. Arsenic is a metalloid.",
  ),
  // Box 34: Element 34 (Se - Selenium)
  "34": const ElementData(
    boxIndex: 34,
    atomicNumber: 34,
    symbol: "Se",
    name: "Selenium",
    category: "Polyatomic Nonmetal",
    atomicMass: 78.9718,
    funFact:
        "Selenium is a chemical element with symbol Se and atomic number 34. It is a nonmetal with properties that are intermediate between those of its periodic table column-adjacent chalcogen elements sulfur and tellurium. It rarely occurs in its elemental state in nature, or as pure ore compounds.",
  ),
  // Box 35: Element 35 (Br - Bromine)
  "35": const ElementData(
    boxIndex: 35,
    atomicNumber: 35,
    symbol: "Br",
    name: "Bromine",
    category: "Diatomic Nonmetal",
    atomicMass: 79.904,
    funFact:
        "Bromine (from Ancient Greek:βρῶμος, brómos, meaning \"stench\") is a chemical element with symbol Br, and atomic number 35. It is a halogen. The element was isolated independently by two chemists, Carl Jacob Löwig and Antoine Jerome Balard, in 1825–1826.",
  ),
  // Box 36: Element 36 (Kr - Krypton)
  "36": const ElementData(
    boxIndex: 36,
    atomicNumber: 36,
    symbol: "Kr",
    name: "Krypton",
    category: "Noble Gas",
    atomicMass: 83.7982,
    funFact:
        "Krypton (from Greek:κρυπτός kryptos \"the hidden one\") is a chemical element with symbol Kr and atomic number 36. It is a member of group 18 (noble gases) elements. A colorless, odorless, tasteless noble gas, krypton occurs in trace amounts in the atmosphere, is isolated by fractionally distilling liquefied air, and is often used with other rare gases in fluorescent lamps.",
  ),
  // Box 37: Element 37 (Rb - Rubidium)
  "37": const ElementData(
    boxIndex: 37,
    atomicNumber: 37,
    symbol: "Rb",
    name: "Rubidium",
    category: "Alkali Metal",
    atomicMass: 85.46783,
    funFact:
        "Rubidium is a chemical element with symbol Rb and atomic number 37. Rubidium is a soft, silvery-white metallic element of the alkali metal group, with an atomic mass of 85.4678. Elemental rubidium is highly reactive, with properties similar to those of other alkali metals, such as very rapid oxidation in air.",
  ),
  // Box 38: Element 38 (Sr - Strontium)
  "38": const ElementData(
    boxIndex: 38,
    atomicNumber: 38,
    symbol: "Sr",
    name: "Strontium",
    category: "Alkaline Earth Metal",
    atomicMass: 87.621,
    funFact:
        "Strontium is a chemical element with symbol Sr and atomic number 38. An alkaline earth metal, strontium is a soft silver-white or yellowish metallic element that is highly reactive chemically. The metal turns yellow when it is exposed to air.",
  ),
  // Box 39: Element 39 (Y - Yttrium)
  "39": const ElementData(
    boxIndex: 39,
    atomicNumber: 39,
    symbol: "Y",
    name: "Yttrium",
    category: "Transition Metal",
    atomicMass: 88.905842,
    funFact:
        "Yttrium is a chemical element with symbol Y and atomic number 39. It is a silvery-metallic transition metal chemically similar to the lanthanides and it has often been classified as a \"rare earth element\". Yttrium is almost always found combined with the lanthanides in rare earth minerals and is never found in nature as a free element.",
  ),
  // Box 40: Element 40 (Zr - Zirconium)
  "40": const ElementData(
    boxIndex: 40,
    atomicNumber: 40,
    symbol: "Zr",
    name: "Zirconium",
    category: "Transition Metal",
    atomicMass: 91.2242,
    funFact:
        "Zirconium is a chemical element with symbol Zr and atomic number 40. The name of zirconium is taken from the name of the mineral zircon, the most important source of zirconium. The word zircon comes from the Persian word zargun زرگون, meaning \"gold-colored\".",
  ),
  // Box 41: Element 41 (Nb - Niobium)
  "41": const ElementData(
    boxIndex: 41,
    atomicNumber: 41,
    symbol: "Nb",
    name: "Niobium",
    category: "Transition Metal",
    atomicMass: 92.906372,
    funFact:
        "Niobium, formerly columbium, is a chemical element with symbol Nb (formerly Cb) and atomic number 41. It is a soft, grey, ductile transition metal, which is often found in the pyrochlore mineral, the main commercial source for niobium, and columbite. The name comes from Greek mythology:Niobe, daughter of Tantalus since it is so similar to tantalum.",
  ),
  // Box 42: Element 42 (Mo - Molybdenum)
  "42": const ElementData(
    boxIndex: 42,
    atomicNumber: 42,
    symbol: "Mo",
    name: "Molybdenum",
    category: "Transition Metal",
    atomicMass: 95.951,
    funFact:
        "Molybdenum is a chemical element with symbol Mo and atomic number 42. The name is from Neo-Latin molybdaenum, from Ancient Greek Μόλυβδος molybdos, meaning lead, since its ores were confused with lead ores. Molybdenum minerals have been known throughout history, but the element was discovered (in the sense of differentiating it as a new entity from the mineral salts of other metals) in 1778 by Carl Wilhelm Scheele.",
  ),
  // Box 43: Element 43 (Tc - Technetium)
  "43": const ElementData(
    boxIndex: 43,
    atomicNumber: 43,
    symbol: "Tc",
    name: "Technetium",
    category: "Transition Metal",
    atomicMass: 98.0,
    funFact:
        "Technetium (/tɛkˈniːʃiəm/) is a chemical element with symbol Tc and atomic number 43. It is the element with the lowest atomic number in the periodic table that has no stable isotopes:every form of it is radioactive. Nearly all technetium is produced synthetically, and only minute amounts are found in nature.",
  ),
  // Box 44: Element 44 (Ru - Ruthenium)
  "44": const ElementData(
    boxIndex: 44,
    atomicNumber: 44,
    symbol: "Ru",
    name: "Ruthenium",
    category: "Transition Metal",
    atomicMass: 101.072,
    funFact:
        "Ruthenium is a chemical element with symbol Ru and atomic number 44. It is a rare transition metal belonging to the platinum group of the periodic table. Like the other metals of the platinum group, ruthenium is inert to most other chemicals.",
  ),
  // Box 45: Element 45 (Rh - Rhodium)
  "45": const ElementData(
    boxIndex: 45,
    atomicNumber: 45,
    symbol: "Rh",
    name: "Rhodium",
    category: "Transition Metal",
    atomicMass: 102.905502,
    funFact:
        "Rhodium is a chemical element with symbol Rh and atomic number 45. It is a rare, silvery-white, hard, and chemically inert transition metal. It is a member of the platinum group.",
  ),
  // Box 46: Element 46 (Pd - Palladium)
  "46": const ElementData(
    boxIndex: 46,
    atomicNumber: 46,
    symbol: "Pd",
    name: "Palladium",
    category: "Transition Metal",
    atomicMass: 106.421,
    funFact:
        "Palladium is a chemical element with symbol Pd and atomic number 46. It is a rare and lustrous silvery-white metal discovered in 1803 by William Hyde Wollaston. He named it after the asteroid Pallas, which was itself named after the epithet of the Greek goddess Athena, acquired by her when she slew Pallas.",
  ),
  // Box 47: Element 47 (Ag - Silver)
  "47": const ElementData(
    boxIndex: 47,
    atomicNumber: 47,
    symbol: "Ag",
    name: "Silver",
    category: "Transition Metal",
    atomicMass: 107.86822,
    funFact:
        "Silver is a chemical element with symbol Ag (Greek:άργυρος árguros, Latin:argentum, both from the Indo-European root *h₂erǵ- for \"grey\" or \"shining\") and atomic number 47. A soft, white, lustrous transition metal, it possesses the highest electrical conductivity, thermal conductivity and reflectivity of any metal. The metal occurs naturally in its pure, free form (native silver), as an alloy with gold and other metals, and in minerals such as argentite and chlorargyrite.",
  ),
  // Box 48: Element 48 (Cd - Cadmium)
  "48": const ElementData(
    boxIndex: 48,
    atomicNumber: 48,
    symbol: "Cd",
    name: "Cadmium",
    category: "Transition Metal",
    atomicMass: 112.4144,
    funFact:
        "Cadmium is a chemical element with symbol Cd and atomic number 48. This soft, bluish-white metal is chemically similar to the two other stable metals in group 12, zinc and mercury. Like zinc, it prefers oxidation state +2 in most of its compounds and like mercury it shows a low melting point compared to transition metals.",
  ),
  // Box 49: Element 49 (In - Indium)
  "49": const ElementData(
    boxIndex: 49,
    atomicNumber: 49,
    symbol: "In",
    name: "Indium",
    category: "Post-Transition Metal",
    atomicMass: 114.8181,
    funFact:
        "Indium is a chemical element with symbol In and atomic number 49. It is a post-transition metallic element that is rare in Earth's crust. The metal is very soft, malleable and easily fusible, with a melting point higher than sodium, but lower than lithium or tin.",
  ),
  // Box 50: Element 50 (Sn - Tin)
  "50": const ElementData(
    boxIndex: 50,
    atomicNumber: 50,
    symbol: "Sn",
    name: "Tin",
    category: "Post-Transition Metal",
    atomicMass: 118.7107,
    funFact:
        "Tin is a chemical element with the symbol Sn (for Latin:stannum) and atomic number 50. It is a main group metal in group 14 of the periodic table. Tin shows a chemical similarity to both neighboring group-14 elements, germanium and lead, and has two possible oxidation states, +2 and the slightly more stable +4.",
  ),
  // Box 51: Element 51 (Sb - Antimony)
  "51": const ElementData(
    boxIndex: 51,
    atomicNumber: 51,
    symbol: "Sb",
    name: "Antimony",
    category: "Metalloid",
    atomicMass: 121.7601,
    funFact:
        "Antimony is a chemical element with symbol Sb (from Latin:stibium) and atomic number 51. A lustrous gray metalloid, it is found in nature mainly as the sulfide mineral stibnite (Sb2S3). Antimony compounds have been known since ancient times and were used for cosmetics; metallic antimony was also known, but it was erroneously identified as lead upon its discovery.",
  ),
  // Box 52: Element 52 (Te - Tellurium)
  "52": const ElementData(
    boxIndex: 52,
    atomicNumber: 52,
    symbol: "Te",
    name: "Tellurium",
    category: "Metalloid",
    atomicMass: 127.603,
    funFact:
        "Tellurium is a chemical element with symbol Te and atomic number 52. It is a brittle, mildly toxic, rare, silver-white metalloid. Tellurium is chemically related to selenium and sulfur.",
  ),
  // Box 53: Element 53 (I - Iodine)
  "53": const ElementData(
    boxIndex: 53,
    atomicNumber: 53,
    symbol: "I",
    name: "Iodine",
    category: "Diatomic Nonmetal",
    atomicMass: 126.904473,
    funFact:
        "Iodine is a chemical element with symbol I and atomic number 53. The name is from Greek ἰοειδής ioeidēs, meaning violet or purple, due to the color of iodine vapor. Iodine and its compounds are primarily used in nutrition, and industrially in the production of acetic acid and certain polymers.",
  ),
  // Box 54: Element 54 (Xe - Xenon)
  "54": const ElementData(
    boxIndex: 54,
    atomicNumber: 54,
    symbol: "Xe",
    name: "Xenon",
    category: "Noble Gas",
    atomicMass: 131.2936,
    funFact:
        "Xenon is a chemical element with symbol Xe and atomic number 54. It is a colorless, dense, odorless noble gas, that occurs in the Earth's atmosphere in trace amounts. Although generally unreactive, xenon can undergo a few chemical reactions such as the formation of xenon hexafluoroplatinate, the first noble gas compound to be synthesized.",
  ),
  // Box 55: Element 55 (Cs - Cesium)
  "55": const ElementData(
    boxIndex: 55,
    atomicNumber: 55,
    symbol: "Cs",
    name: "Cesium",
    category: "Alkali Metal",
    atomicMass: 132.905451966,
    funFact:
        "Caesium or cesium is a chemical element with symbol Cs and atomic number 55. It is a soft, silvery-gold alkali metal with a melting point of 28 °C (82 °F), which makes it one of only five elemental metals that are liquid at or near room temperature. Caesium is an alkali metal and has physical and chemical properties similar to those of rubidium and potassium.",
  ),
  // Box 56: Element 56 (Ba - Barium)
  "56": const ElementData(
    boxIndex: 56,
    atomicNumber: 56,
    symbol: "Ba",
    name: "Barium",
    category: "Alkaline Earth Metal",
    atomicMass: 137.3277,
    funFact:
        "Barium is a chemical element with symbol Ba and atomic number 56. It is the fifth element in Group 2, a soft silvery metallic alkaline earth metal. Because of its high chemical reactivity barium is never found in nature as a free element.",
  ),
  // Box 57: Lanthanide Placeholder
  "57": lanthanideSeriesPlaceholder,
  // Box 58: Element 72 (Hf - Hafnium)
  "58": const ElementData(
    boxIndex: 58,
    atomicNumber: 72,
    symbol: "Hf",
    name: "Hafnium",
    category: "Transition Metal",
    atomicMass: 178.492,
    funFact:
        "Hafnium is a chemical element with symbol Hf and atomic number 72. A lustrous, silvery gray, tetravalent transition metal, hafnium chemically resembles zirconium and is found in zirconium minerals. Its existence was predicted by Dmitri Mendeleev in 1869, though it was not identified until 1923, making it the penultimate stable element to be discovered (rhenium was identified two years later).",
  ),
  // Box 59: Element 73 (Ta - Tantalum)
  "59": const ElementData(
    boxIndex: 59,
    atomicNumber: 73,
    symbol: "Ta",
    name: "Tantalum",
    category: "Transition Metal",
    atomicMass: 180.947882,
    funFact:
        "Tantalum is a chemical element with symbol Ta and atomic number 73. Previously known as tantalium, its name comes from Tantalus, an antihero from Greek mythology. Tantalum is a rare, hard, blue-gray, lustrous transition metal that is highly corrosion-resistant.",
  ),
  // Box 60: Element 74 (W - Tungsten)
  "60": const ElementData(
    boxIndex: 60,
    atomicNumber: 74,
    symbol: "W",
    name: "Tungsten",
    category: "Transition Metal",
    atomicMass: 183.841,
    funFact:
        "Tungsten, also known as wolfram, is a chemical element with symbol W and atomic number 74. The word tungsten comes from the Swedish language tung sten, which directly translates to heavy stone. Its name in Swedish is volfram, however, in order to distinguish it from scheelite, which in Swedish is alternatively named tungsten.",
  ),
  // Box 61: Element 75 (Re - Rhenium)
  "61": const ElementData(
    boxIndex: 61,
    atomicNumber: 75,
    symbol: "Re",
    name: "Rhenium",
    category: "Transition Metal",
    atomicMass: 186.2071,
    funFact:
        "Rhenium is a chemical element with symbol Re and atomic number 75. It is a silvery-white, heavy, third-row transition metal in group 7 of the periodic table. With an estimated average concentration of 1 part per billion (ppb), rhenium is one of the rarest elements in the Earth's crust.",
  ),
  // Box 62: Element 76 (Os - Osmium)
  "62": const ElementData(
    boxIndex: 62,
    atomicNumber: 76,
    symbol: "Os",
    name: "Osmium",
    category: "Transition Metal",
    atomicMass: 190.233,
    funFact:
        "Osmium (from Greek osme (ὀσμή) meaning \"smell\") is a chemical element with symbol Os and atomic number 76. It is a hard, brittle, bluish-white transition metal in the platinum group that is found as a trace element in alloys, mostly in platinum ores. Osmium is the densest naturally occurring element, with a density of 22.59 g/cm3.",
  ),
  // Box 63: Element 77 (Ir - Iridium)
  "63": const ElementData(
    boxIndex: 63,
    atomicNumber: 77,
    symbol: "Ir",
    name: "Iridium",
    category: "Transition Metal",
    atomicMass: 192.2173,
    funFact:
        "Iridium is a chemical element with symbol Ir and atomic number 77. A very hard, brittle, silvery-white transition metal of the platinum group, iridium is generally credited with being the second densest element (after osmium) based on measured density, although calculations involving the space lattices of the elements show that iridium is denser. It is also the most corrosion-resistant metal, even at temperatures as high as 2000 °C. Although only certain molten salts and halogens are corrosive to solid iridium, finely divided iridium dust is much more reactive and can be flammable.",
  ),
  // Box 64: Element 78 (Pt - Platinum)
  "64": const ElementData(
    boxIndex: 64,
    atomicNumber: 78,
    symbol: "Pt",
    name: "Platinum",
    category: "Transition Metal",
    atomicMass: 195.0849,
    funFact:
        "Platinum is a chemical element with symbol Pt and atomic number 78. It is a dense, malleable, ductile, highly unreactive, precious, gray-white transition metal. Its name is derived from the Spanish term platina, which is literally translated into \"little silver\".",
  ),
  // Box 65: Element 79 (Au - Gold)
  "65": const ElementData(
    boxIndex: 65,
    atomicNumber: 79,
    symbol: "Au",
    name: "Gold",
    category: "Transition Metal",
    atomicMass: 196.9665695,
    funFact:
        "Gold is a chemical element with symbol Au (from Latin:aurum) and atomic number 79. In its purest form, it is a bright, slightly reddish yellow, dense, soft, malleable and ductile metal. Chemically, gold is a transition metal and a group 11 element.",
  ),
  // Box 66: Element 80 (Hg - Mercury)
  "66": const ElementData(
    boxIndex: 66,
    atomicNumber: 80,
    symbol: "Hg",
    name: "Mercury",
    category: "Transition Metal",
    atomicMass: 200.5923,
    funFact:
        "Mercury is a chemical element with symbol Hg and atomic number 80. It is commonly known as quicksilver and was formerly named hydrargyrum (/haɪˈdrɑːrdʒərəm/). A heavy, silvery d-block element, mercury is the only metallic element that is liquid at standard conditions for temperature and pressure; the only other element that is liquid under these conditions is bromine, though metals such as caesium, gallium, and rubidium melt just above room temperature.",
  ),
  // Box 67: Element 81 (Tl - Thallium)
  "67": const ElementData(
    boxIndex: 67,
    atomicNumber: 81,
    symbol: "Tl",
    name: "Thallium",
    category: "Post-Transition Metal",
    atomicMass: 204.38,
    funFact:
        "Thallium is a chemical element with symbol Tl and atomic number 81. This soft gray post-transition metal is not found free in nature. When isolated, it resembles tin, but discolors when exposed to air.",
  ),
  // Box 68: Element 82 (Pb - Lead)
  "68": const ElementData(
    boxIndex: 68,
    atomicNumber: 82,
    symbol: "Pb",
    name: "Lead",
    category: "Post-Transition Metal",
    atomicMass: 207.21,
    funFact:
        "Lead (/lɛd/) is a chemical element in the carbon group with symbol Pb (from Latin:plumbum) and atomic number 82. Lead is a soft, malleable and heavy post-transition metal. Metallic lead has a bluish-white color after being freshly cut, but it soon tarnishes to a dull grayish color when exposed to air.",
  ),
  // Box 69: Element 83 (Bi - Bismuth)
  "69": const ElementData(
    boxIndex: 69,
    atomicNumber: 83,
    symbol: "Bi",
    name: "Bismuth",
    category: "Post-Transition Metal",
    atomicMass: 208.980401,
    funFact:
        "Bismuth is a chemical element with symbol Bi and atomic number 83. Bismuth, a pentavalent post-transition metal, chemically resembles arsenic and antimony. Elemental bismuth may occur naturally, although its sulfide and oxide form important commercial ores.",
  ),
  // Box 70: Element 84 (Po - Polonium)
  "70": const ElementData(
    boxIndex: 70,
    atomicNumber: 84,
    symbol: "Po",
    name: "Polonium",
    category: "Post-Transition Metal",
    atomicMass: 209.0,
    funFact:
        "Polonium is a chemical element with symbol Po and atomic number 84, discovered in 1898 by Marie Curie and Pierre Curie. A rare and highly radioactive element with no stable isotopes, polonium is chemically similar to bismuth and tellurium, and it occurs in uranium ores. Applications of polonium are few.",
  ),
  // Box 71: Element 85 (At - Astatine)
  "71": const ElementData(
    boxIndex: 71,
    atomicNumber: 85,
    symbol: "At",
    name: "Astatine",
    category: "Metalloid",
    atomicMass: 210.0,
    funFact:
        "Astatine is a very rare radioactive chemical element with the chemical symbol At and atomic number 85. It occurs on Earth as the decay product of various heavier elements. All its isotopes are short-lived; the most stable is astatine-210, with a half-life of 8.1 hours.",
  ),
  // Box 72: Element 86 (Rn - Radon)
  "72": const ElementData(
    boxIndex: 72,
    atomicNumber: 86,
    symbol: "Rn",
    name: "Radon",
    category: "Noble Gas",
    atomicMass: 222.0,
    funFact:
        "Radon is a chemical element with symbol Rn and atomic number 86. It is a radioactive, colorless, odorless, tasteless noble gas, occurring naturally as a decay product of radium. Its most stable isotope, 222Rn, has a half-life of 3.8 days.",
  ),
  // Box 73: Element 87 (Fr - Francium)
  "73": const ElementData(
    boxIndex: 73,
    atomicNumber: 87,
    symbol: "Fr",
    name: "Francium",
    category: "Alkali Metal",
    atomicMass: 223.0,
    funFact:
        "Francium is a chemical element with symbol Fr and atomic number 87. It used to be known as eka-caesium and actinium K. It is the second-least electronegative element, behind only caesium. Francium is a highly radioactive metal that decays into astatine, radium, and radon.",
  ),
  // Box 74: Element 88 (Ra - Radium)
  "74": const ElementData(
    boxIndex: 74,
    atomicNumber: 88,
    symbol: "Ra",
    name: "Radium",
    category: "Alkaline Earth Metal",
    atomicMass: 226.0,
    funFact:
        "Radium is a chemical element with symbol Ra and atomic number 88. It is the sixth element in group 2 of the periodic table, also known as the alkaline earth metals. Pure radium is almost colorless, but it readily combines with nitrogen (rather than oxygen) on exposure to air, forming a black surface layer of radium nitride (Ra3N2).",
  ),
  // Box 75: Actinide Placeholder
  "75": actinideSeriesPlaceholder,
  // Box 76: Element 104 (Rf - Rutherfordium)
  "76": const ElementData(
    boxIndex: 76,
    atomicNumber: 104,
    symbol: "Rf",
    name: "Rutherfordium",
    category: "Transition Metal",
    atomicMass: 267.0,
    funFact:
        "Rutherfordium is a chemical element with symbol Rf and atomic number 104, named in honor of physicist Ernest Rutherford. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, 267Rf, has a half-life of approximately 1.3 hours. In the periodic table of the elements, it is a d - block element and the second of the fourth - row transition elements.",
  ),
  // Box 77: Element 105 (Db - Dubnium)
  "77": const ElementData(
    boxIndex: 77,
    atomicNumber: 105,
    symbol: "Db",
    name: "Dubnium",
    category: "Transition Metal",
    atomicMass: 268.0,
    funFact:
        "Dubnium is a chemical element with symbol Db and atomic number 105. It is named after the town of Dubna in Russia (north of Moscow), where it was first produced. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, dubnium-268, has a half-life of approximately 28 hours.",
  ),
  // Box 78: Element 106 (Sg - Seaborgium)
  "78": const ElementData(
    boxIndex: 78,
    atomicNumber: 106,
    symbol: "Sg",
    name: "Seaborgium",
    category: "Transition Metal",
    atomicMass: 269.0,
    funFact:
        "Seaborgium is a synthetic element with symbol Sg and atomic number 106. Its most stable isotope 271Sg has a half-life of 1.9 minutes. A more recently discovered isotope 269Sg has a potentially slightly longer half-life (ca.",
  ),
  // Box 79: Element 107 (Bh - Bohrium)
  "79": const ElementData(
    boxIndex: 79,
    atomicNumber: 107,
    symbol: "Bh",
    name: "Bohrium",
    category: "Transition Metal",
    atomicMass: 270.0,
    funFact:
        "Bohrium is a chemical element with symbol Bh and atomic number 107. It is named after Danish physicist Niels Bohr. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, 270Bh, has a half-life of approximately 61 seconds.",
  ),
  // Box 80: Element 108 (Hs - Hassium)
  "80": const ElementData(
    boxIndex: 80,
    atomicNumber: 108,
    symbol: "Hs",
    name: "Hassium",
    category: "Transition Metal",
    atomicMass: 269.0,
    funFact:
        "Hassium is a chemical element with symbol Hs and atomic number 108, named after the German state of Hesse. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and radioactive; the most stable known isotope, 269Hs, has a half-life of approximately 9.7 seconds, although an unconfirmed metastable state, 277mHs, may have a longer half-life of about 130 seconds. More than 100 atoms of hassium have been synthesized to date.",
  ),
  // Box 81: Element 109 (Mt - Meitnerium)
  "81": const ElementData(
    boxIndex: 81,
    atomicNumber: 109,
    symbol: "Mt",
    name: "Meitnerium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 278.0,
    funFact:
        "Meitnerium is a chemical element with symbol Mt and atomic number 109. It is an extremely radioactive synthetic element (an element not found in nature that can be created in a laboratory). The most stable known isotope, meitnerium-278, has a half-life of 7.6 seconds.",
  ),
  // Box 82: Element 110 (Ds - Darmstadtium)
  "82": const ElementData(
    boxIndex: 82,
    atomicNumber: 110,
    symbol: "Ds",
    name: "Darmstadtium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 281.0,
    funFact:
        "Darmstadtium is a chemical element with symbol Ds and atomic number 110. It is an extremely radioactive synthetic element. The most stable known isotope, darmstadtium-281, has a half-life of approximately 10 seconds.",
  ),
  // Box 83: Element 111 (Rg - Roentgenium)
  "83": const ElementData(
    boxIndex: 83,
    atomicNumber: 111,
    symbol: "Rg",
    name: "Roentgenium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 282.0,
    funFact:
        "Roentgenium is a chemical element with symbol Rg and atomic number 111. It is an extremely radioactive synthetic element (an element that can be created in a laboratory but is not found in nature); the most stable known isotope, roentgenium-282, has a half-life of 2.1 minutes. Roentgenium was first created in 1994 by the GSI Helmholtz Centre for Heavy Ion Research near Darmstadt, Germany.",
  ),
  // Box 84: Element 112 (Cn - Copernicium)
  "84": const ElementData(
    boxIndex: 84,
    atomicNumber: 112,
    symbol: "Cn",
    name: "Copernicium",
    category: "Transition Metal",
    atomicMass: 285.0,
    funFact:
        "Copernicium is a chemical element with symbol Cn and atomic number 112. It is an extremely radioactive synthetic element that can only be created in a laboratory. The most stable known isotope, copernicium-285, has a half-life of approximately 29 seconds, but it is possible that this copernicium isotope may have a nuclear isomer with a longer half-life, 8.9 min.",
  ),
  // Box 85: Element 113 (Nh - Nihonium)
  "85": const ElementData(
    boxIndex: 85,
    atomicNumber: 113,
    symbol: "Nh",
    name: "Nihonium",
    category: "Unknown, Probably Transition Metal",
    atomicMass: 286.0,
    funFact:
        "Nihonium is a chemical element with atomic number 113. It has a symbol Nh. It is a synthetic element (an element that can be created in a laboratory but is not found in nature) and is extremely radioactive; its most stable known isotope, nihonium-286, has a half-life of 20 seconds.",
  ),
  // Box 86: Element 114 (Fl - Flerovium)
  "86": const ElementData(
    boxIndex: 86,
    atomicNumber: 114,
    symbol: "Fl",
    name: "Flerovium",
    category: "Post-Transition Metal",
    atomicMass: 289.0,
    funFact:
        "Flerovium is a superheavy artificial chemical element with symbol Fl and atomic number 114. It is an extremely radioactive synthetic element. The element is named after the Flerov Laboratory of Nuclear Reactions of the Joint Institute for Nuclear Research in Dubna, Russia, where the element was discovered in 1998.",
  ),
  // Box 87: Element 115 (Mc - Moscovium)
  "87": const ElementData(
    boxIndex: 87,
    atomicNumber: 115,
    symbol: "Mc",
    name: "Moscovium",
    category: "Unknown, Probably Post-Transition Metal",
    atomicMass: 289.0,
    funFact:
        "Moscovium is the name of a synthetic superheavy element in the periodic table that has the symbol Mc and has the atomic number 115. It is an extremely radioactive element; its most stable known isotope, moscovium-289, has a half-life of only 220 milliseconds. It is also known as eka-bismuth or simply element 115.",
  ),
  // Box 88: Element 116 (Lv - Livermorium)
  "88": const ElementData(
    boxIndex: 88,
    atomicNumber: 116,
    symbol: "Lv",
    name: "Livermorium",
    category: "Unknown, Probably Post-Transition Metal",
    atomicMass: 293.0,
    funFact:
        "Livermorium is a synthetic superheavy element with symbol Lv and atomic number 116. It is an extremely radioactive element that has only been created in the laboratory and has not been observed in nature. The element is named after the Lawrence Livermore National Laboratory in the United States, which collaborated with the Joint Institute for Nuclear Research in Dubna, Russia to discover livermorium in 2000.",
  ),
  // Box 89: Element 117 (Ts - Tennessine)
  "89": const ElementData(
    boxIndex: 89,
    atomicNumber: 117,
    symbol: "Ts",
    name: "Tennessine",
    category: "Unknown, Probably Metalloid",
    atomicMass: 294.0,
    funFact:
        "Tennessine is a superheavy artificial chemical element with an atomic number of 117 and a symbol of Ts. Also known as eka-astatine or element 117, it is the second-heaviest known element and penultimate element of the 7th period of the periodic table. As of 2016, fifteen tennessine atoms have been observed: six when it was first synthesized in 2010, seven in 2012, and two in 2014.",
  ),
  // Box 90: Element 118 (Og - Oganesson)
  "90": const ElementData(
    boxIndex: 90,
    atomicNumber: 118,
    symbol: "Og",
    name: "Oganesson",
    category: "Unknown, Predicted To Be Noble Gas",
    atomicMass: 294.0,
    funFact:
        "Oganesson is IUPAC's name for the transactinide element with the atomic number 118 and element symbol Og. It is also known as eka-radon or element 118, and on the periodic table of the elements it is a p-block element and the last one of the 7th period. Oganesson is currently the only synthetic member of group 18.",
  ),
  // Box 91: Element 57 (La - Lanthanum)
  "91": const ElementData(
    boxIndex: 91,
    atomicNumber: 57,
    symbol: "La",
    name: "Lanthanum",
    category: "Lanthanide",
    atomicMass: 138.905477,
    funFact:
        "Lanthanum is a soft, ductile, silvery-white metallic chemical element with symbol La and atomic number 57. It tarnishes rapidly when exposed to air and is soft enough to be cut with a knife. It gave its name to the lanthanide series, a group of 15 similar elements between lanthanum and lutetium in the periodic table:it is also sometimes considered the first element of the 6th-period transition metals.",
  ),
  // Box 92: Element 58 (Ce - Cerium)
  "92": const ElementData(
    boxIndex: 92,
    atomicNumber: 58,
    symbol: "Ce",
    name: "Cerium",
    category: "Lanthanide",
    atomicMass: 140.1161,
    funFact:
        "Cerium is a chemical element with symbol Ce and atomic number 58. It is a soft, silvery, ductile metal which easily oxidizes in air. Cerium was named after the dwarf planet Ceres (itself named after the Roman goddess of agriculture).",
  ),
  // Box 93: Element 59 (Pr - Praseodymium)
  "93": const ElementData(
    boxIndex: 93,
    atomicNumber: 59,
    symbol: "Pr",
    name: "Praseodymium",
    category: "Lanthanide",
    atomicMass: 140.907662,
    funFact:
        "Praseodymium is a chemical element with symbol Pr and atomic number 59. Praseodymium is a soft, silvery, malleable and ductile metal in the lanthanide group. It is valued for its magnetic, electrical, chemical, and optical properties.",
  ),
  // Box 94: Element 60 (Nd - Neodymium)
  "94": const ElementData(
    boxIndex: 94,
    atomicNumber: 60,
    symbol: "Nd",
    name: "Neodymium",
    category: "Lanthanide",
    atomicMass: 144.2423,
    funFact:
        "Neodymium is a chemical element with symbol Nd and atomic number 60. It is a soft silvery metal that tarnishes in air. Neodymium was discovered in 1885 by the Austrian chemist Carl Auer von Welsbach.",
  ),
  // Box 95: Element 61 (Pm - Promethium)
  "95": const ElementData(
    boxIndex: 95,
    atomicNumber: 61,
    symbol: "Pm",
    name: "Promethium",
    category: "Lanthanide",
    atomicMass: 145.0,
    funFact:
        "Promethium, originally prometheum, is a chemical element with the symbol Pm and atomic number 61. All of its isotopes are radioactive; it is one of only two such elements that are followed in the periodic table by elements with stable forms, a distinction shared with technetium. Chemically, promethium is a lanthanide, which forms salts when combined with other elements.",
  ),
  // Box 96: Element 62 (Sm - Samarium)
  "96": const ElementData(
    boxIndex: 96,
    atomicNumber: 62,
    symbol: "Sm",
    name: "Samarium",
    category: "Lanthanide",
    atomicMass: 150.362,
    funFact:
        "Samarium is a chemical element with symbol Sm and atomic number 62. It is a moderately hard silvery metal that readily oxidizes in air. Being a typical member of the lanthanide series, samarium usually assumes the oxidation state +3.",
  ),
  // Box 97: Element 63 (Eu - Europium)
  "97": const ElementData(
    boxIndex: 97,
    atomicNumber: 63,
    symbol: "Eu",
    name: "Europium",
    category: "Lanthanide",
    atomicMass: 151.9641,
    funFact:
        "Europium is a chemical element with symbol Eu and atomic number 63. It was isolated in 1901 and is named after the continent of Europe. It is a moderately hard, silvery metal which readily oxidizes in air and water.",
  ),
  // Box 98: Element 64 (Gd - Gadolinium)
  "98": const ElementData(
    boxIndex: 98,
    atomicNumber: 64,
    symbol: "Gd",
    name: "Gadolinium",
    category: "Lanthanide",
    atomicMass: 157.253,
    funFact:
        "Gadolinium is a chemical element with symbol Gd and atomic number 64. It is a silvery-white, malleable and ductile rare-earth metal. It is found in nature only in combined (salt) form.",
  ),
  // Box 99: Element 65 (Tb - Terbium)
  "99": const ElementData(
    boxIndex: 99,
    atomicNumber: 65,
    symbol: "Tb",
    name: "Terbium",
    category: "Lanthanide",
    atomicMass: 158.925352,
    funFact:
        "Terbium is a chemical element with symbol Tb and atomic number 65. It is a silvery-white rare earth metal that is malleable, ductile and soft enough to be cut with a knife. Terbium is never found in nature as a free element, but it is contained in many minerals, including cerite, gadolinite, monazite, xenotime and euxenite.",
  ),
  // Box 100: Element 66 (Dy - Dysprosium)
  "100": const ElementData(
    boxIndex: 100,
    atomicNumber: 66,
    symbol: "Dy",
    name: "Dysprosium",
    category: "Lanthanide",
    atomicMass: 162.5001,
    funFact:
        "Dysprosium is a chemical element with the symbol Dy and atomic number 66. It is a rare earth element with a metallic silver luster. Dysprosium is never found in nature as a free element, though it is found in various minerals, such as xenotime.",
  ),
  // Box 101: Element 67 (Ho - Holmium)
  "101": const ElementData(
    boxIndex: 101,
    atomicNumber: 67,
    symbol: "Ho",
    name: "Holmium",
    category: "Lanthanide",
    atomicMass: 164.930332,
    funFact:
        "Holmium is a chemical element with symbol Ho and atomic number 67. Part of the lanthanide series, holmium is a rare earth element. Holmium was discovered by Swedish chemist Per Theodor Cleve.",
  ),
  // Box 102: Element 68 (Er - Erbium)
  "102": const ElementData(
    boxIndex: 102,
    atomicNumber: 68,
    symbol: "Er",
    name: "Erbium",
    category: "Lanthanide",
    atomicMass: 167.2593,
    funFact:
        "Erbium is a chemical element in the lanthanide series, with symbol Er and atomic number 68. A silvery-white solid metal when artificially isolated, natural erbium is always found in chemical combination with other elements on Earth. As such, it is a rare earth element which is associated with several other rare elements in the mineral gadolinite from Ytterby in Sweden, where yttrium, ytterbium, and terbium were discovered.",
  ),
  // Box 103: Element 69 (Tm - Thulium)
  "103": const ElementData(
    boxIndex: 103,
    atomicNumber: 69,
    symbol: "Tm",
    name: "Thulium",
    category: "Lanthanide",
    atomicMass: 168.934222,
    funFact:
        "Thulium is a chemical element with symbol Tm and atomic number 69. It is the thirteenth and antepenultimate (third-last) element in the lanthanide series. Like the other lanthanides, the most common oxidation state is +3, seen in its oxide, halides and other compounds.",
  ),
  // Box 104: Element 70 (Yb - Ytterbium)
  "104": const ElementData(
    boxIndex: 104,
    atomicNumber: 70,
    symbol: "Yb",
    name: "Ytterbium",
    category: "Lanthanide",
    atomicMass: 173.0451,
    funFact:
        "Ytterbium is a chemical element with symbol Yb and atomic number 70. It is the fourteenth and penultimate element in the lanthanide series, which is the basis of the relative stability of its +2 oxidation state. However, like the other lanthanides, its most common oxidation state is +3, seen in its oxide, halides and other compounds.",
  ),
  // Box 105: Element 71 (Lu - Lutetium)
  "105": const ElementData(
    boxIndex: 105,
    atomicNumber: 71,
    symbol: "Lu",
    name: "Lutetium",
    category: "Lanthanide",
    atomicMass: 174.96681,
    funFact:
        "Lutetium is a chemical element with symbol Lu and atomic number 71. It is a silvery white metal, which resists corrosion in dry, but not in moist air. It is considered the first element of the 6th-period transition metals and the last element in the lanthanide series, and is traditionally counted among the rare earths.",
  ),
  // Box 106: Element 89 (Ac - Actinium)
  "106": const ElementData(
    boxIndex: 106,
    atomicNumber: 89,
    symbol: "Ac",
    name: "Actinium",
    category: "Actinide",
    atomicMass: 227.0,
    funFact:
        "Actinium is a radioactive chemical element with symbol Ac (not to be confused with the abbreviation for an acetyl group) and atomic number 89, which was discovered in 1899. It was the first non-primordial radioactive element to be isolated. Polonium, radium and radon were observed before actinium, but they were not isolated until 1902.",
  ),
  // Box 107: Element 90 (Th - Thorium)
  "107": const ElementData(
    boxIndex: 107,
    atomicNumber: 90,
    symbol: "Th",
    name: "Thorium",
    category: "Actinide",
    atomicMass: 232.03774,
    funFact:
        "Thorium is a chemical element with symbol Th and atomic number 90. A radioactive actinide metal, thorium is one of only two significantly radioactive elements that still occur naturally in large quantities as a primordial element (the other being uranium). It was discovered in 1828 by the Norwegian Reverend and amateur mineralogist Morten Thrane Esmark and identified by the Swedish chemist Jöns Jakob Berzelius, who named it after Thor, the Norse god of thunder.",
  ),
  // Box 108: Element 91 (Pa - Protactinium)
  "108": const ElementData(
    boxIndex: 108,
    atomicNumber: 91,
    symbol: "Pa",
    name: "Protactinium",
    category: "Actinide",
    atomicMass: 231.035882,
    funFact:
        "Protactinium is a chemical element with symbol Pa and atomic number 91. It is a dense, silvery-gray metal which readily reacts with oxygen, water vapor and inorganic acids. It forms various chemical compounds where protactinium is usually present in the oxidation state +5, but can also assume +4 and even +2 or +3 states.",
  ),
  // Box 109: Element 92 (U - Uranium)
  "109": const ElementData(
    boxIndex: 109,
    atomicNumber: 92,
    symbol: "U",
    name: "Uranium",
    category: "Actinide",
    atomicMass: 238.028913,
    funFact:
        "Uranium is a chemical element with symbol U and atomic number 92. It is a silvery-white metal in the actinide series of the periodic table. A uranium atom has 92 protons and 92 electrons, of which 6 are valence electrons.",
  ),
  // Box 110: Element 93 (Np - Neptunium)
  "110": const ElementData(
    boxIndex: 110,
    atomicNumber: 93,
    symbol: "Np",
    name: "Neptunium",
    category: "Actinide",
    atomicMass: 237.0,
    funFact:
        "Neptunium is a chemical element with symbol Np and atomic number 93. A radioactive actinide metal, neptunium is the first transuranic element. Its position in the periodic table just after uranium, named after the planet Uranus, led to it being named after Neptune, the next planet beyond Uranus.",
  ),
  // Box 111: Element 94 (Pu - Plutonium)
  "111": const ElementData(
    boxIndex: 111,
    atomicNumber: 94,
    symbol: "Pu",
    name: "Plutonium",
    category: "Actinide",
    atomicMass: 244.0,
    funFact:
        "Plutonium is a transuranic radioactive chemical element with symbol Pu and atomic number 94. It is an actinide metal of silvery-gray appearance that tarnishes when exposed to air, and forms a dull coating when oxidized. The element normally exhibits six allotropes and four oxidation states.",
  ),
  // Box 112: Element 95 (Am - Americium)
  "112": const ElementData(
    boxIndex: 112,
    atomicNumber: 95,
    symbol: "Am",
    name: "Americium",
    category: "Actinide",
    atomicMass: 243.0,
    funFact:
        "Americium is a radioactive transuranic chemical element with symbol Am and atomic number 95. This member of the actinide series is located in the periodic table under the lanthanide element europium, and thus by analogy was named after the Americas. Americium was first produced in 1944 by the group of Glenn T.Seaborg from Berkeley, California, at the metallurgical laboratory of University of Chicago.",
  ),
  // Box 113: Element 96 (Cm - Curium)
  "113": const ElementData(
    boxIndex: 113,
    atomicNumber: 96,
    symbol: "Cm",
    name: "Curium",
    category: "Actinide",
    atomicMass: 247.0,
    funFact:
        "Curium is a transuranic radioactive chemical element with symbol Cm and atomic number 96. This element of the actinide series was named after Marie and Pierre Curie – both were known for their research on radioactivity. Curium was first intentionally produced and identified in July 1944 by the group of Glenn T. Seaborg at the University of California, Berkeley.",
  ),
  // Box 114: Element 97 (Bk - Berkelium)
  "114": const ElementData(
    boxIndex: 114,
    atomicNumber: 97,
    symbol: "Bk",
    name: "Berkelium",
    category: "Actinide",
    atomicMass: 247.0,
    funFact:
        "Berkelium is a transuranic radioactive chemical element with symbol Bk and atomic number 97. It is a member of the actinide and transuranium element series. It is named after the city of Berkeley, California, the location of the University of California Radiation Laboratory where it was discovered in December 1949.",
  ),
  // Box 115: Element 98 (Cf - Californium)
  "115": const ElementData(
    boxIndex: 115,
    atomicNumber: 98,
    symbol: "Cf",
    name: "Californium",
    category: "Actinide",
    atomicMass: 251.0,
    funFact:
        "Californium is a radioactive metallic chemical element with symbol Cf and atomic number 98. The element was first made in 1950 at the University of California Radiation Laboratory in Berkeley, by bombarding curium with alpha particles (helium-4 ions). It is an actinide element, the sixth transuranium element to be synthesized, and has the second-highest atomic mass of all the elements that have been produced in amounts large enough to see with the unaided eye (after einsteinium).",
  ),
  // Box 116: Element 99 (Es - Einsteinium)
  "116": const ElementData(
    boxIndex: 116,
    atomicNumber: 99,
    symbol: "Es",
    name: "Einsteinium",
    category: "Actinide",
    atomicMass: 252.0,
    funFact:
        "Einsteinium is a synthetic element with symbol Es and atomic number 99. It is the seventh transuranic element, and an actinide. Einsteinium was discovered as a component of the debris of the first hydrogen bomb explosion in 1952, and named after Albert Einstein.",
  ),
  // Box 117: Element 100 (Fm - Fermium)
  "117": const ElementData(
    boxIndex: 117,
    atomicNumber: 100,
    symbol: "Fm",
    name: "Fermium",
    category: "Actinide",
    atomicMass: 257.0,
    funFact:
        "Fermium is a synthetic element with symbol Fm and atomic number 100. It is a member of the actinide series. It is the heaviest element that can be formed by neutron bombardment of lighter elements, and hence the last element that can be prepared in macroscopic quantities, although pure fermium metal has not yet been prepared.",
  ),
  // Box 118: Element 101 (Md - Mendelevium)
  "118": const ElementData(
    boxIndex: 118,
    atomicNumber: 101,
    symbol: "Md",
    name: "Mendelevium",
    category: "Actinide",
    atomicMass: 258.0,
    funFact:
        "Mendelevium is a synthetic element with chemical symbol Md (formerly Mv) and atomic number 101. A metallic radioactive transuranic element in the actinide series, it is the first element that currently cannot be produced in macroscopic quantities through neutron bombardment of lighter elements. It is the antepenultimate actinide and the ninth transuranic element.",
  ),
  // Box 119: Element 102 (No - Nobelium)
  "119": const ElementData(
    boxIndex: 119,
    atomicNumber: 102,
    symbol: "No",
    name: "Nobelium",
    category: "Actinide",
    atomicMass: 259.0,
    funFact:
        "Nobelium is a synthetic chemical element with symbol No and atomic number 102. It is named in honor of Alfred Nobel, the inventor of dynamite and benefactor of science. A radioactive metal, it is the tenth transuranic element and is the penultimate member of the actinide series.",
  ),
  // Box 120: Element 103 (Lr - Lawrencium)
  "120": const ElementData(
    boxIndex: 120,
    atomicNumber: 103,
    symbol: "Lr",
    name: "Lawrencium",
    category: "Actinide",
    atomicMass: 266.0,
    funFact:
        "Lawrencium is a synthetic chemical element with chemical symbol Lr (formerly Lw) and atomic number 103. It is named in honor of Ernest Lawrence, inventor of the cyclotron, a device that was used to discover many artificial radioactive elements. A radioactive metal, lawrencium is the eleventh transuranic element and is also the final member of the actinide series.",
  ),
};

// ---------------------------------------------------------
// Universal Element Resolver Function
// Supports box numbers ("58", "box 58"), atomic numbers ("72"),
// and chemical symbols ("Hf", "hf")
// ---------------------------------------------------------
ElementData? getElementData(String query) {
  final clean = query.trim();
  if (clean.isEmpty) return null;

  // 1. Direct match in periodicTable (Box number "1" - "120")
  if (periodicTable.containsKey(clean)) {
    return periodicTable[clean];
  }

  // 2. Extract digits if "box 58", "box_58", etc.
  final numMatch = RegExp(r'\d+').firstMatch(clean);
  if (numMatch != null) {
    final digits = numMatch.group(0)!;
    if (periodicTable.containsKey(digits)) {
      return periodicTable[digits];
    }
    final numVal = int.tryParse(digits);
    if (numVal != null && elementsByAtomicNumber.containsKey(numVal)) {
      return elementsByAtomicNumber[numVal];
    }
  }

  // 3. Match by chemical symbol or element name (case-insensitive)
  final lower = clean.toLowerCase();
  for (final elem in periodicTable.values) {
    if (elem.symbol.toLowerCase() == lower ||
        elem.name.toLowerCase() == lower) {
      return elem;
    }
  }

  return null;
}
