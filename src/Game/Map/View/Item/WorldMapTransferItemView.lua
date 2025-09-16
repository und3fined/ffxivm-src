---
--- Author: peterxie
--- DateTime: 2024-04-16 15:44
--- Description: 水晶传送列表水晶项
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")


---@class WorldMapTransferItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgNormal UFImage
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field ToggleBtnCollect UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapTransferItemView = LuaClass(UIView, true)

function WorldMapTransferItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgNormal = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.ToggleBtnCollect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapTransferItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapTransferItemView:OnInit()
	self.Binders =
	{
		{ "MapName", UIBinderSetText.New(self, self.Text01) },
		{ "CrystalName", UIBinderSetText.New(self, self.Text02) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsInFavor", UIBinderSetIsChecked.New(self, self.ToggleBtnCollect) },
	}
end

function WorldMapTransferItemView:OnDestroy()

end

function WorldMapTransferItemView:OnShow()

end

function WorldMapTransferItemView:OnHide()

end

function WorldMapTransferItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnCollect, self.OnStateChangedFavor)
end

function WorldMapTransferItemView:OnRegisterGameEvent()

end

function WorldMapTransferItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.VM = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function WorldMapTransferItemView:OnStateChangedFavor(ToggleButton, ButtonState)
	if not self.VM.IsInFavor then
		if _G.WorldMapMgr:AddTransferFavor(self.VM.CrystalID) then
			_G.WorldMapMgr:SaveMapTransferFavor()
			self.VM.IsInFavor = true
		end
	else
		if _G.WorldMapMgr:RemoveTransferFavor(self.VM.CrystalID) then
			_G.WorldMapMgr:SaveMapTransferFavor()
			self.VM.IsInFavor = false
		end
	end
end

return WorldMapTransferItemView