-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HeadPortraitCfg : CfgBase
local HeadPortraitCfg = {
	TableName = "c_head_portrait_cfg",
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
        _DefActive = '[]',
        _Desc = '[]',
        ID = 1,
        _Icon = '["Texture2D\'/Game/Assets/Icon/Head/UI_Icon_Head_MR.UI_Icon_Head_MR\'"]',
        _IsInvisibleNotHave = '[]',
        RaceID = 1,
        _NameNum = 1,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
            RaceID = 2,
        },
        {
            ID = 3,
            RaceID = 3,
        },
        {
            ID = 4,
            RaceID = 4,
        },
        {
            ID = 5,
            RaceID = 5,
        },
        {
            ID = 6,
            RaceID = 6,
        },
        {
            ID = 7,
            RaceID = 7,
        },
        {
            ID = 8,
            RaceID = 8,
        },
        {
            ID = 9,
            RaceID = 9,
        },
        {
            ID = 10,
            RaceID = 10,
        },
        {
            ID = 11,
            RaceID = 11,
        },
        {
            ID = 12,
            RaceID = 12,
        },
        {
            ID = 13,
            RaceID = 13,
        },
        {
            ID = 14,
            RaceID = 14,
        },
        {
            ID = 15,
            RaceID = 15,
        },
        {
            ID = 16,
            RaceID = 16,
        },
        {
            ID = 17,
            RaceID = 17,
        },
        {
            ID = 18,
            RaceID = 18,
        },
        {
            ID = 19,
            RaceID = 19,
        },
        {
            ID = 20,
            RaceID = 20,
        },
	},
}

setmetatable(HeadPortraitCfg, { __index = CfgBase })

HeadPortraitCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取所有头像信息列表
---@return table
function HeadPortraitCfg:GetHeadPortraitList()
	local Ret = self:FindAllCfg()
	return Ret or {}
end

---获取头像图标
---@param ID number @头像ID 
---@return string 
function HeadPortraitCfg:GetHeadIcon( ID )
	local Ret = self:FindCfgByKey(ID)
	if Ret then
		return Ret.Icon[1]
	end
end

---获取头像图标
---@param ID number @头像ID 
---@return string 
function HeadPortraitCfg:GetHeadIconByRaceID( RaceID, Idx )
	local All = self:GetHeadPortraitList()
        
	for _, Item in pairs(All) do
		if Item.RaceID == RaceID then
			return Item.Icon[Idx]
		end
	end
end

return HeadPortraitCfg
