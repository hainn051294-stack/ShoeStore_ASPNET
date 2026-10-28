namespace ShopBangGiay.ViewModels;

public class HomeViewModel
{
    public List<Models.Product> FeaturedProducts { get; set; } = new();
    public List<Models.Product> NewestProducts { get; set; } = new();
    public List<Models.Category> Categories { get; set; } = new();
}
