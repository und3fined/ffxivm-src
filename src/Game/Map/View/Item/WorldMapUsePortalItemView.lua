---
--- Author: Administrator
--- DateTime: 2024-08-29 09:51
--- Description: 传送网使用券列表项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class WorldMapUsePortalItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnUse CommBtnSView
---@field Slot96 CommBackpack96SlotView
---@field TextHave URichTextBox
---@field TextTicket UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapUsePortalItemView = LuaClass(UIView, true)

function WorldMapUsePortalItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnUse = nil
	--self.Slot96 = nil
	--self.TextHave = nil
	--self.TextTicket = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapUsePortalItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.Slot96)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapUsePortalItemView:OnInit()
	self.Binders = {
		{"bEnable", UIBinderSetIsEnabled.New(self, self.BtnUse, false, true)},
		--{"bDisable",UIBinderSetIsVisible.New(self, self.BtnUse.ImgDisable)},
		{"Name",UIBinderSetText.New(self, self.TextTicket)},
		{"OwnNum",UIBinderSetText.New(self, self.TextHave)},
		{"IconPath",UIBinderSetBrushFromAssetPath.New(self, self.Slot96.Icon)},
		{"IconColor",UIBinderSetColorAndOpacityHex.New(self, self.Slot96.Icon)},
		{"IconColor",UIBinderSetColorAndOpacityHex.New(self, self.Slot96.Icon)},
		{"UseTextColor",UIBinderSetColorAndOpacityHex.New(self, self.BtnUse.TextContent)},
	}
end

function WorldMapUsePortalItemView:OnDestroy()

end

function WorldMapUsePortalItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self.Slot96:SetClickButtonCallback(self.Slot96, function(TargetItemView)
		ItemTipsUtil.ShowTipsByResID(ViewModel.ResID, self.Slot96)
	end)

	self.Slot96:SetLevelVisible(false)
	self.Slot96:SetIconChooseVisible(false)
	self.Slot96:SetNumVisible(false)

	self.BtnUse.TextContent:SetText(_G.LSTR(290002)) -- 使 用

	local bEnable = ViewModel.bEnable
	if bEnable then
		UIUtil.ImageSetBrushFromAssetPathSync(self.BtnUse.Img, self.BtnUse.ImgRecommendAssetPath)
	else
		UIUtil.ImageSetBrushFromAssetPathSync(self.BtnUse.Img, self.BtnUse.ImgDisableAssetPath)
	end
end

function WorldMapUsePortalItemView:OnHide()

end

function WorldMapUsePortalItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnUseBtnClick)
end

function WorldMapUsePortalItemView:OnRegisterGameEvent()

end

function WorldMapUsePortalItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function WorldMapUsePortalItemView:OnUseBtnClick()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	_G.AetheryteticketMgr:OnUseBtnClickInMapPanel(ViewModel.ResID)
end

return WorldMapUsePortalItemView