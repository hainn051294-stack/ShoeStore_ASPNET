using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using ShopBangGiay.Services;

namespace ShopBangGiay.Controllers;

public class CartController : Controller
{
    private readonly ICartService _cartService;

    public CartController(ICartService cartService)
    {
        _cartService = cartService;
    }

    private string? UserId => User.FindFirstValue(ClaimTypes.NameIdentifier);

    public async Task<IActionResult> Index()
    {
        var cart = await _cartService.GetCartAsync(UserId);

        // Bổ sung tên/ảnh sản phẩm cho giỏ session
        if (!User.Identity!.IsAuthenticated)
        {
            await EnrichSessionCartAsync(cart);
        }

        return View(cart);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Add(int productId, int quantity = 1, string? color = null, string? size = null)
    {
        var (success, message, count) = await _cartService.AddAsync(UserId, productId, quantity, color, size);

        if (Request.Headers.ContainsKey("X-Requested-With") && Request.Headers["X-Requested-With"] == "XMLHttpRequest")
            return Json(new { success, message, cartCount = count });

        TempData[success ? "Success" : "Error"] = message;
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Update(int itemId, int quantity)
    {
        await _cartService.UpdateQuantityAsync(UserId, itemId, quantity);
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Remove(int itemId)
    {
        await _cartService.RemoveAsync(UserId, itemId);
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> Count()
    {
        var count = await _cartService.CountAsync(UserId);
        return Json(new { count });
    }

    private async Task EnrichSessionCartAsync(ShopBangGiay.ViewModels.CartViewModel cart)
    {
        var productIds = cart.Items.Select(i => i.ProductId).Distinct().ToList();
        if (productIds.Count == 0) return;

        var db = HttpContext.RequestServices.GetRequiredService<ShopBangGiay.Data.ApplicationDbContext>();
        var products = await db.Products
            .Where(p => productIds.Contains(p.Id))
            .ToDictionaryAsync(p => p.Id);

        foreach (var item in cart.Items)
        {
            if (products.TryGetValue(item.ProductId, out var p))
            {
                if (string.IsNullOrEmpty(item.ProductName)) item.ProductName = p.Name;
                if (string.IsNullOrEmpty(item.ProductImage)) item.ProductImage = p.MainImage;
                item.Stock = p.Stock;
            }
        }
    }
}
