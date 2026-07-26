# =============================================================================
# МОДУЛЬ: tourism_db.py
# ОПИСАНИЕ: Реализация базы данных «Туризм» на Python с SQLite.
#           Содержит функции для создания таблиц, заполнения тестовыми данными
#           и выполнения примеров запросов.
# =============================================================================

import sqlite3
import datetime

# -----------------------------------------------------------------------------
# 1. Функция создания таблиц
# -----------------------------------------------------------------------------
def create_tables(conn: sqlite3.Connection) -> None:
    """
    Создаёт все пять таблиц в базе данных, если они ещё не существуют.
    Используется SQL-синтаксис SQLite.
    """
    cursor = conn.cursor()

    # Таблица «Страны» (справочник)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Countries (
            id_country INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            code TEXT NOT NULL UNIQUE,
            description TEXT
        )
    ''')

    # Таблица «Клиенты» (справочник)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Clients (
            id_client INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT UNIQUE,
            passport TEXT NOT NULL UNIQUE
        )
    ''')

    # Таблица «Услуги» (справочник)
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Services (
            id_service INTEGER PRIMARY KEY AUTOINCREMENT,
            service_name TEXT NOT NULL UNIQUE,
            service_type TEXT NOT NULL,
            base_price REAL NOT NULL DEFAULT 0.0
        )
    ''')

    # Таблица «Туры» (справочник) – ссылается на Countries
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Tours (
            id_tour INTEGER PRIMARY KEY AUTOINCREMENT,
            tour_name TEXT NOT NULL,
            country_id INTEGER NOT NULL,
            duration_days INTEGER NOT NULL CHECK (duration_days > 0),
            price REAL NOT NULL,
            description TEXT,
            FOREIGN KEY (country_id) REFERENCES Countries(id_country) ON DELETE RESTRICT
        )
    ''')

    # Таблица «Заказы» (переменная информация) – ссылается на Clients и Tours
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS Orders (
            id_order INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL,
            tour_id INTEGER NOT NULL,
            order_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- в SQLite используем TEXT для даты
            start_date TEXT NOT NULL,  -- дата в формате ГГГГ-ММ-ДД
            status TEXT NOT NULL DEFAULT 'Новый',
            total_price REAL NOT NULL,
            comment TEXT,
            FOREIGN KEY (client_id) REFERENCES Clients(id_client) ON DELETE RESTRICT,
            FOREIGN KEY (tour_id) REFERENCES Tours(id_tour) ON DELETE RESTRICT
        )
    ''')

    conn.commit()
    print("✅ Таблицы успешно созданы (или уже существовали).")


# -----------------------------------------------------------------------------
# 2. Функции заполнения справочников тестовыми данными
# -----------------------------------------------------------------------------
def insert_countries(conn: sqlite3.Connection) -> None:
    """Добавляет несколько стран, если таблица пуста."""
    cursor = conn.cursor()
    # Проверяем, есть ли уже записи
    cursor.execute("SELECT COUNT(*) FROM Countries")
    if cursor.fetchone()[0] > 0:
        print("⏭️  Страны уже заполнены, пропускаем.")
        return

    countries = [
        ("Россия", "RUS", "Многообразие климатических зон и культур"),
        ("Турция", "TUR", "Средиземное море, песчаные пляжи, исторические города"),
        ("Италия", "ITA", "Колизей, Пицца, мода, романтика"),
        ("Таиланд", "THA", "Экзотическая природа, буддийские храмы, острова"),
        ("Египет", "EGY", "Пирамиды, Красное море, дайвинг")
    ]
    cursor.executemany(
        "INSERT INTO Countries (name, code, description) VALUES (?, ?, ?)",
        countries
    )
    conn.commit()
    print(f"✅ Добавлено {len(countries)} стран.")


def insert_clients(conn: sqlite3.Connection) -> None:
    """Добавляет нескольких клиентов."""
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Clients")
    if cursor.fetchone()[0] > 0:
        print("⏭️  Клиенты уже есть, пропускаем.")
        return

    clients = [
        ("Иванов Иван Иванович", "+7-916-123-45-67", "ivan@mail.ru", "4510 123456"),
        ("Петрова Ольга Сергеевна", "+7-985-987-65-43", "olga@yandex.ru", "4520 789012"),
        ("Сидоров Алексей Викторович", "+7-903-111-22-33", "alex@google.com", "4530 345678")
    ]
    cursor.executemany(
        "INSERT INTO Clients (full_name, phone, email, passport) VALUES (?, ?, ?, ?)",
        clients
    )
    conn.commit()
    print(f"✅ Добавлено {len(clients)} клиентов.")


def insert_services(conn: sqlite3.Connection) -> None:
    """Добавляет типовые услуги."""
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Services")
    if cursor.fetchone()[0] > 0:
        print("⏭️  Услуги уже есть, пропускаем.")
        return

    services = [
        ("Страховка здоровья", "страхование", 25.0),
        ("Страховка багажа", "страхование", 15.0),
        ("Трансфер из аэропорта", "трансфер", 30.0),
        ("Трансфер до отеля", "трансфер", 20.0),
        ("Экскурсия в горы", "экскурсия", 50.0),
        ("Экскурсия по городу", "экскурсия", 35.0)
    ]
    cursor.executemany(
        "INSERT INTO Services (service_name, service_type, base_price) VALUES (?, ?, ?)",
        services
    )
    conn.commit()
    print(f"✅ Добавлено {len(services)} услуг.")


def insert_tours(conn: sqlite3.Connection) -> None:
    """Добавляет туры с привязкой к странам."""
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Tours")
    if cursor.fetchone()[0] > 0:
        print("⏭️  Туры уже есть, пропускаем.")
        return

    # Получаем id стран по их кодам
    cursor.execute("SELECT id_country, code FROM Countries")
    country_codes = {row[1]: row[0] for row in cursor.fetchall()}

    tours_data = [
        ("Отдых в Турции", country_codes["TUR"], 7, 850.0,
         "Отель 5*, all inclusive, песчаный пляж"),
        ("Классическая Италия", country_codes["ITA"], 10, 1200.0,
         "Рим, Флоренция, Венеция, завтраки включены"),
        ("Тайский экстрим", country_codes["THA"], 14, 1400.0,
         "Пхукет, экскурсии, дайвинг, ночные рынки"),
        ("По следам фараонов", country_codes["EGY"], 8, 950.0,
         "Каир, Луксор, круиз по Нилу"),
        ("Золотое кольцо России", country_codes["RUS"], 5, 400.0,
         "Суздаль, Владимир, Ярославль, Ростов Великий")
    ]
    cursor.executemany(
        "INSERT INTO Tours (tour_name, country_id, duration_days, price, description) "
        "VALUES (?, ?, ?, ?, ?)",
        tours_data
    )
    conn.commit()
    print(f"✅ Добавлено {len(tours_data)} туров.")


# -----------------------------------------------------------------------------
# 3. Функция для добавления заказа (демонстрация транзакции)
# -----------------------------------------------------------------------------
def add_order(conn: sqlite3.Connection,
              client_passport: str,
              tour_name: str,
              start_date: str,
              status: str = "Новый",
              comment: str = "") -> int:
    """
    Добавляет новый заказ для указанного клиента и тура.
    Возвращает id созданного заказа.
    Использует транзакцию для обеспечения целостности.
    """
    cursor = conn.cursor()
    try:
        # Начинаем транзакцию
        conn.execute("BEGIN")

        # Получаем id клиента по паспорту
        cursor.execute("SELECT id_client FROM Clients WHERE passport = ?", (client_passport,))
        client_row = cursor.fetchone()
        if not client_row:
            raise ValueError(f"Клиент с паспортом {client_passport} не найден.")
        client_id = client_row[0]

        # Получаем id тура по названию
        cursor.execute("SELECT id_tour, price FROM Tours WHERE tour_name = ?", (tour_name,))
        tour_row = cursor.fetchone()
        if not tour_row:
            raise ValueError(f"Тур '{tour_name}' не найден.")
        tour_id = tour_row[0]
        base_price = tour_row[1]

        # Здесь можно было бы добавить доп. услуги, но для простоты берём базовую цену
        total_price = base_price

        # Вставляем заказ
        cursor.execute('''
            INSERT INTO Orders
                (client_id, tour_id, start_date, status, total_price, comment)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (client_id, tour_id, start_date, status, total_price, comment))

        order_id = cursor.lastrowid
        # Фиксируем транзакцию
        conn.commit()
        print(f"✅ Заказ #{order_id} успешно создан для клиента {client_passport} на тур '{tour_name}'.")
        return order_id

    except Exception as e:
        conn.rollback()
        print(f"❌ Ошибка при создании заказа: {e}")
        raise


