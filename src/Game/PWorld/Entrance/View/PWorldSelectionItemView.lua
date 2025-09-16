--[[
Author: yuhang_lightpaw <yuhang@lightpaw.com>
Date: 2024-06-28 09:59:29
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-30 17:19:25
FilePath: \Script\Game\PWorld\Entrance\View\PWorldSelectionItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PWorldSelectionItemView : UIView
---@field VM PWorldSelectionItemVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field HorizontalNormal UFHorizontalBox
---@field ImgLight UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field PanelSelect UFCanvasPanel
---@field TextNormal UFTextBlock
---@field TextSelect UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldSelectionItemView = LuaClass(UIView, true)

function PWorldSelectionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.HorizontalNormal = nil
	--self.ImgLight = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.PanelSelect = nil
	--self.TextNormal = nil
	--self.TextSelect = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldSelectionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end
function PWorldSelectionItemView:OnInit()
	self.Binders = {
		{"SelectionName", UIBinderSetText.New(self, self.TextNormal)},
		{"SelectionName", UIBinderSetText.New(self, self.TextSelect)},
		{"bTabUnlock", UIBinderSetIsVisible.New(self, self.ImgUnlock, true)},
		{"bSelected", UIBinderValueChangedCallback.New(self, nil, function (_, V)
			self:PlayAnimation(V and self.AnimCheck or self.AnimUncheck)
		end)},
		{"bSelected", UIBinderSetIsVisible.New(self, self.TextSelect)},
		{"bSelected", UIBinderSetIsVisible.New(self, self.PanelSelect)},
		{"bSelected", UIBinderSetIsVisible.New(self, self.TextNormal, true)},
	}
end

function PWorldSelectionItemView:OnRegisterBinder()
	if not (self.Params and self.Params.Data) then
		return
	end

	self.VM = self.Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PWorldSelectionItemView:OnSelectChanged(IsSelected)
	if not self.VM then
		return
	end

	self.VM.bSelected = IsSelected
end

return PWorldSelectionItemView