-- Business KPI Queries
-- 1. Total revenue from all shipped or delivered orders
SELECT 
    SUM(total_amount) AS total_revenue
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered');



-- 2. Top 10 customers based on the total amount they spent
SELECT 
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;



--   3. Best selling products based on quantity sold
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM OrderItems oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY oi.product_id
ORDER BY total_quantity_sold DESC
LIMIT 5;




-- 4.Monthly sales trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS monthly_revenue
FROM Orders
WHERE order_status IN ('Shipped', 'Delivered')
GROUP BY month
ORDER BY month;


-- Analytical Queries

-- 1.Sales Rank by Category( product in each category that has the highest revenue)

SELECT
    p.category,
    p.product_name,
    SUM(oi.quantity * oi.price) AS total_sales,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * oi.price) DESC) AS category_rank
FROM OrderItems oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY p.category, p.product_name
ORDER BY p.category, category_rank;



-- 2.Customer Order Frequency( each customer's order and the date of their previous order)

SELECT
    c.full_name,
    o.order_id,
    o.order_date,
    LAG(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date) AS previous_order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.order_status IN ('Shipped', 'Delivered')
ORDER BY c.customer_id, o.order_date;


-- Performance Optimization

-- 1.View: CustomerSalesSummary( Pre-calculates total amount spent by each customer)

CREATE OR REPLACE VIEW CustomerSalesSummary AS
SELECT 
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY c.customer_id, c.full_name;


DELIMITER //

-- Trigger: Log Inventory Changes
CREATE TRIGGER ItemUpdateTrigger
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF OLD.quantity <> NEW.quantity THEN
        INSERT INTO InventoryLogs (product_id, old_quantity, new_quantity, action_type)
        VALUES (OLD.product_id, OLD.quantity, NEW.quantity, 'UPDATE');
    END IF;
END //

-- Stored Procedure(automates creating an order with multiple items via JSON)

DROP PROCEDURE IF EXISTS ProcessNewOrder //

CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT,
    IN p_order_details JSON
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE item_count INT;
    DECLARE current_product_id INT;
    DECLARE current_quantity INT;
    DECLARE current_price DECIMAL(10,2);
    DECLARE current_stock INT;
    DECLARE total_order_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE insufficient_stock INT DEFAULT 0;
    
    -- Start Transaction
    START TRANSACTION;

    -- Calculate total amount and check stock availability first
    SET item_count = JSON_LENGTH(p_order_details);
    
    WHILE i < item_count DO
        SET current_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_details, CONCAT('$[', i, '].product_id')));
        SET current_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_order_details, CONCAT('$[', i, '].quantity')));
        
        -- Get price and stock
        SELECT price, quantity INTO current_price, current_stock
        FROM Products p
        JOIN Inventory inv ON p.product_id = inv.product_id
        WHERE p.product_id = current_product_id;
        
        IF current_stock < current_quantity THEN
            SET insufficient_stock = 1;
        END IF;
        
        SET total_order_amount = total_order_amount + (current_price * current_quantity);
        SET i = i + 1;
    END WHILE;
    
    IF insufficient_stock = 1 THEN
        ROLLBACK;
        SELECT 'Error: One or more items have insufficient stock.' AS message;
    ELSE
        -- Insert Order
        INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
        VALUES (p_customer_id, CURDATE(), total_order_amount, 'Pending');
        
        SET @last_order_id = LAST_INSERT_ID();
        
        -- Reset loop index
        SET i = 0;
        
        -- Process each item
        WHILE i < item_count DO
            SET current_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_details, CONCAT('$[', i, '].product_id')));
            SET current_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_order_details, CONCAT('$[', i, '].quantity')));
            
            -- Get price again
            SELECT price INTO current_price FROM Products WHERE product_id = current_product_id;
            
            -- Insert Order Item
            INSERT INTO OrderItems (order_id, product_id, quantity, price)
            VALUES (@last_order_id, current_product_id, current_quantity, current_price);
            
            -- Update Inventory (Trigger will handle logging)
            UPDATE Inventory
            SET quantity = quantity - current_quantity
            WHERE product_id = current_product_id;
            
            SET i = i + 1;
        END WHILE;
        
        COMMIT;
        SELECT 'Order placed successfully.' AS message, @last_order_id AS order_id;
    END IF;
END //

DELIMITER ;

/* Test Case for CustomerSalesSummary view
-- Shows how much each customer has spent
   SELECT * FROM CustomerSalesSummary;
*/

/* Test Cases for ProcessNewOrder procedure
-- 1. Place order with enough stock
    CALL ProcessNewOrder('1', '[{"product_id": 1, "quantity": 5}]');

-- 2. Place order with quantity exceeding stock (should show error)
    CALL ProcessNewOrder('2', '[{"product_id": 1, "quantity": 1000}]');

-- 3. Place multiple orders for the same product and check inventory updates
    CALL ProcessNewOrder('3', '[{"product_id": 4, "quantity": 2}, {"product_id": 4, "quantity": 3}]');
    SELECT * FROM Inventory WHERE product_id = 4;

-- 4. Check last order inserted in Orders table
    SELECT * FROM Orders ORDER BY order_id DESC LIMIT 1;

-- 5. Check last order items in OrderItems table
    SELECT * FROM OrderItems ORDER BY order_item_id DESC LIMIT 5;
    
-- 6. Check Inventory Logs (This is where your logs are stored)
    SELECT * FROM InventoryLogs ORDER BY change_time DESC;
*/
