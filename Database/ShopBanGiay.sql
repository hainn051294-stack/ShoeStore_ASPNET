-- =====================================================================
-- SneakerHub - Co so du lieu SQL Server
-- Du an: ASPNET-DK25TTG2-NGUYENNAMHAI-shopbangiay (ASP.NET Core MVC, .NET 8)
-- Cach dung: chay toan bo script tren SQL Server / SQL Server LocalDB
--   Server: (localdb)\MSSQLLocalDB   |   Database: ShopBanGiayDb
-- Tai khoan demo:  admin@shopgiay.vn / Admin@123   |   user@shopgiay.vn / User@123
-- =====================================================================

USE master;
GO
IF DB_ID(N'ShopBanGiayDb') IS NULL
    CREATE DATABASE ShopBanGiayDb;
GO
USE ShopBanGiayDb;
GO

-- ===================== BANG IDENTITY =====================
IF OBJECT_ID(N'AspNetRoles') IS NULL
CREATE TABLE AspNetRoles (
    Id NVARCHAR(450) NOT NULL PRIMARY KEY,
    Name NVARCHAR(256) NULL,
    NormalizedName NVARCHAR(256) NULL,
    ConcurrencyStamp NVARCHAR(MAX) NULL
);
GO
IF OBJECT_ID(N'AspNetUsers') IS NULL
CREATE TABLE AspNetUsers (
    Id NVARCHAR(450) NOT NULL PRIMARY KEY,
    UserName NVARCHAR(256) NULL,
    NormalizedUserName NVARCHAR(256) NULL,
    Email NVARCHAR(256) NULL,
    NormalizedEmail NVARCHAR(256) NULL,
    EmailConfirmed BIT NOT NULL DEFAULT 0,
    PasswordHash NVARCHAR(MAX) NULL,
    SecurityStamp NVARCHAR(MAX) NULL,
    ConcurrencyStamp NVARCHAR(MAX) NULL,
    PhoneNumber NVARCHAR(50) NULL,
    PhoneNumberConfirmed BIT NOT NULL DEFAULT 0,
    TwoFactorEnabled BIT NOT NULL DEFAULT 0,
    LockoutEnd DATETIMEOFFSET NULL,
    LockoutEnabled BIT NOT NULL DEFAULT 0,
    AccessFailedCount INT NOT NULL DEFAULT 0,
    FullName NVARCHAR(MAX) NOT NULL,
    Address NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL
);
GO
IF OBJECT_ID(N'AspNetUserRoles') IS NULL
CREATE TABLE AspNetUserRoles (
    UserId NVARCHAR(450) NOT NULL,
    RoleId NVARCHAR(450) NOT NULL,
    PRIMARY KEY (UserId, RoleId),
    CONSTRAINT FK_AspNetUserRoles_AspNetUsers FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE,
    CONSTRAINT FK_AspNetUserRoles_AspNetRoles FOREIGN KEY (RoleId) REFERENCES AspNetRoles(Id) ON DELETE CASCADE
);
GO
IF OBJECT_ID(N'AspNetUserClaims') IS NULL
CREATE TABLE AspNetUserClaims (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    ClaimType NVARCHAR(MAX) NULL,
    ClaimValue NVARCHAR(MAX) NULL,
    CONSTRAINT FK_AspNetUserClaims_AspNetUsers FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);
GO
IF OBJECT_ID(N'AspNetUserLogins') IS NULL
CREATE TABLE AspNetUserLogins (
    LoginProvider NVARCHAR(450) NOT NULL,
    ProviderKey NVARCHAR(450) NOT NULL,
    ProviderDisplayName NVARCHAR(MAX) NULL,
    UserId NVARCHAR(450) NOT NULL,
    PRIMARY KEY (LoginProvider, ProviderKey, UserId),
    CONSTRAINT FK_AspNetUserLogins_AspNetUsers FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);
