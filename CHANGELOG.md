# 变更记录

## [0.4.0] - 2026-08-23

### Added

- SARIF Builder API，可创建日志、规则、结果、位置及常用扩展字段；
- Generic、Github、Strict 三种校验 Profile 与 `validate --profile` CLI；
- 合法/非法 SARIF fixture 回归集和 CLI 边界回归测试；
- GitHub Actions Code Scanning 集成示例；
- `Noverberrain/moonsarif@0.4.0` 发布到 Mooncakes。

## [0.3.0] - 2026-08-23

### Added

- GitHub Code Scanning 上传前兼容性检查及 `github-check` CLI；
- `relatedLocations`、`fingerprints`、`suppressions`、`fixes`、`properties` 等常用 SARIF 结果字段；
- CLI 回归 smoke test，覆盖报告、baseline 门禁和兼容性检查；
- 可复现的小型性能基准脚本，默认测量 1000 条结果；
- 架构、README 和初审申报材料同步更新；
- `Noverberrain/moonsarif@0.3.0` 已发布到 Mooncakes。

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
- 流式处理/大文件优化、更多平台兼容规则和 Mooncakes 包持续维护仍需后续评估。