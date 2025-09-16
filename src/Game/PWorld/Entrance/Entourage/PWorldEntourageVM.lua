local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PWorldEntourageConfirmMemVM  = require("Game/PWorld/Entrance/Entourage/PWorldEntourageConfirmMemVM")
local PWorldEntourageMemVM = require("Game/PWorld/Entrance/Entourage/PWorldEntourageMemVM")

local PWorldRewardVM = require("Game/PWorld/Entrance/ItemVM/PWorldRewardVM")
local PWorldEntEntityVM = require("Game/PWorld/Entrance/PWorldEntEntityVM")

local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local UIBindableList = require("UI/UIBindableList")

local SceneEncourageCfg = require("TableCfg/SceneEncourageCfg")
local SceneEncourageTeamCfg = require("TableCfg/SceneEncourageTeamCfg")
local SceneEncourageNpcCfg = require("TableCfg/SceneEncourageNpcCfg")
local PworldCfg = require("TableCfg/PworldCfg")

local ProtoCommon = require("Protocol/ProtoCommon")
local ScenePoolType = ProtoCommon.ScenePoolType

local Func_TYPE = ProtoCommon.function_type

local ProfUtil = require("Game/Profession/ProfUtil")

local MajorUtil = require("Utils/MajorUtil")

local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local PWorldHelper = require("Game/PWorld/PWorldHelper")

---@class PWorldEntourageVM :UIViewModel
---@field Policy PWorldEntPolNM
local PWorldEntourageVM = LuaClass(UIViewModel)

function PWorldEntourageVM:Ctor()
    self.EntCfg = nil

    self.MemList = UIBindableList.New(PWorldEntourageMemVM)
    self.RewardList = UIBindableList.New(PWorldRewardVM)
    self.EntList = UIBindableList.New(PWorldEntEntityVM)

    self:SetEntIdx(0, {ID=0})

    self.PWorldTy = ScenePoolType.ScenePoolChallenge

    --- Info
    self.PWorldRequireLv         = 0
    self.PWorldRequireEquipLv    = 0

    --- View
    -- Title
    self.PWorldIcon = ""
    self.PWorldName = ""
    self.BG = ""

    -- TopBar
    self.Infor = ""
    self.Summary = ""

    -- Join Infp
    self.LvTips = ""
    self.EquipTips = ""
    self.CanJoin = false
    self.JoinTips = ""
    -- join booleans
    self.bPassLv = false
    self.bPassEquip = false

    -- Visible
    self.IsShowCommMask = false
    self.IsShowInfor = false
    self.IsShowSummary = false

    -- Confirm Panel
    self.ConfirmViewBG = ""
    self.ConfirmViewName = ""
    self.ConfirmViewLevel = 1
    self.ConfirmViewLevelDesc = ""
    self.ConfirmMemList = UIBindableList.New(PWorldEntourageConfirmMemVM)
    self.ConfirmReadyCnt =3
    self.ConfirmIsMajorReady = false
    self.ConfirmModel = 1
    self.ConfirmMemCnt = 0

    self.ForbidText = ""
end

function PWorldEntourageVM:OnInit()
    self.Policy = require("Game/PWorld/Entrance/Policy/PWorldEntPolNM")
end

function PWorldEntourageVM:UpdateEntInfo()
    local Info = self.Policy:GetEntInfo(self.CurEntID)
    self.EntCfg                  = Info.EntCfg 
    -- self.PWorldID                = Info.PWorldID
    self.BG                      = Info.BG
    self.PWorldName              = Info.PWorldName
    -- self.MaxMatchCnt             = Info.MaxMatchCnt
    self.PWorldRequireLv         = Info.PWorldRequireLv
    self.PWorldRequireEquipLv    = Info.PWorldRequireEquipLv
    self.IsChocoboRandomTrack    = Info.IsChocoboRandomTrack


    self.Infor = self.EntCfg.Explain
    self.Summary =self.EntCfg.Summary

    if Info.CombatCfg then
       self.EquipSyncLv =  Info.CombatCfg.EquipMaxLv or 0
    else
       self.EquipSyncLv = 0
    end

    local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
    self.PWorldIcon = (SceneEnterTypeCfg:FindCfgByKey(self.EntCfg.TypeID) or {}).Icon or ""
end

function PWorldEntourageVM:OnMainPanelShow(InEntID)
    self:UpdateEntList()
    local EntID = InEntID or _G.PWorldEntDetailVM.CurEntID
    self:SetEntByID(EntID)
