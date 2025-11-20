---
--- Author: richyczhou
--- DateTime: 2025-09-05 18:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local GMCharacterEditorMgr = require("Game/GM/CharacterEditor/GMCharacterEditorMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CharacterOptionView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UButton
---@field Icon UFImage
---@field IndexText UTextBlock
---@field SelectBg UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CharacterOptionView = LuaClass(UIView, true)

function CharacterOptionView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Icon = nil
	--self.IndexText = nil
	--self.SelectBg = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CharacterOptionView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CharacterOptionView:OnInit()
    self.Binders = {
        { "IsSelected", UIBinderSetIsVisible.New(self, self.SelectBg)},
        { "Text", UIBinderSetText.New(self, self.IndexText)},
    }
end

function CharacterOptionView:OnDestroy()

end

function CharacterOptionView:OnShow()

end

function CharacterOptionView:OnHide()

end

function CharacterOptionView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Button, self.OnButtonClicked)
end

function CharacterOptionView:OnRegisterGameEvent()

end

function CharacterOptionView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function CharacterOptionView:OnButtonClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    --local Adapter = Params.Adapter
    --if nil == Adapter then
    --    return
    --end
    ---- UIAdapterTableView:OnTableItemClicked
    --Adapter:OnItemClicked(self, Params.Index)

    self:DoSelectChanged(not self.IsSelected)
end

function CharacterOptionView:DoSelectChanged(IsSelected)
    local ViewModel = self.Params.Data
    if ViewModel and ViewModel.OnSelectedChange then
        self.IsSelected = IsSelected
        if IsSelected then
            GMCharacterEditorMgr.FaceOptionValue = GMCharacterEditorMgr.FaceOptionValue + ViewModel.Value
        else
            GMCharacterEditorMgr.FaceOptionValue = GMCharacterEditorMgr.FaceOptionValue - ViewModel.Value
        end
        _G.FLOG_INFO("[CharacterOptionView:OnSelectChanged] [%s] IsSelected: %s, FaceOptionValue:%d", ViewModel.Text, tostring(IsSelected), GMCharacterEditorMgr.FaceOptionValue)

        ViewModel:OnSelectedChange(IsSelected)
        GMCharacterEditorMgr:OnFaceChanged(ProtoCommon.avatar_personal.AvatarOption, GMCharacterEditorMgr.FaceOptionValue)
    end
end

return CharacterOptionView