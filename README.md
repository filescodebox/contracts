# contracts

FileCodeBox 契约层:错误码 + Thrift 生成的 API 类型。纯类型、零业务依赖,是前后端与所有实现方(backend core、filecodebox-fnos 等)的单一真相源。

## 内容

| 目录 | 说明 |
|------|------|
| `errcode/` | 全站统一业务码(码段规划见文件头注释) |
| `gen/` | 由 `FileCodeBox/backend/idl/*.thrift` 生成的纯模型类型(Thrift v0.13 工具链) |

## 依赖规则(强制)

- 本模块**不允许** import 任何项目内包,仅依赖 thrift runtime 与标准库。
- 任何破坏性变更(删除/改名字段、改错误码语义)视为 **不兼容变更**,必须升主版本。

## 重新生成 gen/

```bash
# IDL 源位于 FileCodeBox 仓库 backend/idl/,生成命令见其 Makefile
cd FileCodeBox/backend && make gen
# 产物 gen/http/model/* 拷贝至本模块 gen/ 下
```

## 引用方式

```go
import (
    "github.com/filescodebox/contracts/errcode"
    "github.com/filescodebox/contracts/gen/share"
)
```

下游 `go.mod` 无需任何 `replace`:thrift 版本约束以 `require` 形式从本模块传递。
