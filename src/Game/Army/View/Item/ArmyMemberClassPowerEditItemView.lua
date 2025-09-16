---
--- Author: daniel
--- DateTime: 2023-03-14 17:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class ArmyMemberClassPowerEditItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field ImgClassIcon UFImage
---@field ImgClassNum UFTextBlock
---@field PanelAdd UFCanvasPanel
---@field TextAdd UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassPowerEditItemView = LuaClass(UIView, true)

function ArmyMemberClassPowerEditItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.ImgClassIcon = nil
	--self.ImgClassNum = nil
	--self.PanelAdd = nil
	--self.TextAdd = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassPowerEditItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassPowerEditItemView:OnInit()
    self.Binders = {
        {"TextStr", UIBinderSetText.New(self, self.ImgClassNum)},
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgClassIcon)},
        {"IsChecked", UIBinderSetIsChecked.New(self, self.ToggleBtn)},
        {"IsAddItem", UIBinderSetIsVisible.New(self, self.ToggleBtn, true)},
        {"IsAddItem", UIBinderSetIsVisible.New(self, self.PanelAdd)},
		{"bSelected", UIBinderValueChangedCallback.New(self, nil, self.OnSelectChanged)},
        {"IsNoName", UIBinderValueChangedCallback.New(self, nil, self.OnIsNoNameChanged)},
    }
end

function ArmyMemberClassPowerEditItemView:OnDestroy()
end

function ArmyMemberClassPowerEditItemView:OnShow()
    -- LSTR string:新增分组
    self.TextAdd:SetText(LSTR(910148))
end

function ArmyMemberClassPowerEditItemView:OnHide()
end

function ArmyMemberClassPowerEditItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function ArmyMemberClassPowerEditItemView:OnRegisterGameEvent()
end

function ArmyMemberClassPowerEditItemView:OnRegisterBinder()
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

function ArmyMemberClassPowerEditItemView:OnClickedItem()
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

---@field IsSelected boolean
function ArmyMemberClassPowerEditItemView:OnSelectChanged(IsSelected)
	self.ToggleBtn:SetChecked(IsSelected, false)
end

-- ---@field IsSelected boolean
-- function ArmyMemberClassPowerEditItemView:OnSelectChanged(IsSelected)
--     self.ToggleBtn:SetChecked(IsSelected, false)
-- end

function ArmyMemberClassPowerEditItemView:OnIsNoNameChanged(IsNoName)
    local RedColor = "dc5868ff"
    local NormalColor = "AAAAAAFF"
    if IsNoName then
        UIUtil.SetColorAndOpacityHex(self.ImgClassNum, RedColor)
    else
        UIUtil.SetColorAndOpacityHex(self.ImgClassNum, NormalColor)
    end
end

return ArmyMemberClassPowerEditItemView
