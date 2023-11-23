# Database-Design-Ecommerce

*The order of code in my .sql file is different than this README file , I have separated my code in categories in the coding file using comments. I have created the tables first and then trigger functions and triggers and after that indexes and Views. But understanding the code is easier in the order I have used in this README file.*

## Introduction

I have designed this Database for an e-commerce Website, I have provided the documentation and the code to create this database, along with some views that are readily available. An ERD for this Database is also published using crow foot’s notation to better understand the Database. I have tried to include most aspects that you would need from an e-commerce website’s database, I have tried to keep it simple so anyone using this database can modify it according to their needs. Feedback on this Database is always appreciated.

## CUSTOMERS TABLE

The first query is to create the customers table which will contain information like the first_name, last_name, email and phone number for the customer. For the address of the customer I am planning to make a separate table, because I want to give a customer option to add multiple address. Also if I have a separate table for address that makes it easier to do location based analysis using CITY, COUNTRY, POSTAL CODE and so on.

`CREATE TABLE customers(`

`customer_id INT NOT NULL PRIMARY KEY,`

`first_name VARCHAR(30) NOT NULL,`

`last_name VARCHAR(40) NOT NULL,`

`email VARCHAR(40) UNIQUE,`

`phone_number VARCHAR(15) UNIQUE,`

`account_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,`

`last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);`

Keep in mind that you don’t need the TRIGGER FUNCTION and TRIGGER if you are making your database for mysql DBMS. This is for Postgres. If you are on mysql , you just need to replace the last line of my customers table creation code from :
last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
TO
last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
And it will perform the same function that the triggers below are performing.

## FUNCTION AND TRIGGER FOR LAST_UPDATED COLUMN TO WORK PROPERLY

Now I have set account_created and last_updated columns such that they put in the Current Timestamp when the new rows are added. That works for out account_created column but I also want my last_updated column to update automatically every time a row is modified, For that I will have to create a Trigger for UPDATE clause and also create  TRIGGER function for that.


## TRIGGER FUNCTION

This function is called by the Trigger and it  updates the last_updated column of each row that is updated in the customers table.

`CREATE OR REPLACE FUNCTION update_last_updated_column()`

`RETURNS TRIGGER AS `

`$$`

`BEGIN`

`NEW.last_updated=CURRENT_TIMESTAMP;`

`RETURN NEW;`

`END;`

`$$`

`LANGUAGE plpgsql;`

## TRIGGER
This is the trigger that is used to call the trigger function every time the update Claus is used on the customers table. This trigger calls the trigger function.

`CREATE TRIGGER update_last_updated_trigger`

`BEFORE UPDATE ON customers`

`FOR EACH ROW`

`EXECUTE FUNCTION update_last_updated_column();`






## ADDRESS TABLE

I added this table to add clarity and help in further analysis based on location in the future like I explained in the paragraph above. This table has address_id as the primary key and the customer_id is the foreign key referencing to customers table.

`CREATE TABLE address (`

`address_id INTEGER PRIMARY KEY,`

`street VARCHAR(100),`

`city VARCHAR(100) NOT NULL,`

`state VARCHAR(70) NOT NULL,`

`postal_code VARCHAR(20),`

`country VARCHAR(70) NOT NULL,`

