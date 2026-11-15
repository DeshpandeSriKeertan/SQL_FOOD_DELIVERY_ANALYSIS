-- 1 Display all orders of a customer
DELIMITER $$

CREATE PROCEDURE sp_customer_order1(IN p_customer_id INT)
BEGIN
    SELECT order_id, order_date,order_status
    FROM orders
    WHERE customer_id = p_customer_id;
END $$

DELIMITER ;
CALL sp_customer_order1(15);



-- 2 Find total spending of a customer
DELIMITER $$

CREATE PROCEDURE sp_customer_spending(IN p_customer_id INT)
BEGIN
    SELECT c.customer_id, c.customer_name,
        COALESCE(SUM(p.amount), 0) AS total_spending
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    LEFT JOIN payments p
        ON o.order_id = p.order_id AND p.payment_status = 'Paid'
    WHERE c.customer_id = p_customer_id
    GROUP BY c.customer_id, c.customer_name;
END $$

DELIMITER ;

CALL sp_customer_spending(6);



-- 3 Display restaurant order details
DELIMITER $$

CREATE PROCEDURE sp_restaurant_orders(IN p_restaurant_id INT)
BEGIN
    SELECT r.restaurant_name, o.order_id, c.customer_name, o.order_date, o.order_status
    FROM orders o
    JOIN restaurants r
        ON o.restaurant_id = r.restaurant_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE r.restaurant_id = p_restaurant_id
    ORDER BY o.order_date DESC;
END $$

DELIMITER ;
CALL sp_restaurant_orders(8);



-- 4 Calculate restaurant revenue between two dates
DELIMITER $$

CREATE PROCEDURE sp_restaurant_revenue(
    IN p_restaurant_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT r.restaurant_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(p.amount), 0) AS total_revenue
    FROM restaurants r
    LEFT JOIN orders o
        ON r.restaurant_id = o.restaurant_id
        AND o.order_date BETWEEN p_start_date AND p_end_date
    LEFT JOIN payments p
        ON o.order_id = p.order_id
        AND p.payment_status = 'Paid'
    WHERE r.restaurant_id = p_restaurant_id
    GROUP BY r.restaurant_id, r.restaurant_name;
END $$

DELIMITER ;

CALL sp_restaurant_revenue(2, '2026-01-01', '2026-07-31');