GO
IF OBJECT_ID(N'AspNetUserTokens') IS NULL
CREATE TABLE AspNetUserTokens (
    UserId NVARCHAR(450) NOT NULL,
    LoginProvider NVARCHAR(450) NOT NULL,
    Name NVARCHAR(450) NOT NULL,
    Value NVARCHAR(MAX) NULL,
    PRIMARY KEY (UserId, LoginProvider, Name),
    CONSTRAINT FK_AspNetUserTokens_AspNetUsers FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);
GO
IF OBJECT_ID(N'AspNetRoleClaims') IS NULL
CREATE TABLE AspNetRoleClaims (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    RoleId NVARCHAR(450) NOT NULL,
    ClaimType NVARCHAR(MAX) NULL,
    ClaimValue NVARCHAR(MAX) NULL,
    CONSTRAINT FK_AspNetRoleClaims_AspNetRoles FOREIGN KEY (RoleId) REFERENCES AspNetRoles(Id) ON DELETE CASCADE
);
GO
-- ===================== BANG NGHIEP VU =====================
IF OBJECT_ID(N'Categories') IS NULL
CREATE TABLE Categories (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Slug NVARCHAR(120) NOT NULL,
    Description NVARCHAR(500) NULL,
    Icon NVARCHAR(80) NULL,
    DisplayOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO
IF OBJECT_ID(N'Products') IS NULL
CREATE TABLE Products (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Slug NVARCHAR(220) NOT NULL,
    ShortDescription NVARCHAR(400) NULL,
    Description NVARCHAR(MAX) NULL,
    Specifications NVARCHAR(MAX) NULL,
    Price DECIMAL(18,2) NOT NULL,
    SalePrice DECIMAL(18,2) NULL,
    Stock INT NOT NULL DEFAULT 0,
    MainImage NVARCHAR(300) NULL,
    ColorOptions NVARCHAR(200) NULL,
    SizeOptions NVARCHAR(200) NULL,
    Gender NVARCHAR(10) NOT NULL DEFAULT N'Nam',
    IsFeatured BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL,
    CategoryId INT NOT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);
GO
IF OBJECT_ID(N'ProductImages') IS NULL
CREATE TABLE ProductImages (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    Url NVARCHAR(300) NOT NULL,
    Color NVARCHAR(60) NULL,
    DisplayOrder INT NOT NULL DEFAULT 0,
    ProductId INT NOT NULL,
    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductId) REFERENCES Products(Id) ON DELETE CASCADE
);
GO
IF OBJECT_ID(N'Carts') IS NULL
CREATE TABLE Carts (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    UserId NVARCHAR(450) NOT NULL,
    CreatedAt DATETIME2 NOT NULL,
    CONSTRAINT FK_Carts_AspNetUsers FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);
GO
IF OBJECT_ID(N'CartItems') IS NULL
CREATE TABLE CartItems (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    CartId INT NOT NULL,
    ProductId INT NOT NULL,
    Color NVARCHAR(50) NULL,
    Size NVARCHAR(10) NULL,
    Quantity INT NOT NULL DEFAULT 0,
    Price DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_CartItems_Carts FOREIGN KEY (CartId) REFERENCES Carts(Id) ON DELETE CASCADE,
    CONSTRAINT FK_CartItems_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
);
GO
IF OBJECT_ID(N'Orders') IS NULL
CREATE TABLE Orders (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    OrderCode NVARCHAR(30) NOT NULL,
    UserId NVARCHAR(450) NOT NULL,
    ReceiverName NVARCHAR(120) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(300) NOT NULL,
    Note NVARCHAR(500) NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    Status INT NOT NULL DEFAULT 0,
    PaymentMethod NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL,
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Orders_AspNetUsers FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id)
);
GO
IF OBJECT_ID(N'OrderDetails') IS NULL
CREATE TABLE OrderDetails (
    Id INT IDENTITY NOT NULL PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    ProductImage NVARCHAR(300) NULL,
    Color NVARCHAR(50) NULL,
    Size NVARCHAR(10) NULL,
    Quantity INT NOT NULL DEFAULT 0,
    UnitPrice DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderId) REFERENCES Orders(Id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
);
GO

