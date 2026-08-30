import { useState, useEffect } from 'react';
import { collection, query, onSnapshot, doc, setDoc, updateDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { Edit, Save, X, RefreshCw, Layers } from 'lucide-react';

const DUMMY_EXPERIMENTS = [
  {
    id: 'ar1',
    title: 'Limewater Test for Carbon Dioxide',
    topic: 'Gas Testing',
    category: 'Chemical Reactions',
    backgroundInfo: 'Limewater (calcium hydroxide solution) turns milky white when carbon dioxide is bubbled through it. This classic test detects CO₂ by forming insoluble calcium carbonate (CaCO₃) as a white precipitate, demonstrating a simple and reliable qualitative gas test used in chemistry labs worldwide.',
    safetyNote: 'Limewater is mildly alkaline (pH ~12). Avoid contact with eyes and skin. Wear safety goggles and gloves. Do not ingest. Ensure adequate ventilation when generating CO₂ from acid-carbonate reactions.',
    relatedConcepts: ['Carbon Dioxide', 'Calcium Hydroxide', 'Precipitation Reactions', 'Qualitative Analysis', 'Carbonates'],
    requiredMaterials: ['Limewater (calcium hydroxide) solution', 'Test tubes or flasks', 'Delivery tube with stopper', 'Source of CO₂ (e.g., dilute acid and carbonate salt)', 'Safety goggles'],
    steps: [
      { bottleTag: 'ChemicalA', instructionTitle: 'Step 1: Base Liquid', instructionDetail: 'Pour the base solution.' },
      { bottleTag: 'ActivatorB', instructionTitle: 'Step 2: Catalyst', instructionDetail: 'Add the activator to complete.' },
    ],
    thumbnailUrl: 'https://img.rocket.new/generatedImages/rocket_gen_img_159a809cd-1767041982810.png',
    iconName: 'bubble_chart',
    tintColorValue: 0xFF0D2E1F,
    semanticLabel: 'Clear glass flask with milky white liquid showing carbon dioxide limewater test',
  },
  {
    id: 'ar2',
    title: 'Silver Nitrate Precipitation Test',
    topic: 'Halide Ion Testing',
    category: 'Precipitation',
    backgroundInfo: 'Silver nitrate (AgNO₃) is used to identify halide ions (Cl⁻, Br⁻, I⁻) in solution. Adding AgNO₃ produces characteristic colored precipitates: white for chloride, cream for bromide, and pale yellow for iodide. This test is a cornerstone of qualitative inorganic analysis.',
    safetyNote: 'Silver nitrate is corrosive and will stain skin and clothing dark brown/black. Wear gloves and goggles at all times. Avoid contact with organic materials. Dispose of silver waste in designated containers — do not pour down the drain.',
    relatedConcepts: ['Halide Ions', 'Ionic Precipitation', 'Qualitative Analysis', 'Solubility Rules', 'Silver Compounds'],
    requiredMaterials: ['Silver nitrate solution (AgNO₃, 0.1 M)', 'Test tubes and rack', 'Droppers or pipettes', 'Solutions containing Cl⁻, Br⁻, and I⁻ ions', 'Dilute nitric acid (HNO₃)'],
    steps: [
      { bottleTag: 'ReagentX', instructionTitle: 'Step 1: Reagent', instructionDetail: 'Add Reagent X.' },
    ],
    thumbnailUrl: 'https://img.rocket.new/generatedImages/rocket_gen_img_173eec5f9-1784971684687.png',
    iconName: 'science',
    tintColorValue: 0xFF1E1535,
    semanticLabel: 'Test tubes showing white cream and yellow precipitates from silver nitrate halide tests',
  },
  {
    id: 'ar3',
    title: 'Conductivity Test',
    topic: 'Electrical Conductivity',
    category: 'Electrochemistry',
    backgroundInfo: 'The conductivity test determines whether a substance conducts electricity by completing a circuit with a light bulb or LED. Ionic compounds in solution and metals conduct electricity, while covalent compounds and distilled water do not. This experiment distinguishes electrolytes from non-electrolytes.',
    safetyNote: 'Use low-voltage power sources (batteries, 6V max). Never use mains electricity for conductivity tests. Keep water away from electrical connections. Dry hands before handling equipment. Dispose of solutions properly after testing.',
    relatedConcepts: ['Electrolytes', 'Ionic Compounds', 'Electric Current', 'Free Ions', 'Metallic Bonding'],
    requiredMaterials: ['Conductivity apparatus (battery, wires, light bulb/LED, electrodes)', 'Small beakers', 'Distilled water', 'Various test substances (NaCl, sugar, tap water)', 'Stirring rods'],
    steps: [
      { bottleTag: 'ElectrodeA', instructionTitle: 'Step 1: Setup', instructionDetail: 'Place the electrodes.' },
      { bottleTag: 'Power', instructionTitle: 'Step 2: Power On', instructionDetail: 'Connect to battery.' },
    ],
    thumbnailUrl: 'https://img.rocket.new/generatedImages/rocket_gen_img_14f381e2d-1784971685298.png',
    iconName: 'bolt',
    tintColorValue: 0xFF0D2A2E,
    semanticLabel: 'Conductivity apparatus with electrodes in solution connected to a light bulb',
  },
  {
    id: 'ar4',
    title: 'Law of Conservation of Mass',
    topic: 'Stoichiometry',
    category: 'Chemical Reactions',
    backgroundInfo: 'The Law of Conservation of Mass states that mass is neither created nor destroyed in a chemical reaction. By measuring the total mass of reactants before and after a reaction in a closed system, students verify that the total mass remains constant, confirming Lavoisier\'s foundational principle of chemistry.',
    safetyNote: 'Use sealed containers when performing reactions that produce gases to prevent mass loss. Handle chemicals carefully to avoid spills. Wear goggles and gloves. Ensure the balance is calibrated and on a stable surface before measuring.',
    relatedConcepts: ['Stoichiometry', 'Balanced Equations', 'Closed Systems', 'Antoine Lavoisier', 'Mole Concept'],
    requiredMaterials: ['Electronic balance (sensitive to 0.01g)', 'Erlenmeyer flask', 'Balloon or tight-fitting stopper', 'Baking soda (Sodium bicarbonate)', 'Vinegar (Dilute acetic acid)'],
    steps: [],
    thumbnailUrl: 'https://images.pexels.com/photos/3735747/pexels-photo-3735747.jpeg',
    iconName: 'balance',
    tintColorValue: 0xFF2E1510,
    semanticLabel: 'Laboratory balance scale with chemical flasks demonstrating conservation of mass',
  },
  {
    id: 'ar5',
    title: 'pH Indicator Acid and Base',
    topic: 'Acid-Base Chemistry',
    category: 'Chemical Reactions',
    backgroundInfo: 'pH indicators are substances that change color depending on the acidity or alkalinity of a solution. Natural indicators like red cabbage juice and universal indicator paper display a spectrum of colors from red (acidic) to purple (alkaline), allowing students to classify common household substances on the pH scale.',
    safetyNote: 'Some acids and bases are corrosive. Always wear goggles and gloves. Avoid skin contact with strong acids (HCl, H₂SO₄) or strong bases (NaOH). Neutralize spills with sodium bicarbonate (for acids) or dilute acid (for bases) before cleaning.',
    relatedConcepts: ['pH Scale', 'Acids and Bases', 'Neutralization', 'Indicators', 'Hydrogen Ion Concentration'],
    requiredMaterials: ['Universal indicator solution or red cabbage juice', 'Test tubes or spotting plate', 'Droppers', 'Various test liquids (lemon juice, vinegar, soapy water, etc.)', 'pH color chart'],
    steps: [],
    thumbnailUrl: 'https://img.rocket.new/generatedImages/rocket_gen_img_1d0d8b59b-1772367719711.png',
    iconName: 'colorize',
    tintColorValue: 0xFF0D2E3F,
    semanticLabel: 'Row of test tubes showing rainbow of colors from pH indicator acid base test',
  },
  {
    id: 'ar6',
    title: 'Elephant Toothpaste',
    topic: 'Decomposition Reactions',
    category: 'Chemical Reactions',
    backgroundInfo: 'Elephant Toothpaste is a dramatic decomposition reaction where hydrogen peroxide rapidly breaks down into water and oxygen gas, catalyzed by potassium iodide or yeast. The rapid release of oxygen creates a large foam eruption. This experiment demonstrates catalysis, decomposition reactions, and exothermic processes in a visually spectacular way.',
    safetyNote: 'Use only 3–6% hydrogen peroxide for classroom demonstrations. High-concentration H₂O₂ (30%+) causes severe burns and must only be handled by trained instructors with full PPE. The reaction is exothermic — the foam will be hot. Do not touch immediately after the reaction.',
    relatedConcepts: ['Catalysis', 'Decomposition Reactions', 'Exothermic Reactions', 'Hydrogen Peroxide', 'Oxygen Gas'],
    requiredMaterials: ['Hydrogen peroxide (3% or 6%)', 'Liquid dish soap', 'Food coloring', 'Dry yeast dissolved in warm water (or KI solution)', 'Graduated cylinder or empty plastic bottle', 'Safety tray or tarp (to catch foam)'],
    steps: [
      { bottleTag: 'Surf', instructionTitle: 'Step 1: Add Soap', instructionDetail: 'Pour the dish soap into the beaker.' },
      { bottleTag: 'Peroxide', instructionTitle: 'Step 2: Add Peroxide', instructionDetail: 'Add hydrogen peroxide to the mixture.' },
      { bottleTag: 'Dye', instructionTitle: 'Step 3: Add Dye', instructionDetail: 'Add food coloring.' },
      { bottleTag: 'Yeast', instructionTitle: 'Step 4: Add Yeast to Cylinder', instructionDetail: 'Pour the yeast into the cylinder with water' },
      { bottleTag: 'Activator', instructionTitle: 'Step 5: Pour Yeast', instructionDetail: 'Pour the Cylinder with yeast last to start the reaction!' }
    ],
    thumbnailUrl: 'https://img.rocket.new/generatedImages/rocket_gen_img_1ee613807-1784971685914.png',
    iconName: 'waves',
    tintColorValue: 0xFF1A2E0D,
    semanticLabel: 'Large colorful foam eruption from cylinder demonstrating elephant toothpaste reaction',
  },
  {
    id: 'ar7',
    title: 'Flame Test',
    topic: 'Atomic Emission Spectra',
    category: 'Spectroscopy',
    backgroundInfo: 'The flame test identifies metal ions by the characteristic colors they produce when heated in a flame. Each metal emits a unique color due to electrons jumping to higher energy levels and releasing photons of specific wavelengths when they return to ground state. Lithium burns red, sodium yellow, potassium lilac, copper green-blue, and barium pale green.',
    safetyNote: 'Always work near a fume hood or in a well-ventilated area. Tie back hair and avoid loose clothing near open flames. Use nichrome wire loops cleaned with hydrochloric acid between tests. Some metal salts (barium compounds) are toxic — wash hands thoroughly after handling.',
    relatedConcepts: ['Atomic Emission Spectra', 'Electron Energy Levels', 'Photon Emission', 'Metal Ion Identification', 'Spectroscopy'],
    requiredMaterials: ['Bunsen burner', 'Nichrome wire loops or wooden splints soaked in water', 'Dilute hydrochloric acid (for cleaning wire)', 'Metal salt solutions (LiCl, NaCl, KCl, CuCl₂, BaCl₂)', 'Safety goggles'],
    steps: [
      { bottleTag: 'ElementA', instructionTitle: 'Step 1: Element', instructionDetail: 'Inspect Element A.' }
    ],
    thumbnailUrl: 'https://img.rocket.new/generatedImages/rocket_gen_img_1817773a0-1784320962469.png',
    iconName: 'local_fire_department',
    tintColorValue: 0xFF2E1A00,
    semanticLabel: 'Colorful flame test showing bright orange yellow and green flames from metal salts',
  }
];

export default function ARLabManager() {
  const [experiments, setExperiments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingExp, setEditingExp] = useState(null);
  const [seeding, setSeeding] = useState(false);

  useEffect(() => {
    const q = query(collection(db, 'ar_experiments'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const expData = [];
      snapshot.forEach(doc => {
        expData.push({ _docId: doc.id, ...doc.data() });
      });
      // Sort by ID to keep them in order
      expData.sort((a, b) => a.id.localeCompare(b.id));
      setExperiments(expData);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleSeedData = async () => {
    setSeeding(true);
    try {
      for (const exp of DUMMY_EXPERIMENTS) {
        await setDoc(doc(db, 'ar_experiments', exp.id), exp);
      }
      alert('Initial AR experiments seeded successfully!');
    } catch (error) {
      console.error(error);
      alert('Error seeding data: ' + error.message);
    }
    setSeeding(false);
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (!editingExp) return;
    try {
      await updateDoc(doc(db, 'ar_experiments', editingExp._docId), {
        title: editingExp.title,
        topic: editingExp.topic,
        category: editingExp.category,
        backgroundInfo: editingExp.backgroundInfo,
        safetyNote: editingExp.safetyNote,
        relatedConcepts: editingExp.relatedConcepts,
        requiredMaterials: editingExp.requiredMaterials,
        steps: editingExp.steps || [],
      });
      setEditingExp(null);
    } catch (error) {
      console.error(error);
      alert('Error updating experiment: ' + error.message);
    }
  };

  const handleArrayChange = (field, index, value) => {
    const newArray = [...editingExp[field]];
    newArray[index] = value;
    setEditingExp({ ...editingExp, [field]: newArray });
  };

  const handleArrayAdd = (field) => {
    setEditingExp({ ...editingExp, [field]: [...editingExp[field], ''] });
  };

  const handleArrayRemove = (field, index) => {
    const newArray = editingExp[field].filter((_, i) => i !== index);
    setEditingExp({ ...editingExp, [field]: newArray });
  };

  const handleStepChange = (index, field, value) => {
    const newSteps = [...(editingExp.steps || [])];
    newSteps[index] = { ...newSteps[index], [field]: value };
    setEditingExp({ ...editingExp, steps: newSteps });
  };

  const handleStepAdd = () => {
    const newSteps = [...(editingExp.steps || []), { bottleTag: '', instructionTitle: '', instructionDetail: '' }];
    setEditingExp({ ...editingExp, steps: newSteps });
  };

  const handleStepRemove = (index) => {
    const newSteps = (editingExp.steps || []).filter((_, i) => i !== index);
    setEditingExp({ ...editingExp, steps: newSteps });
  };

  if (loading) {
    return <div style={{ padding: '40px', color: 'white', textAlign: 'center' }}>Loading experiments...</div>;
  }

  return (
    <div className="animate-fade-in" style={{ paddingBottom: '60px' }}>
      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <h1>AR Lab Content</h1>
          <p>Manage background information, safety notes, and materials for AR experiments.</p>
        </div>
        {experiments.length === 0 && (
          <button 
            className="btn btn-primary" 
            onClick={handleSeedData}
            disabled={seeding}
          >
            <RefreshCw size={18} className={seeding ? "animate-spin" : ""} />
            {seeding ? 'Seeding...' : 'Initialize Database'}
          </button>
        )}
      </div>

      <div className="glass-panel" style={{ padding: '24px' }}>
        {experiments.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
            <Layers size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
            <h3>No AR Experiments Found</h3>
            <p style={{ maxWidth: '400px', margin: '0 auto' }}>
              The database is currently empty. Click the <strong>Initialize Database</strong> button above to populate it with the default experiments.
            </p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {experiments.map(exp => (
              <div className="flex-mobile-col" key={exp._docId} style={{ 
                background: 'rgba(255,255,255,0.03)', 
                border: '1px solid var(--border-light)',
                borderRadius: '12px',
                padding: '20px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                gap: '16px'
              }}>
                <div>
                  <h3 style={{ margin: '0 0 8px 0', color: 'white' }}>{exp.title}</h3>
                  <div style={{ display: 'flex', gap: '12px', color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
                    <span className="badge badge-role" style={{ background: 'rgba(0,184,255,0.1)', color: 'var(--accent-blue)' }}>{exp.category}</span>
                    <span>Topic: {exp.topic}</span>
                  </div>
                </div>
                <button className="btn btn-secondary mobile-w-full" onClick={() => setEditingExp({...exp})}>
                  <Edit size={16} /> Edit Content
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Edit Modal */}
      {editingExp && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          backdropFilter: 'blur(8px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 1000,
          padding: '20px'
        }}>
          <div className="glass-panel animate-fade-in" style={{ 
            width: '100%', maxWidth: '800px', 
            maxHeight: '90vh', overflowY: 'auto',
            padding: '32px',
            border: '1px solid var(--border-light)'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h2 style={{ margin: 0, color: 'white' }}>Edit AR Experiment</h2>
              <button className="btn btn-secondary" onClick={() => setEditingExp(null)} style={{ padding: '8px' }}>
                <X size={20} />
              </button>
            </div>

            <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
              
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="input-group">
                  <label className="input-label">Title</label>
                  <input 
                    className="input-field" 
                    value={editingExp.title}
                    onChange={(e) => setEditingExp({...editingExp, title: e.target.value})}
                    required
                  />
                </div>
                <div className="input-group">
                  <label className="input-label">Topic</label>
                  <input 
                    className="input-field" 
                    value={editingExp.topic}
                    onChange={(e) => setEditingExp({...editingExp, topic: e.target.value})}
                    required
                  />
                </div>
              </div>

              <div className="input-group">
                <label className="input-label">Category</label>
                <select 
                  className="input-field" 
                  value={editingExp.category}
                  onChange={(e) => setEditingExp({...editingExp, category: e.target.value})}
                >
                  <option value="Chemical Reactions">Chemical Reactions</option>
                  <option value="Precipitation">Precipitation</option>
                  <option value="Electrochemistry">Electrochemistry</option>
                  <option value="Spectroscopy">Spectroscopy</option>
                </select>
              </div>

              <div className="input-group">
                <label className="input-label">Background Information</label>
                <textarea 
                  className="input-field" 
                  value={editingExp.backgroundInfo}
                  onChange={(e) => setEditingExp({...editingExp, backgroundInfo: e.target.value})}
                  rows={4}
                  style={{ resize: 'vertical' }}
                  required
                />
              </div>

              <div className="input-group">
                <label className="input-label">Safety Notes</label>
                <textarea 
                  className="input-field" 
                  value={editingExp.safetyNote}
                  onChange={(e) => setEditingExp({...editingExp, safetyNote: e.target.value})}
                  rows={3}
                  style={{ resize: 'vertical' }}
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
                {/* Required Materials */}
                <div className="input-group">
                  <label className="input-label" style={{ display: 'flex', justifyContent: 'space-between' }}>
                    Required Materials
                    <button type="button" onClick={() => handleArrayAdd('requiredMaterials')} style={{ background: 'none', border: 'none', color: 'var(--accent-green)', cursor: 'pointer', fontSize: '0.8rem' }}>
                      + Add Material
                    </button>
                  </label>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    {editingExp.requiredMaterials.map((material, index) => (
                      <div key={`mat-${index}`} style={{ display: 'flex', gap: '8px' }}>
                        <input 
                          className="input-field" 
                          style={{ margin: 0 }}
                          value={material}
                          onChange={(e) => handleArrayChange('requiredMaterials', index, e.target.value)}
                        />
                        <button type="button" onClick={() => handleArrayRemove('requiredMaterials', index)} className="btn btn-secondary" style={{ padding: '8px' }}>
                          <X size={16} />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Related Concepts */}
                <div className="input-group">
                  <label className="input-label" style={{ display: 'flex', justifyContent: 'space-between' }}>
                    Related Concepts
                    <button type="button" onClick={() => handleArrayAdd('relatedConcepts')} style={{ background: 'none', border: 'none', color: 'var(--accent-blue)', cursor: 'pointer', fontSize: '0.8rem' }}>
                      + Add Concept
                    </button>
                  </label>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    {editingExp.relatedConcepts.map((concept, index) => (
                      <div key={`con-${index}`} style={{ display: 'flex', gap: '8px' }}>
                        <input 
                          className="input-field" 
                          style={{ margin: 0 }}
                          value={concept}
                          onChange={(e) => handleArrayChange('relatedConcepts', index, e.target.value)}
                        />
                        <button type="button" onClick={() => handleArrayRemove('relatedConcepts', index)} className="btn btn-secondary" style={{ padding: '8px' }}>
                          <X size={16} />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <div className="input-group">
                <label className="input-label" style={{ display: 'flex', justifyContent: 'space-between' }}>
                  Experiment Steps (Dynamic AR Actions)
                  <button type="button" onClick={handleStepAdd} style={{ background: 'none', border: 'none', color: 'var(--accent-purple)', cursor: 'pointer', fontSize: '0.8rem', fontWeight: 'bold' }}>
                    + Add Step
                  </button>
                </label>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  {(editingExp.steps || []).map((step, index) => (
                    <div key={`step-${index}`} style={{ display: 'grid', gridTemplateColumns: '1fr 2fr 3fr auto', gap: '8px', alignItems: 'start', background: 'rgba(255,255,255,0.02)', padding: '12px', borderRadius: '8px', border: '1px solid var(--border-light)' }}>
                      <div>
                        <div style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Bottle Tag</div>
                        <input className="input-field" style={{ margin: 0, padding: '6px' }} value={step.bottleTag} onChange={(e) => handleStepChange(index, 'bottleTag', e.target.value)} placeholder="e.g. Surf" required />
                      </div>
                      <div>
                        <div style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Title</div>
                        <input className="input-field" style={{ margin: 0, padding: '6px' }} value={step.instructionTitle} onChange={(e) => handleStepChange(index, 'instructionTitle', e.target.value)} placeholder="e.g. Step 1: Soap" required />
                      </div>
                      <div>
                        <div style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Detail</div>
                        <input className="input-field" style={{ margin: 0, padding: '6px' }} value={step.instructionDetail} onChange={(e) => handleStepChange(index, 'instructionDetail', e.target.value)} placeholder="Pour soap into beaker" required />
                      </div>
                      <div style={{ paddingTop: '18px' }}>
                        <button type="button" onClick={() => handleStepRemove(index)} className="btn btn-secondary" style={{ padding: '8px', height: '34px' }}>
                          <X size={16} />
                        </button>
                      </div>
                    </div>
                  ))}
                  {(!editingExp.steps || editingExp.steps.length === 0) && (
                    <div style={{ padding: '16px', textAlign: 'center', color: 'var(--text-secondary)', fontSize: '0.9rem', fontStyle: 'italic', border: '1px dashed var(--border-light)', borderRadius: '8px' }}>
                      No steps added yet. Add steps to make this experiment interactive in AR.
                    </div>
                  )}
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px', borderTop: '1px solid var(--border-light)', paddingTop: '24px' }}>
                <button type="button" className="btn btn-secondary" onClick={() => setEditingExp(null)}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  <Save size={18} /> Save Changes
                </button>
              </div>

            </form>
          </div>
        </div>
      )}
    </div>
  );
}
