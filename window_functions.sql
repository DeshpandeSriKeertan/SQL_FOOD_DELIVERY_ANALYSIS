-- 1. Rank restaurants based on their ratings
SELECT restaurant_id, restaurant_name, rating,
    RANK() OVER(ORDER BY rating DESC) AS restaurant_rank
FROM restaurants;



-- 2 Find the top 2 highest-paid orders for each customer.
SELECT *
FROM (
    SELECT o.customer_id,  o.order_id,p.amount,
        DENSE_RANK() OVER(PARTITION BY o.customer_id ORDER BY p.amount DESC) AS order_rank
    FROM orders o
    JOIN payments p
        ON o.order_id = p.order_id
    WHERE p.payment_status = 'Paid') AS ranked_orders
WHERE order_rank <= 2;



-- 3 Calculate the running total of revenue based on order date.
SELECT o.order_id, o.order_date, p.amount,
    SUM(p.amount) OVER(ORDER BY o.order_date, o.order_id) AS running_revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_status = 'Paid';



-- 4 Rank delivery partners based on their average delivery time within each city.
SELECT dp.partner_id, dp.partner_name, dp.city,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time,
    RANK() OVER(PARTITION BY dp.city ORDER BY AVG(o.delivery_time_minutes)) AS delivery_rank
FROM delivery_partners dp
JOIN orders o
    ON dp.partner_id = o.partner_id
WHERE o.order_status = 'Delivered'
GROUP BY dp.partner_id, dp.partner_name, dp.city;