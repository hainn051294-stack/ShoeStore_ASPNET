using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ShopBanGiay.Data;
using ShopBanGiay.Helpers;
using ShopBanGiay.Models;

namespace ShopBanGiay.Areas.Admin.Controllers;

[Area("Admin")]
[Authorize(Roles = "Admin")]
public class OrdersController : Controller
{
    private readonly ApplicationDbContext _db;

    public OrdersController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index(string? q, OrderStatus? status)
    {
        var query = _db.Orders.Include(o => o.User).AsQueryable();

        if (!string.IsNullOrWhiteSpace(q))
            query = query.Where(o => o.OrderCode.Contains(q) || o.ReceiverName.Contains(q) || o.Phone.Contains(q));

        if (status.HasValue)
            query = query.Where(o => o.Status == status.Value);

        var orders = await query
            .OrderByDescending(o => o.CreatedAt)
            .Take(100)
            .ToListAsync();

        ViewBag.StatusFilter = status;
        ViewBag.SearchTerm = q;
        return View(orders);
    }

    public async Task<IActionResult> Details(int id)
    {
        var order = await _db.Orders
            .Include(o => o.User)
            .Include(o => o.Details)
            .ThenInclude(d => d.Product)
            .FirstOrDefaultAsync(o => o.Id == id);

        if (order is null) return NotFound();

        ViewBag.StatusOptions = FormatHelper.StatusOptions(order.Status);
        return View(order);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateStatus(int id, OrderStatus status)
    {
        var order = await _db.Orders.FindAsync(id);
        if (order is null) return NotFound();

        order.Status = status;
        order.UpdatedAt = DateTime.Now;
        await _db.SaveChangesAsync();

        TempData["Success"] = $"Đã cập nhật trạng thái đơn {order.OrderCode}.";
        return RedirectToAction(nameof(Details), new { id });
    }
}
