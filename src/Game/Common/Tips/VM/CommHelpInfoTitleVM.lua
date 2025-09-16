
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local HelpInfoContentItemVM = require("Game/Common/Tips/VM/HelpInfoContentItemVM")
 
local CommHelpInfoTitleVM = LuaClass(UIViewModel)


local TextType =
{
    Title = 0,
    Content = 1,
}

 ---Ctor
function CommHelpInfoTitleVM:Ctor()
    self.TableViewContentList = UIBindableList.New(HelpInfoContentItemVM)
end
 
function CommHelpInfoTitleVM:OnInit()
end

function CommHelpInfoTitleVM:OnBegin()
end

function CommHelpInfoTitleVM:OnEnd()
end 

function CommHelpInfoTitleVM:OnShutdown()
end

function CommHelpInfoTitleVM:UpdateVM(Data)
    local DataList = self.TableViewContentList

    DataList:Clear()

    local ItemList = {}
    for _, v in ipairs(Data) do
        local TitleRow = {}
        TitleRow.Text = v.Title
        TitleRow.WidgetIndex = TextType.Title

        local TitleVM = HelpInfoContentItemVM.New()
        TitleVM:InitVM(TitleRow)
        DataList:Add(TitleVM)

        for _, value in ipairs(v.Content) do
            local ContentRow = {}
            ContentRow.Text = value
            ContentRow.WidgetIndex = TextType.Content
            table.insert(ItemList, {Content = value})

            local ContentVM = HelpInfoContentItemVM.New()
            ContentVM:InitVM(ContentRow)
            DataList:Add(ContentVM)
        end
    end

end

return CommHelpInfoTitleVM