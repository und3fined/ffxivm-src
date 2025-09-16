local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local UIUtil = require("Utils/UIUtil")
local UTF8Util = require("Utils/UTF8Util")
local GuideGlobalCfg = require("TableCfg/GuideGlobalCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify

---@class ChatRemoveNewbieChannelWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnConfirm CommBtnLView
---@field CommSingleBox CommSingleBoxView
---@field InputReason CommMultilineInputBoxView
---@field RichTextRemovePlayer URichTextBox
---@field TextTimeLimit URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatRemoveNewbieChannelWinView = LuaClass(UIView, true)

function ChatRemoveNewbieChannelWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnCancel = nil
	--self.BtnConfirm = nil
	--self.CommSingleBox = nil
	--self.InputReason = nil
	--self.RichTextRemovePlayer = nil
	--self.TextTimeLimit = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatRemoveNewbieChannelWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.CommSingleBox)
	self:AddSubView(self.InputReason)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatRemoveNewbieChannelWinView:OnInit()
	self.BtnConfirm:SetText(LSTR(10002)) -- 10002("确  认")
	self.BtnCancel:SetText(LSTR(10003)) -- 10003("取  消")
	self.Bg:SetTitleText(LSTR(50132)) -- "移除详情"
end

function ChatRemoveNewbieChannelWinView:OnDestroy()

end

function ChatRemoveNewbieChannelWinView:OnShow()
	self.CommSingleBoxConfirm = false
	self.InputReasonConfirm = false
	local Params = self.Params
	if nil == Params then
		return
	end
	--Params.Identity
	self.BtnConfirm:SetIsEnabled(false, true )
	--self.BtnCancel.ParamColor = _G.UE.ECommBtnColor.Normal
	self.BtnCancel:SetButtonStatus(0)
	self.InputReason:SetText("")

	-- "移除%s频道的理由（必填）"
	local RTText = string.format(LSTR(50064), RichTextUtil.GetText(Params.TargetName, "4D85B4")) 
	self.RichTextRemovePlayer:SetText(RTText)

	-- "注意：处理人ID与处理结果会通告全频道；被移除的角色在一段时间内无法参加新人频道，指导者时间限制为%s，新人时间限制为%s。"
	local Text = string.format(LSTR(50065), self:GetCDTime(OnlineStatusUtil.EncodeBitset({OnlineStatusIdentify.OnlineStatusIdentifyMentor})), self:GetCDTime(OnlineStatusUtil.EncodeBitset({OnlineStatusIdentify.OnlineStatusIdentifyNewHandChat})))
	self.TextTimeLimit:SetText(Text)

	-- "移除指令应至针对有发广告或骚扰言行的玩家使用，请详细填写移除理由，以不正当理由移除他人有可能会收到处罚。"
	self.InputReason:SetHintText(LSTR(50066))
	self.InputReason:SetMaxNum(100)

	-- "同意上述内容并将目标移出频道"
	self.CommSingleBox:SetText(LSTR(50150))
	self.CommSingleBox:SetCheckedState(false)
end

function ChatRemoveNewbieChannelWinView:OnHide()

end

function ChatRemoveNewbieChannelWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnBtnConfirmClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnBtnCancelClick)
	UIUtil.AddOnTextChangedEvent(self, self.InputReason.FMultiLineInputText, self.InputReasonTextChanged)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox, self.OnStateChangedEvent)
end

function ChatRemoveNewbieChannelWinView:InputReasonTextChanged()
	local RemoveReason = self.InputReason:GetText()
	self.InputReasonConfirm = UTF8Util.Len(RemoveReason) > 0
	self.BtnConfirm:SetIsEnabled(self.CommSingleBoxConfirm and self.InputReasonConfirm, true)
end

function ChatRemoveNewbieChannelWinView:OnStateChangedEvent()
	self.CommSingleBoxConfirm = self.CommSingleBox:GetChecked()
	self.BtnConfirm:SetIsEnabled(self.CommSingleBoxConfirm and self.InputReasonConfirm, true )
end

function ChatRemoveNewbieChannelWinView:OnRegisterGameEvent()

end

function ChatRemoveNewbieChannelWinView:OnRegisterBinder()

end

function ChatRemoveNewbieChannelWinView:OnBtnConfirmClick()
	local Params = self.Params
	if nil == Params then
		return
	end
	if not self.CommSingleBoxConfirm and not self.InputReasonConfirm then 
		MsgTipsUtil.ShowTipsByID(105012)
		return 
	end
	if not self.CommSingleBoxConfirm then 
		MsgTipsUtil.ShowTipsByID(105011)
		return 
	end
	if not self.InputReasonConfirm then 
		MsgTipsUtil.ShowTipsByID(105010)
		return 
	end

	local Info = {
		Name = Params.TargetName,
		Identity = Params.Identity,
		OnlineStatusCustomID = Params.OnlineStatusCustomID,
	}

	local RemoveReason = self.InputReason:GetText()
	if UTF8Util.Len(RemoveReason) > 0 then
		_G.NewbieMgr:MoveOutNewbieChannelReq(Params.RoleID, Info, RemoveReason)
		self:Hide()
	end
end

function ChatRemoveNewbieChannelWinView:OnBtnCancelClick()
	self:Hide()
end

function ChatRemoveNewbieChannelWinView:GetCDTime(TargetIdentify)
	local OnlineStatusIdentifyEnum = OnlineStatusUtil.QueryMentorRelatedIdentity(TargetIdentify)
	local TextTimeLimit = nil
	if OnlineStatusIdentifyEnum == OnlineStatusIdentify.OnlineStatusIdentifyMentor then
		TextTimeLimit = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideBeKickOutCoolingTime, "Value")[1]
	elseif OnlineStatusIdentifyEnum == OnlineStatusIdentify.OnlineStatusIdentifyReturner then
		TextTimeLimit = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideReturneeBeKickOutCoolingTime, "Value")[1]
	elseif OnlineStatusIdentifyEnum == OnlineStatusIdentify.OnlineStatusIdentifyNewHand then
		TextTimeLimit = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideNewbieBeKickOutCoolingTime, "Value")[1]
		--- "%s分钟"
		return  string.format(LSTR(50152), tostring(math.floor(tonumber(TextTimeLimit or "0") / 60)))   
	end
	--- "%s小时"
	return  string.format(LSTR(50151), tostring(math.floor(tonumber(TextTimeLimit or "0") / 3600)))
end

return ChatRemoveNewbieChannelWinView