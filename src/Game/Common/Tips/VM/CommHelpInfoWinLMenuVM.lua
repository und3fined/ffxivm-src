
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local HelpInfoContentItemVM = require("Game/Common/Tips/VM/HelpInfoContentItemVM")

local TextType =
{
    Title = 0,
    Section = 1,
}

---@class CommHelpInfoWinLMenuVM: UIViewModel
local CommHelpInfoWinLMenuVM = LuaClass(UIViewModel)

function CommHelpInfoWinLMenuVM:Ctor()
    self.Title = ""
    self.MenuList = {}
    self.TableViewContentList = UIBindableList.New(HelpInfoContentItemVM)
end

function CommHelpInfoWinLMenuVM:OnInit()
end

function CommHelpInfoWinLMenuVM:OnBegin()
end

function CommHelpInfoWinLMenuVM:OnEnd()
end 

function CommHelpInfoWinLMenuVM:OnShutdown()
end

function CommHelpInfoWinLMenuVM:InitVM(Value)
   self.Title = Value.Title
   self.MenuList = Value.MenuList
end

function CommHelpInfoWinLMenuVM:UpdateContentList(Index)
    
    local List = self.MenuList[Index].Content
    if List == nil then
        return
    end

    local DataList = self.TableViewContentList

    DataList:Clear()

    for k, v in ipairs(List) do
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

    self.TableViewContentList = DataList
end


return CommHelpInfoWinLMenuVM