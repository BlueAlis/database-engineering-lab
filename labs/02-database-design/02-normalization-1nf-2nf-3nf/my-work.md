## Attempt

## Problem 1 — find the anomalies

update anomaly: อย่างเช่นถ้าเราอยากจะ update รายละเอียดต่างๆ ของ product เช่น name, code, category เราต้องมานั่ง update ทุก row ให้ตรงกันเสี่ยงต่อการผิดพลาดเช่น update ไม่ครบ, update ผิดตัวมาก นอกจากนี้ยังทำให้เกิดการซ้ำซ้อนของข้อมูลด้วย  
```  
UPDATE sales_flat
SET product_category = 'xxx'
WHERE invoice_no = 'INV-002';
```

จาก statement ข้างบน product_category จะถูกเปลี่ยนแค่ของ invoice_no = 'INV-002' ทั้งๆที่ความจริงแล้ว product ตัวนี้ก็อยู่ใน invoice_no = 'INV-001' ด้วย

insert anomaly: สมมุติมี product ใหม่เพิ่มเข้ามา แต่ยังไม่เกิดการขายขึ้น ข้อมูลของ customer กับ sale ก็จะเป็น null หมด แล้วถ้า schema set field พวกนี้เป็น not null ไว้ก็จะทำให้ไม่สามารถเพิ่มสินค้าใหม่เข้ามาได้เลยจนกว่าจะเกิดการขายจริงๆ  

delete anomaly: อยากเช่นในกรณีที่ sale มีคนลาออกแล้วต้องการลบข้อมูลของ sale คนนั้นอออกจากแล้วชื่อของ sale คนนั้นอยู่ใน row เดียวกับ customer ที่เหลือเพียงแค่ row เดียวเหมือนกันการลบ row ที่ sale คนนั้นอยู่ก็จะเป็นการลบ customere คนนั้นออกจากระบบด้วยทั้งๆที่เป็นต้องการลบแค่ sale ไม่ได้อยาก ลบ customer   
```  
DELETE FROM sales_flat
WHERE salesperson_name = 'Boat';
```

## Problem 2 — normalize it

first step 1NF
ทุก column เป็น atomic value อยู่แล้ว

second step 2NF
ตอนนี้เป็น composite key invoice_no, product_code

หา Functional Dependency
customer_id -> customer_name
            -> customer_phone
            -> customer_address
product_code-> product_name
            -> product_category
            -> product_discount_pct
            -> unit_price
salesperson_id  -> salesperson_name
                -> salesperson_phone
invoice_no -> invoice_date
            -> customer_id
            -> salesperson_id
            
invoice_no, product_code   -> quantity
                           -> unit_price

table ของตัวเอง
customer
product
salesperson
invoice
invoice_item

third step 3NF

ตัด transitive dependency ออกแยกออกมาเป็น table ของตัวเอง

category มี biz ของตัวเองควรแยกออกมาอีก 1 table เป็น table category
category id -> category_name
            -> category_discount_pct

สรุป table  

customer  
id bigint pk  
customer_name varchar  
customer_phone varchar  
customer_address text

product  
product_code varchar pk  
product_name varchar  
category_id bigint fk  
unit_price numeric

salesperson  
id bigint pk  
salesperson_name varchar  
salesperson_phone varchar

invoice  
invoice_no varchar pk  
invoice_date date  
customer_id bigint fk  
salesperson_id bigint fk

invoice_item  
id bigint pk  
invoice_no varchar fk  
product_code varchar fk  
quantity int  
unit_price numeric

UNIQUE (invoice_no, product_code)

category  
id bigint pk  
category_name varchar  
category_discount_pct numeric

## Problem 3 — would you actually ship the fully normalized version?

เยส สำหรับ sale report table จะเลือก เก็บ product_name จาก sales_flat ไว้ใน invoice_item เพราะ 
1 เรื่องของ performance (จริงๆเคสนี้ก็ไวอยู่แล้วโดยไม่ต้อง denormalize)
2 สามารถเก็บชื่อสินค้าไว้เป็น snap data ณ เวลาที่ขายจริง เผื่ออนาคตมีการเปลี่ยนชื่อสินค้า

## Experiment
ทดสอบ anomaly แล้วแก้ปัญหา update insert delete ได้จริง

