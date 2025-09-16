---
--- Author: stellahxhu
--- DateTime: 2022-07-07 12:56:49
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TeamRecruitItemVM = require("Game/TeamRecruit/VM/TeamRecruitItemVM")
local TeamRecruitDetailVM = require("Game/TeamRecruit/VM/TeamRecruitDetailVM")
local TeamRecruitTypeVM = require("Game/TeamRecruit/VM/TeamRecruitTypeVM")
local TeamRecruitProfVM = require("Game/TeamRecruit/VM/TeamRecruitProfVM")
local TeamRecruitFuncEditVM = require("Game/TeamRecruit/VM/TeamRecruitFuncEditVM")
local TeamRecruitTypeCfg = require("TableCfg/TeamRecruitTypeCfg")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local UIBindableList = require("UI/UIBindableList")
local PWorldTaskSetUpListItemVM = require("Game/PWorld/Item/PWorldTaskSetUpListItemVM")
local MajorUtil = require("Utils/MajorUtil")

local SceneMode = ProtoCommon.SceneMode
local FunctionType = ProtoCommon.function_type
local TEAM_RECRUIT_PROF = ProtoCommon.team_recruit_prof
local RECRUIT_STATE = ProtoCS.Team.TeamRecruit.RECRUIT_STATE

local FILTER_KEY_ENABLE <const> = "Enable"
local FILTER_KEY_OP <const> = "OP"
local FILTER_KEY_CID <const> = "CID"

---@class TeamRecruitVM : UIViewModel
local TeamRecruitVM = LuaClass(UIViewModel)

local TeamRecruitMgr = nil
local FriendMgr = nil 

function TeamRecruitVM:Ctor()
    self.EditDifficultyVMs = UIBindableList.New((PWorldTaskSetUpListItemVM))
    self.FilterConfigDict = {}
    self.FilterRecruitItemVMList = self:ResetBindableList(self.FilterRecruitItemVMList, TeamRecruitItemVM)
end

function TeamRecruitVM:OnBegin()
    TeamRecruitMgr = _G.TeamRecruitMgr
	FriendMgr = _G.FriendMgr
end

function TeamRecruitVM:OnInit()
    self:Reset()
end

function TeamRecruitVM:OnShutdown()
    self:Reset()
end

function TeamRecruitVM:Reset()
    self.CurSelectRecruitType = nil 
    self.IsRecruiting = false -- 是否在招募中
    self.HasCompleteRecruit = false
    self.ShowProfEditTips = true
    self.ShowProfBubbleTips = true
    self.IsRecruitListEmpty = false 

    self.TeamRecruitTypeVMList = self:ResetBindableList(self.TeamRecruitTypeVMList, TeamRecruitTypeVM)
    self.RecruitItemVMList = self:ResetBindableList(self.RecruitItemVMList, TeamRecruitItemVM)
    self.FuncEditVMList = self:ResetBindableList(self.FuncEditVMList, TeamRecruitFuncEditVM)
    
    --招募详情
    if nil == self.CurRecruitDetailVM then
        self.CurRecruitDetailVM = TeamRecruitDetailVM.New()
    else
        self.CurRecruitDetailVM:Clear() 
    end

    if self.RecruitingDetailVM == nil then
        self.RecruitingDetailVM = TeamRecruitDetailVM.New()
    end

    --招募编辑
    self:ClearEditData()

    self:SetPreSelectTask(nil)

    self.RecruitItemVMList:RegisterUpdateListCallback(self, self.OnItemsUpdate)

    if self.FilterDifficultVMs == nil then
        self.FilterDifficultVMs = UIBindableList.New((PWorldTaskSetUpListItemVM))
    end
    self.FilterDifficultVMs:UpdateByValues({{Op=999},{Op=1},{Op=2},{Op=3},})

    self:ClearFilter()
    self.FilterRecruitItemVMList.Items = {}
    self.ViewingRecruitItemVMList = self.RecruitItemVMList
end

function TeamRecruitVM:Clear()
    if self.FilterRecruitItemVMList then
        self.FilterRecruitItemVMList.Items = {}
    end

    if self.RecruitItemVMList then
        self.RecruitItemVMList:Clear()
    end

    if self.ViewingRecruitItemVMList and self.ViewingRecruitItemVMList ~= self.RecruitItemVMList then
        self.ViewingRecruitItemVMList:Clear()
    end

    self.ViewingRecruitItemVMList = self.RecruitItemVMList
