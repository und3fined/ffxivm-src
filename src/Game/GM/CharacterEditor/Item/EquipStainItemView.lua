---
--- Author: richyczhou
--- DateTime: 2025-09-08 20:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GMCharacterEditorMgr = require("Game/GM/CharacterEditor/GMCharacterEditorMgr")

local FLOG_INFO = _G.FLOG_INFO

---@class EquipStainItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnColor UFButton
---@field ImgColor UFImage
---@field ImgColor_1 UFImage
---@field SectionText UTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipStainItemView = LuaClass(UIView, true)

function EquipStainItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnColor = nil
	--self.ImgColor = nil
	--self.ImgColor_1 = nil
	--self.SectionText = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipStainItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipStainItemView:OnInit()
    self.GMCharacterEditorVM = GMCharacterEditorMgr:GetCharacterEditorVM()

    self.Binders = {
        { "SectionText", UIBinderSetText.New(self, self.SectionText) },
        { "ColorID", UIBinderSetText.New(self, self.TextNum) },
        --{ "StainColor", UIBinderSetColorAndOpacity.New(self, self.ImgColor) },
        { "HexColor", UIBinderSetBrushTintColorHex.New(self, self.ImgColor) },
    }
end

function EquipStainItemView:OnDestroy()

end

function EquipStainItemView:OnShow()
    --FLOG_INFO("[EquipStainItemView:OnShow]")
end

function EquipStainItemView:OnHide()

end

function EquipStainItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnColor, self.OnColorButtonClicked)
end

function EquipStainItemView:OnRegisterGameEvent()

end

function EquipStainItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    ---@type EquipStainItemVM
    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    --print("[EquipStainItemView:OnRegisterBinder] VM:" .. ViewModel:GetName())
    self:RegisterBinders(ViewModel, self.Binders)
end

function EquipStainItemView:OnColorButtonClicked()
    if self.GMCharacterEditorVM.IsShowStainColorPanel then
        self.GMCharacterEditorVM.IsShowStainColorPanel = false
        return
    end

    print("[EquipColorItemView:OnColorButtonClicked]")
    self.GMCharacterEditorVM.IsShowStainColorPanel = true

    local Params = self.Params
    if nil == Params then
        return
    end

    ---@type EquipStainItemVM
    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    GMCharacterEditorMgr.CurStainSectionID = ViewModel.SectionID
end


return EquipStainItemView