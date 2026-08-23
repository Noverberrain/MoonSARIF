# 变更记录

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
- Markdown/HTML 报告和 Mooncakes 发布仍需后续评估。