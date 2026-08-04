<div align="center">

# ⚔️ ironcode

**面向 AI 编码代理的生产级工程门禁。**

*安全、资源安全、后端成本、防御性编码，以及"完成"的证据 —
一套产出并守护生产级代码的纪律。*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#安装--claude-code)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#安装--codex-cli)

[English](README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · **简体中文**

</div>

---

## 为什么需要它

AI 代理能快速写出貌似合理的代码 —— 但也会跳过人类在时间压力下跳过的
那些检查：未释放的流、循环中的查询、空的 `catch {}`、什么都没运行就说
"现在应该可以了"。

**ironcode** 不是风格指南，而是一道*门禁*。它强制执行容易被跳过的检查，
并禁止在没有可观测证据的情况下宣称"完成"。

## 铁律 (Iron Laws)

| # | 铁律 | 含义 |
|---|-----|------|
| 1 | **先有证据，再下结论** | 没有新鲜的测试/构建/运行输出，禁止说"完成/已修复/能用"。 |
| 2 | **先对规格，再谈风格** | 先证明解决的是*正确的问题*，然后才评论质量。 |
| 3 | **先找根因，再动手改** | 复现并追踪后再修复。治标不治本即为失败。 |
| 4 | **先自我分析，再采纳外部意见** | 对 linter、工具、其他代理的发现，须对照实际代码验证后采纳。 |
| 5 | **成本即正确性** | N+1 查询和无界拉取是*缺陷*，不是"以后再优化"。 |

## 五大质量维度

参考文件**按需加载** —— 一行的改动绝不会拉进上千行的检查清单。

| 维度 | 参考 | 捕获内容 |
|---|---|---|
| 🔐 安全 | [`references/security.md`](references/security.md) | 密钥、注入、授权/RLS、SSRF、OWASP Top 10 |
| 🧹 资源安全 | [`references/resource-safety.md`](references/resource-safety.md) | 泄漏的监听器、流、定时器、控制器、无界缓存 |
| 💸 数据访问与成本 | [`references/data-access.md`](references/data-access.md) | N+1、缺失分页、过度拉取、模式漂移、缺失索引 |
| 🛡️ 防御性编码 | [`references/defensive.md`](references/defensive.md) | 空值/边界情况、被吞掉的错误、竞态、幂等性 |
| 🧭 可维护性 | [`references/checklist.md`](references/checklist.md) | 命名、大小、重复、死代码 —— 附完整门禁清单 |
| 🚀 发布就绪度 | [`references/ship-readiness.md`](references/ship-readiness.md) | 发布范围：测试策略、可观测性、部署兼容性、供应链、隐私 |

## 工作方式

该技能是**自适应的** —— 它会检测代理当前所处的模式：

```
PLAN   →  写代码前把检查设计进去
BUILD  →  边写边应用模式（创建资源的同时写好释放代码）
GATE   →  规格 → 诊断 → 五维度 → 验证 → 附证据报告
```

每条发现都具体且可执行：

```
🔴 home_controller.dart:120 — 拉取全部行（无 limit），每次重建都重新执行。
   Fix: 键集分页 + 在途请求防护 + 缓存。
Verification: flutter analyze → 0 issues · make test → 250 passed
Verdict: CHANGES NEEDED
```

## 安装 — Claude Code

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.claude/skills/ironcode
```

用 `/ironcode` 调用，或直接要求*生产级 / 严格 / 无泄漏*的实现或评审 ——
技能会根据其描述自动触发。

## 安装 — Codex CLI

Codex CLI 读取同样的开放 `SKILL.md` 技能格式（旧的 `~/.codex/prompts`
自定义提示词已弃用）。取决于 Codex 版本，用户技能目录为 `~/.codex/skills`
或 `~/.agents/skills`：

```bash
git clone https://github.com/djfksjd/ironcode.git ~/.codex/skills/ironcode
# 或
git clone https://github.com/djfksjd/ironcode.git ~/.agents/skills/ironcode
```

通过技能选择器（`/skills`）或 `$ironcode` 调用。

## 适用范围

设计上与语言和技术栈无关：提供 Flutter/Dart、JS/TS、C#/Java/Kotlin、Go、
Rust、SQL/Postgres（含 Supabase RLS）的模式。示例源于真实的生产事故，
细节请结合自己的技术栈应用。

## 严重度标准

| | 严重度 | 处置 |
|---|---|---|
| 🔴 | 安全漏洞、数据丢失、崩溃、泄漏、无界成本 | 合并前修复 |
| 🟠 | 真实缺陷、强烈坏味道、缺失边界处理 | 合并前修复 |
| 🟡 | 风格、次要命名、可选清理 | 方便时处理 |
| 🔵 | 可选改进 | 作者决定 |

> 发现按**严重度 × 可利用性 × 爆炸半径**排序 —— 不夸大，也不压平。

## 许可证

[MIT](LICENSE)
