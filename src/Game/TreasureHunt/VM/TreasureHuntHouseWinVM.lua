local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")

local ProtoCS = require("Protocol/ProtoCS")
local LOOT_TYPE = ProtoCS.LOOT_TYPE

local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemCfg = require("TableCfg/ItemCfg")
--local TreasuryGuessGameCfg = require("TableCfg/TreasuryGuessGameCfg")

local TreasureHuntHouseWinVM = LuaClass(UIViewModel)
function TreasureHuntHouseWinVM:Ctor()
    self.IsVisibleCloseBtn = false
    self.IsShowAbandon = false
    self.IsShowChallenge = false
    self.IsShowTextWait = false
    self.TextGet = ""

    self.StartTime = nil
end

function TreasureHuntHouseWinVM:OnInit()
    self.CurrRewardList = UIBindableList.New(ItemVM,{ IsCanBeSelected = false, IsShowNum = true, IsDaily = false })
    self.NextRewardList = UIBindableList.New(ItemVM,{ IsCanBeSelected = false, IsShowNum = true, IsDaily = false })
    
    self.StartTime = nil
end

function TreasureHuntHouseWinVM:UpdateData(Params)
    if Params == nil then return end
    
    -- 只有队长或者单人挑战者，现在改成宝图主人
    local IsCaptain  = true
    if TeamMgr:IsInTeam() then
        local RoleID = MajorUtil.GetMajorRoleID()
        if Params.RoleID ~= RoleID then 
            IsCaptain = false
        end
        --IsCaptain = TeamMgr:IsCaptain()
    end
    self.IsVisibleCloseBtn = not IsCaptain
    self.IsShowAbandon = IsCaptain 
    self.IsShowChallenge = IsCaptain
    self.IsShowTextWait = not IsCaptain
    self.StartTime = math.floor(Params.StartTime / 1000) -- 毫秒转秒
    self.TextGet = string.format(LSTR(640052),Params.Guesstimes + 1 )

    self.Guesstimes = Params.Guesstimes
    self:UpdateBaseReward(Params.PrivateItems,Params.RandItems,Params.RollItems)
    -- 当前获得的奖励
    self:UpdateCurrReward()
    --下一次可能获得的奖励
    self:UpdateNextRewardList()
end

function TreasureHuntHouseWinVM:LootItemToItem(LootItem)
    if LootItem.IsScore then
        return { GID = 0, ResID = LootItem.ResID, Num  =LootItem.Num, IsQualityVisible = true, IsScore = true, IsShowNum = true }
    else
        return { GID = LootItem.GID, ResID = LootItem.ResID, Num = LootItem.Num, IsQualityVisible = true, IsScore = false, IsShowNum = true }
    end
end

function TreasureHuntHouseWinVM:GetRewardItems(RewardItems)
    for _, RewardItem in ipairs(RewardItems) do
        local Cfg = ItemCfg:FindCfgByKey(RewardItem.ResID)	
        if Cfg ~= nil then
            local item = self:LootItemToItem(RewardItem)
            local bFind = false
            for _, v in pairs(self.BaseRewardList) do 
                if v.ResID == item.ResID then 
                    v.Num = v.Num + item.Num
                    bFind = true 
                    break
                end
            end
            if not bFind then
                table.insert(self.BaseRewardList,item)
            end
        end
    end
end

function TreasureHuntHouseWinVM:UpdateBaseReward(PrivateItems,RandItems,RollItems)
    self.BaseRewardList = {}
    self:GetRewardItems(PrivateItems)
    self:GetRewardItems(RandItems)
    self:GetRewardItems(RollItems)
end

function TreasureHuntHouseWinVM:UpdateCurrReward()
    local RewardList = {}   
    self.CurrRewardList:Clear()
    for _,RewardItem in pairs(self.BaseRewardList) do 
        local Item = table.deepcopy(RewardItem)
        Item.Num = Item.Num * (self.Guesstimes + 1)
        table.insert(RewardList,Item)
    end
    self.CurrRewardList:UpdateByValues(RewardList)
end

function TreasureHuntHouseWinVM:UpdateNextRewardList() 
    local RewardList = {}   
    self.NextRewardList:Clear()
    for _,RewardItem in pairs(self.BaseRewardList) do 
        local Item = table.deepcopy(RewardItem)
        Item.Num = Item.Num * (self.Guesstimes + 2)
        table.insert(RewardList,Item)
    end
    self.NextRewardList:UpdateByValues(RewardList)
end

return TreasureHuntHouseWinVM