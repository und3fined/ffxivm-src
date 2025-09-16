
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

---@class SelectMonsterMainPanelVM : UIViewModel
local SelectMonsterMainPanelVM = LuaClass(UIViewModel)

function SelectMonsterMainPanelVM:Ctor()
    self.MonsterItemList = {}
    self.TableViewItemsLeft = 0
end

function SelectMonsterMainPanelVM:OnInit()
    --这绑定的数据，不检查是否有变化，必然OnValueChange
    local BindProperty = self:FindBindableProperty("MonsterItemList")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end
end

function SelectMonsterMainPanelVM:OnBegin()
end

function SelectMonsterMainPanelVM:OnEnd()
    self.MonsterItemList = {}
end

function SelectMonsterMainPanelVM:OnShutdown()
end

function SelectMonsterMainPanelVM:SetMonsters(EntranceList)
    self.MonsterItemList = EntranceList
    
    local SizeX = #EntranceList * (136 + 50) --item大小+间隔

    local OffsetX = (536 - SizeX) / 2
    if OffsetX < 0 then
        OffsetX = 0
    end
    
    self.TableViewItemsLeft = OffsetX
end

return SelectMonsterMainPanelVM