end

function TeamRecruitVM:OnItemsUpdate()
    self:UpdateFilter(self.CurSelectRecruitType)
end

function TeamRecruitVM:ClearEditData()
    self:SetEditRecruitType(nil)
    self:SetEditContentID(nil)
    self:SetEditWeeklyReward(nil)
    self:SetEditCompleteTask(false)
    self.EditQuickTextIDs = {}
    self.TempEditQuickTextIDs = {}
    self.EditReduceQuickTextIDs = {}
    self:SetEditSceneMode(SceneMode.SceneModeNormal)
    self.EditPassword = nil 
    self.EditEquipLv = 0
    self.EditSelectProfVMListIdx = nil 
    self.IsCalcingMembersProf = false
    self.EditMessage = ""

    local OldEditProfList = self.EditProfVMList
    self.EditProfVMList = self:ResetBindableList(self.EditProfVMList, TeamRecruitProfVM)
    self.TempEditProfVMList = self:ResetBindableList(self.TempEditProfVMList, TeamRecruitProfVM)

    if OldEditProfList ~= self.EditProfVMList then
        self.EditProfTotalNum = self.EditProfVMList:Length()
        self.EditProfVMList:RegisterUpdateListCallback(self, function()
            self.EditProfTotalNum = self.EditProfVMList:Length()
        end)
    end
end

function TeamRecruitVM:SetEditRecruitType(TypeID)
    self.EditRecruitType = TypeID
end

function TeamRecruitVM:UpdateEditDiffculty(ContentID)
    local Values = {}
    local Cfg = TeamRecruitCfg:FindCfgByKey(ContentID)
    if Cfg and #(Cfg.RecruitModel or {}) > 0 then
        table.insert(Values, {Op = 1,})
        for _, v in ipairs(Cfg.RecruitModel) do
            table.insert(Values, {Op = v + 1,})
        end
    end

    self.bShowEditDifficulty = #Values > 0
    self.EditDifficultyVMs:UpdateByValues(Values)
end

function TeamRecruitVM:SetEditRecruitTypeByContentID(ContentID)
    local TypeID = (TeamRecruitCfg:FindCfgByKey(ContentID) or {}).TypeID
    if TypeID == nil then
        _G.FLOG_ERROR("can not find type id for content id %s", ContentID)
    end
    self:SetEditRecruitType(TypeID)
end

function TeamRecruitVM:SetEditContentID(ID)
    self.EditContentID = ID
    self:UpdateEditDiffculty(ID)

    self.bShowEditWeeklyReward = TeamRecruitUtil.HasWeeklyRewardConfig(ID)
    if not self.bShowEditWeeklyReward then
       self:SetEditWeeklyReward(false) 
    end
end

function TeamRecruitVM:SetEditSceneMode(Mode)
    self.EditSceneMode = Mode
end

function TeamRecruitVM:SetEditCompleteTask(bComplete)
    self.EditCompleteTask = bComplete
    self:UpdateQuickEditID(4, bComplete)
end

function TeamRecruitVM:SetEditWeeklyReward(Value)
    self.EditWeeklyAward = Value
    self:UpdateQuickEditID(8, Value)
end

function TeamRecruitVM:UpdateQuickEditID(ID, bFlag)
    local IDs = table.clone(self.EditQuickTextIDs or {})
    if bFlag then
        table.array_add_unique(IDs, ID) 
     else
        table.remove_item(IDs, ID) 
        if self.EditReduceQuickTextIDs == nil then
             self.EditReduceQuickTextIDs = {}
        end
        table.array_add_unique(self.EditReduceQuickTextIDs, ID)
     end
     table.sort(IDs, function (a, b)
        return a < b
     end)

     self.EditQuickTextIDs = IDs
end

---更新当前招募详情信息
---@param ServerData csteamrecruit.TeamRecruit @招募的完整服务器信息
function TeamRecruitVM:UpdateCurRecruitDetailInfo(ServerData)
    if nil == ServerData then
        return
    end
    self.EditQuickTextIDs = ServerData.QuickMessageIDs or {}
    self.CurRecruitDetailVM:UpdateVM(ServerData)
end

