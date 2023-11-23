
--REFERE TO THE README FILE FOR DESCRIPTION OF EACH TABLE, TRIGGER, TRIGGER FUNCTION, VIEW AND INDEX.
--TABLES

CREATE TABLE customers(
customer_id INT NOT NULL PRIMARY KEY,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(40) NOT NULL,
email VARCHAR(40) UNIQUE,
phone_number VARCHAR(15) UNIQUE,
account_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP);


------

CREATE TABLE address (
address_id INTEGER PRIMARY KEY,
street VARCHAR(100),
city VARCHAR(100) NOT NULL,
state VARCHAR(70) NOT NULL,
postal_code VARCHAR(20),
country VARCHAR(70) NOT NULL,
address_type VARCHAR(30)
);

--------

CREATE TABLE customers_address_link(
customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
address_id INTEGER NOT NULL REFERENCES address(address_id),
PRIMARY KEY(customer_id,address_id)
);

-------

CREATE TABLE product_categories(
category_id INT PRIMARY KEY,
category_name VARCHAR(60) UNIQUE,
category_description VARCHAR(200));

--------

CREATE TABLE products(
product_id INTEGER PRIMARY KEY,
category_id INTEGER REFERENCES product_categories(category_id),
product_name VARCHAR(70) UNIQUE,
product_description VARCHAR(255),
product_price REAL CHECK(product_price>0),
inventory INTEGER CHECK(inventory>=0));

--------



CREATE TABLE orders(
order_id INTEGER PRIMARY KEY,
customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
order_date  TIMESTAMP,
shipping_date TIMESTAMP,
order_status VARCHAR(50),
order_total REAL
);

-------

CREATE TABLE order_details(
orderdetails_id INTEGER PRIMARY KEY,
order_id INTEGER NOT NULL REFERENCES orders(order_id),
product_id INTEGER NOT NULL REFERENCES products(product_id),
product_quantity INTEGER,
price_per_unit REAL
);

-----

CREATE TABLE payments(
payment_id INTEGER PRIMARY KEY,
order_id INTEGER NOT NULL REFERENCES orders(order_id),
payment_date TIMESTAMP,
amount REAL,
payment_method VARCHAR(70),
status VARCHAR(50));

-- TRIGGER FUNCTIONS

CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS 
$$
BEGIN
NEW.last_updated=CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$
LANGUAGE plpgsql;


------


CREATE OR REPLACE FUNCTION reduce_inventory()
RETURNS TRIGGER AS 
$$
BEGIN
UPDATE products SET inventory= inventory-NEW.product_quantity
WHERE product_id=NEW.product_id;
RETURN NEW;
END;
$$
LANGUAGE plpgsql;

--TRIGGERS

CREATE TRIGGER update_last_updated_trigger
BEFORE UPDATE ON customers
FOR EACH ROW 
EXECUTE FUNCTION update_last_updated_column();

---

CREATE TRIGGER order_placed
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION reduce_inventory();



--INDEXES

CREATE INDEX idx_product_name ON products(product_name,inventory);
-----
CREATE INDEX idx_state ON address(state);
----
CREATE INDEX idx_email ON customers(first_name,last_name,email);

-- VIEWS

CREATE VIEW product_inventory AS
SELECT product_name , 
	inventory
FROM products;

----

CREATE VIEW order_details_view AS
SELECT  o.order_id,
	o.order_date,
	p.product_name,
	od.product_quantity,
	od.price_per_unit,
	(od.price_per_unit*od.product_quantity) AS total_price
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id;

---

CREATE VIEW customers_details AS
SELECT DISTINCT c.customer_id,
		c.first_name,
		c.last_name,
		c.email,
		c.phone_number,
		a.city,
		a.country
FROM customers c 
	 JOIN customers_address_link ca ON c.customer_id =ca.customer_id
	 JOIN address a ON a.address_id =ca.address_id;


