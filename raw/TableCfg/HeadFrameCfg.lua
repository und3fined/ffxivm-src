-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HeadFrameCfg : CfgBase
local HeadFrameCfg = {
	TableName = "c_head_frame_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'FrameName',
            },
            {
                Name = 'Description',
            },
            {
                Name = 'Access',
            },
		}
    },
    DefaultValues = {
        FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame.UI_Profile_Img_Frame\'',
        FrameType = 2,
        ID = 1,
        ItemID = 0,
        LifeTimeDesc = '',
        Timelimit = 0,
        UnlockType = 2,
    },
	LuaData = {
        {
            UnlockType = 1,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame4.UI_Profile_Img_Frame4\'',
            FrameType = 3,
            ID = 2,
            ItemID = 61900039,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame15.UI_Profile_Img_Frame15\'',
            ID = 11,
            ItemID = 61900105,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame16.UI_Profile_Img_Frame16\'',
            ID = 12,
            ItemID = 61900149,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame17.UI_Profile_Img_Frame17\'',
            ID = 13,
            ItemID = 61900150,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame10.UI_Profile_Img_Frame10\'',
            FrameType = 3,
            ID = 101,
            ItemID = 61900093,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame11.UI_Profile_Img_Frame11\'',
            FrameType = 3,
            ID = 102,
            ItemID = 61900097,
        },
        {
            FrameIcon = 'Texture2D\'/Game/UI/Texture/PersonInfo/UI_Profile_Img_Frame9.UI_Profile_Img_Frame9\'',
            FrameType = 4,
            ID = 1001,
            LifeTimeDesc = '战令赛季限时',
            UnlockType = 0,
        },
	},
}

setmetatable(HeadFrameCfg, { __index = CfgBase })

HeadFrameCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return HeadFrameCfg
