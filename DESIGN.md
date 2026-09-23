# Design Document

By Viktoriya Savchenko. GitHub SavchenkoViktoria

Video overview:

## Scope

## Scope

The BistroBase database (conceptually named BistroBase, with the database itself named `restaurant`) was designed to automate point-of-sale (POS) and inventory workflows for a multi-location restaurant or retail business. This includes processing retail orders at POS terminals and tracking ingredient consumption in real time across separate branches.

Included in the database's scope are:

* **Stores**, representing individual physical branches or locations across the chain
* **Employees**, including basic identifying details and staff roles
* **Shifts**, capturing cashier working sessions, opening and closing timestamps, and cash drawer balances
* **Customers**, containing contact details and accumulated loyalty reward points
* **Categories and Items**, defining the retail menu, selling prices, and active catalog statuses
* **Ingredients and Tech Cards**, establishing recipes (bills of materials) and unit cost prices
* **Inventory**, recording live on-hand stock levels of raw materials across each store
* **Orders and Order Items**, logging completed or in-progress purchases, line-item quantities, snapshot prices, and payment methods

Out of scope are supplier purchase orders and invoices, table reservation layouts, employee payroll tracking, and multi-tier promotional discount engines.
----------------------------------------------------------------------------------
База даних BistroBase(концептуальна назва, назва самої БазиДаних - restaurant) була створена для автоматизації касово-складських процесів ресторану/магазину з декількома локаціями. Автоматизація включає в себе: обробки роздрібних замовлень на терміналах точок продажу (POS) та автоматичного відстеження витрати запасів.
До складу бази даних входять:

* Заклади, що являють собою окремі фізичні локації/філії мережі

* Співробітники, включаючи ідентифікаційну інформацію та посади

* Зміни, що фіксують робочі години касирів, час відкриття/закриття та залишки в касових ящиках

* Клієнти з їх контактними даними та можлтвість збереження бонусів для програми лояльності

* Категорії та товари, які формують роздрібне меню, ціни продажу та статуси активних позицій у каталозі

* Інгредієнти та технологічні карти, що визначають рецепти та собівартість одиниці продукції

* Запаси, що фіксують актуальні фізичні запаси сировини в окремих магазинах

* Замовлення та позиції замовлень, що фіксують виконані або поточні покупки клієнтів, кількості за позиціями, ціни за одиницю та способи оплати

За межами сфери застосування залишаються замовлення на закупівлю/рахунки-фактури постачальників, схеми бронювання столиків, облік заробітної плати співробітників та багаторівневі механізми надання акційних знижок.

## Functional Requirements

This database will support:

* **CRUD Operations**: Comprehensive creation, retrieval, updating, and deletion (where applicable) across core entities, including store branches, catalog menu items, recipe tech cards, raw ingredients, employee records, and customer loyalty profiles.
* **Shift Lifecycle Management**: Handling operational shifts per location by logging opening and closing timestamps, assigning responsible employees, and reconciling opening and closing cash balances.
* **Order Processing & Snapshot Pricing**: Registering customer orders tied to an active shift and an optional loyalty customer, capturing historical line-item unit prices and quantities at the time of purchase.
* **Order Status Transitions**: Managing the order lifecycle across predefined statuses (`in_process`, `ready`, `cancel`).
* **Automated Real-Time Stock Deduction**: Automatically calculating and subtracting ingredient quantities from the corresponding store's inventory whenever items are ordered, based on tech card specifications.
* **Automated Order Cancellation Reversal**: Automatically returning recipe ingredients to local store inventory if an order status is updated to `cancel`.
* **Out-of-Stock Filtering (Dynamic Stop-List)**: Dynamically exposing an available menu view for point-of-sale terminals that excludes items disabled by administrators or missing required ingredient stocks.
* **Business Analytics & Reporting**: Providing live analytical views to monitor raw material balances, calculate food costs and gross profit margins per dish, and generate end-of-shift Z-reports (total revenue, order counts, average and maximum check values).

Note that in this iteration:
* **Procurement Lifecycle**: Full supply-chain flows (supplier purchase orders, incoming delivery invoices, and batch-level FIFO/FEFO expiration tracking) are not supported.
* **Table Reservations & Floor Plans**: Seating arrangements and table booking mechanisms are out of scope.
* **Accounting & Payroll**: General restaurant accounting, tax compliance calculations, and staff wage tracking are excluded.
* **Promotional Discount Engines**: Multi-tier loyalty discounting or complex coupon rules are not modeled; customer profiles currently track accumulated points only.
----------------------------------------------------------------------------------
Ця база даних забезпечує виконання таких операцій та процесів:

