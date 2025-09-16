---
--- Author: henghaoli
--- DateTime: 2024-08-19 15:16
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class SkillExclusivePropBtnView : MainSkillBaseView
---@field Super MainSkillBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Charge_CD URadialImage
---@field EFF_ADD_Inst_25 UFImage
---@field EFF_Circle_012 UFImage
---@field FCanvasPanel_59 UFCanvasPanel
---@field FImg_CDNormal UFImage
---@field Icon_Skill UFImage
---@field ImgChargeBase UFImage
---@field ImgLockLevel UFTextBlock
---@field Img_CD URadialImage
---@field SecondJoyStick SecondJoyStickView
---@field Text_SkillCD UFTextBlock
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillExclusivePropBtnView = LuaClass(MainSkillBaseView, true)

function SkillExclusivePropBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Charge_CD = nil
	--self.EFF_ADD_Inst_25 = nil
	--self.EFF_Circle_012 = nil
	--self.FCanvasPanel_59 = nil
	--self.FImg_CDNormal = nil
	--self.Icon_Skill = nil
	--self.ImgChargeBase = nil
	--self.ImgLockLevel = nil
	--self.Img_CD = nil
	--self.SecondJoyStick = nil
	--self.Text_SkillCD = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillExclusivePropBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SecondJoyStick)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillExclusivePropBtnView:OnInit()
	self.Super:OnInit()
end

function SkillExclusivePropBtnView:OnDestroy()

end

function SkillExclusivePropBtnView:OnShow()
	self:Refresh()
end

function SkillExclusivePropBtnView:OnHide()
	self.Super:OnHide()
end

function SkillExclusivePropBtnView:OnRegisterUIEvent()

end

function SkillExclusivePropBtnView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function SkillExclusivePropBtnView:OnRegisterBinder()
	local Binders = {
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill)},
		{"bCommonMask", UIBinderSetIsVisible.New(self, self.FImg_CDNormal)},
		{"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
		{"bNormalCD", UIBinderSetIsVisible.New(self, self.Img_CD)},
		{"SkillCDText", UIBinderSetText.New(self, self.Text_SkillCD)},
	}

	self:RegisterBinders(self.BaseBtnVM, Binders)
end

function SkillExclusivePropBtnView:Refresh()
	local Params = self.Params
	if not Params then
		return
	end

	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		return
	end
	local Index = self.ButtonIndex
	local SkillID = Params.SkillList[1]
	LogicData:InitSkillMap(Index, SkillID)
	self.LogicData = LogicData

	self.Super:OnSkillReplace({SkillIndex = Index, SkillID = SkillID})
end

function SkillExclusivePropBtnView:bSupportSecondJoyStick()
	return true
end

-- Drag相关逻辑复用Able按钮
local SkillAbleBtnView = require("Game/MainSkillBtn/SkillAbleBtnView")

SkillExclusivePropBtnView.DoDragSkillStart = SkillAbleBtnView.DoDragSkillStart
SkillExclusivePropBtnView.DoDragSkillMove = SkillAbleBtnView.DoDragSkillMove
SkillExclusivePropBtnView.DoDragSkillEnd = SkillAbleBtnView.DoDragSkillEnd

return SkillExclusivePropBtnView