---
--- Author: loiafeng
--- DateTime: 2023-03-28 09:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OnlineStatusDefine = require("Game/OnlineStatus/OnlineStatusDefine")

local LSTR = _G.LSTR

---@class OnlineStatusInfoTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnYes CommBtnLView
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OnlineStatusInfoTipsView = LuaClass(UIView, true)

function OnlineStatusInfoTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnYes = nil
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OnlineStatusInfoTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnYes)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OnlineStatusInfoTipsView:OnInit()

end

function OnlineStatusInfoTipsView:OnDestroy()

end

function OnlineStatusInfoTipsView:OnShow()
	self.BtnYes:SetText(LSTR(10002))
	self.BtnCancel:SetText(LSTR(10003))
	self.BG:SetTitleText(LSTR(OnlineStatusDefine.NotifyText.SettingConfirm))
	self.RichTextContent:SetText(LSTR(OnlineStatusDefine.NotifyText.MentorConfirmContent))
end

function OnlineStatusInfoTipsView:OnHide()

end

function OnlineStatusInfoTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnConfirm)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnCancel)
end

function OnlineStatusInfoTipsView:OnRegisterGameEvent()

end

function OnlineStatusInfoTipsView:OnRegisterBinder()

end

function OnlineStatusInfoTipsView:OnConfirm()
	local Params = self.Params
	if Params == nil then
		return
	end

	local StatusID = Params.StatusID
	if StatusID == nil then
		return
	end

	_G.OnlineStatusMgr:SetCustomStatus(StatusID, true)
	self.Params = nil
	-- _G.UIViewMgr:HideView(_G.UIViewID.OnlineStatusSettingsPanel)
	-- _G.UIViewMgr:HideView(_G.UIViewID.OnlineStatusSettingsTips)
end

function OnlineStatusInfoTipsView:OnCancel()
	_G.UIViewMgr:HideView(_G.UIViewID.OnlineStatusSettingsTips)
	self.Params = nil
end

return OnlineStatusInfoTipsView