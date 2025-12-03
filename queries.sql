-- подсчет строк

SELECT COUNT(*) AS customers_count
FROM public.customers;

-- топ 10 продавцов

SELECT concat(e.first_name, ' ', e.last_name) AS seller,
       count(s.customer_id) AS operations,
       floor(sum(s.quantity*p.price)) AS income
FROM sales s
INNER JOIN employees e ON e.employee_id = s.sales_person_id
INNER JOIN products p ON p.product_id = s.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10 
	
-- продавцы с прибылью ниже среднего
SELECT concat(e.first_name, ' ', e.last_name) AS seller,
       floor(avg(s.quantity * p.price)) AS average_income
FROM sales s
INNER JOIN employees e ON e.employee_id = s.sales_person_id
INNER JOIN products p ON p.product_id = s.product_id
GROUP BY seller
HAVING avg(s.quantity * p.price) <
  (SELECT avg(s.quantity*p.price)
   FROM sales s
   INNER JOIN employees e ON e.employee_id = s.sales_person_id
   INNER JOIN products p ON p.product_id = s.product_id)
ORDER BY average_income ASC 
	
-- по дням недели
SELECT concat(e.first_name, ' ', e.last_name) AS seller,
       (CASE
            WHEN extract(dow
                         FROM s.sale_date) = 1 THEN 'monday'
            WHEN extract(dow
                         FROM s.sale_date) = 2 THEN 'tuesday  '
            WHEN extract(dow
                         FROM s.sale_date) = 3 THEN 'wednesday'
            WHEN extract(dow
                         FROM s.sale_date) = 4 THEN 'thursday '
            WHEN extract(dow
                         FROM s.sale_date) = 5 THEN 'friday'
            WHEN extract(dow
                         FROM s.sale_date) = 6 THEN 'saturday '
            WHEN extract(dow
                         FROM s.sale_date) = 0 THEN 'sunday'
        END) AS day_of_week,
       floor(sum(s.quantity*p.price)) AS income
FROM sales s
INNER JOIN employees e ON e.employee_id = s.sales_person_id
INNER JOIN products p ON p.product_id = s.product_id
GROUP BY e.first_name,
         e.last_name,
         EXTRACT(dow
                 FROM s.sale_date)
ORDER BY mod(extract(dow
                     FROM s.sale_date)::int + 6, 7),
         seller 
	
-- группы возрастов
SELECT (CASE
            WHEN customers.age <= 25 THEN '16-25'
            WHEN customers.age <= 40 THEN '26-40'
            ELSE '40+'
        END) AS age_category,
       Count(*) AS age_count
FROM public.customers
GROUP BY age_category
ORDER BY age_category 
	
-- покупатели по месяцам
SELECT to_char(s.sale_date, 'yyyy-mm') AS selling_month,
       count(DISTINCT s.customer_id) AS total_customers,
       floor(sum(s.quantity*p.price)) AS income
FROM sales s
INNER JOIN products p ON p.product_id = s.product_id
GROUP BY to_char(s.sale_date, 'yyyy-mm')
ORDER BY to_char(s.sale_date, 'yyyy-mm') ASC 

--первые покупки по акции
WITH first_purchases AS
  (SELECT s.customer_id,
          s.sale_date,
          s.sales_person_id,
          s.product_id,
          ROW_NUMBER() OVER (PARTITION BY s.customer_id
                             ORDER BY s.sale_date) AS purchase_rank
   FROM sales s)
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer,
       fp.sale_date AS sale_date,
       CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_purchases fp
INNER JOIN customers c ON c.customer_id = fp.customer_id
INNER JOIN employees e ON e.employee_id = fp.sales_person_id
INNER JOIN products p ON p.product_id = fp.product_id
WHERE fp.purchase_rank = 1
  AND p.price = 0
ORDER BY fp.customer_id;
