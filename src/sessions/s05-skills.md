# s05: Skills (技能加载)

## 一句话总结

**"Load knowledge when you need it, not upfront"** — 用到什么知识，临时加载什么知识。两层注入策略：系统提示只放 Skill 名称（便宜），tool_result 按需加载完整内容（贵）。

## 关键问题

### 1. 为什么需要 Skills 机制？

**问题**：希望 Agent 遵循特定领域工作流（git 约定、测试模式、代码审查清单）。全塞进系统提示太浪费 -- 10 个 Skill，每个 2000 token，就是 20,000 token，大部分跟当前任务无关。

**解决**：按需加载，模型开口要时才给。

### 2. 两层注入策略是什么？

**Layer 1 - 系统提示（常驻，低成本）**：
```
You are a coding agent.
Skills available:
  - git: Git workflow helpers        ~100 tokens/skill
  - test: Testing best practices
```

**Layer 2 - tool_result（按需，高成本）**：
```xml
<skill name="git">
  Full git workflow instructions...  ~2000 tokens
  Step 1: ...
</skill>
```

### 3. 技能文件如何组织？

```
skills/
  pdf/
    SKILL.md       # YAML frontmatter + 正文
  code-review/
    SKILL.md
```

**设计**：用目录名作为 Skill 标识，YAML frontmatter 存元数据（name, description），正文是完整指令。

## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s05_skills.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s05_skills.py)

