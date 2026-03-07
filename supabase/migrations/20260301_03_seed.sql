-- 20260301_03_seed.sql
insert into public.roles (code, name)
values
  ('customer', 'Customer'),
  ('admin', 'Administrator'),
  ('manager', 'Manager')
on conflict (code) do nothing;

insert into public.categories (name, slug, sort_order)
values
  ('Dresses', 'dresses', 1),
  ('Shoes', 'shoes', 2),
  ('Watches', 'watches', 3),
  ('Bags', 'bags', 4),
  ('Jewellery', 'jewellery', 5)
on conflict (slug) do nothing;

insert into public.products (category_id, title, slug, price, image_url, stock_qty)
select c.id, p.title, p.slug, p.price, p.image_url, p.stock_qty
from (
  values
    ('watches', 'Girl''s Watch', 'girls-watch', 15.00, 'assets/images/w3.jpeg', 100),
    ('dresses', 'Blue Long Shirt', 'blue-long-shirt', 20.00, 'assets/images/5555.jpg', 100),
    ('dresses', 'Black Modern Suit', 'black-modern-suit', 22.00, 'assets/images/westerndress.jpg', 100),
    ('dresses', 'Dull Gold Suit', 'dull-gold-suit', 25.00, 'assets/images/983.jpg', 100),
    ('bags', 'Swift Bag', 'swift-bag', 26.00, 'assets/images/swiftbag.jpg', 100),
    ('watches', 'Silver Watch', 'silver-watch', 29.00, 'assets/images/w8.jpeg', 100),
    ('shoes', 'White Shoes', 'white-shoes', 40.00, 'assets/images/white.jpg', 100)
) as p(category_slug, title, slug, price, image_url, stock_qty)
join public.categories c on c.slug = p.category_slug
on conflict (slug) do nothing;
