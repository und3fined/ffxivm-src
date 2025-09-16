local LuaClass = require("Core/LuaClass")
local UIBindableList = require("UI/UIBindableList")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsActivityWhaleMonutItemVM = require("Game/Ops/VM/OpsActivityWhaleMonutItemVM")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local ProtoRes = require("Protocol/ProtoRes")
local OpsActivityTaskPanelVM = require("Game/Ops/VM/OpsActivityTaskPanelVM")
local OpsActivityWhaleMonutVM = LuaClass(OpsActivityTaskPanelVM)
local ProtoCS = require("Protocol/ProtoCS")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreCfg = require("TableCfg/StoreCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

function OpsActivityWhaleMonutVM:Ctor()
    self.GoodsID = 0
    self.IsBuy = false
    self.TaskVMList = UIBindableList.New(OpsActivityWhaleMonutItemVM)
    self.StrParamText1 = ""
    self.StrParamText2 = ""
    self.StrParamText3 = ""
    self.StrParamText3Visible = false
end

function OpsActivityWhaleMonutVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    local TotalStatisticNodes = {}
  
    local IsLock = false
    local NodeList = ActivityData.NodeList
    for i, v in ipairs(NodeList) do
        if not v.Head.EmergencyShutDown then
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID) or {}
            if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased then
                self:SetGoodsID(NodeCfg.Params and NodeCfg.Params[1] or 0)
                self:SetActGoodsHasBought(v.Extra.Progress)
                local SplitList = string.split(NodeCfg.StrParam, "|")
                for i, v in ipairs(SplitList) do
                    if self["StrParamText".. i] then
                        self["StrParamText".. i] = tonumber(v) and _G.LSTR(tonumber(v)) or v
                    end
                end

                self.PreviewMonutJumpID = NodeCfg.JumpParam
                self.PreviewMonutJumpType = NodeCfg.JumpType
            elseif NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeStatistic then
                local RedDotName = _G.OpsActivityMgr:GetRedDotName(Activity.ClassifyID, Activity.ActivityID, string.format("Reward/Task%s", i))
                local Node = {}
                local RewardStatus = v.Head.RewardStatus
                Node.Index = 0
                Node.NodeID = v.Head.NodeID
                Node.NodeDes = NodeCfg.NodeDesc
                Node.TotalTask = NodeCfg.Target
                Node.FinishedTask = v.Head.Finished and NodeCfg.Target or v.Extra.Progress.Value    --- 活动框架刷新问题 等后面支持Notify推送Extra 再改回去
                Node.RewardStatus = RewardStatus
                Node.Rewards = NodeCfg.Rewards
                Node.JumpType = NodeCfg.JumpType
                Node.JumpID = tonumber(NodeCfg.JumpParam) or 0
                Node.RedDotName = RedDotName
                Node.Sort = RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusDone and NodeCfg.NodeSort or NodeCfg.NodeSort - 999999
                Node.Locked = v.Head.Locked
                Node.JumpButton = NodeCfg.JumpButton
                IsLock = v.Head.Locked
                table.insert(TotalStatisticNodes, Node)
            end
        end
    end

    self.Tasks = TotalStatisticNodes
    self.StrParamText3Visible = not self:GetActGoodsHasBought() or IsLock
    table.sort(self.Tasks,function(l, r) return l.Sort > r.Sort end)
    for i, v in ipairs(self.Tasks) do
        self.Tasks[i].TotalNum = #self.Tasks
        self.Tasks[i].IndexInList = i
    end
    self.TaskVMList:UpdateByValues(self.Tasks)
    self:UpdateRed()
end

function OpsActivityWhaleMonutVM:SetGoodsID(GoodsID)
    self.GoodsID = GoodsID
end

function OpsActivityWhaleMonutVM:GetGoodsID()
    return self.GoodsID
end

function OpsActivityWhaleMonutVM:SetActGoodsHasBought(ProgressData)
    if self.GoodsID ~= 0 then
        local GoodsData = _G.StoreMgr:GetProductDataByID(self.GoodsID)
        local IsCan, CanNotReason = _G.StoreMgr:IsCanBuy(self.GoodsID)
        self.IsBuy = CanNotReason == _G.LSTR(StoreDefine.SecondScreenType.Owned)
        local TempCfg = StoreCfg:FindCfgByKey(self.GoodsID)
        local TempCfgItems = TempCfg.Items or {}
        if not self.IsBuy and TempCfgItems[1] and TempCfgItems[1].ID then
            local Cfg = ItemCfg:FindCfgByKey(TempCfgItems[1].ID)
            self.IsBuy = _G.BagMgr:IsItemUsed(Cfg)
        end
    end

    if not self.IsBuy then
        if ProgressData.Value > 0 then
            self.IsBuy = true
        else
            self.IsBuy = false
        end 
    end
end

function OpsActivityWhaleMonutVM:GetActGoodsHasBought()
   return self.IsBuy
end

function OpsActivityWhaleMonutVM:UpdateRed()
    if next(self.Tasks) then
        for i, v in ipairs(self.Tasks) do
            RedDotMgr:DelRedDotByName(v.RedDotName)
            if v.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                RedDotMgr:AddRedDotByName(v.RedDotName)
            end
        end
    end
end

return OpsActivityWhaleMonutVM