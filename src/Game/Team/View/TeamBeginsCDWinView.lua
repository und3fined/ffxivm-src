---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-06 10:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local SliderMinValue = 5
local SliderMaxValue = 30

---@class TeamBeginsCDWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnStart CommBtnLView
---@field CommCountSlider CommCountSliderView
---@field TextTimes UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamBeginsCDWinView = LuaClass(UIView, true)

function TeamBeginsCDWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnCancel = nil
	--self.BtnStart = nil
	--self.CommCountSlider = nil
	--self.TextTimes = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamBeginsCDWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.CommCountSlider)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamBeginsCDWinView:OnInit()
	self.DefaultSliderValue = 10
end

function TeamBeginsCDWinView:OnDestroy()

end

function TeamBeginsCDWinView:OnShow()
	self.CommCountSlider:SetSliderValueMaxMin(SliderMaxValue, SliderMinValue)
	self.CurrentSliderValue = tonumber(_G.ClientSetupMgr:GetSetupValue(MajorUtil:GetMajorRoleID(), ClientSetupID.CSTeamCountDownDefaultNum) or self.DefaultSliderValue)
	self.CommCountSlider:SetSliderValue(self.CurrentSliderValue)
	self.Bg:SetTitleText(LSTR(1240043))
	self.TextTips:SetText(LSTR(1240047))
	self.TextSetting:SetText(LSTR(1240048))
	self.BtnCancel:SetText(LSTR(1240045))
	self.BtnStart:SetText(LSTR(1240046))
end

function TeamBeginsCDWinView:OnHide()

end

function TeamBeginsCDWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnStart)
	self.CommCountSlider:SetValueChangedCallback(function (v)
		self:SliderValueChangedCallback(v)
	end)
end

function TeamBeginsCDWinView:OnRegisterGameEvent()

end

function TeamBeginsCDWinView:OnRegisterBinder()

end

function TeamBeginsCDWinView:OnClickBtnCancel()
	self:Hide()
end

function TeamBeginsCDWinView:OnClickBtnStart()
	local ServerTime = _G.TimeUtil.GetServerTimeMS()
	_G.SignsMgr.LastClickedCDTimeMS = ServerTime
	_G.PWorldMgr:SendCountDown(self.CurrentSliderValue)
	_G.ClientSetupMgr:SendSetReq(ClientSetupID.CSTeamCountDownDefaultNum, tostring(self.CurrentSliderValue))
	self:Hide()
end

function TeamBeginsCDWinView:SliderValueChangedCallback(Value)
	self.TextTimes:SetText(string.format(LSTR(1240044), Value))	--- "%d秒"
	self.CurrentSliderValue = Value
end

return TeamBeginsCDWinView