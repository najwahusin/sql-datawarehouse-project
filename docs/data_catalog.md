# Data Dictionary for Gold Layer

### 1. gold.dim_customers
  - Stores customers details

| Column Names | Data Types | Description |
|--------------|------------|-------------|
| customer_key | INT | Surrogate key to identify customer's record in the table |
| customer_id | INT | Unique numerical identifier assigned to each cuatomer |
| customer_number | NVARCHAR(50) | Unique alphanumerical identifier assigned to each cuatomer used for tracking and referencing |
| first_name | NVARCHAR(50) | Customer's first name |
| last_name | NVARCHAR(50) | Customer's last name or family name |
| country | NVARCHAR(50) | Customer's country of residence |
| marital_status | NVARCHAR(50) | Customer's marital status (e.g: Married, Single) |
| gender | NVARCHAR(50) | Customer's gender (e.g.: Male, Female, n/a) |
| bithdate | DATE | Customer's date of birth |
| create_date | DATE | The date of the customer's data is recorded in the system|

### 2. gold.dim_products
  - Stores products details

| Column Names | Data Types | Description |
|--------------|------------|-------------|
| product_key | INT | Surrogate key to identify product information in the table |
| product_id | INT | Unique numerical identifier assigned to each product's record |
| product_number | NVARCHAR(50) | Unique alphanumerical identifier assigned to each product used for tracking and referencing |
| product_name | NVARCHAR(50) | Name of product which includes details such as colours and size |
| category_id | NVARCHAR(50) | Alphabetical identifier unique to each product's category |
| category | NVARCHAR(50) | General category for products in the table (e.g.: Accessories, Clothing, etc.) |
| subcategory | NVARCHAR(50) | Subcategory of products in the table (e.g: Locks, Gloves, etc.) |
| maintenance | NVARCHAR(50) | Information on wheter the products needed maintenance or not (e.g: Yes, No, NULL) |
| cost | INT | Cost of products |
| product_line | NVARCHAR(50) ||
| start_date | DATE ||

### 3. gold.fact_sales
  - Stores sales activities including information about

| Column Names | Data Types | Description |
|--------------|------------|-------------|
| order_number | NVARCHAR(50) | Unique alphanumerical identifier for each order made |
| product_key | INT | Surrogate key to identify product information in the table |
| customer_key | INT | Surrogate key to identify customer's record in the table |
| order_date | DATE | Date the order is made |
| shipping_date | DATE | Date the order is shipped |
| due_date | DATE | Date the order is due |
| sales_amount | INT | Sales the amount paid by customers based on the product of price and quantity |
| quantity | INT | Quantity of orders made |
| price | INT | Price of products |
