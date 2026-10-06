<div align="center">

<img src="assets/castor-logo.png" alt="CASTOR logo" width="160">

<h1>CASTOR</h1>

**AI エージェントのためのエンジニアリングゲート。**
*現実で持ちこたえる必要がある仕事のために：アプリケーションコード、ファームウェア、HDL、ハードウェア設計。*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0-e2783a.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#インストール)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#インストール)

[English](README.md) · [한국어](README.ko.md) · **日本語** · [简体中文](README.zh-CN.md)

</div>

> *Castor* はビーバーの属名です。本物の水をせき止める構造物を作る動物です。
> CASTOR は以前 **ironcode** という名前で公開されていました。

---

## なぜ必要か

AI エージェントはもっともらしい成果物を素早く出しますが、人が時間に追われて
省く確認を同じように省きます。誰も解除しないリスナー、ループ内のクエリ、
熱計算をしていないレギュレータ、何も実行せずに言う「これで動くはずです」。

チェックリストを長くしても直りません。チェックリストを渡されたエージェントは
見つけたパターンをすべて欠陥として報告し、型チェックの通過を証拠と呼びます。
CASTOR が与えるのは少数の**判断ルール**です。

- 何が欠陥か：到達可能な条件、仕組み、結果がそろっていること。
- 何が証拠か：主張が誤りならそれを示せたはずの証拠であること。
- 人なしでしてはいけないことは何か：元に戻せないことすべて。

## 何を検証するか

| 分野 | 検出するものの例 |
|---|---|
| **アプリケーションコード** | オブジェクト単位の認可漏れ、並行実行での更新消失、N+1 クエリ、解除されない購読、危険なリトライ、通すために弱められたテスト |
| **ファームウェア / 組み込み** | ISR と共有するデータへの非アトミックなアクセス、タイムアウトのない待機、ティックの桁あふれ、スタックとフラッシュの予算、機器を文鎮化させうる更新 |
| **HDL / FPGA** | 同期化されていないクロックドメイン交差、意図しないラッチ生成、制約のないパスを「タイミング達成」と報告すること |
| **ハードウェア設計** | 最悪条件で定格を超える部品、LDO の熱超過、シンボル・フットプリント・BOM の不一致、逆流給電、浮いているストラップピン |
| **それ以外** | 5 つの問いで原理から組み立てるゲート：要求の出どころ、予算、故障の仕方、元に戻せない手順、反証できる証拠 |

## 6 つの法則

| | 法則 | 意味 |
|---|---|---|
| **C** | **Claims need evidence** · 主張には証拠 | 誤りを示せたはずの証拠なしに「完了」「修正済み」「安全」「製造可能」と言わない。型チェックは動作テストではなく、シミュレーションは実測ではない。 |
| **A** | **Analyze the cause before the fix** · 修正の前に原因 | 再現するか仕組みを追跡し、原因を特定してから直す。修正が 2 回続けて失敗したら設計を疑う。 |
| **S** | **Spec before style** · スタイルの前に仕様 | まず正しい問題をすべて解いているかを確かめ、それから品質を論じる。 |
| **T** | **Trust nothing unverified** · 検証するまで信じない | ツールの出力、他のエージェントの指摘、自分の記憶はどれも手がかりにすぎない。API、パッケージ、レジスタ、ピン配置、定格を作り出さず、`TBC (source needed)` と書く。 |
| **O** | **Overruns are defects** · 超過は欠陥 | クエリ数、メモリ、スタック、遅延、電力、熱、公差、BOM コスト。現実的な負荷で予算を超えるなら、それは「後で最適化」ではなくバグである。 |
| **R** | **Reversible by default** · 元に戻せることを基本に | 本番データの変更、全機器への OTA、eFuse、基板の発注は、準備と説明をしたうえで人の承認を待つ。 |

## 仕組み

```
PLAN   →  作る前に、要求・予算・証拠の計画を決める
BUILD  →  取得の隣に解放を、取得クエリの隣に上限を書く
GATE   →  対象 → 仕様 → 該当リファレンス → 指摘の確定 → 検証 → 判定
DEBUG  →  再現 → 仮説 → 反証または確認 → 修正 → 修正前は失敗、修正後は成功
```

**リスク階層が深さを決めます。** T1 機械的な変更、T2 動作の変更、T3 重大な
変更（認証、決済、マイグレーション、ブートローダ、電源段）。階層は変更の
大きさではなく結果で決まります。1 行のマイグレーションも T3 です。

**パターンは候補にすぎません。** エージェントが *条件 → 仕組み → 結果* を
すべて述べられたときだけ指摘になります。埋められないものは欠陥ではなく質問
として報告します。この 1 つのルールがレビューのノイズの大半を取り除きます。

**判定には決まった優先順位があります。** ブロッキングの指摘、または誰も明示的に
受け入れていない重要な指摘が残っていれば、実行できたかどうかにかかわらず
`CHANGES NEEDED`。階層が求める証拠や重要な回答が欠けていれば `INCOMPLETE`。
それ以外は、何を見て何を見なかったかを明記した `PASS`。

## レポートの例