`address_type VARCHAR(30)`

);`



## CUSTOMERS_ADDRESS_LINK TABLE

I could have left this table out of the picture, but without this table two customers can’t have the same address without making the connection between Address table and Customers table a MANY TO MANY relationship, which we would like to avoid to maintain Data integrity and reduce complexity in our queries. In this table I will use (cusotmer_id and Address_id) together as Primary Key.


`CREATE TABLE customers_address_link(`

`customer_id INTEGER NOT NULL REFERENCES customers(customer_id),`

`address_id INTEGER NOT NULL REFERENCES address(address_id),`

`PRIMARY KEY(customer_id,address_id)`

);`


## PRODUCT_CATEGORIES TABLE

This table represents all the categories of the products that are available in the inventory, It has a primary key category_id which we will use in the products table as a reference back to this table.

`CREATE TABLE product_categories(`
`category_id INT PRIMARY KEY,`

`category_name VARCHAR(60) UNIQUE,`

`category_description VARCHAR(200));`


## PRODUCTS TABLE

This table is for all the products present in the inventory, each product has a product_id, name, a small description, it’s price and the inventory.

`CREATE TABLE products(`

`product_id INTEGER PRIMARY KEY,`

`category_id INTEGER REFERENCES product_categories(category_id),`

`product_name VARCHAR(70) UNIQUE,`

`product_description VARCHAR(255),`

`product_price REAL CHECK(product_price>0),`

`inventory INTEGER CHECK(inventory>=0));`


## ORDERS TABLE 

This table contains information about orders such as order_id, which is the primary key of this table and customer_id which is a foreign key referencing to customers table and other information such as order_date, shipping_date and order_total.


`CREATE TABLE orders(`

`order_id INTEGER PRIMARY KEY,`

`customer_id INTEGER NOT NULL REFERENCES customers(customer_id),`

`order_date  TIMESTAMP,`

`shipping_date TIMESTAMP,`

`order_status VARCHAR(50),`

`order_total REAL`
);`


## ORDER_DETAILS TABLE

This table contains more information about order, such as what products were in a specific order and the quantity of each product. It has a primary key and a foreign key referencing back to order_id and a product_id foreign key referencing back to products table.

`CREATE TABLE order_details(`

`orderdetails_id INTEGER PRIMARY KEY,`

`order_id INTEGER NOT NULL REFERENCES orders(order_id),`

`product_id INTEGER NOT NULL REFERENCES products(product_id),`

`product_quantity INTEGER,`

`price_per_unit REAL`

);`

Now I want the inventory in Products table to reduce every time a new order is placed accordingly, so we will once again create a TRIGGER  and TRIGGER FUNCTION here for that.

## TRIGGER FUNCTION

`CREATE OR REPLACE FUNCTION reduce_inventory()`

`RETURNS TRIGGER AS`

`$$`

`BEGIN`

`UPDATE products SET inventory= inventory-NEW.product_quantity`

`WHERE product_id=NEW.product_id;`

`RETURN NEW;`

`END;`

`$$`

`LANGUAGE plpgsql;`

## TRIGGER 

`CREATE TRIGGER order_placed`

`AFTER INSERT ON order_details`

`FOR EACH ROW`

`EXECUTE FUNCTION reduce_inventory();`


## PAYMENTS TABLE

This table contains payment information of each order, it has payment_id as its PRIMARY KEY and order_id as a foreign key REFERENCING back to orders table along with other information about the payment such as payment date, amount, method and status of the payment

`CREATE TABLE payments(`

`payment_id INTEGER PRIMARY KEY,`

`order_id INTEGER NOT NULL REFERENCES orders(order_id),`

`payment_date TIMESTAMP,`

`amount REAL,`

`payment_method VARCHAR(70),`

`status VARCHAR(50));`


## INDEXING 

Now I want to create some index for better optimization and faster query results. I am going to take some columns that are often used and create indexes on those.

`CREATE INDEX idx_product_name ON products(product_name,inventory);`

`CREATE INDEX idx_state ON address(state);`

`CREATE INDEX idx_email ON customers(first_name,last_name,email);`


## VIEWS

These are some views that I have chosen to add into the database, simply for better efficiency as these are some things that are required occasionally. 

This view can be used to check the product inventory.

`CREATE VIEW product_inventory AS`

`SELECT product_name ,`

`	inventory`

`FROM products;`


This view can be used to check order_details 
`CREATE VIEW order_details_view AS`

`SELECT  o.order_id,`

`	o.order_date,`

`	p.product_name,`

`	od.product_quantity,`

`	od.price_per_unit,`

`	(od.price_per_unit*od.product_quantity) AS total_price`

`FROM orders o`

`JOIN order_details od ON o.order_id = od.order_id`

`JOIN products p ON od.product_id = p.product_id;`



This view to get deatiled information for all customers

`CREATE VIEW customers_details AS`

`SELECT DISTINCT c.customer_id,`

`		c.first_name,`

`		c.last_name,`

`		c.email,`

`		c.phone_number,`

`		a.city,`

`		a.country`

`FROM customers c `

`	 JOIN customers_address_link ca ON c.customer_id =ca.customer_id`
`	 JOIN address a ON a.address_id =ca.address_id;`



