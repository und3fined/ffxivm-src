-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LinkshellCfg : CfgBase
local LinkshellCfg = {
	TableName = "c_linkshell_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = {
        ID = 1,
        Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_01_png.UI_NewFriend_Icon_JoinIn_01_png\'',
        Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_01_png.UI_NewFriend_Icon_Activity_01_png\'',
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_03_png.UI_NewFriend_Icon_JoinIn_03_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_03_png.UI_NewFriend_Icon_Activity_03_png\'',
        },
        {
            ID = 3,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_02_png.UI_NewFriend_Icon_JoinIn_02_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_02_png.UI_NewFriend_Icon_Activity_02_png\'',
        },
        {
            ID = 4,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_04_png.UI_NewFriend_Icon_JoinIn_04_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_04_png.UI_NewFriend_Icon_Activity_04_png\'',
        },
        {
            ID = 5,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_05_png.UI_NewFriend_Icon_JoinIn_05_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_05_png.UI_NewFriend_Icon_Activity_05_png\'',
        },
        {
            ID = 6,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_06_png.UI_NewFriend_Icon_JoinIn_06_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_06_png.UI_NewFriend_Icon_Activity_06_png\'',
        },
        {
            ID = 7,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_07_png.UI_NewFriend_Icon_JoinIn_07_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_07_png.UI_NewFriend_Icon_Activity_07_png\'',
        },
        {
            ID = 8,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_08_png.UI_NewFriend_Icon_JoinIn_08_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_08_png.UI_NewFriend_Icon_Activity_08_png\'',
        },
        {
            ID = 9,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_09_png.UI_NewFriend_Icon_JoinIn_09_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_09_png.UI_NewFriend_Icon_Activity_09_png\'',
        },
        {
            ID = 10,
            Icon = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_JoinIn_10_png.UI_NewFriend_Icon_JoinIn_10_png\'',
            Icon2 = 'PaperSprite\'/Game/UI/Atlas/NewFriend/Frames/UI_NewFriend_Icon_Activity_10_png.UI_NewFriend_Icon_Activity_10_png\'',
        },
	},
}

setmetatable(LinkshellCfg, { __index = CfgBase })

LinkshellCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取活动信息列表
---@return table
function LinkshellCfg:GetActList()
	local Ret = self:FindAllCfg()
	return Ret or {}
end

return LinkshellCfg
