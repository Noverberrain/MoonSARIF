# MoonSARIF 初审项目申报书

> 更新日期：2026 年 8 月 23 日。申报人身份信息以赛事报名系统填写内容为准。

## 一、项目基本信息

- **项目名称：** MoonSARIF
- **项目方向：** MoonBit 开源生态基础库与开发工具
- **开源许可证：** Apache-2.0
- **GitHub：** https://github.com/Noverberrain/MoonSARIF
- **GitLink：** https://gitlink.org.cn/Wyc060514/moonsarif
- **项目性质：** 原创项目，不基于其他项目源码移植

## 二、项目简介与应用场景

MoonSARIF 是使用 MoonBit 原创实现的 SARIF 2.1.0 解析、校验、筛选、合并、去重与基线比较工具链，面向静态分析器、代码扫描平台、CI/CD 系统和 AI 编程 Agent。

项目提供可复用的 SARIF 领域类型模型和纯函数 API，并提供文件型命令行入口，帮助 MoonBit 工具输出标准化扫描结果，在上传代码扫描平台前完成格式/语义检查、结果筛选、重复结果清理和历史 baseline 对比。

## 三、生态价值与创新点

选题调研未在 mooncakes.io 发现专门的 SARIF 工具包。MoonSARIF 聚焦 MoonBit 静态分析生态中的结果交换基础设施，区别于通用 JSON 库，提供：

1. SARIF 2.1.0 领域类型与 `$schema` 往返保留；
2. 面向上传前流程的语义校验和机器可读问题报告；
3. Windows/Linux artifact 路径归一化；
4. 不依赖随机值、对象地址和数组序号的确定性结果指纹；
5. 运行内去重、跨运行 baseline 的 new/unchanged/absent 统计；
6. 可在 CI 中直接使用的 validate/summary/filter/merge/deduplicate/baseline/report CLI；
7. baselineState 标注与 Markdown/HTML 自包含报告，方便人工复核和流水线留档。

## 四、核心功能与现有基础

当前验收候选版已经完成：

- SARIF 2.1.0 核心类型模型；
- JSON 解析、序列化及 `$schema` 字段保留；
- 版本、工具、规则、结果、消息、位置等语义校验；
- error/warning/note/none 分类统计；
- 按 level、ruleId、路径筛选；
- 跨平台 artifact 路径归一化；
- 同版本多日志合并；
- 确定性 fingerprint、run 内 deduplicate；
- baseline 新增、未变化、消失结果统计及 CI 门禁；
- `baselineState` 写回当前结果；
- Markdown/HTML 自包含报告输出；
- 文件型 CLI 和 `--output` 输出；
- 17 个库级测试，覆盖解析、往返、校验、筛选、合并、路径、指纹、去重、baseline 和报告；
- wasm、wasm-gc、JavaScript、native 四个稳定后端检查与测试；
- GitHub Actions 格式、严格检查、测试和公共接口生成验证。

项目已建立 GitHub 与 GitLink 双仓库，代码、文档、示例和申报书均纳入版本管理。仓库中的公开接口以 `moon info` 生成文件为准，后续兼容性变更会同步记录在变更日志中。

## 五、技术路线与交付边界

项目采用“类型模型 → JSON 编解码 → 语义校验 → 统计/筛选/合并 → 指纹/去重/baseline → 报告渲染 → CLI 适配”的分层架构。核心库不依赖操作系统文件 API，因此可复用于 wasm、wasm-gc、JavaScript 和 native；CLI 文件读写主要面向 native 宿主环境。

当前版本的明确边界是：它不是完整 JSON Schema 引擎，不声称覆盖 SARIF 的全部可选字段和平台私有扩展，也不替代 GitHub 等平台的官方校验器。当前指纹以结果规则、首个物理位置和消息为基础；在线查看器、性能基准和 Mooncakes 发布属于后续版本评估事项，不作为本版本已完成能力进行承诺。

## 六、预期交付成果

本阶段交付：

- 可复用的 MoonBit SARIF 核心库；
- 可执行的文件型 CLI；
- `examples/sample.sarif` 示例；
- API、架构、贡献、安全和变更文档；
- 四后端 CI 与自动化测试；
- GitHub/GitLink 开源仓库及可复核提交历史；
- 本申报书 Markdown 与 PDF 文件。

后续可在验收反馈基础上继续补充更多 SARIF 字段、平台兼容性规则、性能基准和 Mooncakes 发布包。

## 七、原创性、开源合规与 AI 使用说明

项目依据公开的 OASIS SARIF 2.1.0 标准进行原创 MoonBit 实现，不复制第三方实现源码。规范、测试数据和依赖来源将在仓库中注明并核对许可证。开发过程中使用 Codex 辅助需求整理、架构设计、代码实现、测试与文档；最终设计取舍、代码审核、提交、许可证合规和参赛责任由申报人承担。

## 八、风险与应对

- **规范覆盖风险：** 通过公开字段分阶段建模、样例和错误样例测试，并明确当前版本边界；
- **平台差异风险：** 将 SARIF 通用能力与平台专属规则分层，提交前保留官方平台校验步骤；
- **指纹误合并风险：** 使用可解释的规则/路径/位置/消息组合，并保留首个结果，后续可引入平台 partial fingerprint；
- **大文件性能风险：** 当前采用内存模型，后续通过基准测试评估流式处理；
- **跨后端风险：** CI 持续执行 wasm、wasm-gc、JavaScript、native 全后端检查和测试。