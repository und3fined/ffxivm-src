
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local HelpInfoContentItemSVM = require("Game/Common/Tips/VM/HelpInfoContentItemSVM")
 
local CommHelpInfoVM = LuaClass(UIViewModel)

 ---Ctor
function CommHelpInfoVM:Ctor()
    self.TableViewContentList = UIBindableList.New(HelpInfoContentItemSVM)
end
 
function CommHelpInfoVM:OnInit()
end

function CommHelpInfoVM:OnBegin()
end

function CommHelpInfoVM:OnEnd()
end 

function CommHelpInfoVM:OnShutdown()
end

function CommHelpInfoVM:UpdateVM(Data)
    self.TableViewContentList:Clear()
    local ItemList = {}
    for _, v in ipairs(Data) do
        for _, value in ipairs(v.Content) do
            table.insert(ItemList, {Content = value})
        end
    end
    self.TableViewContentList:UpdateByValues(ItemList)
end

return CommHelpInfoVM