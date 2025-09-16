-- local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
-- local ProfDefine = require("Game/Profession/ProfDefine")
-- local ProtoCS = require("Protocol/ProtoCS")
-- local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
-- local SceneDailyRandomTaskPoolCfg = require("TableCfg/SceneDailyRandomTaskPoolCfg")
-- local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
-- local JoinErrorCode = PWorldEntDefine.JoinErrorCode
-- local SceneMode = ProtoCommon.SceneMode
-- local FUNCTION_TYPE = ProtoCommon.function_type
-- local ScenePoolType = ProtoCommon.ScenePoolType
-- local MajorUtil = require("Utils/MajorUtil")
-- local LevelExpCfg = require("TableCfg/LevelExpCfg")

-- local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
-- local RoleInitCfg = require("TableCfg/RoleInitCfg")

local ProfUtil = require("Game/Profession/ProfUtil")

local ProtoCommon = require("Protocol/ProtoCommon")

local FuncTy = ProtoCommon.function_type


local BGDict = {
	[FuncTy.FUNCTION_TYPE_GUARD] = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Image_DefenceBg.UI_Entourage_Image_DefenceBg'", 
	[FuncTy.FUNCTION_TYPE_RECOVER] = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Image_HealBg.UI_Entourage_Image_HealBg'", 
	[FuncTy.FUNCTION_TYPE_ATTACK] = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Image_AttackBg.UI_Entourage_Image_AttackBg'", 
}

local Util = {}

function Util.GetProfFrame(Prof)
    local ProfFunc = ProfUtil.Prof2Func(Prof)
	
	if ProfFunc then
		return BGDict[ProfFunc] or ""
	end
	_G.FLOG_ERROR("zhg Util.GetProfFrame Frame Res = nil, ProfFunc = " .. tostring(ProfFunc) .. 
					" Prof = " .. tostring(Prof))
    return ""
end

function Util.GetDefaultFrame()
    return BGDict[FuncTy.FUNCTION_TYPE_ATTACK]
end

return Util