* **Базові операції з даними (CRUD):** Повне керування (створення, перегляд, оновлення та видалення за потреби) основними сутностями системи — філіями закладів, категоріями меню, готовими стравами, технологічними картами (рецептурами), сировиною/інгредієнтами, анкетами співробітників та профілями постійних клієнтів.
* **Керування змінами:** Фіксація робочого циклу касових змін для кожної точки — збереження часу відкриття й закриття зміни, закріплення відповідального працівника та звірка залишків готівки в касовому ящику на початок і кінець дня.
* **Обробка замовлень та фіксація цін:** Оформлення чеків із прив'язкою до активної зміни та зареєстрованого клієнта (за наявності), а також збереження історичної ціни продажу й кількості кожної позиції безпосередньо на момент покупки.
* **Керування життєвим циклом чека:** Зміна та контроль статусів замовлення (`in_process`, `ready`, `cancel`).
* **Автоматичне списання інгредієнтів у реальному часі:** Розрахунок та списання сировини зі складу відповідного закладу на основі техкарт одразу після додавання страв до чека.
* **Автоматичне повернення сировини при скасуванні:** Відновлення списаних залишків інгредієнтів на складі точки, якщо статус замовлення змінюється на `cancel`.
* **Динамічний стоп-лист (меню для касирів):** Формування актуального списку доступних страв для термінала, який автоматично виключає вимкнені адміністратором позиції або страви, для яких не вистачає інгредієнтів на складі.
* **Бізнес-аналітика та звітність:** Надання даних у реальному часі щодо залишків на складі, розрахунку собівартості сировини (food cost) і маржинальності кожної страви, а також формування підсумкових Z-звітів за зміною (загальна виручка, кількість чеків, середній та максимальний чек).

Обмеження та винятки поточної версії:
* **Повний цикл складських закупівель:** Взаємодія з постачальниками (замовлення на закупівлю, вхідні накладні та партії сировини з обліком термінів придатності за FIFO/FEFO) наразі не підтримується.
* **Бронювання місць і карта залу:** Схеми посадкових місць та бронювання столиків не входять до меж проєкту.
* **Бухгалтерський облік та зарплата:** Загальний фінансовий облік підприємства, сплата податків і нарахування заробітної плати працівникам перебувають за межами цієї системи.
* **Багаторівневі системи знижок:** Складні маркетингові акції, купони та градація знижок не реалізовані; програма лояльності на цьому етапі фіксує баланс бонусних балів клієнта.

## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities:

#### Stores

