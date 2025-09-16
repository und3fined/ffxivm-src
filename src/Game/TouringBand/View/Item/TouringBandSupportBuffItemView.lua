---
--- Author: Administrator
--- DateTime: 2025-02-12 16:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class TouringBandSupportBuffItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconBuff UFImage
---@field TextBuffName UFTextBlock
---@field TextDescribe UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandSupportBuffItemView = LuaClass(UIView, true)

function TouringBandSupportBuffItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.IconBuff = nil
    --self.TextBuffName = nil
    --self.TextDescribe = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandSupportBuffItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandSupportBuffItemView:OnInit()

end

function TouringBandSupportBuffItemView:OnDestroy()

end

function TouringBandSupportBuffItemView:OnShow()

end

function TouringBandSupportBuffItemView:OnHide()

end

function TouringBandSupportBuffItemView:OnRegisterUIEvent()

end

function TouringBandSupportBuffItemView:OnRegisterGameEvent()

end

function TouringBandSupportBuffItemView:OnRegisterBinder()
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

    local Binders = {
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.IconBuff) },
        { "Name", UIBinderSetText.New(self, self.TextBuffName) },
        { "Content", UIBinderSetText.New(self, self.TextDescribe) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

return TouringBandSupportBuffItemView