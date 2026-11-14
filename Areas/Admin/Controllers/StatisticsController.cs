using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ShopBanGiay.Data;

namespace ShopBanGiay.Areas.Admin.Controllers;

[Area("Admin")]
[Authorize(Roles = "Admin")]
public class StatisticsController : Controller
{
    private readonly ApplicationDbContext _db;

    public StatisticsController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index()
    {
        var now = DateTime.Now;
        var yearStart = new DateTime(now.Year, 1, 1);

        var orders = await _db.Orders
            .Where(o => o.Status != Models.OrderStatus.Cancelled)
            .ToListAsync();

        ViewBag.TotalRevenue = orders.Sum(o => o.TotalAmount);
        ViewBag.TotalOrders = orders.Count;
        ViewBag.AverageOrder = orders.Count > 0 ? orders.Average(o => o.TotalAmount) : 0;

        // Doanh thu 12 tháng trong năm hiện tại
        var labels = new List<string>();
        var data = new List<decimal>();
        for (var m = 1; m <= 12; m++)
        {
            var start = new DateTime(now.Year, m, 1);
            var end = start.AddMonths(1);
            labels.Add($"T{m}");
            data.Add(orders.Where(o => o.CreatedAt >= start && o.CreatedAt < end).Sum(o => o.TotalAmount));
        }
        ViewBag.ChartLabels = labels;
        ViewBag.ChartData = data;

        // Top bán chạy
        ViewBag.BestSellers = await _db.OrderDetails
            .GroupBy(d => new { d.ProductId, d.ProductName })
            .Select(g => new
            {
                g.Key.ProductId,
                g.Key.ProductName,
                TotalQty = g.Sum(x => x.Quantity),
                TotalRevenue = g.Sum(x => x.UnitPrice * x.Quantity)
            })
            .OrderByDescending(x => x.TotalQty)
            .Take(10)
            .ToListAsync();

        ViewBag.TopBrands = await _db.OrderDetails
            .Include(d => d.Product)
            .ThenInclude(p => p.Category)
            .GroupBy(d => d.Product.Category.Name)
            .Select(g => new
            {
                Brand = g.Key,
                TotalQty = g.Sum(x => x.Quantity)
            })
            .OrderByDescending(x => x.TotalQty)
            .ToListAsync();

        return View();
    }
}
