--
-- Author: ds_yangyumian
-- Date: 2024-06-3 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")


local CompanyType = ProtoRes.grand_company_type
local LSTR = _G.LSTR
local ScoreMgr = _G.ScoreMgr

local GrandCompanyImg = {
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_Flag_TheMaelstrom.UI_CompanySeal_Img_Flag_TheMaelstrom'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_Flag_TheOrderoftheTwinAdder.UI_CompanySeal_Img_Flag_TheOrderoftheTwinAdder'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_Flag_TheImmortalFlames.UI_CompanySeal_Img_Flag_TheImmortalFlames'",
}

---@class CompanySealTransferWinVM : UIViewModel
local CompanySealTransferWinVM = LuaClass(UIViewModel)

---Ctor
function CompanySealTransferWinVM:Ctor()
	self.Title = nil
	self.Desc = nil
	self.LeftImg = nil
	self.RightImg = nil
	self.LeftRankIcon = nil
	self.RightRankIcon = nil
	self.LeftRankText = nil
	self.RightRankText = nil
	self.LeftIcon2 = nil
	self.RightIcon2 = nil
	self.Tips = nil
	self.TextQuantity = nil
	self.PanelSureVisible = false
	self.PanelTransVisible = true
	self.IsSure = false
	self.BtnStyle = 1
	self.IsCanTransfer = false
	self.IsCDOver = false
	self.SurplusCDDay = 0
	self.IconTicket = nil
end

function CompanySealTransferWinVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealTransferWinVM:UpdateVM()

end

function CompanySealTransferWinVM:OnBegin()

end

function CompanySealTransferWinVM:OnEnd()

end

function CompanySealTransferWinVM:UpdateInfo()
	self.Title = LSTR(1160012)
	local CurGrandName = ProtoEnumAlias.GetAlias(CompanyType, CompanySealMgr.GrandCompanyID)
	local OpenGrandName = ProtoEnumAlias.GetAlias(CompanyType, CompanySealMgr.CurOpenTransferID)
	self.Desc = string.format("%s<span color=\"#d1ba8e\">%s</>%s<span color=\"#d1ba8e\">%s</>%s", LSTR(1160046), CurGrandName, LSTR(1160052), OpenGrandName, LSTR(1160023))
	self:SetImgAndIcon()
	--self:SetSureViewInfo()
	self:SetTips()
	self.IconTicket = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
end

function CompanySealTransferWinVM:SetImgAndIcon()
	self.LeftImg = GrandCompanyImg[CompanySealMgr.GrandCompanyID]
	self.RightImg = GrandCompanyImg[CompanySealMgr.CurOpenTransferID]
	local CurRankLv
	if CompanySealMgr.MilitaryLevel == 0 then
		CurRankLv = 1
	else
		CurRankLv = CompanySealMgr.MilitaryLevel
	end
	local CurOpenTransferLv
	if not CompanySealMgr.MilitaryLevelList[CompanySealMgr.CurOpenTransferID] or CompanySealMgr.MilitaryLevelList[CompanySealMgr.CurOpenTransferID] == 0 then
		CurOpenTransferLv = 1
	else
		CurOpenTransferLv = CompanySealMgr:GetMilitaryLvByGrandCompanyID(CompanySealMgr.CurOpenTransferID)
	end
	local CurRankIconPath = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID][CurRankLv].Icon
	local CurOpenTransferIconPath = CompanySealMgr.CompanyRankList[CompanySealMgr.CurOpenTransferID][CurOpenTransferLv].Icon
	self.LeftRankIcon = CurRankIconPath
	self.RightRankIcon = CurOpenTransferIconPath
	self.LeftRankText = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID][CurRankLv].RankName
	self.RightRankText = CompanySealMgr.CompanyRankList[CompanySealMgr.CurOpenTransferID][CurOpenTransferLv].RankName
end

function CompanySealTransferWinVM:SetSureViewInfo()
	self.LeftIcon2 = GrandCompanyImg[CompanySealMgr.GrandCompanyID]
	self.RightIcon2 = GrandCompanyImg[CompanySealMgr.CurOpenTransferID]

	local CurHas = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
	local CurNeed
	local TransferCD = CompanySealMgr.TransferTime
	local IsCDOver = false
	if TransferCD == 0 then
		IsCDOver = true
		CurNeed = 0
	else
		IsCDOver = self:GetCD(TransferCD)
		CurNeed = CompanySealMgr.TransferCost
	end
	self.IsCDOver = IsCDOver
	if CurHas >= CurNeed then
		self.TextQuantity = string.format("<span color=\"#d1ba8e\">%s</>", ScoreMgr.FormatScore(string.format("%d", CurNeed)))
		self.BtnStyle = 1
		self.IsCanTransfer = true
	else
		self.TextQuantity = string.format("<span color=\"#dc5868\">%s</>", ScoreMgr.FormatScore(string.format("%d", CurNeed)))
		self.BtnStyle = 2
		self.IsCanTransfer = false
	end
end

function CompanySealTransferWinVM:SetTips()
	local TipsCfg = HelpCfg:FindAllHelpIDCfg(11046)
	local TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(TipsCfg))
	--"1、玩家军衔达到<span color=\"#d1ba8e\">%d级</>后，可以改变自己所属军队,转移到新的大国防联军，某些转入前的军队专属物品将不能使用\n2、更换所属军队有<span color=\"#d1ba8e\">%d天</>的冷却时间，第一次更换无需缴纳费用，从第二次开始每次需要缴纳一定金币作为转换费\n3、改变所属军队后，原所属大国防联军的军票、<span color=\"#d1ba8e\">军衔会被冻结</>，若以后再重新转回先前的军队，会重新继承原先的军衔，<span color=\"#d1ba8e\">军票也将重新启用</>"
	self.Tips = string.format(TipsContent[1].Content[1], CompanySealMgr.CanChangedLevel, CompanySealMgr.TransferTimeLimit)
end

function CompanySealTransferWinVM:UpdateSureState(Value)
	self.IsSure = Value
	if Value then
		self:SetSureViewInfo()
	end
end

function CompanySealTransferWinVM:UpdateSureView(Value)
	self.PanelSureVisible = Value
	self.PanelTransVisible = not Value
end

function CompanySealTransferWinVM:GetCD(Time)
	if Time == nil then
		FLOG_ERROR("CompanySealTransferWinVM GetCD Error")
		return false
	end
	local IsCDOver = false
	local CurTime = TimeUtil.GetServerTime()
	local CDLimit = CompanySealMgr.TransferTimeLimit * 24 * 60 * 60
	local Second = CurTime - Time
	local Day
	if Second >= CDLimit then
		IsCDOver = true
		Day = 0
	else
		local Surplus = CDLimit - Second
		Day = math.ceil(Surplus / (24 * 60 * 60))
	end

	self.SurplusCDDay = Day
	return IsCDOver
end

return CompanySealTransferWinVM