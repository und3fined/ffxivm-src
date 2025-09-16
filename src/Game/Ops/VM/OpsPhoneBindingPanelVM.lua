local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local ItemDefine = require("Game/Item/ItemDefine")

local ActivityNodeCircleType = ProtoRes.Game.ActivityNodeCircleType
local LSTR = _G.LSTR
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsPhoneBindingPanelVM : UIViewModel
local OpsPhoneBindingPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsPhoneBindingPanelVM:Ctor()
    self.TextTitle = nil
    self.TextHint = nil
    self.FirstBindRewardNum = nil
    self.PerMonthRewardNum = nil
    self.FirstBindRewardIcon = nil
    self.FirstBindRewardImgQuality = nil
    self.PerMonthRewardIcon = nil
    self.PerMonthRewardImgQuality = nil
    self.TextBindPhone = nil
    self.PhoneBindInfo = nil
    self.FirstRewardNumVisiable = false
    self.MonthRewardNumVisiable = false
    self.PanelBoundVisiable = false
    self.PanelUnboundVisiable = false
    self.PanelBtn2Visiable = false
    self.BtnLReleaseVisiable = false
    self.PanelVerificationVisiable = false
    self.FirstBindRewardReceieved = false
    self.MonthRewardReceieved = false
    self.FirstBindRewardAvailable = false
    self.MonthRewardAvailable = false
end

function OpsPhoneBindingPanelVM:Update(Params)
    local ActivityData = Params.Activity
    self.ClassifyID = ActivityData.ClassifyID
    self.ActivityID = ActivityData.ActivityID
    self.TextTitle = ActivityData.Title
    self.TextHint = ActivityData.SubTitle
    --self.PhoneBindInfo = ActivityData.Info

    local PhoneBindNode = nil
    local NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypePhoneBind)
    if NodeList then
        PhoneBindNode = NodeList[1]
    end

    local FirstBindNode = nil
    local PerMonthNode = nil
    NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode)
    if NodeList then
        for _, v in ipairs(NodeList) do
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID) or {}
            if NodeCfg.CircleType == ActivityNodeCircleType.ActivityNodeCircleTypeMonth then
                PerMonthNode = NodeCfg
            else
                FirstBindNode = NodeCfg
            end
        end
    end

--[[
    local ActivityNodesCfg = ActivityNodeCfg:FindAllCfg("ActivityID = " .. self.ActivityID)
    local PhoneBindNode = nil
    local FirstBindNode = nil
    local PerMonthNode = nil
    if ActivityNodesCfg then
        for _, v in ipairs(ActivityNodesCfg) do
            if v.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypePhoneBind then
                PhoneBindNode = v
            elseif v.CircleType == ProtoRes.Game.ActivityNodeCircleType.ActivityNodeCircleTypeMonth then
                PerMonthNode = v
            else
                FirstBindNode = v
            end
        end
    end]]--

    if FirstBindNode ~= nil then
        self.FirstBindNodeID = FirstBindNode.NodeID
        self.FirstBindRewardItemID = FirstBindNode.Rewards[1].ItemID
        self.FirstBindRewardNum = FirstBindNode.Rewards[1].Num
        if FirstBindNode.Rewards[1].Num > 1 then
            self.FirstRewardNumVisiable = true
        end
        self.FirstBindRewardIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.FirstBindRewardItemID))
        self.FirstBindRewardImgQuality =  ItemUtil.GetSlotColorIcon(self.FirstBindRewardItemID, ItemDefine.ItemSlotType.Item152Slot)
    end

    if PerMonthNode ~= nil then
        self.PerMonthNodeID = PerMonthNode.NodeID
        self.PerMonthRewardItemID = PerMonthNode.Rewards[1].ItemID
        self.PerMonthRewardAmount = PerMonthNode.Rewards[1].Num
        self.PerMonthRewardNum = _G.ScoreMgr.FormatScore(self.PerMonthRewardAmount)
        if PerMonthNode.Rewards[1].Num > 1 then
            self.MonthRewardNumVisiable = true
        end
        self.PerMonthRewardIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.PerMonthRewardItemID))
        self.PerMonthRewardImgQuality =  ItemUtil.GetSlotColorIcon(self.PerMonthRewardItemID, ItemDefine.ItemSlotType.Item152Slot)
    end

    if PhoneBindNode ~= nil then
        self.PhoneBindNodeID = PhoneBindNode.Head.NodeID
    end

