---
--- Author: stellahxhu
--- DateTime: 2022-07-25 11:10
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LuaClass = require("Core/LuaClass")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class TeamAttriAddInforView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AddIconFar UFImage
---@field AddIconHealth UFImage
---@field AddIconMagic UFImage
---@field AddIconNear UFImage
---@field AddIconTank UFImage
---@field BG Comm2FrameLView
---@field FText_AttriMain UFTextBlock
---@field FText_Value URichTextBox
---@field ImgDarkBarFar UFImage
---@field ImgDarkBarHealth UFImage
---@field ImgDarkBarMagic UFImage
---@field ImgDarkBarNear UFImage
---@field ImgDarkBarTank UFImage
---@field ImgFar UFImage
---@field ImgHealth UFImage
---@field ImgLightBarFar UFImage
---@field ImgLightBarHealth UFImage
---@field ImgLightBarMagic UFImage
---@field ImgLightBarNear UFImage
---@field ImgLightBarTank UFImage
---@field ImgMagic UFImage
---@field ImgNear UFImage
---@field ImgTank UFImage
---@field TeamAttriAddItem_Far TeamAttriAddJobItemView
---@field TeamAttriAddItem_Health TeamAttriAddJobItemView
---@field TeamAttriAddItem_Magic TeamAttriAddJobItemView
---@field TeamAttriAddItem_Near TeamAttriAddJobItemView
---@field TeamAttriAddItem_Tank TeamAttriAddJobItemView
---@field TextInfor UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamAttriAddInforView = LuaClass(UIView, true)

function TeamAttriAddInforView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AddIconFar = nil
	--self.AddIconHealth = nil
	--self.AddIconMagic = nil
	--self.AddIconNear = nil
	--self.AddIconTank = nil
	--self.BG = nil
	--self.FText_AttriMain = nil
	--self.FText_Value = nil
	--self.ImgDarkBarFar = nil
	--self.ImgDarkBarHealth = nil
	--self.ImgDarkBarMagic = nil
	--self.ImgDarkBarNear = nil
	--self.ImgDarkBarTank = nil
	--self.ImgFar = nil
	--self.ImgHealth = nil
	--self.ImgLightBarFar = nil
	--self.ImgLightBarHealth = nil
	--self.ImgLightBarMagic = nil
	--self.ImgLightBarNear = nil
	--self.ImgLightBarTank = nil
	--self.ImgMagic = nil
	--self.ImgNear = nil
	--self.ImgTank = nil
	--self.TeamAttriAddItem_Far = nil
	--self.TeamAttriAddItem_Health = nil
	--self.TeamAttriAddItem_Magic = nil
	--self.TeamAttriAddItem_Near = nil
	--self.TeamAttriAddItem_Tank = nil
	--self.TextInfor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamAttriAddInforView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.TeamAttriAddItem_Far)
	self:AddSubView(self.TeamAttriAddItem_Health)
	self:AddSubView(self.TeamAttriAddItem_Magic)
	self:AddSubView(self.TeamAttriAddItem_Near)
	self:AddSubView(self.TeamAttriAddItem_Tank)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamAttriAddInforView:OnPostInit()
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")

	self.TeamAttriAddItem_Tank:SetPredefinedProfs(TeamRecruitUtil.GetViewingOpenProfs(ProtoCommon.class_type.CLASS_TYPE_TANK))
	self.TeamAttriAddItem_Health:SetPredefinedProfs(TeamRecruitUtil.GetViewingOpenProfs(ProtoCommon.class_type.CLASS_TYPE_HEALTH))
	self.TeamAttriAddItem_Near:SetPredefinedProfs(TeamRecruitUtil.GetViewingOpenProfs(ProtoCommon.class_type.CLASS_TYPE_NEAR))
	self.TeamAttriAddItem_Far:SetPredefinedProfs(TeamRecruitUtil.GetViewingOpenProfs(ProtoCommon.class_type.CLASS_TYPE_FAR))
	self.TeamAttriAddItem_Magic:SetPredefinedProfs(TeamRecruitUtil.GetViewingOpenProfs(ProtoCommon.class_type.CLASS_TYPE_MAGIC))

	self.Binders = {
		{ "ClassTypeTank", UIBinderSetIsVisible.New(self, self.AddIconTank) },
		{ "ClassTypeTank", UIBinderSetIsVisible.New(self, self.ImgDarkBarTank, true) },
		{ "ClassTypeTank", UIBinderSetIsVisible.New(self, self.ImgLightBarTank) },
		{ "ClassTypeTank", UIBinderSetIsVisible.New(self, self.ImgTank) },

		{ "ClassTypeHealth", UIBinderSetIsVisible.New(self, self.AddIconHealth) },
		{ "ClassTypeHealth", UIBinderSetIsVisible.New(self, self.ImgDarkBarHealth, true) },
		{ "ClassTypeHealth", UIBinderSetIsVisible.New(self, self.ImgLightBarHealth) },
		{ "ClassTypeHealth", UIBinderSetIsVisible.New(self, self.ImgHealth) },

		{ "ClassTypeNear", UIBinderSetIsVisible.New(self, self.AddIconNear) },
		{ "ClassTypeNear", UIBinderSetIsVisible.New(self, self.ImgDarkBarNear, true) },
		{ "ClassTypeNear", UIBinderSetIsVisible.New(self, self.ImgLightBarNear) },
		{ "ClassTypeNear", UIBinderSetIsVisible.New(self, self.ImgNear) },

		{ "ClassTypeFar", UIBinderSetIsVisible.New(self, self.AddIconFar) },
		{ "ClassTypeFar", UIBinderSetIsVisible.New(self, self.ImgDarkBarFar, true) },
		{ "ClassTypeFar", UIBinderSetIsVisible.New(self, self.ImgLightBarFar) },
		{ "ClassTypeFar", UIBinderSetIsVisible.New(self, self.ImgFar) },

		{ "ClassTypeMagic", UIBinderSetIsVisible.New(self, self.AddIconMagic) },
		{ "ClassTypeMagic", UIBinderSetIsVisible.New(self, self.ImgDarkBarMagic, true) },
		{ "ClassTypeMagic", UIBinderSetIsVisible.New(self, self.ImgLightBarMagic) },
		{ "ClassTypeMagic", UIBinderSetIsVisible.New(self, self.ImgMagic) },

		{ "ClassTypeNum", 	UIBinderValueChangedCallback.New(self, nil, self.OnClassTypeNumChanged) },
	}


	self.BG:SetTitleText(_G.LSTR(1300060))
	self.TextInfor:SetText(_G.LSTR(1300061))
	self.FText_AttriMain:SetText(_G.LSTR(1300062))
end

function TeamAttriAddInforView:OnRegisterUIEvent()
	if not self.FrameM then return end
	UIUtil.AddOnClickedEvent(self, self.FrameM.ButtonClose, self.OnClickButtonClose)
end

function TeamAttriAddInforView:OnRegisterBinder()
	local VM
	local IsDungeon = _G.PWorldMgr:CurrIsInDungeon() 
	if IsDungeon then
		VM = _G.PWorldTeamVM
	else
		VM = _G.TeamVM
	end

	self:RegisterBinders(VM, self.Binders)
end

function TeamAttriAddInforView:OnClassTypeNumChanged(Num)
	if nil == Num then
		return
	end
	
	local fmt = Num > 0 and '<span color="#89BD88FF">+%d%%</>' or "+%d%%"
	self.FText_Value:SetText(string.format(fmt, Num))
end

function TeamAttriAddInforView:OnClickButtonClose()
	self:Hide()
end

return TeamAttriAddInforView