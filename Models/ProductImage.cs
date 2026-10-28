using System.ComponentModel.DataAnnotations;

namespace ShopBangGiay.Models;

public class ProductImage
{
    public int Id { get; set; }

    [Required, StringLength(300)]
    public string Url { get; set; } = string.Empty;

    [StringLength(60)]
    public string? Color { get; set; }

    public int DisplayOrder { get; set; }
    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;
}
