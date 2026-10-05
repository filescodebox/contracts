package main

import (
	"encoding/json"
	"os"
	"regexp"
	"sort"
	"strings"
	"testing"
)

var declNameRe = regexp.MustCompile(`(?m)^export (?:interface|type) (\w+)`)

// TestGenerateOnRealIDL 用仓内真实 IDL 做生成质量守卫：域模块齐全、容器类型
// 映射正确（map → Record / list → T[]）、可选性按 requiredness、产物无 unknown。
func TestGenerateOnRealIDL(t *testing.T) {
	files, err := Generate("../../idl")
	if err != nil {
		t.Fatalf("Generate: %v", err)
	}

	if _, ok := files["index.d.ts"]; !ok {
		t.Fatal("缺少 index.d.ts 桶出口")
	}
	// 规模守卫：IDL 治理域不应异常缩水（现网 15 域）
	if len(files) < 16 {
		t.Fatalf("域模块数=%d，异常缩水（期望 ≥15 域 + index）", len(files)-1)
	}

	t.Run("容器与标量映射", func(t *testing.T) {
		cases := map[string]string{ // 期望片段 → 所在域模块
			// map<string,string> → Record（原始 AST GetName 返回裸 "map"，
			// 曾因按名字形态匹配漏判为 unknown）
			"headers: Record<string, string>;": "presign.d.ts",
			// list<...> → T[]
			"uploaded_indexes: number[];": "chunk.d.ts",
			"items: FileItem[];":          "admin.d.ts",
			// 标量
			"global_qps: number;":    "ratelimit.d.ts",
			"has_password: boolean;": "share.d.ts",
		}
		for want, file := range cases {
			if !strings.Contains(files[file], want) {
				t.Errorf("%s 缺少 %q", file, want)
			}
		}
	})

	t.Run("可选性按 requiredness", func(t *testing.T) {
		// share_anonymous.GenerateCodeReq.expire_value 为 optional → ?:
		if !strings.Contains(files["share_anonymous.d.ts"], "expire_value?: string;") {
			t.Error("optional 字段应生成 ?:")
		}
		// GetShareReq.password 为 optional（api.query）→ ?:
		if !strings.Contains(files["share.d.ts"], "password?: string;") {
			t.Error("optional query 字段应生成 ?:")
		}
		// required 字段不带 ?
		if strings.Contains(files["share.d.ts"], "text?: string;") {
			t.Error("required 字段不应生成 ?:")
		}
	})

	t.Run("无 unknown 逃逸", func(t *testing.T) {
		for name, content := range files {
			if strings.Contains(content, ": unknown;") {
				t.Errorf("%s 含 unknown 字段（类型解析失败）", name)
			}
		}
	})
}

// TestParityWithOpenAPI 跨产物对账：gen/ts 的类型名单必须与 openapi/openapi.json
// 的 components.schemas 名单完全一致（两侧同源 idl/，序列化名规则同构）。
// 名单漂移说明某侧生成器漏判/多判类型，先修生成器再更新产物。
func TestParityWithOpenAPI(t *testing.T) {
	files, err := Generate("../../idl")
	if err != nil {
		t.Fatalf("Generate: %v", err)
	}

	tsNames := map[string]bool{}
	for name, content := range files {
		if name == "index.d.ts" {
			continue
		}
		for _, m := range declNameRe.FindAllStringSubmatch(content, -1) {
			tsNames[m[1]] = true
		}
	}

	b, err := os.ReadFile("../../openapi/openapi.json")
	if err != nil {
		t.Fatalf("读取 openapi.json: %v", err)
	}
	var spec struct {
		Components struct {
			Schemas map[string]json.RawMessage `json:"schemas"`
		} `json:"components"`
	}
	if err := json.Unmarshal(b, &spec); err != nil {
		t.Fatalf("解析 openapi.json: %v", err)
	}
	oaNames := map[string]bool{}
	for full := range spec.Components.Schemas {
		if i := strings.LastIndex(full, "."); i >= 0 {
			oaNames[full[i+1:]] = true
		}
	}

	var onlyTS, onlyOA []string
	for n := range tsNames {
		if !oaNames[n] {
			onlyTS = append(onlyTS, n)
		}
	}
	for n := range oaNames {
		if !tsNames[n] {
			onlyOA = append(onlyOA, n)
		}
	}
	sort.Strings(onlyTS)
	sort.Strings(onlyOA)
	if len(onlyTS) > 0 || len(onlyOA) > 0 {
		t.Fatalf("gen/ts 与 openapi.json 类型名单不一致:\n 仅 gen/ts: %v\n 仅 openapi: %v", onlyTS, onlyOA)
	}
}
