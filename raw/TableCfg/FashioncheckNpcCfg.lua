-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FashioncheckNpcCfg : CfgBase
local FashioncheckNpcCfg = {
	TableName = "c_fashioncheck_npc_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        HeadIconImage = 'Texture2D\'/Game/UI/Texture/Cards/Avatar/UI_Cards_Img_Avatar_5.UI_Cards_Img_Avatar_5\'',
        ID = 1,
        _Location = '{"Y":200,"X":0,"Z":100100}',
        NPCID = 29041526,
        _Rotation = '{"Y":0,"X":0,"Z":0}',
    },
	LuaData = {
        {
        },
        {
            HeadIconImage = 'Texture2D\'/Game/UI/Texture/Cards/Avatar/UI_Cards_Img_Avatar_1.UI_Cards_Img_Avatar_1\'',
            ID = 2,
            _Location = '{"Y":100,"X":0,"Z":100100}',
            NPCID = 29041527,
        },
        {
            HeadIconImage = 'Texture2D\'/Game/UI/Texture/Cards/Avatar/UI_Cards_Img_Avatar_2.UI_Cards_Img_Avatar_2\'',
            ID = 3,
            _Location = '{"Y":0,"X":0,"Z":100100}',
            NPCID = 29041528,
        },
        {
            HeadIconImage = 'Texture2D\'/Game/UI/Texture/Cards/Avatar/UI_Cards_Img_Avatar_3.UI_Cards_Img_Avatar_3\'',
            ID = 4,
            _Location = '{"Y":-100,"X":0,"Z":100100}',
            NPCID = 29041529,
        },
        {
            HeadIconImage = 'Texture2D\'/Game/UI/Texture/Cards/Avatar/UI_Cards_Img_Avatar_4.UI_Cards_Img_Avatar_4\'',
            ID = 5,
            _Location = '{"Y":-200,"X":0,"Z":100100}',
            NPCID = 29041530,
        },
	},
}

setmetatable(FashioncheckNpcCfg, { __index = CfgBase })

FashioncheckNpcCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FashioncheckNpcCfg
