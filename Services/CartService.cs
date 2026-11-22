using ShopBanGiay.Data;
using ShopBanGiay.Models;
using ShopBanGiay.ViewModels;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace ShopBanGiay.Services;

public class CartService : ICartService
{
    private const string SessionKey = "GUEST_CART";
    private readonly ApplicationDbContext _db;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CartService(ApplicationDbContext db, IHttpContextAccessor httpContextAccessor)
    {
        _db = db;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<CartViewModel> GetCartAsync(string? userId, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrEmpty(userId))
        {
            var cart = await GetOrCreateDbCartAsync(userId, cancellationToken);
            if (cart is not null)
                return MapDbCart(cart);
        }

        return MapSessionCart(GetSessionItems());
    }

    public async Task<(bool Success, string Message, int CartCount)> AddAsync(
        string? userId, int productId, int quantity, string? color, string? size, CancellationToken cancellationToken = default)
    {
        var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == productId && p.IsActive, cancellationToken);
        if (product is null)
            return (false, "Sản phẩm không tồn tại.", 0);

        if (!product.InStock)
            return (false, "Sản phẩm hiện đang hết hàng.", 0);

        quantity = Math.Max(1, quantity);

        if (!string.IsNullOrEmpty(userId))
        {
            var cart = await GetOrCreateDbCartAsync(userId, cancellationToken);
            if (cart is null)
                return await AddAsync(null, productId, quantity, color, size, cancellationToken);

            var item = cart.Items.FirstOrDefault(i =>
                i.ProductId == productId &&
                (i.Color ?? "") == (color ?? "") &&
                (i.Size ?? "") == (size ?? ""));

            var newQty = (item?.Quantity ?? 0) + quantity;
            if (newQty > product.Stock)
                return (false, $"Chỉ còn {product.Stock} sản phẩm trong kho.", cart.Items.Sum(x => x.Quantity));

            if (item is null)
            {
                cart.Items.Add(new CartItem
                {
                    ProductId = productId,
                    Color = color,
                    Size = size,
                    Quantity = quantity,
                    Price = product.DisplayPrice
                });
            }
            else
            {
                item.Quantity = newQty;
            }

            await _db.SaveChangesAsync(cancellationToken);
            var count = cart.Items.Sum(x => x.Quantity);
            return (true, "Đã thêm vào giỏ hàng.", count);
        }
        else
        {
            var items = GetSessionItems();
            var existing = items.FirstOrDefault(i =>
                i.ProductId == productId &&
                (i.Color ?? "") == (color ?? "") &&
                (i.Size ?? "") == (size ?? ""));

            if (existing is null)
            {
                items.Add(new SessionCartItem
                {
                    ProductId = productId,
                    Color = color,
                    Size = size,
                    Quantity = quantity,
                    Price = product.DisplayPrice,
                    ProductName = product.Name,
                    ProductImage = product.MainImage
                });
            }
            else
            {
                existing.Quantity = Math.Min(existing.Quantity + quantity, product.Stock);
            }

            SaveSessionItems(items);
            return (true, "Đã thêm vào giỏ hàng.", items.Sum(x => x.Quantity));
        }
    }

    public async Task UpdateQuantityAsync(string? userId, int itemId, int quantity, CancellationToken cancellationToken = default)
    {
        quantity = Math.Max(1, quantity);

        if (!string.IsNullOrEmpty(userId))
        {
            var cart = await GetOrCreateDbCartAsync(userId, cancellationToken);
            if (cart is null)
            {
                await UpdateQuantityAsync(null, itemId, quantity, cancellationToken);
                return;
            }
            var item = cart.Items.FirstOrDefault(i => i.Id == itemId);
            if (item is null) return;

            var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId, cancellationToken);
            if (product is not null && quantity > product.Stock)
                quantity = product.Stock;

            item.Quantity = quantity;
            await _db.SaveChangesAsync(cancellationToken);
        }
        else
        {
            var items = GetSessionItems();
            var item = items.FirstOrDefault(i => i.Id == itemId);
            if (item is null) return;

            var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId, cancellationToken);
            if (product is not null && quantity > product.Stock)
                quantity = product.Stock;

            item.Quantity = quantity;
            SaveSessionItems(items);
        }
    }

    public async Task RemoveAsync(string? userId, int itemId, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrEmpty(userId))
        {
            var cart = await GetOrCreateDbCartAsync(userId, cancellationToken);
            if (cart is null)
            {
                await RemoveAsync(null, itemId, cancellationToken);
                return;
            }
            var item = cart.Items.FirstOrDefault(i => i.Id == itemId);
            if (item is not null)
            {
                _db.CartItems.Remove(item);
                await _db.SaveChangesAsync(cancellationToken);
            }
        }
        else
        {
            var items = GetSessionItems();
            var item = items.FirstOrDefault(i => i.Id == itemId);
            if (item is not null)
            {
                items.Remove(item);
                SaveSessionItems(items);
            }
        }
    }

    public async Task ClearAsync(string? userId, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrEmpty(userId))
        {
            var cart = await GetOrCreateDbCartAsync(userId, cancellationToken);
            if (cart is null)
            {
                _httpContextAccessor.HttpContext?.Session.Remove(SessionKey);
                return;
            }
            _db.CartItems.RemoveRange(cart.Items);
            await _db.SaveChangesAsync(cancellationToken);
        }
        else
        {
            _httpContextAccessor.HttpContext?.Session.Remove(SessionKey);
        }
    }

    public async Task<int> CountAsync(string? userId, CancellationToken cancellationToken = default)
    {
        var cart = await GetCartAsync(userId, cancellationToken);
        return cart.Count;
    }

    public async Task MergeSessionCartAsync(string userId, CancellationToken cancellationToken = default)
    {
        var sessionItems = GetSessionItems();
        if (sessionItems.Count == 0) return;

        var cart = await GetOrCreateDbCartAsync(userId, cancellationToken);
        if (cart is null)
        {
            _httpContextAccessor.HttpContext?.Session.Remove(SessionKey);
            return;
        }

        foreach (var s in sessionItems)
        {
            var item = cart.Items.FirstOrDefault(i =>
                i.ProductId == s.ProductId &&
                (i.Color ?? "") == (s.Color ?? "") &&
                (i.Size ?? "") == (s.Size ?? ""));

            if (item is null)
            {
                cart.Items.Add(new CartItem
                {
                    ProductId = s.ProductId,
                    Color = s.Color,
                    Size = s.Size,
                    Quantity = s.Quantity,
                    Price = s.Price
                });
            }
            else
            {
                item.Quantity += s.Quantity;
            }
        }

        await _db.SaveChangesAsync(cancellationToken);
        _httpContextAccessor.HttpContext?.Session.Remove(SessionKey);
    }

    private async Task<Cart?> GetOrCreateDbCartAsync(string userId, CancellationToken cancellationToken)
    {
        // Guard: cookie đăng nhập cũ có thể chứa UserId không còn tồn tại trong DB
        // (vd sau khi re-seed/xóa database). Fallback về guest và dọn cookie cũ.
        var userExists = await _db.Users.AnyAsync(u => u.Id == userId, cancellationToken);
        if (!userExists)
        {
            _httpContextAccessor.HttpContext?.Response.Cookies.Delete(".AspNetCore.Identity.Application");
            return null;
        }

        var cart = await _db.Carts
            .Include(c => c.Items)
            .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(c => c.UserId == userId, cancellationToken);

        if (cart is null)
        {
            cart = new Cart { UserId = userId };
            _db.Carts.Add(cart);
            await _db.SaveChangesAsync(cancellationToken);
        }

        return cart;
    }

    private static CartViewModel MapDbCart(Cart cart)
    {
        var items = cart.Items.Select(i => new CartItemViewModel
        {
            ItemId = i.Id,
            ProductId = i.ProductId,
            ProductName = i.Product?.Name ?? "Sản phẩm",
            ProductImage = i.Product?.MainImage,
            Color = i.Color,
            Size = i.Size,
            Quantity = i.Quantity,
            Price = i.Price,
            Stock = i.Product?.Stock ?? 0
        }).ToList();

        return new CartViewModel { Items = items };
    }

    private static CartViewModel MapSessionCart(List<SessionCartItem> sessionItems)
    {
        var items = sessionItems.Select(i => new CartItemViewModel
        {
            ItemId = i.Id,
            ProductId = i.ProductId,
            ProductName = i.ProductName,
            ProductImage = i.ProductImage,
            Color = i.Color,
            Size = i.Size,
            Quantity = i.Quantity,
            Price = i.Price
        }).ToList();

        return new CartViewModel { Items = items };
    }

    private List<SessionCartItem> GetSessionItems()
    {
        var session = _httpContextAccessor.HttpContext?.Session;
        if (session is null) return new List<SessionCartItem>();

        var json = session.GetString(SessionKey);
        if (string.IsNullOrEmpty(json))
            return new List<SessionCartItem>();

        try
        {
            return JsonSerializer.Deserialize<List<SessionCartItem>>(json) ?? new List<SessionCartItem>();
        }
        catch
        {
            return new List<SessionCartItem>();
        }
    }

    private void SaveSessionItems(List<SessionCartItem> items)
    {
        var session = _httpContextAccessor.HttpContext?.Session;
        if (session is null) return;

        session.SetString(SessionKey, JsonSerializer.Serialize(items));
    }
}

public class SessionCartItem
{
    public int Id { get; set; } = new Random().Next(1, int.MaxValue);
    public int ProductId { get; set; }
    public string? Color { get; set; }
    public string? Size { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? ProductImage { get; set; }
}
