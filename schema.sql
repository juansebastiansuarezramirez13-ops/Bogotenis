-- =========================================================
-- BASE DE DATOS: tienda_bogotenis
-- Ejecutar este script completo en phpMyAdmin (pestaña SQL)
-- con Apache y MySQL de XAMPP encendidos.
-- 60 PRODUCTOS - 5 CATEGORIAS
-- =========================================================

DROP DATABASE IF EXISTS tienda_bogotenis;

CREATE DATABASE tienda_bogotenis
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tienda_bogotenis;

-- ---------------------------------------------------------
-- 1. USUARIOS
-- ---------------------------------------------------------
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol ENUM('admin', 'cliente') NOT NULL DEFAULT 'cliente',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo'
);

-- ---------------------------------------------------------
-- NEWSLETTER
-- ---------------------------------------------------------
CREATE TABLE suscriptores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    correo VARCHAR(150) NOT NULL UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- 2. CATEGORIAS
-- ---------------------------------------------------------
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- 3. PRODUCTOS
-- ---------------------------------------------------------
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    marca VARCHAR(60) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    stock INT NOT NULL DEFAULT 20 CHECK (stock >= 0),
    categoria_id INT NOT NULL,
    en_oferta TINYINT(1) NOT NULL DEFAULT 0,
    estado ENUM('disponible', 'agotado', 'oculto') NOT NULL DEFAULT 'disponible',
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (categoria_id)
        REFERENCES categorias(id) ON UPDATE CASCADE
);

-- ---------------------------------------------------------
-- 4. VARIANTES DE COLOR
-- ---------------------------------------------------------
CREATE TABLE variantes_producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    color_nombre VARCHAR(60) NOT NULL,
    color_code VARCHAR(20) NOT NULL,
    imagen VARCHAR(255) NOT NULL,
    orden INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_variante_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- 5. TALLAS
-- ---------------------------------------------------------
CREATE TABLE tallas_producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    talla VARCHAR(10) NOT NULL,
    CONSTRAINT fk_talla_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- 6. PEDIDOS
-- ---------------------------------------------------------
CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    estado ENUM('pendiente', 'confirmado', 'enviado', 'entregado', 'cancelado') NOT NULL DEFAULT 'pendiente',
    direccion_entrega VARCHAR(255),
    metodo_pago VARCHAR(50),
    CONSTRAINT fk_pedido_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
);

-- ---------------------------------------------------------
-- 7. DETALLE DE PEDIDO
-- ---------------------------------------------------------
CREATE TABLE detalle_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    talla VARCHAR(10),
    color_nombre VARCHAR(60),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (pedido_id)
        REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (producto_id)
        REFERENCES productos(id)
);

-- =========================================================
-- DATOS INICIALES
-- =========================================================

-- Ejecuta "python crear_admin.py" para crear admin@bogotenis.com / admin123

-- Categorias
INSERT INTO categorias (id, nombre) VALUES
(1, 'Casuales'),
(2, 'Modernos'),
(3, 'Clasicos'),
(4, 'Deportivos'),
(5, 'Elegantes');

-- =========================================================
-- 60 PRODUCTOS
-- =========================================================

INSERT INTO productos (id, marca, nombre, precio, stock, categoria_id, en_oferta) VALUES
-- === CASUALES (1-12) ===
(1,  'Nike',        'Air Force One Shadow',      283000, 25, 1, 1),
(2,  'Adidas',      'Samba OG Classic',          112000, 30, 1, 0),
(3,  'Adidas',      'Campus 00s Retro',          111000, 22, 1, 1),
(4,  'Puma',        'Cali Dream White',          256000, 18, 1, 0),
(5,  'Reebok',      'Club C 85 Vintage',         234000, 20, 1, 0),
(6,  'Nike',        'Dunk Low Retro',            320000, 15, 1, 1),
(7,  'Adidas',      'Forum Low 84',              289000, 17, 1, 0),
(8,  'Converse',    'One Star Pro',              195000, 24, 1, 0),
(9,  'Vans',        'ComfyCush Old Skool',       215000, 28, 1, 1),
(10, 'New Balance', '550 White',                 340000, 12, 1, 0),
(11, 'Asics',       'Gel-Lyte III',              275000, 16, 1, 0),
(12, 'Puma',        'Suede Classic XXI',         178000, 22, 1, 1),

