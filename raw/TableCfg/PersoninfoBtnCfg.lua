-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Army_png.UI_Profile_Icon_Army_png\'',
}

---@class PersoninfoBtnCfg : CfgBase
local PersoninfoBtnCfg = {
	TableName = "c_personinfo_btn_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = {
        BtnIcon = '',
        ID = 1,
        IsResident = 1,
        Priority = 9,
    },
	LuaData = {
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Chat_png.UI_Profile_Icon_Chat_png\'',
            Priority = 2,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_AddFriend_png.UI_Profile_Icon_AddFriend_png\'',
            ID = 2,
            Priority = 1,
        },
        {
            ID = 3,
            Priority = 3,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_LinkShell_png.UI_Profile_Icon_LinkShell_png\'',
            ID = 4,
            Priority = 5,
        },
        {
            BtnIcon = CS._1_1,
            ID = 5,
            Priority = 6,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Channel_png.UI_Profile_Icon_Channel_png\'',
            ID = 6,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Block_png.UI_Profile_Icon_Block_png\'',
            ID = 7,
            Priority = 17,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Report_png.UI_Profile_Icon_Report_png\'',
            ID = 8,
            Priority = 8,
        },
        {
            ID = 9,
            IsResident = 0,
        },
        {
            ID = 10,
            IsResident = 0,
            Priority = 10,
        },
        {
            ID = 11,
            IsResident = 0,
            Priority = 11,
        },
        {
            ID = 12,
            IsResident = 0,
            Priority = 12,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_RideInvite_png.UI_Profile_Icon_RideInvite_png\'',
            ID = 13,
            IsResident = 0,
            Priority = 13,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Team_png.UI_Profile_Icon_Team_png\'',
            ID = 14,
            Priority = 4,
        },
        {
            BtnIcon = CS._1_1,
            ID = 15,
            Priority = 15,
        },
        {
            BtnIcon = CS._1_1,
            ID = 16,
            Priority = 16,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_Trade_png.UI_Profile_Icon_Trade_png\'',
            ID = 17,
            Priority = 7,
        },
        {
            BtnIcon = 'PaperSprite\'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_InviteSign_png.UI_Profile_Icon_InviteSign_png\'',
            ID = 18,
            Priority = 18,
        },
	},
}

setmetatable(PersoninfoBtnCfg, { __index = CfgBase })

PersoninfoBtnCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PersoninfoBtnCfg
