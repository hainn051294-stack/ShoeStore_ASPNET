# BÁO CÁO TIẾN ĐỘ DỰ ÁN

## SneakerHub - Website bán giày (ASP.NET Core MVC, .NET 8)

---

## 1. Thông tin sinh viên

| Thông tin                | Nội dung            |
| ------------------------ | ------------------- |
| **Họ tên**               | Nguyễn Nam Hải      |
| **MSSV**                 | 170125076           |
| **Lớp**                  | DK25TTG2            |
| **Giảng viên hướng dẫn** | TS. Nguyễn Nhứt Lam |

---

## 2. Tiến độ thực hiện

### Tuần 1: Khởi tạo dự án và thiết kế cơ sở dữ liệu

#### Công việc đã thực hiện

* Tạo project ASP.NET Core MVC (.NET 8) theo mô hình MVC.
* Cài đặt SQL Server (LocalDB) và cấu hình connection string trong `appsettings.json`.
* Thiết kế và khai báo các Model: `Category`, `Product`, `ProductImage`, `CartItem`, `Order`, `OrderDetail`, `ApplicationUser`.
* Tạo `ApplicationDbContext` kế thừa `IdentityDbContext` và cấu hình ASP.NET Core Identity.
* Viết `DbInitializer` tự động tạo database và seed dữ liệu mẫu (2 role, 2 user, 8 danh mục, 18 sản phẩm, 144 ảnh sản phẩm).

#### Kết quả đạt được

* Database `ShopBanGiayDb` được tạo tự động khi chạy lần đầu.
* Dữ liệu mẫu đầy đủ, tài khoản admin và customer hoạt động.

#### Khó khăn

* Lỗi vi phạm khóa ngoại (FK violation) khi seed dữ liệu giỏ hàng cho user chưa tồn tại.
* Chưa phân biệt được `EnsureCreated` và Migration khi tạo database.

#### Hướng giải quyết

* Thêm kiểm tra sự tồn tại của `UserId` trước khi tạo cart, fallback về guest cart.
* Dùng `EnsureCreatedAsync` kết hợp seed tự động trong `DbInitializer` cho phù hợp quy mô đồ án.

---

### Tuần 2: Xây dựng chức năng cơ bản và giao diện

#### Công việc đã thực hiện

* Xây dựng trang chủ với hero banner và danh sách sản phẩm nổi bật.
* Hiển thị danh sách sản phẩm theo danh mục, tìm kiếm và lọc.
* Xây dựng trang chi tiết sản phẩm có gallery ảnh lọc theo màu (`ProductImage.Color`).
* Thêm logo thương hiệu vào trang chủ và mega-menu điều hướng.
* Thiết kế giao diện bằng Bootstrap kết hợp CSS tùy chỉnh.

#### Kết quả đạt được

* Website hiển thị sản phẩm đầy đủ, ảnh sản phẩm load đúng theo màu sắc.
* Giao diện hoàn chỉnh, hiển thị tốt trên máy tính và điện thoại (responsive).

#### Khó khăn

* Ảnh sản phẩm không hiển thị do đường dẫn tĩnh chưa đúng.
* File Razor chứa tiếng Việt bị lỗi mã hóa (ký tự loạn) khi chỉnh sửa nhiều lần.

#### Hướng giải quyết

* Chuẩn hóa thư mục ảnh `wwwroot/images/products/<slug>/<màu>/` và dùng asp-append-version.
* Đảm bảo mọi file lưu ở chuẩn UTF-8 có BOM, chỉnh sửa từng file tuần tự tránh ghi đè.

---

### Tuần 3: Giỏ hàng, đơn hàng, trang quản trị và hoàn thiện

#### Công việc đã thực hiện

* Xây dựng giỏ hàng (thêm, sửa số lượng, xóa) và đặt hàng với mã đơn tự sinh.
* Lưu thông tin đơn hàng và chi tiết đơn hàng (snapshot tên, ảnh, giá tại thời điểm đặt).
* Xây dựng khu vực Admin: quản lý sản phẩm, danh mục, đơn hàng, khách hàng và thống kê doanh thu.
* Phân quyền theo vai trò: Admin quản trị, Customer mua hàng.
* Xuất file SQL khôi phục toàn bộ database (`Database/ShopBanGiay.sql`) và viết README hướng dẫn chạy.
* Hoàn thiện giao diện: banner slider trang chủ tự chạy 4s, gallery chi tiết kiểu Shopee (thumbnails dọc bên trái), menu phân loại giày Nam/Nữ trên thanh điều hướng, logo thương hiệu chỉ hiện hình, nền ảnh sản phẩm hoà vào nền trắng (`mix-blend-mode`).

#### Kết quả đạt được

* Người dùng có thể xem, thêm giỏ hàng, đặt hàng và theo dõi đơn; Admin quản lý được toàn bộ dữ liệu.
* Lọc sản phẩm theo giới tính (11 giày nam / 7 giày nữ) hoạt động đúng, badge Nam/Nữ hiển thị trên card và trang chi tiết.
* Database có thể khôi phục độc lập bằng file SQL trong SSMS.
* Dự án build 0 lỗi, chạy ổn định trên .NET 8.

#### Khó khăn

* Trang thống kê bị lỗi hiển thị số liệu do sai câu truy vấn và lỗi mã hóa file view.
* Dung lượng project quá lớn (khoảng 180 MB) do ảnh gốc và thư viện địa phương.

#### Hướng giải quyết

* Sửa câu truy vấn thống kê và chuẩn hóa encoding file view.
* Nén và chuyển ảnh sang JPG 900px chất lượng 82, loại bỏ thư mục thư viện địa phương, giảm còn khoảng 15 MB.