-- Chi muc
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Categories_Slug')
    CREATE UNIQUE INDEX IX_Categories_Slug ON Categories(Slug);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Products_Slug')
    CREATE UNIQUE INDEX IX_Products_Slug ON Products(Slug);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Products_Name')
    CREATE INDEX IX_Products_Name ON Products(Name);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_ProductImages_ProductId')
    CREATE INDEX IX_ProductImages_ProductId ON ProductImages(ProductId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Carts_UserId')
    CREATE UNIQUE INDEX IX_Carts_UserId ON Carts(UserId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_CartItems_CartId')
    CREATE INDEX IX_CartItems_CartId ON CartItems(CartId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Orders_OrderCode')
    CREATE UNIQUE INDEX IX_Orders_OrderCode ON Orders(OrderCode);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Orders_UserId')
    CREATE INDEX IX_Orders_UserId ON Orders(UserId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_OrderDetails_OrderId')
    CREATE INDEX IX_OrderDetails_OrderId ON OrderDetails(OrderId);
GO

-- ===================== DU LIEU MAU =====================

-- Vai tro
INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) VALUES (N'0722eebe-b4a6-463f-a40a-ef983d55c398', N'Admin', N'ADMIN', N'');
INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) VALUES (N'54da8b54-00b5-4f25-8d35-41e0528eb203', N'User', N'USER', N'');

-- Nguoi dung (mat khau da ma hoa theo chuan ASP.NET Identity)
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, FullName, Address, CreatedAt) VALUES (N'24e0ff08-329a-4432-9149-e71ee3669453', N'admin@shopgiay.vn', N'ADMIN@SHOPGIAY.VN', N'admin@shopgiay.vn', N'ADMIN@SHOPGIAY.VN', 1, N'AQAAAAIAAYagAAAAEIr/Amryl8IPQkD3aHh75q+aqLgAfh3jFrXLxfHwag+X3WKsdssmfoXcwcp8ZyvRgg==', N'E3RQGC4Q4EDDF6BLJO3QJB4SOR5IPB4Z', N'8eefe814-d90b-47b4-9956-753a401cfe09', N'0901234567', 0, 0, 1, 0, N'Quản Trị Viên', N'273 An Dương Vương, Quận 5, TP. Hồ Chí Minh', N'2026-10-28 13:19:07');
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp, PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled, AccessFailedCount, FullName, Address, CreatedAt) VALUES (N'321de960-ab68-497e-9681-1bb80e53baea', N'user@shopgiay.vn', N'USER@SHOPGIAY.VN', N'user@shopgiay.vn', N'USER@SHOPGIAY.VN', 1, N'AQAAAAIAAYagAAAAENO+N46Wta2VHqF86lLL3nqt4FoxbNCguDHfpBVC025whnSuEEji0nARFvulGznxqg==', N'FIQ6CXD5RXIWQM357BB3HUT7A7WHQRY6', N'3c9e2149-4e41-404e-9cc4-00bf123754e7', N'0901234567', 0, 0, 1, 0, N'Nguyễn Nam Hải', N'273 An Dương Vương, Quận 5, TP. Hồ Chí Minh', N'2026-10-28 13:19:08');

-- Gan vai tro
INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES (N'24e0ff08-329a-4432-9149-e71ee3669453', N'0722eebe-b4a6-463f-a40a-ef983d55c398');
INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES (N'321de960-ab68-497e-9681-1bb80e53baea', N'54da8b54-00b5-4f25-8d35-41e0528eb203');

-- Danh muc (thuong hieu)
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Nike', N'nike', N'Giày thể thao Nike chính hãng', N'bi-lightning-charge', 1, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Adidas', N'adidas', N'Giày thể thao Adidas chính hãng', N'bi-tencent-qq', 2, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Puma', N'puma', N'Giày thể thao Puma chính hãng', N'bi-speedometer', 3, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'New Balance', N'new-balance', N'Giày New Balance chính hãng', N'bi-shuffle', 4, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Vans', N'vans', N'Giày Vans street style', N'bi-skateboard', 5, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Converse', N'converse', N'Giày Converse cổ điển', N'bi-star', 6, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Jordan', N'jordan', N'Air Jordan collection', N'bi-trophy', 7, 1);
INSERT INTO Categories (Name, Slug, Description, Icon, DisplayOrder, IsActive) VALUES (N'Skechers', N'skechers', N'Giày Skechers êm ái', N'bi-cloud-fill', 8, 1);

