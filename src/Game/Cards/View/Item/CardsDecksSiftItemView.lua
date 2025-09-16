---
--- Author: Administrator
--- DateTime: 2023-10-26 10:32
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")

---@class CardsDecksSiftItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsDecksSiftItemView = LuaClass(UIView, true)

function CardsDecksSiftItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClick = nil
    -- self.ImgIcon = nil
    -- self.ImgSelect = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsDecksSiftItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsDecksSiftItemView:OnInit()
    local Binders = {{"ImgAssetPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
                     {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)}}
    self.Binders = Binders
end

function CardsDecksSiftItemView:OnDestroy()

end

function CardsDecksSiftItemView:OnShow()

end

function CardsDecksSiftItemView:OnHide()

end

function CardsDecksSiftItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClick)
end

function CardsDecksSiftItemView:OnBtnClick()
    self.ViewModel:OnClicked()
end

function CardsDecksSiftItemView:OnRegisterGameEvent()

end

function CardsDecksSiftItemView:OnRegisterBinder()
    self.ViewModel = self.Params.Data -- ViewModel 是 MagicCardEditGroupFilterBtnVM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsDecksSiftItemView
