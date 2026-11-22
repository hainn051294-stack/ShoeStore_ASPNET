# SneakerHub — Website bán giày

Đồ án ASP.NET Core MVC (.NET 8) — cửa hàng giày SneakerHub với trang khách hàng và trang quản trị đầy đủ.

- **Sinh viên:** NGUYỄN NAM HẢI — MSSV 170125076
- **Lớp:** DK25TTG2
- **Framework:** ASP.NET Core 8 (MVC) + Entity Framework Core 8 + ASP.NET Core Identity

---

## ⚡ Chạy nhanh (3 bước)

1. **Yêu cầu:** Visual Studio 2022 17.8+ (có .NET 8 SDK). SQL Server LocalDB có sẵn khi cài Visual Studio.
2. Mở **`ShopBanGiay.sln`** → bấm **F5**.
3. Trình duyệt tự mở `http://localhost:5247` — database `ShopBanGiayDb` được **tự tạo + tự seed** lần đầu chạy:

| Dữ liệu tự sinh | Số lượng |
| --- | --- |
| Danh mục | 8 |
| Sản phẩm (+144 ảnh thật trong `wwwroot`) | 18 |
| Tài khoản demo | 2 (admin + khách hàng) |
| Đơn hàng mẫu | 1 |

### Tài khoản demo

| Vai trò | Email | Mật khẩu |
| --- | --- | --- |
| Quản trị | admin@shopgiay.vn | Admin@123 |
| Khách hàng | user@shopgiay.vn | User@123 |

> **Cách chạy thủ công (tuỳ chọn):** nếu muốn nạp DB từ file SQL, chạy
> `sqlcmd -S "(localdb)\MSSQLLocalDB" -E -f 65001 -i Database\ShopBanGiay.sql`
> (bắt buộc `-f 65001` để tiếng Việt không lỗi font). Chi tiết đầy đủ xem [setup/readme.md](setup/readme.md).

---

## 🧭 Các đường dẫn chính

| Trang | Đường dẫn |
| --- | --- |
| Trang chủ | `/` |
| Danh sách sản phẩm | `/Product` |
| Chi tiết sản phẩm | `/Product/{slug}` |
| Giỏ hàng | `/Cart` |
| Đặt hàng | `/Checkout` |
| Đơn hàng của tôi | `/Order` |
| Tài khoản | `/Account/Login`, `/Account/Register`, `/Profile` |
| **Quản trị (role Admin)** | `/Admin/Dashboard`, `/Admin/Products`, `/Admin/Orders`, `/Admin/Customers`, `/Admin/Statistics` |

## ✨ Chức năng chính

**Khách hàng:** tìm kiếm/lọc sản phẩm, xem chi tiết + ảnh + thông số, chọn màu/size rồi thêm vào giỏ hàng (AJAX), đặt hàng, theo dõi đơn, đăng ký/đăng nhập, quản lý hồ sơ.

**Quản trị:** dashboard thống kê, CRUD sản phẩm/danh mục (kèm quản lý ảnh), quản lý đơn hàng (cập nhật trạng thái), quản lý khách hàng, thống kê doanh thu.

## 🗂️ Cấu trúc project

```
ShopBanGiay/
├── Controllers/        # Account, Cart, Checkout, Home, Order, Product, Profile
│   └── Admin/          # Dashboard, Products, Orders, Customers, Statistics
├── Data/               # ApplicationDbContext, DbInitializer (tự tạo + seed DB)
├── Models/             # Product, Category, Cart, Order, OrderDetail, ApplicationUser...
├── Views/              # Razor views (Account, Cart, Checkout, Home, Order, Product, Profile, Admin)
├── wwwroot/            # css, js, lib, images/products (144 ảnh sản phẩm)
├── Database/
│   ├── ShopBanGiay.sql # Script tạo DB + seed toàn bộ (UTF-8, N-prefix đầy đủ)
│   └── diagram.md      # Sơ đồ ERD (Mermaid) theo khóa ngoại thực tế
├── setup/readme.md     # Hướng dẫn kỹ thuật chi tiết
├── soft/readme.md      # Phần mềm cần cài đặt
└── progress-report/    # Báo cáo tiến độ
```

## 🗄️ Database

- 14 bảng: 7 bảng nghiệp vụ (Categories, Products, ProductImages, Carts, CartItems, Orders, OrderDetails) + 7 bảng Identity.
- Connection string (`appsettings.json`): `Server=(localdb)\MSSQLLocalDB;Database=ShopBanGiayDb;Trusted_Connection=True;MultipleActiveResultSets=true`
- DB được tạo tự động lần đầu chạy app (`EnsureCreated` + seed trong `Data/DbInitializer.cs`), không cần Migration và không bắt buộc chạy file SQL.

## 📄 Tài liệu khác

- [setup/readme.md](setup/readme.md) — yêu cầu môi trường, kết nối DB, 2 cách khởi tạo dữ liệu, xử lý lỗi font tiếng Việt.
- [soft/readme.md](soft/readme.md) — phần mềm cần cài trên máy mới.
- [progress-report/progress-report.md](progress-report/progress-report.md) — báo cáo tiến độ theo tuần.
- [Database/diagram.md](Database/diagram.md) — sơ đồ ERD + hướng dẫn tạo Database Diagrams trong SSMS.

---

*Chạy thử đã kiểm chứng: build 0 lỗi / 0 cảnh báo, toàn bộ route chính + luồng giỏ hàng hoạt động, tiếng Việt hiển thị chuẩn.*
