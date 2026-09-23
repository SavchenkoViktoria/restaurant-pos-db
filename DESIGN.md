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
* `name`: `VARCHAR(30) NOT NULL`, the name of the store location.
* `address`: `VARCHAR(60) NOT NULL`, the physical address of the branch.
* `phone_number`: `VARCHAR(20) NOT NULL UNIQUE`, contact telephone number of the branch, constrained to be unique.

#### Employees

The `instructors` table includes:

* `id`, which specifies the unique ID for the instructor as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `first_name`, which specifies the instructor's first name as `TEXT`.
* `last_name`, which specifies the instructor's last name as `TEXT`.

All columns in the `instructors` table are required and hence should have the `NOT NULL` constraint applied. No other constraints are necessary.

#### Shifts

The `problems` table includes:

* `id`, which specifies the unique ID for the instructor as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `problem_set`, which is an `INTEGER` specifying the number of the problem set of which the problem is a part. Problem sets are *not* represented separately, given that each is only identified by a number.
* `name`, which is the name of the problem set as `TEXT`.

All columns in the `problems` table are required, and hence should have the `NOT NULL` constraint applied. No other constraints are necessary.

#### Customers

The `submissions` table includes:

* `id`, which specifies the unique ID for the submission as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `student_id`, which is the ID of the student who made the submission as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `students` table to ensure data integrity.
* `problem_id`, which is the ID of the problem which the submission solves as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `problems` table to ensure data integrity.
* `submission_path`, which is the path, relative to the database, at which the submission files are stored. It is assumed that all submissions are uploaded to the same server on which the database file is stored, and that submission files can be accessed by following the relative path from the database. Given that this attribute stores a filepath, not the submission files themselves, it is of type affinity `TEXT`.
* `correctness`, which is the score, as a float from 0 to 1.0, the student received on the assignment. This column is represented with a `NUMERIC` type affinity, which can store either floats or integers.
* `timestamp`, which is the timestamp at which the submission was made.

All columns are required and hence have the `NOT NULL` constraint applied where a `PRIMARY KEY` or `FOREIGN KEY` constraint is not. The `correctness` column has an additional constraint to check if its value is greater than 0 and less than or equal 1, given that this is the valid range for a correctness score. Similar to the student's `started` attribute, the submission `timestamp` attribute defaults to the current timestamp when a new row is inserted.

#### Categories

The `comments` table includes:

* `id`, which specifies the unique ID for the submission as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `instructor_id`, which specifies the ID of the instructor who wrote the comment as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `instructors` table, which ensures that each comment be referenced back to an instructor.
* `submission_id`, which specifies the ID of the submission on which the comment was written as an `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `submissions` table, which ensures each comment belongs to a particular submission.
* `contents`, which contains the contents of the columns as `TEXT`, given that `TEXT` can still store long-form text.

All columns are required and hence have the `NOT NULL` constraint applied where a `PRIMARY KEY` or `FOREIGN KEY` constraint is not.

#### Ingradients

#### Items

#### Tech_cards

#### Inventory

#### Orders

#### Order_items

### Relationships

The below entity relationship diagram describes the relationships among the entities in the database.

![ER Diagram](diagram.png)

As detailed by the diagram:

* One student is capable of making 0 to many submissions. 0, if they have yet to submit any work, and many if they submit to more than one problem (or make more than one submission to any one problem). A submission is made by one and only one student. It is assumed that students will submit individual work (not group work).
* A submission is associated with one and only one problem. At the same time, a problem can have 0 to many submissions: 0 if no students have yet submitted work to that problem, and many if more than one student has submitted work for that problem.
* A comment is associated with one and only one submission, whereas a submission can have 0 to many comments: 0 if an instructor has yet to comment on the submission, and many if an instructor leaves more than one comment on a submission.
* A comment is written by one and only one instructor. At the same time, an instructor can write 0 to many comments: 0 if they have yet to comment on any students' work, and many if they have written more than 1 comment.

## Optimizations

Per the typical queries in `queries.sql`, it is common for users of the database to access all submissions submitted by any particular student. For that reason, indexes are created on the `first_name`, `last_name`, and `github_username` columns to speed the identification of students by those columns.

Similarly, it is also common practice for a user of the database to concerned with viewing all students who submitted work to a particular problem. As such, an index is created on the `name` column in the `problems` table to speed the identification of problems by name.

## Limitations

The current schema assumes individual submissions. Collaborative submissions would require a shift to a many-to-many relationship between students and submissions.
