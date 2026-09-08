-- Costia starter taxonomy + retailer seed

INSERT INTO wellness_goals (code, slug, name, description, icon, sort_order) VALUES
('HG01','sleep-relaxation','Sleep & Relaxation','Sleep quality, relaxation and evening support','😴',1),
('HG02','energy-vitality','Energy & Vitality','Energy metabolism, nutrient intake and everyday vitality','⚡',2),
('HG03','brain-cognitive','Brain & Cognitive','Memory, focus and cognitive wellness','🧠',3),
('HG04','heart-cardiovascular','Heart & Cardiovascular','Cardiovascular and circulatory nutritional support','❤️',4),
('HG05','immune-support','Immune Support','Nutritional support for normal immune function','🛡️',5),
('HG06','digestive-gut-health','Digestive & Gut Health','Digestion, gut health, fiber and regularity','🥗',6),
('HG07','bones-minerals','Bones & Minerals','Bone and mineral nutrition','🦴',7),
('HG08','joints-mobility','Joints & Mobility','Joint, connective-tissue and mobility support','🦵',8),
('HG09','muscle-recovery','Muscle & Recovery','Muscle nutrition, exercise and recovery','💪',9),
('HG10','skin-hair-nails','Skin, Hair & Nails','Nutritional support for skin, hair and nails','✨',10),
('HG11','womens-health','Women''s Health','Women''s nutritional and life-stage support','👩',11),
('HG12','mens-health','Men''s Health','Men''s nutritional support','👨',12),
('HG13','healthy-aging','Healthy Aging','General nutritional support associated with healthy aging','🌱',13),
('HG14','stress-mood','Stress & Mood','Everyday stress management and emotional-wellness support','🧘',14),
('HG15','weight-metabolic-health','Weight & Metabolic Health','Nutrition, satiety and healthy weight-management support','⚖️',15)
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), sort_order=VALUES(sort_order), is_active=1;

INSERT INTO supplement_categories (slug,name,description,sort_order) VALUES
('multivitamins','Multivitamins','Daily and life-stage multivitamin products',1),
('individual-vitamins','Individual Vitamins','Single-vitamin and vitamin-complex products',2),
('minerals','Minerals','Magnesium, calcium, zinc, iron and other mineral products',3),
('sleep-relaxation','Sleep & Relaxation','Products positioned around sleep and relaxation',4),
('stress-mood','Stress & Mood','Products positioned around stress and mood support',5),
('energy','Energy','Products positioned around energy and vitality',6),
('brain-memory','Brain & Memory','Products positioned around memory and cognitive wellness',7),
('heart-health','Heart Health','Omega-3, CoQ10 and other heart-positioned products',8),
('digestive-gut','Digestive & Gut Health','Probiotics, prebiotics, fiber and digestive support',9),
('joint-mobility','Joint & Mobility','Joint, connective-tissue and mobility products',10),
('sports-recovery','Sports, Muscle & Recovery','Creatine, protein, electrolytes and recovery products',11),
('hair-skin-nails','Hair, Skin & Nails','Collagen, biotin and beauty-positioned supplements',12),
('immune','Immune Support','Vitamin C, D, zinc, elderberry and immune blends',13),
('healthy-aging','Healthy Aging','Products positioned around healthy aging',14),
('womens-wellness','Women''s Wellness','Prenatal, menopause, iron and women''s specialty formulas',15),
('mens-wellness','Men''s Wellness','Men''s multivitamins and specialty formulations',16),
('weight-metabolic','Weight & Metabolic','Fiber, protein, satiety and metabolic-positioned products',17),
('greens-herbals','Greens, Superfoods & Herbals','Greens powders, mushrooms, herbs and adaptogens',18)
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), sort_order=VALUES(sort_order), is_active=1;

INSERT INTO product_formats (slug,name) VALUES
('capsule','Capsule'),('tablet','Tablet'),('softgel','Softgel'),('gummy','Gummy'),('powder','Powder'),('liquid','Liquid'),('drink-mix','Drink Mix'),('stick-pack','Stick Pack'),('chewable','Chewable'),('other','Other')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO retailers (slug,name,website_url) VALUES
('costco','Costco','https://www.costco.com/'),
('cvs','CVS','https://www.cvs.com/'),
('walgreens','Walgreens','https://www.walgreens.com/')
ON DUPLICATE KEY UPDATE name=VALUES(name), website_url=VALUES(website_url), is_active=1;

INSERT INTO ingredients (slug,name,ingredient_type,description) VALUES
('magnesium','Magnesium','mineral','Essential mineral involved in numerous normal physiological processes.'),
('melatonin','Melatonin','other','Hormone-related ingredient commonly used in sleep products.'),
('l-theanine','L-Theanine','amino_acid','Amino acid found in tea and used in relaxation-oriented products.'),
('glycine','Glycine','amino_acid','Amino acid used in nutrition and sleep-oriented formulations.'),
('gaba','GABA','amino_acid','Neurotransmitter-related ingredient used in some relaxation products.'),
('valerian','Valerian','herbal','Herbal ingredient commonly used in sleep products.'),
('chamomile','Chamomile','herbal','Herbal ingredient commonly used in calming and evening products.'),
('lemon-balm','Lemon Balm','herbal','Herbal ingredient used in relaxation-oriented products.'),
('ashwagandha','Ashwagandha','herbal','Adaptogenic herb used in stress and wellness products.'),
('vitamin-b12','Vitamin B12','vitamin','Vitamin involved in normal red blood cell formation and energy metabolism.'),
('iron','Iron','mineral','Essential mineral involved in oxygen transport and normal energy metabolism.'),
('coq10','CoQ10','other','Coenzyme used in cellular energy-related processes.'),
('creatine','Creatine','amino_acid','Compound used in muscle and exercise nutrition.'),
('electrolytes','Electrolytes','mineral','Group including sodium, potassium and other minerals used in hydration products.'),
('vitamin-c','Vitamin C','vitamin','Vitamin involved in antioxidant protection and collagen formation.'),
('vitamin-d','Vitamin D','vitamin','Vitamin involved in calcium absorption, bone and immune function.'),
('omega-3','Omega-3','fatty_acid','Family of polyunsaturated fatty acids including EPA and DHA.'),
('dha','DHA','fatty_acid','Omega-3 fatty acid commonly found in fish oil and brain-focused products.'),
('epa','EPA','fatty_acid','Omega-3 fatty acid commonly found in fish oil.'),
('calcium','Calcium','mineral','Essential mineral important for normal bone structure and function.'),
('zinc','Zinc','mineral','Essential mineral involved in numerous physiological processes including immune function.'),
('glucosamine','Glucosamine','other','Ingredient commonly used in joint-support products.'),
('chondroitin','Chondroitin','other','Ingredient commonly used in joint-support products.'),
('msm','MSM','other','Sulfur-containing compound commonly used in joint-support formulas.'),
('turmeric-curcumin','Turmeric / Curcumin','herbal','Turmeric-derived ingredient used in wellness and joint-oriented formulations.'),
('collagen','Collagen','protein','Protein ingredient used in beauty, joint and recovery products.'),
('biotin','Biotin','vitamin','B vitamin commonly used in hair, skin and nail formulations.'),
('probiotics','Probiotics','microorganism','Beneficial microorganisms used in digestive-health products.'),
('prebiotics','Prebiotics','fiber','Ingredients used to support beneficial gut bacteria.'),
('fiber','Fiber','fiber','Dietary fiber used in digestive, satiety and regularity products.')
ON DUPLICATE KEY UPDATE name=VALUES(name), ingredient_type=VALUES(ingredient_type), description=VALUES(description), is_active=1;
