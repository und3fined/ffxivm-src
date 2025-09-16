local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SavageRankHeadSlotVM = require("Game/SavageRank/View/Item/SavageRankHeadSlotVM")
local UIBindableList = require("UI/UIBindableList")

---@class SavageRankViewRankItemVM : UIViewModel
local SavageRankViewRankItemVM = LuaClass(UIViewModel)

---Ctor
function SavageRankViewRankItemVM:Ctor()
    self.CurHeadList = UIBindableList.New(SavageRankHeadSlotVM)
    self.RankNumber = nil
    self.TopThreeNumber = nil
    self.EquipLvText = nil
    self.TimeText = nil
    self.RankIcon = nil
    self.ImgBadgeVisible = nil
    self.ImgNormalVisible = nil
    self.PassDate = nil
    self.TeamInfo = nil
    self.BgImg = nil
    self.RankNumberVisible = nil
    self.TopThreeNumberVisible = nil
end

function SavageRankViewRankItemVM:OnInit()

end
 
---UpdateVM
---@param List table
function SavageRankViewRankItemVM:UpdateVM(List)
    local _ <close> = _G.CommonUtil.MakeProfileTag("SavageRankViewRankItemVM:UpdateVM")
    local TeamInfo = _G.SavageRankMgr:GetSortProfList(List.TeamInfo)
    self:UpdateHeadList(TeamInfo)
    self:UpdateInfo(List)
end

function SavageRankViewRankItemVM:UpdateHeadList(List)
    local _ <close> = _G.CommonUtil.MakeProfileTag("UpdateHeadList")
    self.CurHeadList:UpdateByValues(List, nil, true)
end

function SavageRankViewRankItemVM:UpdateInfo(List)
    self.RankNumber = List.Rank
    self.EquipLvText = List.EquipLevel
    self.TimeText = _G.SavageRankMgr:GetElapsedTime(List.ElapsedTime)
    self.TeamInfo = List.TeamInfo
    self.PassDate = List.PassTime
    self:SetRankIcon(List.Rank)
    self:SetBGImg(List.Rank)
end

function SavageRankViewRankItemVM:SetBGImg(Rank)
    if Rank < 4 then
        self.TopThreeNumber = Rank
        self.TopThreeNumberVisible = true
        self.RankNumberVisible = false
        self.BgImg = _G.SavageRankMgr:GetBgImg(Rank)
    else
        self.RankNumber = Rank
        self.TopThreeNumberVisible = false
        self.RankNumberVisible = true
        self.BgImg = _G.SavageRankMgr:GetBgImg(4)
    end
end

function SavageRankViewRankItemVM:SetRankIcon(Rank)
    if Rank > 0 and Rank <= 3 then
        self.ImgBadgeVisible = true
        self.ImgNormalVisible = false
        self.RankIcon = _G.SavageRankMgr:GetRankIcon(Rank)
    else
        self.ImgBadgeVisible = false
        self.ImgNormalVisible = true
    end
end

function SavageRankViewRankItemVM:IsEqualVM(Value)
end

return SavageRankViewRankItemVM