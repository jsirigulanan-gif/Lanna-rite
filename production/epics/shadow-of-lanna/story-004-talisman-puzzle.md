# Story 004: talisman-puzzle

> **Epic**: Shadow of Lanna: Midnight Rite
> **Status**: Done
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-06

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 4`

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

- [x] ประตูเชื่อมระหว่างอาคารเรียนไม้กับลานพิธีมีสถานะล็อก (Locked) พร้อมสัญลักษณ์ยันต์ตุง
- [x] มีเบาะแสปริศนา (คัมภีร์ใบลาน) ให้ผู้เล่นสำรวจเพื่ออ่านลำดับทิศทางของตุง
- [x] เมื่อสำรวจประตูล็อก หน้าจอแก้ปริศนาตุงจะเปิดขึ้นมาให้ผู้เล่นเลือกหรือหมุนสัญลักษณ์ตามทิศทาง
- [x] เมื่อผู้เล่นใส่รหัสสัญลักษณ์ตุงถูกต้อง กลไกล็อกจะคลายออก ประตูเปลี่ยนสถานะเป็น Unlocked และเปิดทางเชื่อมสู่โซนใหม่ได้
- [x] หากกรอกผิดจะมีเสียงแจ้งเตือนและคงสถานะล็อกไว้เช่นเดิม

---

## Implementation Notes

- สร้าง `LockedDoor` เป็น `StaticBody2D` หรือ `Area2D` ที่มีตัวแปร `is_locked: bool`
- สร้างหน้าต่าง UI ปริศนา `TungPuzzle` ที่ส่ง Signal `puzzle_solved` เมื่อผู้เล่นกรอกค่าตรงกับ `correct_pattern`
- บันทึกสถานะการเปิดประตูไว้ในตัวจัดการสถานะฉาก

---

## Out of Scope

- [Story 006]: การเปิดประตูรั้วบานใหญ่เพื่อหนีรอดและจบเกม

---

## Files

- `src/puzzles/tung_puzzle.gd`
- `src/puzzles/tung_puzzle.tscn`
- `src/environment/locked_door.gd`
- `src/environment/locked_door.tscn`
- `tests/unit/puzzles/tung_puzzle_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic  
**Required evidence**: `tests/unit/puzzles/tung_puzzle_test.gd` (advisory at minimal)  
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/shadow-of-lanna/story-003-inventory-system.md`
- Unlocks: `production/epics/shadow-of-lanna/story-006-win-loss-loop.md`
