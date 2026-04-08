# s01: The Agent Loop (Agent 循环)

## 一句话总结

**"One loop & Bash is all you need"** -- 一个工具 + 一个循环 = 一个 Agent。

## 关键问题

### 1. Agent Loop 的核心思想是什么？

**核心**：建立**模型与真实世界的连接**。语言模型本身只能推理，无法执行实际操作。通过一个简单的循环，将模型的 tool_use 请求与实际执行连接起来。

### 2. Agent Loop 的工作流程？

```
+--------+      +-------+      +---------+
|  User  | ---> |  LLM  | ---> |  Tool   |
| prompt |      |       |      | execute |
+--------+      +---+---+      +----+----+
                    ^                |
                    |   tool_result  |
                    +----------------+
```

**步骤**：
1. 用户 prompt 作为第一条消息加入 messages 列表
2. 发送 messages + tools 定义给 LLM
3. 追加助手响应到 messages
4. 如果 `stop_reason != "tool_use"`，循环结束
5. 执行每个 tool_use，收集结果
6. 将结果作为 user 消息追加到 messages
7. 回到步骤 2

### 3. stop_reason 的作用？

**控制循环退出**：
- `stop_reason == "tool_use"`：模型请求调用工具，继续循环
- `stop_reason != "tool_use"`：模型完成工作，退出循环

```python
if response.stop_reason != "tool_use":
    return  # 退出循环
```

### 4. 消息列表如何累积？

```python
messages = [{"role": "user", "content": query}]

# 循环中：
messages.append({"role": "assistant", "content": response.content})
messages.append({"role": "user", "content": results})
```

**工具结果格式**：
```python
{
    "type": "tool_result",
    "tool_use_id": block.id,
    "content": output,
}
```

## ❓ 易误解点

**Q：`stop_reason` 是工具执行后返回的吗？**

A：不是。`stop_reason` 是 LLM API 响应的一部分，由模型决定是否需要调用工具。工具执行后返回的是 `tool_result`，不会改变 `stop_reason`。

## 🔗 原文位置

- 代码实现：[learn-claude-code/agents/s01_agent_loop.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s01_agent_loop.py)

