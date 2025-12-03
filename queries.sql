SELECT Count(*) as customers_count
FROM public.customers;
-- подсчет строк

SELECT concat(e.first_name,' ',e.last_name) as seller,
count(s.customer_id) as operations,
floor(sum(s.quantity*p.price)) as income
from sales s 
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
group by seller
order by income desc 
limit 10
-- топ 10 продавцов

SELECT concat(e.first_name,' ',e.last_name) as seller,
floor(avg(s.quantity*p.price)) as average_income
from sales s 
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
group by seller
having avg(s.quantity*p.price) < ( select avg(s.quantity*p.price) from sales s 
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
)
order by average_income asc 
-- продавцы с прибылью ниже среднего

SELECT concat(e.first_name,' ',e.last_name) as seller,
(case 
	when extract(dow from s.sale_date) = 1 then 'monday'
	when extract(dow from s.sale_date) = 2 then 'tuesday  '
	when extract(dow from s.sale_date) = 3 then 'wednesday'
	when extract(dow from s.sale_date) = 4 then 'thursday '
	when extract(dow from s.sale_date) = 5 then 'friday'
	when extract(dow from s.sale_date) = 6 then 'saturday '
	when extract(dow from s.sale_date) = 0 then 'sunday'
end) as day_of_week,
floor(sum(s.quantity*p.price)) as income
from sales s 
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
group by e.first_name, e.last_name, EXTRACT(dow FROM s.sale_date)
order by mod(extract(dow from s.sale_date)::int + 6, 7), seller
-- по дням недели

SELECT (case
	when customers.age <= 25 then '16-25' 
	when customers.age <= 40 then '26-40' 
	else '40+'
end) as age_category,
Count(*) as age_count 
FROM public.customers
group by age_category
order by age_category 
-- группы возрастов

select to_char(s.sale_date, 'yyyy-mm') as selling_month,
count(distinct s.customer_id) as total_customers,
floor(sum(s.quantity*p.price)) as income
from sales s 
inner join products p on p.product_id = s.product_id
group by to_char(s.sale_date, 'yyyy-mm')
order by to_char(s.sale_date, 'yyyy-mm') asc
-- покупатели по месяцам

WITH first_purchases AS (
    SELECT 
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        s.product_id,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.sale_date) as purchase_rank
    FROM sales s
)
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    fp.sale_date AS sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_purchases fp
INNER JOIN customers c ON c.customer_id = fp.customer_id
INNER JOIN employees e ON e.employee_id = fp.sales_person_id
INNER JOIN products p ON p.product_id = fp.product_id
WHERE fp.purchase_rank = 1 AND p.price = 0
ORDER BY fp.customer_id;
--первыпе покупки по акции
