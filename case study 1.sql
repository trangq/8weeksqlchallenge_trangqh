CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

 --1. What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as TotalAmountspent
FROM sales as s
inner join menu as m
on s.product_id=m.product_id
group by customer_id
order by customer_id asc;
--2.How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) as NumberOfVist
from sales
group by customer_id;
--3. What was the first item from the menu purchased by each customer?
SELECT customer_id, order_date, product_name from (
select s.customer_id,s.order_date,m.product_name,
dense_rank() over(partition by s.customer_id order by s.order_date) as rank
from sales as s
inner join menu as m
on s.product_id=m.product_id ) as t
where t.rank = 1

 --4. What is the most purchased item on the menu and how many times was it purchases

select count(*) as most_purchased, product_name from 
  sales a 
 join menu b on
a.product_id = b.product_id  
GROUP BY product_name
order by most_purchased desc


-- 5. Which item was the most popular for each customer?
select count(*) as most_purchased, customer_id, product_name from 
  sales a 
 join menu b on
a.product_id = b.product_id  
GROUP BY  customer_id, product_name
order by  customer_id, most_purchased desc


-- 6. Which item was purchased first by the customer after they became a member?



select a.customer_id, a.order_date,	b.product_name, c.join_date,DATEDIFF(Day,c.join_date, a.order_date) as day_since_join,
dense_rank() over(partition by a.customer_id order by 

DATEDIFF(Day,c.join_date, a.order_date))
as rnk
from sales as  a inner join menu as b
on a.product_id= b.product_id 
join members c on 
a.customer_id = c.customer_id
where a.order_date >= c.join_date


 --7. Which item was purchased just before the customer became a member?
select a.customer_id, a.order_date,	b.product_name, c.join_date,abs(DATEDIFF(Day,c.join_date, a.order_date)) as day_to_join,
dense_rank() over(partition by a.customer_id order by 

DATEDIFF(Day,c.join_date, a.order_date))
as rnk
from sales as  a inner join menu as b
on a.product_id= b.product_id 
join members c on 
a.customer_id = c.customer_id
where a.order_date <= c.join_date

--8.What is the total items and amount spent for each member before they became a member?

select a.customer_id, 	count(b.product_name) as total_items, sum(b.price) as amount_spent
from sales as  a inner join menu as b
on a.product_id= b.product_id 
join members c on 
a.customer_id = c.customer_id
and a.order_date <= c.join_date
group by a.customer_id

--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as 
(
 select a.customer_id, b.product_name, b.price , CASE b.product_name 
         WHEN 'sushi' THEN 2 * 10 * b.price   
         ELSE price  * 10
      END 
 as point
 from sales a 
 join menu b on
a.product_id = b.product_id 

)
select  customer_id,sum(point) as point from cte 
group by customer_id


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?



select a.customer_id,  sum(case
                     	when  a.order_date>=c.join_date and datediff(day,a.order_date,c.join_date)<=7 then price*20
                        else price *10
                        end) as totalpoint
 from sales a 
 join menu b on
a.product_id = b.product_id 
join members
c on 
a.customer_id = c.customer_id
 where a.order_date<='2021-01-31'
 group by a.customer_id;




select s.customer_id,--s.order_date,p.join_date,m.product_id,m.price,  
                   sum(case
                     	when  s.order_date>=p.join_date and datediff(day, s.order_date,p.join_date)<=7 then price*20
                        else price *10
                        end) as totalpoint
from sales as s
 inner join menu as m
 on s.product_id=m.product_id
 inner join members as p
 on s.customer_id=p.customer_id
 where s.order_date<='2021-01-31'
 group by s.customer_id;