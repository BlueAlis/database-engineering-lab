# My Attempt — subqueries-and-exists-vs-in-vs-join

## 1.Warm-up — three ways to ask the same question
Query:
```sql
select distinct  c."name" ,c.city  
from customers c
inner join orders o 
on c.id = o.customer_id 
where o.status = 'completed'

select c."name" ,c.city  
from customers c
where c.id in (
	select o.customer_id  from orders o
	where status = 'completed'
)

select c."name" ,c.city  
from customers c
where exists(
	select 1
	from orders o 
	where o.status = 'completed'
	and o.customer_id = c.id 
)

```

Output:
```
"name","city"
Apex Builders,Chonburi
Ban Suan Villas,Bangkok
Delta Infrastructure,Nonthaburi
Malee Home Improvement,Bangkok
Northern Concrete Works,Chiang Mai
Piti Renovation,Bangkok
Somchai Construction Co.,Bangkok
Sunshine Hardware,Chiang Mai
Thai Building Supply Partners,Nonthaburi

```

Notes: do you expect (a)
to need `DISTINCT`? Why would (b) and (c) not have that problem in the
first place?  
answer:  
a ต้องการ distinct เพราะว่าเมื่อเรา join ธรรมดาในกรณีที่มี customer คนนั้นมีหลาย order แล้ว select มาแต่ name , city จะทำให้เห็นข้อมูลที่ซ้ำกันหลาย row ทำให้ต้องใช้ distinct ตัด row ที่ซ้ำกันออกไป  
b ไม่ต้องการเพราะเป็นการวนเช็คที่ละแถวจาก table customer ไม่ว่าใน in จะมี customer ซ้ำกี่รอบก็ยังจะได้ customer นั้นออกมา row เดียวอยู่ดี  
c ไม่ต้องการเพราะมีการทำ correlation เช็ค ว่า order status complete นั้นเป็นของ customer นั้นจริงหรือไม่ ถ้าไม่มี correlation ก็จะได้ผลลัพธ์แบบ static คือขอแค่ order มี status complete ก็จะเห็นทุก user ดี

ในเคสนี้ (การเช็ค) การใช้ exists ดีที่สุด เพราะไม่ต้องพึ่งการใช้ distinct , ถ้าเงื่อนไขที่ต้องการซับซ้อนขึ้นก็สามารถทำได้เลยโดยไม่กระทบ outer row count, performance ดีกว่าการใช้ join+distinct
## 2. NOT EXISTS, and where NOT IN gets dangerous
Query:
```sql
select * 
from products p 
where not exists(
	select 1 
	from orders o
	inner join order_items oi
	on o.id = oi.order_id 
	where o.status = 'completed' 
	and p.id = oi.product_id 
)
```

Output:
```
"id","sku","name","category","unit_price","unit"

```

Notes:  if the subquery inside a
`NOT IN (...)` can return so much as one `NULL` among its rows, what
happens to the whole `NOT IN` result? Would `NOT EXISTS` have the same
problem?  
answer: จะไม่ได้ result เลย เพราะใช้ Three-Valued Logic (true,false,unknown) โดยที่ null จะได้เป็น unknown และ การใช้ not in ทุกเงื่อนไขต้องได้เป็น true ทั้งหมด
ส่วนการใช้ not exists เป็นการเช็คว่ามีหรือไม่มี และไม่ใช่การเอาค่าใน subquery ไปเปรียบเทียบกับ outer query แบบ not in ทำให้ไม่เจอปัญหานี้

## 3. Correlated subquery — priced above category average
Query:
```sql
select p.name, p.category, p.unit_price,
       (
            select avg(p2.unit_price) 
            from products p2 
            where p2.category = p.category
       ) as category_avg
from products p
where p.unit_price >  
       (
            select avg(p2.unit_price) 
            from products p2 
            where p2.category = p.category
       ) 
```

Output:
```
"name","category","unit_price","category_avg"
Portland Cement 50kg,Cement,180.00,150.0000000000000000
Rebar 12mm 6m,Rebar & Steel,250.00,220.0000000000000000
Concrete Block 20cm,Bricks & Blocks,22.00,15.2500000000000000
Crushed Gravel,Sand & Aggregate,500.00,475.0000000000000000
Exterior Paint 20L,Paint & Finishing,1450.00,1325.0000000000000000

```

Notes:  
ควรใช้ CTE ในการทำ select category_avg ลดการคำนวณซ้ำลง  หนรือจะใช้ group by ในการหา avg category price แทนก็ได้
  
ที่ต้องแยก alias (p ,p2) เพราะเป็นคนละ scope กัน

## 4. Scalar subquery — above-average spenders
Query:
```sql
with total_spend as (
	select c.name , COALESCE(SUM(oi.quantity * oi.unit_price ),0) as total_spend
	from customers c 
	left join orders o 
	on o.customer_id  = c.id 
	and o.status = 'completed'
	left join order_items oi 
	on o.id = oi.order_id 
	group by c.id
)
select * 
from total_spend ts
where ts.total_spend > (select avg(ts2.total_spend) from total_spend ts2)
```

Output:
```  
-- derived table 
"name","total_spend"
Piti Renovation,7700.00
Green Roof Renovations,0
Sunshine Hardware,7000.00
Malee Home Improvement,6900.00
Apex Builders,30200.00
Thai Building Supply Partners,22100.00
Northern Concrete Works,4750.00
Delta Infrastructure,13900.00
Somchai Construction Co.,14350.00
Ban Suan Villas,5150.00

-- answer
"name","total_spend"
Apex Builders,30200.00
Thai Building Supply Partners,22100.00
Delta Infrastructure,13900.00
Somchai Construction Co.,14350.00
```

Notes:  
  Think about the order of operations here: what has to be computed first,
before you can even write the comparison  
answer: หา total spend ต่อ customer ก่อนถึงจะเอาไปหา avg total spend ของุกคนได้  

ถ้าใส่ on ตรง where จะทำให้กลายเป็น inner join ทำให้ customer ที่ไม่มี completed หลุดไป  
ใช้ CTE เพราะไม่สามารถใช้ aggregate ซ้อนกันได้
Scalar subquery = subquery ที่คืนค่าออกมาแค่ 1 แถว 1 column เท่านั้น

## 5. Subquery in FROM — top spender per city

Query:
```sql
select name, city, total_spend 
from (
	select c.name, c.city , 
		sum(oi.quantity * oi.unit_price ) as total_spend , 
		row_number() over (partition by c.city order by sum(oi.quantity * oi.unit_price ) desc , c.id asc) as ranking
	from customers c 
	inner join orders o 
	on c.id = o.customer_id 
	inner join order_items oi 
	on o.id = oi.order_id 
	where o.status = 'completed'
	group by c.id
)
where ranking = 1
```

Output:
```  
"name","city","total_spend"
Somchai Construction Co.,Bangkok,14350.00
Sunshine Hardware,Chiang Mai,7000.00
Apex Builders,Chonburi,30200.00
Thai Building Supply Partners,Nonthaburi,22100.00
```
Notes: there's more
than one valid way to do the second part; whichever you pick, be ready to
explain why it gets exactly one row per city even if there's a tie.  
answer: ใช้ row_number() เพราะทุก row จะได้เลขต่างกัน เมื่อ where = 1 จะทำให้ได้ผลลัพธ์แค่ row เดียวต่อ city
