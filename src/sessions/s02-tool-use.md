# s02: Tool Use (工具使用)

## 一句话总结

**"Adding a tool means adding one handler"** -- 加一个工具只加一个 handler，循环不用改，新工具注册进 dispatch map 就行。

## 关键问题

### 1. 为什么需要专用工具？

**只有 bash 的问题**：
- `cat` 截断不可预测
- `sed` 遇到特殊字符容易出错
- 每次 bash 调用都是不受约束的安全面
- 无法在工具层面做路径沙箱

**专用工具的优势**：
- `read_file`: 可以控制读取行数（limit 参数）
- `write_file`: 自动创建目录，路径安全检查
- `edit_file`: 精确文本替换，避免 sed 的转义问题
- 所有文件操作都经过 `safe_path()` 沙箱检查

### 2. Dispatch Map 的作用？

**作用**：将工具名映射到处理函数，避免 if/elif 链式判断。

```python
TOOL_HANDLERS = {
    "bash":       lambda **kw: run_bash(kw["command"]),
    "read_file":  lambda **kw: run_read(kw["path"], kw.get("limit")),
    "write_file": lambda **kw: run_write(kw["path"], kw["content"]),
    "edit_file":  lambda **kw: run_edit(kw["path"], kw["old_text"], kw["new_text"]),
}
```

**使用方式**：
```python
handler = TOOL_HANDLERS.get(block.name)
output = handler(**block.input) if handler else f"Unknown tool: {block.name}"
```

**优势**：
- O(1) 时间复杂度查找
- 工具注册简单：只需在字典中添加一项
- 循环体完全不需要修改

### 3. 路径沙箱 (safe_path) 如何工作？

**作用**：防止文件操作逃逸工作区，增强安全性。

```python
def safe_path(p: str) -> Path:
    path = (WORKDIR / p).resolve()
    if not path.is_relative_to(WORKDIR):
        raise ValueError(f"Path escapes workspace: {p}")
    return path
```

**示例**：
```python
safe_path("file.txt")      # OK: /workspace/file.txt
safe_path("../secret.txt") # Error: Path escapes workspace
```


## 🔗 原文位置

- 代码实现：[https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s02_tool_use.py](https://github.com/shareAI-lab/learn-claude-code/blob/16b927c8ee7befa07caf8844d22f86ffef0aea05/agents/s02_tool_use.py)