```
castor · GATE — working tree vs HEAD · T3

Requirements: issue #214 — met

F1 🔴 inventory/reserve.ts:48 — 最後の 1 個に対する 2 件の同時決済がどちらも
   stock=1 を読み、どちらも stock=0 を書く → 在庫超過の注文。
   Evidence: 静的な追跡。読み取り (:41) と書き込み (:48) は別の文で、ロックも
   制約もバージョン確認もない。
   Fix: 条件付き UPDATE 1 文にし、影響行数 0 を売り切れとして扱う。

Verification: npm test -- reserve → failed (14 件中 1 件)。F1 のために追加した
              競合テストが問題を再現することを示す
Coverage: examined correctness, data-access · not applicable resources ·
          not examined deployment
Decision: CHANGES NEEDED
```

基板でも同じ形式です。

```
castor · GATE — power.kicad_sch rev A · T3

F1 🔴 U3 (LDO, SOT-223) — 入力 12 V、3V3 レールの持続負荷 400 mA
   → P ≈ (12 − 3.3) × 0.4 ≈ 3.5 W → 60 °C/W（データシート rev C、表 6.4）で
   定常状態の上昇は約 209 °C → 動作上限 125 °C を大きく超える。
   Evidence: 引用した値からの計算。
   Fix: 12 V → 3.3 V の降圧を降圧コンバータに置き換える。
Q1 ❓ 60 °C/W はタブ下の銅箔 1 in² を前提とした値。レイアウトは提供されていない。

Verification: ERC → blocked (ツールにアクセスできない); 計算 → static-only
Decision: CHANGES NEEDED
```

## リファレンス

必要なときだけ読み込みます。1 行の変更で千行のチェックリストを引き込むことは
なく、見なかった範囲はレポートに書かれます。

| リファレンス | 内容 |
|---|---|
| [`verification.md`](references/verification.md) | 主張に合う証拠の選び方、レビュー対象の定め方、偽りの成功を生む落とし穴 |
| [`correctness.md`](references/correctness.md) | 不変条件、並行性、部分的な失敗、リトライ、金額・時刻・単位 |
| [`security.md`](references/security.md) | 層をまたぐアクセス制御、インジェクション、セッション、SSRF、シークレット、LLM を呼ぶアプリ |
| [`resource-safety.md`](references/resource-safety.md) | 所有権、キャンセル、到達可能性、際限のない増加 |
| [`data-access.md`](references/data-access.md) | N+1、ページネーション、件数取得、インデックス、コードとスキーマの一致 |
| [`ship-readiness.md`](references/ship-readiness.md) | デプロイ中の互換性、ロールバック、可観測性、サプライチェーン、プライバシー |
| [`domains/firmware.md`](references/domains/firmware.md) | 割り込み、タイミング、メモリ、ウォッチドッグ、不揮発データ、更新 |
| [`domains/hardware.md`](references/domains/hardware.md) | 定格、電源ツリー、保護、インターフェース、フットプリント、レイアウト、製造発注 |
| [`domains/hdl.md`](references/domains/hdl.md) | クロックドメイン交差、リセット、シミュレーションと合成の差、タイミング制約 |

## インストール

**Claude Code**

```bash
git clone https://github.com/djfksjd/castor.git ~/.claude/skills/castor
```

`/castor` で呼び出すか、本番品質の、厳密な、あるいは製造に出せる実装や
レビューを依頼すれば、スキルの説明に基づいて自動的に起動します。

**Codex CLI**

Codex も同じ `SKILL.md` 形式を読みます。バージョンによりユーザースキルの
ディレクトリは `~/.codex/skills` または `~/.agents/skills` です。

```bash
git clone https://github.com/djfksjd/castor.git ~/.codex/skills/castor
```

スキルセレクタ（`/skills`）または `$castor` で呼び出します。

## ironcode からの移行

以前のリポジトリ URL は転送されますが、スキル名とフォルダ名が変わりました。

```bash
mv ~/.claude/skills/ironcode ~/.claude/skills/castor
git -C ~/.claude/skills/castor remote set-url origin https://github.com/djfksjd/castor.git
git -C ~/.claude/skills/castor pull
```

変更点：`/ironcode` は `/castor` に、5 つの鉄則は CASTOR の 6 つの法則に、判定は
`PASS` / `CHANGES NEEDED` / `INCOMPLETE` になりました。`checklist.md` と
`defensive.md` は `verification.md` と `correctness.md` に置き換えられました。
詳しくは[変更履歴](CHANGELOG.md)をご覧ください。

## スキル自体のテスト

スキルはプロンプトであり、プロンプトは静かに劣化します。そのため 2 種類の
確認を同梱しています。

```bash
scripts/lint.sh              # 構造：パス、ルーティング、分量の上限、ルールの単一の定義元
scripts/run-evals.sh codex   # 動作：フィクスチャをゲートにかけ、evals/expected.md と照合
```

[`evals/cases`](evals/cases) のフィクスチャは対になっています。片方には欠陥を
仕込み、もう片方は似て見えても正しいものです。欠陥しか見ないレビュアーは
何でも報告するようになるからです。[`evals/README.md`](evals/README.md) を
参照してください。

## 限界

CASTOR はレビューの規律であり、認証ではありません。`PASS` は、明示した対象と
範囲の中で根拠のある欠陥が見つからなかったという意味です。セキュリティを
保証するものではなく、商用電源、リチウム電池、安全上重要な設計、EMC 適合、
誰も測定していない項目を合格にすることはありません。それらはレポートに
「未完了の検証」として記載されます。

## ライセンス

[MIT](LICENSE)