-- === MODERNOS (13-24) ===
(13, 'Nike',        'Air Max Plus TN',           267000, 20, 2, 1),
(14, 'New Balance', 'NB 9060 Chunky',            190000, 18, 2, 0),
(15, 'Balenciaga',  'Triple S Neo',              160000, 10, 2, 1),
(16, 'Nike',        'Air Max 270 React',         389000, 15, 2, 0),
(17, 'Adidas',      'Yeezy Boost 350 V2',       450000,  8, 2, 0),
(18, 'Puma',        'RS-X Reinvention',          299000, 14, 2, 1),
(19, 'New Balance', '327 Sea Salt',              310000, 16, 2, 0),
(20, 'Nike',        'Air Jordan 1 Low',          370000, 12, 2, 0),
(21, 'Adidas',      'NMD R1 V3',                 345000, 13, 2, 1),
(22, 'Asics',       'Gel-NYC Cream',             298000, 11, 2, 0),
(23, 'Converse',    'Run Star Hike',             245000, 19, 2, 0),
(24, 'Vans',        'Sk8-Hi Reissue',            225000, 21, 2, 1),

-- === CLASICOS (25-36) ===
(25, 'Converse',    'Chuck Taylor 70s AllStar',  275000, 30, 3, 1),
(26, 'Nike',        'Blazer Mid 77',             295000, 22, 3, 0),
(27, 'Adidas',      'Stan Smith',                260000, 28, 3, 0),
(28, 'Reebok',      'Classic Leather Legacy',    245000, 20, 3, 1),
(29, 'Puma',        'Mention Suede',             185000, 25, 3, 0),
(30, 'New Balance', '574 Classic',               349000, 18, 3, 1),
(31, 'Vans',        'Old Skool Classic',         199000, 32, 3, 0),
(32, 'Converse',    'Jack Purcell Ox',           210000, 16, 3, 0),
(33, 'Nike',        'Air Force 1 07',            310000, 24, 3, 0),
(34, 'Adidas',      'Superstar',                 285000, 26, 3, 1),
(35, 'Fila',        'Disruptor II',              269000, 19, 3, 0),
(36, 'New Balance', '2002R Protection Pack',     380000, 10, 3, 0),

-- === DEPORTIVOS (37-48) ===
(37, 'Nike',        'Air Zoom Pegasus 40',       349000, 22, 4, 0),
(38, 'Adidas',      'Ultraboost Light Sport',    237000, 18, 4, 1),
(39, 'Nike',        'Downshifter 12',            259000, 25, 4, 0),
(40, 'Under Armour','Charged Assert 9',          319000, 15, 4, 1),
(41, 'New Balance', 'Fresh Foam X 880v13',       420000, 12, 4, 0),
(42, 'Asics',       'Gel-Kayano 30',             480000, 10, 4, 0),
(43, 'Puma',        'Velocity Nitro 2',          335000, 16, 4, 1),
(44, 'Salomon',     'Speedcross 6',              489000,  8, 4, 0),
(45, 'Adidas',      'Adizero Adios Pro 3',       520000,  6, 4, 0),
(46, 'Nike',        'React Infinity Run 3',      395000, 14, 4, 1),
(47, 'Brooks',      'Ghost 15',                  370000, 11, 4, 0),
(48, 'Hoka',        'Clifton 9',                 445000,  9, 4, 0),

-- === ELEGANTES (49-60) ===
(49, 'Lacoste',     'Europa Leather Elegance',   230000, 14, 5, 0),
(50, 'Prada',       'Stiletto Luxury Heel',      100000,  8, 5, 1),
(51, 'Timberland',  '6-Inch Premium Boot',       420000, 12, 5, 0),
(52, 'Clarks',      'Desert Boot 2',             310000, 16, 5, 0),
(53, 'Cole Haan',   'Grand Crosscourt II',       275000, 18, 5, 1),
(54, 'Johnston & Murphy','Melton Oxford',        380000, 10, 5, 0),
(55, 'Ecco',        'Soft 7 Sneaker',            350000, 14, 5, 0),
(56, 'Camper',      'Pelotas XL',                290000, 12, 5, 1),
(57, 'Geox',        'Uomo Xand',                 265000, 20, 5, 0),
(58, 'Florsheim',   'Cap Toe Oxford',            340000,  9, 5, 0),
(59, 'Skechers',    'Dress Flex' ,               195000, 22, 5, 1),
(60, 'Tommy Hilfiger','Dress Casual Lace',        285000, 17, 5, 0);

