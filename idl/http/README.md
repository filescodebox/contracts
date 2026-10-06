# idl/http/ - HTTP API 定义

此目录存放 Hz HTTP API 的 IDL 定义文件（thrift）。

## 文件说明

| 文件 | 用途 |
|------|------|
| `health.thrift` | 健康检查服务（K8s 探针等基础设施端点） |

## health.thrift - 健康检查服务

提供 K8s 风格的健康检查接口。

### 接口列表

| 接口 | 方法 | 路径 | 用途 |
|------|------|------|------|
| `Health` | GET | `/health` | 基础健康检查 |
| `Readiness` | GET | `/ready` | K8s 就绪探针 |
| `Liveness` | GET | `/live` | K8s 存活探针 |
| `Version` | GET | `/version` | 版本信息 |
| `Ping` | GET | `/ping` | Ping/Pong |

### 响应示例

```json
// GET /health
{
    "status": "healthy",
    "timestamp": "2026-01-01T00:00:00Z"
}

// GET /ready
{
    "status": "ready",
    "database": true,
    "redis": true
}

// GET /version
{
    "name": "filescodebox",
    "version": "1.0.0",
    "build_time": "2026-01-01T00:00:00Z",
    "git_commit": "abc1234",
    "go_version": "go1.26"
}
```

## 代码生成

本目录 IDL 随仓库统一生成（无单独 make 目标），在仓库根执行：

```bash
./scripts/gen-model.sh            # 全量再生成（含 http/）
CHECK=1 ./scripts/gen-model.sh    # 只校验（CI 用）
```

## 添加新服务

1. 在此目录创建新的 `.thrift` 文件（`namespace go http.<sub>` 裸域名）
2. 定义请求/响应 struct 与 service，hz 注解直接内联（无需 include）
3. 执行 `./scripts/gen-model.sh` 再生成

```thrift
namespace go http.example

struct ExampleReq {
    1: required string name (api.query = "name"),
}

struct ExampleResp {
    1: required string message (api.body = "message"),
}

service ExampleService {
    ExampleResp Hello(1: ExampleReq req) (api.get = "/api/v1/hello")
}
```

路由注解规范见仓库根 `idl/api.thrift` 约定文档。
