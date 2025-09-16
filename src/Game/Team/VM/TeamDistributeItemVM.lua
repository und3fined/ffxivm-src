
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")

local FLOG_WARNING = _G.FLOG_WARNING

---@class TeamDistributeItemVM : UIViewModel
local TeamDistributeItemVM = LuaClass(UIViewModel)

--物品选中后的表现
TeamDistributeItemVM.SelectMode = {
	Select = "IsSelected",
	Preview = "IsPreview",
	Tick = "IsSelectTick",
	IsFishLoop = "IsFishLoop",
}

---Ctor
function TeamDistributeItemVM:Ctor()
    self.RichTextDescribe = ""
    self.IsBtnRondomEnable = true
    self.IsBtnGiveUpEnable = true
    self.IsShowPanelBtn = true
    self.IsShowPanelProbar = true
    self.PanelProbar = 0
    self.RewardItemVMInfo = {}
    self.IsSelected = false
    self.ProgressValue = 1
    self.CountDownNum = 60
    self.IsStartRollTimer = false
    self.ExpireTime = 0
    self.TeamID = 0
    self.IsAlreadyPossessed = false
    self.Num = 0
    self.NumVisible = true
    self.ItemName = ""
    self.TextDes = ""           		-- 奖励状态 放弃/已获得/已拥有
    self.IsQualify = true       		-- 需求资格
    self.IsHaveEligibility = true       -- 归属资格
    self.ShowTipDaily = false
    self.ShowTipFirst = false
    self.IsGiveUp = false
    self.IsOperated = false
    self.IsMask = false
    self.TextMask = false
    self.IsWait = false
    self.IsShowBuff = false
    self.ClassBuffPath = ""
	self.Cfg = nil
    self.AwardID = 0
	self.NumVisible = false
	self.Icon = ""
    self.ItemQualityIcon = ""
	self.IsHighValue = false
end

function TeamDistributeItemVM:UpdateVM(Value)

    self.AwardID = Value.AwardID
    self.IsBind = Value.IsBind
    self.ResID = Value.ResID
    self.RollExpireTime = Value.ExpireTime
    self.TeamID = Value.TeamID
    self.Num = Value.Num
    self.IsHighValue = Value.IsHighValue
    self.IsHaveEligibility = Value.IsHaveEligibility
	if self.IsHaveEligibility ~= true then
		self.IsBtnRondomEnable = false
	end
    if Value.IsObtain ~= nil then
		self.Obtained = Value.IsObtain          -- 是否获得
	end

    local TempExpireTime = self.RollExpireTime
    local  ExpireTime = TempExpireTime * 1000 - TimeUtil.GetServerTimeMS()
	ExpireTime = ExpireTime / 1000
    self.CountDownNum = ExpireTime
    self.Cfg = ItemCfg:FindCfgByKey(Value.ResID)
    if nil == self.Cfg then
        FLOG_WARNING("TeamDistributeItemVM:UpdateVM can't find item cfg, ResID =%d", Value.ResID)
        return
    end
    self.ItemType = self.Cfg.ItemType
    self.Grade = self.Cfg.Grade
    self.ItemLevel = self.Cfg.ItemLevel
    self.IsUnique = self.Cfg.IsUnique > 0

    -- self.RichTextDescribe = Cfg.ItemName                 -- 取消装备名称显示
    self.ItemName = ItemCfg:GetItemName(Value.ResID)

    self.Icon = ItemCfg.GetIconPath(self.Cfg.IconID)
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(self.ResID)

    -- local RewardItemVMInfo = {}
    -- RewardItemVMInfo.ResID = Value.ResID
    -- self.RewardItemVMInfo = RewardItemVMInfo
    -- self.RewardItemVM:UpdateVM(self.RewardItemVMInfo)
end

function TeamDistributeItemVM:SetIsSelected(Value)
    self.IsSelected = Value
end

function TeamDistributeItemVM:OnInit()
    self.IsBtnRondomEnable = true
    self.IsBtnGiveUpEnable = true
    self.IsShowPanelBtn = true
    self.IsShowPanelProbar = true
    self.PanelProbar = 0
    self.RewardItemVMInfo = {}
    self.IsQualify = true       -- 需求资格
    self.IsHaveEligibility = true       -- 归属资格
    self.RichTextDescribe = ""
    self.IsAlreadyPossessed = false
    self.IsSelected = false
    self.ProgressValue = 1
    self.IsStartRollTimer = false
    self.NumVisible = true
    self.TextDes = ""           -- 奖励状态 放弃/已获得/已拥有
    self.IsGiveUp = false
    self.IsOperated = false
    self.IsMask = false
    self.TextMask = false
    self.IsWait = false
    self.IsShowBuff = false
    self.ClassBuffPath = ""
	self.NumVisible = false
end

function TeamDistributeItemVM:OnBegin()
end

function TeamDistributeItemVM:OnEnd()
end

function TeamDistributeItemVM:OnShutdown()
end


return TeamDistributeItemVM