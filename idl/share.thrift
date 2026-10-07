// =====================================================================
// share.thrift — 分享
// =====================================================================
// 迁移自: idl/share.proto
// =====================================================================

namespace go share

// ==================== 分享文本 ====================

struct ShareTextReq {
    1: required string text          (api.body = "text"),
    2: required i32    expire_value  (api.body = "expire_value"),
    3: required string expire_style  (api.body = "expire_style"),  // minute, hour, day, week, month, year, forever
    4: required bool   require_auth  (api.body = "require_auth"),
    // 密码保护:require_auth 时必填(前端 multipart form 发送;此前 handler DefaultPostForm 直读)
    5: optional string password      (api.body = "password"),
    // 自定义取件码(P3):仅登录用户可指定(防匿名抢注)
    6: optional string custom_code   (api.body = "custom_code"),
    // E2E 密文分享:true 时文本跳过 HTML 转义(转义会破坏解密)
    7: optional bool   encrypted     (api.body = "encrypted"),
}

struct ShareData {
    1: required string code (api.body = "code"),
    2: required string url  (api.body = "url"),
    // 6 位取件码（2026-10-07 起文件分享铸造：pickup_code → code 的 KV 映射，
    // 匿名通道 retrieve/search/download 均可解析；文本分享与永久分享不铸造，为空）
    3: optional string pickup_code (api.body = "pickup_code"),
}

struct ShareTextResp {
    1: required i32       code    (api.body = "code"),
    2: required string    message (api.body = "message"),
    3: required ShareData data    (api.body = "data"),
}

// ==================== 分享文件 ====================

struct ShareFileReq {
    // 文件通过 multipart/form-data 上传
    1: required i32    expire_value (api.form = "expire_value"),
    2: required string expire_style (api.form = "expire_style"),
    3: required bool   require_auth (api.form = "require_auth"),
    // 密码保护:require_auth 时必填
    4: optional string password     (api.form = "password"),
}

struct ShareFileResp {
    1: required i32       code    (api.body = "code"),
    2: required string    message (api.body = "message"),
    3: required ShareData data    (api.body = "data"),
}

// ==================== 获取分享 ====================

struct GetShareReq {
    1: required string code     (api.path = "code"),
    2: optional string password (api.query = "password"),
}

struct ShareDetail {
    1: required string code         (api.body = "code"),
    2: required string text         (api.body = "text"),
    3: required string file_name    (api.body = "file_name"),
    4: required string file_size    (api.body = "file_size"),   // 后端格式化前的字节数字符串
    5: required string url          (api.body = "url"),
    6: required bool   has_password (api.body = "has_password"),
    7: required string expire_time  (api.body = "expire_time"),
    // ---- 以下为此前 handler ad-hoc map 附加字段(v0.6.0 入契约) ----
    8:  optional string download_url (api.body = "download_url"), // 带下载令牌的取件链接(security.download_token.enabled 时必须携带)
    9:  optional string token        (api.body = "token"),        // 下载令牌(功能关闭时不下发)
    10: optional bool   encrypted    (api.body = "encrypted"),    // E2E 密文,前端以链接 #fragment 密钥解密
    11: optional bool   is_multi     (api.body = "is_multi"),     // 多文件分享(前端显示"打包下载")
    12: optional list<ShareFileItem> files (api.body = "files"),  // 文件清单(含单文件,前端统一渲染)
}

// 多文件清单项
struct ShareFileItem {
    1: required i64    id   (api.body = "id"),
    2: required string name (api.body = "name"),
    3: required i64    size (api.body = "size"),
}

struct GetShareResp {
    1: required i32         code    (api.body = "code"),
    2: required string      message (api.body = "message"),
    3: required ShareDetail data    (api.body = "data"),
}

// ==================== 下载分享 ====================

struct DownloadFileReq {
    1: required string code     (api.query = "code"),
    2: optional string password (api.query = "password"),
}

struct DownloadFileResp {
    // 文件下载使用流式响应，此消息用于 JSON 错误响应
    1: required i32    code    (api.body = "code"),
    2: required string message (api.body = "message"),
}

// ==================== 服务定义 ====================

service ShareService {
    // ShareText 分享文本
    ShareTextResp ShareText(1: ShareTextReq req) (api.post = "/share/text/")

    // ShareFile 分享文件
    ShareFileResp ShareFile(1: ShareFileReq req) (api.post = "/share/file/")

    // GetShare 获取分享内容
    GetShareResp GetShare(1: GetShareReq req) (api.get = "/share/select/")

    // DownloadFile 下载文件
    DownloadFileResp DownloadFile(1: DownloadFileReq req) (api.get = "/share/download")
}
