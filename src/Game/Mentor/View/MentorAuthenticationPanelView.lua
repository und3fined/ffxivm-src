---
--- Author: Administrator
--- DateTime: 2023-03-30 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoCameraUtil = require("Game/Photo/Util/PhotoCameraUtil")
local MentorMgr = require("Game/Mentor/MentorMgr")
local MentorDefine = require("Game/Mentor/MentorDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local GUIDE_TYPE = ProtoCommon.GUIDE_TYPE

local LSTR = _G.LSTR

---@class MentorAuthenticationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnConfirm CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field ImgHand UFImage
---@field ImgHand_1 UFImage
---@field ImgMentorIcon UFImage
---@field PanelConfirmGoldSaucer UFCanvasPanel
---@field PanelConfirmNormal UFCanvasPanel
---@field PanelGoldSaucer UFCanvasPanel
---@field PanelNormalBG UFCanvasPanel
---@field PanelSeal UFCanvasPanel
---@field PanelSeal_1 UFCanvasPanel
---@field TextRule UFTextBlock
---@field TextRuleDetail UFTextBlock
---@field TextSeal UFTextBlock
---@field TextTitle UFTextBlock
---@field TextWarning UFTextBlock
---@field AnimConfirm UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MentorAuthenticationPanelView = LuaClass(UIView, true)

function MentorAuthenticationPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnConfirm = nil
	--self.CloseBtn = nil
	--self.ImgHand = nil
	--self.ImgHand_1 = nil
	--self.ImgMentorIcon = nil
	--self.PanelConfirmGoldSaucer = nil
	--self.PanelConfirmNormal = nil
	--self.PanelGoldSaucer = nil
	--self.PanelNormalBG = nil
	--self.PanelSeal = nil
	--self.PanelSeal_1 = nil
	--self.TextRule = nil
	--self.TextRuleDetail = nil
	--self.TextSeal = nil
	--self.TextTitle = nil
	--self.TextWarning = nil
	--self.AnimConfirm = nil
	--self.AnimHide = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MentorAuthenticationPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MentorAuthenticationPanelView:OnInit()
end

function MentorAuthenticationPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)
end

function MentorAuthenticationPanelView:OnRegisterGameEvent()

end

function MentorAuthenticationPanelView:OnRegisterBinder()
	
end

function MentorAuthenticationPanelView:OnDestroy()

end

function MentorAuthenticationPanelView:TranslatedText()
	self.BtnConfirm:SetText(LSTR(760039))
	self.TextRule:SetText(LSTR(760032))
	self.TextRuleDetail:SetText(LSTR(760033))
	self.TextWarning:SetText(LSTR(760034))
	self.TextSeal:SetText(LSTR(760025))
end

function MentorAuthenticationPanelView:OnShow()
	self:TranslatedText()
	self.KeepClicking = false
	if self.Params == nil then
		return 
	end
	self.BubbleTimerID = nil
	--PhotoCameraUtil.SetOffset(200,0)
	local ShowType = self.Params.ShowType or 0

	local bGoldSauserType = ShowType == GUIDE_TYPE.GUIDE_TYPE_GOLD_SAUSER
	UIUtil.SetIsVisible(self.PanelGoldSaucer, bGoldSauserType)
	UIUtil.SetIsVisible(self.PanelNormalBG, not bGoldSauserType)

	UIUtil.SetIsVisible(self.PanelConfirmGoldSaucer, bGoldSauserType)
	UIUtil.SetIsVisible(self.PanelConfirmNormal, not bGoldSauserType)
	
	self.TextTitle:SetText(MentorDefine.FinishTabs[ShowType].AuthenticationPanelTextTips)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgMentorIcon, MentorDefine.FinishTabs[ShowType].AuthenticationPanelImgMentorIcon)

	local NPCEntityID = _G.InteractiveMgr.CurInteractEntityID
	self.NPCEntityID = NPCEntityID
	_G.SpeechBubbleMgr:ShowBubbleSingle(NPCEntityID, MentorDefine.NPCAuthenticationBubbleText) 
	self.BubbleTimerID = self:RegisterTimer(function() _G.SpeechBubbleMgr:HideBubbleSingle(NPCEntityID) self.BubbleTimerID = nil end, 3)
end

function MentorAuthenticationPanelView:OnHide()
	self:PlayAnimation(self.AnimHide)
	PhotoCameraUtil.SetOffset(0,0)
	if self.BubbleTimerID ~= nil then
		_G.SpeechBubbleMgr:HideBubbleSingle(self.NPCEntityID)
	end
	if self.PlayUnlockTips then
		local ShowType = (self.Params or {}).ShowType or 0
		_G.MentorMainPanelVM:OpenMentorUnlockTips(ShowType)
		self.PlayUnlockTips = false
	end
end

function MentorAuthenticationPanelView:OnClickBtnConfirm()
	if not self.KeepClicking then
		MentorMgr:SendMsgMentorConfirmReq(self.Params.ShowType)
		self.KeepClicking = true
		self:RegisterTimer(function() self.KeepClicking = false end ,1.0 )
	end
end

function MentorAuthenticationPanelView:AuthenticationFeedback(IsSuccess)
	self:UnRegisterAllTimer()
	self.KeepClicking = true
	if self.Params == nil then return end
	if IsSuccess then
		self:PlayAnimation(self.AnimConfirm)
		local AnimTime = self.AnimConfirm:GetEndTime() or 1
		self.PlayUnlockTips = true
		self:RegisterTimer(function ()
			local ShowType = self.Params.ShowType or 0
			self.PlayUnlockTips = false
			self:Hide()
			_G.MentorMainPanelVM:OpenMentorUnlockTips(ShowType)
		end, AnimTime)
	else
		self:Hide()
	end
end

return MentorAuthenticationPanelView