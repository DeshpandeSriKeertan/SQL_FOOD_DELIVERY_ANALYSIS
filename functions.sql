-- 1. Find the number of days since each customer registered
SELECT customer_id, customer_name,
    SUBSTRING_INDEX(customer_name, ' ', 1) AS first_name,
    DATEDIFF(CURDATE(), signup_date) AS registration_days
FROM customers;


-- 2 Display restaurant names along with their cuisine types in a single column and show the length of each restaurant name.
SELECT restaurant_id,
    CONCAT(restaurant_name, ' - ', cuisine_type) AS restaurant_details,
    LENGTH(restaurant_name) AS name_length
FROM restaurants;

-- 3  Display order ID, restaurant details, order date in DD-MM-YYYY format and order weekday.
SELECT o.order_id, 
CONCAT(UPPER(r.restaurant_name), ' - ', r.cuisine_type) AS restaurant_details,
    DATE_FORMAT(o.order_date, '%d-%m-%Y') AS formatted_date,
    DAYNAME(o.order_date) AS order_day
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id ;


-- 4  Display delivery partner names in uppercase, extract their first names, and show their joining month and year. 
SELECT
    partner_id,
    UPPER(partner_name) AS partner_name,
    SUBSTRING_INDEX(partner_name, ' ', 1) AS first_name,
    MONTHNAME(joining_date) AS joining_month,
    YEAR(joining_date) AS joining_year
FROM delivery_partners;