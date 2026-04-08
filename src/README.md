# Learn Claude Code Notes

> **The model is the agent. The code is the harness. Build great harnesses. The agent will do the rest.**
>
> 模型是智能体，代码是 harness。构建优秀的 harness，智能体自会完成剩余工作。

## 关于本书

这是 [learn-claude-code](https://github.com/shareAI-lab/learn-claude-code) 项目的中文学习笔记。

**原文档**：[learn-claude-code/docs/zh/](../learn-claude-code/docs/zh/)

## 核心思想

**Agent = Model**（模型即智能体）

**Harness = Tools + Knowledge + Context + Permissions**（工具 + 知识 + 上下文 + 权限）

**Product = Agent + Harness**（完整产品 = 智能体 + 环境）

## 学习路径

本书分为 4 个阶段，共 12 个 session：

| 阶段 | Sessions | 主题 | 递进关系 |
|------|----------|------|----------|
| Phase 1 | s01-s02 | The Loop - 基础循环与工具 | 建立模型与世界的连接 |
| Phase 2 | s03-s06 | Planning & Knowledge - 规划与知识管理 | 让单 Agent 在有限上下文窗口内高效 |
| Phase 3 | s07-s08 | Persistence - 持久化与并行 | 为多 Agent 协作提供共享任务状态 |
| Phase 4 | s09-s12 | Teams - 多 Agent 协作 | 在共享状态上实现团队沟通与自组织 |

**四阶段递进关系：**
```
Phase 1: 循环基础
   ↓
Phase 2: 上下文管理 ──→ 单 Agent 能力完善
   ↓
Phase 3: 任务持久化 ──→ 为多 Agent 协作提供基础设施（任务图 + 并行执行）
   ↓
Phase 4: 多 Agent 协作 ──→ 基于共享状态的团队沟通、协议、自治
```

详细总结见：[总结](./summary.md)
