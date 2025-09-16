--[[
Author: v_hggzhang
Date: 2022-11-25 14:31
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-05-31 16:49:05
FilePath: \Script\Game\PWorld\Entrance\View\PWorldSelectChildItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PWorldSelectChildItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgItemNormal UFImage
---@field ImgItemSelect UFImage
---@field ImgLock UFImage
---@field ImgMatching UFImage
---@field Panelhighlydifficult UFCanvasPanel
---@field TextHighlyDifficult UFTextBlock
---@field TextNormal UFTextBlock
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldSelectChildItemView = LuaClass(UIView, true)

function PWorldSelectChildItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgItemNormal = nil
	--self.ImgItemSelect = nil
	--self.ImgLock = nil
	--self.ImgMatching = nil
	--self.Panelhighlydifficult = nil
	--self.TextHighlyDifficult = nil
	--self.TextNormal = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldSelectChildItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldSelectChildItemView:OnInit()
	self.Binders = {
		{ "PWorldName", UIBinderSetText.New(self, self.TextNormal) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgItemSelect) },
		{ "bShowLock", 	UIBinderSetIsVisible.New(self, self.ImgLock) },
		{ "IsMatching", UIBinderSetIsVisible.New(self, self.ImgMatching) },
		{ "BackgroudImageIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgItemNormal) },
		{ "bPrettyHard", UIBinderValueChangedCallback.New(self, nil, self.OnPrettyHardChanged)},
	}
end

function PWorldSelectChildItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	if nil == Params.Data then
		return
	end

	self.VM = Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PWorldSelectChildItemView:OnSelectChanged(IsSelected)
	if self.VM then
		self.VM:SetSelected(IsSelected)
	end
end

function PWorldSelectChildItemView:OnPrettyHardChanged(Value)
	UIUtil.SetIsVisible(self.Panelhighlydifficult, Value)
	if Value then
		self.TextHighlyDifficult:SetText(_G.LSTR(1320232))
	end
end

return PWorldSelectChildItemView