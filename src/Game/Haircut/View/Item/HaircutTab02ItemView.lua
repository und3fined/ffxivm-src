---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local FLinearColor = _G.UE.FLinearColor
local LoginMapMgr = _G.LoginMapMgr

---@class HaircutTab02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgBgSelect UFImage
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutTab02ItemView = LuaClass(UIView, true)

function HaircutTab02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgBgSelect = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutTab02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutTab02ItemView:OnInit()
	self.Binders = {
		{ "TextTitle", UIBinderSetText.New(self, self.TextName)},
	}
end

function HaircutTab02ItemView:OnDestroy()

end

function HaircutTab02ItemView:OnShow()
	if self.Params then
		--Cfg可能是职业演示套装、种族演示套装，也可能是
		local Name = self.Params.Data
		if Name ~= nil and type(Name) == "string" then
			self.TextName:SetText(Name)
		end
	end
end

function HaircutTab02ItemView:OnHide()

end

function HaircutTab02ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnSubBtnClick)
end

function HaircutTab02ItemView:OnRegisterGameEvent()

end

function HaircutTab02ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel or type(ViewModel) == "string" then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)

end

function HaircutTab02ItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.OnSelectedChange then
		ViewModel:OnSelectedChange(IsSelected)
	end
	self:SetTextColor(IsSelected)

	if IsSelected then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUncheck)
	end
end

function HaircutTab02ItemView:SetTextColor(IsSelected)
	local HexColor = "#fff4d0"
	local OutlineColor = "8066447F"
	if IsSelected == false then
		local bDarkMap = LoginMapMgr:IsHaircutDefaultMap()
		if bDarkMap then
			HexColor = "#878075"
		else
			HexColor = "#d5d5d5"
		end
		OutlineColor = "2121217F"
	end
	local LinearColor = FLinearColor.FromHex(HexColor)

	self.TextName:SetColorAndOpacity(LinearColor)

	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextName, OutlineColor)
end

function HaircutTab02ItemView:OnSubBtnClick()
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


return HaircutTab02ItemView