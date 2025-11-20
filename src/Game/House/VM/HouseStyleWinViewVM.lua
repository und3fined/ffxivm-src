local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HouseLocalDef = require("Game/House/HouseLocalDef")

local HouseStyleWinViewVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR

function HouseStyleWinViewVM:Ctor()
    self.HouseStyleList = {} -- 房屋风格列表
    self.CurSelectIndex = 1 -- 当前选中的风格索引
end


function HouseStyleWinViewVM:UpdateVM(Value)
    local IsValid = nil ~= Value
    if IsValid then
        self.HouseStyleList = Value
    end
end

function HouseStyleWinViewVM:GetBuildCostEnough()
    local SelectedItemData = self.HouseStyleList[self.CurSelectIndex]
    local ItemId = tonumber(SelectedItemData.ItemIds)
    local ItemNum = _G.BagMgr:GetItemNum(ItemId)
    local Enough = ItemNum >= HouseLocalDef.BuildHouseItemCostNum
    return Enough
end

return HouseStyleWinViewVM
