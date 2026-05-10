-- Seed data for Délice Distribution
-- Passwords are bcrypt hash of "12345678"

INSERT INTO users (name, email, password, role, magasin_name, phone, address, points_balance) VALUES
(
  'Admin Délice',
  'admin@delice.tn',
  '$2a$10$G0inx9Ikb.7yfG/DDw7Ys.fwEruzJ6os1uENaduGLGSYsxtbDE1ga',
  'admin',
  NULL,
  '+216 71 000 000',
  'Tunis, Tunisie',
  0
),
(
  'Magasin Ben Ali',
  'magasin1@delice.tn',
  '$2a$10$G0inx9Ikb.7yfG/DDw7Ys.fwEruzJ6os1uENaduGLGSYsxtbDE1ga',
  'magasin',
  'Épicerie Ben Ali',
  '+216 22 111 222',
  'Rue de la Liberté, Sfax',
  150
),
(
  'Magasin Trabelsi',
  'magasin2@delice.tn',
  '$2a$10$G0inx9Ikb.7yfG/DDw7Ys.fwEruzJ6os1uENaduGLGSYsxtbDE1ga',
  'magasin',
  'Superette Trabelsi',
  '+216 55 333 444',
  'Avenue Habib Bourguiba, Sousse',
  80
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, description, image, category, price, stock, is_active) VALUES
('Lait Délice 1L', 'Lait entier pasteurisé Délice 1 litre', 'lait_1l.jpg', 'Lait', 1.850, 500, TRUE),
('Lait Délice 0.5L', 'Lait entier pasteurisé Délice 500ml', 'lait_500ml.jpg', 'Lait', 0.950, 800, TRUE),
('Yaourt Nature 125g', 'Yaourt nature Délice 125g', 'yaourt_nature.jpg', 'Yaourt', 0.450, 1000, TRUE),
('Yaourt Fruits 125g', 'Yaourt aux fruits Délice 125g', 'yaourt_fruits.jpg', 'Yaourt', 0.550, 900, TRUE),
('Fromage Fondu 8P', 'Fromage fondu Délice 8 portions', 'fromage_fondu.jpg', 'Fromage', 2.200, 300, TRUE),
('Crème Fraîche 200g', 'Crème fraîche Délice 200g', 'creme_fraiche.jpg', 'Crème', 1.500, 400, TRUE),
('Beurre Délice 200g', 'Beurre doux Délice 200g', 'beurre.jpg', 'Beurre', 3.200, 250, TRUE),
('Lben 1L', 'Lait fermenté Délice 1 litre', 'lben.jpg', 'Lait', 1.200, 600, TRUE),
('Jus Orange 1L', 'Jus d''orange Délice 1 litre', 'jus_orange.jpg', 'Jus', 2.500, 350, TRUE),
('Jus Pomme 1L', 'Jus de pomme Délice 1 litre', 'jus_pomme.jpg', 'Jus', 2.500, 350, TRUE),
('Crème Dessert Chocolat', 'Crème dessert chocolat Délice 125g', 'creme_choco.jpg', 'Dessert', 0.750, 700, TRUE),
('Fromage Blanc 500g', 'Fromage blanc Délice 500g', 'fromage_blanc.jpg', 'Fromage', 2.800, 200, TRUE)
ON CONFLICT DO NOTHING;
