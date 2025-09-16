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

        local NodeCfg = nil
        local NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
        if NodeList and #NodeList > 0 then
            local NodeID  = NodeList[1].Head.NodeID
            NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
        end

        --[[
        local ActivityNodesCfg = ActivityNodeCfg:FindAllCfg("ActivityID = " .. ActivityData.ActivityID)
        if ActivityNodesCfg then
            for _, v in ipairs(ActivityNodesCfg) do
                if v.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay then
                    NodeCfg = v
                    break
                end
            end
        end]]--

        if NodeCfg ~= nil then
            local AwardItemList = NodeCfg.Rewards
            for i = #AwardItemList, 1, -1 do
                if AwardItemList[i].ItemID == 0 then
                    table.remove(AwardItemList, i)
                else
                    AwardItemList[i].ItemSlotType = ItemDefine.ItemSlotType.Item96Slot
                end
            end
            self.BtnContent = NodeCfg.JumpButton
            self.JumpType = NodeCfg.JumpType
            self.JumpParam = NodeCfg.JumpParam
            if self.BtnContent and self.BtnContent ~= "" then
                self.bShowCommBtnGoto = true
            else
               self.bShowCommBtnGoto = false
            end

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
        else
            self.BtnContent = nil
            self.JumpType = nil
            self.JumpParam = nil
            self.bShowTableViewSlot = false
            self.bShowCommBtnGoto = false
            self.bShowImgline = false
        end
    end
end


return OpsActivityLeftandRightPanelVM