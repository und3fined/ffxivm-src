local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemDefine = require("Game/Item/ItemDefine")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsActivityLeftandRightPanelVM : UIViewModel
local OpsActivityLeftandRightPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsActivityLeftandRightPanelVM:Ctor()
    self.TextIntroduction = nil
    self.TextTitle = nil
    self.TextSubTitle = nil
    self.BtnContent = nil
    self.JumpType = nil
    self.JumpParam = nil
    self.bShowSubTitle = false
    self.bShowTextIntroduction = false
    self.bShowCommBtnGoto = false
    self.bShowTableViewSlot = false
    self.bShowImgline = false
    self.bShowPanelReward = false
    self.bShowCommBtnGoto2 = false
    self.bShowVideo = false
    self.AwardVMList = UIBindableList.New(OpsActivityRewardItemVM)
end

function OpsActivityLeftandRightPanelVM:Update(Params)
    local ActivityData = Params.Activity
    if ActivityData then
        self.TextTitle = ActivityData.Title
        self.TextIntroduction = ActivityData.Info
        if self.TextIntroduction and self.TextIntroduction ~= "" then
            self.bShowTextIntroduction = true
        else
            self.bShowTextIntroduction = false
        end
        self.TextSubTitle = ActivityData.SubTitle
        if self.TextSubTitle and self.TextSubTitle ~= "" then
            self.bShowSubTitle = true
        else
            self.bShowSubTitle = false
        end
        local ClientShowNodeCfg = nil
        local LoginDayNodeCfg = nil
        self.LoginDayNodeRewards = nil
        self.LoginDayNodeID = nil
        self.IsLoginDay = false
        local LoginDayNodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay)
        local ClientShowNodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
        if ClientShowNodeList and #ClientShowNodeList > 0 then
            local NodeID  = ClientShowNodeList[1].Head.NodeID
            ClientShowNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
        end

        if LoginDayNodeList ~= nil and #LoginDayNodeList > 0 then
            local NodeID  = LoginDayNodeList[1].Head.NodeID
            LoginDayNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
        end

        if ClientShowNodeCfg ~= nil then
            local AwardItemList = ClientShowNodeCfg.Rewards
            for i = #AwardItemList, 1, -1 do
                if AwardItemList[i].ItemID == 0 then
                    table.remove(AwardItemList, i)
                else
                    AwardItemList[i].ItemSlotType = ItemDefine.ItemSlotType.Item96Slot
                end
            end
            self.BtnContent = ClientShowNodeCfg.JumpButton
            self.JumpType = ClientShowNodeCfg.JumpType
            self.JumpParam = ClientShowNodeCfg.JumpParam
            if self.BtnContent and self.BtnContent ~= "" then
                self.bShowCommBtnGoto = true
            else
               self.bShowCommBtnGoto = false
            end
            self:SetPanelState(Params, AwardItemList, ClientShowNodeCfg)
        elseif LoginDayNodeCfg ~= nil then
            local AwardItemList = LoginDayNodeCfg.Rewards
            for i = #AwardItemList, 1, -1 do
                if AwardItemList[i].ItemID == 0 then
                    table.remove(AwardItemList, i)
                else
                    AwardItemList[i].ItemSlotType = ItemDefine.ItemSlotType.Item96Slot
                end
            end
            self.LoginDayNodeRewards = AwardItemList
            self.bShowCommBtnGoto = true
            self.IsLoginDay = true
            self:SetPanelState(Params, AwardItemList, LoginDayNodeCfg)
            if LoginDayNodeList ~= nil and #LoginDayNodeList > 0 then
                self.RewardStatus  = LoginDayNodeList[1].Head.RewardStatus
                self.LoginDayNodeID = LoginDayNodeList[1].Head.NodeID
            end
        else
            self.BtnContent = nil
            self.JumpType = nil
            self.JumpParam = nil
            self.bShowTableViewSlot = false
            self.bShowCommBtnGoto = false
            self.bShowCommBtnGoto2 = false
            self.bShowImgline = false
            self.bShowPanelReward = false
            self.bShowVideo = false
            self.VideoPath = nil
        end
    end
end


function OpsActivityLeftandRightPanelVM:SetPanelState(Params, AwardItemList, NodeCfg)
    if #AwardItemList > 0 then
        self.bShowTableViewSlot = true
        self.AwardVMList:UpdateByValues(AwardItemList)
    else
        self.bShowTableViewSlot = false
    end
    if self.bShowTableViewSlot and self.bShowTextIntroduction then
        self.bShowImgline = true
    else
        self.bShowImgline = false
    end

    if self.bShowTableViewSlot or self.bShowCommBtnGoto then
        self.bShowPanelReward = true
    else
        self.bShowPanelReward = false
    end

    if Params.IsHorizontalCenterPanel then
        if not self.bShowTableViewSlot and self.bShowCommBtnGoto then
            self.bShowCommBtnGoto2 = true
            self.bShowCommBtnGoto = false
        else
            self.bShowCommBtnGoto2 = false
        end
    end

    if NodeCfg.StrParam and NodeCfg.StrParam ~= "" then
        self.bShowVideo = true
        self.VideoPath = NodeCfg.StrParam
    else
        self.bShowVideo = false
        self.VideoPath = nil
    end
end


return OpsActivityLeftandRightPanelVM