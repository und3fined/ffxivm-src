---
--- Author: chriswang
--- DateTime: 2025-05-16 15:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR
local SaveKey = require("Define/SaveKey")
local SettingsVM = require("Game/Settings/VM/SettingsVM")

---@class SettingsFPSSettingWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChoose UFButton
---@field BtnChoose_1 UFButton
---@field BtnYes CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgSelect UFImage
---@field ImgSelect_1 UFImage
---@field RichTextType URichTextBox
---@field RichTextType_1 URichTextBox
---@field TextDescribe UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsFPSSettingWinView = LuaClass(UIView, true)

function SettingsFPSSettingWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChoose = nil
	--self.BtnChoose_1 = nil
	--self.BtnYes = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgSelect = nil
	--self.ImgSelect_1 = nil
	--self.RichTextType = nil
	--self.RichTextType_1 = nil
	--self.TextDescribe = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsFPSSettingWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnYes)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsFPSSettingWinView:OnInit()
	self.CurMode = 0
end

function SettingsFPSSettingWinView:OnDestroy()

end

function SettingsFPSSettingWinView:OnShow()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(110067))	--设置副本帧率模式
	self.TextDescribe:SetText(LSTR(110068))
	self.RichTextType:SetText(LSTR(110069))		--推荐模式<span color="#89bd88">（推荐）</>
	self.RichTextType_1:SetText(LSTR(110070))	--自定义<span color="#dc5868">（不推荐）</>
	self.TextContent:SetText(LSTR(110071))		--副本中帧率将会锁定：中帧率
	self.TextContent_1:SetText(LSTR(110072))	--副本中将保持当前帧率
	
	UIUtil.SetIsVisible(self.ImgSelect, false)
	UIUtil.SetIsVisible(self.ImgSelect_1, false)

	UIUtil.SetIsVisible(self.Comm2FrameM_UIBP.ButtonClose, false)
	self.BtnYes:SetIsEnabled(false, true)
	self.BtnYes:SetText(LSTR(110032))
end

function SettingsFPSSettingWinView:OnHide()

end

function SettingsFPSSettingWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChoose, self.OnModeLeftBtnChoose)
	UIUtil.AddOnClickedEvent(self, self.BtnChoose_1, self.OnModeRightBtnChoose)
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnBtnYes)

end

function SettingsFPSSettingWinView:OnRegisterGameEvent()

end

function SettingsFPSSettingWinView:OnRegisterBinder()

end

function SettingsFPSSettingWinView:OnModeLeftBtnChoose()
	UIUtil.SetIsVisible(self.ImgSelect, true)
	UIUtil.SetIsVisible(self.ImgSelect_1, false)
	self.CurMode = 2
	self.BtnYes:SetIsEnabled(true, true)
end

function SettingsFPSSettingWinView:OnModeRightBtnChoose()
	UIUtil.SetIsVisible(self.ImgSelect, false)
	UIUtil.SetIsVisible(self.ImgSelect_1, true)
	self.CurMode = 1
	self.BtnYes:SetIsEnabled(true, true)
end

function SettingsFPSSettingWinView:OnBtnYes()
	if self.CurMode == 0 or not self.CurMode then
		_G.MsgTipsUtil.ShowTips(LSTR(110073))
		return
	end

	_G.SettingsMgr:SetValueBySaveKey("PerformanceMode", self.CurMode)
	_G.EventMgr:SendEvent(_G.EventID.SettingsMaxFPSChanged)
	SettingsVM:SetCategory(6)
	SettingsVM:UpdateItemList(true)

	self:Hide()

	FLOG_INFO("setting PopUI Select PerformanceMode:%d", self.CurMode)
end

return SettingsFPSSettingWinView