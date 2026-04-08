# s12: Worktree Isolation (Worktree 隔离)

## 一句话总结

**"Each works in its own directory, no interference"** — 各干各的目录，互不干扰。任务管目标，worktree 管目录，用任务 ID 绑定，永不碰撞的并行执行通道。

## 关键问题

### 1. 为什么需要 Worktree 隔离？

**问题**：到 s11，Agent 已经能自主认领和完成任务。但所有任务共享一个目录。两个 Agent 同时重构不同模块 -- A 改 `config.py`，B 也改 `config.py`，未提交的改动互相污染。

**解决**：给每个任务一个独立的 git worktree 目录，用任务 ID 把两边关联起来。

### 2. 控制平面与执行平面如何绑定？

```
控制平面 (.tasks/)                  执行平面 (.worktrees/)
+------------------+                +------------------------+
| task_1.json      |                | auth-refactor/         |
|   status: in_progress  <------>   branch: wt/auth-refactor
|   worktree: "auth-refactor"   |   task_id: 1             |
+------------------+                +------------------------+

绑定同时写入两侧状态:
def bind_worktree(self, task_id, worktree):
    task = self._load(task_id)
    task["worktree"] = worktree
    if task["status"] == "pending":
        task["status"] = "in_progress"  # 自动推进状态
    self._save(task)
```

### 3. Worktree 生命周期？

**创建**：
```python
WORKTREES.create("auth-refactor", task_id=1)
# -> git worktree add -b wt/auth-refactor .worktrees/auth-refactor HEAD
```

**执行**：
```python
subprocess.run(command, shell=True, cwd=worktree_path, ...)
```

**收尾**（二选一）：
- `worktree_keep(name)` -- 保留目录
- `worktree_remove(name, complete_task=True)` -- 删除目录 + 完成任务

### 4. 事件流的作用？

**每个生命周期步骤写入 `.worktrees/events.jsonl`**：
```json
{
  "event": "worktree.remove.after",
  "task": {"id": 1, "status": "completed"},
  "worktree": {"name": "auth-refactor", "status": "removed"},
  "ts": 1730000000
}
```

**作用**：崩溃后从 `.tasks/` + `.worktrees/index.json` + `events.jsonl` 重建现场。


## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s12_worktree_task_isolation.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s12_worktree_task_isolation.py)

