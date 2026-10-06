# idl/rpc/ - Kitex RPC 服务定义（预留）

此目录为 Kitex RPC 服务的 IDL 预留位。**当前为空**：生态内服务间通信现状仅
HTTP/JSON + WebSocket，评估结论是保留 Kitex 作为未来传输面细拆时的升级路径
（触发条件见 hub 仓 `docs/specs/` 多副本设计文档）。

若未来引入 RPC 服务：

1. 在此目录创建 `.thrift` 文件（`namespace go <sub>` 裸域名）
2. 定义请求/响应 struct 与 service
3. 接入生成链（扩展 `scripts/gen-model.sh` 或新脚本），产物落 `gen/rpc/`
4. 生成物禁止手动修改

> 历史说明：本目录曾规划 `health.proto` 探活服务；proto → thrift 迁移完成后该
> 规划未再启用，健康检查由 `idl/http/health.thrift`（HTTP 端点）承担。
