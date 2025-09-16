---
--- Author: Administrator
--- DateTime: 2025-03-18 14:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldExploraSelectionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field HorizontalNormal UFHorizontalBox
---@field ImgLight UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field PanelSelect UFCanvasPanel
---@field TextNormal UFTextBlock
---@field TextSelect UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraSelectionItemView = LuaClass(UIView, true)

function WorldExploraSelectionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.HorizontalNormal = nil
	--self.ImgLight = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.PanelSelect = nil
	--self.TextNormal = nil
	--self.TextSelect = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraSelectionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraSelectionItemView:OnInit()

end

function WorldExploraSelectionItemView:OnDestroy()

end

function WorldExploraSelectionItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	self.TextNormal:SetText(Data.Name or "")
	self.TextSelect:SetText(Data.Name or "")
end

function WorldExploraSelectionItemView:OnHide()

end

function WorldExploraSelectionItemView:OnRegisterUIEvent()

end

function WorldExploraSelectionItemView:OnRegisterGameEvent()

end

function WorldExploraSelectionItemView:OnRegisterBinder()

end


function WorldExploraSelectionItemView:OnSelectChanged(IsSelected)
	self:StopAnimation(self.AnimCheck)
    self:StopAnimation(self.AnimUncheck)

	if (IsSelected) then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUncheck)
	end

	UIUtil.SetIsVisible(self.PanelSelect, IsSelected)
	UIUtil.SetIsVisible(self.TextSelect, IsSelected)
	UIUtil.SetIsVisible(self.HorizontalNormal, not IsSelected)
end

return WorldExploraSelectionItemView