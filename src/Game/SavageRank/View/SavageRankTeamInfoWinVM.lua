--
-- Author: ds_yangyumian
-- Date: 2024-12-24 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local SavageRankInfoPlayerItemVM = require("Game/SavageRank/View/Item/SavageRankInfoPlayerItemVM")


---@class SavageRankTeamInfoWinVM : UIViewModel
local SavageRankTeamInfoWinVM = LuaClass(UIViewModel)

---Ctor
function SavageRankTeamInfoWinVM:Ctor()
	self.CurTeamList = UIBindableList.New(SavageRankInfoPlayerItemVM)
    self.RankNumber = nil
    self.EquipLvText = nil
    self.TimeText = nil
    self.RankIcon = nil
    self.ImgBadgeVisible = nil
    self.ImgNormalVisible = nil
    self.PassDate = nil
	self.DateText = nil
end

function SavageRankTeamInfoWinVM:OnInit()

end

function SavageRankTeamInfoWinVM:OnBegin()

end

function SavageRankTeamInfoWinVM:OnEnd()

end

---UpdateVM
---@param List table
function SavageRankTeamInfoWinVM:UpdateVM(List)

end

function SavageRankTeamInfoWinVM:UpdateInfo(List)
	self.RankNumber = List.Rank
	self.EquipLvText = List.EquipLv
	self.TimeText = List.Time
    local PassDate = List.PassDate
    local TimeScond = math.floor(PassDate / 1000)
	self.DateText = os.date("%Y/%m/%d %H:%M", TimeScond)
	self:SetRankIcon(List.Rank, List.RankIcon)
    local TeamInfolist = {}
    for _, Info in pairs(List.TeamList) do
        local Data = {}
        Data.RoleID = Info.RoleID
        Data.ProfClass = Info.ProfClass
        Data.Prof = Info.Prof
        Data.Lv = Info.Level
        Data.EquipLevel = Info.EquipLevel
        table.insert(TeamInfolist, Data)
    end
	self:UpdateTeamList(TeamInfolist)
end

function SavageRankTeamInfoWinVM:SetRankIcon(Rank, Icon)
	    if Rank > 0 and Rank <= 3 then
        self.ImgBadgeVisible = true
        self.ImgNormalVisible = false
        self.RankIcon = Icon
    else
        self.ImgBadgeVisible = false
        self.ImgNormalVisible = true
    end
end

function SavageRankTeamInfoWinVM:UpdateTeamList(List)
    local TeamInfo = _G.SavageRankMgr:GetSortProfList(List)
	self.CurTeamList:UpdateByValues(TeamInfo)
end

function SavageRankTeamInfoWinVM:IsEqualVM(Value)
end


return SavageRankTeamInfoWinVM