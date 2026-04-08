# s06: Context Compact (上下文压缩)

## 一句话总结

**"Context will fill up; you need a way to make room"** — 上下文总会满，要有办法腾地方。三层压缩策略为无限会话腾出空间。

## 关键问题

### 1. 三层压缩分别指什么？

**三层压缩**：
1. **Micro Compact（微型压缩）**: 替换旧 tool_result 为占位符（每轮静默执行）
2. **Auto Compact（自动压缩）**: token 超限时，保存对话 + LLM 总结（自动触发）
3. **Manual Compact（手动压缩）**: 模型调用 `compact` 工具时执行压缩（手动触发）

**关键理解**：Layer 2 和 Layer 3 是同一套逻辑（都调用 `auto_compact`），区别只是触发方式（自动 vs 手动）。

### 2. Micro Compact 做了什么？

**目标**：替换旧的 tool_result 为占位符，减少 token 消耗。

**策略**：
- 保留最近 3 个 tool_result（`KEEP_RECENT = 3`）
- 更早的结果替换为 `"[Previous: used {tool_name}]"`
- **例外**：`read_file` 的结果不压缩（**原文档未提及**——因为文件内容是参考资料，压缩后会导致模型重新读文件，浪费 token）

```python
def micro_compact(messages: list) -> list:
    # 遍历所有 user message 中的 tool_result
    for msg_idx, msg in enumerate(messages):
        if msg["role"] == "user" and isinstance(msg.get("content"), list):
            for part_idx, part in enumerate(msg["content"]):
                if isinstance(part, dict) and part.get("type") == "tool_result":
                    # 压缩 tool_result 内容
                    # ...
```

**防御性编程**：使用 `isinstance` 检查类型，避免崩溃。

### 3. Auto Compact 何时触发？

**触发条件**：当 `estimate_tokens(messages) > 50000` 时自动触发。

**执行流程**：
1. **保存对话**：完整消息历史保存到 `.transcripts/transcript_{timestamp}.jsonl`
2. **LLM 总结**：让模型总结对话（包含：已完成什么、当前状态、关键决策）
3. **替换消息**：所有 messages 替换为一条摘要消息

```python
def auto_compact(messages: list) -> list:
    # 1. 保存完整对话到磁盘
    TRANSCRIPT_DIR.mkdir(exist_ok=True)
    transcript_path = TRANSCRIPT_DIR / f"transcript_{int(time.time())}.jsonl"
    # 2. 让 LLM 总结对话
    summary = client.messages.create(..., 
        "Summarize this conversation for continuity. Include: "
        "1) What was accomplished, 2) Current state, 3) Key decisions made.")
    # 3. 替换所有消息为摘要
    return [{"role": "user", 
             "content": f"[Conversation compressed. Transcript: {transcript_path}]\n\n{summary}"}]
```

**效果**：
```
压缩前：messages = [msg1, msg2, ..., msg100]  # ~50000 tokens
压缩后：messages = [summary_msg]              # ~500 tokens
```

### 4. Manual Compact 如何触发？

**触发方式**：模型主动调用 `compact` 工具。

```python
# 模型调用 compact 工具
{"type": "tool_use", "name": "compact", "input": {"focus": "当前任务进度"}}

# agent_loop 检测到 manual_compact
if manual_compact:
    print("[manual compact]")
    messages[:] = auto_compact(messages)  # 和 Auto Compact 相同逻辑
    return  # 压缩后退出，下一轮从摘要继续
```

**使用场景**：
- 用户主动要求："上下文太长了，压缩一下"
- 模型判断需要压缩时

### 5. Message Schema 详解？（补充）

**为什么需要理解这个？**

`micro_compact` 需要用 `isinstance` 检查，因为 API 的 `content` 类型是动态的：

**Message 结构**：
```python
{
    "role": "user" | "assistant",
    "content": str | list  # 字符串或 ContentBlock 列表
}
```

**ContentBlock 类型**：

| 位置 | type | 说明 | content 类型 |
|------|------|------|-------------|
| User | `text` | 文本消息 | 字符串 |
| User | `image` | 图片 | 对象 (base64) |
| User | `document` | 文档 (PDF/TXT) | 对象 (base64/text) |
| User | `tool_result` | 工具结果 | 字符串 **或** 列表 |
| Assistant | `text` | 文本回复 | 字符串 |
| Assistant | `tool_use` | 工具调用 | 对象 |

**嵌套层级**（最多 3 层）：
```
Level 0: message.content (列表)
   │
   └─ Level 1: content[n] (ContentBlock)
         │
         └─ tool_result.content (列表，仅多模态时)
               │
               └─ Level 2: content[m] (原子元素，不能再是列表)
```

**为什么 micro_compact 需要 `isinstance` 检查？**
- `content` 可能是字符串（普通消息）或列表（多工具/多模态）
- `tool_result.content` 可能是字符串或列表（多模态结果）
- 需要安全地遍历，避免对非列表类型调用列表操作

### 6. 三层压缩流程图？

```
每轮循环
   │
   ├─→ [Layer 1: micro_compact] ──→ 替换旧 tool_result 为占位符（静默）
   │
   ├─→ [检查：tokens > 50000?]
   │       │
   │       ├─ no → 继续
   │       │
   │       └─ yes → [Layer 2: auto_compact]
   │                   ├─ 保存到 .transcripts/
   │                   ├─ LLM 总结
   │                   └─ 替换 messages 为摘要
   │
   └─→ [模型调用 compact 工具？]
           │
           └─ yes → [Layer 3: manual compact]
                       └─ 同 Layer 2 逻辑
```

---

## 📚 官方文档参考

- [Anthropic API - Messages](https://docs.anthropic.com/en/api/messages)
- [Tool Use Guide](https://docs.anthropic.com/en/docs/build-with-claude/tool-use)
- [Vision (多模态)](https://docs.anthropic.com/en/docs/build-with-claude/vision)

---

## ❓ 易误解点

**Q：`message.content` 是什么类型？**

A：可能是字符串或列表。当一次调用多个工具时，结果是列表；普通文本消息是字符串。

**Q：`tool_result.content` 是什么类型？**

A：同样可能是字符串或列表。多模态结果（如图片 + 文字）是列表，纯文本结果是字符串。`micro_compact` 需要用 `isinstance` 检查来安全处理这两种情况。

**Q：为什么 `read_file` 的结果不压缩？**

A：因为 `read_file` 的输出是参考资料（文件内容），压缩后会丢失信息，导致模型需要重新读取文件，反而浪费 token。这是代码中的设计巧思，原文档未提及。

## 🔗 原文位置

- 代码实现：[learn-claude-code/agents/s06_context_compact.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s06_context_compact.py)

