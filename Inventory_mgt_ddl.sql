CREATE DATABASE inventory_system;
USE inventory_system;
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    shipping_address VARCHAR(255)
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) CHECK (price >= 0)
);


CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT CHECK (quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    order_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);


CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT CHECK (quantity > 0),
    price DECIMAL(10,2) CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


INSERT INTO Customers (full_name, email, phone, shipping_address) VALUES
('Ama Serwaa', 'ama.serwaa@example.com', '0241234567', 'East Legon, Accra'),
('Kwame Mensah', 'kwame.mensah@example.com', '0209876543', 'Adenta Housing, Accra'),
('Fatima Ibrahim', 'fatima.ibrahim@example.com', '0548882211', 'Tamale Central, Northern Region'),
('Yaw Kofi', 'yaw.kofi@example.com', '0275566988', 'Kasoa CP, Central Region'),
('Mariam Sule', 'mariam.sule@example.com', '0501122448', 'Nima 441, Accra'),
('Abdul Rahman', 'abdul.rahman@example.com', '0249988776', 'Aboabo, Kumasi'),
('Nana Adwoa', 'nana.adwoa@example.com', '0553344556', 'Tema Community 7'),
('Selorm Fiagbe', 'selorm.fiagbe@example.com', '0202233445', 'Ho Municipal, Volta Region'),
('Rahim Osman', 'rahim.osman@example.com', '0246677885', 'Wa Central, Upper West'),
('Naa Dedei', 'naa.dedei@example.com', '0265544332', 'Labadi, Accra'),
('Joseph Annor', 'joseph.annor@example.com', '0549090807', 'Koforidua Effiduase'),
('Ramatu Yakubu', 'ramatu.yakubu@example.com', '0554433221', 'Bolgatanga Estates'),
('Kwaku Owusu', 'kwaku.owusu@example.com', '0276109203', 'Santasi, Kumasi'),
('Zainab Alhassan', 'zainab.alhassan@example.com', '0248001234', 'Madina Zongo, Accra'),
('Ibrahim Tanko', 'ibrahim.tanko@example.com', '0205657788', 'Sagnarigu, Tamale'),
('Patience Adjei', 'patience.adjei@example.com', '0507766554', 'Kwashieman, Accra'),
('Hafiz Musah', 'hafiz.musah@example.com', '0248899001', 'Asawase, Kumasi'),
('Emelia Korkor', 'emelia.korkor@example.com', '0543001122', 'Cape Coast, Abura'),
('Amina Mukhtar', 'amina.mukhtar@example.com', '0559900887', 'New Town, Accra'),
('Elorm Agbeko', 'elorm.agbeko@example.com', '0208112233', 'Ashaiman Lebanon Zone 2');






INSERT INTO Products (product_name, category, price) VALUES
('Laptop', 'Electronics', 4500.00),
('Smartphone', 'Electronics', 3200.00),
('Headphones', 'Electronics', 150.00),
('Bluetooth Speaker', 'Electronics', 180.00),
('Smartwatch', 'Electronics', 300.00),

('T-Shirt', 'Apparel', 50.00),
('Jeans', 'Apparel', 80.00),
('Sneakers', 'Apparel', 120.00),
('Hoodie', 'Apparel', 95.00),
('Dress', 'Apparel', 130.00),

('Novel Book', 'Books', 30.00),
('Notebook', 'Books', 15.00),
('Textbook', 'Books', 180.00),
('Magazine', 'Books', 25.00),
('Storybook', 'Books', 20.00),

('Backpack', 'Accessories', 70.00),
('Wristwatch', 'Accessories', 250.00),
('Wallet', 'Accessories', 45.00),
('Sunglasses', 'Accessories', 90.00),
('Handbag', 'Accessories', 180.00);


INSERT INTO Inventory (product_id, quantity) VALUES
(1, 50),
(2, 100),
(3, 70),
(4, 40),
(5, 30),
(6, 60),
(7, 35),
(8, 90),
(9, 55),
(10, 25),
(11, 80),
(12, 120),
(13, 20),
(14, 150),
(15, 200),
(16, 45),
(17, 25),
(18, 110),
(19, 75),
(20, 65);


INSERT INTO Orders (customer_id, order_date, total_amount, order_status) VALUES
(1, '2025-12-01', 500.00, 'Delivered'),
(2, '2025-12-02', 150.00, 'Shipped'),
(3, '2025-11-03', 300.00, 'Pending'),
(4, '2025-11-05', 1200.00, 'Delivered'),
(5, '2025-10-06', 450.00, 'Processing'),
(6, '2025-01-10', 900.00, 'Delivered'),
(1, '2025-11-12', 75.00, 'Cancelled'),
(8, '2025-10-13', 250.00, 'Shipped'),
(9, '2025-11-14', 600.00, 'Pending'),
(10, '2025-11-15', 320.00, 'Delivered'),
(1, '2025-11-18', 1100.00, 'Delivered'),
(6, '2025-11-20', 80.00, 'Processing'),
(13, '2025-11-21', 260.00, 'Pending'),
(14, '2025-10-22', 140.00, 'Delivered'),
(5, '2025-11-25', 500.00, 'Shipped'),
(6, '2025-11-27', 200.00, 'Delivered'),
(17, '2025-11-29', 950.00, 'Processing'),
(18, '2025-11-30', 350.00, 'Pending'),
(19, '2025-12-01', 700.00, 'Delivered'),
(2, '2025-09-02', 180.00, 'Shipped'),
(1, '2025-09-25', 500.00, 'Shipped'),
(6, '2025-11-27', 200.00, 'Delivered'),
(7, '2025-11-29', 950.00, 'Processing'),
(1, '2025-09-30', 350.00, 'Delivered'),
(9, '2025-09-01', 700.00, 'Delivered'),
(20, '2025-12-02', 180.00, 'Shipped');


INSERT INTO OrderItems (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 4500.00),
(1, 4, 1, 180.00),
(2, 3, 1, 150.00),
(3, 7, 1, 80.00),
(3, 4, 3, 15.00),
(4, 2, 1, 3200.00),
(5, 6, 1, 60.00),
(5, 9, 1, 55.00),
(6, 8, 2, 90.00),
(6, 1, 1, 45.00),
(7, 1, 2, 25.00),
(8, 10, 1, 25.00),
(8, 1, 1, 250.00),
(9, 5, 2, 30.00),
(10, 11, 1, 80.00),
(11, 1, 1, 4500.00),
(11, 2, 1, 180.00),
(12, 8, 1, 110.00),
(13, 3, 1, 150.00),
(13, 7, 2, 80.00),
(14, 9, 1, 55.00),
(14, 15, 2, 20.00),
(15, 6, 1, 60.00),
(16, 13, 1, 180.00),
(16, 12, 2, 15.00),
(17, 1, 1, 45.00),
(17, 4, 1, 180.00),
(18, 8, 1, 90.00),
(19, 2, 1, 3200.00),
(1, 11, 1, 80.00),
(20, 5, 2, 30.00);






