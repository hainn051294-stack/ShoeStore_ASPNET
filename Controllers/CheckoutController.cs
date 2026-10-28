using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using ShopBangGiay.Services;
using Microsoft.EntityFrameworkCore;
using ShopBangGiay.ViewModels;

namespace ShopBangGiay.Controllers;

[Authorize]
public class CheckoutController : Controller
{
    private readonly IOrderService _orderService;
    private readonly ICartService _cartService;

    public CheckoutController(IOrderService orderService, ICartService cartService)
    {
        _orderService = orderService;
        _cartService = cartService;
    }

    public async Task<IActionResult> Index()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var cart = await _cartService.GetCartAsync(userId);

        if (cart.IsEmpty)
            return RedirectToAction("Index", "Cart");

        var user = await HttpContext.RequestServices
            .GetRequiredService<Microsoft.AspNetCore.Identity.UserManager<Models.ApplicationUser>>()
            .FindByIdAsync(userId);

        var model = new CheckoutViewModel
        {
            ReceiverName = user?.FullName ?? "",
            Phone = user?.PhoneNumber ?? "",
            Address = user?.Address ?? ""
        };

        ViewBag.Cart = cart;
        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Index(CheckoutViewModel model)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var cart = await _cartService.GetCartAsync(userId);

        if (!ModelState.IsValid)
        {
            ViewBag.Cart = cart;
            return View(model);
        }

        var (success, message, order) = await _orderService.PlaceOrderAsync(userId, model);

        if (!success)
        {
            ModelState.AddModelError(string.Empty, message);
            ViewBag.Cart = cart;
            return View(model);
        }

        return RedirectToAction(nameof(Success), new { code = order!.OrderCode });
    }

    public async Task<IActionResult> Success(string code)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var db = HttpContext.RequestServices.GetRequiredService<ShopBangGiay.Data.ApplicationDbContext>();

        var order = await db.Orders
            .Include(o => o.Details)
            .FirstOrDefaultAsync(o => o.OrderCode == code && o.UserId == userId);

        if (order is null)
            return RedirectToAction("Index", "Home");

        return View(order);
    }
}
