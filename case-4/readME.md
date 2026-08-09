# TourismWebApp

**WEB-приложение на Delphi 10.2 и IIS для управления туристическими заказами**

## 📋 Описание
Приложение предоставляет REST API и веб-интерфейс для работы с турами, клиентами и заказами. Построено на технологии WebBroker (ISAPI DLL) и использует MS SQL Server в качестве базы данных.

## 🛠 Технологии
- Delphi 10.2 Tokyo
- Microsoft IIS
- MS SQL Server
- FireDAC

## 📁 Структура

TourismWebApp/
├── src/ 	# Исходный код Delphi
├── db/ 	# SQL-скрипт базы данных
├── docs/ 	# Документация
└── README.md


## 🚀 Быстрый старт
1. Выполните скрипт `db/TourismDB.sql` в MS SQL Server.
2. Скомпилируйте проект в Delphi 10.2 (ISAPI DLL).
3. Настройте IIS (см. `docs/DeploymentGuide.md`).
4. Откройте в браузере: `http://localhost/TourismWebApp/TourismWebApp.dll`