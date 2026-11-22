using ShopBanGiay.Data;
using ShopBanGiay.Models;
using ShopBanGiay.ViewModels;
using Microsoft.EntityFrameworkCore;

namespace ShopBanGiay.Services;

public class OrderService : IOrderService
{
    private readonly ApplicationDbContext _db;
    private readonly ICartService _cartService;

    public OrderService(ApplicationDbContext db, ICartService cartService)
    {
        _db = db;
        _cartService = cartService;
    }

    public async Task<(bool Success, string Message, Order? Order)> PlaceOrderAsync(
        string userId, CheckoutViewModel input, CancellationToken cancellationToken = default)
    {
        var cart = await _cartService.GetCartAsync(userId, cancellationToken);
        if (cart.IsEmpty)
            return (false, "Giỏ hàng đang trống.", null);

        await using var transaction = await _db.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            foreach (var item in cart.Items)
            {
                var product = await _db.Products.FirstOrDefaultAsync(p => p.Id == item.ProductId, cancellationToken);
                if (product is null || !product.IsActive)
                    return (false, $"Sản phẩm '{item.ProductName}' không còn khả dụng.", null);

                if (product.Stock < item.Quantity)
                    return (false, $"Sản phẩm '{product.Name}' chỉ còn {product.Stock} trong kho.", null);
            }

            var order = new Order
            {
                OrderCode = $"ORD{DateTime.Now:yyyyMMddHHmmss}",
                UserId = userId,
                ReceiverName = input.ReceiverName.Trim(),
                Phone = input.Phone.Trim(),
                Address = input.Address.Trim(),
                Note = input.Note?.Trim(),
                TotalAmount = cart.Total,
                Status = OrderStatus.Pending,
                PaymentMethod = "COD",
                CreatedAt = DateTime.Now
            };

            foreach (var item in cart.Items)
            {
                var product = await _db.Products.FirstAsync(p => p.Id == item.ProductId, cancellationToken);
                product.Stock -= item.Quantity;

                order.Details.Add(new OrderDetail
                {
                    ProductId = product.Id,
                    ProductName = product.Name,
                    ProductImage = product.MainImage,
                    Color = item.Color,
                    Size = item.Size,
                    Quantity = item.Quantity,
                    UnitPrice = item.Price
                });
            }

            _db.Orders.Add(order);
            await _db.SaveChangesAsync(cancellationToken);
            await _cartService.ClearAsync(userId, cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            return (true, "Đặt hàng thành công.", order);
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            return (false, "Không thể tạo đơn hàng. Vui lòng thử lại.", null);
        }
    }
}
