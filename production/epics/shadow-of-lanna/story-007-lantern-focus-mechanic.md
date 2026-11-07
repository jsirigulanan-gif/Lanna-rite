# Story 007: lantern-focus-mechanic

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Core
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-07

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 1 & 4`

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

- [x] เมื่อควบคุมน้องสาว สามารถกดคลิกขวา (RMB) หรือปุ่ม `F` เพื่อเปิดโหมดรวมแสงตะเกียง (Focus Light Beam)
- [x] เมื่อเปิดโหมด Focus ลำแสง `SpotLight3D` จะสว่างจ้าขึ้น 2 เท่า ระยะส่องไกลขึ้น และมุมลำแสงแคบลงเพื่อเล็งทิศทาง
- [x] อัตราการใช้น้ำมันตะเกียงในขณะเปิดโหมด Focus จะผลาญเร็วกว่าปกติ 3 เท่า และยกเลิกทันทีเมื่อน้ำมันหมด
- [x] หากลำแสง Focus ส่องกระทบร่างของผีกะ (`SpiritAI3D`) ผีจะเอามือบังหน้าและเข้าสู่สถานะ `STUNNED` หยุดนิ่งเป็นเวลา 3 วินาที
- [x] มีเสียงเอฟเฟกต์ผีกรีดร้องและประกายแสงเมื่อผีถูกแสงไฟสตั๊น

---

## Implementation Notes

- เพิ่มฟังก์ชัน `set_focused(focused: bool)` ใน `lantern_light_3d.gd` เพื่อปรับค่า `light_energy`, `spot_range`, `spot_angle`
- ใช้ `RayCast3D` หรือ `ShapeCast3D` จากตะเกียงเพื่อตรวจจับศัตรูในกลุ่ม `enemies`
- เรียกใช้เมธอด `stun(duration)` ใน `spirit_ai_3d.gd` เมื่อโดนแสงตะเกียง

---

## Out of Scope

- [Story 008]: ระบบขึงสายสิญจน์ของพี่ชาย

---

## Files

- `src/entities/player/lantern_light_3d.gd`
- `src/entities/enemies/spirit_ai_3d.gd`
- `src/audio/audio_manager.gd`
