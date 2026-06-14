-- ============================================
--  COFFEE SHOP DATABASE SCHEMA (MSSQL)
-- ============================================

CREATE DATABASE CoffeeShopDB;
GO

USE CoffeeShopDB;
GO

-- ── MENU CATEGORIES ──────────────────────────
CREATE TABLE Categories (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    SortOrder   INT DEFAULT 0,
    IsActive    BIT DEFAULT 1,
    CreatedAt   DATETIME DEFAULT GETDATE()
);

-- ── MENU ITEMS ───────────────────────────────
CREATE TABLE MenuItems (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId  INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
    Name        NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500),
    Price       DECIMAL(10,2) NOT NULL,
    ImageUrl    NVARCHAR(500),
    IsAvailable BIT DEFAULT 1,
    IsFeatured  BIT DEFAULT 0,
    CreatedAt   DATETIME DEFAULT GETDATE()
);

-- ── TEAM MEMBERS ─────────────────────────────
CREATE TABLE TeamMembers (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Name      NVARCHAR(150) NOT NULL,
    Role      NVARCHAR(100),
    Bio       NVARCHAR(500),
    ImageUrl  NVARCHAR(500),
    SortOrder INT DEFAULT 0,
    IsActive  BIT DEFAULT 1
);

-- ── GALLERY ──────────────────────────────────
CREATE TABLE Gallery (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Title     NVARCHAR(150),
    ImageUrl  NVARCHAR(500) NOT NULL,
    Category  NVARCHAR(100),
    SortOrder INT DEFAULT 0,
    IsActive  BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- ── TESTIMONIALS ─────────────────────────────
CREATE TABLE Testimonials (
    Id         INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(150) NOT NULL,
    Review     NVARCHAR(1000) NOT NULL,
    Rating     INT CHECK (Rating BETWEEN 1 AND 5),
    IsApproved BIT DEFAULT 0,
    CreatedAt  DATETIME DEFAULT GETDATE()
);

-- ── CONTACT MESSAGES ─────────────────────────
CREATE TABLE ContactMessages (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Name      NVARCHAR(150) NOT NULL,
    Email     NVARCHAR(200) NOT NULL,
    Phone     NVARCHAR(20),
    Subject   NVARCHAR(255),
    Message   NVARCHAR(2000) NOT NULL,
    IsRead    BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- ── SITE SETTINGS ────────────────────────────
CREATE TABLE SiteSettings (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey  NVARCHAR(100) NOT NULL UNIQUE,
    SettingValue NVARCHAR(MAX),
    UpdatedAt   DATETIME DEFAULT GETDATE()
);

-- ── ADMIN USERS ──────────────────────────────
CREATE TABLE AdminUsers (
    Id           INT IDENTITY(1,1) PRIMARY KEY,
    Username     NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(500) NOT NULL,
    Email        NVARCHAR(200),
    LastLogin    DATETIME,
    CreatedAt    DATETIME DEFAULT GETDATE()
);

-- ── SEED DATA ────────────────────────────────
INSERT INTO Categories (Name, Description, SortOrder) VALUES
('Hot Coffee',   'Freshly brewed hot coffee drinks',   1),
('Cold Coffee',  'Chilled and iced coffee specialties', 2),
('Tea & Others', 'Premium teas and non-coffee drinks',  3),
('Food & Snacks','Pastries, sandwiches and bites',      4);

INSERT INTO MenuItems (CategoryId, Name, Description, Price, IsFeatured) VALUES
(1, 'Espresso',       'Rich double-shot espresso',                     80.00,  1),
(1, 'Cappuccino',     'Espresso with steamed milk foam',               120.00, 1),
(1, 'Café Latte',     'Smooth espresso with creamy milk',              130.00, 0),
(1, 'Flat White',     'Velvety microfoam over double ristretto',       140.00, 0),
(2, 'Cold Brew',      '18-hour slow-steeped cold brew concentrate',    160.00, 1),
(2, 'Iced Latte',     'Espresso over ice with chilled milk',           150.00, 0),
(2, 'Frappuccino',    'Blended iced coffee with whipped cream',        180.00, 1),
(3, 'Masala Chai',    'Spiced Indian tea with ginger & cardamom',      90.00,  0),
(3, 'Matcha Latte',   'Ceremonial grade matcha with oat milk',         170.00, 1),
(4, 'Croissant',      'Buttery golden French croissant',               80.00,  0),
(4, 'Avocado Toast',  'Sourdough with smashed avocado & chilli flakes',160.00, 0);

INSERT INTO TeamMembers (Name, Role, Bio, SortOrder) VALUES
('Arjun Patel',   'Head Barista',      'Certified Q-Grader with 8 years of specialty coffee experience.', 1),
('Meera Shah',    'Café Manager',      'Hospitality expert passionate about creating warm experiences.',  2),
('Rohan Mehta',   'Roast Master',      'Sources single-origin beans directly from farms across India.',  3);

INSERT INTO SiteSettings (SettingKey, SettingValue) VALUES
('cafe_name',    'Brew & Bloom'),
('cafe_address', '12, Paldi Cross Roads, Ahmedabad, Gujarat 380007'),
('cafe_phone',   '+91 98765 43210'),
('cafe_email',   'hello@brewandbloom.in'),
('cafe_hours',   'Mon–Sat: 7:00 AM – 10:00 PM  |  Sun: 8:00 AM – 9:00 PM'),
('cafe_about',   'Born from a love of craft coffee and community, Brew & Bloom opened its doors in 2018 with one simple goal — serve extraordinary coffee in a space that feels like home.');

-- Default admin (password: Admin@123 — change in production!)
INSERT INTO AdminUsers (Username, PasswordHash, Email) VALUES
('admin', 'AQAAAAIAAYagAAAAEJLtfake_bcrypt_hash_replace_this==', 'admin@brewandbloom.in');

GO