# contracts

FileCodeBox 契约层:错误码 + Thrift 生成的 API 类型。纯类型、零业务依赖,是前后端与所有实现方(backend core、filecodebox-fnos 等)的单一真相源。

## 内容

| 目录 | 说明 |
|------|------|
| `errcode/` | 全站统一业务码(码段规划见文件头注释) |
| `gen/` | 由 `idl/*.thrift` 生成的纯模型类型(Thrift v0.13 工具链) |
| `idl/` | Thrift IDL 源(单一真相源,与 gen/ 同仓演进) |

## 依赖规则(强制)

- 本模块**不允许** import 任何项目内包,仅依赖 thrift runtime 与标准库。
- 任何破坏性变更(删除/改名字段、改错误码语义)视为 **不兼容变更**,必须升主版本。

## 重新生成 gen/

IDL 源(`idl/`)与生成产物(`gen/`)都在本仓内,自包含再生成:

```bash
./scripts/install-tools.sh       # 首次:安装 hz v0.9.7 + thriftgo v0.4.3(与既有产物一致)
./scripts/gen-model.sh           # 从 idl/*.thrift 全量再生成 gen/<domain>/
CHECK=1 ./scripts/gen-model.sh   # 只校验 gen/ 与 idl/ 是否同步(CI 可用)
```

> 历史说明: 生成曾依赖旧单体仓库 FileCodeBox/backend 的 `make gen` + 手工拷贝,
> 现已内聚到本仓(idl/ 与生成脚本于 2026-10 自单体迁入)。

## 引用方式

```go
import (
    "github.com/filescodebox/contracts/errcode"
    "github.com/filescodebox/contracts/gen/share"
)
```

下游 `go.mod` 无需任何 `replace`:thrift 版本约束以 `require` 形式从本模块传递。
