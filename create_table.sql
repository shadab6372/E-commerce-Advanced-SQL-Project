CREATE TABLE categories(
category_id varchar(10) PRIMARY KEY,
category_name varchar(15)
)

CREATE TABLE customers(
cust_id varchar(10) PRIMARY KEY,
name varchar(25),
state varchar(20),
address varchar(70)
)

CREATE TABLE inventory(
inventory_id varchar(10) PRIMARY KEY,
product_id varchar(10),
stock_remaining int,
warehouse_id varchar(10),
restock_date date
)

CREATE TABLE order_items(
order_item_id varchar(10) PRIMARY KEY,
order_id varchar(10),
product_id varchar(10),
quantity int,
price_per_unit numeric,
total_price numeric
)

CREATE TABLE orders(
order_id varchar(10) PRIMARY KEY,
order_date date,
customer_id varchar(10),
order_state varchar(20),
seller_id varchar(10)
)

CREATE TABLE payments(
payment_id varchar(10) PRIMARY KEY,
payment_date date,
payment_mode varchar(10),
payment_status varchar(20),
order_id varchar(10)
)

CREATE TABLE products(
product_id varchar(10) PRIMARY KEY,
product_name varchar(30),
price numeric,
cogs numeric,
category_id varchar(10)
)

CREATE TABLE sellers(
seller_id varchar(10) PRIMARY KEY,
seller_name varchar(40)
)

CREATE TABLE shipping(
shipping_id varchar(15) PRIMARY KEY,
order_id varchar(10),
delivery_status varchar(15),
shipping_date date,
return_date date
)



COPY categories 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/categories.csv'
DELIMITER ','
CSV HEADER

COPY customers 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/customers.csv'
DELIMITER ','
CSV HEADER

COPY inventory 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/inventory.csv'
DELIMITER ','
CSV HEADER

COPY order_items 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/order_items.csv'
DELIMITER ','
CSV HEADER

COPY orders 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/orders.csv'
DELIMITER ','
CSV HEADER

COPY payments 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/payments.csv'
DELIMITER ','
CSV HEADER

COPY products 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/products.csv'
DELIMITER ','
CSV HEADER

COPY sellers 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/sellers.csv'
DELIMITER ','
CSV HEADER

COPY shipping 
FROM 'G:/Data Analysis/Ecomerce SQL data analysis/dataset/shipping.csv'
DELIMITER ','
CSV HEADER





ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_product
FOREIGN KEY (product_id) REFERENCES products(product_id)

ALTER TABLE order_items
ADD CONSTRAINT fk_orders_item
FOREIGN KEY (order_id) REFERENCES orders(order_id)

ALTER TABLE order_items
ADD CONSTRAINT fk_order_product
FOREIGN KEY (product_id) REFERENCES products(product_id)

ALTER TABLE orders
ADD CONSTRAINT fk_order_customer
FOREIGN KEY (customer_id) REFERENCES customers(cust_id)

ALTER TABLE orders
ADD CONSTRAINT fk_order_seller
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)

ALTER TABLE payments
ADD CONSTRAINT fk_payment_order
FOREIGN KEY (order_id) REFERENCES orders(order_id)

ALTER TABLE products
ADD CONSTRAINT fk_product_category
FOREIGN KEY (category_id) REFERENCES categories(category_id)

ALTER TABLE shipping
ADD CONSTRAINT fk_order_shipping
FOREIGN KEY (order_id) REFERENCES orders(order_id)
