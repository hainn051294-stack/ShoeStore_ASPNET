using ShopBanGiay.Data;
using ShopBanGiay.Helpers;
using ShopBanGiay.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace ShopBanGiay.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

        await db.Database.EnsureCreatedAsync();

        await EnsureRoleAsync(roleManager, "Admin");
        await EnsureRoleAsync(roleManager, "User");

        await EnsureUserAsync(userManager, "admin@shopgiay.vn", "Admin@123", "Quản Trị Viên", "Admin");
        var user = await EnsureUserAsync(userManager, "user@shopgiay.vn", "User@123", "Nguyễn Nam Hải", "User");

        if (await db.Products.AnyAsync()) return;

        await SeedCategoriesAsync(db);
        await SeedProductsAsync(db);
        await SeedDemoOrderAsync(db, user);
    }

    private static async Task EnsureRoleAsync(RoleManager<IdentityRole> roleManager, string name)
    {
        if (!await roleManager.RoleExistsAsync(name))
            await roleManager.CreateAsync(new IdentityRole(name));
    }

    private static async Task<ApplicationUser> EnsureUserAsync(
        UserManager<ApplicationUser> userManager, string email, string password, string fullName, string role)
    {
        var existing = await userManager.FindByEmailAsync(email);
        if (existing is not null) return existing;

        var user = new ApplicationUser
        {
            UserName = email,
            Email = email,
            FullName = fullName,
            PhoneNumber = "0901234567",
            Address = "273 An Dương Vương, Quận 5, TP. Hồ Chí Minh",
            EmailConfirmed = true,
            CreatedAt = DateTime.Now
        };

        await userManager.CreateAsync(user, password);
        await userManager.AddToRoleAsync(user, role);
        return user;
    }

    private static async Task SeedCategoriesAsync(ApplicationDbContext db)
    {
        var categories = new List<Category>
        {
            new() { Name = "Nike", Slug = "nike", Icon = "bi-lightning-charge", Description = "Giày thể thao Nike chính hãng", DisplayOrder = 1 },
            new() { Name = "Adidas", Slug = "adidas", Icon = "bi-tencent-qq", Description = "Giày thể thao Adidas chính hãng", DisplayOrder = 2 },
            new() { Name = "Puma", Slug = "puma", Icon = "bi-speedometer", Description = "Giày thể thao Puma chính hãng", DisplayOrder = 3 },
            new() { Name = "New Balance", Slug = "new-balance", Icon = "bi-shuffle", Description = "Giày New Balance chính hãng", DisplayOrder = 4 },
            new() { Name = "Vans", Slug = "vans", Icon = "bi-skateboard", Description = "Giày Vans street style", DisplayOrder = 5 },
            new() { Name = "Converse", Slug = "converse", Icon = "bi-star", Description = "Giày Converse cổ điển", DisplayOrder = 6 },
            new() { Name = "Jordan", Slug = "jordan", Icon = "bi-trophy", Description = "Air Jordan collection", DisplayOrder = 7 },
            new() { Name = "Skechers", Slug = "skechers", Icon = "bi-cloud-fill", Description = "Giày Skechers êm ái", DisplayOrder = 8 }
        };

        db.Categories.AddRange(categories);
        await db.SaveChangesAsync();
    }

    private static async Task SeedProductsAsync(ApplicationDbContext db)
    {
        var cat = await db.Categories.ToDictionaryAsync(c => c.Slug);
        const string sizes = "36,37,38,39,40,41,42,43";
        var products = new List<Product>();

        void Add(string category, string name, decimal price, decimal? sale, int stock,
            string shortDesc, bool featured, string[] colorLabels, string?[] colorSlugs,
            string? fallbackImage = null, string gender = "Nam")
        {
            var slug = SlugHelper.ToSlug(name);
            var first = colorSlugs.FirstOrDefault(c => c is not null);
            var product = new Product
            {
                Name = name,
                Slug = slug,
                ShortDescription = shortDesc,
                Description = shortDesc + " Được phân phối chính hãng, bảo hành 6 tháng, hỗ trợ đổi trả trong 7 ngày.",
                Specifications = "Chất liệu: Da tổng hợp / Vải canvas\nĐế giày: Cao su chống trượt\nForm: Óng chân chuẩn\nXuất xứ: Chính hãng",
                Price = price,
                SalePrice = sale,
                Stock = stock,
                MainImage = first is null
                    ? $"/images/products/{fallbackImage ?? "placeholder.svg"}"
                    : $"/images/products/{slug}-{first}/1.jpg",
                ColorOptions = string.Join(", ", colorLabels),
                SizeOptions = sizes,
                Gender = gender,
                IsFeatured = featured,
                IsActive = true,
                CreatedAt = DateTime.Now.AddDays(-products.Count),
                CategoryId = cat[category].Id
            };

            var order = 1;
            for (var ci = 0; ci < colorSlugs.Length; ci++)
            {
                var cs = colorSlugs[ci];
                if (cs is null) continue;
                for (var i = 1; i <= 4; i++)
                    product.Images.Add(new ProductImage
                    {
                        Url = $"/images/products/{slug}-{cs}/{i}.jpg",
                        DisplayOrder = order++,
                        Color = ci < colorLabels.Length ? colorLabels[ci] : null
                    });
            }
            if (order == 1 && fallbackImage is not null)
                product.Images.Add(new ProductImage { Url = $"/images/products/{fallbackImage}", DisplayOrder = 1 });

            products.Add(product);
        }

        Add("nike", "Nike Air Force 1 '07", 3_190_000, 2_890_000, 24, "Biểu tượng street-wear kinh điển với đế Air êm ái.", true,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" });
        Add("nike", "Nike Air Max 270", 4_490_000, null, 15, "Đệm khí Air Max 270 siêu êm cho vận động cả ngày.", true,
            new[] { "Đen", "Hồng" }, new[] { "black", "pink" });
        Add("nike", "Nike Dunk Low Retro", 3_690_000, 3_290_000, 18, "Phong cách retro huyền thoại từ sân bóng rổ.", false,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" });
        Add("adidas", "Adidas Ultraboost 22", 5_190_000, null, 12, "Đệm Boost trả năng vượt trội cho chạy bộ.", true,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" });
        Add("adidas", "Adidas Stan Smith", 2_590_000, 2_190_000, 30, "Sneaker da trắng huyền thoại, dễ phối đồ.", false,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" }, gender: "Nữ");
        Add("adidas", "Adidas Samba OG", 2_790_000, null, 20, "Phong cách terraces cổ điển đang làm mưa làm gió.", false,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" });
        Add("puma", "Puma RS-X Reinvention", 3_290_000, 2_890_000, 16, "Chunky sneaker với bộ đệm RS cùng màu bắt mắt.", false,
            new[] { "Xanh dương", "Đỏ" }, new[] { "blue", "red" }, gender: "Nữ");
        Add("puma", "Puma Suede Classic XXI", 2_290_000, null, 25, "Giày da lộn cổ điển từ năm 1968.", false,
            new[] { "Đen", "Xanh dương" }, new[] { "black", "blue" });
        Add("new-balance", "New Balance 550", 3_490_000, 3_090_000, 14, "Sneaker basketball retro hot nhất hiện nay.", true,
            new[] { "Hồng", "Trắng" }, new[] { "pink", "white" }, gender: "Nữ");
        Add("new-balance", "New Balance 990v5", 6_490_000, null, 8, "Cao cấp Made in USA, êm ái đỉnh cao.", false,
            new[] { "Đen", "Xám" }, new[] { "black", "grey" });
        Add("vans", "Vans Old Skool", 1_990_000, 1_690_000, 35, "Sidebar đường viền nổi biểu tượng của Vans.", true,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" }, gender: "Nữ");
        Add("vans", "Vans Sk8-Hi", 2_190_000, null, 22, "Cổ cao bảo vệ mắt cá, phong cách skate.", false,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" });
        Add("converse", "Converse Chuck Taylor All Star Classic", 1_590_000, 1_390_000, 40, "Huyền thoại canvas vượt thời gian.", false,
            new[] { "Đen", "Đỏ" }, new[] { "black", "red" }, gender: "Nữ");
        Add("converse", "Converse Run Star Hike", 2_790_000, null, 17, "Đế lì dày phong cách retro-futurism.", false,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" }, gender: "Nữ");
        Add("jordan", "Air Jordan 1 Mid", 4_990_000, 4_590_000, 10, "Biểu tượng Jumpman với chất liệu da cao cấp.", true,
            new[] { "Đen", "Đỏ" }, new[] { "black", "red" });
        Add("jordan", "Air Jordan 4 Retro", 7_490_000, null, 6, "Silhouette huyền thoại thiết kế bởi Tinker Hatfield.", false,
            new[] { "Hồng", "Trắng" }, new[] { "pink", "white" }, gender: "Nữ");
        Add("skechers", "Skechers D'Lites 4.0", 2_490_000, 1_990_000, 28, "Đế Memory Foam siêu êm cho đi lại cả ngày.", false,
            new[] { "Đen", "Trắng" }, new[] { "black", "white" });
        Add("skechers", "Skechers Summits Quick Getaway", 1_790_000, null, 32, "Nhẹ như không, tiện lợi cho mỗi ngày.", false,
            new[] { "Đen", "Xanh dương" }, new[] { "black", "blue" });

        db.Products.AddRange(products);
        await db.SaveChangesAsync();
    }

    private static async Task SeedDemoOrderAsync(ApplicationDbContext db, ApplicationUser user)
    {
        var products = await db.Products.Take(2).ToListAsync();
        if (products.Count < 2) return;

        var order = new Order
        {
            OrderCode = $"ORD{DateTime.Now:yyyyMMddHHmmss}DEMO",
            UserId = user.Id,
            ReceiverName = user.FullName,
            Phone = user.PhoneNumber ?? "0901234567",
            Address = user.Address ?? "TP. Hồ Chí Minh",
            Status = OrderStatus.Completed,
            PaymentMethod = "COD",
            CreatedAt = DateTime.Now.AddDays(-7)
        };

        foreach (var p in products)
        {
            order.Details.Add(new OrderDetail
            {
                ProductId = p.Id,
                ProductName = p.Name,
                ProductImage = p.MainImage,
                Color = "Đen",
                Size = "41",
                Quantity = 1,
                UnitPrice = p.DisplayPrice
            });
        }

        order.TotalAmount = order.Details.Sum(d => d.UnitPrice * d.Quantity);
        db.Orders.Add(order);
        await db.SaveChangesAsync();
    }
}