-- =========================================================
-- VARIANTES DE COLOR (1-2 por producto)
-- =========================================================

INSERT INTO variantes_producto (producto_id, color_nombre, color_code, imagen, orden) VALUES
-- Casuales (cada producto su imagen: producto{N}-1.png, segundo color producto{N}-2.png)
(1,  'Pastel Multi',    '#ffedd5', 'producto1-1.png',  0),
(2,  'Blanco Nucleo',   '#e2e8f0', 'producto2-1.png',  0),
(3,  'Verde Pino',      '#047857', 'producto3-1.png',  0),
(4,  'Blanco Puro',     '#ffffff', 'producto4-1.png',  0),
(5,  'Tiza Clasico',    '#f5f5dc', 'producto5-1.png',  0),
(5,  'Negro Retro',     '#1a1a1a', 'producto5-2.png',  1),
(6,  'Negro/Blanco',    '#111827', 'producto6-1.png',  0),
(7,  'Blanco Verde',    '#dcfce7', 'producto7-1.png',  0),
(8,  'Negro Classico',  '#111827', 'producto8-1.png',  0),
(9,  'Negro/Rojo',      '#2c3e50', 'producto9-1.png',  0),
(10, 'Blanco',          '#ffffff', 'producto10-1.png', 0),
(11, 'Gris Azul',       '#94a3b8', 'producto11-1.png', 0),
(12, 'Negro Clasico',   '#1a1a1a', 'producto12-1.png', 0),

-- Modernos
(13, 'Lava Naranja',    '#ea580c', 'producto13-1.png', 0),
(13, 'Azul Cyan',       '#06b6d4', 'producto13-2.png', 1),
(14, 'Gris Concreto',   '#cbd5e1', 'producto14-1.png', 0),
(15, 'Negro Neon',      '#a3e635', 'producto15-1.png', 0),
(16, 'Negro React',     '#1a1a1a', 'producto16-1.png', 0),
(16, 'Blanco React',    '#f5f5f5', 'producto16-2.png', 1),
(17, 'Onyx',            '#111827', 'producto17-1.png', 0),
(18, 'Multi Rojo',      '#e74c3c', 'producto18-1.png', 0),
(19, 'Sea Salt',        '#d4c5a9', 'producto19-1.png', 0),
(20, 'Negro Rojo',      '#b91c1c', 'producto20-1.png', 0),
(20, 'Blanco Rojo',     '#dc2626', 'producto20-2.png', 1),
(21, 'Core Negro',      '#0f172a', 'producto21-1.png', 0),
(22, 'Cream',           '#fef3c7', 'producto22-1.png', 0),
(23, 'Negro Blanco',    '#1a1a1a', 'producto23-1.png', 0),
(24, 'Negro/Blanco',    '#2c3e50', 'producto24-1.png', 0),

-- Clasicos
(25, 'Negro Atemporal', '#111827', 'producto25-1.png', 0),
(25, 'Blanco Puro',     '#ffffff', 'producto25-2.png', 1),
(26, 'Negro/Gris',      '#1a1a1a', 'producto26-1.png', 0),
(27, 'Verde Blanco',    '#047857', 'producto27-1.png', 0),
(28, 'Blanco Lt Blue',  '#dbeafe', 'producto28-1.png', 0),
(29, 'Negro Clasico',   '#1a1a1a', 'producto29-1.png', 0),
(30, 'Gris Vintage',    '#7f8c8d', 'producto30-1.png', 0),
(30, 'Verde Foresta',   '#27ae60', 'producto30-2.png', 1),
(31, 'Negro',           '#1a1a1a', 'producto31-1.png', 0),
(32, 'Blanco Negro',    '#ffffff', 'producto32-1.png', 0),
(33, 'Blanco Blanco',   '#ffffff', 'producto33-1.png', 0),
(34, 'Negro Blanco',    '#111827', 'producto34-1.png', 0),
(35, 'Blanco',          '#f5f5f5', 'producto35-1.png', 0),
(36, 'Gris Reflexion',  '#94a3b8', 'producto36-1.png', 0),

