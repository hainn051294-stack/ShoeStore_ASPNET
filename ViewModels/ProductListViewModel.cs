using Microsoft.AspNetCore.Mvc.Rendering;

namespace ShopBangGiay.ViewModels;

public class ProductListViewModel
{
    public List<Models.Product> Products { get; set; } = new();
    public List<Models.Category> Categories { get; set; } = new();

    public string? SearchTerm { get; set; }
    public int? CategoryId { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public string? SortOrder { get; set; }

    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 9;
    public int TotalItems { get; set; }
    public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);
    public bool HasPreviousPage => Page > 1;
    public bool HasNextPage => Page < TotalPages;

    public IEnumerable<SelectListItem> SortOptions => new List<SelectListItem>
    {
        new("Mặc định", ""),
        new("Tên A → Z", "name_asc"),
        new("Tên Z → A", "name_desc"),
        new("Giá thấp → cao", "price_asc"),
        new("Giá cao → thấp", "price_desc"),
        new("Mới nhất", "newest")
    };
}
