--
-- Author: ZhengJanChuan
-- Date: 2025-03-04 16:42
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")

---@class WardrobeTipsListItem2VM : UIViewModel
local WardrobeTipsListItem2VM = LuaClass(UIViewModel)

---Ctor
function WardrobeTipsListItem2VM:Ctor()
    self.ProfName = ""
    self.Progress = ""
end

function WardrobeTipsListItem2VM:OnInit()
end

function WardrobeTipsListItem2VM:OnBegin()
end

function WardrobeTipsListItem2VM:OnEnd()
end

function WardrobeTipsListItem2VM:OnShutdown()
end

function WardrobeTipsListItem2VM:UpdateVM(Value)
    self.ProfName = Value.ProfName
    self.Progress = string.format("%d/%d", Value.Num, Value.TotalNum)
end

function WardrobeTipsListItem2VM:IsEqualVM(Value)
    return false
end


--要返回当前类
return WardrobeTipsListItem2VM