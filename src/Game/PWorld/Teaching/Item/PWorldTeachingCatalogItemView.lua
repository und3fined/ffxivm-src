---
--- Author: ashyuan
--- DateTime: 2024-04-19 15:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local TeachingMgr = _G.TeachingMgr

---@class PWorldTeachingCatalogItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field IconPassed UFImage
---@field Img UFImage
---@field PanelTag UFCanvasPanel
---@field PanelUnopened UFCanvasPanel
---@field TextCatalog UFTextBlock
---@field TextRequire UFTextBlock
---@field TextTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeachingCatalogItemView = LuaClass(UIView, true)

function PWorldTeachingCatalogItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.IconPassed = nil
	--self.Img = nil
	--self.PanelTag = nil
	--self.PanelUnopened = nil
	--self.TextCatalog = nil
	--self.TextRequire = nil
	--self.TextTag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeachingCatalogItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeachingCatalogItemView:OnInit()

end

function PWorldTeachingCatalogItemView:OnDestroy()

end

function PWorldTeachingCatalogItemView:OnShow()

end

function PWorldTeachingCatalogItemView:OnHide()

end

function PWorldTeachingCatalogItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.StartTeaching)
end

function PWorldTeachingCatalogItemView:OnRegisterGameEvent()

end

function PWorldTeachingCatalogItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextCatalog) },
		{ "Require", UIBinderSetText.New(self, self.TextRequire) },
		{ "ShowPassed", UIBinderSetVisibility.New(self, self.IconPassed) },
		{ "ShowLocked", UIBinderSetVisibility.New(self, self.PanelUnopened) },
		{ "ImgPath", UIBinderSetBrushFromAssetPath.New(self, self.Img) },
		{ "ShowSelected", UIBinderSetVisibility.New(self, self.PanelTag) },
		{ "TextTag", UIBinderSetText.New(self, self.TextTag) },
	}
	
	self:RegisterBinders(self.ViewModel, Binders)
end

function PWorldTeachingCatalogItemView:StartTeaching()
	if not self.ViewModel.CanEnter then
		MsgTipsUtil.ShowTips(LSTR(890014))
		return
	end

	if not self.ViewModel.PreCompleted then
		MsgTipsUtil.ShowTips(LSTR(890015))
		return
	end

	if _G.TeamMgr:GetMemberNum() > 0 then
		MsgTipsUtil.ShowTips(LSTR(890016))
		return
	end

	-- 选择当前项目,直接返回
	if TeachingMgr:IsSelected(self.ViewModel.InteractiveID) then
		return
	end

	if TeachingMgr:IsEnableTeaching(true) then
		local function Callback()
			TeachingMgr:StartTeaching(self.ViewModel.InteractiveID)
		end
		local TipsStr = TeachingMgr.IsTeachScene and LSTR(890017) or LSTR(890018)
		MsgBoxUtil.ShowMsgBoxTwoOp(self, self.ViewModel.Name, TipsStr, Callback, nil, LSTR(890020),  LSTR(890021))
	end
end

return PWorldTeachingCatalogItemView