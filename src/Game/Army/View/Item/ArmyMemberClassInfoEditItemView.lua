---
--- Author: qibaoyiyi
--- DateTime: 2023-03-14 17:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class ArmyMemberClassInfoEditItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SingleBoxEdit CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassInfoEditItemView = LuaClass(UIView, true)

function ArmyMemberClassInfoEditItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SingleBoxEdit = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassInfoEditItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBoxEdit)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassInfoEditItemView:OnInit()
    self.Binders = {
        {"Desc", UIBinderValueChangedCallback.New(self,  nil, self.OnTextChanged)},
		{"bChecked", UIBinderValueChangedCallback.New(self, nil, self.OnCheckChanged)},
		{"bCanEdit", UIBinderValueChangedCallback.New(self, nil, self.OnCanEditChanged)},
    }
end

function ArmyMemberClassInfoEditItemView:OnDestroy()
end

function ArmyMemberClassInfoEditItemView:OnShow()
    -- local Params = self.Params
    -- if nil == Params then
    --     return
    -- end
    -- local Data = Params.Data
    -- if Data == nil then
    --     return
    -- end
    -- local PmsText = Data.PermssionData.Desc
    -- local Punctuation
    -- if Data.PermssionData.Important == ArmyDefine.One then
    --     Punctuation = "*"
    -- else
    --     Punctuation = ""
    -- end
    -- self.SingleBoxEdit:SetText(string.format("%s%s", Punctuation, PmsText))
    -- self.SingleBoxEdit:SetChecked(Data.bChecked, false)
    -- self.SingleBoxEdit:SetIsEnabled(Data.bCanEdit)
end

function ArmyMemberClassInfoEditItemView:OnHide()
end

function ArmyMemberClassInfoEditItemView:OnTextChanged(Desc)
    self.SingleBoxEdit:SetText(Desc)
end

function ArmyMemberClassInfoEditItemView:OnCheckChanged(bChecked)
    self.SingleBoxEdit:SetChecked(bChecked, false)
end

function ArmyMemberClassInfoEditItemView:OnCanEditChanged(bCanEdit)
    self.SingleBoxEdit:SetIsEnabled(bCanEdit)

end

function ArmyMemberClassInfoEditItemView:OnRegisterUIEvent()
    UIUtil.AddOnStateChangedEvent(self, self.SingleBoxEdit, self.OnCheckStateChanged)
end

function ArmyMemberClassInfoEditItemView:OnRegisterGameEvent()
end

function ArmyMemberClassInfoEditItemView:OnRegisterBinder()
    local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyMemberClassInfoEditItemView:OnCheckStateChanged(IsChecked)
    local Params = self.Params
    if nil == Params then
        return
    end
    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end
    Adapter:OnItemClicked(self, Params.Index)
end

return ArmyMemberClassInfoEditItemView
