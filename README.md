# Inventory Management System

A robust SQL-based Inventory Management System designed to handle customers, products, orders, and real-time inventory tracking. This project demonstrates advanced MySQL features including Stored Procedures with JSON parsing, Triggers, and Views.

## Features

- **Order Processing**: Automated order creation handling multiple items per order via JSON input.
- **Inventory Management**: Real-time stock verification and atomic updates.
- **Audit Logging**: Automatic tracking of all inventory changes (stock updates, sales) via database triggers.
- **Analytics**: KPI queries for revenue, best-selling products, and customer spending rank.

## Database Schema

The system consists of the following 6 normalized tables:

1.  **Customers**: Stores customer details (`customer_id`, `full_name`, `email`, etc.).
2.  **Products**: Catalog of available items (`product_id`, `name`, `price`, `category`).
3.  **Inventory**: Current stock levels linked to products.
4.  **Orders**: Master order records (`order_id`, `customer_id`, `total_amount`, `status`).
5.  **OrderItems**: Line items for each order (`order_id`, `product_id`, `quantity`, `price`).
6.  **InventoryLogs**: **[NEW]** Audit trail for inventory adjustments (`log_id`, `old_quantity`, `new_quantity`, `change_time`).

##  Key Components

### 1. Stored Procedure: `ProcessNewOrder`

A transactional procedure that accepts a JSON array of items to create a complete order in one go.

**Signature:**

```sql
ProcessNewOrder(
    IN p_customer_id INT,
    IN p_order_details JSON
)
```

**Logic:**

- Parses the input JSON (e.g., `[{"product_id": 1, "quantity": 2}, ...]`).
- Checks stock availability for _all_ items before proceeding.
- Calculates the total order value.
- Inserts the record into `Orders`.
- Inserts individual line items into `OrderItems`.
- Updates `Inventory` counts.
- **Rolls back** the entire transaction if any product is out of stock.

### 2. Trigger: `ItemUpdateTrigger`

Automatically fires whenever the `Inventory` table is updated. It records the state before and after the change into the `InventoryLogs` table, ensuring strict accountability.

### 3. View: `CustomerSalesSummary`

A virtual table that aggregates total spending per customer for quick reporting.

##  How to Run

### Prerequisite

- MySQL 5.7+ (Required for JSON support) or MySQL 8.0+.
- MySQL Workbench or any SQL client.

### Steps

1.  **Setup Database (DDL)**:
    Open and run `Inventory_mgt_ddl.sql`. This will:

    - Create the `inventory_system` database.
    - Create all tables.
    - Seed the database with sample Customers and Products.

2.  **Setup Logic (DML)**:
    Open and run `Inventory_mgt_dml.sql`. This will:
    - Create the `ProcessNewOrder` stored procedure.
    - Create the `ItemUpdateTrigger`.
    - Create the `CustomerSalesSummary` view.
    - (Optional) Execute the test cases at the end of the file.

### Testing

You can place a test order using the following SQL command:

```sql
CALL ProcessNewOrder(1, '[
    {"product_id": 1, "quantity": 1},
    {"product_id": 2, "quantity": 2} -- Ordering 2 Smartphones
]');
```

Check the results:

```sql
SELECT * FROM Orders ORDER BY order_id DESC LIMIT 1;
SELECT * FROM InventoryLogs ORDER BY change_time DESC;
```

``` mermaid