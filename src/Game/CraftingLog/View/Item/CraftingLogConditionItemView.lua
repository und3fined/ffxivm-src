--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-05-28 10:42:30
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-05-28 17:09:16
FilePath: \Client\Source\Script\Game\CraftingLog\View\Item\CraftingLogConditionItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: ghnvbnvb
--- DateTime: 2023-04-13 15:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CraftingLogConditionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCheck UFImage
---@field ImgForbidden UFImage
---@field TextCondition UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogConditionItemView = LuaClass(UIView, true)

function CraftingLogConditionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCheck = nil
	--self.ImgForbidden = nil
	--self.TextCondition = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogConditionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogConditionItemView:OnInit()
	self.Binders = {
		{"TextCondition", UIBinderSetText.New(self, self.TextCondition)},
		{"bForbiddenShow", UIBinderSetIsVisible.New(self, self.ImgForbidden)},
		{"bCheckedShow", UIBinderSetIsVisible.New(self, self.ImgCheck)}
	}
end

function CraftingLogConditionItemView:OnDestroy()
end

function CraftingLogConditionItemView:OnShow()
end

function CraftingLogConditionItemView:OnHide()
end

function CraftingLogConditionItemView:OnRegisterUIEvent()
end

function CraftingLogConditionItemView:OnRegisterGameEvent()
end

function CraftingLogConditionItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

return CraftingLogConditionItemView
