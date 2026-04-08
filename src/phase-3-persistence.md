# Phase 3: Persistence（持久化）

> **Break big goals into small tasks, order them, persist to disk**

## 阶段概述

Phase 3 解决两个问题：
1. 如何让任务图持久化到磁盘？（s07 Task System）
2. 如何让慢操作不阻塞 Agent？（s08 Background Tasks）

**与 Phase 2 的区别：**
- Phase 2 的磁盘 = 暂存（进度/知识/历史，可重建）
- Phase 3 的磁盘 = 状态（任务图/依赖关系，丢失会导致协作失败）

## Sessions

- [s07: Task System](./sessions/s07-task-system.md)
- [s08: Background Tasks](./sessions/s08-background-tasks.md)
