---
--- Author: ds_jan
--- DateTime: 2024-06-27 15:02
--- Description:
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
 
local HelpInfoContentItemSVM = LuaClass(UIViewModel)


 ---Ctor
function HelpInfoContentItemSVM:Ctor()
    self.RichTextContent = ""
end
 
function HelpInfoContentItemSVM:OnInit()
end

function HelpInfoContentItemSVM:OnBegin()
end

function HelpInfoContentItemSVM:OnEnd()
end 

function HelpInfoContentItemSVM:OnShutdown()
end

function HelpInfoContentItemSVM:UpdateVM(Value)
    self.RichTextContent = Value.Content
end

function HelpInfoContentItemSVM:IsEqualVM(Value)
    return false
end

return HelpInfoContentItemSVM