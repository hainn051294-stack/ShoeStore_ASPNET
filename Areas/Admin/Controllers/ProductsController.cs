using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ShopBanGiay.Data;
using ShopBanGiay.Helpers;
using ShopBanGiay.Models;
using Microsoft.AspNetCore.Mvc.Rendering;
using ShopBanGiay.ViewModels;

namespace ShopBanGiay.Areas.Admin.Controllers;

[Area("Admin")]
[Authorize(Roles = "Admin")]
public class ProductsController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IWebHostEnvironment _env;

    public ProductsController(ApplicationDbContext db, IWebHostEnvironment env)
    {
        _db = db;
        _env = env;
    }

    public async Task<IActionResult> Index(string? q, int? categoryId)
    {
        var query = _db.Products.Include(p => p.Category).AsQueryable();

        if (!string.IsNullOrWhiteSpace(q))
            query = query.Where(p => p.Name.Contains(q));

        if (categoryId.HasValue)
            query = query.Where(p => p.CategoryId == categoryId.Value);

        var products = await query
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        var categories = await _db.Categories.OrderBy(c => c.DisplayOrder).ToListAsync();
        ViewBag.Categories = categories;
        ViewBag.SearchTerm = q;
        ViewBag.CategoryFilter = categoryId;

        return View(products);
    }

    [HttpGet]
    public async Task<IActionResult> Create()
    {
        await LoadCategoriesAsync();
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(AdminProductViewModel model)
    {
        if (!ModelState.IsValid)
        {
            await LoadCategoriesAsync();
            return View(model);
        }

        var mainImagePath = await SaveFileAsync(model.MainImageFile) ?? "/images/products/placeholder.svg";

        var product = new Product
        {
            Name = model.Name.Trim(),
            Slug = SlugHelper.ToSlug(model.Name),
            ShortDescription = model.ShortDescription,
            Description = model.Description,
            Specifications = model.Specifications,
            Price = model.Price,
            SalePrice = model.SalePrice,
            Stock = model.Stock,
            MainImage = mainImagePath,
            ColorOptions = model.ColorOptions,
            SizeOptions = model.SizeOptions,
            IsFeatured = model.IsFeatured,
            IsActive = model.IsActive,
            CategoryId = model.CategoryId,
            CreatedAt = DateTime.Now
        };

        _db.Products.Add(product);
        await _db.SaveChangesAsync();

        // Lưu gallery
        if (model.GalleryFiles is { Count: > 0 })
        {
            var order = 1;
            foreach (var file in model.GalleryFiles)
            {
                var path = await SaveFileAsync(file);
                if (path is null) continue;
                _db.ProductImages.Add(new ProductImage { ProductId = product.Id, Url = path, DisplayOrder = order++ });
            }
            await _db.SaveChangesAsync();
        }

        TempData["Success"] = "Thêm sản phẩm thành công.";
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var product = await _db.Products
            .Include(p => p.Images)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (product is null) return NotFound();

        var model = new AdminProductViewModel
        {
            Id = product.Id,
            Name = product.Name,
            ShortDescription = product.ShortDescription,
            Description = product.Description,
            Specifications = product.Specifications,
            Price = product.Price,
            SalePrice = product.SalePrice,
            Stock = product.Stock,
            ColorOptions = product.ColorOptions,
            SizeOptions = product.SizeOptions,
            IsFeatured = product.IsFeatured,
            IsActive = product.IsActive,
            CategoryId = product.CategoryId
        };

        await LoadCategoriesAsync();
        ViewBag.ExistingImages = product.Images.OrderBy(i => i.DisplayOrder).ToList();
        ViewBag.MainImage = product.MainImage;
        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, AdminProductViewModel model)
    {
        if (id != model.Id) return NotFound();
        if (!ModelState.IsValid)
        {
            await LoadCategoriesAsync();
            return View(model);
        }

        var product = await _db.Products
            .Include(p => p.Images)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (product is null) return NotFound();

        product.Name = model.Name.Trim();
        product.Slug = SlugHelper.ToSlug(model.Name);
        product.ShortDescription = model.ShortDescription;
        product.Description = model.Description;
        product.Specifications = model.Specifications;
        product.Price = model.Price;
        product.SalePrice = model.SalePrice;
        product.Stock = model.Stock;
        product.ColorOptions = model.ColorOptions;
        product.SizeOptions = model.SizeOptions;
        product.IsFeatured = model.IsFeatured;
        product.IsActive = model.IsActive;
        product.CategoryId = model.CategoryId;

        var newMainImage = await SaveFileAsync(model.MainImageFile);
        if (newMainImage is not null)
            product.MainImage = newMainImage;

        if (model.GalleryFiles is { Count: > 0 })
        {
            var order = product.Images.Count + 1;
            foreach (var file in model.GalleryFiles)
            {
                var path = await SaveFileAsync(file);
                if (path is null) continue;
                _db.ProductImages.Add(new ProductImage { ProductId = product.Id, Url = path, DisplayOrder = order++ });
            }
        }

        await _db.SaveChangesAsync();
        TempData["Success"] = "Cập nhật sản phẩm thành công.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var product = await _db.Products.FindAsync(id);
        if (product is null) return NotFound();

        try
        {
            _db.Products.Remove(product);
            await _db.SaveChangesAsync();
            TempData["Success"] = "Đã xóa sản phẩm.";
        }
        catch
        {
            // Sản phẩm đã có trong đơn hàng -> chỉ ẩn đi
            product.IsActive = false;
            await _db.SaveChangesAsync();
            TempData["Warning"] = "Sản phẩm đã có đơn hàng nên chỉ được ẩn khỏi website.";
        }

        return RedirectToAction(nameof(Index));
    }

    private async Task LoadCategoriesAsync()
    {
        var categories = await _db.Categories
            .Where(c => c.IsActive)
            .OrderBy(c => c.DisplayOrder)
            .ToListAsync();

        ViewBag.CategoryOptions = new SelectList(categories, "Id", "Name");
    }

    private async Task<string?> SaveFileAsync(IFormFile? file)
    {
        if (file is null || file.Length == 0) return null;

        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(ext)) return null;

        var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads", "products");
        Directory.CreateDirectory(uploadsFolder);

        var fileName = $"{Guid.NewGuid():N}{ext}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        await using var stream = new FileStream(filePath, FileMode.Create);
        await file.CopyToAsync(stream);

        return $"/uploads/products/{fileName}";
    }
}
