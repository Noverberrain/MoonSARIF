# MoonSARIF

纯 MoonBit 实现的 SARIF 2.1.0 生成、解析、校验、筛选、合并、去重、基线门禁与报告工具链。

- GitHub：[Noverberrain/MoonSARIF](https://github.com/Noverberrain/MoonSARIF)
- GitLink：[Wyc060514/moonsarif](https://gitlink.org.cn/Wyc060514/moonsarif)
- Mooncakes：[Noverberrain/moonsarif](https://mooncakes.io/docs/Noverberrain/moonsarif)
- 许可证：Apache-2.0

## 项目定位

MoonSARIF 面向 MoonBit 静态分析器、CI/CD、代码扫描平台和 AI 编程 Agent，提供一套可复用的 SARIF 领域模型与工程工具。它不是通用 JSON Schema 验证器，而是针对 SARIF 工作流提供：

- 2.1.0 核心类型和 JSON 往返；
- 版本、工具、规则、结果、消息和位置的语义校验；
- 结果统计、按等级/规则/路径筛选；
- 跨 Windows/Linux 路径归一化；
- 多日志合并；
- 确定性结果指纹、同日志去重；
- 当前日志与历史 baseline 的 new/unchanged/absent 对比；
- 将 baselineState 写回当前 SARIF 结果；
- Markdown/HTML 自包含报告；
- 可在 CI 中拒绝新增问题的 baseline 门禁；
- GitHub Code Scanning 上传前兼容性检查；
- SARIF Builder，可从 MoonBit 静态分析器直接创建日志、规则、结果和位置；
- Generic、Github、Strict 三种校验 Profile；
- relatedLocations、fingerprints、suppressions、fixes、properties 等常用结果字段；
- 文件型 CLI，便于接入 CI。

## 当前状态

当前版本为 **0.4.0**。核心库和 CLI 已完成第一轮闭环，支持 wasm、wasm-gc、JavaScript、native 四个稳定后端的检查与测试；文件读写 CLI 主要面向 native 环境，库本身保持跨后端设计。

项目明确不承诺覆盖 SARIF 规范的所有可选字段，也不替代平台官方的完整 JSON Schema 校验器。对未建模字段，解析时会按当前公开 API 范围处理；提交到具体平台前，仍建议执行平台侧校验。

## 快速开始

### 库 API

```mbt check
///|
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
  let report = @moonsarif.validate(log)
  let summary = @moonsarif.summarize(log)
  assert_true(report.is_valid())
  assert_eq(summary.result_count, 1)
}
```

### Builder

```mbt nocheck
let builder = @moonsarif.LogBuilder::new(tool_name="MoonLint", tool_version="0.4.0")
builder.add_rule(id="MB001")
let index = builder.add_result(
  rule_id="MB001",
  level="warning",
  message=@moonsarif.message_text("unused declaration"),
  location=@moonsarif.make_location(uri="src/main.mbt", start_line=12),
)
builder.set_partial_fingerprints(index, { "primaryLocationLineHash": "example" })
let log = builder.finish()
```

Builder 固定生成 SARIF 2.1.0，并可继续设置 related locations、fingerprints、suppressions、fixes、properties 和 baseline state。

### 校验 Profile

```bash
moon run cmd/main -- validate examples/sample.sarif --profile generic
moon run cmd/main -- validate examples/sample.sarif --profile github
moon run cmd/main -- validate examples/sample.sarif --profile strict
```

`generic` 执行通用语义检查，`github` 执行 Code Scanning 上传前检查，`strict` 额外要求结果有声明规则、位置和相对 artifact URI，并拒绝重复指纹。旧的 `github-check` 命令继续可用。

### GitHub Actions

可复制 [GitHub Actions 示例](examples/github-actions/README.md)，或直接使用 `examples/github-actions/moonsarif-code-scanning.yml`。


```bash
# 检查 SARIF；发现结构/语义错误时退出码为 1
moon run cmd/main -- validate examples/sample.sarif

# 输出统计摘要
moon run cmd/main -- summary examples/sample.sarif --pretty

# 筛选 warning，支持 rule/path 条件
moon run cmd/main -- filter examples/sample.sarif \
  --level warning --path src/main.mbt --output filtered.sarif

# 合并多个同版本日志
moon run cmd/main -- merge first.sarif second.sarif --output merged.sarif

# 删除同一日志中的重复结果
moon run cmd/main -- deduplicate merged.sarif --output unique.sarif

# 比较当前结果与历史 baseline；有新增问题时退出码为 3
moon run cmd/main -- baseline current.sarif baseline.sarif --fail-on-new

# 限制新增问题数量
moon run cmd/main -- baseline current.sarif baseline.sarif --max-new 0

# 生成 Markdown 报告
moon run cmd/main -- report examples/sample.sarif --format markdown

# 生成 HTML 报告
moon run cmd/main -- report examples/sample.sarif --format html --output report.html

# 报告中标记 new/unchanged
moon run cmd/main -- report current.sarif --baseline baseline.sarif --format markdown

# 检查 GitHub Code Scanning 常见兼容性问题
moon run cmd/main -- github-check current.sarif
```

CLI 退出码：`0` 表示成功，`1` 表示校验发现 SARIF 错误，`2` 表示命令参数、文件读写或解析错误，`3` 表示 baseline 门禁拒绝新增问题。CLI 的错误信息当前写入标准输出，以便在不同宿主和后端中保持一致；自动化脚本应以退出码为准。

## 验证

```bash
moon fmt
moon check --target all --deny-warn --warn-list +73
moon test --target all --deny-warn
moon info
```

GitHub Actions 会执行格式检查、四个稳定后端的检查/测试、CLI 回归测试、1000 条结果的小型性能基准以及公共接口生成检查。

## 文档

- [架构说明](docs/ARCHITECTURE.md)
- [贡献指南](CONTRIBUTING.md)
- [安全策略](SECURITY.md)
- [变更记录](CHANGELOG.md)
- [初审项目申报书](docs/MoonSARIF-初审申报书.md)

## 后续计划

- 补充更多 SARIF 可选字段与官方样例覆盖；
- 增加更细粒度的平台兼容规则和真实上传回归样例；
- 评估流式解析/写出和大文件优化；
- 已发布 `Noverberrain/moonsarif@0.4.0`；后续根据 API 稳定性和赛事要求持续维护。

## 开源与 AI 使用说明

项目依据公开的 OASIS SARIF 2.1.0 标准进行原创 MoonBit 实现，不复制第三方实现源码。开发过程中使用 Codex 辅助需求整理、架构设计、实现、测试和文档；最终代码审核、提交、许可证合规和参赛责任由项目申报人承担。

## 许可证

Apache License 2.0。