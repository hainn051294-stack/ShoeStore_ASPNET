// SneakerHub — site scripts

// Cập nhật badge giỏ hàng khi load trang (dự phòng)
document.addEventListener('DOMContentLoaded', function () {
    const badge = document.getElementById('cartBadge');
    if (!badge || badge.textContent !== '0') return;

    fetch('/Cart/Count')
        .then(r => r.json())
        .then(d => { badge.textContent = d.count; })
        .catch(() => { });
});

// Hiệu ứng reveal on scroll
const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
        if (e.isIntersecting) {
            e.target.style.opacity = '1';
            e.target.style.transform = 'translateY(0)';
        }
    });
}, { threshold: 0.08 });

window.addEventListener('load', () => {
    document.querySelectorAll('.product-card, .brand-card, .stat-card').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(14px)';
        el.style.transition = 'opacity .5s ease, transform .5s ease';
        observer.observe(el);
    });
});

// Định dạng tiền hiển thị nhanh (dùng chung)
function formatVnd(value) {
    return value.toLocaleString('vi-VN') + ' ₫';
}
