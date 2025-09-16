---
--- Author: Leo
--- DateTime: 2023-03-30 12:22:34
--- Description: 收藏品系统物品
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local CollectablesMgr = require("Game/Collectables/CollectablesMgr")
local EToggleButtonState = _G.UE.EToggleButtonState
local ScoreCfg = require("TableCfg/ScoreCfg")
local ProtoRes = require("Protocol/ProtoRes")

local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR
---@class CollectablesMarketItemVM : UIViewModel

---@field ID number  @成品道具ID
---@field ProfessionIndex number @所属职业
---@field CollectionLevel number @收藏品等级
---@field StarLevel number @星级
---@field UnlockLevel number @解锁等级
---@field bIsMaxLevelCollect bool @是否满级收藏品
---@field OpenVersion string @开始版本  -- 未使用
---@field ClosingVersion string @截止版本 -- 未使用
---@field CollectValue number[] @收藏品价值
---@field LowTicketReward number[] @低级工票报酬
---@field HighTicketReward number[] @高级工票报酬
---@field ExperienceReward number[] @经验报酬
---@field Name string @名称
---@field Icon string @图标路径
---@field TicketIcon string @工票图标路径
---@field TicketID string @工票ID
---@field HoldingNum number @持有数量
---@field bIsSelect EToggleButtonState @是否选中
---@field bSelect bool @是否出现报酬一栏按钮
---@field CollectValueRange string @收藏品价值范围
local CollectablesMarketItemVM = LuaClass(UIViewModel)

---Ctor
---@string ID :ID
function CollectablesMarketItemVM:Ctor()
    self.ID = 0
    self.ProfessionIndex = 0
    self.CollectionLevel = 0
    self.StarLevel = 0
    self.UnlockLevel = 0
    self.bIsMaxLevelCollect = false
    self.CollectValue = {}
    self.LowTicketReward = {}
    self.HighTicketReward = {}
    self.ExperienceReward = {}

    self.Name = ""
    self.Icon = ""
    self.TicketIcon = ""
    self.CollectValueRange = ""
    self.TicketID = 0
    self.HoldingNum = 0
    self.bIsSelect = EToggleButtonState.UnChecked
    self.bSelect = false
end


function CollectablesMarketItemVM:Init()

end

function CollectablesMarketItemVM:OnBegin()

end

function CollectablesMarketItemVM:OnEnd()

end

function CollectablesMarketItemVM:IsEqualVM(Value)
    return true
end

function CollectablesMarketItemVM:UpdateVM(Value)
    local TempID = Value.ID
    self.ID = TempID
    local Cfg = ItemCfg:FindCfgByKey(self.ID)
    if nil == Cfg then
        FLOG_WARNING("CollectablesMarketItemVM:UpdateVM can't find item cfg, ID =%d", TempID)
        return
    end
    self.Name = string.gsub(Cfg.ItemName or "", "%b<>", "")
    self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
    self.ProfessionIndex = Value.ProfessionIndex
    self.CollectionLevel = string.format(LSTR(770001), Value.CollectionLevel)
    self.bIsMaxLevelCollect = Value.IsMaxLevelCollect
    --确定工票图标
    self:SetTicketIcon()
    self.StarLevel = Value.StarLevel
    self.UnlockLevel = Value.UnlockLevel
    self.CollectValue = Value.CollectValue
    self.HighTicketReward = Value.HighTicketReward
    self.LowTicketReward = Value.LowTicketReward
    local MinValueIndex = 1
    local MaxValueIndex = 3
    self.CollectValueRange = string.format("%s~%s", self.CollectValue[MinValueIndex] or 0, self.CollectValue[MaxValueIndex] or 0 )
    if self.bIsMaxLevelCollect == 1 then
        self.TicketRewardText = string.format("%s", self.HighTicketReward[MaxValueIndex] or 0 )
    else
        self.TicketRewardText = string.format("%s", self.LowTicketReward[MaxValueIndex] or 0 )
    end
    self.ExperienceReward = Value.ExperienceReward
    self.MinExperienceReward = self.ExperienceReward[MinValueIndex]
    self.HoldingNum = Value.HoldingNum
end

---@type 根据背包中拥有的数量设置持有数量
function CollectablesMarketItemVM:SetHoldingNum()
    local Data = CollectablesMgr:GetCollectionInBag(self.ID)
    self.HoldingNum = #Data or 0
end

---@type 确定工票图标
function CollectablesMarketItemVM:SetTicketIcon()
    local TicketID = 0
    local ScoreType = ProtoRes.SCORE_TYPE
    local MinEarHandsProfIndex = 36
    if self.ProfessionIndex < MinEarHandsProfIndex and self.bIsMaxLevelCollect == 0 then
        TicketID = ScoreType.SCORE_TYPE_HAND_BLUE_CODE
    elseif self.ProfessionIndex < MinEarHandsProfIndex and self.bIsMaxLevelCollect == 1 then
        TicketID = ScoreType.SCORE_TYPE_HAND_RED_CODE 
    elseif self.ProfessionIndex >= MinEarHandsProfIndex and self.bIsMaxLevelCollect == 0 then
        TicketID = ScoreType.SCORE_TYPE_GROUND_BLUE_CODE
    elseif self.ProfessionIndex >= MinEarHandsProfIndex and self.bIsMaxLevelCollect == 1 then
        TicketID = ScoreType.SCORE_TYPE_GROUND_RED_CODE
    end
    self.TicketID = TicketID
    local ScoreCfgData = ScoreCfg:FindCfgByKey(TicketID)
    self.TicketIcon = ScoreCfgData.IconName
end

--- 设置返回的索引：0
function CollectablesMarketItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function CollectablesMarketItemVM:AdapterOnGetCanBeSelected()
    return true
end

--- 返回子节点列表
function CollectablesMarketItemVM:AdapterOnGetChildren()
    return {}
end

return CollectablesMarketItemVM