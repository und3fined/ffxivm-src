---
--- Author: xingcaicao
--- DateTime: 2023-04-13 16:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class PersonInfoProfItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ContentNode UFCanvasPanel
---@field EmptyPanel UFCanvasPanel
---@field IconProf UFImage
---@field IconUnStyle_1 UFImage
---@field TextLevel UFTextBlock
---@field TextNone UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoProfItemView = LuaClass(UIView, true)

function PersonInfoProfItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ContentNode = nil
	--self.EmptyPanel = nil
	--self.IconProf = nil
	--self.IconUnStyle_1 = nil
	--self.TextLevel = nil
	--self.TextNone = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoProfItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoProfItemView:OnInit()
	self.Binders = {
		{ "LevelColor", UIBinderSetColorAndOpacityHex.New(self, self.TextLevel) },
		--{ "ProfID",		UIBinderSetProfIconSimple2nd.New(self, self.IconProf) },
		{ "ProfIcon",		UIBinderSetImageBrush.New(self, self.IconProf) },
		{ "LevelDesc", 	UIBinderSetText.New(self, self.TextLevel) },
		{ "IsUnLock", 	UIBinderSetIsVisible.New(self, self.TextLevel) },
		{ "IsUnLock", 	UIBinderSetIsVisible.New(self, self.TextNone, true) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.EmptyPanel) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, self.ContentNode, true) },
	}
end

function PersonInfoProfItemView:OnDestroy()

end

function PersonInfoProfItemView:OnShow()
end

function PersonInfoProfItemView:OnHide()
	self.Params = nil
end

function PersonInfoProfItemView:OnRegisterUIEvent()

end

function PersonInfoProfItemView:OnRegisterGameEvent()

end

function PersonInfoProfItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel
	if nil == ViewModel then
		return
	end

	self.TextNone:SetText("-")

	self:RegisterBinders(ViewModel, self.Binders)
end

function PersonInfoProfItemView:UpdateProfInfo( ProfVM )
	if nil == ProfVM then
		return
	end

	--图标
	local ProfID = ProfVM.ProfID
	if ProfID then
		local ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(ProfID)
		if not string.isnilorempty(ProfIcon) then
			UIUtil.ImageSetBrushFromAssetPath(self.IconProf, ProfIcon)
		end
	end

	--等级
	self.TextLevel:SetText(ProfVM.LevelDesc or "")
	self.TextNone:SetText("-")

	--是否解锁
	local IsUnLock = ProfVM.IsUnLock == true
	UIUtil.SetIsVisible(self.TextLevel, IsUnLock) 
	UIUtil.SetIsVisible(self.TextNone, not IsUnLock) 
end

function PersonInfoProfItemView:GetViewportPosition()
	local LocalPos = UIUtil.CanvasSlotGetPosition(self.IconProf)
	local Pos = UIUtil.LocalToViewport(self.ContentNode, LocalPos)
	return Pos
end

return PersonInfoProfItemView