---
--- Author: Alex
--- DateTime: 2025-07-24 11:34
--- Description:保镖游戏竹子砍痕样例ItemVM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")


---@class BanbooSampleItemVM : UIViewModel
---@field Index number@SampleID
local BanbooSampleItemVM = LuaClass(UIViewModel)

function BanbooSampleItemVM:Ctor()
    self.Index = 0
    self.ShowIndex = ""
    self.TriggerWrongAnim = nil
end

function BanbooSampleItemVM:UpdateVM(Value)
    self.Index = Value.Index
    self.ShowIndex = tostring(Value.ShowIndex)
    self.TriggerWrongAnim = nil
end

function BanbooSampleItemVM:IsEqualVM(Value)
	return self.Index == Value.Index
end

--- 触发错误动画播放
function BanbooSampleItemVM:TriggerWrongAnimPlay()
    local AnimTrigger = self.TriggerWrongAnim or false
    self.TriggerWrongAnim = not AnimTrigger
end

return BanbooSampleItemVM


