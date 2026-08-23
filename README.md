# MoonSARIF

纯 MoonBit 实现的 SARIF 2.1.0 解析、校验、筛选、合并、去重、基线门禁与报告工具链。

- GitHub：[Noverberrain/MoonSARIF](https://github.com/Noverberrain/MoonSARIF)
- GitLink：[Wyc060514/moonsarif](https://gitlink.org.cn/Wyc060514/moonsarif)
- Mooncakes：[Noverberrain/moonsarif](https://mooncakes.io/docs/Noverberrain/moonsarif)
- 许可证：Apache-2.0

## 项目定位

MoonSARIF 面向 MoonBit 静态分析器、CI/CD、代码扫描平台和 AI 编程 Agent，提供 SARIF 2.1.0 领域模型与工程工具：

- JSON 解析/序列化与 `$schema` 保留；
- 结构和语义校验；
- 统计、筛选、合并、去重与确定性 fingerprint；
- baseline 的 new/unchanged/absent 对比与 CI 门禁；
- GitHub Code Scanning 上传前兼容性检查；
- relatedLocations、fingerprints、suppressions、fixes、properties 等常用结果字段；
- Markdown/HTML 自包含报告。

## 快速开始

```bash
moon run cmd/main -- validate examples/sample.sarif
moon run cmd/main -- github-check examples/sample.sarif
moon run cmd/main -- summary examples/sample.sarif --pretty
moon run cmd/main -- report examples/sample.sarif --format markdown
moon run cmd/main -- report examples/sample.sarif --format html --output report.html
```

基线门禁示例：

```bash
moon run cmd/main -- baseline current.sarif baseline.sarif --fail-on-new
moon run cmd/main -- baseline current.sarif baseline.sarif --max-new 0
```

## 验证

```bash
moon fmt
moon check --target all --deny-warn --warn-list +73
moon test --target all --deny-warn
moon info
```

CI 还会运行 `tests/cli_smoke.sh` 和 `tools/benchmark.py --results 1000`。

## 文档

- [架构说明](docs/ARCHITECTURE.md)
- [贡献指南](CONTRIBUTING.md)
- [安全策略](SECURITY.md)
- [变更记录](CHANGELOG.md)
- [初审项目申报书](docs/MoonSARIF-初审申报书.md)

## 路线图

- [x] 核心类型模型、JSON 往返与常用结果扩展
- [x] 基础语义校验、统计、筛选与合并
- [x] 结果去重、稳定指纹与 baseline 门禁
- [x] GitHub Code Scanning 兼容性检查
- [x] Markdown/HTML 报告
- [x] CLI 回归测试和小型性能基准
- [ ] 更多 SARIF 可选字段与官方样例覆盖
- [ ] 更细粒度的平台兼容规则和真实上传回归
- [ ] 流式处理与大文件优化评估
- [x] Mooncakes 发布 `Noverberrain/moonsarif@0.3.0`

## 开源与 AI 使用说明

项目依据公开的 OASIS SARIF 2.1.0 标准进行原创 MoonBit 实现，不复制第三方实现源码。开发过程中使用 Codex 辅助需求整理、架构设计、实现、测试和文档；最终代码审核、提交、许可证合规和参赛责任由项目申报人承担。

## 许可证

Apache License 2.0。
