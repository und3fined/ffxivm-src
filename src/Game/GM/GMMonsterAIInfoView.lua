---
--- Author: haialexzhou
--- DateTime: 2022-07-11 20:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local CS_CMD = ProtoCS.CS_CMD
local CS_DEBUG_CMD = ProtoCS.CS_DEBUG_CMD
local ActorUtil = require("Utils/ActorUtil")

---@class GMMonsterAIInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content URichTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMMonsterAIInfoView = LuaClass(UIView, true)
--local ShowUITimer = nil
local AITargetID = 0

function GMMonsterAIInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMMonsterAIInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMMonsterAIInfoView:OnInit()

end

function GMMonsterAIInfoView:OnDestroy()

end

function GMMonsterAIInfoView:OnShow()
	
end

function GMMonsterAIInfoView:OnHide()

end

function GMMonsterAIInfoView:OnRegisterUIEvent()

end

function GMMonsterAIInfoView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.GMGetMonsterAIInfo, self.OnUpdateMonsterAIInfo)
end

function GMMonsterAIInfoView:OnRegisterBinder()

end

function GMMonsterAIInfoView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.2, 0)
end

function GMMonsterAIInfoView:OnTimer()
	local MajorTargetID = _G.TargetMgr:GetMajorSelectedTarget()
	if nil == MajorTargetID or MajorTargetID <= 0 or MajorUtil.IsMajor(MajorTargetID) then
		return
	end

	self:SendReq(MajorTargetID)
end

function GMMonsterAIInfoView:SendReq(TargetID)
	AITargetID = TargetID
	--_G.FLOG_INFO("SendReq TargetID=%d",TargetID)
	local MsgID = CS_CMD.CS_CMD_DEBUG
	local MsgBody = {}
	local SubMsgID = CS_DEBUG_CMD.CS_DEBUG_CMD_AI_INFO_GET
	local ai_info_req = {}
	ai_info_req.entity_id = TargetID
	MsgBody.Cmd = SubMsgID
	MsgBody.ai_info_req  = ai_info_req
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GMMonsterAIInfoView:OnUpdateMonsterAIInfo(Params)
    if (Params ~= nil) then
		--_G.FLOG_INFO("OnUpdateMonsterAIInfo Params=%s",Params)
		if ActorUtil.IsCombatState(AITargetID) then
			self.Content:SetText(Params)
		else
			local result = string.match(Params, "^(.-)-------.*")

			if result then
				self.Content:SetText(result)
			else
				self.Content:SetText(Params)
			end
			
		end
	end
end

return GMMonsterAIInfoView