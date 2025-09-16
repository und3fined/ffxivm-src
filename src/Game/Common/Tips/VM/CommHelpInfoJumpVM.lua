
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CommHelpInfoTitleVM = require("Game/Common/Tips/VM/CommHelpInfoTitleVM")
local HelpInfoContentItemVM = require("Game/Common/Tips/VM/HelpInfoContentItemVM")

local CommHelpInfoJumpVM = LuaClass(UIViewModel)

local TextType = {
    Title = 0,
    Content = 1
}
 ---Ctor
function CommHelpInfoJumpVM:Ctor()
    self.Title = ""
    self.TableViewContentList = UIBindableList.New(CommHelpInfoTitleVM)
    self.SubTitle = ""
    self.JumpIcon = ""
    self.JumpTitle = ""
    self.JumpArrowVisible = true
    self.JumpWayVisible = false
end
 
function CommHelpInfoJumpVM:OnInit()
end

function CommHelpInfoJumpVM:OnBegin()
end

function CommHelpInfoJumpVM:OnEnd()
end 

function CommHelpInfoJumpVM:OnShutdown()
end

function CommHelpInfoJumpVM:UpdateVM(Data)
    self.Title = Data.Title
    self.SubTitle = Data.SubTitle
    self.TableViewContentList:Clear()
    local DataList = self.TableViewContentList

    for _, v in ipairs(Data.Content) do
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
            table.insert(DataList, {Content = value})
            local ContentVM = HelpInfoContentItemVM.New()
            ContentVM:InitVM(ContentRow)
            DataList:Add(ContentVM)
        end
    end

    local JumpWay = Data.JumpWay
    self.JumpWayVisible = JumpWay ~= nil
    if JumpWay then
        self.JumpIcon = JumpWay.JumpIcon
        self.JumpTitle = JumpWay.JumpTitle
        self.JumpArrowVisible = JumpWay.IsRedirect
    end

end

return CommHelpInfoJumpVM