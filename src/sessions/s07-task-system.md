# s07: Task System (任务系统)

## 一句话总结

**"Break big goals into small tasks, order them, persist to disk"** — 大目标拆成小任务，排好序，记在磁盘上。文件持久化的任务图（DAG），用 `blockedBy` 表达依赖关系，为多 Agent 协作打基础。

## 关键问题

### 1. 为什么需要 Task System？

**s03 TodoManager 的局限**：
- 扁平清单，没有顺序、没有依赖
- 只活在内存里，上下文压缩（s06）后丢失
- 状态只有"做完/没做完"

**真实需求**：任务 B 依赖任务 A，任务 C 和 D 可以并行，任务 E 要等 C 和 D 都完成。

### 2. 任务图如何表示？

**每个任务是一个 JSON 文件**：
```json
{
  "id": 4,
  "subject": "Write tests",
  "status": "pending",
  "blockedBy": [2, 3],
  "owner": ""
}
```

**DAG 示例**：
```
                 +----------+
            +--> | task 2   | --+
            |    | pending  |   |
+----------+     +----------+    +--> +----------+
| task 1   |                          | task 4   |
| completed| --> +----------+    +--> | blocked  |
+----------+     | task 3   | --+     +----------+
                 | pending  |
                 +----------+
```

### 3. 依赖如何解除？

**完成任务时自动解锁后续任务**：
```python
def _clear_dependency(self, completed_id):
    for f in self.dir.glob("task_*.json"):
        task = json.loads(f.read_text())
        if completed_id in task.get("blockedBy", []):
            task["blockedBy"].remove(completed_id)
            self._save(task)  # 自动解锁
```

### 4. 任务图回答的三个问题？

- **什么可以做？** → `status == "pending"` 且 `blockedBy == []`
- **什么被卡住？** → `blockedBy` 非空
- **什么做完了？** → `status == "completed"`


## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s07_task-system.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s07_task-system.py)

