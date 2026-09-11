## Attempt

## 1. core schema for inventory + sales


### Think sequentially

**Business**  
ร้านวัสดุก่อสร้างมีสินค้า สินค้าหนึ่งถูกแบ่งออกเป็นหมวดหมู่  
สินค้ามีการนับจำนวนสต็อกและมีราคาต่อหน่วย  
มีการออกใบขาย ในใบขายสามารถขายสินค้าได้หลายอย่าง พร้อมจำนวนที่ซื้อ  
การส่งสินค้าจะผูกกับซัพพลายเออ 1 รายและสามารถเติมสินค้าได้ทีเดียวหลายสินค้า  
-product มีรหัสสินค้า, รหัสสินค้าไม่ควรเปลี่ยนได้, สินค้า 1 ตัวอาจมี supplier ได้หลายราย , สินค้าแต่ละชิ้นควรมีแค่ 1 หมวดหมู่, มี status active,inactive,out 
-product จำนวนสินค้า สามารถเป็น 0 ได้
-ใบขาย จำนวนสินค้าไม่สามารถเป็น 0 ได้

**Entities**  
produc,
sale,
sale_item,
cetagory,
supplier,
delivery,
delivery_item

table customer อาจจะยังไม่ต้องมีตอนนี้ก็สามารถออกใบขายได้เหมือนกันในกรณีที่ร้านค้าไม่ได้มีการทำระบบสมาชิกเก็บข้อมูลลูกค้าไว้  
table user สำหรับพนักงานเว้นไว้ก่อน  

**Relationships**
product 1:N delivery_item
delivery 1:N delivery_item
product 1:N sale_item
sale 1:N sale_item
cetegory 1:N product
supplier 1:N delivery

**Key**  
product
id, product_code, name, quantity, unit_price, created_at, updated_at, created_by, updated_by, status,
description, cetegory_id

sale
id, created_at, updated_at, created_by, updated_by, status, payment_method, sale_no

cetegory
id, name, created_at, updated_at, created_by, updated_by, status

supplier
id, name, mobile_no, email, address,created_at, updated_at, created_by, updated_by

delivery
id, created_at, updated_at, created_by, updated_by, status, payment_method, delivery_no

sale_item
id, created_at, updated_at, created_by,
updated_by, status, product_id, quantity, unit_price, sale_id

delivery_item
id, created_at, updated_at, created_by,
updated_by, status, product_id, quantity, unit_price, delivery_id

**Create Table**
```
CREATE TABLE category (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE supplier (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    mobile_no VARCHAR(20),
    email VARCHAR(255),
    address TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT
);

CREATE TABLE product (
    id BIGSERIAL PRIMARY KEY,
    product_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    quantity NUMERIC(12,2) NOT NULL DEFAULT 0,
    unit_price NUMERIC(12,2) NOT NULL DEFAULT 0,

    description TEXT,
    category_id BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES category(id),

    CONSTRAINT chk_product_quantity
        CHECK (quantity >= 0),

    CONSTRAINT chk_product_unit_price
        CHECK (unit_price >= 0)
);

CREATE TABLE sale (
    id BIGSERIAL PRIMARY KEY,
    sale_no VARCHAR(50) NOT NULL UNIQUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    payment_method VARCHAR(30) NOT NULL
);

CREATE TABLE delivery (
    id BIGSERIAL PRIMARY KEY,
    delivery_no VARCHAR(50) NOT NULL UNIQUE,

    supplier_id BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    payment_method VARCHAR(30) NOT NULL,

    CONSTRAINT fk_delivery_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(id)
);

CREATE TABLE sale_item (
    id BIGSERIAL PRIMARY KEY,

    sale_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_sale_item_sale
        FOREIGN KEY (sale_id)
        REFERENCES sale(id),

    CONSTRAINT fk_sale_item_product
        FOREIGN KEY (product_id)
        REFERENCES product(id),

    CONSTRAINT chk_sale_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_sale_item_unit_price
        CHECK (unit_price >= 0)
);

CREATE TABLE delivery_item (
    id BIGSERIAL PRIMARY KEY,

    delivery_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_delivery_item_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES delivery(id),

    CONSTRAINT fk_delivery_item_product
        FOREIGN KEY (product_id)
        REFERENCES product(id),

    CONSTRAINT chk_delivery_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_delivery_item_unit_price
        CHECK (unit_price >= 0)
);
```

## Revision

