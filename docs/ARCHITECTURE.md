# MoonSARIF 架构说明

MoonSARIF 采用“类型模型 + 纯函数工具链 + CLI 适配层”的结构。核心库不依赖操作系统文件 API，便于在 wasm、wasm-gc、JavaScript 和 native 后端复用；文件型 CLI 通过 `moonbitlang/x/fs` 提供宿主文件读写。

## 模块

- `types.mbt`：SARIF 2.1.0 核心数据模型。
- `json.mbt`：JSON 解析和序列化，专门处理 `$schema` 字段。
- `validation.mbt`：结构与语义校验，输出机器可读的问题列表。
- `summary.mbt`：统计、筛选与多日志合并。
- `path.mbt`：跨平台 artifact URI/路径归一化。
- `identity.mbt`：结果消息/位置归一化、确定性指纹、去重、baseline 比较和 `baselineState` 标注。
- `report.mbt`：Markdown/HTML 报告渲染与安全转义。
- `compatibility.mbt`：GitHub Code Scanning 常见兼容性规则。
- `cmd/main`：命令行适配层，负责参数、文件、输出和退出码，不重复实现领域逻辑。

## 数据流

```text
SARIF file
   │
   ▼
fs.read_file_to_string
   │
   ▼
parse ──► SarifLog ──► validate / summarize / filter / merge
                            │
                            ├─► fingerprint / deduplicate
                            ├─► compare_baseline / annotate_baseline
                            ├─► render_markdown / render_html
                            └─► stringify / output file
```

## CLI 命令

- `validate <file>`：解析并校验日志，输出 `ValidationReport` JSON；存在 `IssueError` 时退出 1。
- `summary <file>`：输出各等级结果、run 数量和规则数量。
- `filter <file>`：按 `--level`、`--rule`/`--rule-id`、`--path` 筛选，并保留工具元数据。
- `merge <file>...`：仅合并相同 SARIF 版本的日志，按输入顺序拼接 runs。
- `deduplicate <file>`：对每个 run 保留首次出现的结果指纹。
- `baseline <current> <old>`：按唯一指纹统计新增、未变化和消失结果；`--fail-on-new` 或 `--max-new` 可作为 CI 门禁，拒绝时退出 3。
- `report <file>`：生成 Markdown 或自包含 HTML 报告；`--baseline` 会将 `baselineState` 写回报告中的结果。
- `github-check <file>`：在通用校验外检查 GitHub Code Scanning 常见要求，如 ruleId、位置、artifact URI 和 baselineState。

`--output` 将结果写入文件，否则打印到标准输出；`--pretty` 控制 JSON 缩进。CLI 文件操作主要面向 native，核心库 API 仍可用于全部稳定后端。

## 指纹与去重策略

当前指纹使用长度前缀编码组合：

```text
ruleId + normalized first location(path:line:column) + message text/markdown
```

它不使用对象地址、数组索引、时间戳或随机数，因此同一问题在不同运行中可得到相同身份。长度前缀避免简单分隔符拼接造成的歧义。当前实现以首个物理位置作为主要定位；没有物理位置时仍可基于规则和消息建立身份。未来可扩展为优先使用 SARIF `partialFingerprints` 的兼容策略。

## 校验边界

校验器当前重点覆盖：

- `version` 必须为 `2.1.0`；
- run 的工具名称不能为空；
- rule id 不能为空且不能重复；
- 消息必须包含非空 text 或 markdown；
- level 必须是 SARIF 常见等级；
- 行列号必须为正数，行区间不能倒置；
- 未声明 ruleId 产生 warning，而不是直接阻断。

它不是完整 JSON Schema 引擎，也不会声称验证所有 SARIF 可选字段和平台扩展字段。

## 兼容性与测试

CI 使用 `moon check --target all` 与 `moon test --target all` 覆盖 wasm、wasm-gc、JavaScript、native，并通过 `moon fmt` 和 `moon info` 检查格式与公共接口变化。新增领域能力优先写库级测试，再用示例文件验证 CLI 闭环。

## 后续演进

1. 补充更多 SARIF 可选字段和官方样例。
2. 增加大文件性能基准。
3. 增加更细粒度的平台兼容性规则。
4. 在 API 稳定后评估 Mooncakes 发布。