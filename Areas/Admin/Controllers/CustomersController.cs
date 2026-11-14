using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ShopBanGiay.Data;

namespace ShopBanGiay.Areas.Admin.Controllers;

[Area("Admin")]
[Authorize(Roles = "Admin")]
public class CustomersController : Controller
{
    private readonly ApplicationDbContext _db;

    public CustomersController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index()
    {
        // loại bỏ Quản Trị Viên khỏi danh sách khách hàng
        var adminIds = await _db.UserRoles
            .Join(_db.Roles.Where(r => r.Name == "Admin"),
                ur => ur.RoleId, r => r.Id,
                (ur, r) => ur.UserId)
            .ToListAsync();

        var customers = await _db.Users
            .Where(u => !adminIds.Contains(u.Id))
            .OrderBy(u => u.FullName)
            .ToListAsync();

        var orderCounts = await _db.Orders
            .GroupBy(o => o.UserId)
            .ToDictionaryAsync(g => g.Key, g => g.Count());

        ViewBag.OrderCounts = orderCounts;
        return View(customers);
    }

    public async Task<IActionResult> Details(string id)
    {
        var user = await _db.Users
            .Include(u => u.Orders)
            .ThenInclude(o => o.Details)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (user is null) return NotFound();

        // không cho xem chi tiết tài khoản quản trị từ mục khách hàng
        var isAdmin = await _db.UserRoles
            .Join(_db.Roles.Where(r => r.Name == "Admin"),
                ur => ur.RoleId, r => r.Id,
                (ur, r) => ur.UserId)
            .AnyAsync(uid => uid == user.Id);

        if (isAdmin) return NotFound();
        return View(user);
    }
}
