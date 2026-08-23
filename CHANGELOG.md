# 变更记录

## [0.2.0] - 2026-08-23

### Added

- `annotate_baseline`：将当前结果标记为 `new` 或 `unchanged`；
- `report` CLI 及 Markdown/HTML 自包含报告渲染 API；
- `--fail-on-new`、`--max-new` baseline CI 门禁，拒绝时返回退出码 3；
- 报告、baseline 标注和跨平台位置展示测试；
- README 与架构文档中的 CI/报告使用示例。


## [0.1.0] - 2026-08-23

### Added

- SARIF 2.1.0 核心类型、JSON 解析与序列化；
- 结构和常见语义校验；
- severity/rule/path 筛选、统计和多日志合并；
- 跨平台 artifact 路径归一化；
- 确定性结果指纹、run 内去重和 baseline 比较；
- `validate`、`summary`、`filter`、`merge`、`deduplicate`、`baseline` CLI 命令；
- 四个稳定后端的 CI 检查、测试和公共接口生成验证；
- 架构说明、贡献指南、安全策略、示例和申报材料。

### Limitations

- 当前不是完整 SARIF JSON Schema 验证器；
- CLI 文件读写主要面向 native 后端；
- 指纹当前使用首个物理位置，尚未覆盖所有平台专用指纹规则；
- 大文件性能基准和 Mooncakes 发布仍需后续评估。