-- Deportivos
(37, 'Negro/Blanco',    '#0f172a', 'producto37-1.png', 0),
(38, 'Blanco Nieve',    '#ffffff', 'producto38-1.png', 0),
(38, 'Negro Deportivo', '#0f172a', 'producto38-2.png', 1),
(39, 'Azul Oscuro',     '#1e3a5f', 'producto39-1.png', 0),
(40, 'Negro',           '#111827', 'producto40-1.png', 0),
(41, 'Azul Marino',     '#1e3a5f', 'producto41-1.png', 0),
(42, 'Blanco Glow',     '#ffffff', 'producto42-1.png', 0),
(43, 'Negro Volt',      '#a3e635', 'producto43-1.png', 0),
(44, 'Negro/Verde',     '#27ae60', 'producto44-1.png', 0),
(45, 'Negro Rosado',    '#ec4899', 'producto45-1.png', 0),
(46, 'Negro Rojo',      '#b91c1c', 'producto46-1.png', 0),
(47, 'Negro Azul',      '#2563eb', 'producto47-1.png', 0),
(48, 'Azul/Verde',      '#06b6d4', 'producto48-1.png', 0),

-- Elegantes
(49, 'Mocasin Marron',  '#78350f', 'producto49-1.png', 0),
(50, 'Rojo Pasion',     '#dc2626', 'producto50-1.png', 0),
(51, 'Mostaza Clasico', '#d97706', 'producto51-1.png', 0),
(52, 'Miel Beige',      '#d4a574', 'producto52-1.png', 0),
(53, 'Blanco Gris',     '#e2e8f0', 'producto53-1.png', 0),
(54, 'Negro Polished',  '#111827', 'producto54-1.png', 0),
(55, 'Blanco Nero',     '#ffffff', 'producto55-1.png', 0),
(56, 'Negro Napa',      '#1a1a1a', 'producto56-1.png', 0),
(57, 'Negro',           '#111827', 'producto57-1.png', 0),
(58, 'Cognac',          '#8b4513', 'producto58-1.png', 0),
(59, 'Negro Flex',      '#1a1a1a', 'producto59-1.png', 0),
(60, 'Azul Marino',     '#1e3a5f', 'producto60-1.png', 0);

-- =========================================================
-- TALLAS POR PRODUCTO
-- =========================================================

INSERT INTO tallas_producto (producto_id, talla) VALUES
-- Casuales (1-12)
(1,'36'),(1,'37'),(1,'38'),(1,'39'),(1,'40'),
(2,'37'),(2,'38'),(2,'39'),(2,'40'),(2,'41'),(2,'42'),
(3,'36'),(3,'37'),(3,'38'),(3,'39'),(3,'40'),
(4,'36'),(4,'37'),(4,'38'),(4,'39'),
(5,'37'),(5,'38'),(5,'39'),(5,'40'),(5,'41'),
(6,'38'),(6,'39'),(6,'40'),(6,'41'),(6,'42'),(6,'43'),
(7,'37'),(7,'38'),(7,'39'),(7,'40'),(7,'41'),
(8,'36'),(8,'37'),(8,'38'),(8,'39'),(8,'40'),
(9,'37'),(9,'38'),(9,'39'),(9,'40'),(9,'41'),(9,'42'),
(10,'38'),(10,'39'),(10,'40'),(10,'41'),(10,'42'),
(11,'37'),(11,'38'),(11,'39'),(11,'40'),(11,'41'),
(12,'36'),(12,'37'),(12,'38'),(12,'39'),

-- Modernos (13-24)
(13,'38'),(13,'39'),(13,'40'),(13,'41'),(13,'42'),(13,'43'),
(14,'37'),(14,'38'),(14,'39'),(14,'40'),(14,'41'),(14,'42'),
(15,'38'),(15,'39'),(15,'40'),(15,'41'),(15,'42'),
(16,'38'),(16,'39'),(16,'40'),(16,'41'),(16,'42'),(16,'43'),
(17,'38'),(17,'39'),(17,'40'),(17,'41'),(17,'42'),
(18,'39'),(18,'40'),(18,'41'),(18,'42'),(18,'43'),
(19,'37'),(19,'38'),(19,'39'),(19,'40'),(19,'41'),
(20,'38'),(20,'39'),(20,'40'),(20,'41'),(20,'42'),(20,'43'),
(21,'38'),(21,'39'),(21,'40'),(21,'41'),(21,'42'),
(22,'38'),(22,'39'),(22,'40'),(22,'41'),(22,'42'),
(23,'37'),(23,'38'),(23,'39'),(23,'40'),(23,'41'),
(24,'36'),(24,'37'),(24,'38'),(24,'39'),(24,'40'),(24,'41'),

