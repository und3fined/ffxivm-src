---
--- Author: Administrator
--- DateTime: 2024-07-08 15:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class TouringBandMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgAvatar UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandMemberItemView = LuaClass(UIView, true)

function TouringBandMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgAvatar = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandMemberItemView:OnInit()

end

function TouringBandMemberItemView:OnDestroy()

end

function TouringBandMemberItemView:OnShow()

end

function TouringBandMemberItemView:OnHide()

end

function TouringBandMemberItemView:OnRegisterUIEvent()

end

function TouringBandMemberItemView:OnRegisterGameEvent()

end

function TouringBandMemberItemView:OnRegisterBinder()
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
        { "HeadIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgAvatar) },
        { "TextName", UIBinderSetText.New(self, self.TextName)},
    }
    self:RegisterBinders(ViewModel, Binders)
end

return TouringBandMemberItemView