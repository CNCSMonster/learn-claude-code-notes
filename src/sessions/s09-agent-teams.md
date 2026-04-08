# s09: Agent Teams (Agent 团队)

## 一句话总结

**"When the task is too big for one, delegate to teammates"** — 任务太大，分给队友。Lead + teammates + JSONL 收件箱，建立多 Agent 协作基础。

## 关键问题

### 1. 发送和读取权限？

```
每个 agent 可以：
✓ 给任何 teammate 发送消息（只要知道名字）
✓ 只能读取自己的 inbox
```

### 2. Lead 和队友的工具有何区别？

**Lead 有 9 个工具**：
```python
TOOLS = [
    {"name": "bash", ...}, {"name": "read_file", ...},
    {"name": "write_file", ...}, {"name": "edit_file", ...},
    {"name": "spawn_teammate", ...}, {"name": "list_teammates", ...},
    {"name": "send_message", ...}, {"name": "read_inbox", ...},
    {"name": "broadcast", ...},
]
```

**队友只有 6 个工具**（少了 `spawn_teammate`、`list_teammates`、`broadcast`）：
```python
def _teammate_tools(self) -> list:
    return [
        {"name": "bash", ...}, {"name": "read_file", ...},
        {"name": "write_file", ...}, {"name": "edit_file", ...},
        {"name": "send_message", ...}, {"name": "read_inbox", ...},
    ]
```

### 3. 队友如何知道其他成员？

**队友没有 `list_teammates` 工具**，由 Lead 在 spawn 的 prompt 中告知：
```python
spawn_teammate(
    name="alice",
    role="coder",
    prompt="You are alice, the coder. Bob is the reviewer. "
           "When you finish coding, send bob a message for review."
)
```

### 4. 完整通信图？

```
┌─────────────────────────────────────────────────────────┐
│                      Lead (领导)                         │
│  工具：spawn_teammate, list_teammates, send_message     │
│        read_inbox, broadcast                            │
└───────────────┬─────────────────────┬───────────────────┘
                │                     │
      send_message         send_message
      to="alice"           to="bob"
                │                     │
                v                     v
┌───────────────────────┐ ┌───────────────────────┐
│    Alice (Coder)      │ │   Bob (Reviewer)      │
│  工具：send_message   │ │  工具：send_message   │
│        read_inbox     │ │        read_inbox     │
└───────────────────────┘ └───────────────────────┘
                │                     │
                └──────────┬──────────┘
                           │
                 send_message
                 to="lead"
                           ↓
              ┌────────────────────────┐
              │  lead.jsonl (Lead 邮箱) │
              └────────────────────────┘
```

### 5. JSONL 的作用？

**JSONL** = 每行是一个完整 JSON。

```
{"type": "message", "from": "alice", "content": "hello"}
{"type": "message", "from": "bob", "content": "hi"}
```

**优势**：追加写入无需读改写整个文件。

---

## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s09_agent_teams.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s09_agent_teams.py)

