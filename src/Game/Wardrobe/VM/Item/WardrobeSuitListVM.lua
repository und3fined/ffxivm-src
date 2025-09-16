--
-- Author: ZhengJanChuan
-- Date: 2025-03-13 15:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local WardrobeSuitItemVM = require("Game/Wardrobe/VM/Item/WardrobeSuitItemVM")
local UIBindableList = require("UI/UIBindableList")

---@class WardrobeSuitListVM : UIViewModel
local WardrobeSuitListVM = LuaClass(UIViewModel)

---Ctor
function WardrobeSuitListVM:Ctor()
    self.ID = nil
    self.IsSelected = nil
    self.TitelName = ""
    self.AppItems1 = UIBindableList.New(WardrobeSuitItemVM)
    self.AppItems2 = UIBindableList.New(WardrobeSuitItemVM)
end

function WardrobeSuitListVM:OnInit()
end

function WardrobeSuitListVM:OnBegin()
end

function WardrobeSuitListVM:OnEnd()
end

function WardrobeSuitListVM:OnShutdown()
end

function WardrobeSuitListVM:UpdateVM(Value)
    self.TitelName = Value.TitelName
    self.ID = Value.ID
    self.AppItems1:Clear()
    self.AppItems2:Clear()
    if Value.AppItems and next(Value.AppItems) then
        local ItemList1 = {}
        local ItemList2 = {}
        for index, v in ipairs(Value.AppItems) do
            local Data = {}
            local Cfg =  EquipmentCfg:FindCfgByEquipID(v)
            if Cfg ~= nil and Cfg.AppearanceID and Cfg.AppearanceID ~= 0 then
                Data.AppID = Cfg.AppearanceID
                Data.EquipID = v
                table.insert(index <= 5 and ItemList1 or ItemList2, Data)
            end
        end

        self.AppItems1:UpdateByValues(ItemList1)
        self.AppItems2:UpdateByValues(ItemList2)
    end
end

function WardrobeSuitListVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeSuitListVM:IsEqualVM(Value)
    return false
end


--要返回当前类
return WardrobeSuitListVM