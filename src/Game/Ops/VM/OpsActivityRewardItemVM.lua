local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")

---@class OpsActivityRewardItemVM : UIViewModel
local OpsActivityRewardItemVM = LuaClass(UIViewModel)

---Ctor
function OpsActivityRewardItemVM:Ctor()
    self.Icon = nil
    self.ItemQualityIcon = nil
    self.Num = nil
    self.ItemID = nil
    self.HideItemLevel = true
    self.IconChooseVisible = false
    self.IconReceivedVisible = false
end

function OpsActivityRewardItemVM:UpdateVM(Params)
    if Params.DropID ~= nil then
        self.ItemID = Params.DropID
        self.ItemQualityIcon = ItemUtil.GetItemColorIcon(Params.DropID)
        if Params.ItemSlotType ~= nil then
            self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(Params.DropID, ItemDefine.ItemSlotType.Item96Slot)
        end
        self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Params.DropID))
        self.Num = _G.ScoreMgr.FormatScore(Params.DropNum)
        self.IconReceivedVisible = Params.IconReceivedVisible
        self.IsMask = Params.IconReceivedVisible
        self.LotteryProbability = Params.LotteryProbability
        self.ProbabilityColor = Params.ProbabilityColor
        self.BtnCheck = ItemUtil.IsCanPreviewByResID(self.ItemID)
    elseif Params.Day ~= nil then
        self.ItemID = Params.ItemID
        self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Params.ItemID))
        self.Num = _G.ScoreMgr.FormatScore(Params.Num)
        self.Day = Params.Day
        self.TextDay = Params.TextDay
        self.ImgBG = Params.ImgBG
        self.ActivityID = Params.ActivityID
        self.BtnPreviewVisible = Params.BtnPreviewVisible
        self.IconReceivedVisible = Params.IconReceivedVisible
        self.IconRewardAvaiable = Params.IconRewardAvaiable
    elseif Params.ItemID ~= nil then
        self.ItemID = Params.ItemID
        self.ItemQualityIcon = ItemUtil.GetItemColorIcon(Params.ItemID)
        self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Params.ItemID))
        if Params.ItemSlotType ~= nil then
            self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(Params.ItemID, ItemDefine.ItemSlotType.Item96Slot)
        end
        self.Num = _G.ScoreMgr.FormatScore(Params.Num)
        if Params.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
            self.IconReceivedVisible = true
            self.IsMask = true
        else
            self.IconReceivedVisible = false
            self.IsMask = false
        end
    end
end

function OpsActivityRewardItemVM:IsEqualVM(Value)
    return false
end

return OpsActivityRewardItemVM