---清理当前招募详情信息
function TeamRecruitVM:ClearCurRecruitDetailInfo( )
    self.CurRecruitDetailVM:Clear() 
end

function TeamRecruitVM:SetHasCompleteRecruit(b)
    self.HasCompleteRecruit = b
end

function TeamRecruitVM:UpdateIsRecruitListEmpty( )
    self.IsRecruitListEmpty = self.ViewingRecruitItemVMList == nil or self.ViewingRecruitItemVMList:Length() == 0
end

---更新招募类型列表
function TeamRecruitVM:UpdateTeamRecruitTypeVMList( )
    local TypeIDMap = {}
    local AllCfg = TeamRecruitCfg:FindAllCfg() or {}

    for _, v in ipairs(AllCfg) do
        local TypeID = v.TypeID 
        if TypeID and not TypeIDMap[TypeID] then
            if TeamRecruitUtil.IsRecruitUnlocked(v.ID) then
                TypeIDMap[TypeID] = true
            end
        end
    end

    local TypeIDList = table.indices(TypeIDMap)
    local Data = {}

    for _, v in ipairs(TypeIDList) do
        local Info = TeamRecruitTypeCfg:GetRecruitTypeInfo(v)
        if Info then
            table.insert(Data, Info)
        end
    end

    table.sort(Data, function (lhs, rhs)
        return lhs.ID < rhs.ID
    end)

    self.TeamRecruitTypeVMList:UpdateByValues(Data)
end

function TeamRecruitVM:GetTeamRecruitTypeVMListIdx( RecruitType )
    local _, Idx  = self.TeamRecruitTypeVMList:Find(function(e) 
        return e.TypeID == RecruitType 
    end)

    return Idx
end

local function FuncSortRecruit(a, b)
    if TeamRecruitVM.IsRecruiting then
        local RA = _G.TeamRecruitMgr.RecruitID == a.RoleID
        local RB = _G.TeamRecruitMgr.RecruitID == b.RoleID
        if RA ~= RB then
            return RA
        end
    end

    if a.RoleID == MajorUtil.GetMajorRoleID() then
       return true 
    end
    if b.RoleID == MajorUtil.GetMajorRoleID() then
       return false 
    end

    local LUnopen = TeamRecruitUtil.IsUnOpenTask(a.ContentID)
    local RUnopen = TeamRecruitUtil.IsUnOpenTask(b.ContentID)
    if LUnopen ~= RUnopen then
        return not LUnopen
    end

    local FA = _G.FriendMgr:IsFriend(a.RoleID)
    local FB = _G.FriendMgr:IsFriend(b.RoleID)
    if FA ~= FB then
        return FA
    end

    local ArmyA = _G.ArmyMgr:GetIsArmyMemberByRoleID(a.RoleID)
    local ArmyB = _G.ArmyMgr:GetIsArmyMemberByRoleID(b.RoleID)
    if ArmyA ~= ArmyB then
        return ArmyA
    end

    if a.StartTime ~= b.StartTime then
        return a.StartTime < b.StartTime
    end

    return  a.RoleID < b.RoleID
end

---更新招募列表
function TeamRecruitVM:UpdateRecruitItemList( TeamRecruitList, TypeID, bAppend)
    local RoleIDList = {}
    local OpenList = {}

    for _, v in pairs(TeamRecruitList) do
        if v.State == RECRUIT_STATE.RECRUIT_STATE_OPEN and not FriendMgr:IsInBlackList(v.RoleID) then
            table.insert(RoleIDList, v.RoleID)
            table.insert(OpenList, v)
        end
    end

    -- all are banned, ignore
    if #TeamRecruitList > 0 and #OpenList == 0 then
        _G.FLOG_WARNING("TeamRecruitVM:UpdateRecruitItemList ignore since all banned")
        return
    end

    if bAppend and #OpenList > 0 then
        -- remove existing recruit items which is not the currrent type
        self.RecruitItemVMList:RemoveItemsByPredicate(function(Item)
            local Cfg = TeamRecruitCfg:FindCfgByKey(Item.ContentID)
            return Cfg == nil or Cfg.TypeID ~= TypeID or table.find_by_predicate(OpenList, function(r)
                return r.RoleID == Item.RoleID
            end) ~= nil
        end, true, nil, true)

        if #OpenList > 0 and (#OpenList + self.RecruitItemVMList:Length()) < 1000 then
           for _, v in ipairs(OpenList) do
                self.RecruitItemVMList:AddByValue(v)
           end 
           self.RecruitItemVMList:Sort(FuncSortRecruit)
           self.RecruitItemVMList:OnUpdateList()
        else
            self.RecruitItemVMList:UpdateByValues(OpenList, FuncSortRecruit)
        end
    else
        self.RecruitItemVMList:UpdateByValues(OpenList, FuncSortRecruit)
    end
    
    self:UpdateFilter(TypeID)
    self:UpdateIsRecruitListEmpty()