The `stores` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each store location using an auto-incrementing integer.
* `name`: `VARCHAR(30) NOT NULL`, the name of the store location, can`t be NULL, containts 30 symbols.
* `address`: `VARCHAR(60) NOT NULL`, the physical address of the branch, can`t be NULL, containts 60 symbols.
* `phone_number`: `VARCHAR(20) NOT NULL UNIQUE`, contact telephone number of the branch, constrained to be unique, can`t be NULL, containts 20 symbols.

#### Employees

The `employees` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each employee.
* `store_id`: `INT NOT NULL`, foreign key referencing `stores(id)` with `ON DELETE CASCADE`.
* `first_name`: `VARCHAR(30) NOT NULL`, employee's first name, containts 30 symbols.
* `last_name`: `VARCHAR(30) NOT NULL`, employee's last name, containts 30 symbols.
* `role`: `employee_role NOT NULL`, custom ENUM type (`'cashier'`, `'waiter'`, `'cook'`, `'manager'`, `'admin'`).
* `pincode`: `VARCHAR(4) NOT NULL`, short numeric code used by employees for POS terminal authorization, containts 4 symbols.
* `UNIQUE (store_id, pincode)`: ensures PIN codes are unique within the same branch while allowing identical PINs across different branches.

All columns in the `employees` table are required and hence should have the `NOT NULL` constraint applied.

#### Shifts

The `shifts` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each shift.
* `store_id`: `INT NOT NULL`, foreign key referencing `stores(id)` with `ON DELETE CASCADE`.
* `employee_id`: `INT NOT NULL`, foreign key referencing `employees(id)` with `ON DELETE CASCADE`.
* `open_at`: `TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`, exact timestamp when the register was opened.
* `close_at`: `TIMESTAMP`, timestamp when the shift concluded; remains `NULL` while the shift is open.
* `starting_cash`: `NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (starting_cash >= 0)`, opening cash drawer float.
* `ending_cash`: `NUMERIC(10, 2) CHECK (ending_cash >= 0)`, reconciled closing cash amount in the drawer.

All columns, except `close_at` in the `shifts` table are required, and hence should have the `NOT NULL` constraint applied. No other constraints are necessary.

#### Customers

The `customers` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each loyalty customer.
* `first_name`: `VARCHAR(30) NOT NULL`, customer's first name.
* `last_name`: `VARCHAR(30) NOT NULL`, customer's last name.
* `phone_number`: `VARCHAR(20) NOT NULL UNIQUE`, unique mobile number used for loyalty profile lookup.
* `points_balance`: `NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (points_balance >= 0)`, accumulated reward points balance.
* `registered_at`: `TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`, date and time of customer enrollment.

#### Categories

The `categories` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each category.
* `name`: `VARCHAR(30) NOT NULL UNIQUE`, distinct category title (e.g., Coffee, Desserts).

#### Ingradients

The `ingradients` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each ingredient.
* `name`: `VARCHAR(30) NOT NULL UNIQUE`, unique raw material title.
* `unit`: `unit_type NOT NULL`, custom ENUM type indicating the unit of measurement (`'g'`, `'ml'`, `'pcs'`).
* `cost_per_unit`: `NUMERIC(10, 2) NOT NULL`, purchasing cost per specified measurement unit.

#### Items

The `items` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each menu item.
* `category_id`: `INT NOT NULL`, foreign key referencing `categories(id)` with `ON DELETE CASCADE`.
* `name`: `VARCHAR(30) NOT NULL UNIQUE`, unique dish or beverage title.
* `cost`: `NUMERIC(10, 2) NOT NULL`, retail selling price.
* `is_active`: `BOOLEAN NOT NULL DEFAULT TRUE`, soft-deletion/visibility flag indicating whether the item is active on the menu.

#### Tech_cards

The `tech_cards` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each recipe ingredient entry.
* `item_id`: `INT NOT NULL`, foreign key referencing `items(id)` with `ON DELETE CASCADE`.
* `ingradient_id`: `INT NOT NULL`, foreign key referencing `ingradients(id)` with `ON DELETE CASCADE`.
* `quantity`: `NUMERIC(5, 2) NOT NULL`, ingredient proportion needed to prepare one unit of the dish.
* `UNIQUE (item_id, ingradient_id)`: guarantees each ingredient is specified only once per menu item.

#### Inventory

The `inventory` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each inventory record.
* `store_id`: `INT NOT NULL`, foreign key referencing `stores(id)` with `ON DELETE CASCADE`.
* `ingradient_id`: `INT NOT NULL`, foreign key referencing `ingradients(id)` with `ON DELETE CASCADE`.
* `current_stock`: `NUMERIC(10, 2) NOT NULL`, the actual remaining physical balance in stock.
* `UNIQUE (store_id, ingradient_id)`: prevents duplicate balance rows for the same ingredient at the same store branch.

#### Orders

The `orders` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each order.
* `shift_id`: `INT`, foreign key referencing `shifts(id)` with `ON DELETE CASCADE`.
* `customer_id`: `INT`, foreign key referencing `customers(id)` with `ON DELETE SET NULL`, preserving order history if a customer account is removed.
* `created_at`: `TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`, exact order placement time.
* `status`: `order_status NOT NULL`, custom ENUM status (`'in_process'`, `'ready'`, `'cancel'`).
* `payment_method`: `payment_type`, custom ENUM method (`'cash'`, `'card'`), nullable to support unpaid in-process orders.
* `total_amount`: `NUMERIC(10, 2) NOT NULL`, total monetary amount of the order.

#### Order_items

The `order_items` table includes:

* `id`: `SERIAL PRIMARY KEY`, uniquely identifies each line item.
* `order_id`: `INT`, foreign key referencing `orders(id)` with `ON DELETE CASCADE`.
* `item_id`: `INT`, foreign key referencing `items(id)` with `ON DELETE CASCADE`.
* `quantity`: `NUMERIC(5, 2) NOT NULL`, number of portions purchased.
* `unit_price`: `NUMERIC(10, 2) NOT NULL`, selling price per unit at the time of purchase, preserving historical sales revenue against future item price updates.

### Relationships

The below entity relationship diagram describes the relationships among the entities in the database.

![ER Diagram](diagram.png)

As detailed by the diagram:

* Stores to Employees (1 to Many): Each store employs multiple staff members, but each employee belongs to exactly one branch (stores.id = employees.store_id).

* Stores to Shifts (1 to Many): A store hosts multiple work shifts over time, but every shift belongs strictly to one store (stores.id = shifts.store_id).

* Employees to Shifts (1 to Many): An employee can operate multiple shifts over time, while each shift is assigned to one responsible employee (employees.id = shifts.employee_id).

* Shifts to Orders (1 to Many): A single shift contains multiple processed customer orders, but each order belongs to one shift (shifts.id = orders.shift_id).

* Customers to Orders (1 to Many, Optional): A customer can make multiple purchases over time. An order can exist without an associated customer (customer_id IS NULL) for anonymous walk-in sales.

* Orders to Order Items (1 to Many): Each order contains one or more line items (orders.id = order_items.order_id), and each line item belongs to one parent order.

* Categories to Items (1 to Many): A category contains multiple menu items, but each item belongs to one category (categories.id = items.category_id).

* Items to Ingredients (Many to Many): Resolved via the tech_cards junction table (tech_cards.item_id and tech_cards.ingradient_id). One item requires multiple raw ingredients, and one raw material is reused across multiple item recipes.

* Stores to Ingredients (Many to Many): Resolved via the inventory junction table (inventory.store_id and inventory.ingradient_id), tracking localized ingredient balances for each individual store location.

## Optimizations

Per the typical queries in `queries.sql`, it is common for users of the database to access all submissions submitted by any particular student. For that reason, indexes are created on the `first_name`, `last_name`, and `github_username` columns to speed the identification of students by those columns.

Similarly, it is also common practice for a user of the database to concerned with viewing all students who submitted work to a particular problem. As such, an index is created on the `name` column in the `problems` table to speed the identification of problems by name.

## Limitations

The current schema assumes individual submissions. Collaborative submissions would require a shift to a many-to-many relationship between students and submissions.
