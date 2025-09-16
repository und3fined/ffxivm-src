--[[
Author: jususchen jususchen@tencent.com
Date: 2025-02-20 15:58:05
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-02-20 15:58:31
FilePath: \Script\Binder\UIBinderSetImageBrushByResFunc.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class UIBinderSetImageBrushByResFunc : UIBinderSetBrushFromAssetPath
local UIBinderSetImageBrushByResFunc = LuaClass(UIBinderSetBrushFromAssetPath)

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetImageBrushByResFunc:OnValueChanged(NewValue, OldValue)
    local AssetPath = self.ResFunc(NewValue, OldValue)
    if AssetPath ~= self.AssetPath then
        if AssetPath and AssetPath ~= "" then
            UIBinderSetBrushFromAssetPath.OnValueChanged(self, AssetPath, self.AssetPath)
        end
        self.AssetPath = AssetPath
    end
end

---@param ResFunc function
---@return UIBinderSetImageBrushByResFunc
function UIBinderSetImageBrushByResFunc.NewByResFunc(ResFunc, ...)
    local O = UIBinderSetImageBrushByResFunc.New(...)
    O.ResFunc = ResFunc
    return O
end

return UIBinderSetImageBrushByResFunc