end

---更新具体招募Item信息
---@param TeamRecruit csteamrecruit.TeamRecruit @招募的完整信息
function TeamRecruitVM:UpdateRecruitItem( TeamRecruit )
    if nil == TeamRecruit then
        return
    end

    local RoleID = TeamRecruit.RoleID
    if nil == RoleID then
        return
    end

    local Item = self.RecruitItemVMList:Find(function(e) 
        return RoleID == e.RoleID 
    end) 

    if Item then
        if TeamRecruit.State == RECRUIT_STATE.RECRUIT_STATE_OPEN then
            Item:UpdateVM(TeamRecruit)

        else
            self.RecruitItemVMList:Remove(Item)
            self:UpdateIsRecruitListEmpty()
        end
    end
end

function TeamRecruitVM:SetCurSelectRecruitType( TypeID )
    if nil == TypeID then
        return
    end

    self.CurSelectRecruitType = TypeID
    self:InnerUpdateFilterData(TypeID)
end

---获取招募内容列表
---@param TypeID number @招募类型ID
---@return table
function TeamRecruitVM:GetRecruitContentList( TypeID )
    local Ret = {}
	local CfgList = TeamRecruitCfg:GetContentListByType(TypeID)
    if nil == CfgList then
        return Ret
    end

    for _, v in ipairs(CfgList) do
        if TeamRecruitUtil.IsRecruitUnlocked(v.ID) then
            table.insert(Ret, v)
        end
    end

    table.sort(Ret, function(lhs, rhs)
        return lhs.ID < rhs.ID
    end)

    return Ret
end

-------------------------------------------------------------------------------------------------------
---Edit

function TeamRecruitVM:SetEditQuickTextIDs( IDs, ReduceIDs )
    self.EditReduceQuickTextIDs = ReduceIDs or {}
    self.EditQuickTextIDs = IDs or {}
end

function TeamRecruitVM:UpdateEditTempQuickID( ID, IsAdd )
    if nil == ID then
        return
    end

    if IsAdd then
        if not table.contain(self.TempEditQuickTextIDs, ID) then
            table.insert(self.TempEditQuickTextIDs, ID)
        end

    else
        table.remove_item(self.TempEditQuickTextIDs, ID)
    end
end

--重置当前选择的内容职业信息列表
function TeamRecruitVM:ResetEditProfVMList(InData)
    if nil == self.EditContentID then
        self.EditProfVMList:Clear()
        return
    end

    if InData and InData.ID == self.EditContentID and InData.Prof then
        self:CalcMembersProf( InData.Prof )
        return
    end

	local Cfg = TeamRecruitCfg:FindCfgByKey(self.EditContentID)
	if nil == Cfg then
        self.EditProfVMList:Clear()
        return
    end

	local Data = {}
	local DefaultProf = Cfg.DefaultProf or {}

	for k, v in ipairs(DefaultProf) do
		local Info = {}
		Info.Loc = k
        -- Info.Prof = v
        -- if k == 1 then
        --     Info.RoleID = MajorUtil.GetMajorRoleID()
        -- end

            -- Info.Prof = { MajorUtil.GetMajorProfID() }

        -- else
            if v == TEAM_RECRUIT_PROF.TEAM_RECRUIT_MODEL_GUARD then -- 防护
                Info.Prof = TeamRecruitUtil.GetAllOpenProfByFunctionType(FunctionType.FUNCTION_TYPE_GUARD)

            elseif v == TEAM_RECRUIT_PROF.TEAM_RECRUIT_MODEL_ATTACK then -- 进攻
                Info.Prof = TeamRecruitUtil.GetAllOpenProfByFunctionType(FunctionType.FUNCTION_TYPE_ATTACK)

            elseif v == TEAM_RECRUIT_PROF.TEAM_RECRUIT_MODEL_RECOVER then -- 回复 
                Info.Prof = TeamRecruitUtil.GetAllOpenProfByFunctionType(FunctionType.FUNCTION_TYPE_RECOVER)

            elseif v == TEAM_RECRUIT_PROF.TEAM_RECRUIT_MODEL_ALL then -- 所有人
                Info.Prof = TeamRecruitUtil.GetAllOpenProf() 
            end
        -- end

        table.insert(Data, Info)
	end

    self:CalcMembersProf( Data )
