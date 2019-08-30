/* PART 1 */

/* Create a report*/
USE DS2;

DROP TABLE IF EXISTS summarytable;
CREATE TABLE summarytable AS
 SELECT
  o.orderid,
  o.orderdate,
  o.customerid,
  o.totalamount,
  ol.quantity AS order_quantity,
  ca.category,
  p.title,
  c.city,
  c.state,
  c.country,
  c.age,
  c.income,
  c.gender,

  /* customer type {'new': 'first order','existing':'>=1'} */
  (SELECT CASE WHEN (SELECT count(*) FROM orders o_tmp_1 LEFT JOIN customers c_tmp_1 on c_tmp_1.customerid = o_tmp_1.customerid
   WHERE c_tmp_1.customerid = c.customerid and o_tmp_1.orderdate < o.orderdate) = 0 THEN 'new' ELSE 'existing'
  END AS customertype) as customer_type

  FROM ORDERS o LEFT JOIN customers c on c.customerid = o.customerid inner join orderlines ol on ol.orderid = o.orderid inner join products p on p.prod_id = ol.prod_id
  inner join categories ca on ca.category = p.category

  ORDER BY o.orderdate ASC;

DROP table IF EXISTS statistic;
CREATE TABLE statistic AS
SELECT  distinct a.customerid,
		1 as previous_order_number,
		a.totalamount as total_amount_of_previous_order
FROM summarytable a
WHERE  a.customer_type = 'new'
ORDER BY a.customerid;

DROP TABLE IF EXISTS statistic2;
CREATE TABLE statistic2 AS
SELECT  a.customerid,
		COUNT(a.orderid) as previous_order_number,
		SUM(a.totalamount) as total_amount_of_previous_order
FROM summarytable a 
WHERE a.customer_type = 'existing'
GROUP BY a.customerid
ORDER BY a.customerid;



/* PART 2 */
-- 1
/* percent of the sales come from new vs. existing customers*/
select sum(totalamount) / (select sum(totalamount) from summarytable)
from summarytable
group by customer_type;

-- 2
/* distribution of sales by category*/
select category, count(*)/ (select count(totalamount) from summarytable), sum(totalamount)/ (select sum(totalamount) from summarytable)
from summarytable
group by category
order by category;


-- 3
/* the distribution of sales by customer age buckets*/
select case when age < 20 then '<20'
   when age >= 20 and age < 30 then '20-30'
   when age >= 30 and age < 40 then '30-40'
   when age >= 40 and age < 50 then '40-50'
   when age >= 50 and age < 60 then '50-60'
   when age >= 60 and age < 70 then '60-70'
   when age >= 70 and age < 80 then '70-80'
   when age >= 80 and age < 90 then '80-90'
   when age >= 90 then '>90'
  end as customer_age_buckets, 
  sum(totalamount) / (select sum(TOTALAMOUNT) from summarytable) as sales_freq
  from (select age, totalamount from summarytable) as summarytable_tmp
  group by customer_age_buckets;
  


	
  

