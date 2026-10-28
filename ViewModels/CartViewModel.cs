namespace ShopBangGiay.ViewModels;

public class CartViewModel
{
    public List<CartItemViewModel> Items { get; set; } = new();

    public int Count => Items.Sum(i => i.Quantity);
    public decimal SubTotal => Items.Sum(i => i.Price * i.Quantity);
    public decimal ShippingFee => SubTotal >= 2_000_000 || SubTotal == 0 ? 0 : 30_000;
    public decimal Total => SubTotal + ShippingFee;
    public bool IsEmpty => Items.Count == 0;
}

public class CartItemViewModel
{
    public int ItemId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? ProductImage { get; set; }
    public string? Color { get; set; }
    public string? Size { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public int Stock { get; set; } = 99;

    public decimal LineTotal => Price * Quantity;
}
