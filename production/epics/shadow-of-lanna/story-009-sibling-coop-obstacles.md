# Story 009: sibling-coop-obstacles

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Core
> **Type**: Logic/Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 3`

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

- [x] มีตู้ไม้สักหนักขวางทางเดิน ซึ่งขึ้นข้อความแจ้งว่า "หนักเกินไปสำหรับน้องสาว — ต้องให้พี่ชายดัน"
- [x] เมื่อควบคุมพี่ชาย สามารถกด `[E] ค้างไว้เพื่อดันตู้` ตู้จะค่อยๆ เลื่อนถอยหลังเปิดทางเดิน พร้อมเสียงไม้เสียดสีกับพื้น
- [x] มีช่องระบายอากาศแคบๆ ที่ผนังห้องเรียน ซึ่งขึ้นข้อความแจ้งว่า "ตัวใหญ่เกินไป — น้องสาวเท่านั้นที่มุดได้"
- [x] เมื่อควบคุมน้องสาว สามารถกด `[E] เพื่อมุดลอดช่องแคบ` ลอดข้ามเข้าไปในห้องที่ล็อกตาย
- [x] น้องสาวสามารถสำรวจสลักกลอนจากด้านในเพื่อปลดล็อกประตูให้พี่ชายเดินตามเข้ามาได้

---

## Implementation Notes

- สร้าง `src/environment/props/pushable_wardrobe_3d.gd` & `.tscn` ตรวจสอบ `body.sibling_role == PlayerSibling3D.SiblingRole.BROTHER`
- สร้าง `src/environment/props/crawl_vent_3d.gd` & `.tscn` ตรวจสอบ `body.sibling_role == PlayerSibling3D.SiblingRole.SISTER`
- ใช้ Tween เคลื่อนย้ายตำแหน่งตู้และตัวละครอย่างนุ่มนวล

---

## Out of Scope

- [Story 010]: ระบบคุ้ยหาไอเทมตามโต๊ะตู้

---

## Files

- `src/environment/props/pushable_wardrobe_3d.gd`
- `src/environment/props/pushable_wardrobe_3d.tscn`
- `src/environment/props/crawl_vent_3d.gd`
- `src/environment/props/crawl_vent_3d.tscn`
