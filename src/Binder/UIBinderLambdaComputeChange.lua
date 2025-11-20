--[[
Author: jususchen jususchen@tencent.com
Date: 2025-06-24 19:03:36
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-06-24 19:26:39
FilePath: \Script\Binder\UIBinderLambdaComputeChange.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]


local LuaClass = require("Core/LuaClass")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ParentChangeCallback <const> = UIBinderValueChangedCallback.OnValueChanged

---@class UIBinderLambdaComputeChange : UIBinderValueChangedCallback
local UIBinderLambdaComputeChange = LuaClass(UIBinderValueChangedCallback)

local ValueAQKey <const> = "CachedValue"
local LamdaAQKey <const> = "ComputeFunc"

function UIBinderLambdaComputeChange:OnValueChanged()
    local OldValue = rawget(self, ValueAQKey)
    local ComputeFunc = rawget(self, LamdaAQKey)
    local NewValue = ComputeFunc()
    if OldValue ~= NewValue then
        rawset(self, ValueAQKey, NewValue)
        ParentChangeCallback(self, NewValue, OldValue)
    end
end

---@return UIBinderLambdaComputeChange
---@param Callback  function
---@param ComputeFunc function
function UIBinderLambdaComputeChange.CustomNew(View, Callback, ComputeFunc)
    local Binder = UIBinderLambdaComputeChange.New(View, nil, Callback)
    rawset(Binder, LamdaAQKey, ComputeFunc)
    return Binder
end

return UIBinderLambdaComputeChange