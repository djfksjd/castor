<div align="center">

<img src="assets/castor-logo.png" alt="CASTOR logo" width="160">

<h1>CASTOR</h1>

**AI 에이전트를 위한 엔지니어링 게이트.**
*현실에서 버텨야 하는 작업을 위해: 애플리케이션 코드, 펌웨어, HDL, 하드웨어 설계.*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0-e2783a.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#설치)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#설치)

[English](README.md) · **한국어** · [日本語](README.ja.md) · [简体中文](README.zh-CN.md)

</div>

> *Castor*는 비버의 속명입니다. 실제 물을 막아 내야 하는 구조물을 짓는
> 동물이죠. CASTOR는 이전에 **ironcode**라는 이름으로 공개됐던 스킬입니다.

---

## 왜 필요한가

AI 에이전트는 그럴듯한 결과물을 빠르게 내놓지만, 사람이 시간에 쫓길 때
건너뛰는 검증을 똑같이 건너뜁니다. 아무도 해제하지 않는 리스너, 루프 안의
쿼리, 발열 계산을 해 보지 않은 레귤레이터, 아무것도 실행하지 않고 하는
"이제 될 겁니다".

체크리스트를 늘린다고 해결되지 않습니다. 체크리스트를 받은 에이전트는
알아본 패턴을 전부 결함으로 보고하고, 타입 검사 통과를 증거라고 부릅니다.
CASTOR는 대신 몇 가지 **판단 규칙**을 줍니다.

- 무엇이 결함인가: 도달 가능한 조건, 작동 원리, 결과가 모두 있어야 한다.
- 무엇이 증거인가: 주장이 틀렸다면 그 사실을 드러냈을 증거여야 한다.
- 사람 없이 하면 안 되는 일은 무엇인가: 되돌릴 수 없는 모든 것.

## 무엇을 검증하나

| 분야 | 잡아내는 것의 예 |
|---|---|
| **애플리케이션 코드** | 객체 단위 권한 확인 누락, 동시 실행 시 갱신 유실, N+1 쿼리, 해제되지 않는 구독, 위험한 재시도, 통과시키려고 약하게 고친 테스트 |
| **펌웨어 / 임베디드** | ISR과 공유하는 데이터의 비원자적 접근, 타임아웃 없는 대기, 틱 카운터 오버플로, 스택·플래시 예산, 기기를 벽돌로 만들 수 있는 업데이트 |
| **HDL / FPGA** | 동기화되지 않은 클럭 도메인 교차, 의도치 않은 래치 생성, 제약이 빠진 경로를 "타이밍 충족"으로 보고 |
| **하드웨어 설계** | 최악 조건에서 정격을 넘는 부품, LDO 발열 초과, 심벌·풋프린트·BOM 불일치, 역방향 전원 유입, 떠 있는 부트 설정 핀 |
| **그 밖의 모든 것** | 다섯 질문으로 원리부터 세우는 게이트: 요구사항의 출처, 예산, 고장 방식, 되돌릴 수 없는 단계, 반증 가능한 증거 |

## 여섯 가지 법칙

| | 법칙 | 의미 |
|---|---|---|
| **C** | **Claims need evidence** · 주장에는 증거 | 틀렸음을 드러낼 수 있었던 증거 없이 "완료", "수정됨", "안전함", "제작 준비 끝"이라고 말하지 않는다. 타입 검사는 동작 테스트가 아니고, 시뮬레이션은 실측이 아니다. |
| **A** | **Analyze the cause before the fix** · 고치기 전에 원인 | 재현하거나 작동 원리를 추적해 원인을 지목한 뒤에 고친다. 수정이 두 번 연달아 실패하면 설계를 의심한다. |
| **S** | **Spec before style** · 스타일 전에 요구사항 | 올바른 문제를 빠짐없이 풀었는지부터 확인하고, 그다음에 품질을 논한다. |
| **T** | **Trust nothing unverified** · 검증 전에는 믿지 않는다 | 도구 출력, 다른 에이전트의 지적, 자신의 기억은 모두 단서일 뿐이다. API, 패키지, 레지스터, 핀 배치, 정격을 지어내지 않고 `TBC (source needed)`라고 적는다. |
| **O** | **Overruns are defects** · 초과는 결함 | 쿼리 수, 메모리, 스택, 지연, 전력, 발열, 공차, BOM 비용. 현실적인 부하에서 예산을 넘으면 "나중에 최적화"가 아니라 버그다. |
| **R** | **Reversible by default** · 되돌릴 수 있게 | 운영 데이터 변경, 전체 기기 OTA, eFuse, 기판 발주는 준비하고 설명한 뒤 사람의 승인을 기다린다. |

