# Reflection — subqueries-and-exists-vs-in-vs-join

<!-- Written by me, once, after the lab is otherwise done. Not edited afterward — if understanding changes later, that's a new mistake/follow-up entry, not a rewrite of this. -->

## What I understand now, that I didn't going in

RANK() เรียงข้ามเลขที่ซ้ำ 1,1,3
DENSE_RANK() เรียงแบบต่อเลข 1,1,2
ROW NUMBER() เรียงแบบ unique 1,2,3

## What surprised me

planner เปลี่ยนแพลนตาม scale ข้อมูลที่มีอยู่

## What I'm still not sure about / would want to re-test

-


## Word

outer query 
inner query
derived table 