-- Clasicos (25-36)
(25,'35'),(25,'36'),(25,'37'),(25,'38'),(25,'39'),(25,'40'),
(26,'36'),(26,'37'),(26,'38'),(26,'39'),(26,'40'),(26,'41'),
(27,'36'),(27,'37'),(27,'38'),(27,'39'),(27,'40'),(27,'41'),(27,'42'),
(28,'37'),(28,'38'),(28,'39'),(28,'40'),(28,'41'),
(29,'36'),(29,'37'),(29,'38'),(29,'39'),
(30,'38'),(30,'39'),(30,'40'),(30,'41'),(30,'42'),(30,'43'),(30,'44'),
(31,'37'),(31,'38'),(31,'39'),(31,'40'),(31,'41'),(31,'42'),(31,'43'),
(32,'36'),(32,'37'),(32,'38'),(32,'39'),(32,'40'),
(33,'38'),(33,'39'),(33,'40'),(33,'41'),(33,'42'),(33,'43'),(33,'44'),
(34,'36'),(34,'37'),(34,'38'),(34,'39'),(34,'40'),(34,'41'),
(35,'37'),(35,'38'),(35,'39'),(35,'40'),(35,'41'),(35,'42'),
(36,'38'),(36,'39'),(36,'40'),(36,'41'),(36,'42'),

-- Deportivos (37-48)
(37,'38'),(37,'39'),(37,'40'),(37,'41'),(37,'42'),(37,'43'),(37,'44'),
(38,'38'),(38,'39'),(38,'40'),(38,'41'),(38,'42'),(38,'43'),
(39,'38'),(39,'39'),(39,'40'),(39,'41'),(39,'42'),(39,'43'),(39,'44'),
(40,'39'),(40,'40'),(40,'41'),(40,'42'),(40,'43'),(40,'44'),
(41,'38'),(41,'39'),(41,'40'),(41,'41'),(41,'42'),(41,'43'),
(42,'38'),(42,'39'),(42,'40'),(42,'41'),(42,'42'),(42,'43'),
(43,'39'),(43,'40'),(43,'41'),(43,'42'),(43,'43'),
(44,'39'),(44,'40'),(44,'41'),(44,'42'),(44,'43'),(44,'44'),
(45,'40'),(45,'41'),(45,'42'),(45,'43'),(45,'44'),
(46,'38'),(46,'39'),(46,'40'),(46,'41'),(46,'42'),(46,'43'),
(47,'38'),(47,'39'),(47,'40'),(47,'41'),(47,'42'),(47,'43'),
(48,'38'),(48,'39'),(48,'40'),(48,'41'),(48,'42'),(48,'43'),

-- Elegantes (49-60)
(49,'38'),(49,'39'),(49,'40'),(49,'41'),(49,'42'),
(50,'36'),(50,'37'),(50,'38'),(50,'39'),
(51,'39'),(51,'40'),(51,'41'),(51,'42'),(51,'43'),
(52,'38'),(52,'39'),(52,'40'),(52,'41'),(52,'42'),
(53,'38'),(53,'39'),(53,'40'),(53,'41'),(53,'42'),
(54,'39'),(54,'40'),(54,'41'),(54,'42'),(54,'43'),
(55,'38'),(55,'39'),(55,'40'),(55,'41'),(55,'42'),
(56,'37'),(56,'38'),(56,'39'),(56,'40'),(56,'41'),
(57,'38'),(57,'39'),(57,'40'),(57,'41'),(57,'42'),
(58,'39'),(58,'40'),(58,'41'),(58,'42'),(58,'43'),
(59,'38'),(59,'39'),(59,'40'),(59,'41'),(59,'42'),
(60,'38'),(60,'39'),(60,'40'),(60,'41'),(60,'42');
