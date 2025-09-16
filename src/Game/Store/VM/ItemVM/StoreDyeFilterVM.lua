---
---@author Lucas
---DateTime: 2023-05-7 15:11:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local LSTR = _G.LSTR

---@class StoreDyeFilterVM: UIViewModel
---@field bSelected bool 是否选中
---@field SubName string 标签名
local StoreDyeFilterVM = LuaClass(UIViewModel)

function StoreDyeFilterVM:Ctor()
    self.bSelected = false
    self.SubName = ""
    self.TextColor = "#b2b2b2"
end

function StoreDyeFilterVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreDyeFilterVM:UpdateVM(Value)
    self.bSelected = false
    if Value.bSelected ~= nil then
        self.bSelected = Value.bSelected
    end
    self.SubName = Value.SubName
end

function StoreDyeFilterVM:ChangeSelected(Flag)
    self.bSelected = Flag
end

return StoreDyeFilterVM