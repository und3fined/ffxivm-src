-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MiniappWechatParamsCfg : CfgBase
local MiniappWechatParamsCfg = {
	TableName = "c_miniapp_wechat_params_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        GameData = '',
        ID = 1,
        Link = 'pages/index/index?sCode=1234',
        MediaPath = 'pages/index/index?sCode=1234',
        MediaTagName = 'MSG_INVITE',
        MiniAppID = 'gh_5249c375c947',
        MiniProgramType = 2,
        ShareTicket = 0,
        ThumbPath = 'https://game.gtimg.cn/images/ff14/act/a20250214call/share.png',
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            Link = '',
            MediaTagName = '',
            ThumbPath = '',
        },
	},
}

setmetatable(MiniappWechatParamsCfg, { __index = CfgBase })

MiniappWechatParamsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MiniappWechatParamsCfg
