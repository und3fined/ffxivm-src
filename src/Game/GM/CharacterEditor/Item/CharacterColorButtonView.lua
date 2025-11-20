---
--- Author: richyczhou
--- DateTime: 2025-08-22 16:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GMCharacterEditorMgr = require("Game/GM/CharacterEditor/GMCharacterEditorMgr")
local ProtoCommon = require("Protocol/ProtoCommon")

local FLinearColor = _G.UE.FLinearColor
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

---@class CharacterColorButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnColor UFButton
---@field ImgColor UFImage
---@field ImgSelectEffect UFImage
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CharacterColorButtonView = LuaClass(UIView, true)

function CharacterColorButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnColor = nil
	--self.ImgColor = nil
	--self.ImgSelectEffect = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CharacterColorButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CharacterColorButtonView:OnInit()

end

function CharacterColorButtonView:OnDestroy()

end

function CharacterColorButtonView:OnShow()
    UIUtil.SetIsVisible(self.ImgSelectEffect, true)
end

function CharacterColorButtonView:OnHide()

end

function CharacterColorButtonView:OnRegisterUIEvent()

end

function CharacterColorButtonView:OnRegisterGameEvent()

end

function CharacterColorButtonView:OnRegisterBinder()

end

function CharacterColorButtonView:OnColorChanged(NewValue, ColorType)
    if NewValue == nil then
        FLOG_WARNING("[CharacterColorButtonView:OnColorChanged] NewValue error")
        local ColorList = GMCharacterEditorMgr:GetColorListByType(ColorType)
        if ColorList then
            NewValue = ColorList[1]
        end
    end

    if NewValue == nil then
        FLOG_WARNING("[CharacterColorButtonView:OnColorChanged] NewValue error")
        return
    end

    local ColorValue = NewValue.Color
    if ColorValue == nil then
        FLOG_WARNING("[CharacterColorButtonView:OnColorChanged] ColorValue error")
        return
    end

    FLOG_INFO("[CharacterColorButtonView:OnColorChanged] ColorType:%d, Num:%d", ColorType, NewValue.DataValue)
    --UIUtil.ImageSetColorAndOpacity(self.ImgColor, FLinearColor(ColorValue.R/255, ColorValue.G/255, ColorValue.B/255, ColorValue.A/255))
    self.ImgColor:SetColorAndOpacity(FLinearColor(ColorValue.R/255, ColorValue.G/255, ColorValue.B/255, ColorValue.A/255))
    self.TextNum:SetText(tostring(NewValue.DataValue))
end

return CharacterColorButtonView