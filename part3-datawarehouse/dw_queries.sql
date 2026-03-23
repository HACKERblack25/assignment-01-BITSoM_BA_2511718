-- ============================================================
-- Part 3.2 — Analytical Queries on the Star Schema
-- ============================================================

-- Q1: Total sales revenue by product category for each month
-- Q1:
SELECT
    d.year,
    d.month,
    d.month_name,
    p.category,
    SUM(f.revenue)      AS total_revenue,
    SUM(f.units_sold)   AS total_units
FROM fact_sales     f
JOIN dim_date       d ON f.date_key    = d.date_key
JOIN dim_product    p ON f.product_key = p.product_key
GROUP BY d.year, d.month, d.month_name, p.category
ORDER BY d.year, d.month, total_revenue DESC;


-- Q2: Top 2 performing stores by total revenue
-- Q2:
SELECT
    s.store_name,
    s.city,
    SUM(f.revenue)              AS total_revenue,
    SUM(f.units_sold)           AS total_units,
    COUNT(f.transaction_id)     AS total_transactions
FROM fact_sales f
JOIN dim_store  s ON f.store_key = s.store_key
GROUP BY s.store_name, s.city
ORDER BY total_revenue DESC
LIMIT 2;


-- Q3: Month-over-month sales trend across all stores
-- Q3:
SELECT
    d.year,
    d.month,
    d.month_name,
    SUM(f.revenue)  AS monthly_revenue,
    LAG(SUM(f.revenue)) OVER (ORDER BY d.year, d.month) AS prev_month_revenue,
    ROUND(
        (SUM(f.revenue) - LAG(SUM(f.revenue)) OVER (ORDER BY d.year, d.month))
        / NULLIF(LAG(SUM(f.revenue)) OVER (ORDER BY d.year, d.month), 0) * 100
    , 2) AS mom_growth_pct
FROM fact_sales f
JOIN dim_date   d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;