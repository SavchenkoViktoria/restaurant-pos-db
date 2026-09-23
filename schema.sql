----------------------------------------------------------------------------------
                    --схема бази даних для ресторанного обліку
                       --restaurant POS database schema
----------------------------------------------------------------------------------

--ОПИС СТВОРЕНИХ ТИПІВ (ENUM)
--DESCRIPTION OF ENUM TYPES

-- створення типу даних (ENUM) посада працівника
-- create ENUM type for employee position
CREATE TYPE employee_role AS ENUM ('cashier', 'waiter', 'cook', 'manager', 'admin');

-- створення типу даних одиниця вимірювання
-- create ENUM type for unit of measurement
CREATE TYPE unit_type AS ENUM ('g', 'ml', 'pcs');

-- створення типу даних (ENUM) статус замовлення
-- create ENUM type for an order status
CREATE TYPE order_status AS ENUM ('in_process', 'ready', 'cancel');

-- створення типу даних (ENUM) спосіб оплати
-- create ENUM type for payment method
CREATE TYPE payment_type AS ENUM ('cash', 'card');

-----------------------------------------------------------------------------------
--ОПИС СТВОРЕНИХ ТАБЛИЦЬ
--DATABASE SCHEMA TABLES

--створення таблиці магазинів
--create stores table
CREATE TABLE stores (
id SERIAL PRIMARY KEY,
name VARCHAR(30) NOT NULL,
address VARCHAR(60) NOT NULL,
phone_number VARCHAR (20) NOT NULL UNIQUE
);

--створення таблиці працівників
--create employees table
CREATE TABLE employees (
id SERIAL PRIMARY KEY,
store_id INT NOT NULL,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
role employee_role NOT NULL,
pincode VARCHAR (4) NOT NULL,
FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
UNIQUE (store_id, pincode)
);

--створення таблиці змін
--create shifts table
CREATE TABLE shifts (
id SERIAL PRIMARY KEY,
store_id INT NOT NULL,
employee_id INT NOT NULL,
open_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
close_at TIMESTAMP,
starting_cash NUMERIC (10,2) NOT NULL DEFAULT (0.00) CHECK (starting_cash>=0),
ending_cash NUMERIC (10,2) CHECK (ending_cash>=0),
FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);

