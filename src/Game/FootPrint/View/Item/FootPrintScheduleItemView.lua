---
--- Author: Administrator
--- DateTime: 2024-04-01 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local FootPrintMgr = require("Game/FootPrint/FootPrintMgr")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local FootPrintVM = require("Game/FootPrint/FootPrintVM")
local LSTR = _G.LSTR

---@class FootPrintScheduleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bar UProgressBar
---@field Btn CommBtnMView
---@field EFF_Bar UFCanvasPanel
---@field TextFootPrint UFTextBlock
---@field TexxtSchedule UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FootPrintScheduleItemView = LuaClass(UIView, true)

function FootPrintScheduleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bar = nil
	--self.Btn = nil
	--self.EFF_Bar = nil
	--self.TextFootPrint = nil
	--self.TexxtSchedule = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FootPrintScheduleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FootPrintScheduleItemView:InitConstStringInfo()
	self.TextFootPrint:SetText(LSTR(320002))
	self.Btn:SetButtonText(LSTR(320003))
	
end

function FootPrintScheduleItemView:OnInit()
	self.Binders = {
		{"ScheduleText", UIBinderSetText.New(self, self.TexxtSchedule)},
		{"SchedulePercent", UIBinderSetPercent.New(self, self.Bar)},
		{"bCanLight", UIBinderSetIsVisible.New(self, self.Btn, nil, true)},
		{"bCanLight", UIBinderSetIsVisible.New(self, self.EFF_Bar)},
	}
	self:InitConstStringInfo()
end

function FootPrintScheduleItemView:OnDestroy()

end

function FootPrintScheduleItemView:OnShow()

end

function FootPrintScheduleItemView:OnHide()

end

function FootPrintScheduleItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FootPrintScheduleItemView:OnRegisterGameEvent()

end

function FootPrintScheduleItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function FootPrintScheduleItemView:OnBtnClicked()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local SchedulePercent = ViewModel.SchedulePercent
	if not SchedulePercent or SchedulePercent < 1 then
		MsgTipsUtil.ShowErrorTips(LSTR(320001))
		return
	end--]]

	local RegionID = ViewModel.RegionID
	if not RegionID then
		return
	end
	
	FootPrintMgr:SendMsgReceiveFootMarkRegionAwardReq(RegionID)
	--[[FootPrintMgr.CurLightRegionID = RegionID
	FootPrintVM:OnNotifyMapRewardReceived(RegionID)--]]
end

return FootPrintScheduleItemView