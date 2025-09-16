---
--- Author: saintzhao
--- DateTime: 2025-01-02 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")

---@class Main2ndMoreTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field FImg_Icon UFImage
---@field FTextBlock_BtnName UFTextBlock
---@field MenuItem UFButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndMoreTipsItemView = LuaClass(UIView, true)

function Main2ndMoreTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.FImg_Icon = nil
	--self.FTextBlock_BtnName = nil
	--self.MenuItem = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndMoreTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndMoreTipsItemView:OnInit()

end

function Main2ndMoreTipsItemView:OnDestroy()

end

function Main2ndMoreTipsItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.FImg_Icon, Item.Icon)
	self.FTextBlock_BtnName:SetText(Item.BtnName)
	self.BtnEntranceID = Item.BtnEntranceID

	if Item.IsNeedShowRedDot then
		self.CommonRedDot_UIBP:SetIsCustomizeRedDot(true)
		self.CommonRedDot_UIBP:SetRedDotUIIsShow(true)
		local IsShowRedDot = false
		if Item.BtnEntranceID == Main2ndPanelDefine.MoreMenuType.Questionnaire then
			IsShowRedDot = _G.MURSurveyMgr.bNeedShowRedDot
		end
		UIUtil.SetIsVisible(self.CommonRedDot_UIBP, IsShowRedDot)
	end
end

function Main2ndMoreTipsItemView:OnHide()

end

function Main2ndMoreTipsItemView:OnRegisterUIEvent()

end

function Main2ndMoreTipsItemView:OnRegisterGameEvent()

end

function Main2ndMoreTipsItemView:OnRegisterBinder()

end

return Main2ndMoreTipsItemView