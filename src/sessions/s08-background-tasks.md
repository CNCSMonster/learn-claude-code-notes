# s08: Background Tasks (后台任务)

## 一句话总结

**"Run slow operations in the background; the agent keeps thinking"** — 慢操作丢后台，agent 继续想下一步。守护线程跑命令，完成后注入通知队列，循环保持单线程，只有子进程 I/O 被并行化。

## 关键问题

### 1. 为什么需要 Background Tasks？

**问题**：有些命令要跑几分钟（`npm install`、`pytest`、`docker build`）。阻塞式循环下模型只能干等。

**场景**：用户说 "装依赖，顺便建个配置文件"，阻塞模式下 Agent 只能一个一个来。

**解决**：后台执行 + 通知队列，Agent 可以继续做其他事。

### 2. 通知队列如何工作？

```python
class BackgroundManager:
    def __init__(self):
        self.tasks = {}
        self._notification_queue = []  # 线程安全的队列
        self._lock = threading.Lock()
```

**执行流程**：
1. `run()` 启动守护线程，立即返回
2. 子进程完成后，结果进入通知队列
3. 每次 LLM 调用前排空队列，注入到 messages

### 3. 结果如何注入？

```python
def agent_loop(messages: list):
    while True:
        # 1. 排空通知队列
        notifs = BG.drain_notifications()
        if notifs:
            notif_text = "\n".join(
                f"[bg:{n['task_id']}] {n['result']}" for n in notifs)
            messages.append({"role": "user",
                "content": f"<background-results>\n{notif_text}\n</background-results>"})
        
        # 2. 正常 LLM 调用
        response = client.messages.create(...)
```

**时间线**：
```
Agent --[spawn A]--[spawn B]--[other work]----
             |          |
             v          v
          [A runs]   [B runs]      (并行执行)
             |          |
             +-- results injected before next LLM call --+
```


## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s08_background-tasks.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s08_background-tasks.py)

