# Epic: Shadow of Lanna: Midnight Rite

**Goal:** สองพี่น้องแท็กทีมเอาชีวิตรอดในโรงเรียนร้างล้านนา — น้องสาวใช้ไฟตะเกียงส่องสกัดผีและมุดช่องแคบ พี่ชายดันตู้หนักเปิดทางและขึงสายสิญจน์สะกดวิญญาณ เพื่อหยุดยั้งพิธีกรรมบูชายัญเลือดก่อนอรุณรุ่ง
**Brief:** `design/game-brief.md`
**Tier:** minimal

## Scope
1. ระบบควบคุมและสลับสองพี่น้อง (Sibling Switch/Follow) พร้อมแสงตะเกียงในความมืด
2. AI ผีล้านนา (ผีกะ/ผีโพง) ลาดตระเวน ตรวจจับแสง/เสียง และไล่ล่า
3. ระบบช่องเก็บของจำกัด (Grid Inventory) และการเก็บ/ใช้ไอเทม
4. ปริศนารหัสตุงล้านนา และประตูล็อกเชื่อมพื้นที่
5. จุดหลบซ่อนตัวตู้/โต๊ะ และการผูกสายสิญจน์ขวางประตู
6. เงื่อนไขชนะ/แพ้ หลบหนีหลังดับแท่นบูชา และหน้าจอ Game Over
7. ระบบรวมแสงตะเกียงสตั๊นผี (Lantern Focus)
8. ระบบขึงสายสิญจน์กั้นประตู (Sai Sin Ward)
9. อุปสรรคแท็กทีมสองพี่น้อง (Sibling Co-op Obstacles)
10. ระบบคุ้ยหาไอเทมตามลิ้นชักตู้โต๊ะ (Resource Scavenging)

## Build Order
1. `story-001-sibling-controller.md` (Done)
2. `story-002-spirit-ai.md` (Done)
3. `story-003-inventory-system.md` (Done)
4. `story-004-talisman-puzzle.md` (Done)
5. `story-005-hiding-and-wards.md` (Done)
6. `story-006-win-loss-loop.md` (Done)
7. `story-007-lantern-focus-mechanic.md` (Next)
8. `story-008-saisin-ward-mechanic.md`
9. `story-009-sibling-coop-obstacles.md`
10. `story-010-resource-scavenging.md`

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | sibling-controller | Logic | Done | N/A (minimal) |
| 002 | spirit-ai | Logic | Done | N/A (minimal) |
| 003 | inventory-system | UI | Done | N/A (minimal) |
| 004 | talisman-puzzle | Logic | Done | N/A (minimal) |
| 005 | hiding-and-wards | Integration | Done | N/A (minimal) |
| 006 | win-loss-loop | Integration | Done | N/A (minimal) |
| 007 | lantern-focus-mechanic | Visual/Feel | Done | N/A (minimal) |
| 008 | saisin-ward-mechanic | Integration | Done | N/A (minimal) |
| 009 | sibling-coop-obstacles | Logic/Integration | Done | N/A (minimal) |
| 010 | resource-scavenging | Integration | Done | N/A (minimal) |
