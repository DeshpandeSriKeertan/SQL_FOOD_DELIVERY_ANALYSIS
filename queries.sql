-- 1. Restaurant-wise completed orders and revenue
SELECT r.restaurant_name, COUNT(DISTINCT o.order_id) AS completed_orders,
       SUM(oi.quantity * oi.item_price) AS food_revenue
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'Delivered' AND p.payment_status = 'Paid'
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY food_revenue DESC;


-- 2. Customers whose total spending is greater than the average customer spending
SELECT c.customer_id, c.customer_name, SUM(p.amount) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(p.amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(p2.amount) AS customer_total
        FROM orders o2
        JOIN payments p2 ON o2.order_id = p2.order_id
        WHERE p2.payment_status = 'Paid'
        GROUP BY o2.customer_id
    ) AS customer_spending
)
ORDER BY total_spending DESC;


-- 3. Most popular menu item in each restaurant (correlated subquery)
SELECT r.restaurant_name, m.item_name, item_sales.total_quantity
FROM (
    SELECT oi.item_id, SUM(oi.quantity) AS total_quantity
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY oi.item_id
) AS item_sales
JOIN menu_items m ON item_sales.item_id = m.item_id
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
WHERE item_sales.total_quantity = (
    SELECT MAX(x.total_quantity)
    FROM (
        SELECT oi2.item_id, SUM(oi2.quantity) AS total_quantity
        FROM order_items oi2
        JOIN orders o2 ON oi2.order_id = o2.order_id
        WHERE o2.order_status = 'Delivered'
        GROUP BY oi2.item_id
    ) AS x
    JOIN menu_items m2 ON x.item_id = m2.item_id
    WHERE m2.restaurant_id = r.restaurant_id
);



-- 4. Customers who have ordered from every restaurant in their city
SELECT c.customer_id, c.customer_name, c.city
FROM customers c
WHERE (
    SELECT COUNT(DISTINCT o.restaurant_id)
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.customer_id = c.customer_id AND r.city = c.city
) = (
    SELECT COUNT(*)
    FROM restaurants r2
    WHERE r2.city = c.city
);



-- 5. Delivery partners whose average delivery time is below the overall average
SELECT dp.partner_id, dp.partner_name,
       ROUND(AVG(o.delivery_time_minutes),2) AS avg_delivery_minutes
FROM delivery_partners dp
JOIN orders o ON dp.partner_id = o.partner_id
WHERE o.order_status = 'Delivered'
GROUP BY dp.partner_id, dp.partner_name
HAVING AVG(o.delivery_time_minutes) < (
    SELECT AVG(delivery_time_minutes)
    FROM orders
    WHERE order_status = 'Delivered'
);



-- 6. Monthly order volume, paid revenue and cancellation count
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS order_month,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN p.payment_status = 'Paid' THEN p.amount ELSE 0 END) AS paid_revenue,
       SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY order_month;



-- 7. Restaurants with ratings above the average restaurant rating and at least 5 delivered orders
SELECT r.restaurant_id, r.restaurant_name, r.rating,
       COUNT(o.order_id) AS delivered_orders
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.rating
HAVING r.rating > (SELECT AVG(rating) FROM restaurants)
   AND COUNT(o.order_id) >= 5;
   
   

-- 8. Customer-wise order frequency and customer segment
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders,
       CASE
           WHEN COUNT(o.order_id) >= 10 THEN 'Frequent'
           WHEN COUNT(o.order_id) BETWEEN 5 AND 9 THEN 'Regular'
           WHEN COUNT(o.order_id) BETWEEN 1 AND 4 THEN 'Occasional'
           ELSE 'No Orders'
       END AS customer_segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;



-- 9. Items that have never been ordered
SELECT m.item_id, m.item_name, r.restaurant_name
FROM menu_items m
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
LEFT JOIN order_items oi ON m.item_id = oi.item_id
WHERE oi.item_id IS NULL;
