# My Attempt — Joins and Aggregation

## 1. Warm-up filter + join

Query:
```sql
select c."name" , o.id , o.order_date   
from orders o 
left join customers c 
on o.customer_id  = c.id 
where o.status = 'completed' 
and c.city = 'Bangkok' 
and c.customer_type = 'contractor'
order by o.order_date desc
```

Output:
```
"name","id","order_date"
Somchai Construction Co.,15,2026-03-15
Somchai Construction Co.,2,2026-02-10
Somchai Construction Co.,1,2026-01-05
```

Notes: ควรใช้ inner join แทนการใช้ left join ให้ตรงกับการใช้งานจริงที่ต้องการแค่ข้อมูลบางอย่างจากทั้ง 2 table

## 2. Revenue per customer

Query:
```sql
select c.id, c."name" , COALESCE(SUM(oi.quantity * oi.unit_price), 0) as revenue from customers c 
left join orders o 
on o.customer_id = c.id and o.status = 'completed'
left join order_items oi 
on oi.order_id = o.id 
group by c.id, c."name"
order by revenue desc
```

Output:
```
"id","name","revenue"
9,Apex Builders,30200.00
3,Thai Building Supply Partners,22100.00
1,Somchai Construction Co.,14350.00
7,Delta Infrastructure,13900.00
4,Piti Renovation,7700.00
6,Sunshine Hardware,7000.00
2,Malee Home Improvement,6900.00
8,Ban Suan Villas,5150.00
5,Northern Concrete Works,4750.00
10,Green Roof Renovations,0

```

Notes: ใช้ on status แทน where กัน customer ที่ไม่มี order หลุดไป

## 3. Products ordered by many distinct customers

Query:
```sql
select p."name", COUNT(DISTINCT c.id  ) as distinct_customer from customers c 
inner join orders o 
on o.customer_id = c.id and o.status = 'completed'
inner join order_items oi 
on oi.order_id = o.id 
inner join products p 
on oi.product_id = p.id 
group by p.id
having COUNT(DISTINCT c.id ) > 2
```

Output:
```
"name","distinct_customer"
Exterior Paint 20L,4
Portland Cement 50kg,3
Rebar 12mm 6m,4
River Sand,3
```

Notes:
postgres ให้ใช้ group by select column อื่นจากตารางเดียวกันได้ถ้า GROUP BY เป็น primary key ของตารางนั้น  
 
ถ้าเป็น MySQL, SQL Server  ต้องใส่ทุกคอลัมน์ที่ select ลง GROUP BY เสมอ  

what's the difference between counting *rows*
in `order_items` for a product versus counting *distinct customers*? Which
one does the question actually ask for?
  
answer : แตกต่างกันเพราะ การนับจำนวนแถวบอกถึงจำนวน order ที่มีการสั่งสินค้านั้น ส่วน การนับจำนวนลูกค้าบอกถึงว่ามีลูกค้ากี่คนที่สั่งสินค้าชิ้นนั้น โจทย์ต้องการ distinct customers

ใช้ inner join เพราะโจทย์ไม่ได้บอกให้เก็บ product หรือ customer ที่ไม่ต้องการไว้

district c.id , group by p.id เพราะ เป็น primary key ไม่มีโอกาสซ้ำแบบการใช้ name

## 4. Customers with no orders at all

Query:
```sql
select c.id, c."name", count(o.customer_id) as count_order from customers c 
left join orders o 
on o.customer_id = c.id 
group by c.id, c."name"
having count(o.customer_id) = 0
```

Output:
```
"id","name","count_order"
10,Green Roof Renovations,0
```

Notes:

คำถาม: ผลลัพธ์ข้อ 4 ได้ลูกค้าคนเดียวกับที่ revenue = 0 ในข้อ 2 พอดี — เป็นเรื่องบังเอิญของ dataset นี้ หรือ query ข้อ 2 กับข้อ 4 วัดสิ่งเดียวกัน? ถ้ามีลูกค้าที่สั่ง order แต่ถูก cancel ทั้งหมด query ทั้งสองข้อจะให้ผลเหมือนหรือต่างกันสำหรับลูกค้าคนนั้น

answer: ต่างกันจากข้อ 2 อาจมีลูกค้าสั่ง order มาแต่เกิด cancle หรือกรณีอื่นๆทำให้ไม่เกิดเป็นรายได้จริงๆ
แต่ข้อ 4 คือไม่เคยสั่ง order เลยจริงๆ
## 5. Top categories by revenue

Query:
```sql
select p.category , SUM(oi.quantity * oi.unit_price) as total_revenue from orders o 
inner join order_items oi 
on oi.order_id = o.id 
inner join products p 
on oi.product_id = p.id 
where o.status = 'completed'
group by p.category 
order by SUM(oi.quantity * oi.unit_price) desc
limit 3
```

Output:
```
"category","total_revenue"
Rebar & Steel,29800.00
Cement,27600.00
Paint & Finishing,17600.00

```

Notes:
คำถาม: ถ้าหมวดที่ 3 กับหมวดที่ 4 มี total_revenue เท่ากันพอดี query นี้ (ORDER BY ... LIMIT 3 โดยไม่มี tie-breaker เพิ่ม) จะเลือกอันไหนเป็นอันดับ 3 — แบบ deterministic หรือแบบไม่แน่นอนเวลา rerun ซ้ำ?

answer:
 แบบไม่แน่นอนเป็น undefined order ขึ้นอยู่กับการทำงานของ query execution ในตอนนั้น  
วิธีแก้เพิ่ม tie-breaker column เพิ่ม เช่น  
ORDER BY total_revenue DESC, category ASC
## Optional stretch (largest category per customer)

Query:
```sql  
--use RANK()
with customer_revenue as (
select
 c.id, 
c."name" , 
p.category ,
COALESCE(SUM(oi.quantity * oi.unit_price), 0) as revenue,
RANK() OVER (PARTITION BY c.id  ORDER BY SUM(oi.quantity * oi.unit_price) DESC) as rank
from customers c 
left join orders o 
on o.customer_id = c.id and o.status = 'completed'
left join order_items oi 
on oi.order_id = o.id 
left join products p 
on oi.product_id = p.id 
group by c.id, p.category 
)
select id , name, category ,revenue
from customer_revenue 
where rank = 1
order by revenue desc  
  
--use DISTINCT ON 
SELECT DISTINCT ON (p.category)
    c.id,
    c."name",
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.id
    AND o.status = 'completed'
LEFT JOIN order_items oi
    ON oi.order_id = o.id
LEFT JOIN products p
    ON oi.product_id = p.id
GROUP BY
    c.id,
    c."name",
    p.category
ORDER BY
    p.category,
    SUM(oi.quantity * oi.unit_price) DESC;
```

Output:
```
"id","name","category","revenue"
9,Apex Builders,Cement,14400.00
3,Thai Building Supply Partners,Cement,9000.00
4,Piti Renovation,Paint & Finishing,7700.00
7,Delta Infrastructure,Rebar & Steel,6600.00
1,Somchai Construction Co.,Rebar & Steel,5000.00
6,Sunshine Hardware,Plumbing,4800.00
5,Northern Concrete Works,Sand & Aggregate,4750.00
2,Malee Home Improvement,Paint & Finishing,4350.00
8,Ban Suan Villas,Paint & Finishing,2650.00
10,Green Roof Renovations,,0
```

Notes:  
step 1: หา revenue ต่อ customer category  
step 2: หาแถวที่ยอดสูงสุดของลูกค้าแต่ละคน  
step 3: เอาผลที่ได้จาก step 2 ไป select ใหม่
