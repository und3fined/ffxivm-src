--
-- Author: ds_yangyumian
-- Date: 2024-06-3 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local CompanySealTextItemVM = require("Game/CompanySeal/View/Item/CompanySealTextItemVM")


local CompanyType = ProtoRes.grand_company_type
local LSTR = _G.LSTR
local ScoreMgr = _G.ScoreMgr
local GrandCompanyImg = {
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheMaelstrom.UI_CompanySeal_Img_TheMaelstrom'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheOrderoftheTwinAdder.UI_CompanySeal_Img_TheOrderoftheTwinAdder'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheImmortalFlames.UI_CompanySeal_Img_TheImmortalFlames'",
}


---@class CompanySealPromotionWinVM : UIViewModel
local CompanySealPromotionWinVM = LuaClass(UIViewModel)

---Ctor
function CompanySealPromotionWinVM:Ctor()
	self.LeftRankList = UIBindableList.New(CompanySealTextItemVM)
	self.RightRankList = UIBindableList.New(CompanySealTextItemVM)
	self.LeftText = nil
	self.RightText = nil
	self.LeftIcon = nil
	self.RightIcon = nil
	self.TextQuantity = nil
	self.IsCanPromoted = nil
	--self.Img = nil
	self.Title = nil
	self.BtnStyle = 1
	self.GrandImg1 = nil
	self.GrandImg2 = nil
	self.GrandImg3 = nil
	self.IconTicket = nil
end

function CompanySealPromotionWinVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealPromotionWinVM:UpdateVM()

end

function CompanySealPromotionWinVM:OnBegin()

end

function CompanySealPromotionWinVM:OnEnd()

end

function CompanySealPromotionWinVM:UpdateTitleText()
	--local Cfg = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID][CompanySealMgr.MilitaryLevel]
	local Name = ProtoEnumAlias.GetAlias(CompanyType, CompanySealMgr.GrandCompanyID)
	--self.Img = GrandCompanyImg[CompanySealMgr.GrandCompanyID]
	self:SetImgState(CompanySealMgr.GrandCompanyID)
	self.Title = string.format("%s %s", Name, LSTR(1160037))
	local CurLv = CompanySealMgr.MilitaryLevel
	local NextLv = CurLv + 1
	if NextLv >= #CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID] then
		NextLv = #CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID]
	end
	local CurlvCfg = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID][CurLv]
	local NextlvCfg = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID][NextLv]
	self.LeftText = CurlvCfg.RankName
	self.LeftIcon = CurlvCfg.Icon
	self.RightText = NextlvCfg.RankName
	self.RightIcon = NextlvCfg.Icon
	self:UpdateLeftRankList(CurlvCfg.CompanySealMax)
	self:UpdateRightRankList(NextlvCfg)

	local CurHas = ScoreMgr:GetScoreValueByID(CompanySealMgr.CompanySealID)
	local CurNeed = NextlvCfg.PromotionCompanySeal
	if CurHas >= CurNeed then
		self.TextQuantity = string.format("<span color=\"#d1ba8e\">%s</>", ScoreMgr.FormatScore(string.format("%d", CurNeed)))
		self.BtnStyle = 1
		self.IsCanPromoted = true
	else
		self.TextQuantity = string.format("<span color=\"#dc5868\">%s</>", ScoreMgr.FormatScore(string.format("%d", CurNeed)))
		self.BtnStyle = 2
		self.IsCanPromoted = false
	end
end

function CompanySealPromotionWinVM:UpdateLeftRankList(CompanySealMax)
	local List = {}
	local Data = {}
	Data.Desc = string.format("%s:%s", LSTR(1160006), ScoreMgr.FormatScore(string.format("%d", CompanySealMax)))
	Data.IsLeft = true
	table.insert(List, Data)
	self.LeftRankList:UpdateByValues(List)
end

function CompanySealPromotionWinVM:UpdateRightRankList(Cfg)
	local List = {}
	for i = 1, #Cfg.ShowDesc do
		local Data = {}
		Data.IsLeft = false
		Data.Desc = Cfg.ShowDesc[i]
		Data.IsUnlock = Cfg.IsUnlock[i]
		Data.IsUp = Cfg.IsUp[i]
		table.insert(List, Data)
	end
	self.RightRankList:UpdateByValues(List)
end

function CompanySealPromotionWinVM:SetImgState(GrandCompanyID)
	self.GrandImg1 = GrandCompanyID == 1
	self.GrandImg2 = GrandCompanyID == 2
	self.GrandImg3 = GrandCompanyID == 3
	local ScoreID = CompanySealMgr:GetScoreInfo()
	local ScoreIcon = ScoreMgr:GetScoreIconName(ScoreID)
	self.IconTicket = ScoreIcon
end

function CompanySealPromotionWinVM:IsEqualVM()
end


return CompanySealPromotionWinVM