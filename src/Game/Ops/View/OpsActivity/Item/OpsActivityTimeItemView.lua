---
--- Author: Administrator
--- DateTime: 2024-10-25 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoRes = require("Protocol/ProtoRes")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")
local TIME_DISPLAY_TYPE = ProtoRes.Game.TIME_DISPLAY_TYPE
---@class OpsActivityTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo USizeBox
---@field FCanvasPanel_0 UFCanvasPanel
---@field IconTime UFImage
---@field InforBtn CommInforBtnView
---@field PanelTime UFHorizontalBox
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityTimeItemView = LuaClass(UIView, true)

function OpsActivityTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.FCanvasPanel_0 = nil
	--self.IconTime = nil
	--self.InforBtn = nil
	--self.PanelTime = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityTimeItemView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)
	self.InforBtn:SetCheckClickedCallback(self, self.OnInforBtnClicked)
end

function OpsActivityTimeItemView:OnDestroy()

end

function OpsActivityTimeItemView:OnShow()
	if self.Params == nil then
		return
	end
	local ActivityDate = self.Params

	self.InforBtn.HelpInfoID = ActivityDate:GetActivityHelpInfo()
	UIUtil.SetIsVisible(self.BtnInfo, self.InforBtn.HelpInfoID > 0)
	
	local TimeDisplay = ActivityDate:GetActivityTimeDisplay()
	UIUtil.SetIsVisible(self.FCanvasPanel_0, true)
	UIUtil.SetIsVisible(self.IconTime, true)
	if TimeDisplay == TIME_DISPLAY_TYPE.COUNTDOWN_TIME then
		self.AdapterCountDownTime:Start(ActivityDate:GetActivityTimeCountdown(), 1, true, false)
	elseif TimeDisplay == TIME_DISPLAY_TYPE.COMMON_TIME then
		self.TextTime:SetText(ActivityDate:GetActivityCompleteTime())
	elseif  TimeDisplay == TIME_DISPLAY_TYPE.START_TIME then
		self.TextTime:SetText(ActivityDate:GetActivityAppointTime())
	else
		self.TextTime:SetText(_G.LSTR(970001))
		UIUtil.SetIsVisible(self.IconTime, false)
		UIUtil.SetIsVisible(self.FCanvasPanel_0, self.InforBtn.HelpInfoID > 0)
	end
end

function OpsActivityTimeItemView:OnHide()
end

function OpsActivityTimeItemView:OnRegisterUIEvent()
end

function OpsActivityTimeItemView:OnRegisterGameEvent()
end

function OpsActivityTimeItemView:OnRegisterBinder()
end

function OpsActivityTimeItemView:TimeOutCallback()
	self.TextTime:SetText(_G.LSTR(970002))
end

function OpsActivityTimeItemView:TimeUpdateCallback(LeftTime)
	return LocalizationUtil.GetCountdownTimeForLongTime(LeftTime, "")
end

function OpsActivityTimeItemView:OnInforBtnClicked()
	if self.Params.ActivityID then
		DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityInfoBtn), "0", self.Params.ActivityID)
	end
end

return OpsActivityTimeItemView