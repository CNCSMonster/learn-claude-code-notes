# Phase 2: Planning & Knowledge

> **An agent without a plan drifts**

## 阶段概述

Phase 2 解决一个核心问题：**如何在有限上下文窗口内高效工作**。

核心策略：**磁盘与上下文的分工**——把不急需的数据放磁盘，上下文只保留当前需要的内容。

- **s03 TodoWrite** - 进度存磁盘，不占上下文
- **s04 Subagents** - 探索性工作隔离到独立上下文
- **s05 Skills** - 知识存磁盘，按需加载
- **s06 Context Compact** - 历史存磁盘，当前内容压缩

## Sessions

- [s03: TodoWrite](./sessions/s03-todo-write.md)
- [s04: Subagents](./sessions/s04-subagents.md)
- [s05: Skills](./sessions/s05-skills.md)
- [s06: Context Compact](./sessions/s06-context-compact.md)
