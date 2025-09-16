
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local HelpInfoContentItemVM = require("Game/Common/Tips/VM/HelpInfoContentItemVM")


local TextType =
{
    Title = 0,
    Section = 1,
}

local CommHelpInfoWinVM = LuaClass(UIViewModel)

 ---Ctor
function CommHelpInfoWinVM:Ctor()
    self.TextTitle = ""
    self.TableViewContentList = UIBindableList.New(HelpInfoContentItemVM)
end

function CommHelpInfoWinVM:OnInit()
end

function CommHelpInfoWinVM:OnBegin()
end

function CommHelpInfoWinVM:OnEnd()
end 

function CommHelpInfoWinVM:OnShutdown()
end

function CommHelpInfoWinVM:InitVM(Value)
    if Value == nil or #Value == 0 then
        return
    end

    local DataList = self.TableViewContentList
    self.TextTitle = Value[1].HelpName -- 界面标题

    DataList:Clear()

    for k, v in ipairs(Value) do
        local TitleRow = {}
        TitleRow.Text = v.SecTitle
        TitleRow.WidgetIndex = TextType.Title

        local TitleVM = HelpInfoContentItemVM.New()
        TitleVM:InitVM(TitleRow)
        DataList:Add(TitleVM)

        for index, value in ipairs(v.SecContent) do
            local SectionRow = {}
            SectionRow.Text = value.SecContent
            SectionRow.WidgetIndex = TextType.Section

            local SectionVM = HelpInfoContentItemVM.New()
            SectionVM:InitVM(SectionRow)
            DataList:Add(SectionVM)
        end

    end
end


return CommHelpInfoWinVM
