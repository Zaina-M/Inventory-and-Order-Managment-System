# Inventory Management System 

## Description
This project implements a simple **Inventory Management System** using **MySQL**.  
It demonstrates table creation, data insertion, **views**, and **stored procedures** for database optimization and automation.

---

## Database Tables

1. **Customers** – Stores customer details  
   Columns: `customer_id`, `full_name`, `email`, `phone`, `shipping_address`

2. **Products** – Stores product information  
   Columns: `product_id`, `product_name`, `category`, `price`

3. **Inventory** – Tracks product quantities  
   Columns: `product_id`, `quantity`

4. **Orders** – Stores customer orders  
   Columns: `order_id`, `customer_id`, `order_date`, `total_amount`, `order_status`

5. **OrderItems** – Bridge table connecting Orders and Products (many-to-many)  
   Columns: `order_id`, `product_id`, `quantity`, `price`

---

## Views

### `CustomerSalesSummary`
- Pre-calculates the total amount spent by each customer.  
- Only includes customers who have made at least one order.  
---

## Stored Procedures

### ProcessNewOrder

Automates placing a new order:

1.Checks product stock

2.Updates inventory

3.Creates a new order

4.Adds order items

Returns an error message if stock is insufficient

Example usage:

```sql
SELECT * FROM Customers;
