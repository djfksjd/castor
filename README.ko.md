<div align="center">

# ⚔️ ironcode

**AI 코딩 에이전트를 위한 프로덕션급 엔지니어링 게이트.**

*보안, 리소스 안전, 백엔드 비용, 방어적 코딩, 그리고 "완료"의 증거까지 —
프로덕션급 코드를 만들고 지키는 하나의 규율.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#설치--claude-code)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#설치--codex-cli)

[English](README.md) · **한국어** · [日本語](README.ja.md) · [简体中文](README.zh-CN.md)

</div>

---

## 왜 필요한가

AI 에이전트는 그럴듯한 코드를 빠르게 쓰지만, 사람이 시간에 쫓길 때 건너뛰는
바로 그 검증을 똑같이 건너뜁니다: dispose 안 된 스트림, 루프 안의 쿼리,
빈 `catch {}`, 아무것도 실행하지 않고 말하는 "이제 될 겁니다".

**ironcode**는 스타일 가이드가 아니라 *게이트*입니다. 건너뛰기 쉬운 검증을
강제하고, 관측 가능한 증거 없이 "완료"라고 말하는 것을 금지합니다.

## 철칙 (Iron Laws)

| # | 법칙 | 의미 |
|---|-----|------|
| 1 | **주장 전에 증거** | 테스트·빌드·실행 출력 없이 "완료/수정됨/동작함" 금지. |
| 2 | **스타일 전에 스펙** | 먼저 *올바른 문제*를 풀었는지 증명하고, 그 다음에 품질을 논한다. |
| 3 | **수정 전에 근본 원인** | 재현하고 추적한 뒤에 고친다. 증상 패치는 실패다. |
| 4 | **외부 의견 전에 자체 분석** | 린터·툴·다른 에이전트의 지적은 실제 코드로 검증한 후 채택. |
| 5 | **비용은 정확성의 일부** | N+1 쿼리와 무제한 fetch는 "나중에 최적화"가 아니라 *결함*이다. |

## 5대 품질 차원

레퍼런스 파일은 **필요할 때만** 로드됩니다 — 한 줄짜리 변경에 천 줄짜리
체크리스트를 끌어오지 않습니다.

| 차원 | 레퍼런스 | 잡아내는 것 |
|---|---|---|
| 🔐 보안 | [`references/security.md`](references/security.md) | 시크릿, 인젝션, 인가/RLS, SSRF, OWASP Top 10 |
| 🧹 리소스 안전 | [`references/resource-safety.md`](references/resource-safety.md) | 누수된 리스너·스트림·타이머·컨트롤러, 무제한 캐시 |
| 💸 데이터 접근·비용 | [`references/data-access.md`](references/data-access.md) | N+1, 페이지네이션 누락, 오버페치, 스키마 불일치, 인덱스 누락 |
| 🛡️ 방어적 코딩 | [`references/defensive.md`](references/defensive.md) | null/엣지 케이스, 삼켜진 에러, 레이스, 멱등성 |
| 🧭 유지보수성 | [`references/checklist.md`](references/checklist.md) | 네이밍, 크기, 중복, 죽은 코드 — 전체 게이트 체크리스트 포함 |
| 🚀 출시 준비도 | [`references/ship-readiness.md`](references/ship-readiness.md) | 릴리스 범위: 테스트 전략, 관측성, 배포 호환성, 공급망, 프라이버시 |

## 동작 방식

이 스킬은 **적응형**입니다 — 에이전트가 어떤 모드에 있는지 스스로 감지합니다:

```
PLAN   →  코드를 쓰기 전에 검증을 설계에 반영
BUILD  →  작성하면서 패턴 적용 (리소스를 만들 때 해제 코드를 같이 쓴다)
GATE   →  스펙 → 진단 → 5대 차원 → 검증 → 증거와 함께 보고
```

모든 지적은 구체적이고 실행 가능합니다:

```
🔴 home_controller.dart:120 — 전체 행 fetch(limit 없음), 리빌드마다 재실행.
   Fix: keyset 페이지네이션 + 중복 요청 가드 + 캐시.
Verification: flutter analyze → 0 issues · make test → 250 passed
Verdict: CHANGES NEEDED
```

## 설치 — Claude Code

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.claude/skills/ironcode
```

`/ironcode`로 호출하거나, *프로덕션급 / 꼼꼼한 / 누수 없는* 구현·리뷰를
요청하면 스킬 설명에 의해 자동으로 트리거됩니다.

## 설치 — Codex CLI

Codex CLI는 동일한 오픈 `SKILL.md` 스킬 포맷을 읽습니다(구 `~/.codex/prompts`
커스텀 프롬프트는 deprecated). Codex 버전에 따라 사용자 스킬 디렉터리는
`~/.codex/skills` 또는 `~/.agents/skills`입니다:

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.codex/skills/ironcode
# 또는
git clone https://github.com/djfksjd/ironcode.git ~/.agents/skills/ironcode
```

스킬 선택기(`/skills`) 또는 `$ironcode`로 호출합니다.

## 적용 범위

언어·스택 불문 설계: Flutter/Dart, JS/TS, C#/Java/Kotlin, Go, Rust,
SQL/Postgres(Supabase RLS 포함) 패턴을 제공합니다. 예시는 실제 프로덕션
사고에 기반하며, 세부 사항은 각자의 스택에 맞게 적용하세요.

## 심각도 기준

| | 심각도 | 처리 |
|---|---|---|
| 🔴 | 보안 구멍, 데이터 손실, 크래시, 누수, 무제한 비용 | 머지 전 수정 |
| 🟠 | 실제 버그, 강한 악취, 엣지 처리 누락 | 머지 전 수정 |
| 🟡 | 스타일, 사소한 네이밍, 선택적 정리 | 편할 때 |
| 🔵 | 선택적 개선 | 작성자 판단 |

> 지적은 **심각도 × 악용 가능성 × 폭발 반경**으로 정렬됩니다 — 부풀리지도,
> 뭉개지도 않습니다.

## 라이선스

[MIT](LICENSE)
