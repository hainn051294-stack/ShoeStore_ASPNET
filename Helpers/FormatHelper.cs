using System.Globalization;
using ShopBanGiay.Models;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace ShopBanGiay.Helpers;

public static class FormatHelper
{
    private static readonly CultureInfo Vi = CultureInfo.GetCultureInfo("vi-VN");

    public static string Vnd(decimal value) => string.Format(Vi, "{0:N0} ₫", value);

    public static string StatusText(OrderStatus status) => status switch
    {
        OrderStatus.Pending => "Chờ xác nhận",
        OrderStatus.Confirmed => "Đã xác nhận",
        OrderStatus.Shipping => "Đang giao",
        OrderStatus.Completed => "Hoàn thành",
        OrderStatus.Cancelled => "Đã hủy",
        _ => status.ToString()
    };

    public static string StatusClass(OrderStatus status) => status switch
    {
        OrderStatus.Pending => "badge-pending",
        OrderStatus.Confirmed => "badge-confirmed",
        OrderStatus.Shipping => "badge-shipping",
        OrderStatus.Completed => "badge-completed",
        OrderStatus.Cancelled => "badge-cancelled",
        _ => "badge-pending"
    };

    public static IEnumerable<SelectListItem> StatusOptions(OrderStatus? selected = null)
    {
        return Enum.GetValues<OrderStatus>().Select(s => new SelectListItem
        {
            Value = ((int)s).ToString(),
            Text = StatusText(s),
            Selected = selected.HasValue && selected.Value == s
        });
    }
}