# -----------------------------------------------------------------------------
# 4. Функции для выполнения запросов (примеры)
# -----------------------------------------------------------------------------
def show_all_orders(conn: sqlite3.Connection) -> None:
    """Выводит все заказы с деталями (имя клиента, тур, страна, дата)."""
    cursor = conn.cursor()
    query = '''
        SELECT
            o.id_order,
            c.full_name,
            t.tour_name,
            cnt.name AS country,
            o.start_date,
            o.total_price,
            o.status
        FROM Orders o
        JOIN Clients c ON o.client_id = c.id_client
        JOIN Tours t ON o.tour_id = t.id_tour
        JOIN Countries cnt ON t.country_id = cnt.id_country
        ORDER BY o.order_date DESC
    '''
    cursor.execute(query)
    rows = cursor.fetchall()
    if not rows:
        print("📭 Заказов пока нет.")
        return

    print("\n=== СПИСОК ВСЕХ ЗАКАЗОВ ===")
    for row in rows:
        print(f"Заказ #{row[0]} | {row[1]} | {row[2]} ({row[3]}) | "
              f"Старт: {row[4]} | Сумма: {row[5]:.2f} | Статус: {row[6]}")


def popular_countries(conn: sqlite3.Connection) -> None:
    """Выводит страны по популярности (количество заказов)."""
    cursor = conn.cursor()
    query = '''
        SELECT
            cnt.name AS country,
            COUNT(o.id_order) AS order_count
        FROM Orders o
        JOIN Tours t ON o.tour_id = t.id_tour
        JOIN Countries cnt ON t.country_id = cnt.id_country
        GROUP BY cnt.id_country
        ORDER BY order_count DESC
    '''
    cursor.execute(query)
    rows = cursor.fetchall()
    print("\n=== ПОПУЛЯРНОСТЬ СТРАН (по числу заказов) ===")
    for row in rows:
        print(f"{row[0]}: {row[1]} заказов")


