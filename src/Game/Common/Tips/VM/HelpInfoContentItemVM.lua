
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LSTR = _G.LSTR
 
local HelpInfoContentItemVM = LuaClass(UIViewModel)

local WidgetIndex =
{
    Title = 0,
    Content = 1,
}

 ---Ctor
function HelpInfoContentItemVM:Ctor()
    self.RichTextContent = ""
    self.RichTextTitle = ""
    self.WidgetIndex = 0
end
 
function HelpInfoContentItemVM:OnInit()
end

function HelpInfoContentItemVM:OnBegin()
end

function HelpInfoContentItemVM:OnEnd()
end 

function HelpInfoContentItemVM:OnShutdown()
end

function HelpInfoContentItemVM:InitVM(Value)
    self.WidgetIndex = Value.WidgetIndex

    local LWidgetIndex = self.WidgetIndex
    -- 标题
    if LWidgetIndex == WidgetIndex.Title then
        self.RichTextTitle = Value.Text
    elseif LWidgetIndex == WidgetIndex.Content then
        self.RichTextContent = Value.Text
    end
end

function HelpInfoContentItemVM:AdapterOnGetWidgetIndex()
	return self.WidgetIndex
end

function HelpInfoContentItemVM:IsEqualVM(Value)
    return false
end

return HelpInfoContentItemVM