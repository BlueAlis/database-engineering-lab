# Concept Notes

Working notes on concepts 


If AI helped clarify something, say so inline (e.g. "AI explained X, here's
what clicked for me: ...") rather than presenting the explanation as if it
were independently derived.

---

Oracle VARCHAR2 null == empty string

Primary Key / Index
Primary  
Key → มี Index ให้อัตโนมัติ ใน PostgreSQL  
Index ที่สร้างให้โดย PK เป็น Unique B-tree  
PK บังคับ UNIQUE + NOT NULL  
  
BIGINT vs VARCHAR สำหรับ ID  
BIGINT = fixed 8 bytes → เล็กและ predictable  
VARCHAR = variable-length → โดยทั่วไปใหญ่กว่า  
Index ที่ใช้ BIGINT จึงมัก เล็กกว่า  
Index เล็ก → ใส่ใน Buffer Cache ได้มากกว่า  
Integer comparison → โดยทั่วไปง่าย/เร็วกว่า string comparison  
ส่งผลดีต่อ lookup / JOIN / index traversal  
ความต่างจะเห็นชัดขึ้นเมื่อข้อมูลและ workload ใหญ่
  
Composite Primary Key  
PRIMARY KEY (product_id, supplier_id)  
สร้าง Composite B-tree Index ให้อัตโนมัติ  
(product_id, supplier_id) ห้ามซ้ำ  
product_id → ใช้ index ได้  
product_id + supplier_id → ใช้ index ได้  
supplier_id อย่างเดียว → index นี้ไม่เหมาะเท่าไร  
ถ้าค้น supplier_id บ่อย → สร้าง index แยก

PK = Constraint + Unique Index, Composite PK = Multi-column Unique Index และลำดับ column ใน index มีความสำคัญ
