local LuaClass = require("Core/LuaClass")
local UIBindableList = require("UI/UIBindableList")
local MajorUtil = require("Utils/MajorUtil")

local ProtoCommon = require("Protocol/ProtoCommon")
local MemVM = require("Game/PWorld/Team/PWorldTeamMemberVM")
local PWorldTeamMemExpelVM = require("Game/PWorld/Team/PWorldTeamMemExpelVM")

local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local OpDef = PWorldQuestDefine.OpDef
local ATeamVM = require("Game/Team/Abs/ATeamVM")
local ProfUtil = require("Game/Profession/ProfUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local PWorldHelper = require("Game/PWorld/PWorldHelper")

local SceneModeDef = ProtoCommon.SceneMode

---@class PWorldTeamVM : ATeamVM
local PWorldTeamVM = LuaClass(ATeamVM)

---@deprecated #TODO DELETE IT, replace with PWorldTeamVM:GetDeclaredOwnerMgr instead
local PWorldTeamMgr

function PWorldTeamVM:Ctor()
    self.Mems = UIBindableList.New(MemVM)
    self.MemsNoMj = UIBindableList.New(MemVM)
    self.MemCnt = 0

    self.MatchMems = UIBindableList.New(PWorldTeamMemExpelVM)
    self.MatchMemCount = 0

    self.MemCntGiveUp = 0
    self.GiveUpDesc = ""
    self.HasVoteGiveUp = false
    self.VoteOpGiveUpAccept = false
    self.VoteGiveUpCounter = 0
    self.VoteGiveUpCounterDescNew = ""

    self.MemCntExile = 0
    self.ExileDesc = ""
    self.HasVoteExile = false
    self.VoteOpExileAccept = false
    self.VoteExileCounter = 0
    self.VoteExileCounterDesc = ""

    self.BestPlayerIDVoted = false
    self.ExpelPlayerIDVoted = false

    self.IsSupplementing = false

    self.ExileMemName = ""
end

function PWorldTeamVM:OnInit()
    PWorldTeamMgr = _G.PWorldTeamMgr

	self.Super.OnInit(self)
end

function PWorldTeamVM:OnBegin()
	self.Super.OnBegin(self)
end

function PWorldTeamVM:OnEnd()
	self.Super.OnEnd(self)
end

function PWorldTeamVM:OnShutdown()
	self.Super.OnShutdown(self)
end

function PWorldTeamVM:OnEnterMap()
	local Mode = _G.PWorldMgr:GetMode()
    self.IsShowBtnBar = Mode ~= SceneModeDef.SceneModeStory
end

function PWorldTeamVM:UpdateVM()
    local IDList = self:GetDeclaredOwnerMgr():GetMemIDList()
    self.Mems:UpdateByValues(IDList)
    self.MemCnt = #IDList

    local MatchMemIDList = {}
    local IDsNoMajor = {}
    local MajorID = MajorUtil.GetMajorRoleID()
    for _, ID in pairs(IDList) do
        if ID ~= MajorID and (not _G.TeamMgr:IsTeamMemberByRoleID(ID)) then
            table.insert(MatchMemIDList, ID)
        end
        if ID ~= MajorID then
            table.insert(IDsNoMajor, ID)
        end
    end
    self.MatchMems:UpdateByValues(MatchMemIDList)
    self.MatchMemCount = #MatchMemIDList
    if not table.contain(MatchMemIDList, self.ExpelPlayerIDVoted) then
        self:SetExpelPlayer(nil)
        self:ClearMatchMembersSelection()
    end

    self:UpdateTeamMembers(table.shallowcopy(self:GetDeclaredOwnerMgr().MemberList or {}, false))
    self.MemsNoMj:UpdateByValues(IDsNoMajor)
    self:UpdVoteGiveUp()
end

-------------------------------------------------------------------------------------------------------
---@see Override
function PWorldTeamVM:UpdateTeamMembers(ListMember)
	self.Super.UpdateTeamMembers(self, ListMember)
end

function PWorldTeamVM:GetMainTeamMemSort()
	return ProfUtil.SortByProfID
end
local function SimpleMemSort(a, b)
    if a.ProfID ~= b.ProfID then
        return ProfUtil.SortByProfID(a, b)
    end

    return a.SortID < b.SortID
end

function PWorldTeamVM:GetSimpleMemSort()
	return SimpleMemSort
end

-- Vote
function PWorldTeamVM:UpdGiveUpDesc()
    self.GiveUpDesc = string.format("<span color=\"#FFFFFF\">%d</> / %d", self.MemCntGiveUp, self.MemCnt)
end

function PWorldTeamVM:UpdMemCntGiveUp()
    self.MemCntGiveUp = PWorldTeamMgr:GetMemHasVoteGiveUpCnt() or 0
    self:UpdGiveUpDesc()
end

function PWorldTeamVM:UpdExileDesc()
    local MemCnt = PWorldTeamMgr:GetMemExileVoteCnt()
    self.ExileDesc = string.format("<span color=\"#FFFFFF\">%d</> / %d", self.MemCntExile, MemCnt)
end

function PWorldTeamVM:UpdMemCntExile()
    self.MemCntExile = PWorldTeamMgr:GetMemHasVoteExileCnt() or 0
    self:UpdExileDesc()
end

function PWorldTeamVM:UpdCounterGiveUp()
    self.VoteGiveUpCounter = self:GetDeclaredOwnerMgr():GetVoteGiveupRemainTime()
    self.VoteGiveUpCounterDescNew =  string.sformat(PWorldHelper.GetPWorldText("GIVEUP_COUNTDOWN"), self.VoteGiveUpCounter)
end

function PWorldTeamVM:UpdCounterExile()
    self.VoteExileCounter = self:GetDeclaredOwnerMgr():GetVoteExpelRemainTime()
    self.VoteExileCounterDesc = string.sformat(PWorldHelper.GetPWorldText("EXPEL_COUTDOWN"), self.ExileMemName, self.VoteExileCounter)
end

-------------------------------------------------------------------------------------------------------
---@see Public
function PWorldTeamVM:UpdCounter()
    self:UpdCounterGiveUp()
    self:UpdCounterExile()
end

function PWorldTeamVM:SetSupplement(V)
    self.IsSupplementing = V
end

function PWorldTeamVM:UpdVoteGiveUp()
    self.HasVoteGiveUp = PWorldTeamMgr:HasMajorVoteGiveUp()
    self.VoteOpGiveUpAccept = PWorldTeamMgr:GetMajorVoteOpGiveUp() == OpDef.Accept
    self:UpdMemCntGiveUp()
end

function PWorldTeamVM:UpdVoteExile()
    self.HasVoteExile = PWorldTeamMgr:HasMajorVoteExile()
    self.VoteOpExileAccept = PWorldTeamMgr:GetMajorVoteOpExile() == OpDef.Accept
    self:UpdMemCntExile()
end

function PWorldTeamVM:UpdExileMemName()
    local ExileMemID = PWorldTeamMgr.ExileMemID
    if not ExileMemID then
        self.ExileMemName = ""
        return
    end
    local RoleVM = _G.RoleInfoMgr:FindRoleVM(ExileMemID)
    if not RoleVM then
        self.ExileMemName = ""
        return
    end
    self.ExileMemName = RoleVM.Name
end

function PWorldTeamVM:UpdVoteMVPEnbale()
    local UdFunc = function(BinderList)
        local Items = BinderList:GetItems()
        for _, Item in pairs(Items) do
            Item:UpdMVPVoteEnable()
        end
    end

    UdFunc(self.Mems)
    UdFunc(self.MemsNoMj)
end

function PWorldTeamVM:ClearMatchMembersSelection()
    local Items = self.MatchMems:GetItems()
    for _, Item in pairs(Items) do
        Item:SetSelected(false)
    end
end

function PWorldTeamVM:ClearMembersSelection()
    local ClFunc = function(BinderList)
        local Items = BinderList:GetItems()
        for _, Item in pairs(Items) do
            Item:SetSelected(false)
        end
    end

    ClFunc(self.Mems)
    ClFunc(self.MemsNoMj)
end

function PWorldTeamVM:SetVoteBestPlayer(ID)
    self.BestPlayerIDVoted = ID or false
end

function PWorldTeamVM:SetExpelPlayer(ID)
    self.ExpelPlayerIDVoted = ID or false
end

function PWorldTeamVM:GetMatchMemberCount()
    return self.MatchMems:Length()
end

---@return PWorldTeamMgr | nil
function PWorldTeamVM:GetDeclaredOwnerMgr()
    return self:GetOwnerMgr()
end

return PWorldTeamVM
