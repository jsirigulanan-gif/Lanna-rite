# Story 003: inventory-system

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Core
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-06

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 2`

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
- N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From GDD `design/game-brief.md`, scoped to this story:*

- [x] มีระบบช่องสัมภาระแบบ Grid จำกัดจำนวน (เช่น 8 ช่อง) แสดงผลผ่านหน้าต่าง UI
- [x] ผู้เล่นสามารถกดเปิด/ปิดหน้าต่างช่องสัมภาระได้ด้วยปุ่มเฉพาะ (เช่น ปุ่ม Tab หรือ I)
- [x] สามารถหยิบไอเทมที่วางอยู่ในฉาก (World Item) เข้าสู่ช่องว่างในกระเป๋าได้ หากช่องเต็มจะแสดงข้อความแจ้งเตือน
- [x] มีเมนูคำสั่งสำหรับไอเทมแต่ละชิ้น: ใช้ (Use), ตรวจสอบ (Examine), และ ทิ้ง (Drop)
- [x] การใช้ไอเทมส่งผลต่อสถานะของตัวละคร เช่น น้ำมันตะเกียงช่วยเติมเกจแสง และยาช่วยฟื้นฟูพลังชีวิต

---

## Implementation Notes

- สร้าง Custom Resource `ItemData` สืบทอดจาก `Resource` เพื่อเก็บข้อมูลชื่อ คำอธิบาย ไอคอน และประเภทไอเทม
- UI สัมภาระสร้างด้วย Control Nodes (`GridContainer`, `TextureRect`, `PanelContainer`)
- เชื่อม Signal การกดใช้ไอเทมกับ `sibling_manager.gd`

---

## Out of Scope

- [Story 004]: การใช้ไอเทมชิ้นส่วนยันต์ปลดล็อกประตูเชื่อมพื้นที่

---

## Files

- `src/items/item_data.gd`
- `src/items/world_item.gd`
- `src/items/world_item.tscn`
- `src/ui/inventory/inventory_grid.gd`
- `src/ui/inventory/inventory_grid.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI  
**Required evidence**: a retained screenshot of each screen touched, in `production/qa/evidence/inventory-ui.png`  
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/shadow-of-lanna/story-001-sibling-controller.md`
- Unlocks: `production/epics/shadow-of-lanna/story-004-talisman-puzzle.md`, `production/epics/shadow-of-lanna/story-005-hiding-and-wards.md`
