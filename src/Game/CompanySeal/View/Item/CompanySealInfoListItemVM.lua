--
-- Author: ds_yangyumian
-- Date: 2024-06-3 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local ProtoCS = require("Protocol/ProtoCS")
local CompanyType = ProtoRes.grand_company_type
local LSTR = _G.LSTR
local ScoreMgr = _G.ScoreMgr
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS



---@class CompanySealInfoListItemVM : UIViewModel
local CompanySealInfoListItemVM = LuaClass(UIViewModel)

---Ctor
function CompanySealInfoListItemVM:Ctor()
	self.Level = nil
	self.RankIcon = nil
	self.TextRank = nil
	self.CompanySealNum = nil
	self.Condition = nil
	self.CompanySealIcon = nil
	self.FImageVisible = nil
	self.PromotedVisible = nil
	self.PromotedText = nil	
	self.CurLv = nil
	self.IsCanPromoted = false
	self.PromotedBtnVisible = nil
	self.EffVisible = nil
	self.BGFocusVisible = nil
	self.SealIconVisible = false
	self.PrivilegeText = nil
	self.ImgUpVisible = nil
	self.ImgLockVisible = nil
	self.UnlockTextVisible = nil
	self.UnlockText = LSTR(1160070)--历史军衔
	self.ArmyLogo = nil
	self.CanbepromotedText = nil
	self.CanbepromotedVisible = nil
end

function CompanySealInfoListItemVM:OnInit()

end

function CompanySealInfoListItemVM:OnBegin()

end

function CompanySealInfoListItemVM:OnEnd()

end

---UpdateVM
---@param List table
function CompanySealInfoListItemVM:UpdateVM(List)
	self.CurLv = List.Level
	self.Level = string.format("%d%s", List.Level, LSTR(1160048))
	self.PrivilegeText = List.Privilege
	self.TextRank = List.RankName
	self.RankIcon = List.Icon
	self.ImgLockVisible = false
	self.UnlockTextVisible = false
	self:SetPromotedState(List.PromotionTask, List.PromotionCompanySeal)
	self:SetDesc(List.Desc, List.IsOpen, List.CompanySealMax)
	local RankInfo = CompanySealMgr:GetCompanySealInfo()

	if CompanySealMgr.CurOpenRankID == CompanySealMgr.GrandCompanyID then
		self.BGFocusVisible = self.CurLv == CompanySealMgr.MilitaryLevel
		self.CanbepromotedVisible = self.BGFocusVisible
		self.CanbepromotedText = LSTR(1160079)--当前
	else
		if RankInfo.MilitaryLevelList[CompanySealMgr.CurOpenRankID] and RankInfo.MilitaryLevelList[CompanySealMgr.CurOpenRankID] == self.CurLv then
			self.ImgLockVisible = true
			self.UnlockTextVisible = true
		end
		self.BGFocusVisible = false
		self.CanbepromotedVisible = false
	end
end

function CompanySealInfoListItemVM:SetDesc(Desc, IsOpen, CompanySealMax)
	self.SealIconVisible = true
	local Companyseal = CompanySealMgr:GetScoreInfoByID(CompanySealMgr.CurOpenRankID)
	self.CompanySealIcon = ScoreMgr:GetScoreIconName(Companyseal)

	if not IsOpen then
		self.CompanySealNum = "--"
		self.Condition = string.format("<span color=\"#828282\">%s</>", LSTR(1160020))
	else
		self.CompanySealNum = ScoreMgr.FormatScore(string.format("%d", CompanySealMax))
		self.Condition = Desc
	end
end

function CompanySealInfoListItemVM:SetPromotedState(PromotionTask, PromotionCompanySeal)
	local CurHas = ScoreMgr:GetScoreValueByID(CompanySealMgr.CompanySealID)
	local IsFinish
	if PromotionTask ~= 0 then
		local PreTaskState = _G.QuestMgr:GetQuestStatus(PromotionTask)
		if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            IsFinish = true
		else
			IsFinish = false
        end

	else
		IsFinish = true
	end

	local SurplusLv = self.CurLv - CompanySealMgr.MilitaryLevel

	if IsFinish and CurHas >= PromotionCompanySeal and self.CurLv ~= CompanySealMgr.MilitaryLevel and CompanySealMgr.MilitaryLevel ~= 0 and CompanySealMgr.CurOpenRankID == CompanySealMgr.GrandCompanyID and SurplusLv == 1 then
		self.FImageVisible = true
		self.PromotedVisible = true
		self.PromotedText = LSTR(1160019)--可晋升
		self.ImgUpVisible = true
		self.IsCanPromoted = true
		self.PromotedBtnVisible = true
		self.EffVisible = true
	else
		self.FImageVisible = false
		self.PromotedVisible = false
		self.PromotedText = ""
		self.ImgUpVisible = false
		self.IsCanPromoted = false
		self.PromotedBtnVisible = false
		self.EffVisible = false
	end
end

function CompanySealInfoListItemVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end


return CompanySealInfoListItemVM