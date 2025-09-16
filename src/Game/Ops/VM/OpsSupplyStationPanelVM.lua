local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ItemUtil = require("Utils/ItemUtil")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")


---@class OpsSupplyStationPanelVM : UIViewModel
local OpsSupplyStationPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsSupplyStationPanelVM:Ctor()
    self.TextTitle = nil
    self.TextSubTitle = nil
    self.ImgPoster = nil
    self.PosterDay = nil
    self.RewardSuitID = nil
    self.PosterReceiveVisiable = false
    self.PosterRewardAvailable = false
    self.AwardVMList = UIBindableList.New(OpsActivityRewardItemVM)
end

function OpsSupplyStationPanelVM:Update(Params)
    local Activity = Params.Activity
    local NodeList = Params.NodeList
    if Activity and NodeList then
        self.TextTitle = Activity.Title
        self.TextSubTitle = Activity.SubTitle
        local LoginDayRewards = {}
        for k, v in ipairs(NodeList) do
            local ActivityNode = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID)
            if ActivityNode then
                if ActivityNode.Target == 8 then
                    self.ImgPoster =  ActivityNode.StrParam
                    self.PosterDay = ActivityNode.NodeDesc
                    self.PosterItemID1 = ActivityNode.Rewards[1].ItemID
                    self.PosterItemNum1 = ActivityNode.Rewards[1].Num
                    self.PosterItemID2 = ActivityNode.Rewards[2].ItemID
                    self.PosterItemNum2 = ActivityNode.Rewards[2].Num
                    self.PosterItemID3 = ActivityNode.Rewards[3].ItemID
                    self.PosterItemNum3 = ActivityNode.Rewards[3].Num
                    self.RewardSuitID = ActivityNode.Params[1]
                    self.PosterReceiveVisiable = v.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
                    self.PosterRewardAvailable = v.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
                else
                    local i = ActivityNode.Target
                    local LoginDayReward = {}
                    LoginDayReward.ItemID = ActivityNode.Rewards[1].ItemID
                    LoginDayReward.Num = ActivityNode.Rewards[1].Num
                    LoginDayReward.Type = ActivityNode.Rewards[1].Type
                    LoginDayReward.Day = i
                    LoginDayReward.ActivityID = Activity.ActivityID
                    LoginDayReward.TextDay = ActivityNode.NodeDesc
                    LoginDayReward.IconReceivedVisible = v.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
                    LoginDayReward.IconRewardAvaiable = v.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
                    LoginDayReward.BtnPreviewVisible = ItemUtil.IsCanPreviewByResID(LoginDayReward.ItemID)
                    if LoginDayReward.BtnPreviewVisible then
                        LoginDayReward.ImgBG = OpsActivityDefine.PropBoxType.AdvancedProp
                    else
                        LoginDayReward.ImgBG = OpsActivityDefine.PropBoxType.OrdinaryProp
                    end
                    if LoginDayReward.IconRewardAvaiable then
                        LoginDayReward.ImgBG = OpsActivityDefine.PropBoxType.AvailableProp
                    end
                    LoginDayRewards[i] = LoginDayReward
                end
            end
        end
        self.AwardVMList:UpdateByValues(LoginDayRewards)
    end
end


return OpsSupplyStationPanelVM