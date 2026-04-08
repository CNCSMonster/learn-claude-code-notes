# s10: Team Protocols (团队协议)

## 一句话总结

**"Teammates need shared communication rules"** — 队友需要共享通信规则。请求审批 FSM + 队友状态机，建立标准化协作协议。

## 关键问题

### 1. FSM 是什么？s10 中有哪几个 FSM？

**FSM = Finite State Machine（有限状态机）** — 系统在一组有限状态间转换的数学模型。

**s10 中有两个 FSM**：

| FSM | 状态流转 | 归属 |
|-----|----------|------|
| 协议 FSM | pending → approved/rejected | 请求（request） |
| Teammate FSM | working/idle → shutdown | 队友（teammate） |

**关系**：协议 FSM 驱动 Teammate FSM
```
shutdown 请求 approved → teammate 状态变为 shutdown
```

### 2. 计划模式由谁决定触发和审批？

| | |
|---|---|
| 触发 | Teammate 自主决定（LLM 根据 prompt 判断） |
| 审批 | Lead 自主决定 approve/reject |
| 用户 | 通过指挥 Lead 间接控制 |

### 3. 通信结构？

```
User → Lead ↔ Teammate 1
            ↕
       Teammate 2
```

---

## ❓ 易误解点

**Q：s10 中有几个 FSM？**

A：两个。一个是**协议 FSM**（请求状态：pending → approved/rejected），归属于请求本身；另一个是**Teammate FSM**（队友状态：working/idle → shutdown），归属于队友。协议 FSM 的转换会驱动 Teammate FSM 的转换。

## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s10_team_protocols.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s10_team_protocols.py)