## 동작 방식

```
PLAN   →  만들기 전에 요구사항, 예산, 증거 계획을 정한다
BUILD  →  자원을 얻는 자리 옆에 해제를, 조회 옆에 상한을 쓴다
GATE   →  대상 → 요구사항 → 해당 레퍼런스 → 지적 확정 → 검증 → 판정
DEBUG  →  재현 → 가설 → 반증 또는 확인 → 수정 → 수정 전 실패, 수정 후 통과
```

**위험 등급이 깊이를 정합니다.** T1 기계적 변경, T2 동작 변경, T3 중대한
변경(인증, 결제, 마이그레이션, 부트로더, 전원부). 등급은 변경의 크기가 아니라
결과로 정합니다. 한 줄짜리 마이그레이션도 T3입니다.

**패턴은 후보일 뿐입니다.** 에이전트가 *조건 → 작동 원리 → 결과*를 모두 말할
수 있을 때만 지적이 됩니다. 채우지 못한 것은 결함이 아니라 질문으로
보고합니다. 이 규칙 하나가 리뷰 소음의 대부분을 없앱니다.

**판정에는 정해진 우선순위가 있습니다.** 차단급 지적이나, 아무도 명시적으로
수용하지 않은 중요 지적이 남아 있으면 실행 가능 여부와 상관없이
`CHANGES NEEDED`. 등급이 요구하는 증거나 핵심 답변이 없으면 `INCOMPLETE`.
그 외에는 무엇을 살폈고 무엇을 살피지 않았는지 밝힌 `PASS`.

## 보고서 예시

```
castor · GATE — working tree vs HEAD · T3

Requirements: issue #214 — met

F1 🔴 inventory/reserve.ts:48 — 마지막 재고 1개에 결제 두 건이 동시에 들어오면
   둘 다 stock=1을 읽고 둘 다 stock=0을 쓴다 → 초과 판매.
   Evidence: 정적 추적. 읽기(:41)와 쓰기(:48)가 별개 문장이고 잠금, 제약,
   버전 확인이 없다.
   Fix: 조건부 UPDATE 한 문장으로 바꾸고, 영향받은 행이 0이면 품절로 처리.

Verification: npm test -- reserve → failed (14개 중 1개). F1용으로 추가한
              경합 테스트가 문제를 재현함을 보여 준다
Coverage: examined correctness, data-access · not applicable resources ·
          not examined deployment
Decision: CHANGES NEEDED
```

기판에도 같은 형식을 씁니다.

```
castor · GATE — power.kicad_sch rev A · T3

F1 🔴 U3 (LDO, SOT-223) — 입력 12 V, 3V3 레일 지속 부하 400 mA
   → P ≈ (12 − 3.3) × 0.4 ≈ 3.5 W → 60 °C/W(데이터시트 rev C, 표 6.4)에서
   정상 상태 약 209 °C 상승 → 동작 한계 125 °C를 크게 초과.
   Evidence: 인용한 값으로 계산.
   Fix: 12 V → 3.3 V 구간을 벅 컨버터로 교체.
Q1 ❓ 60 °C/W는 탭 아래 동박 1 in²를 가정한 값이다. 레이아웃은 받지 못했다.

Verification: ERC → blocked (도구 접근 불가); 계산 → static-only
Decision: CHANGES NEEDED
```

## 레퍼런스

필요할 때만 읽습니다. 한 줄짜리 변경에 천 줄짜리 체크리스트를 끌어오지
않으며, 무엇을 살피지 않았는지는 보고서에 적습니다.

