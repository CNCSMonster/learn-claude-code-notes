# Learn Claude Code Notes

> Learn Claude Code -- Harness Engineering for Real Agents
>
> **The model is the agent. The code is the harness.**

[learn-claude-code](https://github.com/shareAI-lab/learn-claude-code) 项目的中文学习笔记，采用 QA 形式整理每个 session 的核心概念。

## 🌐 在线阅读

**[👉 点击此处浏览在线版本](https://CNCSMonster.github.io/learn-claude-code-notes/)**

## 📖 阅读方式

### 本地阅读

```bash
# 1. 安装 mdBook
./setup.sh

# 2. 启动开发服务器
mdbook serve --open
```

### 直接阅读 Markdown

笔记文件位于 `src/sessions/` 目录：
- [s01: The Agent Loop](./src/sessions/s01-the-agent-loop.md)
- [s02: Tool Use](./src/sessions/s02-tool-use.md)
- [s03: TodoWrite](./src/sessions/s03-todo-write.md)
- ...

## 📋 笔记结构

```
learn-claude-code-notes/
├── src/
│   ├── README.md                 # 关于本书
│   ├── SUMMARY.md                # 目录
│   ├── core-concepts.md          # 核心概念
│   ├── phase-*.md                # 阶段概述
│   ├── sessions/                 # Session 笔记
│   │   ├── s01-the-agent-loop.md
│   │   ├── s02-tool-use.md
│   │   └── ...
│   └── summary.md                # 总结
├── book.toml                     # mdBook 配置
├── DEPLOY.md                     # 部署指南
├── setup.sh                      # 安装脚本
└── .github/workflows/
    └── deploy.yml                # GitHub Actions
```

## 🎯 学习路径

| 阶段 | Sessions | 主题 |
|------|----------|------|
| Phase 1 | s01-s02 | The Loop - 基础循环与工具 |
| Phase 2 | s03-s06 | Planning & Knowledge - 规划与知识管理 |
| Phase 3 | s07-s08 | Persistence - 持久化与并行 |
| Phase 4 | s09-s12 | Teams - 多 Agent 协作 |

## 🚀 快速开始

### 1. 一句话总结

| Session | 一句话总结 |
|---------|------------|
| s01 | **One loop & Bash is all you need** |
| s02 | **Adding a tool means adding one handler** |
| s03 | **An agent without a plan drifts** |
| s04 | **Break big tasks down; each subtask gets a clean context** |
| s05 | **Load knowledge when you need it, not upfront** |
| s06 | **Context will fill up; you need a way to make room** |
| s07 | **Break big goals into small tasks, order them, persist to disk** |
| s08 | **Run slow operations in the background; the agent keeps thinking** |
| s09 | **When the task is too big for one, delegate to teammates** |
| s10 | **Teammates need shared communication rules** |
| s11 | **Teammates scan the board and claim tasks themselves** |
| s12 | **Each works in its own directory, no interference** |

### 2. 核心公式

```
Agent = Model（模型即智能体）

Harness = Tools + Knowledge + Context + Permissions

Product = Agent + Harness
```

## 📦 部署

详见 [DEPLOY.md](./DEPLOY.md)

```bash
# 本地构建
mdbook build

# 输出在 ./book/ 目录
```

## 🔗 参考资源

- [原项目 GitHub](https://github.com/shareAI-lab/learn-claude-code)
- [原项目文档（中文）](./learn-claude-code/docs/zh/)
- [原项目文档（英文）](./learn-claude-code/docs/en/)

## 🛠️ 技术栈

本项目使用 [mdbook-zh-search](https://github.com/cncsmonster/mdbook-zh-search) 构建，它是 mdBook 的增强版本，提供了更好的中文搜索支持。

## 📝 许可证

MIT

---

> **Bash is all you need. Real agents are all the universe needs.**
