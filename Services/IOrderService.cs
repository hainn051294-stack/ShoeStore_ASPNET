namespace ShopBanGiay.Services;

public interface IOrderService
{
    Task<(bool Success, string Message, Models.Order? Order)> PlaceOrderAsync(string userId, ViewModels.CheckoutViewModel input, CancellationToken cancellationToken = default);
}
