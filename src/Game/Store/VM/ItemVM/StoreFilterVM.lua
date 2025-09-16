---
---@author Lucas
---DateTime: 2023-05-7 15:11:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local LSTR = _G.LSTR
local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreFilterVM: UIViewModel
---@field bSelected bool 是否选中
---@field SubName string 标签名
local StoreFilterVM = LuaClass(UIViewModel)

function StoreFilterVM:Ctor()
    self.bSelected = false
    self.SubName = ""
	self.TextColor = "#b2b2b2"
end

function StoreFilterVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreFilterVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreFilterVM:InitVM Value is nil")
        return
    end

    if Value.bSelected ~= nil then
        self.bSelected = Value.bSelected
    end

    self.SubName = Value.SubName
end

function StoreFilterVM:ChangeSelected(Flag)
    self.bSelected = Flag
end

return StoreFilterVM