def revenue_report(conn: sqlite3.Connection) -> None:
    """Общая выручка по оплаченным заказам."""
    cursor = conn.cursor()
    cursor.execute("SELECT SUM(total_price) FROM Orders WHERE status = 'Оплачен'")
    total = cursor.fetchone()[0]
    if total is None:
        total = 0.0
    print(f"\n💵 Общая выручка по оплаченным заказам: {total:.2f}")


# -----------------------------------------------------------------------------
# 5. Основная функция (запуск демонстрации)
# -----------------------------------------------------------------------------
def main():
    # Подключаемся к базе данных (файл tourism.db)
    conn = sqlite3.connect("tourism.db")
    # Разрешаем работу с внешними ключами (SQLite по умолчанию их отключает)
    conn.execute("PRAGMA foreign_keys = ON")

    # Создаём таблицы
    create_tables(conn)

    # Заполняем справочники (только если они пусты)
    insert_countries(conn)
    insert_clients(conn)
    insert_services(conn)
    insert_tours(conn)

    # Добавляем несколько тестовых заказов (если ещё нет)
    try:
        # Проверяем, есть ли уже заказы
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM Orders")
        if cursor.fetchone()[0] == 0:
            # Создаём заказы с использованием транзакции
            add_order(conn, "4510 123456", "Отдых в Турции", "2025-07-15", "Новый", "Хочу номер с видом на море")
            add_order(conn, "4520 789012", "Классическая Италия", "2025-09-01", "Оплачен", "")
            add_order(conn, "4530 345678", "Тайский экстрим", "2025-12-10", "Подтверждён", "Нужен гид-русскоговорящий")
            # Ещё один заказ для демонстрации
            add_order(conn, "4510 123456", "Золотое кольцо России", "2025-06-20", "Оплачен", "")
        else:
            print("⏭️  Заказы уже есть, пропускаем добавление новых.")
    except Exception as e:
        print(f"⚠️  Не удалось добавить тестовые заказы: {e}")

    # Выполняем примеры запросов
    show_all_orders(conn)
    popular_countries(conn)
    revenue_report(conn)

    # Закрываем соединение
    conn.close()
    print("\n✅ Работа завершена.")


# -----------------------------------------------------------------------------
# Точка входа
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    main()