create database CineABP2
use CineABP2;

CREATE TABLE Membresias (
    id_membresia INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    id_membresia INT NOT NULL,
    CONSTRAINT fk_Usuarios_Membresias 
        FOREIGN KEY (id_membresia) REFERENCES Membresias(id_membresia)
);
CREATE TABLE Tipos_Comidas (
    id_tipo_comida INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE Comidas (
    id_comida INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL CHECK (stock >= 0),
    id_tipo_comida INT NOT NULL,
    CONSTRAINT fk_tipo_comida 
        FOREIGN KEY (id_tipo_comida) REFERENCES Tipos_Comidas(id_tipo_comida)
);

CREATE TABLE Salas (
    id_sala INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    capacidad INT NOT NULL CHECK (capacidad > 0)
);
CREATE TABLE Peliculas (
    id_pelicula INT IDENTITY(1,1) PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL UNIQUE,
    duracion INT NOT NULL CHECK (duracion > 0)
);

CREATE TABLE Metodos_Pago (
    id_metodo_pago INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Funciones (
    id_funcion INT IDENTITY(1,1) PRIMARY KEY,
    id_pelicula INT,
    id_sala INT,
    fecha DATE,
    hora TIME,
    precio_base DECIMAL(10,2),
    FOREIGN KEY (id_pelicula) REFERENCES Peliculas(id_pelicula),
    FOREIGN KEY (id_sala) REFERENCES Salas(id_sala)
);

CREATE TABLE Tickets (
    id_ticket INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT,
    id_funcion INT,
    fecha_compra DATE,
    asiento VARCHAR(10),
    precio_final DECIMAL(10,2),
    id_metodo_pago INT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_funcion) REFERENCES Funciones(id_funcion),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodos_Pago(id_metodo_pago)
);

CREATE TABLE Ventas_Comidas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT, 
    fecha DATE,
    precio DECIMAL(10,2),
    id_metodo_pago INT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodos_Pago(id_metodo_pago)
);

CREATE TABLE Detalle_Venta_Comidas (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT,
    id_comida INT,
    cantidad INT CHECK (cantidad > 0),
    FOREIGN KEY (id_venta) REFERENCES Ventas_Comidas(id_venta),
    FOREIGN KEY (id_comida) REFERENCES Comidas(id_comida)
);
INSERT INTO Membresias (nombre)
VALUES ('Gold'), ('Premium'), ('Común'), ('Plata'), ('Black');

INSERT INTO Usuarios (nombre, apellido, email, telefono, id_membresia)
VALUES
('Juan', 'Gómez', 'juan@gmail.com', '351222111', 1),
('Ana', 'Martínez', 'ana@gmail.com', '351999888', 2),
('Sara', 'Pérez', 'sara@gmail.com', '351111222', 3),
('Lucas', 'Rivas', 'lucas@gmail.com', '351333444', 4),
('Mario', 'López', 'mario@gmail.com', '351555666', 5);

INSERT INTO Tipos_Comidas (nombre)
VALUES ('Bebida'), ('Snack'), ('Combo'), ('Dulces'), ('Comida Rápida');

INSERT INTO Comidas (nombre, precio, stock, id_tipo_comida)
VALUES
('Coca Cola', 1500, 100, 1),
('Fanta', 1500, 100, 1),
('Pochoclo Salado', 2500, 60, 2),
('Pochoclo Dulce', 2600, 50, 2),
('Combo Familiar', 5000, 30, 3);

INSERT INTO Salas (nombre, capacidad)
VALUES ('1A', 40), ('2A', 50), ('3A', 60), ('4A', 70), ('5A', 80);

INSERT INTO Peliculas (titulo, duracion)
VALUES
('Avengers Endgame', 148),
('Avengers Infinity War', 149),
('Metegol', 106),
('Homo Argentum', 98),
('Spiderman 2', 127);

CREATE INDEX idx_Peliculas_titulo ON Peliculas(titulo);

CREATE INDEX idx_Comidas_tipo ON Comidas(id_tipo_comida);

CREATE INDEX idx_Usuarios_membresia ON Usuarios(id_membresia);

SELECT 
    p.titulo,
    s.nombre AS sala,
    f.fecha,
    f.hora,
    f.precio_base,
    p.duracion
FROM Funciones f
JOIN Peliculas p ON f.id_pelicula = p.id_pelicula
JOIN Salas s ON f.id_sala = s.id_sala
ORDER BY f.fecha, f.hora, s.nombre;

SELECT 
    p.titulo,
    COUNT(t.id_ticket) AS entradas_vendidas
FROM Peliculas p
JOIN Funciones f ON p.id_pelicula = f.id_pelicula
LEFT JOIN Tickets t ON t.id_funcion = f.id_funcion
GROUP BY p.titulo
ORDER BY entradas_vendidas DESC;

SELECT 
    u.nombre,
    u.apellido,
    v.fecha AS fecha_venta,
    v.precio AS total,
    mp.nombre AS metodo_pago,
    SUM(d.cantidad) AS cantidad_items
FROM Ventas_Comidas v
JOIN Usuarios u ON v.id_usuario = u.id_usuario
JOIN Metodos_Pago mp ON v.id_metodo_pago = mp.id_metodo_pago
JOIN Detalle_Venta_Comidas d ON v.id_venta = d.id_venta
GROUP BY u.nombre, u.apellido, v.fecha, v.precio, mp.nombre;

SELECT 
    u.nombre,
    u.apellido,
    u.email,
    m.nombre AS tipo_membresia
FROM Usuarios u
JOIN Membresias m ON u.id_membresia = m.id_membresia
LEFT JOIN Ventas_Comidas v ON u.id_usuario = v.id_usuario
WHERE v.id_venta IS NULL;

SELECT
    (SELECT SUM(precio_final) FROM Tickets) AS total_tickets,
    (SELECT SUM(precio) FROM Ventas_Comidas) AS total_candy,
    (SELECT SUM(precio_final) FROM Tickets) +
    (SELECT SUM(precio) FROM Ventas_Comidas) AS total_general;