---
--- Author: jamiyang
--- DateTime: 2024-07-05 20:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local FLinearColor = _G.UE.FLinearColor
local LoginMapMgr = _G.LoginMapMgr

---@class HaircutPreviewTab02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgBgSelect UFImage
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutPreviewTab02ItemView = LuaClass(UIView, true)

function HaircutPreviewTab02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgBgSelect = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutPreviewTab02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutPreviewTab02ItemView:OnInit()
	self.Binders = {
		{ "TextTitle", UIBinderSetText.New(self, self.TextName)},
	}
end

function HaircutPreviewTab02ItemView:OnDestroy()

end

function HaircutPreviewTab02ItemView:OnShow()
	if self.Params then
		--Cfg可能是职业演示套装、种族演示套装，也可能是
		local Name = self.Params.Data
		if Name ~= nil and type(Name) == "string" then
			self.TextName:SetText(Name)
		end
	end
end

function HaircutPreviewTab02ItemView:OnHide()

end

function HaircutPreviewTab02ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnSubBtnClick)
end

function HaircutPreviewTab02ItemView:OnRegisterGameEvent()

end

function HaircutPreviewTab02ItemView:OnRegisterBinder()
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

function HaircutPreviewTab02ItemView:OnSelectChanged(IsSelected)
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

function HaircutPreviewTab02ItemView:SetTextColor(IsSelected)
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

function HaircutPreviewTab02ItemView:OnSubBtnClick()
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

return HaircutPreviewTab02ItemView