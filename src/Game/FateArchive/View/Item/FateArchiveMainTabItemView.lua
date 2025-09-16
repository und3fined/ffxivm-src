---
--- Author: Administrator
--- DateTime: 2024-08-28 10:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")

---@class FateArchiveMainTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveMainTabItemView = LuaClass(UIView, true)

function FateArchiveMainTabItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgNormal = nil
    --self.ImgSelect = nil
    --self.TextNumber = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveMainTabItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveMainTabItemView:OnInit()
    self.Binders = {
        {"IconNormal", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormal)},
        {"IconSelect", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelect)},
        {"TextPercentVisible", UIBinderSetIsVisible.New(self, self.TextNumber)},
        {"Percent", UIBinderSetText.New(self, self.TextNumber)}
    }
end

function FateArchiveMainTabItemView:OnDestroy()
end

function FateArchiveMainTabItemView:OnShow()
end

function FateArchiveMainTabItemView:OnHide()
end

function FateArchiveMainTabItemView:OnRegisterUIEvent()
end

function FateArchiveMainTabItemView:OnRegisterGameEvent()
end

function FateArchiveMainTabItemView:OnRegisterBinder()
    self.ViewModel = self.Params.Data
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function FateArchiveMainTabItemView:OnSelectChanged(IsSelected)
    if (IsSelected) then
        UIUtil.SetIsVisible(self.ImgSelect, true)
        UIUtil.SetIsVisible(self.ImgNormal, false)
        self:StopAnimation(self.AnimNormal)
        self:PlayAnimation(self.AnimSelect)
    else
        UIUtil.SetIsVisible(self.ImgSelect, false)
        UIUtil.SetIsVisible(self.ImgNormal, true)
        self:StopAnimation(self.AnimSelect)
        self:PlayAnimation(self.AnimNormal)
    end
end

return FateArchiveMainTabItemView
