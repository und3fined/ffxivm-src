local OpenGVoiceLog = false -- 是否开启GVoice日志
local IsTestDev = false -- 是否测试环境
local MaxRecordTime  = 20    -- 最长录音时间
local MinRecordTime  = 1     -- 最短录音时间

-- 参考 TestMic 函数返回值 (http://gcloud.oa.com/pages/documents/details.html?projectId=255&docId=3036）
-- Android 环境返回值
local MicCheckNo = {
    GetJaveEnvFailed = -2,      -- 安卓获取Jave Env 失败
    InterfaceError = -1,        -- 接口调用出错
    Succ = 0,                   -- 麦克风可用
    AndroidNoPermission = 100,  -- 没有麦克风权限(安卓)
    NoPermission = 200,     -- 没有麦克风权限
    NoMicDevice = 201,      -- 无效的麦克风设备
    ErrorJNI = 202,         -- JNI调用出错
    ErrorRecording = 4100,  -- 正在进行录音，请先停止录音，然后再调用 TestMic 接口
    NoInit = 4105,          -- 没有进行初始化
}

local GCloudVoiceCompleteCode = {
    -- Common codes (0x1000 系列)
    GV_ON_OK = 0x1000,                          -- 4096, 操作成功
    GV_ON_NET_ERR = 0x1001,                     -- 4097, 网络错误
    GV_ON_UNKNOWN = 0x1002,                     -- 4098, 未知错误
    GV_ON_INTERNAL_ERR = 0x1003,                -- 4099, 内部错误（需日志定位）
    GV_ON_BUSINESS_NOT_FOUND = 0x1004,          -- 4100, 业务未开通
    GV_ON_FAIL = 0x1005,                        -- 4101, 操作失败
    GV_ON_SHOULD_ONE_ROOM_ONE_SCENES = 0x1006,  -- 4102, 房间与场景需一一对应

    -- 实时语音模块 (0x2000 系列)
    GV_ON_JOINROOM_SUCC = 0x2001,           -- 8193, 加入房间成功
    GV_ON_JOINROOM_TIMEOUT = 0x2002,        -- 8194, 加入房间超时
    GV_ON_JOINROOM_SVR_ERR = 0x2003,        -- 8195, 服务器通信错误
    GV_ON_JOINROOM_UNKNOWN = 0x2004,        -- 8196, 未知错误（保留）
    GV_ON_JOINROOM_RETRY_FAIL = 0x2005,     -- 8197, 重试加入失败
    GV_ON_QUITROOM_SUCC = 0x2006,           -- 8198, 退出房间成功
    GV_ON_ROOM_OFFLINE = 0x2007,            -- 8199, 房间断线
    GV_ON_ROLE_SUCC = 0x2008,               -- 8200, 角色切换成功
    GV_ON_ROLE_TIMEOUT = 0x2009,            -- 8201, 角色切换超时
    GV_ON_ROLE_MAX_AHCHOR = 0x2010,         -- 8202, 主播人数超限
    GV_ON_ROLE_NO_CHANGE = 0x2011,          -- 8203, 角色未改变
    GV_ON_ROLE_SVR_ERROR = 0x2012,          -- 8204, 服务器角色错误

    -- 消息模式 (0x3000 系列)
    GV_ON_MESSAGE_KEY_APPLIED_SUCC = 0x3001,        -- 12289, 密钥申请成功
    GV_ON_MESSAGE_KEY_APPLIED_TIMEOUT = 0x3002,     -- 12290, 密钥申请超时
    GV_ON_MESSAGE_KEY_APPLIED_SVR_ERR = 0x3003,     -- 12291, 服务器通信错误
    GV_ON_MESSAGE_KEY_APPLIED_UNKNOWN = 0x3004,     -- 12292, 未知错误（保留）
    GV_ON_UPLOAD_RECORD_DONE = 0x3005,              -- 12293, 文件上传成功
    GV_ON_UPLOAD_RECORD_ERROR = 0x3006,             -- 12294, 文件上传错误
    GV_ON_DOWNLOAD_RECORD_DONE = 0x3007,            -- 12295, 文件下载成功
    GV_ON_DOWNLOAD_RECORD_ERROR = 0x3008,           -- 12296, 文件下载错误
    GV_ON_PLAYFILE_DONE = 0x3009,                   -- 12297, 文件播放完成
    GV_ON_DOWNLOAD_FILEID_NOT_EXIST = 0x3010,       -- 12304, 文件ID不存在
    GV_ON_UPLOAD_FILEID_CIVIL_FAILED = 0x3011,      -- 12305, 文明语音上传失败

    -- 翻译模块 (0x4000-0x5000 系列)
    GV_ON_STT_SUCC = 0x4001,                -- 16385, 语音转写成功
    GV_ON_STT_TIMEOUT = 0x4002,             -- 16386, 语音转写超时
    GV_ON_STT_APIERR = 0x4003,              -- 16387, 服务端API错误
    GV_ON_RSTT_SUCC = 0x5001,               -- 20481, 流式转写成功
    GV_ON_RSTT_TIMEOUT = 0x5002,            -- 20482, 流式转写超时
    GV_ON_RSTT_APIERR = 0x5003,             -- 20483, 服务端错误
    GV_ON_RSTT_RETRY = 0x5004,              -- 20484, 需要重试
    GV_ON_RSTT_SHORT = 0x5005,              -- 20485, 语音时长过短

    -- 语音举报 (0x6000 系列)
    GV_ON_REPORT_SUCC = 0x6001,             -- 24577, 举报成功
    GV_ON_DATA_ERROR = 0x6002,              -- 24578, 数据非法
    GV_ON_PUNISHED = 0x6003,                -- 24579, 玩家被处罚
    GV_ON_NOT_PUNISHED = 0x6004,            -- 24580, 玩家未被处罚
    GV_ON_KEY_DELECTED = 0x6005,            -- 24581, 密钥被删除
    GV_ON_REPORT_SUCC_SELF = 0x6006,        -- 24582, 自我举报成功

    -- LGame 相关 (0x7000 系列)
    GV_ON_SAVEDATA_SUCC = 0x7001,          -- 28673, 保存录音成功
    GV_ON_KARAOKE_DONE = 0x7002,           -- 28674, 卡拉OK完成
    GV_ON_KARAOKE_CANCEL = 0x7003,         -- 28675, 卡拉OK取消

    -- 房间成员状态 (0x8000 系列)
    GV_ON_ROOM_MEMBER_INROOM = 0x8001,          -- 32769, 成员加入房间
    GV_ON_ROOM_MEMBER_OUTROOM = 0x8002,         -- 32770, 成员离开房间
    GV_ON_ROOM_MEMBER_MICOPEN = 0x8003,         -- 32771, 成员开麦
    GV_ON_ROOM_MEMBER_MICCLOSE = 0x8004,        -- 32772, 成员闭麦
    GV_ON_DEVICE_EVENT_ADD = 0x8101,            -- 33025, 设备添加事件
    GV_ON_DEVICE_EVENT_UNUSABLE = 0x8102,       -- 33026, 设备不可用
    GV_ON_DEVICE_EVENT_DEFAULTCHANGE = 0x8103,  -- 33027, 默认设备变更

    -- 文明语音 (0x9000 系列)
    GV_ON_UPLOAD_REPORT_INFO_ERROR = 0x9001,    -- 36865, 举报信息上传错误
    GV_ON_UPLOAD_REPORT_INFO_TIMEOUT = 0x9002,  -- 36866, 举报信息上传超时

    -- 语音翻译 (0xA000 系列)
    GV_ON_ST_SUCC = 0xA001,                -- 40961, 语音翻译成功
    GV_ON_ST_HTTP_ERROR = 0xA002,          -- 40962, HTTP通信错误
    GV_ON_ST_SERVER_ERROR = 0xA003,        -- 40963, 服务端错误
    GV_ON_ST_INVALID_JSON = 0xA004,        -- 40964, JSON解析失败
    GV_ON_ST_ALREADY_EXIST = 0xA005,       -- 40965, 操作已进行
    GV_ON_ST_RC_FAILED = 0xA006,           -- 40966, 资源分配失败

    -- 小程序相关 (0xB000 系列)
    GV_ON_WX_UPLOAD_SUCC = 0xB001,         -- 45057, 信息上传成功
    GV_ON_WX_UPLOAD_ERR = 0xB002,          -- 45058, 信息上传失败
    GV_ON_WX_ROOM_SUCC = 0xB003,           -- 45059, 房间查询成功
    GV_ON_WX_ROOM_ERR = 0xB004,            -- 45060, 房间查询失败
    GV_ON_WX_USER_SUCC = 0xB005,           -- 45061, 用户查询成功
    GV_ON_WX_USER_ERR = 0xB006,            -- 45062, 用户查询失败

    -- 实时翻译 (0xC000 系列)
    GV_ON_TRANSLATE_SUCC = 0xC001,         -- 49153, 实时翻译启用成功
    GV_ON_TRANSLATE_SERVER_ERR = 0xC002,   -- 49154, 实时翻译服务错误

    -- 魔法语音 (0xD000 系列)
    GV_ON_MAGICVOICE_SUCC = 0xD001,             -- 53249, 魔法语音启用成功
    GV_ON_MAGICVOICE_SERVER_ERR = 0xD002,       -- 53250, 魔法语音服务错误
    GV_ON_RECVMAGICVOICE_SUCC = 0xD003,         -- 53251, 接收魔法语音成功
    GV_ON_RECVMAGICVOICE_SERVER_ERR = 0xD004,   -- 53252, 接收魔法语音失败
    GV_ON_MAGICVOICE_FILE_SUCC = 0xD005,        -- 53253, 离线文件上传成功
    GV_ON_MAGICVOICE_FILE_FAIL = 0xD006         -- 53254, 离线文件处理失败
}

local VoiceDefine = {
    OpenGVoiceLog   = OpenGVoiceLog,
    IsTestDev       = IsTestDev,
    MaxRecordTime   = MaxRecordTime,
    MinRecordTime   = MinRecordTime,
    MicCheckNo      = MicCheckNo,

    GCloudVoiceCompleteCode = GCloudVoiceCompleteCode,
}

return VoiceDefine