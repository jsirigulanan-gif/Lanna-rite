# Story 002: spirit-ai

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-06

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

- [x] ผีล้านนา (ผีกะ/ผีโพง) มีระบบสถานะ AI: PATROL (ลาดตระเวน), INVESTIGATE (ตรวจสอบเสียง/แสง), CHASE (ไล่ล่า), และ ATTACK (จู่โจม)
- [x] ผีมีขอบเขตการมองเห็น (Line of Sight ผ่าน RayCast2D) และตอบสนองต่อแสงตะเกียงของผู้เล่น
- [x] ผีตรวจจับเสียงฝีเท้าของผู้เล่นได้เมื่อผู้เล่นกดวิ่งในระยะใกล้
- [x] เมื่อผู้เล่นถูกโจมตี พลังชีวิต (Health) จะลดลง และตัวละครจะมีการสะบัดถอย (Knockback เล็กน้อย)
- [x] หากผู้เล่นหลุดพ้นสายตาและไม่มีเสียง ผีจะวนหาชั่วขณะก่อนกลับสู่เส้นทางลาดตระเวนเดิม

---

## Implementation Notes

- ใช้ `CharacterBody2D` หรือ `Area2D` ร่วมกับ `RayCast2D` สำหรับตรวจสอบการมองเห็นโดยไม่ทะลุกำแพง
- กำหนดกลุ่ม (Group) `player` สำหรับระบุตำแหน่งเป้าหมาย
- ใช้ Timer ในการเปลี่ยนสถานะระหว่างค้นหาและลาดตระเวน

---

## Out of Scope

- [Story 005]: การหยุดชะงักเมื่อเจอกลไกสายสิญจน์หรือการไม่เห็นผู้เล่นในตู้ซ่อน

---

## Files

- `src/entities/enemies/spirit_ai.gd`
- `src/entities/enemies/spirit_ai.tscn`
- `tests/unit/ai/spirit_ai_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic  
**Required evidence**: `tests/unit/ai/spirit_ai_test.gd` (advisory at minimal)  
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/shadow-of-lanna/story-001-sibling-controller.md`
- Unlocks: `production/epics/shadow-of-lanna/story-005-hiding-and-wards.md`