end

function PWorldEntourageVM:UpdateVM()
    self:UpdateEntList()
    self:UpdateCurEntInfo()
end

function PWorldEntourageVM:UpdateCurEntInfo()
    if self.CurEntID == nil or self.CurEntID == 0 then
       return 
    end

    -- 
    self:UpdateEntInfo()

    -- rewards
    self:UpdateRewards()

    -- update tips
    self:UpdateJoinInfo()

    -- Update Mems
    self:UpdateMemList()

    self:UpdateConfirmInfo()
end

-------------------------------------------------------------------------------------------------------
---@see Update

function PWorldEntourageVM:UpdateConfirmInfo()
    -- local EntCfg = SceneEnterCfg:FindCfgByKey(self.CurEntID)
    local ConfirmMemListData = {}
    table.insert(ConfirmMemListData, {IsMajor = true})
    for _, Mem in pairs(self.MemListData) do
        table.insert(ConfirmMemListData, Mem)
    end
    self.ConfirmMemList:UpdateByValues(ConfirmMemListData)
    self.ConfirmReadyCnt = #ConfirmMemListData - 1
    self.ConfirmMemCnt = #ConfirmMemListData
    self.ConfirmIsMajorReady = false
    self.ConfirmModel = 1
    self.IsMem4 = #ConfirmMemListData <= 4
    local Cfg = PworldCfg:FindCfgByKey(self.CurEntID)
    if Cfg then
        self.ConfirmViewBG = Cfg.PWorldBanner2
        self.ConfirmViewName = Cfg.PWorldName
        self.ConfirmViewLevel = Cfg.PlayerLevel
        self.ConfirmViewLevelDesc = string.sformat(_G.LSTR(1320078), self.ConfirmViewLevel)
    end
end

function PWorldEntourageVM:MatchMemListData(MemListData, EntID)
    local Ret = {}

    local MajorVM = MajorUtil.GetMajorRoleVM()
    local EntCfg = SceneEnterCfg:FindCfgByKey(EntID)

    if EntCfg and MajorVM and MajorVM.Prof then
        local MajorProf = MajorVM.Prof
        local ReqFuncs = PWorldEntUtil.GetRequireMemProfFunc(self.CurEntID, self.PWorldTy)
        local ReqCnt = PWorldEntUtil.GetRequireMemCnt(self.CurEntID, self.PWorldTy) - 1
        local MajorFunc = ProfUtil.Prof2Func(MajorProf)
        -- if major is not combat prof, let major be attack prof 
        if not ProfUtil.IsCombatProf(MajorProf) then
            MajorFunc = Func_TYPE.FUNCTION_TYPE_ATTACK
        end
        -- eliminate major's func
        if ReqFuncs[MajorFunc] and ReqFuncs[MajorFunc] > 0 then
            ReqFuncs[MajorFunc] = ReqFuncs[MajorFunc] - 1
        else
            _G.FLOG_ERROR("zhg PWorldEntourageVM:UpdateMemList cfg logic err")
        end
        -- pick up NPCS that are needed 
        for _, Item in pairs(MemListData) do
            local MemFunc = ProfUtil.Prof2Func(Item.ProfID)
            if ReqFuncs[MemFunc] and ReqFuncs[MemFunc] > 0 and ReqCnt > 0 then
                ReqFuncs[MemFunc] = ReqFuncs[MemFunc] - 1
                ReqCnt = ReqCnt - 1
                table.insert(Ret, Item)
            end
        end
    else
        _G.FLOG_ERROR("zhg PWorldEntourageVM:UpdateMemList err EntCfg or MajorVM or MajorVM.Prof")
    end

    return Ret
end

-- member list
function PWorldEntourageVM:UpdateMemList()
    local MemListData = self:GenMemList(self.CurEntID)
    self.MemListData = MemListData
    self.MemList:Clear()
    self.MemList:UpdateByValues(MemListData)
end

function PWorldEntourageVM:GenMemList(EntID)
    local Cfg = SceneEncourageTeamCfg:FindCfgByKey(EntID)
    local MemListData = {}
    if Cfg then
        for _, V in pairs(Cfg.PlotAsstNpcID or {}) do
            local Cfg = SceneEncourageNpcCfg:FindCfgByKey(V)
            if Cfg then
                table.insert(MemListData, {ID = V, ProfID = Cfg.ProfType})
            end
        end

        MemListData = self:MatchMemListData(MemListData, EntID)
        table.sort(MemListData, ProfUtil.SortByProfID)
    end

    return MemListData