end

function TeamRecruitVM:CalcMembersProf( Profs )
    self.IsCalcingMembersProf = true 
    -- self.EditProfVMList:Clear()
	TeamRecruitMgr:SendCalcMemberIndexReq(Profs)
end

---更新编辑职位数据列表
---@param Profs table<RecruitProf>
function TeamRecruitVM:UpdateEditProfVMList( Profs )
    table.sort(Profs, TeamRecruitUtil.SortEditProf)

    self.EditProfVMList:UpdateByValues(Profs)
    self.TempEditProfVMList:UpdateByValues(Profs)
    self.IsCalcingMembersProf = false 
end

---@return TeamRecruitProfVM | nil
function TeamRecruitVM:GetCurSelectTempEditProfVM()
    if nil == self.EditSelectProfVMListIdx or self.EditSelectProfVMListIdx <= 0 then
        return
    end

    local Idx = self.EditSelectProfVMListIdx
    if Idx > self.TempEditProfVMList:Length() then
        return
    end

    return self.TempEditProfVMList:Get(Idx)
end

function TeamRecruitVM:GetEditProfs()
    local Ret = {}

    local Items = self.EditProfVMList:GetItems() or {}

    for _, v in ipairs(Items) do
        table.insert(Ret, { Loc = v.Loc, Prof = v.Profs, RoleID = v.RoleID })
    end

    return Ret
end

function TeamRecruitVM:GetEditPassword()
    return string.isnilorempty(self.EditPassword) and "" or self.EditPassword
end

function TeamRecruitVM:SetPreSelectTask(Task)
    self.PreSelectTask = Task
end

function TeamRecruitVM:OnRecruitClose(RecruitID)
    local function PredRemove(v)
        return v.RoleID == RecruitID
    end

    self.RecruitItemVMList:RemoveByPredicate(PredRemove, true)
    self.FilterRecruitItemVMList:RemoveByPredicate(PredRemove, true)
end

function TeamRecruitVM:IsEnableFilter(TypeID)
    return self:GetFilterProp(TypeID, FILTER_KEY_ENABLE) == true
end

function TeamRecruitVM:ClearFilter()
    self.FilterConfigDict = {}
    self:UpdateFilter(self.CurSelectRecruitType)
end

function TeamRecruitVM:EnableFilter(TypeID, bEnable)
    self:SetFilterProp(TypeID, FILTER_KEY_ENABLE, bEnable == true)
    if TypeID == self.CurSelectRecruitType then
       self:UpdateFilter(TypeID) 
    end
end

function TeamRecruitVM:UpdateFilter(TypeID)
    local FilterItems = {}
    local FilterTypeID = TypeID or self.CurSelectRecruitType
    local bFilter = self:IsEnableFilter(FilterTypeID)
    local bFlag
    for _, v in ipairs(self.RecruitItemVMList:GetItems()) do
        local bNotRetain
        if bFilter then
            if self.IsRecruiting then
                bNotRetain = (v.RoleID ~= MajorUtil.GetMajorRoleID() and v.RoleID ~= _G.TeamRecruitMgr.RecruitID and not TeamRecruitUtil.CanJoinRecruit(v) )
            else
                bNotRetain = not TeamRecruitUtil.CanJoinRecruit(v)
            end
        end

        do
            local Op = self:GetFilterOp(FilterTypeID)
            if Op ~= nil and Op ~= 999 then
                bNotRetain = Op ~= ((v.SceneMode or 0) + 1)
            end

            if not bNotRetain then
                local CID = self:GetFilterContentID(FilterTypeID)
                bNotRetain = (CID ~= nil and CID ~= v.ContentID)
            end
        end
        if not bNotRetain then
            table.insert(FilterItems, v) 
        else
           bFlag = true
        end
    end

    self.FilterRecruitItemVMList.Items = FilterItems
    self.FilterRecruitItemVMList:OnUpdateList()
    if bFlag then
       self.ViewingRecruitItemVMList = self.FilterRecruitItemVMList 
    else
        self.ViewingRecruitItemVMList = self.RecruitItemVMList
    end
