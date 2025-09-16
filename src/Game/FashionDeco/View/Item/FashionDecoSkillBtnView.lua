---
--- Author: ccppeng
--- DateTime: 2024-11-25 18:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FashionDecoSkillBtnVM = require("Game/FashionDeco/VM/FashionDecoSkillBtnVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local WBL = _G.UE.UWidgetBlueprintLibrary
---@class FashionDecoSkillBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_ADD_Inst_25 UFImage
---@field EFF_Circle_012 UFImage
---@field FCanvasPanel_59 UFCanvasPanel
---@field FImg_CDNormal UFImage
---@field Icon_Skill UFImage
---@field Img_CD URadialImage
---@field Text_SkillCD UFTextBlock
---@field AnimCDFinish UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoSkillBtnView = LuaClass(UIView, true)

function FashionDecoSkillBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_ADD_Inst_25 = nil
	--self.EFF_Circle_012 = nil
	--self.FCanvasPanel_59 = nil
	--self.FImg_CDNormal = nil
	--self.Icon_Skill = nil
	--self.Img_CD = nil
	--self.Text_SkillCD = nil
	--self.AnimCDFinish = nil
	--self.AnimClick = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoSkillBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoSkillBtnView:OnInit()
	self.ViewModel = FashionDecoSkillBtnVM.New()
end

function FashionDecoSkillBtnView:OnDestroy()

end

function FashionDecoSkillBtnView:OnShow()

end

function FashionDecoSkillBtnView:OnHide()

end

function FashionDecoSkillBtnView:OnRegisterUIEvent()
	
end
function FashionDecoSkillBtnView:OnMouseButtonDown(InGeo, InMouseEvent)
	if self.ViewModel ~= nil then
		self.ViewModel:ActiveFunction()
		self:PlayAnimation(self.AnimClick)
	end
	return WBL.Handled()
end
function FashionDecoSkillBtnView:OnRegisterGameEvent()

end

function FashionDecoSkillBtnView:OnRegisterBinder()
	self.Binders = {
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill,nil,nil,true)},
	}
	self:RegisterBinders(self.ViewModel, self.Binders)
	--暂时没有CD
	UIUtil.SetIsVisible(self.Text_SkillCD, false)
end
return FashionDecoSkillBtnView