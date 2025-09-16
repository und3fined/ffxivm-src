-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _2_1 = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Frame01.UI_PWorld_Img_Inlet_Frame01\'',
    _3_1 = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061802.UI_Icon_061802\'',
}

---@class SceneEnterTypeCfg : CfgBase
local SceneEnterTypeCfg = {
	TableName = "c_scene_enter_type_cfg",
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
        BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Entrance_Img_Pic03.UI_PWorld_Entrance_Img_Pic03\'',
        FrameImage = '',
        ID = 1,
        Icon = '',
        LockBG = '',
        Type = 1,
    },
	LuaData = {
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG01.UI_PWorld_Img_Inlet_BG01\'',
            FrameImage = CS._2_1,
            Icon = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061808.UI_Icon_061808\'',
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG01.UI_PWorld_Img_Inlet_Lock_BG01\'',
        },
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG02.UI_PWorld_Img_Inlet_BG02\'',
            FrameImage = CS._2_1,
            ID = 2,
            Icon = CS._3_1,
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG02.UI_PWorld_Img_Inlet_Lock_BG02\'',
            Type = 2,
        },
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG03.UI_PWorld_Img_Inlet_BG03\'',
            FrameImage = CS._2_1,
            ID = 3,
            Icon = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061805.UI_Icon_061805\'',
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG03.UI_PWorld_Img_Inlet_Lock_BG03\'',
            Type = 3,
        },
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG04.UI_PWorld_Img_Inlet_BG04\'',
            FrameImage = CS._2_1,
            ID = 4,
            Icon = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061803.UI_Icon_061803\'',
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG04.UI_PWorld_Img_Inlet_Lock_BG04\'',
            Type = 4,
        },
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG06.UI_PWorld_Img_Inlet_BG06\'',
            ID = 5,
            Icon = 'Texture2D\'/Game/Assets/Icon/900000/UI_Icon_900258.UI_Icon_900258\'',
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG06.UI_PWorld_Img_Inlet_Lock_BG06\'',
            Type = 5,
        },
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG05.UI_PWorld_Img_Inlet_BG05\'',
            ID = 6,
            Icon = 'Texture2D\'/Game/Assets/Icon/900000/UI_Icon_900257.UI_Icon_900257\'',
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG05.UI_PWorld_Img_Inlet_Lock_BG05\'',
            Type = 8,
        },
        {
            ID = 7,
            Type = 7,
        },
        {
            BG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_BG07.UI_PWorld_Img_Inlet_BG07\'',
            ID = 9,
            Icon = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061807.UI_Icon_061807\'',
            LockBG = 'Texture2D\'/Game/UI/Texture/PWorld/UI_PWorld_Img_Inlet_Lock_BG07.UI_PWorld_Img_Inlet_Lock_BG07\'',
            Type = 9,
        },
        {
            ID = 10,
            Type = 10,
        },
        {
            ID = 11,
            Type = 11,
        },
        {
            BG = '',
            ID = 12,
            Icon = 'Texture2D\'/Game/Assets/Icon/061000/UI_Icon_061809.UI_Icon_061809\'',
            Type = 12,
        },
        {
            BG = '',
            ID = 13,
            Icon = CS._3_1,
            Type = 13,
        },
	},
}

setmetatable(SceneEnterTypeCfg, { __index = CfgBase })

SceneEnterTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
local PWorldEntIDCache = nil
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")

local function InitPWorldEntIDCache()
	PWorldEntIDCache = {}
	local All = SceneEnterTypeCfg:FindAllCfg()

	local AllEntNorm = SceneEnterCfg:FindAllCfg()
	local AllEntRand = SceneEnterDailyRandomCfg:FindAllCfg()

	for _, V in pairs(All) do
		local ID = V.ID
		PWorldEntIDCache[ID] = {}
	end

	for _, V in pairs(AllEntNorm) do
		local TypeID = V.TypeID
		if PWorldEntIDCache[TypeID] then
			table.insert(PWorldEntIDCache[TypeID], V.ID)
		end
	end

	for _, V in pairs(AllEntRand) do
		local TypeID = V.TypeID
		if PWorldEntIDCache[TypeID] then
			table.insert(PWorldEntIDCache[TypeID], V.ID)
		end
	end
end

function SceneEnterTypeCfg:GetPWorldEntIDs(TypeID)
	if not PWorldEntIDCache then
		InitPWorldEntIDCache()
	end

	return PWorldEntIDCache[TypeID]
end

return SceneEnterTypeCfg
