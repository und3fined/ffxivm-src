--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2023-12-08 09:26:57
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-01-07 14:49:27
FilePath: \Client\Source\Script\Binder\UIBinderSetDesaturation.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--
-- Author: anypkvcai
-- Date: 2022-05-13 14:58
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetDesaturation : UIBinder
local UIBinderSetDesaturation = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetDesaturation:Ctor(View, Widget,InReverse)
	self.InReverse = InReverse
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetDesaturation:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end
	
	local InReverse = self.InReverse
	local TrueValue = InReverse == true and 0 or 1
	local FalseValue = InReverse == true and 1 or 0
	local Desaturation = NewValue and TrueValue or FalseValue

	UIUtil.SetImageDesaturate(self.Widget, nil, Desaturation)
end

return UIBinderSetDesaturation