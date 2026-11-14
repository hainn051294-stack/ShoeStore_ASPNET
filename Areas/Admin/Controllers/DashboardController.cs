using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ShopBanGiay.Data;

namespace ShopBanGiay.Areas.Admin.Controllers;

[Area("Admin")]
[Authorize(Roles = "Admin")]
public class DashboardController : Controller
{
    private readonly ApplicationDbContext _db;

    public DashboardController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index()
    {
        var now = DateTime.Now;
        var sixMonthsAgo = new DateTime(now.Year, now.Month, 1).AddMonths(-5);

        ViewBag.TotalRevenue = await _db.Orders
            .Where(o => o.Status != Models.OrderStatus.Cancelled)
            .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;

        ViewBag.TotalOrders = await _db.Orders.CountAsync();
        ViewBag.PendingOrders = await _db.Orders.CountAsync(o => o.Status == Models.OrderStatus.Pending);
        ViewBag.TotalProducts = await _db.Products.CountAsync();
        ViewBag.TotalCustomers = await _db.Users.CountAsync();

        ViewBag.LowStockProducts = await _db.Products
            .Where(p => p.IsActive && p.Stock <= 10)
            .OrderBy(p => p.Stock)
            .Take(5)
            .ToListAsync();

        ViewBag.RecentOrders = await _db.Orders
            .Include(o => o.User)
            .OrderByDescending(o => o.CreatedAt)
            .Take(5)
            .ToListAsync();

        var labels = new List<string>();
        var data = new List<decimal>();
        for (var i = 5; i >= 0; i--)
        {
            var start = new DateTime(now.Year, now.Month, 1).AddMonths(-i);
            var end = start.AddMonths(1);
            var revenue = await _db.Orders
                .Where(o => o.CreatedAt >= start && o.CreatedAt < end && o.Status != Models.OrderStatus.Cancelled)
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;
            labels.Add($"T{start.Month}");
            data.Add(revenue);
        }

        ViewBag.ChartLabels = labels;
        ViewBag.ChartData = data;

        return View();
    }
}
