# MoonSARIF 初审项目申报书

> 申报日期：2026 年 8 月 11 日。申报人身份信息以赛事报名系统填写内容为准。

## 一、项目基本信息
- **项目名称：** MoonSARIF
- **项目方向：** MoonBit 开源生态基础库与开发工具
- **开源许可证：** Apache-2.0
- **GitHub：** https://github.com/Noverberrain/MoonSARIF
- **GitLink：** 拟使用 `https://gitlink.org.cn/Wyc060514/moonsarif`，仓库创建后核验
- **项目性质：** 原创项目，不基于其他项目源码移植

## 二、项目简介与应用场景
MoonSARIF 是使用 MoonBit 原创实现的 SARIF 2.1.0 解析、校验、合并与报告工具链，面向静态分析器、代码扫描平台、CI/CD 系统和 AI 编程 Agent。项目帮助 MoonBit 工具输出标准化扫描结果，并在上传 GitHub Code Scanning 等平台前完成兼容性检查、问题筛选、结果去重和报告生成。

## 三、生态价值与创新点
选题调研未在 mooncakes.io 发现专门的 SARIF 工具包。MoonSARIF 将填补 MoonBit 静态分析结果交换基础设施的空白；相比通用 JSON 库，它提供 SARIF 领域类型、语义校验、跨平台路径处理、稳定指纹、baseline 对比及 CI 报告能力，可作为其他 MoonBit 检查器和质量平台的公共底座。

## 四、核心功能与现有基础
当前已完成 SARIF 核心类型模型、JSON 往返、`$schema` 保留、结构与语义校验、严重等级统计、按 level/rule/path 筛选、路径归一化和多日志合并。项目现有 13 次提交、10 个测试，已在 wasm、wasm-gc、JavaScript 和 native 后端全部通过，并配置格式、检查、测试及公共接口一致性 CI。

## 五、技术路线与实施计划
项目采用“类型模型 → JSON 编解码 → 语义校验 → 指纹与对比算法 → 报告生成 → CLI/WebAssembly”的分层架构。后续将依次完成文件型 CLI、结果去重与稳定指纹、baseline 新增/消失/未变化对比、GitHub Code Scanning 兼容规则、Markdown/HTML 报告、性能与大文件测试、在线查看器及 mooncakes.io 发布。

## 六、预期交付成果
交付可复用 MoonBit 包、完整命令行工具、WebAssembly 在线查看器、可运行示例、SARIF 兼容性文档、跨后端测试与 CI、性能报告，以及可从 mooncakes.io 安装的正式版本；计划形成 4,000 行以上有效 MoonBit 实现和系统化测试。

## 七、原创性、开源合规与 AI 使用说明
项目依据公开的 OASIS SARIF 2.1.0 标准进行原创 MoonBit 实现，不复制第三方实现源码；规范、测试数据和依赖来源将在仓库中注明并核对许可证。开发过程中使用 Codex 辅助需求整理、架构设计、代码实现、测试与文档，最终设计取舍、代码审核、提交和参赛责任由申报人承担。

## 八、风险与应对
主要风险包括 SARIF 规范覆盖面较大、平台兼容规则差异、稳定指纹准确性和大文件处理性能。项目将通过分阶段类型覆盖、官方样例与错误样例测试、跨后端回归、基准测试、流式处理预研及版本化 API 降低风险。
