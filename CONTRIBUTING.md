# 贡献指南

感谢参与 MoonSARIF。项目使用 MoonBit，提交前请确保本地工具链可以完成全后端验证。

## 开发流程

1. 从 GitHub 仓库创建分支，保持一个变更主题一个提交或一组可读提交。
2. 修改核心库时优先保持 API 小而稳定，避免把文件系统依赖引入根包。
3. 为新增行为补充库级测试；CLI 行为同时更新 README 和示例命令。
4. 提交前运行：

```bash
moon fmt
moon check --target all --deny-warn --warn-list +73
moon test --target all --deny-warn
moon info
```

## 提交要求

- 提交信息使用清晰的动词，例如 `feat:`、`fix:`、`test:`、`docs:`；
- 不提交 `_build/`、`.mooncakes/`、凭据或包含敏感数据的 SARIF 文件；
- 不要为了增加提交次数创建空提交；
- 公共 API 变化应在 `CHANGELOG.md` 和文档中说明；
- CI 失败时请在 PR 描述中附上失败命令和工具链版本。

## 代码风格

遵循 MoonBit 格式化器输出，公共函数写简短文档，领域逻辑放在根包，CLI 只做参数和 I/O 适配。不要把 SARIF 输入当作可信数据，所有输入都应经过解析和校验。

## Pull Request

PR 描述请包含：变更目的、行为示例、测试命令、兼容性影响和已知限制。涉及 SARIF 规范解释时，附上对应规范章节或测试样例来源。