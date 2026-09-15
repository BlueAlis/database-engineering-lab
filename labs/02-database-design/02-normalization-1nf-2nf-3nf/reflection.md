# Reflection — normalization-1nf-2nf-3nf

<!-- Written by me, once, after the lab is otherwise done. Not edited afterward — if understanding changes later, that's a new mistake/follow-up entry, not a rewrite of this. -->


## note

Functional Dependency รู้ A แล้วรู้ B ได้ด้วย  
1NF หนึ่ง cell = หนึ่งค่า (Atomic Value)  
2NF Non-key ต้องขึ้นกับ Key ทั้งหมด ไม่ใช่แค่บางส่วน ถ้ายังมีอยู่เรียก Partial Dependency  
3NF Non-key ไม่ควรขึ้นกับ Non-key ถ้ายังมีอยู่เรียก Transitive Dependency  
anomaly ปัญหาที่เกิดจากความซ้ำซ้อนของ data update, insert, delete  
  
  
word  
materialized view  
view table  
reporting/summary table
