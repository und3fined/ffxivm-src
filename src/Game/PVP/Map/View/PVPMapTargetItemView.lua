---
--- Author: peterxie
--- DateTime:
--- Description: PVP地图可选目标
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")


---@class PVPMapTargetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBgTips UFImage
---@field ImgCrystal UFImage
---@field ImgCrystal2 UFImage
---@field ImgJob UFImage
---@field ImgJob2 UFImage
---@field ImgJobBg UFImage
---@field ImgJobBg2 UFImage
---@field ImgSelected UFImage
---@field PanelTips UFCanvasPanel
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPMapTargetItemView = LuaClass(UIView, true)

function PVPMapTargetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBgTips = nil
	--self.ImgCrystal = nil
	--self.ImgCrystal2 = nil
	--self.ImgJob = nil
	--self.ImgJob2 = nil
	--self.ImgJobBg = nil
	--self.ImgJobBg2 = nil
	--self.ImgSelected = nil
	--self.PanelTips = nil
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPMapTargetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPMapTargetItemView:OnInit()
	self.Binders = {
		{ "IconBgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg) },
		{ "IsPlayer", UIBinderSetIsVisible.New(self, self.ImgJobBg) },
		{ "IsPlayer", UIBinderSetIsVisible.New(self, self.ImgJob) },
		{ "IsPlayer", UIBinderSetIsVisible.New(self, self.ImgCrystal, true) },

		{ "IconBgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg2) },
		{ "IsPlayer", UIBinderSetIsVisible.New(self, self.ImgJobBg2) },
		{ "IsPlayer", UIBinderSetIsVisible.New(self, self.ImgJob2) },
		{ "IsPlayer", UIBinderSetIsVisible.New(self, self.ImgCrystal2, true) },

		{ "RenderOpacity", UIBinderSetRenderOpacity.New(self, self) },

		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgJobSelected) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.PanelTips) },
		{ "TipsContent", UIBinderSetText.New(self, self.RichTextContent) },
	}

	self.TeamMemberBinders = {
		{ "ProfID", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob) },
		{ "ProfID", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob2) },
	}
end

function PVPMapTargetItemView:OnDestroy()

end

function PVPMapTargetItemView:OnShow()

end

function PVPMapTargetItemView:OnHide()

end

function PVPMapTargetItemView:OnRegisterUIEvent()

end

function PVPMapTargetItemView:OnRegisterGameEvent()

end

function PVPMapTargetItemView:OnRegisterBinder()
	local ViewModel = self.Params and self.Params.Data or nil
	if not ViewModel then
		return
	end
	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)

	if ViewModel.MemberVM then
		self:RegisterBinders(ViewModel.MemberVM, self.TeamMemberBinders)
	end
end

function PVPMapTargetItemView:GetViewModel()
	return self.ViewModel
end

return PVPMapTargetItemView