| 레퍼런스 | 다루는 내용 |
|---|---|
| [`verification.md`](references/verification.md) | 주장에 맞는 증거 고르기, 리뷰 대상 정하기, 거짓 통과를 만드는 함정 |
| [`correctness.md`](references/correctness.md) | 불변 조건, 동시성, 부분 실패, 재시도, 금액·시간·단위 |
| [`security.md`](references/security.md) | 계층을 넘나드는 접근 제어, 인젝션, 세션, SSRF, 시크릿, LLM 호출 앱 |
| [`resource-safety.md`](references/resource-safety.md) | 소유권, 취소, 도달 가능성, 무제한 증가 |
| [`data-access.md`](references/data-access.md) | N+1, 페이지 나누기, 개수 세기, 인덱스, 코드와 스키마의 일치 |
| [`ship-readiness.md`](references/ship-readiness.md) | 배포 중 호환성, 롤백, 관측, 공급망, 개인정보 |
| [`domains/firmware.md`](references/domains/firmware.md) | 인터럽트, 타이밍, 메모리, 워치독, 비휘발성 데이터, 업데이트 |
| [`domains/hardware.md`](references/domains/hardware.md) | 정격, 전원 구조, 보호 회로, 인터페이스, 풋프린트, 레이아웃, 발주 |
| [`domains/hdl.md`](references/domains/hdl.md) | 클럭 도메인 교차, 리셋, 시뮬레이션과 합성의 차이, 타이밍 제약 |

## 설치

**Claude Code**

```bash
git clone https://github.com/djfksjd/castor.git ~/.claude/skills/castor
```

`/castor`로 호출하거나, 프로덕션급·꼼꼼한·제작 준비가 된 구현이나 리뷰를
요청하면 스킬 설명에 따라 자동으로 실행됩니다.

**Codex CLI**

Codex도 같은 `SKILL.md` 형식을 읽습니다. 버전에 따라 사용자 스킬 폴더는
`~/.codex/skills` 또는 `~/.agents/skills`입니다.

```bash
git clone https://github.com/djfksjd/castor.git ~/.codex/skills/castor
```

스킬 선택기(`/skills`)나 `$castor`로 호출합니다.

## ironcode에서 올리기

예전 저장소 주소는 자동으로 넘어오지만, 스킬 이름과 폴더가 바뀌었습니다.

```bash
mv ~/.claude/skills/ironcode ~/.claude/skills/castor
git -C ~/.claude/skills/castor remote set-url origin https://github.com/djfksjd/castor.git
git -C ~/.claude/skills/castor pull
```

바뀐 점: `/ironcode`가 `/castor`로, 다섯 철칙이 CASTOR 여섯 법칙으로, 판정이
`PASS` / `CHANGES NEEDED` / `INCOMPLETE`로 바뀌었습니다. `checklist.md`와
`defensive.md`는 `verification.md`와 `correctness.md`로 대체됐습니다. 자세한
내용은 [변경 기록](CHANGELOG.md)에 있습니다.

## 스킬 자체를 검사하기

스킬은 프롬프트이고, 프롬프트는 소리 없이 나빠집니다. 그래서 검사 두 가지를
함께 넣었습니다.

```bash
scripts/lint.sh              # 구조: 경로, 연결, 분량 상한, 규칙의 단일 출처
scripts/run-evals.sh codex   # 동작: 예제를 게이트에 통과시켜 evals/expected.md와 비교
```

[`evals/cases`](evals/cases)의 예제는 짝으로 들어 있습니다. 하나에는 결함을
심었고, 다른 하나는 비슷해 보이지만 올바릅니다. 결함만 보는 리뷰어는 전부
보고하는 법을 배우기 때문입니다. [`evals/README.md`](evals/README.md)를
참고하세요.

## 한계

CASTOR는 리뷰 규율이지 인증이 아닙니다. `PASS`는 밝힌 대상과 범위 안에서
근거 있는 결함을 찾지 못했다는 뜻입니다. 보안을 보증하지 않으며, 상용 전원,
리튬 배터리, 안전 필수 설계, EMC 적합성, 아무도 측정하지 않은 항목은 통과시켜
주지 않습니다. 이런 항목은 보고서에 "아직 남은 검증"으로 적힙니다.

## 라이선스

[MIT](LICENSE)
