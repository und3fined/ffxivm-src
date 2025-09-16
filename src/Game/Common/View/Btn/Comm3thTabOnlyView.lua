---
--- Author: v_zanchang
--- DateTime: 2023-05-16 09:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class Comm3thTabOnlyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn3th UFButton
---@field ImgBtnSelect UFImage
---@field ImgIconNormal UFImage
---@field ImgIconSelect UFImage
---@field ImgLeftLine UFImage
---@field ScaleBoxText UScaleBox
---@field TextTabName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm3thTabOnlyView = LuaClass(UIView, true)

function Comm3thTabOnlyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn3th = nil
	--self.ImgBtnSelect = nil
	--self.ImgIconNormal = nil
	--self.ImgIconSelect = nil
	--self.ImgLeftLine = nil
	--self.ScaleBoxText = nil
	--self.TextTabName = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm3thTabOnlyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm3thTabOnlyView:OnInit()

end

function Comm3thTabOnlyView:OnDestroy()

end

function Comm3thTabOnlyView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end
end

function Comm3thTabOnlyView:OnHide()

end

function Comm3thTabOnlyView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn3th, self.OnClickButtonItem)
	UIUtil.AddOnDoubleClickedEvent(self, self.Btn3th, self.OnDoubleClickButtonItem)
end

function Comm3thTabOnlyView:OnRegisterGameEvent()

end

function Comm3thTabOnlyView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function Comm3thTabOnlyView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

function Comm3thTabOnlyView:OnDoubleClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemDoubleClicked(self, Params.Index)
end

function Comm3thTabOnlyView:OnSelectChanged(IsSelected)
	if IsSelected then
		self:PlayAnimation(self.AnimCheck)
		UIUtil.SetIsVisible(self.ImgIconSelect, true)
	else
		self:PlayAnimation(self.AnimUncheck)
	end

	--使用ItemVM.SelectMode，不要在这里加if else

	-- if ViewModel.AwardID == 0 or ViewModel.IsAlreadyPossessed or ViewModel.Obtained then
	-- 	UIUtil.SetIsVisible(self.FImg_Select, IsSelected)
	-- 	UIUtil.SetIsVisible(self.FImg_Preview, false)
	-- else
	-- 	UIUtil.SetIsVisible(self.FImg_Preview, IsSelected)
	-- 	UIUtil.SetIsVisible(self.FImg_Select, false)
	-- end
	-- if ViewModel.AwardID == nil then
	-- 	UIUtil.SetIsVisible(self.FImg_Select, IsSelected)
	-- else
	-- 	UIUtil.SetIsVisible(self.FImg_Preview, IsSelected)
	-- end

end

return Comm3thTabOnlyView