local LuaClass = require("Core/LuaClass")
--local ItemVM = require("Game/Item/ItemVM")
local UIViewModel = require("UI/UIViewModel")

local MountSettingTipsItemVM = require("Game/Mount/VM/MountSettingTipsItemVM")

local LSTR = _G.LSTR

---@class MountSettingTipsVM : UIViewModel
local MountSettingTipsVM = LuaClass(UIViewModel)

function MountSettingTipsVM:Ctor()
    self.ListSettingTipsItemVM = nil
end

function MountSettingTipsVM:GenItems(Index)
    if self.ListSettingTipsItemVM == nil then
        --生成数据
        local List = {}

        local ItemVM = MountSettingTipsItemVM.New()
        ItemVM.Title = LSTR(1090022)
        ItemVM:SetSelect(false)
        ItemVM.Index = 1
        List[#List + 1] = ItemVM

        ItemVM = MountSettingTipsItemVM.New()
        ItemVM.Title = LSTR(1090023)
        ItemVM:SetSelect(false)
        ItemVM.Index = 2
        List[#List + 1] = ItemVM

        ItemVM = MountSettingTipsItemVM.New()
        ItemVM.Title = LSTR(1090024)
        ItemVM:SetSelect(false)
        ItemVM.Index = 3
        List[#List + 1] = ItemVM

        self.ListSettingTipsItemVM = List
    end

    for _,value in ipairs(self.ListSettingTipsItemVM) do
        value:SetSelect(value.Index == Index)
    end
end

return MountSettingTipsVM