<div align="center">

<img src="assets/castor-logo.png" alt="CASTOR logo" width="160">

<h1>CASTOR</h1>

**面向 AI 智能体的工程关卡。**
*为必须在现实中站得住的工作而设：应用代码、固件、HDL 与硬件设计。*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0-e2783a.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757.svg)](#安装)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-skill-10a37f.svg)](#安装)

[English](README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · **简体中文**

</div>

> *Castor* 是河狸的属名：一种修筑必须挡得住真水的建筑的动物。
> CASTOR 此前以 **ironcode** 的名字发布。

---

## 为什么需要

AI 智能体能很快产出看起来合理的成果，却会跳过人在赶工时同样会跳过的检查：
没人移除的监听器、循环里的查询、没算过热耗的稳压器、什么都没运行就说的
“现在应该可以了”。

加长检查清单解决不了这个问题。拿到清单的智能体会把认出的每个模式都报告成
缺陷，并把类型检查通过称为证据。CASTOR 给出的是少量**判断规则**：

- 什么算缺陷：可达的触发条件、机制和后果三者齐备。
- 什么算证据：如果结论是错的，它本可以把错误暴露出来。
- 什么事不能在没有人的情况下做：一切无法撤销的操作。

## 检查什么

| 领域 | 能发现的问题示例 |
|---|---|
| **应用代码** | 对象级授权缺失、并发下的更新丢失、N+1 查询、未释放的订阅、不安全的重试、为了通过而被削弱的测试 |
| **固件 / 嵌入式** | 与 ISR 共享数据的非原子访问、没有超时的等待、节拍计数回绕、栈与闪存预算、可能让设备变砖的升级 |
| **HDL / FPGA** | 未同步的跨时钟域信号、意外推断出的锁存器、把无约束路径报告为“时序收敛” |
| **硬件设计** | 最坏情况下超出额定值的器件、LDO 热耗超限、符号/封装/BOM 不一致、反向灌电、悬空的配置引脚 |
| **其他任何工作** | 用五个问题从原理出发搭建关卡：需求来源、预算、失效方式、不可逆步骤、可证伪的证据 |

## 六条法则

| | 法则 | 含义 |
|---|---|---|
| **C** | **Claims need evidence** · 结论要有证据 | 没有本可证明其错误的证据，就不说“完成”“已修复”“安全”“可以投板”。类型检查不是行为测试，仿真不是实测。 |
| **A** | **Analyze the cause before the fix** · 先找原因再修复 | 复现或追踪机制，指出原因，然后再改。连续两次修复失败，就该质疑设计。 |
| **S** | **Spec before style** · 先需求后风格 | 先确认解决的是正确的问题，而且是全部，再谈质量。 |
| **T** | **Trust nothing unverified** · 未经验证不采信 | 工具输出、其他智能体的结论、自己的记忆都只是线索。不编造 API、软件包、寄存器、引脚定义或额定值，而是写上 `TBC (source needed)`。 |
| **O** | **Overruns are defects** · 超支即缺陷 | 查询次数、内存、栈、延迟、功耗、发热、公差、BOM 成本。在真实负载下超出预算就是 bug，而不是“以后再优化”。 |
| **R** | **Reversible by default** · 默认可撤销 | 修改生产数据、全量 OTA、烧写 eFuse、下单制板：先准备并说明，然后等待人的批准。 |

## 工作方式

```
PLAN   →  动手之前确定需求、预算和取证计划
BUILD  →  在获取资源的地方写下释放，在读取的地方写下上限
GATE   →  对象 → 需求 → 相关参考 → 确立问题 → 验证 → 判定
DEBUG  →  复现 → 假设 → 证伪或确认 → 修复 → 修复前失败、修复后通过
```

**风险等级决定深度。** T1 机械性改动，T2 行为改动，T3 重大改动（认证、支付、
迁移、引导加载程序、功率级）。等级取决于后果而不是改动大小：一行迁移语句
也是 T3。

**模式只是候选。** 只有当智能体能完整说出*触发条件 → 机制 → 后果*时，它才
成为问题。补不全的部分以疑问而不是缺陷的形式报告。仅这一条规则就去掉了
大部分评审噪音。

**判定有固定的优先级。** 只要还有阻断级问题，或者没有人明确接受的重要问题
未解决，不论能否运行任何东西，都是 `CHANGES NEEDED`。等级所要求的证据或关键
答复缺失则是 `INCOMPLETE`。其余情况为 `PASS`，并注明检查了什么、没检查什么。

## 报告示例

```
castor · GATE — working tree vs HEAD · T3

Requirements: issue #214 — met

F1 🔴 inventory/reserve.ts:48 — 针对最后一件库存的两个并发结算都读到
   stock=1，又都写入 stock=0 → 超卖。
   Evidence: 静态追踪。读取 (:41) 与写入 (:48) 是两条独立语句，没有锁、
   约束或版本检查。
   Fix: 改为单条条件更新，并把影响行数为 0 视为售罄。

Verification: npm test -- reserve → failed (14 项中 1 项)。说明为 F1 添加的
              竞态测试能复现该问题
Coverage: examined correctness, data-access · not applicable resources ·
          not examined deployment
Decision: CHANGES NEEDED
```

同样的格式用于电路板：

```
castor · GATE — power.kicad_sch rev A · T3

F1 🔴 U3 (LDO, SOT-223) — 输入 12 V，3V3 电源轨持续负载 400 mA
   → P ≈ (12 − 3.3) × 0.4 ≈ 3.5 W → 按 60 °C/W（数据手册 rev C，表 6.4）
   稳态温升约 209 °C → 远超 125 °C 的工作上限。
   Evidence: 由引用数值计算得出。
   Fix: 12 V → 3.3 V 这一级改用降压转换器。
Q1 ❓ 60 °C/W 以散热焊盘下 1 in² 铜箔为前提；未提供布局。

Verification: ERC → blocked (无法使用工具); 计算 → static-only
Decision: CHANGES NEEDED
```

## 参考文件

按需加载。一行改动不会引入上千行的检查清单，没有检查的范围会写在报告里。

| 参考文件 | 内容 |
|---|---|
| [`verification.md`](references/verification.md) | 为结论选择匹配的证据、确定评审对象、导致虚假通过的陷阱 |
| [`correctness.md`](references/correctness.md) | 不变量、并发、部分失败、重试、金额/时间/单位 |
| [`security.md`](references/security.md) | 跨层访问控制、注入、会话、SSRF、密钥、调用 LLM 的应用 |
| [`resource-safety.md`](references/resource-safety.md) | 所有权、取消、可达性、无界增长 |
| [`data-access.md`](references/data-access.md) | N+1、分页、计数、索引、代码与数据库结构的一致性 |
| [`ship-readiness.md`](references/ship-readiness.md) | 发布期间的兼容性、回滚、可观测性、供应链、隐私 |
| [`domains/firmware.md`](references/domains/firmware.md) | 中断、时序、内存、看门狗、非易失数据、升级 |
| [`domains/hardware.md`](references/domains/hardware.md) | 额定值、电源树、保护、接口、封装、布局、投板 |
| [`domains/hdl.md`](references/domains/hdl.md) | 跨时钟域、复位、仿真与综合的差异、时序约束 |

## 安装

**Claude Code**

```bash
git clone https://github.com/djfksjd/castor.git ~/.claude/skills/castor
```

用 `/castor` 调用，或者直接要求生产级、严谨或可投板的实现与评审，技能会
根据其描述自动触发。

**Codex CLI**

Codex 读取同样的 `SKILL.md` 格式。视版本而定，用户技能目录为
`~/.codex/skills` 或 `~/.agents/skills`：

```bash
git clone https://github.com/djfksjd/castor.git ~/.codex/skills/castor
```

通过技能选择器（`/skills`）或 `$castor` 调用。

## 从 ironcode 升级

旧的仓库地址会自动跳转，但技能名称和目录名已经改变：

```bash
mv ~/.claude/skills/ironcode ~/.claude/skills/castor
git -C ~/.claude/skills/castor remote set-url origin https://github.com/djfksjd/castor.git
git -C ~/.claude/skills/castor pull
```

变化：`/ironcode` 改为 `/castor`；五条铁律变为 CASTOR 六条法则；判定改为
`PASS` / `CHANGES NEEDED` / `INCOMPLETE`；`checklist.md` 和 `defensive.md` 由
`verification.md` 和 `correctness.md` 取代。详见[更新日志](CHANGELOG.md)。

## 测试技能本身

技能就是提示词，而提示词会悄悄退化。因此随附两项检查：

```bash
scripts/lint.sh              # 结构：路径、路由、篇幅上限、规则的唯一出处
scripts/run-evals.sh codex   # 行为：让样例过一遍关卡，再对照 evals/expected.md
```

[`evals/cases`](evals/cases) 中的样例成对出现：一个埋入了缺陷，另一个看起来
相似但其实正确，因为只见过缺陷的评审者会学会什么都报告。参见
[`evals/README.md`](evals/README.md)。

## 局限

CASTOR 是一种评审纪律，不是认证。`PASS` 表示在声明的对象和范围内没有发现
证据充分的缺陷。它不构成安全保证，也不会放行市电、锂电池、安全攸关的设计、
EMC 合规，或任何没有人实际测量过的项目。这些会在报告中列为“尚欠的验证”。

## 许可证

[MIT](LICENSE)