-- San pham (tham chieu Category qua slug de an toan ID)
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Nike Air Force 1 ''07', N'nike-air-force-1-07', N'Biểu tượng street-wear kinh điển với đế Air êm ái.', N'Biểu tượng street-wear kinh điển với đế Air êm ái. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 3190000.00, 2890000.00, 24, N'/images/products/nike-air-force-1-07-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 1, 1, N'2026-10-28 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'nike'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Nike Air Max 270', N'nike-air-max-270', N'Đệm khí Air Max 270 siêu êm cho vận động cả ngày.', N'Đệm khí Air Max 270 siêu êm cho vận động cả ngày. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 4490000.00, NULL, 15, N'/images/products/nike-air-max-270-black/1.jpg', N'Đen, Hồng', N'36,37,38,39,40,41,42,43', 1, 1, N'2026-10-27 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'nike'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Nike Dunk Low Retro', N'nike-dunk-low-retro', N'Phong cách retro huyền thoại từ sân bóng rổ.', N'Phong cách retro huyền thoại từ sân bóng rổ. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 3690000.00, 3290000.00, 18, N'/images/products/nike-dunk-low-retro-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-26 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'nike'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Adidas Ultraboost 22', N'adidas-ultraboost-22', N'Đệm Boost trả năng vượt trội cho chạy bộ.', N'Đệm Boost trả năng vượt trội cho chạy bộ. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 5190000.00, NULL, 12, N'/images/products/adidas-ultraboost-22-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 1, 1, N'2026-10-25 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'adidas'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Adidas Stan Smith', N'adidas-stan-smith', N'Sneaker da trắng huyền thoại, dễ phối đồ.', N'Sneaker da trắng huyền thoại, dễ phối đồ. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 2590000.00, 2190000.00, 30, N'/images/products/adidas-stan-smith-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-24 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'adidas'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Adidas Samba OG', N'adidas-samba-og', N'Phong cách terraces cổ điển đang làm mưa làm gió.', N'Phong cách terraces cổ điển đang làm mưa làm gió. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 2790000.00, NULL, 20, N'/images/products/adidas-samba-og-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-23 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'adidas'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Puma RS-X Reinvention', N'puma-rs-x-reinvention', N'Chunky sneaker với bộ đệm RS cùng màu bắt mắt.', N'Chunky sneaker với bộ đệm RS cùng màu bắt mắt. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 3290000.00, 2890000.00, 16, N'/images/products/puma-rs-x-reinvention-blue/1.jpg', N'Xanh dương, Đỏ', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-22 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'puma'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Puma Suede Classic XXI', N'puma-suede-classic-xxi', N'Giày da lộn cổ điển từ năm 1968.', N'Giày da lộn cổ điển từ năm 1968. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 2290000.00, NULL, 25, N'/images/products/puma-suede-classic-xxi-black/1.jpg', N'Đen, Xanh dương', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-21 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'puma'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'New Balance 550', N'new-balance-550', N'Sneaker basketball retro hot nhất hiện nay.', N'Sneaker basketball retro hot nhất hiện nay. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 3490000.00, 3090000.00, 14, N'/images/products/new-balance-550-pink/1.jpg', N'Hồng, Trắng', N'36,37,38,39,40,41,42,43', 1, 1, N'2026-10-20 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'new-balance'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'New Balance 990v5', N'new-balance-990v5', N'Cao cấp Made in USA, êm ái đỉnh cao.', N'Cao cấp Made in USA, êm ái đỉnh cao. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 6490000.00, NULL, 8, N'/images/products/new-balance-990v5-black/1.jpg', N'Đen, Xám', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-19 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'new-balance'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Vans Old Skool', N'vans-old-skool', N'Sidebar đường viền nổi biểu tượng của Vans.', N'Sidebar đường viền nổi biểu tượng của Vans. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 1990000.00, 1690000.00, 35, N'/images/products/vans-old-skool-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 1, 1, N'2026-10-18 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'vans'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Vans Sk8-Hi', N'vans-sk8-hi', N'Cổ cao bảo vệ mắt cá, phong cách skate.', N'Cổ cao bảo vệ mắt cá, phong cách skate. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 2190000.00, NULL, 22, N'/images/products/vans-sk8-hi-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-17 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'vans'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Converse Chuck Taylor All Star Classic', N'converse-chuck-taylor-all-star-classic', N'Huyền thoại canvas vượt thời gian.', N'Huyền thoại canvas vượt thời gian. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 1590000.00, 1390000.00, 40, N'/images/products/converse-chuck-taylor-all-star-classic-black/1.jpg', N'Đen, Đỏ', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-16 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'converse'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Converse Run Star Hike', N'converse-run-star-hike', N'Đế lì dày phong cách retro-futurism.', N'Đế lì dày phong cách retro-futurism. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 2790000.00, NULL, 17, N'/images/products/converse-run-star-hike-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-15 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'converse'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Air Jordan 1 Mid', N'air-jordan-1-mid', N'Biểu tượng Jumpman với chất liệu da cao cấp.', N'Biểu tượng Jumpman với chất liệu da cao cấp. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 4990000.00, 4590000.00, 10, N'/images/products/air-jordan-1-mid-black/1.jpg', N'Đen, Đỏ', N'36,37,38,39,40,41,42,43', 1, 1, N'2026-10-14 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'jordan'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Air Jordan 4 Retro', N'air-jordan-4-retro', N'Silhouette huyền thoại thiết kế bởi Tinker Hatfield.', N'Silhouette huyền thoại thiết kế bởi Tinker Hatfield. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 7490000.00, NULL, 6, N'/images/products/air-jordan-4-retro-pink/1.jpg', N'Hồng, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-13 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'jordan'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Skechers D''Lites 4.0', N'skechers-dlites-40', N'Đế Memory Foam siêu êm cho đi lại cả ngày.', N'Đế Memory Foam siêu êm cho đi lại cả ngày. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 2490000.00, 1990000.00, 28, N'/images/products/skechers-dlites-40-black/1.jpg', N'Đen, Trắng', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-12 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'skechers'));
INSERT INTO Products (Name, Slug, ShortDescription, Description, Specifications, Price, SalePrice, Stock, MainImage, ColorOptions, SizeOptions, IsFeatured, IsActive, CreatedAt, CategoryId) VALUES (N'Skechers Summits Quick Getaway', N'skechers-summits-quick-getaway', N'Nhẹ như không, tiện lợi cho mỗi ngày.', N'Nhẹ như không, tiện lợi cho mỗi ngày. Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.', N'Chất liệu: Da tổng hợp / Vải canvas
Đế giày: Cao su chống trượt
Form: Óng chân chuẩn
Xuất xứ: Chính hãng', 1790000.00, NULL, 32, N'/images/products/skechers-summits-quick-getaway-black/1.jpg', N'Đen, Xanh dương', N'36,37,38,39,40,41,42,43', 0, 1, N'2026-10-11 13:19:08', (SELECT Id FROM Categories WHERE Slug = N'skechers'));

-- Phan loai gioi tinh: cap nhat 8 san pham cho nu
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'Adidas Stan Smith';
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'Puma RS-X Reinvention';
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'New Balance 550';
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'Vans Old Skool';
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'Converse Chuck Taylor All Star Classic';
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'Converse Run Star Hike';
UPDATE Products SET Gender = N'Nữ' WHERE Name = N'Air Jordan 4 Retro';

-- Anh san pham (tham chieu Product qua slug)
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-force-1-07-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'nike-air-force-1-07'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-pink/1.jpg', N'Hồng', 5, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-pink/2.jpg', N'Hồng', 6, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-pink/3.jpg', N'Hồng', 7, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-air-max-270-pink/4.jpg', N'Hồng', 8, (SELECT Id FROM Products WHERE Slug = N'nike-air-max-270'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/nike-dunk-low-retro-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'nike-dunk-low-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-ultraboost-22-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'adidas-ultraboost-22'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-stan-smith-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'adidas-stan-smith'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/adidas-samba-og-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'adidas-samba-og'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-blue/1.jpg', N'Xanh dương', 1, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-blue/2.jpg', N'Xanh dương', 2, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-blue/3.jpg', N'Xanh dương', 3, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-blue/4.jpg', N'Xanh dương', 4, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-red/1.jpg', N'Đỏ', 5, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-red/2.jpg', N'Đỏ', 6, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-red/3.jpg', N'Đỏ', 7, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-rs-x-reinvention-red/4.jpg', N'Đỏ', 8, (SELECT Id FROM Products WHERE Slug = N'puma-rs-x-reinvention'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-blue/1.jpg', N'Xanh dương', 5, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-blue/2.jpg', N'Xanh dương', 6, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-blue/3.jpg', N'Xanh dương', 7, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/puma-suede-classic-xxi-blue/4.jpg', N'Xanh dương', 8, (SELECT Id FROM Products WHERE Slug = N'puma-suede-classic-xxi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-pink/1.jpg', N'Hồng', 1, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-pink/2.jpg', N'Hồng', 2, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-pink/3.jpg', N'Hồng', 3, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-pink/4.jpg', N'Hồng', 4, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-550-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'new-balance-550'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-grey/1.jpg', N'Xám', 5, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-grey/2.jpg', N'Xám', 6, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-grey/3.jpg', N'Xám', 7, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/new-balance-990v5-grey/4.jpg', N'Xám', 8, (SELECT Id FROM Products WHERE Slug = N'new-balance-990v5'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-old-skool-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'vans-old-skool'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/vans-sk8-hi-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'vans-sk8-hi'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-red/1.jpg', N'Đỏ', 5, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-red/2.jpg', N'Đỏ', 6, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-red/3.jpg', N'Đỏ', 7, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-chuck-taylor-all-star-classic-red/4.jpg', N'Đỏ', 8, (SELECT Id FROM Products WHERE Slug = N'converse-chuck-taylor-all-star-classic'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/converse-run-star-hike-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'converse-run-star-hike'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-red/1.jpg', N'Đỏ', 5, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-red/2.jpg', N'Đỏ', 6, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-red/3.jpg', N'Đỏ', 7, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-1-mid-red/4.jpg', N'Đỏ', 8, (SELECT Id FROM Products WHERE Slug = N'air-jordan-1-mid'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-pink/1.jpg', N'Hồng', 1, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-pink/2.jpg', N'Hồng', 2, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-pink/3.jpg', N'Hồng', 3, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-pink/4.jpg', N'Hồng', 4, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/air-jordan-4-retro-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'air-jordan-4-retro'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-white/1.jpg', N'Trắng', 5, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-white/2.jpg', N'Trắng', 6, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-white/3.jpg', N'Trắng', 7, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-dlites-40-white/4.jpg', N'Trắng', 8, (SELECT Id FROM Products WHERE Slug = N'skechers-dlites-40'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-black/1.jpg', N'Đen', 1, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-black/2.jpg', N'Đen', 2, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-black/3.jpg', N'Đen', 3, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-black/4.jpg', N'Đen', 4, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-blue/1.jpg', N'Xanh dương', 5, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-blue/2.jpg', N'Xanh dương', 6, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-blue/3.jpg', N'Xanh dương', 7, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
INSERT INTO ProductImages (Url, Color, DisplayOrder, ProductId) VALUES (N'/images/products/skechers-summits-quick-getaway-blue/4.jpg', N'Xanh dương', 8, (SELECT Id FROM Products WHERE Slug = N'skechers-summits-quick-getaway'));
