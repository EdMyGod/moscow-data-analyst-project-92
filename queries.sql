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
having avg(s.quantity*p.price) > ( select avg(s.quantity*p.price) from sales s 
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
)
order by average_income asc 
-- продавцы с прибылью ниже среднего

SELECT concat(e.first_name,' ',e.last_name) as seller,
(case 
	when extract(dow from s.sale_date) = 0 then 'monday'
	when extract(dow from s.sale_date) = 1 then 'tuesday'
	when extract(dow from s.sale_date) = 2 then 'wednesday'
	when extract(dow from s.sale_date) = 3 then 'thursday'
	when extract(dow from s.sale_date) = 4 then 'friday'
	when extract(dow from s.sale_date) = 5 then 'saturday'
	when extract(dow from s.sale_date) = 6 then 'sunday'
end) as day_of_week,
floor(sum(s.quantity*p.price)) as income
from sales s 
inner join employees e on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
group by e.first_name, e.last_name, EXTRACT(dow FROM s.sale_date)
order by extract(dow from s.sale_date), seller 
-- по дням недели