# Story 005: hiding-and-wards

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-06

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 5`

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

- [x] มีวัตถุจุดซ่อนตัวในฉาก (ตู้ไม้ / ใต้โต๊ะเรียน) ที่ผู้เล่นสามารถกด Interact เพื่อเข้าไปหลบซ่อนได้
- [x] เมื่อตัวละครเข้าไปหลบซ่อน สถานะตัวละครจะเปลี่ยนเป็น `HIDDEN` ปิดการมองเห็นและไม่ส่งเสียงฝีเท้า
- [x] AI ศัตรู (จาก Story 002) จะยกเลิกสถานะไล่ล่าหากผู้เล่นเข้าไปซ่อนตัวก่อนที่ศัตรูจะประชิดถึงตัว
- [x] ผู้เล่นสามารถนำไอเทม "สายสิญจน์" มาติดตั้งที่กรอบประตูห้องได้
- [x] เมื่อศัตรูเดินชนเขตสายสิญจน์ ศัตรูจะถูกผลักถอยหลังและติดสถานะ Stun ชั่วคราว (เช่น 5 วินาที) ก่อนที่สายสิญจน์จะสลายไป

---

## Implementation Notes

- สร้าง `HidingSpot` เป็น `Area2D` จัดการการซ่อนตัวละคร ย้ายตำแหน่งกล้อง และควบคุมมุมมองแคบๆ จากในตู้
- สร้าง `SaiSinBarrier` เป็นตัวกั้นเส้นทางที่มี Area2D ตรวจจับกลุ่ม `enemy` และสั่งคำสั่งผลักถอยกลับใน AI

---

## Out of Scope

- [Story 006]: การหลบหนีและฉากจบของเกม

---

## Files

- `src/environment/hiding_spot.gd`
- `src/environment/hiding_spot.tscn`
- `src/items/sai_sin_barrier.gd`
- `src/items/sai_sin_barrier.tscn`
- `tests/integration/gameplay/hiding_ward_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration  
**Required evidence**: `tests/integration/gameplay/hiding_ward_test.gd` OR playtest doc in `production/qa/evidence/hiding-ward-evidence.md`  
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/shadow-of-lanna/story-002-spirit-ai.md`, `production/epics/shadow-of-lanna/story-003-inventory-system.md`
- Unlocks: `production/epics/shadow-of-lanna/story-006-win-loss-loop.md`
