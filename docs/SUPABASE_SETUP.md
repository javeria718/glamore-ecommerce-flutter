# Supabase Migration Order

1. `20260301_01_schema.sql`
2. `20260301_02_rls.sql`
3. `20260301_03_seed.sql`
4. `20260301_04_remove_department_from_profiles.sql`

Run with Supabase CLI:
- `supabase db push`

Tables used by app runtime now:
- `profiles`
- `products`
- `categories`
- `carts`
- `cart_items`
- `orders`
