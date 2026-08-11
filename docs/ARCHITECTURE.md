# MoonSARIF 架构说明

MoonSARIF 采用“类型模型 + 纯函数工具链 + CLI 适配层”的结构。

## 当前模块

- `types.mbt`：SARIF 2.1.0 核心数据模型。
- `json.mbt`：JSON 解析和序列化，处理特殊的 `$schema` 字段。
- `validation.mbt`：结构与语义校验，输出机器可读的问题列表。
- `summary.mbt`：统计、筛选与多日志合并。
- `path.mbt`：跨平台 artifact URI/路径归一化。
- `cmd/main`：命令行入口，目前提供帮助与版本信息。

## 设计原则

1. 核心库保持纯 MoonBit，并可在 wasm、wasm-gc、JavaScript 和 native 后端检查。
2. 不依赖完整 JSON Schema 引擎也能提供 SARIF 领域语义校验。
3. 公共类型保留 SARIF 原始 camelCase 字段名，减少格式转换成本。
4. CLI 只负责输入输出，解析、校验、筛选和汇总逻辑全部位于可复用库中。

## 后续里程碑

1. 原生 CLI 文件读写：`validate`、`summary`、`filter`、`merge`。
2. 基于稳定指纹和位置的结果去重。
3. baseline 对比：`new`、`unchanged`、`absent`。
4. GitHub Code Scanning 兼容性规则集。
5. Markdown、HTML 报告和 WebAssembly 在线查看器。
