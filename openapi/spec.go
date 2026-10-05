// Package openapi 内嵌 IDL 生成的 OpenAPI 3.0 规范。
//
// openapi.json 由 cmd/gen-openapi 从 idl/*.thrift 生成（勿手改，CI 有同步校验），
// 本包仅做 go:embed 暴露，供 core 在 /openapi.json 服务时合并 IDL schema。
// contracts 零业务依赖纪律不受影响：本包不 import 任何项目内包。
package openapi

import _ "embed"

// Spec IDL 生成的 OpenAPI 3.0 规范（JSON 字节）。
//
//go:embed openapi.json
var Spec []byte
