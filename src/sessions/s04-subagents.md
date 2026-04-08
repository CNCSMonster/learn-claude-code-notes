# s04: Subagents (子代理)

## 一句话总结

**"Break big tasks down; each subtask gets a clean context"** — 大任务拆小，每个小任务干净的上下文。Subagent 以 `messages=[]` 启动，运行独立循环，只返回摘要文本，保持父 Agent 上下文清洁。

## 关键问题

### 1. 为什么需要 Subagents？

**问题**：Agent 工作越久，messages 数组越胖。每次读文件、跑命令的输出都永久留在上下文里。

**场景**："这个项目用什么测试框架？" 可能要读 5 个文件，但父 Agent 只需要一个词："pytest"。

**解决**：Subagent 承担探索性工作，只返回浓缩的摘要。

### 2. Subagent 的上下文隔离如何实现？

**独立 messages 数组**：
```python
def run_subagent(prompt: str) -> str:
    sub_messages = [{"role": "user", "content": prompt}]  # 从零开始
    for _ in range(30):  # safety limit
        response = client.messages.create(...)
        sub_messages.append({"role": "assistant", "content": response.content})
        # ... 执行工具，追加结果 ...
    # 整个消息历史直接丢弃，只返回摘要
    return "".join(b.text for b in response.content if hasattr(b, "text"))
```

**父 Agent 视角**：Subagent 只是一个返回字符串的 `task` 工具。

### 3. 工具权限如何控制？

**父 Agent 工具** = 子 Agent 工具 + `task` 工具

```python
PARENT_TOOLS = CHILD_TOOLS + [
    {"name": "task",
     "description": "Spawn a subagent with fresh context.",
     "input_schema": {...}}
]
```

**禁止递归**：Subagent 没有 `task` 工具，防止无限生成子代理。


## ❓ 易误解点

**Q：Subagent 的消息历史会保留吗？**

A：不会。Subagent 的完整 `messages[]` 在运行结束后直接丢弃，只返回最终的摘要文本给父 Agent。这是保持父 Agent 上下文清洁的关键。

## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s04_subagents.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s04_subagents.py)