end

-- entrance list
local function EntSort(a, b)
    if a.Priority and b.Priority then
        return a.Priority < b.Priority
    end

    return false
end

function PWorldEntourageVM:FetchEntListInfo()
    local EntListData = {}
    for _, Item in pairs(SceneEncourageCfg:FindAllCfg() or {}) do
        if self.Policy:CheckFilter(Item.SceneID) then
            table.insert(EntListData, {ID = Item.SceneID, Priority = Item.ID, bNotShowMatch=true})
        end
    end

    table.sort(EntListData, EntSort)
    return EntListData
end

function PWorldEntourageVM:UpdateEntList()
    self.EntList:UpdateByValues(self:FetchEntListInfo())
end

function PWorldEntourageVM:SetEntIdx(Idx, ItemData)
    self.CurEntIdx = Idx
    self:SetCurEntID(ItemData.ID)
end

function PWorldEntourageVM:SetEntByID(EntID)
    local Index = 1
    local ItemData = nil
    for Idx, Item in ipairs(self.EntList:GetItems()) do
        if Item.ID == EntID then
           Index = Idx
           ItemData = Item
           break
        end
    end

    if ItemData then
       self:SetEntIdx(Index, ItemData) 
    else
       _G.FLOG_ERROR("PWorldEntourageVM:SetEntByID invalid EntID: %s %s", EntID, debug.traceback()) 
    end
end

---@private
function PWorldEntourageVM:SetCurEntID(ID)
    local bChanged = self.CurEntID ~= ID
    self.CurEntID = ID
    if bChanged and self.CurEntID and self.CurEntID ~= 0 then
        self:UpdateCurEntInfo()
    end
end

-- rewards
function PWorldEntourageVM:UpdateRewards()
    -- 查询时，还未初始化
    if not self.Policy then
        return
    end

    self.RewardsData = self.Policy:GetRewardData(self.EntCfg)
    self.RewardList:UpdateByValues(self.RewardsData)
end

-- desc
local ReqDescCol = {
    Succ = "#D5D5D5FF",
    Fail = "#DC5868FF",
}

local GetColorReqDesc = function(Desc, Cond)
    local Col = Cond and ReqDescCol.Succ or ReqDescCol.Fail

    return string.format("<span color=\"%s\">%s</>", Col, Desc)
end

-- 职业等要求tips
function PWorldEntourageVM:UpdateJoinInfo()
    if self.CurEntID == nil or self.CurEntID == 0 then
       return 
    end

    self.ForbidText = _G.LSTR(1320006)
    local IsPass, RltInfo = self.Policy:CheckJoinPre(self.CurEntID)
    RltInfo = RltInfo or {}
    self.RltInfo = RltInfo
    local ReqLv = self.PWorldRequireLv
    self.LvTips = string.sformat(_G.LSTR(1320079), ReqLv)
    self.bPassLv = RltInfo.IsPassLv
    self.LvTips = GetColorReqDesc(self.LvTips, self.bPassLv)
    -- equip
    self.bPassEquip = RltInfo.IsPassEquipLv
    self.EquipTips = PWorldHelper.pformat("PWOLRD_EQUILP_LIMIT_FULL", self.PWorldRequireEquipLv, self.EquipSyncLv)
    self.EquipTips = GetColorReqDesc(self.EquipTips, self.bPassEquip)

    self.CanJoin = IsPass

    if not RltInfo.IsPassMem then
        self.JoinTips = _G.LSTR(1320080)
    elseif not self.bPassLv then
        self.JoinTips = _G.LSTR(1320081)
    elseif not self.bPassEquip then
        self.JoinTips = _G.LSTR(1320082)
    end

    if _G.TeamMgr:IsInTeam() then
        self.ForbidText = _G.LSTR(1320083)
        self.JoinTips = self.ForbidText
        self.CanJoin = false
    end
end

-------------------------------------------------------------------------------------------------------
---@see Set

function PWorldEntourageVM:SetIsShowInfor(V)
    self.IsShowInfor = V
    self.IsShowCommMask = true
end

function PWorldEntourageVM:SetIsShowSummary(V)
    self.IsShowSummary = V
    self.IsShowCommMask = true
end

function PWorldEntourageVM:SetIsShowCommMask(V)
    self.IsShowCommMask = V

    if not V then
        self.IsShowSummary = false
        self.IsShowInfor = false
    end
end

return PWorldEntourageVM
