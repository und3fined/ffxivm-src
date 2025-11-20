--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-15 11:38:46
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-15 17:24:18
FilePath: \Script\Game\Adventure\AdventureRecommendFateTaskItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local AdventureItemItemVM = require("Game/Adventure/ItemVM/AdventureItemItemVM")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR

local AdventureRecommendFateTaskItemVM = LuaClass(UIViewModel)

function AdventureRecommendFateTaskItemVM:Ctor()
    self.RewardList = UIBindableList.New(AdventureItemItemVM)
    self.MapID = nil
    self.TextTitle = nil
    self.PlayerNum = nil
    self.BattleDes = nil
end

function AdventureRecommendFateTaskItemVM:UpdateVM(Params)
    self.MapID = Params.MapID
    self.TextTitle = Params.TextTitle
    self.PlayerNum = string.format(LSTR(520080), Params.PlayerNum) 
    self.BattleDes = string.format(LSTR(520081), Params.BattleDes)
    self:SetRewardData()
end

function AdventureRecommendFateTaskItemVM:IsEqualVM(Value)
    return self.MapID == Value.MapID
end

function AdventureRecommendFateTaskItemVM:SetRewardData()
    local ItemList = {}
    local RewardData = _G.AdventureFateRecommendMgr.FateRewardCfg
    for i, v in ipairs(RewardData) do
        local Data = {}
        Data.ResID = v
        Data.IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(v))
        if i == #RewardData then
            Data.DateText = LSTR(520082)
        end
        table.insert(ItemList, Data)
    end

    self.RewardList:UpdateByValues(ItemList)
end

return AdventureRecommendFateTaskItemVM