--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-21 11:24:26
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-21 15:56:58
FilePath: \Client\Source\Script\Game\FishNotesNew\View\FishIngholeDetailsPanel2View.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local UIUtil = require("Utils/UIUtil")

---@class FishIngholeDetailsPanel2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTop UFButton
---@field FishBait FishIngholeBaitItemView
---@field FishInformationI FishIngholeInformationItemView
---@field FishTime3 FishTime3ItemView
---@field FishTimeList FishTimeListView
---@field FishTimeProbar FishTimeProbarItemView
---@field ScrollBox UScrollBox
---@field AnimIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeDetailsPanel2View = LuaClass(UIView, true)

function FishIngholeDetailsPanel2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTop = nil
	--self.FishBait = nil
	--self.FishInformationI = nil
	--self.FishTime3 = nil
	--self.FishTimeList = nil
	--self.FishTimeProbar = nil
	--self.ScrollBox = nil
	--self.AnimIn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeDetailsPanel2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishBait)
	self:AddSubView(self.FishInformationI)
	self:AddSubView(self.FishTime3)
	self:AddSubView(self.FishTimeList)
	self:AddSubView(self.FishTimeProbar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeDetailsPanel2View:OnInit()
	self.Binders = {
		{"bFishWindowsVisible", UIBinderSetIsVisible.New(self, self.FishTimeList)},
		{"bFishWeatherVisible", UIBinderSetIsVisible.New(self, self.FishTime3)},
	}
end

function FishIngholeDetailsPanel2View:OnDestroy()
end

function FishIngholeDetailsPanel2View:OnShow()
	self:PlayAnimation(self.AnimIn)
	self:OnClickedBtnTop()
end

function FishIngholeDetailsPanel2View:OnHide()

end

function FishIngholeDetailsPanel2View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTop, self.OnClickedBtnTop)
	self:RegisterUIEvent(self.ScrollBox, "OnUserScrolled", self.OnScrolled)
end

function FishIngholeDetailsPanel2View:OnRegisterGameEvent()

end

function FishIngholeDetailsPanel2View:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishIngholeDetailsPanel2View:OnClickedBtnTop()
	self.ScrollBox:ScrollToStart()
	UIUtil.SetIsVisible(self.BtnTop, false, false)
end

function FishIngholeDetailsPanel2View:OnScrolled()
	local Value = self.ScrollBox:GetScrollOffset()
	if Value <= 0 then
		UIUtil.SetIsVisible(self.BtnTop, false, false)
	elseif not UIUtil.IsVisible(self.BtnTop) then
		UIUtil.SetIsVisible(self.BtnTop, true, true)
	end
end

return FishIngholeDetailsPanel2View