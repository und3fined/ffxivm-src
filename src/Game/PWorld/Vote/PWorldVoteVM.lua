local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")

local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")

local ItemTipsVM = require("Game/Item/ItemTipsVM")
local ItemVM = require("Game/Item/ItemVM")
local PWorldEntranceParentItemVM = require("Game/PWorld/Entrance/ItemVM/PWorldEntranceParentItemVM")
local PWorldVoteMemberVM = require("Game/PWorld/Vote/PWorldVoteMemberVM")

local ProtoRes = require ("Protocol/ProtoRes")
local ProfUtil = require("Game/Profession/ProfUtil")
local MajorUtil = require("Utils/MajorUtil")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local FUNCTION_TYPE = ProtoCommon.function_type
local SceneMode = ProtoCommon.SceneMode


---@class PWorldVoteVM :  UIViewModel
local PWorldVoteVM = LuaClass(UIViewModel)

local LSTR = _G.LSTR

local RoleInfoMgr
local TeamVM
local PWorldVoteMgr

function PWorldVoteVM:Ctor()
    self.VoteMemberVMs = UIBindableList.New(PWorldVoteMemberVM)
    self.ReadyCnt = 0

    -- Scene
    self.SceneBG = ""
    self.SceneName = ""
    self.SceneLevel = 0
    self.SceneLevelDesc = ""
    self.SneceIcon = ""
    self.Model = -1
    self.IsRand = false

    self.IsMem4 = false
    
    self.TypeID = nil
    self.IsPVP = false
    self.IsCrystalline = false -- 纷争前线用不一样的tableview，所以区分一下是PVP的什么模式
end

function PWorldVoteVM:OnInit()
end

function PWorldVoteVM:OnBegin()
    RoleInfoMgr = _G.RoleInfoMgr
    TeamVM = _G.TeamVM
    PWorldVoteMgr = _G.PWorldVoteMgr
end

function PWorldVoteVM:IsEqualVM(_)
    return false
end

function PWorldVoteVM:UpdateVM()
    self:UpdMems()
    self.ReadyCnt = 0
    self:SetMajorReady(false)
    self.Model = PWorldVoteMgr.Model

    local RandomEntID = PWorldVoteMgr.RandomEntID
    self.IsRand = RandomEntID > 0

    if self.IsRand then
        local Cfg = SceneEnterDailyRandomCfg:FindCfgByKey(RandomEntID)
        if not Cfg then
            _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not SceneEnterDailyRandomCfg = %s", tostring(RandomEntID)))
            return
        end

        self.SceneBG = Cfg.PWorldBanner
        self.SceneName = Cfg.Name
        self.SceneLevel = Cfg.PlayerLv
        self.SceneLevelDesc = string.sformat(LSTR(1320078), self.SceneLevel)
    else
        -- Scene
        local SceneID = PWorldVoteMgr:GetEnterSceneID()
        if not SceneID then
            return
        end

        local Cfg = PworldCfg:FindCfgByKey(SceneID)

        if not Cfg then
            _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not Cfg SceneID = %s", tostring(SceneID)))
            return
        end

        local PWECfg = SceneEnterCfg:FindCfgByKey(SceneID)

        if PWECfg then
            local Type = PWECfg.TypeID

            local PWETCfg = SceneEnterTypeCfg:FindCfgByKey(Type)

            if PWETCfg then
                self.SneceIcon = PWETCfg.Icon
                self.TypeID = PWECfg.TypeID
            else
                _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not SceneEnterTypeCfg SceneID = %s", tostring(SceneID)))
            end
        else
            _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not SceneEnterCfg SceneID = %s", tostring(SceneID)))
        end
        
        self.SceneBG = Cfg.PWorldBanner2
        self.SceneName = Cfg.PWorldName
        -- 水晶冲突副本特别处理名字
        if PWECfg then
            if PWorldEntUtil.IsCrystallineExercise(PWECfg.TypeID) then
                self.SceneName = LSTR(1320137)
            elseif PWorldEntUtil.IsCrystallineRank(PWECfg.TypeID) then
                self.SceneName = LSTR(1320138)
            end
        end
        
        --local CurSceneLevel = Cfg.PlayerLevel
        ---- 陆行鸟竞赛
        --if Cfg.SubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_CHOCOBO_RACE then
        --    CurSceneLevel = _G.ChocoboMgr:GetRaceChocoboLevel()
        --end
        
        self.SceneLevel = Cfg.PlayerLevel
        self.SceneLevelDesc = string.sformat(LSTR(1320078), self.SceneLevel)
    end
end

function PWorldVoteVM:SetReady(RoleID, V)
    local Mem = self:FindMem(RoleID)
    if Mem then
        Mem:SetReady(V)
    end

    self.ReadyCnt = self:GetReadyCnt()
    if RoleID == MajorUtil.GetMajorRoleID() and RoleID ~= nil then
        self:SetMajorReady(V)
    end
end

function PWorldVoteVM:SetMajorReady(V)
    self.IsMajorReady = V
    local SidebarDefine = require("Game/Sidebar/SidebarDefine")
    local SideBarVM = _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.PWorldEnterConfirm)
    if SideBarVM then
        SideBarVM:SetTips(V and LSTR(1320094) or LSTR(1320085))
    end
end

function PWorldVoteVM:GetHasReady(RoleID)
    local Mem = self:FindMem(RoleID)
    return Mem and Mem.HasReady
end

function PWorldVoteVM:GetReadyCnt()
    local Items = self.VoteMemberVMs:GetItems() or {}

    local Cnt = 0
    for _, Item in pairs(Items) do
        if Item.HasReady then
            Cnt = Cnt + 1
        end
    end

    return Cnt
end

function PWorldVoteVM:GetMemCnt()
    local Len = self.VoteMemberVMs:Length()
    return Len
end

---@private
function PWorldVoteVM:FindMem(RoleID)
    local Mem = self.VoteMemberVMs:Find(function(Item)
        return Item.RoleID == RoleID and RoleID ~= nil and RoleID ~= 0
    end)

    return Mem
end

function PWorldVoteVM:UpdMems()
    local Mems = PWorldVoteMgr:GetEnterSceneRoleInfos() or {}
    if #Mems <= 0 then
        return
    end

    local IsCrystalline = PWorldVoteMgr:GetCurPollType() == ProtoCS.PollType.PoolType_CrystalConflict
    local IsFrontline = false -- 后续纷争前线使用
    self.IsPVP = IsCrystalline or IsFrontline
    self.IsCrystalline = IsCrystalline
    self.IsMem4 = #Mems <= 4

    -- 水晶冲突把自己放第一位，如果后续纷争前线也需要可以改成用IsPVP
    if IsCrystalline then
        local MajorID = MajorUtil.GetMajorRoleID()
        local function SortFunc(Actor1, Actor2)
            if Actor1 and Actor1.ActorID == MajorID then
                return true
            end
            return false
        end
        table.sort(Mems, SortFunc)
    end

    self.VoteMemberVMs:UpdateByValues(Mems or {})
    self:UpdateTeamProfInfo()
end

function PWorldVoteVM:UpdateTeamProfInfo()
    for _, Item in ipairs(self.VoteMemberVMs:GetItems()) do
        if Item.IsTeamMateOrMajor then
            Item:SetSyncProf(_G.TeamMgr:GetTeamMemberProf(Item.RoleID))
            Item:SetSyncLevel(_G.TeamMgr:GetTeamMemberLevel(Item.RoleID))
        end
    end
end

return PWorldVoteVM