--- loiafeng: 废弃蓝图 见MainBuffInfoTipsNewView
--- Author: v_hggzhang
--- DateTime: 2022-05-11 10:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderAdapterBuffLeftTimeColor = require("Game/Buff/UIBinderAdapterBuffLeftTimeColor")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")
local UIBinderSetDesaturation = require("Binder/UIBinderSetDesaturation")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local BuffUIUtil =  require("Game/Buff/BuffUIUtil")

---@class MainBuffInfoTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextLeftTime URichTextBox
---@field IconBuff UFImage
---@field FTextBuffName UFText
---@field FTextBuffDesc UFText

---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainBuffInfoTipsView = LuaClass(UIView, true)

function MainBuffInfoTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.RichTextLeftTime = nil
    --self.IconBuff = nil
    --self.FTextBuffName = nil
    --self.FTextBuffDesc = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainBuffInfoTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainBuffInfoTipsView:OnInit()
    self.BuffBinders = {
        {"BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.IconBuff)},
        {"IsEffective", UIBinderSetDesaturation.New(self, self.IconBuff, true)},
        {"LeftTime", UIBinderValueChangedCallback.New(self, nil, self.OnLeftTimeChanged)},
        {"IsFromMajor", UIBinderAdapterBuffLeftTimeColor.New(UIBinderSetColorAndOpacityHex.New(self, self.RichTextLeftTime))},
        {"Name", UIBinderSetText.New(self, self.FTextBuffName)},
        {"Desc", UIBinderSetText.New(self, self.FTextBuffDesc)},
    }
end

function MainBuffInfoTipsView:OnDestroy()
end

function MainBuffInfoTipsView:OnShow()
end

function MainBuffInfoTipsView:OnHide()
    self:ChangeVMAndUpdate(nil)
end

function MainBuffInfoTipsView:OnRegisterUIEvent()
end

function MainBuffInfoTipsView:OnRegisterGameEvent()
end

function MainBuffInfoTipsView:OnRegisterBinder()
end

function MainBuffInfoTipsView:ChangeVMAndUpdate(VM)
    if self.VM then
        self:UnRegisterBinders(self.VM, self.BuffBinders)
    end

    if VM ~= nil then
        self.VM = VM
        self:RegisterBinders(self.VM, self.BuffBinders)
    end
end

function MainBuffInfoTipsView:OnLeftTimeChanged(NewValue)
    if self.VM == nil then
        return
    end

    --详情界面还需要根据初始的可见性判断是否显示
    if self.VM.IsBuffTimeDisplayOrigin and NewValue > 0 then
        UIUtil.SetIsVisible(self.RichTextLeftTime, true)

        if self.VM:IsCountBuff() then
            self.RichTextLeftTime:SetText(string.format(_G.LSTR(500003), NewValue))  -- %d 次
        else
            self.RichTextLeftTime:SetText(BuffUIUtil.GetBuffSmartLeftTime(NewValue))
        end
    else
        UIUtil.SetIsVisible(self.RichTextLeftTime,false)
    end
end

local Handled = _G.UE.UWidgetBlueprintLibrary.Handled()

function MainBuffInfoTipsView:OnMouseButtonDown(_, _)
	return Handled
end

return MainBuffInfoTipsView
