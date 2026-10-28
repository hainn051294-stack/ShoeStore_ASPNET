using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBangGiay.Models;

public class OrderDetail
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }

    [Required, StringLength(200)]
    public string ProductName { get; set; } = string.Empty;

    [StringLength(300)]
    public string? ProductImage { get; set; }

    [StringLength(50)]
    public string? Color { get; set; }

    [StringLength(10)]
    public string? Size { get; set; }

    public int Quantity { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal UnitPrice { get; set; }

    public Order Order { get; set; } = null!;
    public Product Product { get; set; } = null!;

    [NotMapped]
    public decimal LineTotal => UnitPrice * Quantity;
}
