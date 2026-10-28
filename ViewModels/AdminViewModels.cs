using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace ShopBangGiay.ViewModels;

public class AdminProductViewModel
{
    public int Id { get; set; }

    [Required(ErrorMessage = "Vui lòng nhập tên sản phẩm")]
    [StringLength(200)]
    [Display(Name = "Tên sản phẩm")]
    public string Name { get; set; } = string.Empty;

    [Display(Name = "Mô tả ngắn")]
    [StringLength(400)]
    public string? ShortDescription { get; set; }

    [Display(Name = "Mô tả chi tiết")]
    public string? Description { get; set; }

    [Display(Name = "Thông số kỹ thuật")]
    public string? Specifications { get; set; }

    [Required(ErrorMessage = "Vui lòng nhập giá")]
    [Range(0, 999_999_999, ErrorMessage = "Giá không hợp lệ")]
    [Display(Name = "Giá bán")]
    public decimal Price { get; set; }

    [Range(0, 999_999_999, ErrorMessage = "Giá khuyến mãi không hợp lệ")]
    [Display(Name = "Giá khuyến mãi")]
    public decimal? SalePrice { get; set; }

    [Required(ErrorMessage = "Vui lòng nhập số lượng tồn kho")]
    [Range(0, 100_000)]
    [Display(Name = "Tồn kho")]
    public int Stock { get; set; }

    [Display(Name = "Màu sắc (cách nhau bởi dấu phẩy)")]
    [StringLength(200)]
    public string? ColorOptions { get; set; }

    [Display(Name = "Kích cỡ (cách nhau bởi dấu phẩy)")]
    [StringLength(200)]
    public string? SizeOptions { get; set; }

    [Display(Name = "Sản phẩm nổi bật")]
    public bool IsFeatured { get; set; }

    [Display(Name = "Đang kinh doanh")]
    public bool IsActive { get; set; } = true;

    [Required(ErrorMessage = "Vui lòng chọn thương hiệu")]
    [Display(Name = "Thương hiệu")]
    public int CategoryId { get; set; }

    [Display(Name = "Ảnh chính")]
    public IFormFile? MainImageFile { get; set; }

    [Display(Name = "Ảnh gallery")]
    public List<IFormFile>? GalleryFiles { get; set; }

    public List<SelectListItem> CategoryOptions { get; set; } = new();
}
