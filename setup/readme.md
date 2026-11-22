# Hướng dẫn kỹ thuật
## SneakerHub - Website bán giày (ASP.NET Core MVC, .NET 8)

## Yêu cầu môi trường

| Công cụ | Ghi chú |
| --- | --- |
| .NET SDK 8.0+ (Visual Studio 2022 17.8+) | `dotnet --version` |
| SQL Server LocalDB | Có sẵn khi cài Visual Studio 2022 |
| sqlcmd hoặc SSMS | Tùy chọn, dùng để chạy file `.sql` |

## Kết nối database

Đã cấu hình sẵn trong `appsettings.json`:

```json
"DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=ShopBanGiayDb;Trusted_Connection=True;MultipleActiveResultSets=true"
```

Trùng đúng với ảnh cấu hình:
- **Server Name**: `(localdb)\MSSQLLocalDB`
- **Authentication**: Windows Authentication
- **Password**: không cần

## Khởi tạo dữ liệu — 2 cách

### Cách 1 — Chỉ cần chạy app (khuyên dùng)

Mở `ShopBanGiay.sln` bằng Visual Studio 2022 và bấm **F5**, hoặc:

```bash
dotnet run
```

`DbInitializer` sẽ tự động:
- Tạo database `ShopBanGiayDb`
- Tạo toàn bộ bảng (7 bảng Identity + 7 bảng nghiệp vụ)
- Nạp 8 danh mục, 18 sản phẩm (có phân loại giới tính Nam/Nữ), 144 ảnh sản phẩm (ảnh thật trong `wwwroot`)
- Tạo tài khoản admin/user mẫu

### Cách 2 — Chạy file `.sql` trước (nếu máy không có LocalDB)

**Lưu ý quan trọng về encoding:** file `.sql` được lưu ở chuẩn **UTF-8**. Khi chạy bằng
`sqlcmd` **bắt buộc phải thêm tham số `-f 65001`** (code page UTF-8), nếu không chữ
tiếng Việt sẽ bị lỗi font (`?`) sau khi nạp vào database.

```bash
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -f 65001 -i Database\ShopBanGiay.sql
dotnet run
```

Hoặc mở `Database\ShopBanGiay.sql` bằng SSMS và bấm **Execute** (SSMS tự nhận UTF-8,
không cần tham số thêm).

> **Nếu đã từng chạy file `.sql` cũ bị lỗi font:** phải xoá database trước rồi chạy lại,
> vì script chỉ `CREATE DATABASE` khi chưa tồn tại và sẽ báo lỗi trùng khóa khi seed đè:
>
> ```bash
> sqlcmd -S "(localdb)\MSSQLLocalDB" -E -Q "IF DB_ID('ShopBanGiayDb') IS NOT NULL DROP DATABASE ShopBanGiayDb"
> ```
>
> Sau đó chạy lại file `.sql` (hoặc đơn giản hơn: chỉ cần xoá DB rồi `dotnet run` —
> ứng dụng sẽ tự tạo database và seed dữ liệu tiếng Việt đúng chuẩn).

File này sẽ tạo database + toàn bộ schema (14 bảng) + dữ liệu seed. Nếu dùng SQL Server thường (không phải LocalDB), sửa connection string trong `appsettings.json` thành:

```json
"DefaultConnection": "Server=localhost;Database=ShopBanGiayDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
```

## Tài khoản demo

| Vai trò | Email | Mật khẩu |
| --- | --- | --- |
| Quản trị | admin@shopgiay.vn | Admin@123 |
| Khách hàng | user@shopgiay.vn | User@123 |

## Đường dẫn chính

- Trang chủ: <http://localhost:5247>
- Sản phẩm: `/Product`
- Chi tiết sản phẩm: `/Product/Details/{id}`
- Về SneakerHub: `/Home/About`
- Liên hệ: `/Home/Contact`
- Giỏ hàng: `/Cart`
- Đặt hàng: `/Checkout`
- Đơn hàng của tôi: `/Order`
- **Quản trị**: `/Admin/Dashboard` (chỉ role Admin)

---

Tài liệu kỹ thuật  
System: SneakerHub
