<div align="center">

# ⚔️ ironcode

**AIコーディングエージェントのためのプロダクション級エンジニアリングゲート。**

*セキュリティ、リソース安全性、バックエンドコスト、防御的コーディング、
そして「完了」の証拠まで — プロダクション級コードを生み出し守る一つの規律。*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#インストール--claude-code)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#インストール--codex-cli)

[English](README.md) · [한국어](README.ko.md) · **日本語** · [简体中文](README.zh-CN.md)

</div>

---

## なぜ必要か

AIエージェントはもっともらしいコードを速く書きます — そして人間が時間に
追われて省略するのと同じ検証を省略します: dispose されないストリーム、
ループ内のクエリ、空の `catch {}`、何も実行せずに言う「もう動くはずです」。

**ironcode** はスタイルガイドではなく*ゲート*です。省略されがちな検証を
強制し、観測可能な証拠なしに「完了」と宣言することを禁じます。

## 鉄の掟 (Iron Laws)

| # | 掟 | 意味 |
|---|-----|------|
| 1 | **主張の前に証拠** | テスト・ビルド・実行の出力なしに「完了/修正済み/動作する」は禁止。 |
| 2 | **スタイルの前に仕様** | まず*正しい問題*を解いたことを証明し、その後に品質を論じる。 |
| 3 | **修正の前に根本原因** | 再現し追跡してから直す。対症療法は失敗である。 |
| 4 | **外部意見の前に自己分析** | リンタ・ツール・他エージェントの指摘は実コードで検証してから採用。 |
| 5 | **コストは正確性の一部** | N+1クエリと無制限フェッチは「後で最適化」ではなく*欠陥*。 |

## 5つの品質次元

リファレンスファイルは**必要なときだけ**ロードされます — 1行の変更に
千行のチェックリストを持ち込みません。

| 次元 | リファレンス | 検出対象 |
|---|---|---|
| 🔐 セキュリティ | [`references/security.md`](references/security.md) | シークレット、インジェクション、認可/RLS、SSRF、OWASP Top 10 |
| 🧹 リソース安全性 | [`references/resource-safety.md`](references/resource-safety.md) | リークしたリスナー・ストリーム・タイマー・コントローラ、無制限キャッシュ |
| 💸 データアクセスとコスト | [`references/data-access.md`](references/data-access.md) | N+1、ページネーション欠如、オーバーフェッチ、スキーマ乖離、インデックス欠如 |
| 🛡️ 防御的コーディング | [`references/defensive.md`](references/defensive.md) | null/エッジケース、握りつぶされたエラー、レース、冪等性 |
| 🧭 保守性 | [`references/checklist.md`](references/checklist.md) | 命名、サイズ、重複、デッドコード — 完全なゲートチェックリスト付き |
| 🚀 リリース準備度 | [`references/ship-readiness.md`](references/ship-readiness.md) | リリース範囲: テスト戦略、可観測性、デプロイ互換性、サプライチェーン、プライバシー |

## 動作の仕組み

このスキルは**適応型**です — エージェントがどのモードにいるかを自己検出します:

```
PLAN   →  書く前に検証を設計に組み込む
BUILD  →  書きながらパターンを適用（リソース生成と同時に解放コードを書く）
GATE   →  仕様 → 診断 → 5次元 → 検証 → 証拠付きで報告
```

すべての指摘は具体的で実行可能です:

```
🔴 home_controller.dart:120 — 全行フェッチ(limit なし)、リビルドごとに再実行。
   Fix: キーセットページネーション + 多重リクエストガード + キャッシュ。
Verification: flutter analyze → 0 issues · make test → 250 passed
Verdict: CHANGES NEEDED
```

## インストール — Claude Code

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.claude/skills/ironcode
```

`/ironcode` で呼び出すか、*プロダクション級 / 厳密な / リークのない*
実装・レビューを依頼すると、スキルの説明により自動的にトリガーされます。

## インストール — Codex CLI

Codex CLI は同じオープンな `SKILL.md` スキル形式を読み込みます
(旧 `~/.codex/prompts` カスタムプロンプトは非推奨)。Codex のバージョンにより、
ユーザースキルディレクトリは `~/.codex/skills` または `~/.agents/skills` です:

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.codex/skills/ironcode
# または
git clone https://github.com/djfksjd/ironcode.git ~/.agents/skills/ironcode
```

スキルセレクタ(`/skills`)または `$ironcode` で呼び出します。

## 適用範囲

言語・スタック非依存の設計: Flutter/Dart、JS/TS、C#/Java/Kotlin、Go、Rust、
SQL/Postgres(Supabase RLS 含む)のパターンを提供。例は実際のプロダクション
インシデントに基づいています。詳細は各自のスタックに合わせて適用してください。

## 深刻度基準

| | 深刻度 | 処置 |
|---|---|---|
| 🔴 | セキュリティホール、データ損失、クラッシュ、リーク、無制限コスト | マージ前に修正 |
| 🟠 | 実バグ、強いにおい、エッジ処理の欠如 | マージ前に修正 |
| 🟡 | スタイル、些細な命名、任意のクリーンアップ | 都合の良いときに |
| 🔵 | 任意の改善 | 作者の判断 |

> 指摘は**深刻度 × 悪用可能性 × 影響範囲**で順位付けされます —
> 誇張も平坦化もしません。

## ライセンス

[MIT](LICENSE)
