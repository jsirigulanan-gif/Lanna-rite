# Story 006: win-loss-loop

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-06

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 6`

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

- [x] มี `GameManager` กลางที่คอยตรวจจับสถานะพลังชีวิตของตัวละครและระดับน้ำมันตะเกียง
- [x] เมื่อพลังชีวิตของพี่ชายหรือน้องสาวลดลงเหลือ 0 เกมจะเข้าสู่สถานะ `GAME_OVER` และแสดงหน้าจอ Game Over สไตล์ย้อนยุค
- [x] หน้าจอ Game Over มีปุ่ม "ลองใหม่อีกครั้ง" เพื่อโหลดฉากใหม่กลับมายังจุดเริ่มต้น
- [x] มีแท่นบูชายัญ (Altar Shrine) ที่ลานศาลผี เมื่อผู้เล่นเข้าไปกดทำลายเครื่องเซ่น/ดับไฟ จะทริกเกอร์เงื่อนไขปลดผนึกประตูรั้วหมู่บ้าน
- [x] เมื่อสองพี่น้องวิ่งผ่านประตูรั้วหมู่บ้าน เกมจะเปลี่ยนสู่สถานะ `VICTORY` พร้อมแสดงหน้าจอบทสรุปการหลบหนีรอดชีวิต

---

## Implementation Notes

- สร้าง Autoload หรือ Node `GameManager` ควบคุม Game Flow (Playing, GameOver, Victory)
- หน้าจอ `GameOverScreen` และ `VictoryScreen` ใช้ CanvasLayer พร้อม Animation fade-in
- เชื่อมต่อ Signal จาก `AltarShrine` และ `PlayerSibling` เข้าสู่ `GameManager`

---

## Out of Scope

- เนื้อเรื่องส่วนขยายหรือฉากจบแบบหลายตอน (Multi-ending) นอกเหนือจากการรอดชีวิต

---

## Files

- `src/core/game_manager.gd`
- `src/environment/altar_shrine.gd`
- `src/environment/altar_shrine.tscn`
- `src/ui/screens/game_over_screen.gd`
- `src/ui/screens/game_over_screen.tscn`
- `src/ui/screens/victory_screen.gd`
- `src/ui/screens/victory_screen.tscn`
- `tests/integration/gameplay/win_loss_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration  
**Required evidence**: `tests/integration/gameplay/win_loss_test.gd` OR playtest doc in `production/qa/evidence/win-loss-evidence.md`  
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/shadow-of-lanna/story-004-talisman-puzzle.md`, `production/epics/shadow-of-lanna/story-005-hiding-and-wards.md`
- Unlocks: None (MVP Complete)
