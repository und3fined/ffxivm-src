-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MiniappQqParamsCfg : CfgBase
local MiniappQqParamsCfg = {
	TableName = "c_miniapp_qq_params_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        Desc = 'QQ小程序描述',
        ID = 1,
        Link = 'https://www.qq.com',
        MiniAppID = '1109878856',
        MiniPath = 'pages/index/index',
        MiniProgramType = 3,
        MiniWebpageUrl = '',
        ThumbPath = 'https://game.gtimg.cn/images/ff14/act/a20250214call/share.png',
        Title = 'QQ小程序',
    },
	LuaData = {
        {
        },
        {
            Desc = '',
            ID = 2,
            Link = '',
            ThumbPath = '',
            Title = '',
        },
	},
}

setmetatable(MiniappQqParamsCfg, { __index = CfgBase })

MiniappQqParamsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MiniappQqParamsCfg