end

function OpsPhoneBindingPanelVM:UpdatePhoneBindData(Params)
    if Params and Params.NodeList then
        local ActivityNodeList = Params.NodeList
        for _, v in ipairs(ActivityNodeList) do
            if v.Head.NodeID == self.PhoneBindNodeID then
                self.PhoneBindData = v.Extra.PhoneBind
            elseif v.Head.NodeID == self.FirstBindNodeID then
                self.FirstBindRewardStatus = v.Head.RewardStatus
            elseif v.Head.NodeID == self.PerMonthNodeID then
                self.PerMonthRewardStatus = v.Head.RewardStatus
            end
        end
    end
end

function OpsPhoneBindingPanelVM:UpdatePhoneBindState(Params)
    self:UpdatePhoneBindData(Params)
    if self.PhoneBindData == nil then
       return
    end

    self:UpdateRewardStatus(self.FirstBindRewardStatus, self.PerMonthRewardStatus)

    -- 绑定过期
    if self.PhoneBindData.Status == OpsActivityDefine.BindState.Expired then
        self.PanelBoundVisiable = true
        self.PanelUnboundVisiable = false
        self.PanelBtn2Visiable = true
        self.BtnLReleaseVisiable = false
        self.PanelVerificationVisiable = true
        self.TextBindPhone = string.format(LSTR(100062), self.PhoneBindData.PhoneNum)   --已绑定手机：%s
        if self.Version == 1 then
            self.PhoneBindInfo = self.Agreements["verifyAuth"]
        else
            self.PhoneBindInfo = self.Agreements["upgradeAuthWithBtn"]
        end
    -- 已绑定
    elseif self.PhoneBindData.Status == OpsActivityDefine.BindState.Binded then
        self.PanelBoundVisiable = true
        self.PanelUnboundVisiable = false
        self.PanelBtn2Visiable = false
        self.BtnLReleaseVisiable = true
        self.PanelVerificationVisiable = false
        self.TextBindPhone = string.format(LSTR(100062), self.PhoneBindData.PhoneNum)

        local linkIdCounter = 1
        local UnBindInfo = string.gsub(self.Agreements["unbind"], "&%{\"text\": \"(.-)\", \"type\": (%d+), \"action\": (%d+)%}&", function(text, type, action)
            local Tag = string.format("<a color=\"#ffeebb\" linkid=\"%d\" underline=\"false\">%s</>", linkIdCounter, text)
            linkIdCounter = linkIdCounter + 1
            return Tag
        end)
        self.PhoneBindInfo = UnBindInfo
    -- 未绑定
    elseif self.PhoneBindData.Status == OpsActivityDefine.BindState.None then
        self.PanelBoundVisiable = false
        self.PanelUnboundVisiable = true
        self.PanelVerificationVisiable = true
        self.PhoneBindInfo = self.Agreements["bindUseSmsWithBtn"]
    end
end

function OpsPhoneBindingPanelVM:UpdateRewardStatus(FirstBindRewardStatus, PerMonthRewardStatus)
    if FirstBindRewardStatus == 1 then
        self.FirstBindRewardReceieved = false
        self.FirstBindRewardAvailable = true
    elseif FirstBindRewardStatus == 2 then
        self.FirstBindRewardReceieved = true
        self.FirstBindRewardAvailable = false
    else
        self.FirstBindRewardReceieved = false
        self.FirstBindRewardAvailable = false
    end

    if PerMonthRewardStatus == 1 then
        self.MonthRewardReceieved = false
        self.MonthRewardAvailable = true
    elseif PerMonthRewardStatus == 2 then
        self.MonthRewardReceieved = true
        self.MonthRewardAvailable = false
    else
        self.MonthRewardReceieved = false
        self.MonthRewardAvailable = false
    end


end


return OpsPhoneBindingPanelVM