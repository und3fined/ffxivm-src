---
--- Author: Administrator
--- DateTime: 2023-11-01 15:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")
local ChocoboRaceMainVM = nil

---@class ChocoboRaceResultItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrow UFImage
---@field ImgBG UFImage
---@field ImgIcon UFImage
---@field TextName UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceResultItemView = LuaClass(UIView, true)

function ChocoboRaceResultItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrow = nil
	--self.ImgBG = nil
	--self.ImgIcon = nil
	--self.TextName = nil
	--self.TextNumber = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceResultItemView:OnInit()
    ChocoboRaceMainVM = _G.ChocoboRaceMainVM

    self.RaceResultRankListIconPath = {
        [1] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.RESULT_RANK_LIST_ICON_1),
        [2] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.RESULT_RANK_LIST_ICON_2),
        [3] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.RESULT_RANK_LIST_ICON_3),
    }
end

function ChocoboRaceResultItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceResultItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.VM = ViewModel
    
     self.ChocoboBinders = {
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "IsMajor", UIBinderSetIsVisible.New(self, self.ImgArrow) },
        { "IsOver", UIBinderSetIsVisible.New(self, self.TextTime) },
        { "ArrivedTimeText", UIBinderSetText.New(self, self.TextTime) },
        { "ResultRankBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },
    }
    
    local PanelBinders =
    {
        { "Rank", UIBinderValueChangedCallback.New(self, nil, self.OnRankChange) },
        { "Index", UIBinderValueChangedCallback.New(self, nil, self.IndexChange) },
    }
    self:RegisterBinders(ViewModel, PanelBinders)
end

function ChocoboRaceResultItemView:IndexChange(NewValue, OldValue)
    if nil ~= OldValue then
        local ViewModel = ChocoboRaceMainVM:FindChocoboRaceVM(OldValue)
        if nil ~= ViewModel then
            self:UnRegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end

    if nil ~= NewValue then
        local ViewModel = ChocoboRaceMainVM:FindChocoboRaceVM(NewValue)
        if nil ~= ViewModel then
            self.ViewModel = ViewModel
            self:RegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end
end

function ChocoboRaceResultItemView:OnRankChange(NewValue, OldValue)
    self.TextNumber:SetText(tostring(NewValue))
    local IconPath = self.RaceResultRankListIconPath[NewValue]
    if IconPath == nil then
        UIUtil.SetIsVisible(self.ImgIcon, false)
        UIUtil.SetIsVisible(self.TextNumber, true)
    else
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.TextNumber, false)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
    end
end

return ChocoboRaceResultItemView