```
CREATE TABLE category (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    
    CONSTRAINT chk_category_status_match
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

CREATE TABLE supplier (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    mobile_no VARCHAR(20),
    email VARCHAR(255),
    address TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT
);

CREATE TABLE product (
    id BIGSERIAL PRIMARY KEY,
    product_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    quantity NUMERIC(12,2) NOT NULL DEFAULT 0,
    unit_price NUMERIC(12,2) NOT NULL DEFAULT 0,

    description TEXT,
    category_id BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES category(id),

    CONSTRAINT chk_product_quantity
        CHECK (quantity >= 0),

    CONSTRAINT chk_product_unit_price
        CHECK (unit_price >= 0),
        
    CONSTRAINT chk_product_status_match
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'OUT'))
);

CREATE TABLE sale (
    id BIGSERIAL PRIMARY KEY,
    sale_no VARCHAR(50) NOT NULL UNIQUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    payment_method VARCHAR(30) NOT null,
    
    CONSTRAINT chk_sale_status_match
        CHECK (status IN ('COMPLETED', 'INCOMPLETED'))
);

CREATE TABLE delivery (
    id BIGSERIAL PRIMARY KEY,
    delivery_no VARCHAR(50) NOT NULL UNIQUE,

    supplier_id BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    payment_method VARCHAR(30) NOT NULL,

    CONSTRAINT fk_delivery_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(id),
        
    CONSTRAINT chk_delivery_status_match
        CHECK (status IN ('COMPLETED', 'INCOMPLETED'))
);

CREATE TABLE sale_item (
    id BIGSERIAL PRIMARY KEY,

    sale_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,

    CONSTRAINT fk_sale_item_sale
        FOREIGN KEY (sale_id)
        REFERENCES sale(id),

    CONSTRAINT fk_sale_item_product
        FOREIGN KEY (product_id)
        REFERENCES product(id),

    CONSTRAINT chk_sale_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_sale_item_unit_price
        CHECK (unit_price >= 0)
);

CREATE TABLE delivery_item (
    id BIGSERIAL PRIMARY KEY,

    delivery_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity NUMERIC(12,2) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_by BIGINT,

    CONSTRAINT fk_delivery_item_delivery
        FOREIGN KEY (delivery_id)
        REFERENCES delivery(id),

    CONSTRAINT fk_delivery_item_product
        FOREIGN KEY (product_id)
        REFERENCES product(id),

    CONSTRAINT chk_delivery_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_delivery_item_unit_price
        CHECK (unit_price >= 0)
);

CREATE TABLE product_supplier (
    id BIGSERIAL PRIMARY KEY,

    supplier_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,

    supplier_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    lead_time_days DECIMAL(4,1),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by BIGINT,
    updated_by BIGINT,

    CONSTRAINT fk_product_supplier_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES supplier(id),

    CONSTRAINT fk_product_supplier_product
        FOREIGN KEY (product_id)
        REFERENCES product(id),

    CONSTRAINT uq_product_supplier
        UNIQUE (supplier_id, product_id),

    CONSTRAINT chk_product_supplier_supplier_price
        CHECK (supplier_price >= 0),

    CONSTRAINT chk_product_supplier_lead_time
        CHECK (lead_time_days >= 0)
);
```

note: id กับพวก no ใช้เป็น surogant key เพื่อไม่ให้เวลาเกิดการเปลี่ยน no แล้วกระทบกับตารางอื่น (ช่วยเพิ่ม performance ในการทำ index เพราะ int compare เร็วกว่า string)

สิ่งแก้ไข

1. เพิ่ม table ใหม่ product_supplier แต่เดิม supplier -> delivery -> delivery_item บอกได้แค่ว่าสินค้าชิ้นนั้นนำเข้ามาจาก supplier ไหนบ้าง
แต่ไม่สามารถดูตั้งแต่แรกได้ว่า supplier เจ้าไหนมีขายสินค้าอะไรบ้างและสามารถสั่งจาก supplier นั้นได้หรือไม่
2. เพิ่มการ check status ที่สามารถลงได้ใน db กันมีค่าอื่นหลุดเข้ามาทำให้เกิดความสับสนและดีต่อระบบ distributed ในกรณีที่มีหลาย app หรือการทำพวก migrate, batch ช่วยป้องกันความผิดพลาดได้
3. ตัด status ออกจาก sale_item, delivery_item ออกตอนแรกคิดมาในกรณีที่ต้องการคืนสินค้าหรือมีปัญหาบางอย่างแต่ถ้าทำแบบนี้table sale status จะไม่สามารถบอกได้ว่า sale นี้ completed จริงไหม
ควรเพิ่ม table เพิ่มสำหรับรองรับเคสข้างต้นแยกออกไปเลย

## Experiment

ทดสอบรัน script ได้ผลตามที่คาด ai ทดสอบ happy path, fail path ได้ตามที่คาดไว้
 


