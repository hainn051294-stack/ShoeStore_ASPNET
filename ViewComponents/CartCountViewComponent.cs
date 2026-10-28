using System.Security.Claims;
using ShopBangGiay.Services;
using Microsoft.AspNetCore.Mvc;

namespace ShopBangGiay.ViewComponents;

public class CartCountViewComponent : ViewComponent
{
    private readonly ICartService _cartService;

    public CartCountViewComponent(ICartService cartService)
    {
        _cartService = cartService;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var userId = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        var count = await _cartService.CountAsync(userId);
        return View(count);
    }
}
