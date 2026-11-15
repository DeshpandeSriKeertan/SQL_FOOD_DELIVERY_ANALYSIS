-- View 1: Display menu items with restaurant names
CREATE VIEW vw_menu_details AS
SELECT m.item_id, m.item_name, m.category, m.price, r.restaurant_name
FROM menu_items m
JOIN restaurants r
ON m.restaurant_id = r.restaurant_id;
select *from vw_menu_details;


-- View 2: Display payment details with order IDs and customer names
CREATE VIEW vw_payment_details AS
SELECT p.payment_id, o.order_id, c.customer_name, p.payment_method, p.payment_status, p.amount
FROM payments p
JOIN orders o
ON p.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.customer_id;
select *from vw_payment_details order by p.payment_method;


-- View 3: Customer purchase summary
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT c.customer_id, c.customer_name, c.city,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COALESCE(SUM(CASE WHEN p.payment_status='Paid' THEN p.amount ELSE 0 END),0) AS paid_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name, c.city;
select *from vw_customer_summary;


-- View 4: Restaurant performance summary
CREATE VIEW vw_restaurant_performance AS
SELECT r.restaurant_id, r.restaurant_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    ROUND(AVG(rv.restaurant_rating), 2) AS average_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN reviews rv
    ON o.order_id = rv.order_id
GROUP BY r.restaurant_id, r.restaurant_name;
select *from vw_restaurant_performance order by average_customer_rating;
