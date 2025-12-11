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

-- Stored Procedure(automates creating an order)

CREATE PROCEDURE ProcessNewOrder(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE current_stock INT;
    
    -- Get current inventory
    SELECT quantity INTO current_stock
    FROM Inventory
    WHERE product_id = p_product_id;
    
    -- Check stock
    IF current_stock >= p_quantity THEN
        START TRANSACTION;
        
        -- Reduce inventory
        UPDATE Inventory
        SET quantity = quantity - p_quantity
        WHERE product_id = p_product_id;
        
        -- Create new order
        INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
        VALUES (p_customer_id, CURDATE(), p_quantity * (SELECT price FROM Products WHERE product_id = p_product_id), 'Pending');
        
        -- Get last inserted order ID
        SET @last_order_id = LAST_INSERT_ID();
        
        -- Add item to OrderItems
        INSERT INTO OrderItems (order_id, product_id, quantity, price)
        VALUES (@last_order_id, p_product_id, p_quantity, (SELECT price FROM Products WHERE product_id = p_product_id));
        
        COMMIT;
    ELSE
        -- Not enough stock, rollback
        ROLLBACK;
        SELECT CONCAT('Error: Only ', current_stock, ' units in stock') AS message;
    END IF;
END //

DELIMITER ;

/* Test Case for CustomerSalesSummary view
-- Shows how much each customer has spent
   SELECT * FROM CustomerSalesSummary;
*/

/* Test Cases for ProcessNewOrder procedure
-- 1. Place order with enough stock
    CALL ProcessNewOrder(1, 1, 5);

-- 2. Place order with quantity exceeding stock (should show error)
    CALL ProcessNewOrder(2, 1, 1000);

-- 3. Place multiple orders for the same product and check inventory updates
    CALL ProcessNewOrder(3, 4, 2);
    CALL ProcessNewOrder(4, 4, 3);
    SELECT * FROM Inventory WHERE product_id = 4;

-- 4. Check last order inserted in Orders table
   SELECT * FROM Orders ORDER BY order_id DESC LIMIT 1;

-- 5. Check last order items in OrderItems table
   SELECT * FROM OrderItems ORDER BY order_item_id DESC LIMIT 5;
*/ 

