# Story 010: resource-scavenging

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Core
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-07

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

- [x] โต๊ะครูและตู้ลิ้นชักในห้องเรียนสามารถกด `[E] เพื่อค้นหาของ` ได้
- [x] เมื่อค้นหา จะมีเสียงลิ้นชักไม้เลื่อนเปิด และสุ่ม/ดรอปไอเทมออกมา (ขวดน้ำมันตะเกียง หรือม้วนสายสิญจน์)
- [x] ไอเทมที่พบสามารถกดเก็บเข้ากระเป๋า 8 ช่องได้ทันที
- [x] หลังการค้นหา วัตถุจะเปลี่ยนสถานะเป็น "ค้นแล้ว (ว่างเปล่า)" และมีสเตตลิ้นชักไม้เปิดค้างไว้
- [x] หากกระเป๋าเต็ม จะมีข้อความแจ้งเตือน "ช่องเก็บของเต็ม"

---

## Implementation Notes

- สร้าง `src/environment/props/scavenge_container_3d.gd` & `.tscn` สืบทอดจาก `Area3D`
- เชื่อมต่อกับ `InventoryGrid` เมื่อผู้เล่นเก็บไอเทม
- เล่นเสียงไม้เปิด `drawer_creak` ผ่าน `AudioManager`

---

## Out of Scope

- [Story 006]: เงื่อนไขการชนะและหนีรอด

---

## Files

- `src/environment/props/scavenge_container_3d.gd`
- `src/environment/props/scavenge_container_3d.tscn`
- `src/audio/audio_manager.gd`
