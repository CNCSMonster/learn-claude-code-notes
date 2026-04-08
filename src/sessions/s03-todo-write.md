# s03: TodoWrite (待办写入)

## 一句话总结

**"An agent without a plan drifts"** — 没有计划的 agent 走哪算哪。通过带状态的 TodoManager 强制顺序聚焦，连续 3 轮不更新计划就注入 nag reminder 制造问责压力。

## 关键问题

### 1. 为什么需要 TodoWrite？

**问题**：多步任务中模型会丢失进度 -- 重复做过的事、跳步、跑偏。对话越长越严重，工具结果不断填满上下文，系统提示的影响力被稀释。

**解决**：TodoManager 提供**外部记忆**，将进度持久化到磁盘（不在上下文里）。Agent 不需要翻阅历史消息来回忆「做到哪了」，减少了对上下文的依赖。

### 2. TodoManager 的核心约束是什么？

**同一时间只允许一个 `in_progress`** -- 强制顺序聚焦，避免多任务并行导致的注意力分散。

```python
if in_progress_count > 1:
    raise ValueError("Only one task can be in_progress")
```

### 3. Nag Reminder 的工作机制？

**Nag** = 唠叨（英文：不停催促某人做某事）

**触发条件**：模型连续 3 轮以上不调用 `todo` 工具。

**注入方式**：在最后一个 user message 的 content 列表头部插入 `<reminder>` 标签。

```python
if rounds_since_todo >= 3 and messages:
    last = messages[-1]
    if last["role"] == "user" and isinstance(last.get("content"), list):
        last["content"].insert(0, {
            "type": "text",
            "text": "<reminder>Update your todos.</reminder>",
        })
```


## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s03_todo-write.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s03_todo-write.py)