end

function TeamRecruitVM:SetFilterOp(TypeID, Op)
    self:SetFilterProp(TypeID, FILTER_KEY_OP, Op)
end

function TeamRecruitVM:SetFilterContentID(TypeID, ContentID)
    self:SetFilterProp(TypeID, FILTER_KEY_CID, ContentID)
end

function TeamRecruitVM:GetFilterOp(TypeID)
    return self:GetFilterProp(TypeID, FILTER_KEY_OP)
end

function TeamRecruitVM:GetFilterContentID(TypeID)
    return self:GetFilterProp(TypeID, FILTER_KEY_CID)
end

function TeamRecruitVM:ClearFilterData(TypeID)
    self:SetFilterProp(TypeID, FILTER_KEY_CID, nil)
    self:SetFilterProp(TypeID, FILTER_KEY_OP, nil)
end

---@private
function TeamRecruitVM:SetFilterProp(TypeID, K, V)
    if TypeID and K then
       if self.FilterConfigDict[TypeID] == nil then
            self.FilterConfigDict[TypeID] = {}
       end
       self.FilterConfigDict[TypeID][K] = V
    end

    if TypeID == self.CurSelectRecruitType then
       self:InnerUpdateFilterData(TypeID)
    end
end

---@private
function TeamRecruitVM:GetFilterProp(TypeID, K)
    if TypeID and K then
        local E = self.FilterConfigDict[TypeID]
        if E then
           return E[K] 
        end
    end
end

---private
function TeamRecruitVM:InnerUpdateFilterData(TypeID)
    if TypeID == nil then
       return 
    end

    local Op = self:GetFilterOp(TypeID)
    local CID = self:GetFilterContentID(TypeID)
    self.bEnableConcreteFilter = ( TypeID == self.CurSelectRecruitType and not ((Op == 999 or Op == nil) and CID == nil) )
    self:UpdateFilter(TypeID)
end

function TeamRecruitVM:UpdateEditText(Text)
    -- local TeamRecruitFastMsgCfg = require("TableCfg/TeamRecruitFastMsgCfg")

	-- -- --便捷输入
	-- -- local NoneIDs = {} 
	-- local IDList = table.clone(self.EditQuickTextIDs)
    -- local AllQuickText = TeamRecruitFastMsgCfg:GetAllText()

	-- if self.EditCompleteTask then
	-- 	table.array_add_unique(IDList, 4)
	-- end
	-- if self.EditWeeklyAward then
	-- 	table.array_add_unique(IDList, 8)
	-- end
	-- table.sort(IDList, function (a, b)
	-- 	return a < b
	-- end)

	-- for k, v in ipairs(IDList) do
	-- 	local QuickText = AllQuickText[v]
	-- 	if QuickText then
	-- 		local Str = string.format("[%s]", QuickText)  
	-- 		if string.startsWith(Text, Str) then
	-- 			Text = string.gsub(Text, "^" .. string.revisePattern(Str), "", 1)
	-- 		else
	-- 			-- table.insert(NoneIDs, k)
	-- 		end

	-- 	else
	-- 		-- table.insert(NoneIDs, k)
	-- 	end
	-- end

	-- local Temp = ""

	-- for _, v in ipairs(IDList)  do
	-- 	local QuickText = AllQuickText[v]
    --     if not string.isnilorempty(QuickText) then 
	-- 		local Str = string.format("[%s]", QuickText)  
	-- 		Text = string.gsub(Text, string.revisePattern(Str), "", 1)

	-- 		Temp = Temp .. Str
	-- 	end
	-- end

	-- Text = Temp .. Text
	-- -- Temp = ""
	-- -- Text = Temp .. Text

	-- -- for i = #NoneIDs, 1, -1 do 
	-- -- 	local k = NoneIDs[i]
	-- -- 	if k and k <= #IDList then
	-- -- 		table.remove(IDList, k)
	-- -- 	end
	-- -- end

	self.EditMessage = Text
end

return TeamRecruitVM