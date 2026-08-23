# GitHub Code Scanning 示例

此目录展示从 SARIF 文件到 GitHub Code Scanning 的最小工作流。示例不包含 Token，也不会上传仓库之外的数据。

- `sample-result.sarif`：可本地验证的 SARIF 2.1.0 样例。
- `moonsarif-code-scanning.yml`：先运行 `github-check`，再使用 GitHub 官方 action 上传。

工作流需要 `security-events: write` 才能上传 SARIF。来自 fork 的 Pull Request 可能受到 GitHub 权限策略限制；private repository 也需要仓库启用相应的 Code Scanning 能力。

`github-check` 只检查上传前常见兼容性问题，不等同于 GitHub 服务端最终校验。项目不会保存或生成 GitHub Token。
