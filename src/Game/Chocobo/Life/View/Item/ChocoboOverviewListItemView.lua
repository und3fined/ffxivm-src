---
--- Author: Administrator
--- DateTime: 2023-12-14 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")

---@class ChocoboOverviewListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FeatherStage ChocoboFeatherStageItemView
---@field ImgCheck UFImage
---@field ImgCollect UFImage
---@field ImgColor UFImage
---@field ImgFlag UFImage
---@field ImgGandar UFImage
---@field ImgIcon UFImage
---@field ImgRend UFImage
---@field ImgSelect UFImage
---@field PanelAvatar01 UFCanvasPanel
---@field PanelLevel02 UFCanvasPanel
---@field PanelStage UFCanvasPanel
---@field PanelStar UFCanvasPanel
---@field RedDot CommonRedDot2View
---@field Star UFTextBlock
---@field StarPanelItem ChocoboStarPanelItemView
---@field TextLevel UFTextBlock
---@field TextLevel02 UFTextBlock
---@field TextName UFTextBlock
---@field TextStage UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboOverviewListItemView = LuaClass(UIView, true)

function ChocoboOverviewListItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FeatherStage = nil
	--self.ImgCheck = nil
	--self.ImgCollect = nil
	--self.ImgColor = nil
	--self.ImgFlag = nil
	--self.ImgGandar = nil
	--self.ImgIcon = nil
	--self.ImgRend = nil
	--self.ImgSelect = nil
	--self.PanelAvatar01 = nil
	--self.PanelLevel02 = nil
	--self.PanelStage = nil
	--self.PanelStar = nil
	--self.RedDot = nil
	--self.Star = nil
	--self.StarPanelItem = nil
	--self.TextLevel = nil
	--self.TextLevel02 = nil
	--self.TextName = nil
	--self.TextStage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewListItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FeatherStage)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.StarPanelItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboOverviewListItemView:OnInit()
    self.BlueStarAdapter = UIAdapterTableView.CreateAdapter(self, self.StarPanelItem.TableViewBlue, nil, nil)
    self.RedStarAdapter = UIAdapterTableView.CreateAdapter(self, self.StarPanelItem.TableViewRed, nil, nil)
end

function ChocoboOverviewListItemView:OnDestroy()

end

function ChocoboOverviewListItemView:OnShow()
    UIUtil.SetIsVisible(self.RedDot, true)
    UIUtil.SetIsVisible(self.ImgCheck, false)
    self.RedDot:SetIsCustomizeRedDot(true)
    self:UpdateRedDot()
end

function ChocoboOverviewListItemView:OnHide()

end

function ChocoboOverviewListItemView:OnRegisterUIEvent()

end

function ChocoboOverviewListItemView:OnRegisterGameEvent()

end

function ChocoboOverviewListItemView:OnRegisterBinder()
    local Params = self.Params
    if Params ==  nil then return end 

    local ViewModel = Params.Data
    if ViewModel == nil then return end

    self.VM = ViewModel

    local Binders = {
        --{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgCheck) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
        { "IsLike", UIBinderSetIsVisible.New(self, self.ImgCollect) },
        { "IsRacer", UIBinderSetIsVisible.New(self, self.ImgFlag) },
        { "IsRent", UIBinderSetIsVisible.New(self, self.ImgRend) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
        { "GenderPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgGandar) },
        { "FilterAttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        { "GenerationText", UIBinderSetText.New(self, self.TextLevel) },
        { "LevelText", UIBinderSetText.New(self, self.TextLevel02) },
        { "StarCountText", UIBinderSetText.New(self, self.Star) },
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "FeatherValue", UIBinderSetText.New(self, self.TextStage) },
        { "FeatherRankText", UIBinderSetText.New(self, self.FeatherStage.TextNumber) },
        { "FeatherIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FeatherStage.ImgBG) },
        { "FilterBlueStarVMList", UIBinderUpdateBindableList.New(self, self.BlueStarAdapter) },
        { "FilterRedStarVMList", UIBinderUpdateBindableList.New(self, self.RedStarAdapter) },
    }
    self:RegisterBinders(ViewModel, Binders)
    
    local MainVMBinders = {
        { "FilterType", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurFilterType) },
    }
    self:RegisterBinders(_G.ChocoboMainVM, MainVMBinders)
end

function ChocoboOverviewListItemView:OnValueChangedCurFilterType(Value)
     UIUtil.SetIsVisible(self.StarPanelItem.ImgBG, false)
    if Value == ChocoboDefine.OVERVIEW_FILTER_TYPE.STAR then
        UIUtil.SetIsVisible(self.Star, true)
        UIUtil.SetIsVisible(self.PanelLevel02, false)
        UIUtil.SetIsVisible(self.PanelStage, false)
        UIUtil.SetIsVisible(self.PanelStar, false)
    elseif Value == ChocoboDefine.OVERVIEW_FILTER_TYPE.LEVEL then
        UIUtil.SetIsVisible(self.Star, false)
        if not self.VM.IsRent then
            UIUtil.SetIsVisible(self.PanelLevel02, true)
        else
            UIUtil.SetIsVisible(self.PanelLevel02, false)
        end
        UIUtil.SetIsVisible(self.PanelStage, false)
        UIUtil.SetIsVisible(self.PanelStar, false)
    elseif Value == ChocoboDefine.OVERVIEW_FILTER_TYPE.FEATHER_VALUE then
        UIUtil.SetIsVisible(self.Star, false)
        UIUtil.SetIsVisible(self.PanelLevel02, false)
        if not self.VM.IsRent then  
            UIUtil.SetIsVisible(self.PanelStage, true)
        else 
            UIUtil.SetIsVisible(self.PanelStage, false)
        end
        UIUtil.SetIsVisible(self.PanelStar, false)
    else
        UIUtil.SetIsVisible(self.Star, false)
        UIUtil.SetIsVisible(self.PanelLevel02, false)
        UIUtil.SetIsVisible(self.PanelStage, false)
        UIUtil.SetIsVisible(self.PanelStar, true)
        self.VM:SetOverviewFilterType(Value)
    end
end

function ChocoboOverviewListItemView:OnSelectChanged(Value)
    if self.VM ~= nil then
        self.VM:SetSelect(Value)
        if Value then
            self:DelRedDot()
        end
    end
end

function ChocoboOverviewListItemView:UpdateRedDot()
    if self.VM == nil or self.VM.ChocoboID == nil then
        return
    end
    
    local IsShow = true
    local RedDotList = _G.ChocoboMgr:GetCustomizeRedDotList()
    local RedDotName = "OverviewList" .. self.VM.ChocoboID

    for __, ItemName in pairs(RedDotList) do
        if RedDotName == ItemName then
            IsShow = false
        end
    end

    if self.RedDot and self.RedDot.ItemVM then
        self.RedDot.ItemVM.IsVisible = IsShow
    end
    
    if self.VM.IsSelect then
        self:DelRedDot()
    end
    _G.ChocoboMgr:AddCustomizeRedDotName(RedDotName)
end

function ChocoboOverviewListItemView:DelRedDot()
    if self.VM == nil or self.VM.ChocoboID == nil then
        return
    end
    
    if self.RedDot and self.RedDot.ItemVM then
        self.RedDot.ItemVM.IsVisible = false
    end
end

return ChocoboOverviewListItemView