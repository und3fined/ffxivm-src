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
local CompanySealInfoListItemVM = require("Game/CompanySeal/View/Item/CompanySealInfoListItemVM")


local CompanyType = ProtoRes.grand_company_type
local LSTR = _G.LSTR
local GrandCompanyImg = {
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_Flag_TheMaelstrom.UI_CompanySeal_Img_Flag_TheMaelstrom'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_Flag_TheOrderoftheTwinAdder.UI_CompanySeal_Img_Flag_TheOrderoftheTwinAdder'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_Flag_TheImmortalFlames.UI_CompanySeal_Img_Flag_TheImmortalFlames'",
}

---@class CompanySealInfoWinVM : UIViewModel
local CompanySealInfoWinVM = LuaClass(UIViewModel)

---Ctor
function CompanySealInfoWinVM:Ctor()
	self.RankList = UIBindableList.New(CompanySealInfoListItemVM) 
	self.TitleText = nil
	self.LeftDesc = nil
	self.TextLevel = LSTR(1160049)--级别
	self.TextMilitaryRank = LSTR(1160009)--军衔
	self.TextCompanySeal = LSTR(1160006)--军票上限
	self.TextCondition = LSTR(1160040)--晋升条件
	self.TextPrivilege = LSTR(1160069)--军衔特权
	self.GrandIcon = nil
	self.TitleText = nil
	self.CurrentrankDes = nil
	self.RankIcon = nil
	self.RankLevel = nil
	self.CurAmount = nil
	self.SealIcon = nil
	self.TextMoneyDes = nil
	self.LockIconVisible = nil
	self.RightInfoVisible = nil
	self.ArmyLogo = nil
	self.ArmyBG = nil
end

function CompanySealInfoWinVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealInfoWinVM:UpdateVM()

end

function CompanySealInfoWinVM:UpdateRankListInfo(List)
	if List == nil then
		return
	end

	self.RankList:UpdateByValues(List)
end

function CompanySealInfoWinVM:UpdateTextInfo(GrandCompanyID)
	local RankInfo = CompanySealMgr:GetCompanySealInfo()
	self.GrandIcon = GrandCompanyImg[GrandCompanyID]
	self.RankIcon = GrandCompanyImg[GrandCompanyID]
	local Name = ProtoEnumAlias.GetAlias(CompanyType, GrandCompanyID)
	self.TitleText = string.format("%s%s", Name, LSTR(1160010))
	self.RightInfoVisible = true
	self.LockIconVisible = false

	self.ArmyLogo = CompanySealMgr:GetLogoPath(CompanySealMgr.CurOpenRankID)
	self.ArmyBG = CompanySealMgr:GetBgPath(CompanySealMgr.CurOpenRankID)
	local CompanysealInfo = CompanySealMgr.CompanyRankList and CompanySealMgr.CompanyRankList[CompanySealMgr.CurOpenRankID]
	local MilitaryLv = CompanySealMgr:GetMilitaryLvByGrandCompanyID(GrandCompanyID)
	local CompanySealMax = 0
	if CompanysealInfo and CompanysealInfo[MilitaryLv] then
		self.RankLevel = CompanysealInfo[MilitaryLv].RankName
		CompanySealMax = CompanysealInfo[MilitaryLv].CompanySealMax
	else
		FLOG_ERROR("CompanysealInfo NIL")
	end

	if GrandCompanyID == _G.CompanySealMgr.GrandCompanyID then
		self.LeftDesc = string.format("<span color=\"#d5d5d5\">%s</><span color=\"#d1ba8e\">%s%s</><span color=\"#d5d5d5\">%s</>", LSTR(1160043), Name, LSTR(1160004), LSTR(1160024))  --满足对应条件后，可在 处晋升军衔
		self.CurrentrankDes = LSTR(1160066) --当前军衔
	else
		if RankInfo.MilitaryLevelList[GrandCompanyID] and RankInfo.MilitaryLevelList[GrandCompanyID] > 0 then
			self.LeftDesc = string.format("<span color=\"#d5d5d5\">%s</><span color=\"#d1ba8e\">【%s】</> , %s", LSTR(1160031), Name, LSTR(1160065))--您当前暂未加入  ，重新加入后可恢复历史军衔
			self.LockIconVisible = true
			self.CurrentrankDes = LSTR(1160067) --历史军衔
		else
			self.LeftDesc = string.format("<span color=\"#d5d5d5\">%s</><span color=\"#d1ba8e\">【%s】</>", LSTR(1160031), Name)--您当前暂未加入  
			self.RightInfoVisible = false
		end
	end

	self.TextMoneyDes = LSTR(1160068) --持有军票：
	local ScoreID = CompanySealMgr:GetScoreInfoByID(GrandCompanyID)
	local Max = CompanySealMax
	local Limit = ScoreMgr.FormatScore(Max)
	local CurHas = ScoreMgr:GetScoreValueByID(ScoreID)
	local Cur = ScoreMgr.FormatScore(CurHas)
	self.CurAmount = string.format("%s/%s", Cur, Limit)

end

function CompanySealInfoWinVM:OnBegin()

end

function CompanySealInfoWinVM:OnEnd()

end


return CompanySealInfoWinVM