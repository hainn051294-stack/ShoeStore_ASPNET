using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ShopBanGiay.Data;
using ShopBanGiay.Helpers;
using ShopBanGiay.Models;

namespace ShopBanGiay.Areas.Admin.Controllers;

[Area("Admin")]
[Authorize(Roles = "Admin")]
public class CategoriesController : Controller
{
    private readonly ApplicationDbContext _db;

    public CategoriesController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index()
    {
        var categories = await _db.Categories
            .Include(c => c.Products)
            .OrderBy(c => c.DisplayOrder)
            .ToListAsync();
        return View(categories);
    }

    [HttpGet]
    public IActionResult Create() => View();

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Category model)
    {
        if (!ModelState.IsValid) return View(model);

        if (await _db.Categories.AnyAsync(c => c.Name == model.Name))
        {
            ModelState.AddModelError("Name", "Tên thương hiệu đã tồn tại.");
            return View(model);
        }

        model.Slug = SlugHelper.ToSlug(model.Name);
        _db.Categories.Add(model);
        await _db.SaveChangesAsync();

        TempData["Success"] = "Thêm thương hiệu thành công.";
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var category = await _db.Categories.FindAsync(id);
        if (category is null) return NotFound();
        return View(category);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, Category model)
    {
        if (id != model.Id) return NotFound();
        if (!ModelState.IsValid) return View(model);

        var category = await _db.Categories.FindAsync(id);
        if (category is null) return NotFound();

        category.Name = model.Name;
        category.Slug = SlugHelper.ToSlug(model.Name);
        category.Description = model.Description;
        category.Icon = model.Icon;
        category.DisplayOrder = model.DisplayOrder;
        category.IsActive = model.IsActive;

        await _db.SaveChangesAsync();

        TempData["Success"] = "Cập nhật thương hiệu thành công.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var category = await _db.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category is null) return NotFound();

        if (category.Products.Count > 0)
        {
            TempData["Error"] = $"Không thể xóa '{category.Name}' vì còn {category.Products.Count} sản phẩm.";
            return RedirectToAction(nameof(Index));
        }

        _db.Categories.Remove(category);
        await _db.SaveChangesAsync();

        TempData["Success"] = "Đã xóa thương hiệu.";
        return RedirectToAction(nameof(Index));
    }
}
