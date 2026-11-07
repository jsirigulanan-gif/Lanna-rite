# Story 008: saisin-ward-mechanic

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Core
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 2 & 4`

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

- [x] มีไอเทม "ม้วนด้ายสายสิญจน์อาคม" (Sai Sin Cord) ในกระเป๋าเก็บของ
- [x] เมื่อควบคุมพี่ชายและยืนใกล้กรอบประตู จะมีข้อความแจ้งเตือนกด `[E] ขึงสายสิญจน์ป้องกันผี`
- [x] เมื่อขึงแล้ว จะเกิดแนวด้ายสายสิญจน์สีขาวเรืองแสงขวางประตู พร้อมแสงสีขาวนวล
- [x] ผีกะ (`SpiritAI3D`) จะไม่สามารถก้าวข้ามผ่านแนวกั้นสายสิญจน์นี้ได้ โดยจะถูกผลักถอยหลังและต้องเปลี่ยนเส้นทาง
- [x] ผู้เล่น (พี่ชายและน้องสาว) สามารถก้าวข้ามผ่านได้ตามปกติ

---

## Implementation Notes

- สร้าง `src/environment/props/sai_sin_ward_3d.gd` & `.tscn` สืบทอดจาก `StaticBody3D` / `Area3D`
- กำหนด Collision Mask ให้กั้นเฉพาะ Layer 4 (Enemies) โดยไม่กั้น Layer 2 (Player)
- เพิ่มเอฟเฟกต์แสง `OmniLight3D` สีขาวนวลเมื่อขึงสำเร็จ

---

## Out of Scope

- [Story 009]: ระบบผลักตู้และมุดช่องแคบของสองพี่น้อง

---

## Files

- `src/environment/props/sai_sin_ward_3d.gd`
- `src/environment/props/sai_sin_ward_3d.tscn`
- `src/items/saisin_cord.tres`
