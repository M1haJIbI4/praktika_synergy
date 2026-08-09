-- ============================================================
-- База данных: TourismDB
-- Описание: Система управления туристическими заказами
-- ============================================================

-- Создание базы данных (если не существует)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TourismDB')
BEGIN
    CREATE DATABASE TourismDB;
END;
GO

USE TourismDB;
GO

-- 1. Таблица «Страны» (справочник)
CREATE TABLE Countries (
    id_country INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    code CHAR(3) NOT NULL UNIQUE,
    description NVARCHAR(500)
);
GO

-- 2. Таблица «Клиенты» (справочник)
CREATE TABLE Clients (
    id_client INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(150) NOT NULL,
    phone NVARCHAR(20) NOT NULL,
    email NVARCHAR(100) UNIQUE,
    passport NVARCHAR(20) NOT NULL UNIQUE
);
GO

-- 3. Таблица «Туры» (справочник)
CREATE TABLE Tours (
    id_tour INT IDENTITY(1,1) PRIMARY KEY,
    tour_name NVARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    duration_days INT NOT NULL CHECK (duration_days > 0),
    price DECIMAL(10,2) NOT NULL,
    description NVARCHAR(500),
    CONSTRAINT FK_Tours_Countries FOREIGN KEY (country_id)
        REFERENCES Countries(id_country) ON DELETE NO ACTION
);
GO

-- 4. Таблица «Заказы» (переменная информация)
CREATE TABLE Orders (
    id_order INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    tour_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT GETDATE(),
    start_date DATE NOT NULL,
    status NVARCHAR(30) NOT NULL DEFAULT 'Новый',
    total_price DECIMAL(10,2) NOT NULL,
    comment NVARCHAR(500),
    CONSTRAINT FK_Orders_Clients FOREIGN KEY (client_id)
        REFERENCES Clients(id_client) ON DELETE NO ACTION,
    CONSTRAINT FK_Orders_Tours FOREIGN KEY (tour_id)
        REFERENCES Tours(id_tour) ON DELETE NO ACTION
);
GO

-- 5. Заполнение тестовыми данными
INSERT INTO Countries (name, code, description) VALUES
    ('Россия', 'RUS', 'Многообразие климатических зон и культур'),
    ('Турция', 'TUR', 'Средиземное море, песчаные пляжи'),
    ('Италия', 'ITA', 'Колизей, Пицца, романтика'),
    ('Таиланд', 'THA', 'Экзотическая природа, буддийские храмы');
GO

INSERT INTO Clients (full_name, phone, email, passport) VALUES
    ('Иванов Иван Иванович', '+7-916-123-45-67', 'ivan@mail.ru', '4510 123456'),
    ('Петрова Ольга Сергеевна', '+7-985-987-65-43', 'olga@yandex.ru', '4520 789012'),
    ('Сидоров Алексей Викторович', '+7-903-111-22-33', 'alex@google.com', '4530 345678');
GO

INSERT INTO Tours (tour_name, country_id, duration_days, price, description) VALUES
    ('Отдых в Турции', 2, 7, 850.00, 'Отель 5*, all inclusive, песчаный пляж'),
    ('Классическая Италия', 3, 10, 1200.00, 'Рим, Флоренция, Венеция, завтраки включены'),
    ('Тайский экстрим', 4, 14, 1400.00, 'Пхукет, экскурсии, дайвинг, ночные рынки'),
    ('Золотое кольцо России', 1, 5, 400.00, 'Суздаль, Владимир, Ярославль, Ростов Великий');
GO

INSERT INTO Orders (client_id, tour_id, start_date, status, total_price, comment) VALUES
    (1, 1, '2025-07-15', 'Новый', 850.00, 'Хочу номер с видом на море'),
    (2, 2, '2025-09-01', 'Оплачен', 1200.00, ''),
    (3, 3, '2025-12-10', 'Подтверждён', 1400.00, 'Нужен гид-русскоговорящий'),
    (1, 4, '2025-06-20', 'Оплачен', 400.00, '');
GO