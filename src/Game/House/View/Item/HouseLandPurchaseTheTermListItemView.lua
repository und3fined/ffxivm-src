--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-20 17:02:48
FilePath: \Script\Game\House\View\Item\HouseLandPurchaseTheTermListItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class HouseLandPurchaseTheTermListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFocus UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseTheTermListItemView = LuaClass(UIView, true)

function HouseLandPurchaseTheTermListItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgFocus = nil
    --self.Text = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseTheTermListItemView:OnRegisterBinder()
	local ViewModel = self.Params.Data
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.Text)},
		{"IsSelect", UIBinderSetIsVisible.New(self, self.ImgFocus)},
		{"Color", UIBinderSetColorAndOpacityHex.New(self, self.Text)},
	}

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return HouseLandPurchaseTheTermListItemView
