using ShopBanGiay.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ShopBanGiay.ViewComponents;

public class CategoryMenuViewComponent : ViewComponent
{
    private readonly ApplicationDbContext _db;

    public CategoryMenuViewComponent(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IViewComponentResult> InvokeAsync()
    {
        var categories = await _db.Categories
            .Where(c => c.IsActive)
            .OrderBy(c => c.DisplayOrder)
            .ToListAsync();
        return View(categories);
    }
}
