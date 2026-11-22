using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace ShopBanGiay.Helpers;

public static class SlugHelper
{
    public static string ToSlug(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return string.Empty;

        var normalized = text.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder();

        foreach (var c in normalized)
        {
            var category = CharUnicodeInfo.GetUnicodeCategory(c);
            if (category != UnicodeCategory.NonSpacingMark)
                builder.Append(c);
        }

        var slug = builder.ToString().Normalize(NormalizationForm.FormC);
        slug = slug.Replace("đ", "d").Replace("Đ", "d");
        slug = Regex.Replace(slug, @"[^a-z0-9\s-]", string.Empty);
        slug = Regex.Replace(slug, @"\s+", "-");
        slug = Regex.Replace(slug, "-{2,}", "-").Trim('-');
        return slug;
    }
}
