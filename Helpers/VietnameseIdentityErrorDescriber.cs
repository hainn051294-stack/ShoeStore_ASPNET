using Microsoft.AspNetCore.Identity;

namespace ShopBanGiay.Helpers;

public class VietnameseIdentityErrorDescriber : IdentityErrorDescriber
{
    public override IdentityError PasswordRequiresNonAlphanumeric()
        => new() { Code = "PasswordRequiresNonAlphanumeric", Description = "Mật khẩu phải có ít nhất một ký tự đặc biệt." };

    public override IdentityError PasswordRequiresDigit()
        => new() { Code = "PasswordRequiresDigit", Description = "Mật khẩu phải có ít nhất một chữ số." };

    public override IdentityError PasswordRequiresUpper()
        => new() { Code = "PasswordRequiresUpper", Description = "Mật khẩu phải có ít nhất một chữ cái in hoa." };

    public override IdentityError PasswordRequiresLower()
        => new() { Code = "PasswordRequiresLower", Description = "Mật khẩu phải có ít nhất một chữ cái thường." };

    public override IdentityError PasswordTooShort(int length)
        => new() { Code = "PasswordTooShort", Description = $"Mật khẩu phải có ít nhất {length} ký tự." };

    public override IdentityError DuplicateUserName(string userName)
        => new() { Code = "DuplicateUserName", Description = $"Tên đăng nhập '{userName}' đã tồn tại." };

    public override IdentityError DuplicateEmail(string email)
        => new() { Code = "DuplicateEmail", Description = $"Email '{email}' đã được sử dụng." };

    public override IdentityError InvalidEmail(string? email)
        => new() { Code = "InvalidEmail", Description = "Email không hợp lệ." };

    public override IdentityError PasswordMismatch()
        => new() { Code = "PasswordMismatch", Description = "Mật khẩu không đúng." };
}
