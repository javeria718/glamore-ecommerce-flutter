-- 20260303_01_cart_items_product_image.sql
alter table public.cart_items
add column if not exists product_image text;

-- Best-effort backfill for existing cart rows using product title match.
update public.cart_items ci
set product_image = p.image_url
from public.products p
where (ci.product_image is null or btrim(ci.product_image) = '')
  and ci.product_name = p.title
  and p.image_url is not null
  and btrim(p.image_url) <> '';
