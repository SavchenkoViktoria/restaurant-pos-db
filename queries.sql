----------------------------------------------------------------------------------
                --набір SQL-запитів база даних для ресторанного обліку
                       --SQL-query for POS restaurant database
----------------------------------------------------------------------------------
--СТВОРЕННЯ ДОВІДНИКІВ
--CREATE DIRECTORIES

--додавання закладів мережі
--insert stores
INSERT INTO stores (name, address, phone_number) VALUES
('BISTRO Center', 'Kyiv, Khreshchatyk Street 10', '+38050123456'),
('BISTRO SofBorsh', 'Sofiivska Borshchahivka village, Sobornosti Street 106', '+38050123457');

--додавання персоналу
--insert employees
INSERT INTO employees (store_id, first_name, last_name, role, pincode) VALUES
(1, 'Olha', 'Shevchenko', 'cook', '1234'),
(1, 'Nazar', 'Kovalenko', 'waiter', '4321'),
(1, 'Daria', 'Stepanenko', 'cashier', '1111');

--додавання клієнтів
--insert customers
INSERT INTO customers (first_name, last_name, phone_number, registered_at) VALUES
('Viktoriya', 'Shevchenko', '+380989635250', NOW()),
('Alice', 'Kovalenko', '+380989635251', NOW()),
('Liza', 'Stepanenko', '+380989635252', NOW());

--додавання категорій товару
--insert categories of goods
INSERT INTO categories (name) VALUES ('Coffee'), ('Сroissants');

--додавання інградієнтів страв (собівартість за 1 одиницю)
--insert ingradients og items (cost per 1 unit)
INSERT INTO ingradients (name, unit, cost_per_unit) VALUES
('сoffee beans', 'g', 0.65),
('milk', 'ml', 0.042),
('semi-finished croissant', 'pcs', 25.00);

--внесення залишків на склад
--insert current stock of inventory
INSERT INTO inventory (store_id, ingradient_id, current_stock) VALUES
(1,1,5000.00), --5 kg of beans
(1,2,20000.00), --20 l of milk
(1,3,30.00); --30 psc of croissant

--внесення страв
--insert items
INSERT INTO items (category_id, name, cost, is_active) VALUES
(1,'cappuccino',65.00,TRUE),
(1,'espresso',45.00,TRUE),
(2,'croissant',55.00,TRUE);

--додавання рецептів/тех карт
--insert recipe
INSERT INTO tech_cards (item_id, ingradient_id, quantity) VALUES
(1, 1, 18.00), --cappuccino: 18 g of beans
(1,2,150.00), -- + 150 ml of milk
(2,1,18.00), --espresso: 18 g of beans
(3,3,1); --croissant: 1 semi-finished croissant

--ОПЕРАЦІЙНА РОБОТА КАСИ
--CASH REGISTER OPERATIONS

--відкриття зміни
--open shift
INSERT INTO shifts (store_id, employee_id) VALUES (1,3);

--оформлення замовлення
--insert an order
INSERT INTO orders (shift_id, status, total_amount) VALUES (1,'in_process',185);

--додавання позицій в замовлення
--insert items into order
INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
(1,1,2,65), (1,3,1,55);

--перевірка залишків
--check the inventory
SELECT ingradient_name, current_stock, unit
FROM view_store_stock
WHERE store_name = 'BISTRO Center';

--оплата замовлення
--order payment
UPDATE orders SET status ='ready', payment_method='cash' WHERE id=1;

--оформлення замовлення
--insert an order
INSERT INTO orders (shift_id, status, total_amount) VALUES (1,'in_process',120);

--додавання позицій в замовлення
--insert items into order
INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
(2,1,1,65), (2,3,1,55);

--скасування замовлення
--cancel an order
UPDATE orders SET status ='cancel' WHERE id=2;

--перевірка залишків
--check the inventory
SELECT ingradient_name, current_stock, unit
FROM view_store_stock
WHERE store_name = 'BISTRO Center';

--закриття зміни
--close a shift
UPDATE shifts SET close_at= NOW(),ending_cash=185.00
WHERE id=1;

--АНАЛІТИЧНІ ПОДАННЯ
--ANALYTICAL VIEWS

--подання собівартості товарів
--view for item costs
SELECT * FROM view_item_costs;

--подання підсумків робочої зміни
--view for shift summary
SELECT * FROM view_shift_summary;

--подання з актуальними позиціями в меню
--view for available menu
SELECT * FROM view_available_menu;

--пошук товарів в дефіциті
--view for low stock items
SELECT ingradient_name, current_stock, unit
FROM view_store_stock
WHERE store_name = 'BISTRO Center'
  AND current_stock < 5;

--пошук найпопулярніших страв за історією замовлень
--most popular items by order history
SELECT i.name AS item_name, SUM(oi.quantity) AS total_sold,
  SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
    JOIN items i ON oi.item_id=i.id
    JOIN orders o ON oi.order_id=o.id
WHERE o.status = 'ready'
GROUP BY i.name
ORDER BY total_sold DESC
LIMIT 5;

--ОЧИЩЕННЯ ТА КОРЕКЦІЯ ДАНИХ
--DELETE AND UPDATE DATA

--видалення позицій із відкритих замовлень
--delete items from open order
DELETE FROM order_items
WHERE order_id IN
    (SELECT id FROM orders WHERE status IN ('in_process','cancel'));

--видалення позицій із чернеток
--delete items from drafts
DELETE FROM orders
WHERE status IN ('in_process','cancel');
