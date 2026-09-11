# Reflection — core-schema-keys-and-relationships

<!-- Written by me, once, after the lab is otherwise done. Not edited afterward — if understanding changes later, that's a new mistake/follow-up entry, not a rewrite of this. -->


## note

Pure junction/bridge: table มีแค่ fk จับคู่กัน  
Associative entity: junction table ที่มี attribute เป็นของตัวเอง สามารถโตขึ้นเป็น entity จริงจังที่หลังได้เมื่อมี relation เพิ่มขึ้น  
candidate key: ทุก column หรือกลุ่ม column ที่ unique พอจะเป็น pk ได้
alternate key: candidate key ที่ไม่ถูกเลือก

CHECK vs ENUM type vs lookup table  
check เขียนง่าย เปลี่ยนค่ายากต้อง alter table drop constranint แล้ว add ใหม่  
emun type เก็บใน storage compare เร็วกว่า เพราะเก็บเป็น int เพิ่มค่าใหม่ง่าย แต่เปลี่ยนเปลี่ยนกับลบค่าเก่ายาก  
lookup table: table แยกที่เก็บข้อมูล static แก้ง่าย ข้อเสียต้อง join ทุกครั้งทำให้ซับซ้อนเวลาใช้งาน ไม่เหมาะกับการกับอะไรง่ายๆแบบ status
