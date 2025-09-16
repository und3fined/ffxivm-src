--
-- Author: henghaoli
-- Date: 2022-09-09
-- Description: 将一个bool类型属性绑定到一个循环播放的动画上, true播放, false停止
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

---@class UIBinderIsLoopAnimPlay : UIBinder
local UIBinderIsLoopAnimPlay = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param Animation UWidgetAnimation
---@param RestoreState boolean
function UIBinderIsLoopAnimPlay:Ctor(View, Widget, Animation,RestoreState)
	self.View = View
	self.Animation = Animation
	self.Widget = Widget

    if RestoreState == nil then
        RestoreState = false
    end

    self.RestoreState = RestoreState
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderIsLoopAnimPlay:OnValueChanged(NewValue, OldValue)
    if NewValue then
        self.View:PlayAnimation(self.Animation, 0, 0,nil, 1.0, self.RestoreState)
    else
        self.View:StopAnimation(self.Animation)
    end
end

return UIBinderIsLoopAnimPlay