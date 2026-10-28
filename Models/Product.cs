using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBangGiay.Models;

public class Product
{
    public int Id { get; set; }

    [Required, StringLength(200)]
    public string Name { get; set; } = string.Empty;

    [Required, StringLength(220)]
    public string Slug { get; set; } = string.Empty;

    [StringLength(400)]
    public string? ShortDescription { get; set; }

    public string? Description { get; set; }
    public string? Specifications { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Price { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal? SalePrice { get; set; }

    public int Stock { get; set; }

    [StringLength(300)]
    public string? MainImage { get; set; }

    [StringLength(200)]
    public string? ColorOptions { get; set; }

    [StringLength(200)]
    public string? SizeOptions { get; set; }

    public bool IsFeatured { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;

    public ICollection<ProductImage> Images { get; set; } = new List<ProductImage>();
    public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
    public ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();

    [NotMapped]
    public decimal DisplayPrice => SalePrice is > 0 and var sale && sale < Price ? sale : Price;

    [NotMapped]
    public bool IsOnSale => SalePrice is > 0 and var sale && sale < Price;

    [NotMapped]
    public bool InStock => Stock > 0;
}
