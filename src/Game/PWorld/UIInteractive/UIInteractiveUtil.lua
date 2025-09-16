--
-- Author: ashyuan
-- Date: 2024-4-9
-- Description:副本UI交互通用方法
--

local LuaClass = require("Core/LuaClass")
local GlobalCfg = require("TableCfg/GlobalCfg")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local PworldUiInteractiveCfg = require("TableCfg/PworldUiInteractiveCfg")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")

local CS_CMD = ProtoCS.CS_CMD

---@class UIInteractiveUtil
local UIInteractiveUtil = {}

-- function UIInteractiveUtil.CheckSceneID(SceneID)
--     local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
--     local SceneIDTable = GlobalCfg:FindValue(SceneID, "Value")
--     if table.contain(SceneIDTable, PWorldResID) then
--         return true
--     end
--     return false
-- end

function UIInteractiveUtil.GetInteractiveConfig(UIType)
	return PworldUiInteractiveCfg:FindAllCfgByUIType(UIType)
end

function UIInteractiveUtil.SendInteractiveByGuideID(GuideID)
	local TeachUICfg = PworldUiInteractiveCfg:FindAllCfgByUIType(ProtoRes.pworld_ui_type.PWORLD_UI_GUIDE)
    for i = 1, #TeachUICfg do
        local Param = TeachUICfg[i].Param
		if (Param == nil or Param[1] == nil) then
            FLOG_ERROR("SendInteractiveByGuideID Error! Cfg InVaild")
            return
        end

        local CfgID = Param[1]
		if CfgID == GuideID then
			local InteractiveID = TeachUICfg[i].InteractiveID
			UIInteractiveUtil.SendInteractiveReq(InteractiveID)
			return
		end
	end
	--FLOG_ERROR("SendInteractiveByGuideID Error! GuideID[%d] InVaild", GuideID)
end

function UIInteractiveUtil.SendInteractiveReq(InteractiveDescID)
	-- local MsgID = CS_CMD.CS_CMD_INTERAVIVE
	-- local SubMsgID = ProtoCS.CsInteractionCMD.CsInteractionCMDStart

	-- local MsgBody = {}
	-- MsgBody.Cmd = SubMsgID
	-- MsgBody.Start = {
    --     InteractiveID = InteractiveDescID,
    --     Obj = {ObjID = 0, Type = ProtoCS.InteractionObjType.InteractionObjTypeEmpty}
    -- }

	-- _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	_G.InteractiveMgr:SendInteractiveStartReqWithoutObj(InteractiveDescID)
end

function UIInteractiveUtil.InteractiveIsCompleted(InteractiveID)

	local Cfg = PworldUiInteractiveCfg:FindCfgByInteractiveID(InteractiveID)

    if not Cfg or not Cfg.Param then
        FLOG_ERROR("Interactive descCfg id: %d need Cofig", InteractiveID)
        return false
    end

	local ConditionID = Cfg.Param[4]
	if ConditionID == nil then
		FLOG_ERROR("Interactive descCfg id: %d Param Null", InteractiveID)
		return false
	end

	-- 判断条件是否完成
	if ConditionMgr:CheckConditionByID(ConditionID) then
		return true
	else
		return false
	end
end

return UIInteractiveUtil