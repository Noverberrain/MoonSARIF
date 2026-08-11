# MoonSARIF

纯 MoonBit 实现的 SARIF 2.1.0 解析、校验、筛选、合并与报告工具链。

> 当前状态：早期开发版本。核心类型模型、JSON 往返、语义校验、统计、筛选和合并 API 已可使用。

## 为什么做 MoonSARIF

SARIF（Static Analysis Results Interchange Format）是静态分析结果的标准交换格式。MoonSARIF 希望为 MoonBit 静态分析器、CI、代码扫描平台和 AI Agent 提供一套可复用、跨后端的基础设施。

项目重点不是再做一个通用 JSON 解析器，而是解决 SARIF 工程流程中的具体问题：

- 上传代码扫描平台前发现格式和语义错误；
- 合并多个扫描器或多个分片产生的报告；
- 按严重等级、规则和路径筛选结果；
- 生成稳定摘要并支持后续 baseline 对比；
- 为 MoonBit 工具输出标准化扫描结果提供类型模型。

## 已实现

- SARIF 2.1.0 核心类型模型；
- JSON 解析、序列化及 `$schema` 字段保留；
- 版本、工具、规则、结果、消息和位置语义校验；
- error/warning/note/none 分类统计；
- 按 level、ruleId、路径筛选；
- Windows/Linux artifact 路径归一化；
- 多个同版本 SARIF 日志合并；
- wasm、wasm-gc、JavaScript、native 全后端检查与测试。

## 快速开始

```moonbit
test {
  let input =
    #|{
    #|  "version": "2.1.0",
    #|  "runs": [{
    #|    "tool": { "driver": { "name": "MoonLint" } },
    #|    "results": [{
    #|      "ruleId": "MB001",
    #|      "level": "warning",
    #|      "message": { "text": "example finding" }
    #|    }]
    #|  }]
    #|}
  let log = @moonsarif.parse(input)
  let summary = @moonsarif.summarize(log)
  assert_eq(summary.result_count, 1)
  assert_eq(summary.warning_count, 1)
}
```

## 常用命令

```bash
moon check --target all --deny-warn --warn-list +73
moon test --target all --deny-warn
moon run cmd/main -- help
moon info
```

## 路线图

- [x] 核心类型模型与 JSON 往返
- [x] 基础语义校验
- [x] 统计、筛选与合并
- [ ] 文件型 CLI：`validate`、`summary`、`filter`、`merge`
- [ ] 结果去重与稳定指纹
- [ ] baseline 新增/消失/未变化对比
- [ ] GitHub Code Scanning 兼容性检查
- [ ] Markdown/HTML 报告
- [ ] WebAssembly 在线查看器

架构和后续设计见 `docs/ARCHITECTURE.md`。

## 许可证

Apache License 2.0。