--створення таблиці покупців
--create customer table
CREATE TABLE customers (
id SERIAL PRIMARY KEY,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
phone_number VARCHAR(20) NOT NULL UNIQUE,
points_balance NUMERIC(10,2) NOT NULL DEFAULT (0.00) CHECK (points_balance>=0),
registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--створення таблиці інградієнтів
--create ingradients table
CREATE TABLE ingradients (
id SERIAL PRIMARY KEY,
name VARCHAR(30) NOT NULL UNIQUE,
unit unit_type NOT NULL,
cost_per_unit NUMERIC (10,2) NOT NULL
);

--створення таблиці залишків на складі
--create inventory table
CREATE TABLE inventory (
id SERIAL PRIMARY KEY,
store_id INT NOT NULL ,
ingradient_id INT NOT NULL,
current_stock NUMERIC(10,2) NOT NULL,
FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
FOREIGN KEY (ingradient_id) REFERENCES ingradients(id) ON DELETE CASCADE,
UNIQUE (store_id, ingradient_id)
);

--створення таблиці категорій товару
--create product categories table
CREATE TABLE categories (
id SERIAL PRIMARY KEY,
name VARCHAR(30) NOT NULL UNIQUE
);

--створення таблиці страв/товарів
--create products table
CREATE TABLE items (
id SERIAL PRIMARY KEY,
category_id INT NOT NULL,
name VARCHAR(30) NOT NULL UNIQUE,
cost NUMERIC (10,2) NOT NULL,
is_active BOOLEAN NOT NULL DEFAULT TRUE,
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

--створення таблиці технологічних карток товару
--create recipes table
CREATE TABLE tech_cards (
id SERIAL PRIMARY KEY,
item_id INT NOT NULL,
ingradient_id INT NOT NULL,
quantity NUMERIC (5,2) NOT NULL,
FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
FOREIGN KEY (ingradient_id) REFERENCES ingradients(id) ON DELETE CASCADE,
UNIQUE (item_id, ingradient_id)
);

--створення таблиці замовлень
--create orders table
CREATE TABLE orders (
id SERIAL PRIMARY KEY,
shift_id INT,
customer_id INT,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
status order_status NOT NULL,
payment_method payment_type,
total_amount NUMERIC (10,2) NOT NULL,
FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE,
FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);

--створення таблиці замовлених позицій
--create ordered items table
CREATE TABLE order_items (
id SERIAL PRIMARY KEY,
order_id INT,
item_id INT,
quantity NUMERIC (5,2) NOT NULL,
unit_price NUMERIC (10,2) NOT NULL,
FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);
-----------------------------------------------------------------------------------
--ОПИС ІНДЕКСІВ
--INDEX DESCRIPTIONS

--створення індексу для пошуку клієнта за прізвищем та ім'ям
--create index to search customers by last and first name
CREATE INDEX index_customers_name ON customers(last_name, first_name);

--створення індексу для пошуку позиції за назвою
--create index to search items by name
CREATE INDEX index_items_name ON items(name);

--створення індексу для пошуку доступної позиції
--create index to search active items
CREATE INDEX index_active_items ON items(id)
WHERE is_active = TRUE;


--створення індексу для пошуку замовлення за часом створення
--create index for order creation time
CREATE INDEX index_orders_created ON orders(created_at);

--створення індексу для пошуку замовлення за ідентифікатором клієнта
--create index for order customer id
CREATE INDEX index_orders_customer ON orders(customer_id);

--створення індексу для пошуку замовлення за ідентифікатором зміни
--create index for order`s shifts id
CREATE INDEX index_orders_shifts ON orders(shift_id);

--створення індексу для пошуку замовлених позицій за ідентифікатором замовлення
--create index for order`s items by order id
CREATE INDEX index_orders_items ON order_items(order_id);

--створення індексу для пошуку товарів, які закінчуються на складі
--create partial index for low stock items
CREATE INDEX index_inventory_stock ON inventory(store_id, current_stock) WHERE current_stock<5;
-----------------------------------------------------------------------------------
--ОПИС ПОДАНЬ
--VIEW DESCRIPTIONS

--створення подання залишків товарів на складах
--create view for current stock inventory
CREATE VIEW view_store_stock AS
SELECT stores.name AS store_name, ingradients.name AS ingradient_name,
ingradients.unit, inventory.current_stock
FROM stores
JOIN inventory ON stores.id=inventory.store_id
JOIN ingradients ON ingradients.id=inventory.ingradient_id;

--створення подання звітності за зміну
--create view for shift summary
CREATE VIEW view_shift_summary AS
SELECT shifts.id AS shift_id, stores.name AS store_name,
CONCAT_WS(' ', employees.first_name, employees.last_name) AS employee_name,
shifts.open_at, shifts.close_at, COUNT(orders.id) AS total_orders,
COALESCE(SUM(orders.total_amount), 0.00) AS total_revenue,
COALESCE(ROUND(AVG(orders.total_amount), 2), 0.00) AS avg_check,
COALESCE(MAX(orders.total_amount), 0.00) AS max_check
FROM shifts
JOIN stores ON stores.id=shifts.store_id
JOIN employees ON shifts.employee_id=employees.id
LEFT JOIN orders ON shifts.id=orders.shift_id AND orders.status != 'cancel'
GROUP BY shifts.id, stores.name, employees.first_name, employees.last_name, shifts.open_at, shifts.close_at
ORDER BY stores.name ASC, shifts.id DESC;

--створення подання собівартості товарів
--create view for item costs
CREATE VIEW view_item_costs AS
SELECT items.id, items.name, items.cost AS selling_price,
ROUND(SUM(tech_cards.quantity * ingradients.cost_per_unit),2) AS estimated_food_cost,
ROUND(items.cost-SUM(tech_cards.quantity * ingradients.cost_per_unit),2) AS gross_profit
FROM items
JOIN tech_cards ON items.id=tech_cards.item_id
JOIN ingradients ON tech_cards.ingradient_id=ingradients.id
GROUP BY items.id, items.name, items.cost;

--створення подання з актуальними позиціями меню
--create available menu view
CREATE VIEW view_available_menu AS
SELECT s.id AS store_id, s.name AS store_name, c.name AS category_name,
i.id AS item_id, i.name AS item_name, i.cost AS price
FROM items i
CROSS JOIN stores s
JOIN categories c ON i.category_id=c.id
WHERE i.is_active = TRUE
AND NOT EXISTS(
    SELECT 1
    FROM tech_cards tc
    JOIN inventory inv ON tc.ingradient_id=inv.ingradient_id
    WHERE tc.item_id=i.id
    AND inv.store_id=s.id
    AND (inv.current_stock <=0 OR inv.current_stock < tc.quantity)
);
-----------------------------------------------------------------------------------
--ОПИС ТРИГЕРІВ
--TRIGGERS DESCRIPTIONS

--створення функції списання продуктів зі складу при створенні замовлення
--create trigger function to deduct ingredients upon order placement
CREATE OR REPLACE FUNCTION fn_deduct_inventory_on_order()
RETURNS TRIGGER AS $$
DECLARE
    v_store_id INT;
BEGIN
    SELECT s.store_id INTO v_store_id
    FROM orders o
    JOIN shifts s ON o.shift_id=s.id
    WHERE o.id=NEW.order_id;

    UPDATE inventory inv
    SET current_stock = inv.current_stock - (tc.quantity*NEW.quantity)
    FROM tech_cards tc
    WHERE inv.ingradient_id=tc.ingradient_id
        AND tc.item_id=NEW.item_id
        AND inv.store_id=v_store_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--створення тригеру списання продуктів зі складу при створенні замовлення
--create trigger to deduct ingredients upon order placement
CREATE TRIGGER trg_deduct_inventory
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION fn_deduct_inventory_on_order();

--створення функції повернення продуктів на склад після скасування замовлення
--create trigger function to restore ingredients after order cancel
CREATE OR REPLACE FUNCTION fn_restore_inventory_on_cancel()
RETURNS TRIGGER AS $$
DECLARE
    v_store_id INT;
    rec RECORD;
BEGIN
    IF NEW.status = 'cancel' AND OLD.status != 'cancel' THEN

    SELECT s.store_id INTO v_store_id
    FROM shifts s
    WHERE s.id=NEW.shift_id;

    FOR rec IN
        SELECT tc.ingradient_id, SUM(tc.quantity*oi.quantity) AS total_to_restore
        FROM order_items oi
        JOIN tech_cards tc ON oi.item_id = tc.item_id
        WHERE oi.order_id=NEW.id
        GROUP BY tc.ingradient_id
    LOOP
        UPDATE inventory inv
        SET current_stock = inv.current_stock + rec.total_to_restore
        WHERE inv.ingradient_id=rec.ingradient_id
            AND inv.store_id=v_store_id;
    END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--створення тригеру повернення продуктів на склад після скасування замовлення
--create trigger to restore ingredients after order cancel
CREATE TRIGGER trg_restore_inventory_on_cancel
AFTER UPDATE OF status ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_restore_inventory_on_cancel();
-----------------------------------------------------------------------------------
