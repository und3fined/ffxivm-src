--
-- Author: ds_yangyumian
-- Date: 2024-12-24 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local SavageRankViewItemVM = require("Game/SavageRank/View/Item/SavageRankViewItemVM")
local SavageRankViewRankItemVM = require("Game/SavageRank/View/Item/SavageRankViewRankItemVM")
local SavageRankHeadSlotVM = require("Game/SavageRank/View/Item/SavageRankHeadSlotVM")


---@class SavageRankMainVM : UIViewModel
local SavageRankMainVM = LuaClass(UIViewModel)

---Ctor
function SavageRankMainVM:Ctor()
	self.CurTeamInfoList = UIBindableList.New(SavageRankViewRankItemVM)
	self.CurPworldInfoList = UIBindableList.New(SavageRankViewItemVM)
	self.CurSelfTeamInfoList = UIBindableList.New(SavageRankHeadSlotVM)
	self.SelfLvText = nil
	self.SelfTimeText = nil
	self.SelfRankText = nil
	self.SelfRankIcon = nil
	self.SelfImgBadgeVisible = nil
	self.SelfImgNormalVisible = nil
	self.BgImg = nil
	self.SelfBgImg = nil
end

function SavageRankMainVM:OnInit()

end

function SavageRankMainVM:OnBegin()

end

function SavageRankMainVM:OnEnd()

end

---UpdateVM
---@param List table
function SavageRankMainVM:UpdateVM(List)

end

function SavageRankMainVM:UpdateTeamInfo(List)
	local _ <close> = _G.CommonUtil.MakeProfileTag("SavageRankMainVM:UpdateTeamInfo")
	self.CurTeamInfoList:UpdateByValues(List, nil, true)
end

function SavageRankMainVM:UpdatePworldInfo(List)
	self.CurPworldInfoList:UpdateByValues(List)
end

function SavageRankMainVM:UpdateSelfTeamInfo(List)
	self:SetSelfTeamInfo(List)
	local HeadList = _G.SavageRankMgr:GetSortProfList(List.TeamInfo.TeamMembers)
	self.SelfLvText = self:GetAverageLv(HeadList)
	self.CurSelfTeamInfoList:UpdateByValues(HeadList)
end

function SavageRankMainVM:UpdateBgImg(Index)
	local Cfg = _G.SavageRankMgr:GetSavageRankCfg()
	if Cfg then
		self.BgImg = Cfg[Index].BG
	end
end

function SavageRankMainVM:SetSelfTeamInfo(List)
	local TimeStamp = List.TeamInfo.ElapsedTime
    self.SelfTimeText = _G.SavageRankMgr:GetElapsedTime(TimeStamp)
	local Rank = (List.SendIndex - 1) * 100 + List.RankIndex
	self.SelfRankText = Rank
	if Rank > 0 and Rank <= 3 then
		self.SelfImgBadgeVisible = true
		self.SelfImgNormalVisible = false
        self.SelfRankIcon = _G.SavageRankMgr:GetRankIcon(Rank)
    else
		self.SelfImgBadgeVisible = false
		self.SelfImgNormalVisible = true
    end
	self:SetSelfBgImg(Rank)
end

function SavageRankMainVM:SetSelfBgImg(Rank)
	if Rank < 4 then
        self.BgImg = _G.SavageRankMgr:GetBgImg(Rank)
    else
        self.BgImg = _G.SavageRankMgr:GetBgImg(4)
    end
end

function SavageRankMainVM:GetTeamTimeInfo(TimeStamp)
    local Minutes = math.floor(TimeStamp / 60000)
	TimeStamp = TimeStamp % 60000
    local Seconds = math.floor(TimeStamp / 1000)
	TimeStamp = TimeStamp % 1000
    local Milliseconds = TimeStamp

	if TimeStamp >= 100 then
        Milliseconds = math.floor(TimeStamp / 10)
    end
    local TimeStr = string.format("%2d:%02d.%02d", Minutes, Seconds, Milliseconds)
	return TimeStr
end

function SavageRankMainVM:GetSelfTeamInfo(List)
	local Data = {}
	Data.Rank = (List.SendIndex - 1) * 100 + List.RankIndex
	Data.TimeText = self:GetTeamTimeInfo(List.TeamInfo.ElapsedTime)
	Data.EquipLv = self:GetAverageLv(List.TeamInfo.TeamMembers)
	Data.TeamList = List.TeamInfo.TeamMembers
	Data.RankIcon = _G.SavageRankMgr:GetRankIcon(Data.Rank)
	Data.PassDate = List.TeamInfo.PassTime

	return Data
end

function SavageRankMainVM:GetAverageLv(List)
	local Total = 0
	local Len = #List
	local EquipLevel = 0
	for _, Value in pairs(List) do
		Total = Total + Value.EquipLevel
	end

	EquipLevel = math.floor(Total / Len)
	return EquipLevel
end

function SavageRankViewRankItemVM:IsEqualVM(Value)
end

return SavageRankMainVM