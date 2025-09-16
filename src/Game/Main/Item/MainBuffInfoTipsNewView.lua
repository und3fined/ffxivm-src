---
--- Author: chunfengluo
--- DateTime: 2024-09-27 20:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderAdapterBuffLeftTimeColor = require("Game/Buff/UIBinderAdapterBuffLeftTimeColor")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBuffPile = require("Binder/UIBinderSetBuffPile")
local BuffUIUtil =  require("Game/Buff/BuffUIUtil")
local BuffDefine = require("Game/Buff/BuffDefine")

---@class MainBuffInfoTipsNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBuffDesc URichTextBox
---@field FTextBuffName URichTextBox
---@field FTextPile UFTextBlock
---@field IconBuff UFImage
---@field IconStop UFImage
---@field RichTextLeftTime URichTextBox
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainBuffInfoTipsNewView = LuaClass(UIView, true)

function MainBuffInfoTipsNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBuffDesc = nil
	--self.FTextBuffName = nil
	--self.FTextPile = nil
	--self.IconBuff = nil
	--self.IconStop = nil
	--self.RichTextLeftTime = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainBuffInfoTipsNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainBuffInfoTipsNewView:OnInit()
    self.BuffBinders = {
        {"BuffIcon", UIBinderSetBrushFromMaterial.New(self, self.IconBuff)},
        {"IsEffective", UIBinderValueChangedCallback.New(self, nil, self.OnIsEffectiveChanged)},
        {"LeftTime", UIBinderValueChangedCallback.New(self, nil, self.OnLeftTimeChanged)},
        {"IsFromMajor", UIBinderAdapterBuffLeftTimeColor.New(UIBinderSetColorAndOpacityHex.New(self, self.RichTextLeftTime))},
        {"Name", UIBinderValueChangedCallback.New(self, self.FTextBuffName, self.UpdateName)},
        {"Desc", UIBinderValueChangedCallback.New(self, self.FTextBuffDesc, self.UpdateDesc)},
        {"Pile", UIBinderSetBuffPile.New(self, self.FTextPile)},
    }
end

function MainBuffInfoTipsNewView:OnDestroy()

end

function MainBuffInfoTipsNewView:OnShow()

end

function MainBuffInfoTipsNewView:OnHide()
    self:ChangeVMAndUpdate(nil)
end

function MainBuffInfoTipsNewView:OnRegisterUIEvent()

end

function MainBuffInfoTipsNewView:OnRegisterGameEvent()

end

function MainBuffInfoTipsNewView:OnRegisterBinder()
	-- if nil ~= self.VM then
	-- 	self:RegisterBinders(self.VM, self.BuffBinders)
	-- end
end

function MainBuffInfoTipsNewView:ChangeVMAndUpdate(VM)
    if self.VM then
        self:UnRegisterBinders(self.VM, self.BuffBinders)
    end

	self.VM = VM

    if VM ~= nil and self:GetIsShowView() then
        self:RegisterBinders(self.VM, self.BuffBinders)
    end
end

function MainBuffInfoTipsNewView:OnLeftTimeChanged(NewValue)
    if self.VM == nil or NewValue == nil then
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

function MainBuffInfoTipsNewView:OnMouseButtonDown(_, _)
	return Handled
end

function MainBuffInfoTipsNewView:UpdateName()
	if self.VM == nil then
		FLOG_ERROR("MainBuffInfoTipsNewView.UpdateName: self.VM is nil")
		return
	end

	local Text = self.VM.Name
	if not self.VM.IsEffective then
		Text = string.format("%s<span color=\"#d15e6cff\">%s</>", self.VM.Name, _G.LSTR(500004))  -- （失效）
	end

	self.FTextBuffName:SetText(Text)
end

function MainBuffInfoTipsNewView:UpdateDesc()
	if self.VM == nil then
		FLOG_ERROR("MainBuffInfoTipsNewView.UpdateDesc: self.VM is nil")
		return
	end

	local Text = self.VM.Desc
	if not self.VM.IsEffective and self.VM.BuffSkillType == BuffDefine.BuffSkillType.BonusState then
		Text = string.format("<span color=\"#d15e6cff\">%s</>\n%s", _G.LSTR(500005), self.VM.Desc)  -- （已有同类高级效果）
	end

	self.FTextBuffDesc:SetText(Text)
end

function MainBuffInfoTipsNewView:OnIsEffectiveChanged(NewValue, OldValue)
	if self.VM == nil then
		FLOG_ERROR("MainBuffInfoTipsNewView.OnIsEffectiveChanged: self.VM is nil")
		return
	end

	self:UpdateName()
	self:UpdateDesc()

	local BuffType = self.VM.BuffSkillType
	UIUtil.SetImageDesaturate(self.IconBuff, nil, (BuffType == BuffDefine.BuffSkillType.Combat and not NewValue) and 1 or 0)  -- 0-正常，1-灰化
	UIUtil.SetIsVisible(self.IconStop, BuffType == BuffDefine.BuffSkillType.BonusState and not NewValue)
end

return MainBuffInfoTipsNewView