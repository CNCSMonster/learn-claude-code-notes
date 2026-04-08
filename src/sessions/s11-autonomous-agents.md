# s11: Autonomous Agents (自治 Agent)

## 一句话总结

**"Teammates scan the board and claim tasks themselves"** — 队友扫描看板自己认领任务。IDLE 轮询 + 自动认领 + 身份重注入，实现自组织团队。

## 关键问题

### 1. 自治性的体现？

**s10 vs s11 的核心区别**：

| 特性 | s10 | s11 |
|------|-----|-----|
| 任务分配 | Lead 手动指派 | 队友自己扫描看板认领 |
| 空闲行为 | 无 | 轮询收件箱 + 任务看板 |
| 工具集 | 12 个 | 14 个 (+idle, +claim_task) |
| 超时机制 | 无 | 60 秒空闲自动 shutdown |

**自治性体现**：
- 队友进入 IDLE 状态后，自动扫描 `.tasks/` 目录查找未认领的任务
- 找到 pending 状态、无 owner、未被阻塞的任务时，自动调用 `claim_task` 认领
- 无需 Lead 逐个分配任务，实现自组织

### 2. IDLE 阶段工作机制？

```python
def _idle_poll(self, name, messages):
    for _ in range(IDLE_TIMEOUT // POLL_INTERVAL):  # 60s / 5s = 12 次
        time.sleep(POLL_INTERVAL)  # 每 5 秒轮询一次

        # 1. 检查收件箱
        inbox = BUS.read_inbox(name)
        if inbox:
            messages.append({"role": "user",
                "content": f"<inbox>{inbox}</inbox>"})
            return True  # 有新消息，恢复 WORK 状态

        # 2. 扫描任务看板
        unclaimed = scan_unclaimed_tasks()
        if unclaimed:
            claim_task(unclaimed[0]["id"], name)
            messages.append({"role": "user",
                "content": f"<auto-claimed>Task #{unclaimed[0]['id']}: "
                           f"{unclaimed[0]['subject']}</auto-claimed>"})
            return True  # 认领到任务，恢复 WORK 状态

    return False  # 60 秒超时，进入 SHUTDOWN
```

**轮询内容**：
1. **收件箱**：检查是否有新消息
2. **任务看板**：扫描 `.tasks/task_*.json` 文件

**认领条件**：
- `status == "pending"`
- `owner` 为空
- `blockedBy` 为空

### 3. 身份重注入解决了什么问题？

**问题**：Context Compact (s06) 后，消息列表被压缩，Agent 可能忘记自己的身份。

**实现**：
```python
if len(messages) <= 3:  # 上下文过短
    messages.insert(0, {"role": "user",
        "content": f"<identity>You are '{name}', role: {role}, "
                   f"team: {team_name}. Continue your work.</identity>"})
```

### 4. 队友生命周期？

```
+-------+
| spawn |  ← Lead 创建
+---+---+
    |
    v
+-------+   tool_use     +-------+
| WORK  | <------------- |  LLM  |
+---+---+                +-------+
    |
    | stop_reason != tool_use
    v
+--------+
|  IDLE  |  每 5 秒轮询，持续最多 60 秒
+---+----+
    |
    +---> 收件箱有消息 -------------> 恢复 WORK
    |
    +---> 有未认领任务 -------------> 认领 -> 恢复 WORK
    |
    +---> 60 秒超时 ----------------> SHUTDOWN
```

---

## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s11_autonomous_agents.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s11_autonomous_agents.py)

