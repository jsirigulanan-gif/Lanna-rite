# Story 001: sibling-controller

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-06

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 1`

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

- [x] ตัวละครหลักสามารถเคลื่อนที่ 8 ทิศทางด้วยความเร็วเดินปกติ และสามารถกดวิ่งโดยใช้เกจความเหนื่อย (Stamina)
- [x] มีระบบสลับการควบคุม (Switch Character) ระหว่างพี่ชาย (ม.4) และน้องสาว (ม.2) ด้วยปุ่มเฉพาะ
- [x] ตัวละครที่ไม่ได้ถูกควบคุมจะเข้าสู่โหมดเดินตาม (Follow AI) รักษาระยะห่างที่เหมาะสมและหยุดเมื่อใกล้ตัวละครหลัก
- [x] ตัวละครน้องสาวมีระบบตะเกียงส่องสว่าง (PointLight2D) ท่ามกลางความมืด พร้อมเกจระดับน้ำมันตะเกียง
- [x] เมื่อน้ำมันตะเกียงหมด รัศมีแสงจะหรี่ลงเหลือเพียงความมืดสลัวและเปิดรับอันตรายจากวิญญาณ

---

## Implementation Notes

- สร้าง `CharacterBody2D` สำหรับตัวละครทั้งสองตัว โดยกำหนด Collision Layer และ Mask สำหรับ Player
- ใช้ `PointLight2D` สำหรับแสงตะเกียง และผูกกับการแสดงผล CanvasModulate (บรรยากาศมืด)
- จัดการ State เคลื่อนที่ด้วย Finite State Machine แบบง่าย (IDLE, WALK, RUN, FOLLOW)

---

## Out of Scope

- [Story 002]: พฤติกรรม AI ศัตรูและการตรวจจับ
- [Story 003]: ระบบช่องสัมภาระและไอเทมเติมน้ำมัน

---

## Files

- `src/entities/player/player_sibling.gd`
- `src/entities/player/lantern_light.gd`
- `src/entities/player/sibling_manager.gd`
- `src/entities/player/player_sibling.tscn`
- `src/entities/player/sibling_manager.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic  
**Required evidence**: `tests/unit/player/sibling_controller_test.gd` (advisory at minimal)  
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/shadow-of-lanna/story-002-spirit-ai.md`, `production/epics/shadow-of-lanna/story-003-inventory-system.md`
