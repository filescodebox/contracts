// =====================================================================
// admin.thrift — 管理员模块
// =====================================================================
// 迁移自: idl/admin.proto
// =====================================================================

namespace go admin

// ==================== 管理员登录 ====================

struct AdminLoginReq {
    1: required string username (api.body = "username"),
    2: required string password (api.body = "password"),
}

struct AdminLoginData {
    1: required string token      (api.body = "token"),
    2: required string token_type (api.body = "token_type"),
    3: required i64    expires_in (api.body = "expires_in"),
}

struct AdminLoginResp {
    1: required i32            code    (api.body = "code"),
    2: required string         message (api.body = "message"),
    3: required AdminLoginData data    (api.body = "data"),
}

// ==================== 系统统计 ====================

struct AdminStatsReq {
}

struct AdminStatsData {
    1: required i64 total_files      (api.body = "total_files"),
    2: required i64 total_users      (api.body = "total_users"),
    3: required i64 total_size       (api.body = "total_size"),
    4: required i64 today_uploads    (api.body = "today_uploads"),
    5: required i64 today_downloads  (api.body = "today_downloads"),
}

struct AdminStatsResp {
    1: required i32             code    (api.body = "code"),
    2: required string          message (api.body = "message"),
    3: required AdminStatsData  data    (api.body = "data"),
}

// ==================== 文件管理 ====================

struct AdminListFilesReq {
    1: required i32    page       (api.query = "page"),
    2: required i32    page_size  (api.query = "page_size"),
    3: optional string keyword    (api.query = "keyword"),
    4: optional string sort_by    (api.query = "sort_by"),
}

struct FileItem {
    1: required i64    id             (api.body = "id"),
    2: required string code           (api.body = "code"),
    3: required string file_name      (api.body = "file_name"),
    4: required i64    file_size      (api.body = "file_size"),
    5: required string expire_time    (api.body = "expire_time"),
    6: required i32    view_count     (api.body = "view_count"),
    7: required i32    download_count (api.body = "download_count"),
    8: required string created_at     (api.body = "created_at"),
}

struct AdminFileList {
    1: required list<FileItem> items     (api.body = "items"),
    2: required i64            total     (api.body = "total"),
    3: required i32            page      (api.body = "page"),
    4: required i32            page_size (api.body = "page_size"),
}

struct AdminListFilesResp {
    1: required i32            code    (api.body = "code"),
    2: required string         message (api.body = "message"),
    3: required AdminFileList  data    (api.body = "data"),
}

// ==================== 删除文件 ====================

struct AdminDeleteFileReq {
    1: required i64 id (api.path = "id"),
}

struct AdminDeleteFileResp {
    1: required i32    code    (api.body = "code"),
    2: required string message (api.body = "message"),
}

// ==================== 用户管理 ====================

struct AdminListUsersReq {
    1: required i32    page       (api.query = "page"),
    2: required i32    page_size  (api.query = "page_size"),
    3: optional string keyword    (api.query = "keyword"),
    4: optional i32    status     (api.query = "status"),
}

struct UserItem {
    1: required i64    id          (api.body = "id"),
    2: required string username    (api.body = "username"),
    3: required string email       (api.body = "email"),
    4: required string nickname    (api.body = "nickname"),
    5: required i32    status      (api.body = "status"),
    6: required i64    quota_used  (api.body = "quota_used"),
    7: required i64    quota_limit (api.body = "quota_limit"),
    8: required string created_at  (api.body = "created_at"),
}

struct AdminUserList {
    1: required list<UserItem> items     (api.body = "items"),
    2: required i64            total     (api.body = "total"),
    3: required i32            page      (api.body = "page"),
    4: required i32            page_size (api.body = "page_size"),
}

struct AdminListUsersResp {
    1: required i32           code    (api.body = "code"),
    2: required string        message (api.body = "message"),
    3: required AdminUserList data    (api.body = "data"),
}

// ==================== 更新用户状态 ====================

struct AdminUpdateUserStatusReq {
    1: required i64 id     (api.path = "id"),
    2: required i32 status (api.body = "status"),
}

struct AdminUpdateUserStatusResp {
    1: required i32    code    (api.body = "code"),
    2: required string message (api.body = "message"),
}

// ==================== 系统配置 ====================
// 契约形态(2026-10-06 定):配置体 = 领域 SystemConfig(app/admin/service.go)
// 的扁平 JSON。配置段随功能版本演进(指针段 nil-overlay、未设段回退 yaml,
// 服务端整体校验),契约层刻意不锁形——自由格式对象,OpenAPI 视角为空
// schema,语义以本注释为准。新增配置段无需改本文件。

struct AdminGetConfigReq {
}

// data = SystemConfig 全量 JSON(base/storage/transfer/user/ui/upload_ex/
// download/notify/local_import/oidc/api_token/runtime_storage 等段;
// omitempty 指针段未在线设置时不下发)。前端按段读取,未知段忽略。
struct AdminConfigData {
}

struct AdminGetConfigResp {
    1: required i32             code    (api.body = "code"),
    2: required string          message (api.body = "message"),
    3: required AdminConfigData data    (api.body = "data"),
}

// body = SystemConfig 局部 JSON:只带要改的段,nil 段保留现状。
// 注意:勿包 {config:...} 壳——曾因包壳导致新段写入被静默丢弃(假开关,
// v0.13.5 修复;旧三段 typed 契约同时退役)。
struct AdminUpdateConfigReq {
}

struct AdminUpdateConfigResp {
    1: required i32    code    (api.body = "code"),
    2: required string message (api.body = "message"),
}

// ==================== 服务定义 ====================

service AdminService {
    // AdminLogin 管理员登录
    AdminLoginResp AdminLogin(1: AdminLoginReq req) (api.post = "/admin/login")

    // AdminStats 系统统计
    AdminStatsResp AdminStats(1: AdminStatsReq req) (api.get = "/admin/stats")

    // AdminListFiles 文件列表
    AdminListFilesResp AdminListFiles(1: AdminListFilesReq req) (api.get = "/admin/files")

    // AdminDeleteFile 删除文件
    AdminDeleteFileResp AdminDeleteFile(1: AdminDeleteFileReq req) (api.delete = "/admin/files/:id")

    // AdminListUsers 用户列表
    AdminListUsersResp AdminListUsers(1: AdminListUsersReq req) (api.get = "/admin/users")

    // AdminUpdateUserStatus 更新用户状态
    AdminUpdateUserStatusResp AdminUpdateUserStatus(1: AdminUpdateUserStatusReq req) (api.put = "/admin/users/:id/status")

    // AdminGetConfig 获取系统配置
    AdminGetConfigResp AdminGetConfig(1: AdminGetConfigReq req) (api.get = "/admin/config")

    // AdminUpdateConfig 更新系统配置
    AdminUpdateConfigResp AdminUpdateConfig(1: AdminUpdateConfigReq req) (api.put = "/admin/config")
}
