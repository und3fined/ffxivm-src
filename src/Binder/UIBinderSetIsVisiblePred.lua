--[[
Author: jususchen jususchen@tencent.com
Date: 2025-02-18 14:19:46
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-02-18 14:20:13
FilePath: \Script\Binder\UIBinderSetIsVisiblePred.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE/
--]]
--


local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class UIBinderSetIsVisiblePred : UIBinderSetIsVisible
local UIBinderSetIsVisiblePred = LuaClass(UIBinderSetIsVisible)

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsVisiblePred:OnValueChanged(NewValue, OldValue)
    local PredValue = self.Pred(NewValue, OldValue) == true
    if self.CachedPredValue ~= PredValue then
        UIBinderSetIsVisible.OnValueChanged(self, PredValue, self.CachedPredValue)
        self.CachedPredValue = PredValue
    end
end

---@param Pred function
---@return UIBinderSetIsVisiblePred
function UIBinderSetIsVisiblePred.NewByPred(Pred, ...)
    local Obj = UIBinderSetIsVisiblePred.New(...)
    Obj.Pred = Pred
    return Obj
end

return UIBinderSetIsVisiblePred