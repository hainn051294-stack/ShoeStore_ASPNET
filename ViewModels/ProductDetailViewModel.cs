namespace ShopBangGiay.ViewModels;

public class ProductDetailViewModel
{
    public Models.Product Product { get; set; } = null!;
    public List<Models.Product> RelatedProducts { get; set; } = new();
}
