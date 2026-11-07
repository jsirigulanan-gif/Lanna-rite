# Epic: Shadow of Lanna: Midnight Rite

**Goal:** สองพี่น้องนักเรียน (พี่ชาย ม.4 และน้องสาว ม.2) ต้องเอาชีวิตรอดและเปิดโปงพิธีกรรมบูชายัญลึกลับประจำปีของหมู่บ้านกลางหุบเขาภาคเหนือ ที่เปลี่ยนโรงเรียนไม้เก่าและหมู่บ้านให้กลายเป็นแดนผีสิง
**Brief:** `design/game-brief.md`
**Tier:** minimal

## Scope
1. ระบบควบคุมและสลับสองพี่น้อง (Sibling Switch/Follow) พร้อมแสงตะเกียงในความมืด
2. AI ผีล้านนา (ผีกะ/ผีโพง) ลาดตระเวน ตรวจจับแสง/เสียง และไล่ล่า
3. ระบบช่องเก็บของจำกัด (Grid Inventory) และการเก็บ/ใช้ไอเทม
4. ปริศนารหัสตุงล้านนา และประตูล็อกเชื่อมพื้นที่
5. จุดหลบซ่อนตัวตู้/โต๊ะ และการผูกสายสิญจน์ขวางประตู
6. เงื่อนไขชนะ/แพ้ หลบหนีหลังดับแท่นบูชา และหน้าจอ Game Over

## Build Order
1. `story-001-sibling-controller.md`
2. `story-002-spirit-ai.md`
3. `story-003-inventory-system.md`
4. `story-004-talisman-puzzle.md`
5. `story-005-hiding-and-wards.md`
6. `story-006-win-loss-loop.md`

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | sibling-controller | Logic | Done | N/A (minimal) |
| 002 | spirit-ai | Logic | Done | N/A (minimal) |
| 003 | inventory-system | UI | Done | N/A (minimal) |
| 004 | talisman-puzzle | Logic | Done | N/A (minimal) |
| 005 | hiding-and-wards | Integration | Done | N/A (minimal) |
| 006 | win-loss-loop | Integration | Done | N/A (minimal) |
