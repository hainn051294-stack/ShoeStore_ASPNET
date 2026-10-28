using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBangGiay.Data;
using ShopBangGiay.Helpers;
using ShopBangGiay.ViewModels;

namespace ShopBangGiay.Controllers;

public class ProductController : Controller
{
    private readonly ApplicationDbContext _db;

    public ProductController(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IActionResult> Index(string? q, int? categoryId, decimal? minPrice,
        decimal? maxPrice, string? sortOrder, int page = 1)
    {
        var pageSize = 9;
        var query = _db.Products
            .Include(p => p.Category)
            .Where(p => p.IsActive)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(q))
            query = query.Where(p => p.Name.Contains(q) || p.ShortDescription!.Contains(q));

        if (categoryId.HasValue)
            query = query.Where(p => p.CategoryId == categoryId.Value);

        if (minPrice.HasValue)
            query = query.Where(p => p.DisplayPrice >= minPrice.Value);

        if (maxPrice.HasValue)
            query = query.Where(p => p.DisplayPrice <= maxPrice.Value);

        query = sortOrder switch
        {
            "name_asc" => query.OrderBy(p => p.Name),
            "name_desc" => query.OrderByDescending(p => p.Name),
            "price_asc" => query.OrderBy(p => p.DisplayPrice),
            "price_desc" => query.OrderByDescending(p => p.DisplayPrice),
            "newest" => query.OrderByDescending(p => p.CreatedAt),
            _ => query.OrderBy(p => p.Name)
        };

        var totalItems = await query.CountAsync();

        var products = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var categories = await _db.Categories
            .Where(c => c.IsActive)
            .OrderBy(c => c.DisplayOrder)
            .ToListAsync();

        var vm = new ProductListViewModel
        {
            Products = products,
            Categories = categories,
            SearchTerm = q,
            CategoryId = categoryId,
            MinPrice = minPrice,
            MaxPrice = maxPrice,
            SortOrder = sortOrder,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalItems
        };

        return View(vm);
    }

    public async Task<IActionResult> Details(string slug)
    {
        if (string.IsNullOrWhiteSpace(slug))
            return NotFound();

        var product = await _db.Products
            .Include(p => p.Category)
            .Include(p => p.Images.OrderBy(i => i.DisplayOrder))
            .FirstOrDefaultAsync(p => p.Slug == slug && p.IsActive);

        if (product is null)
            return NotFound();

        var related = await _db.Products
            .Include(p => p.Category)
            .Where(p => p.CategoryId == product.CategoryId && p.Id != product.Id && p.IsActive)
            .OrderByDescending(p => p.IsFeatured)
            .Take(4)
            .ToListAsync();

        var vm = new ProductDetailViewModel
        {
            Product = product,
            RelatedProducts = related
        };

        return View(vm);
    }
}
