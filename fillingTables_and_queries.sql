--INSERTING DATA IN OUR TABLES SO WE CAN PERFORM SOME QUERIES ON OUR DATA.

INSERT INTO product_categories(category_id,category_name,category_description)
VALUES
	(1,'Clothing', 'Clothes such as shirts,pants,garments etc.'),
	(2,'Accessory','Jewellery, Belts, Headbands etc.'),
	(3,'Electronics','Mobile phones, laptops, TV(s), smart watch etc');


INSERT INTO products(product_id,category_id,product_name,product_description,product_price,inventory)
VALUES 
	(1,2,'PU Leather Belt','High quality Leather Belt',49.99,14),
	(2,3,'Iphone SE','IOS based phone By Apple Brand',599.99,6),
	(3,2,'Silver Ring with Black Onyx', 'Sterling Silver Ring with Black Onyx Stone, square shaped',149.99,4),
	(4,1,'Black Fleece Jacket','Black oversized Fleece Jacket, wool-blend',129.99,5);

INSERT INTO Customers(customer_id,first_name,last_name,email,phone_number)
VALUES 
	(1,'Sam','Watts','samwatts321@example.com','232-727-XXXX'),
	(2,'Rishi','Chauhan','rishi32@example.com','432-272-XXXX'),
	(3,'Ayush','Reddy','ayushreddy672@example.com','278-921-XXXX'),
	(4,'Frank','Blackwell','Frank2Blackwell@example.com','272-441-XXXX');

INSERT INTO orders(order_id,customer_id,shipping_date,order_status,order_total)
VALUES
	(1,2,'2023-11-24 11:01:39','pending',199.97),
	(2,3,'2023-11-26 12:05:20','delivered',129.99),
	(3,4,'2023-11-22 09:07:21','pending',749.98)

INSERT INTO order_details(orderdetails_id,order_id,product_id,product_quantity,price_per_unit)
VALUES 
	(1,1,1,1,49.99),
	(2,1,3,1,149.99),
	(3,2,4,1,129.99),
	(4,3,2,1,599.99),
	(5,3,3,1,149.99)

INSERT INTO address(address_id,street,city,state,postal_code,country,address_type)
VALUES (1,'123 ottawa Ave.','Ottawa','Ontario','A2B C7E','Canada','shipping'),
	(2,'12 Richmond Ave.','Toronto','Ontario','AC3 D9E','Canada','billing'),
	(3,'17 North Ave.','Windsor','Ontario','E2R F4E','Canada','shipping'),
	(4,'23 west Ave.','Calgary','Alberta','X9F V5G','Canada','shipping'),
	(5,'57 east Ave.','Vancouver','British Columbia','F9G W7T','Canada','billing')

INSERT INTO customers_address_link(address_id,customer_id)
VALUES 
	(1,3),
	(2,4),
	(5,2),
	(5,1),
	(1,2)


--PERFORMING SOME QUERIES

-- SELECTING product name, product desc, category,cat_description,price and inventory where price of
--a product is more than 120.

SELECT product_name,product_description, category_name,category_description,product_price,inventory
FROM products p JOIN product_categories pc ON p.category_id= pc.category_id
WHERE product_price>120;



-- BELOW we see our trigger functions in work, once we update email of a customer , the last_updated
-- column of that row will automatically update.
UPDATE customers
SET email='samwatts123@example.com'
WHERE customer_id=1;
--

	
-- Lets see all addresses of a customer with customer_id = 2

SELECT c.customer_id, c.first_name, (a.street||', ' || a.city||', ' || a.state || ', '|| a.country) AS address, a.address_type
FROM customers c JOIN customers_address_link ca ON c.customer_id=ca.customer_id
JOIN address a ON a.address_id= ca.address_id
WHERE c.customer_id=2


-- Let's see billing addrss of all customers
SELECT c.customer_id, c.first_name, (a.street||', ' || a.city||', ' || a.state || ', '|| a.country) AS address, a.address_type
FROM customers c JOIN customers_address_link ca ON c.customer_id=ca.customer_id
JOIN address a ON a.address_id= ca.address_id
WHERE address_type='billing' 