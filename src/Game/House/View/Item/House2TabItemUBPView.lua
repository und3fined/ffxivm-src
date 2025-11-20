---
--- Author: mingyyzhang
--- DateTime: 2025-06-16 19:40
--- Description:
---

local CommMenuParentItemView = require("Game/Common/Menu/CommMenuParentItemView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")

---@class House2TabItemUBPView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconArrowNoraml UFImage
---@field IconArrowSelect UFImage
---@field ImgNoraml UFImage
---@field ImgSelect UFImage
---@field PanelIcon UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextTab UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

local House2TabItemUBPView = LuaClass(CommMenuParentItemView, true)
local MenuGetSelectKeyFun = nil

function House2TabItemUBPView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconArrowNoraml = nil
	--self.IconArrowSelect = nil
	--self.ImgNoraml = nil
	--self.ImgSelect = nil
	--self.PanelIcon = nil
	--self.RedDot = nil
	--self.TextTab = nil
	--self.AnimCheck = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimUncheck = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function House2TabItemUBPView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function House2TabItemUBPView:OnInit()
    self.IsSelected = nil
    self.IsExpanded = false
    self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextTab) },
		{ "IsExpanded", UIBinderValueChangedCallback.New(self, nil, self.OnExpandedChanged) },
		{ "IsShowTogetherWithChildItem", UIBinderValueChangedCallback.New(self, nil, self.OnShowTogetherWithChildItem) }
	}

    self.TextTabFont = self.TextTab.Font
end

function House2TabItemUBPView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end

    UIUtil.SetIsVisible(self.ImgSelect, false)
    self:UpdateTextColorBySelect(false)
    self:UpdateItem(Params.Data)
    local ViewModel = Params.Data
    if (not ViewModel.IsModuleOpen or ViewModel.IsUnLock) and not ViewModel.IsAutoExpand then
        UIUtil.SetIsVisible(self.PanelIcon, false)
    else
        UIUtil.SetIsVisible(self.PanelIcon, true)
    end
end

function House2TabItemUBPView:OnHide()
	UIUtil.SetIsVisible(self.IconArrowSelect, false)
	UIUtil.SetIsVisible(self.IconArrowNoraml, false)
	self:StopAllAnimations()
	MenuGetSelectKeyFun = nil
end

function House2TabItemUBPView:OnSelectChanged(IsSelected)
	if self.IsSelected == IsSelected then return end

	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if not ViewModel.IsUnLock then return end

	self.IsSelected = IsSelected
	local Adapter = Params.Adapter
	if Adapter and not IsSelected then
		local Child = ViewModel:FindChild(Adapter.SelectedItem)
		if Child then
			self.IsSelected = true
		end
	end
	UIUtil.SetIsVisible(self.ImgSelect, self.IsSelected)

	self:UpdateTextColorBySelect(self.IsSelected)
    self:UpdateArrowShow()
end

function House2TabItemUBPView:UpdateArrowShow()
	local Params = self.Params
	local ViewModel = Params.Data

    UIUtil.SetIsVisible(self.IconArrowSelect, false)
    UIUtil.SetIsVisible(self.IconArrowNoraml, false)
	if ViewModel and ViewModel.IsAutoExpand then
        if self.IsSelected then
            UIUtil.SetIsVisible(self.IconArrowSelect, true)
            if self.IsExpanded then
                self.IconArrowSelect:SetRenderTransformAngle(0)
            else
                self.IconArrowSelect:SetRenderTransformAngle(-180)
            end
        else
            UIUtil.SetIsVisible(self.IconArrowNoraml, true)
        end
    end
end

function House2TabItemUBPView:SetRedDotShowByData(Data)
    if Data.RedDotID then
		self.RedDot:SetRedDotIDByID(Data.RedDotID)
	end
end

function House2TabItemUBPView:UpdateItem(Data)
	if not Data then return end
	self:SetRedDotShowByData(Data)		

	local IsSelected = self.IsSelected
	if MenuGetSelectKeyFun then
		local NowSelectKey = MenuGetSelectKeyFun()
		IsSelected = Data.Key == NowSelectKey
	end

	self:UpdateTextColorBySelect(IsSelected)
	self:UpdateArrowShow()
end

--- 更新选中非选中字色
function House2TabItemUBPView:UpdateTextColorBySelect(IsSelected)
    local LinearColor
    if IsSelected then
        LinearColor = _G.UE.FLinearColor.FromHex("5A4224")
    else
        LinearColor = _G.UE.FLinearColor.FromHex("878075")
    end

    if LinearColor then
        self.TextTab:SetColorAndOpacity(LinearColor)
    end
end

function House2TabItemUBPView:OnExpandedChanged(IsExpanded, OldValue)
	if not self.Params then return end
    self.IsExpanded = false
	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.IsAutoExpand and IsExpanded then
        self.IsExpanded = true
	end

    self:UpdateArrowShow()
end

return House2TabItemUBPView