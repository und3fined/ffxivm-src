
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local SelectMonsterMainPanelVM = require("Game/Interactive/SelectMonster/SelectMonsterMainPanelVM")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local MonsterCfg = require("TableCfg/MonsterCfg")

local SelectMonsterMgr = LuaClass(MgrBase)

--特殊类型的交互，不走通用交互的统一ui体系

--名字后缀，最多26个
--因为需要同一个怪的不同客户端的标记一致，所以按EntityID来划分标记，如果重复的话，处理下不重复就好
SelectMonsterMgr.StrTag = {"A", "B", "C", "D", "E", "F", "G", "H"
    , "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
SelectMonsterMgr.StrTagNum = 26

--[ResID, true]     这种数据需要读表，将来可以预加载
SelectMonsterMgr.ClickSelectMonsterMap = {}
SelectMonsterMgr.EntityIDToTagIndexMap = {}
SelectMonsterMgr.TagIndexToEntityIDMap = {}
SelectMonsterMgr.MonsterList = {}

function SelectMonsterMgr:OnInit()
end

function SelectMonsterMgr:OnBegin()
    self.EntityIDToTagIndexMap = {}
    self.TagIndexToEntityIDMap = {}
    self.MonsterList = {}
end

function SelectMonsterMgr:OnEnd()
    self.EntityIDToTagIndexMap = {}
    self.TagIndexToEntityIDMap = {}
    self.MonsterList = {}

    self:HideMainPanel()
end

function SelectMonsterMgr:OnShutdown()
end

function SelectMonsterMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
end

function SelectMonsterMgr:ShowMainPanel()
    if not self.MainPanel then
        self.MainPanel = _G.UIViewMgr:ShowView(UIViewID.SelectMonsterMainPanel)
    end

    if not self.MainPanel:IsVisible() then
        self.MainPanel = _G.UIViewMgr:ShowView(UIViewID.SelectMonsterMainPanel)
    end

    self:StartTickTimer()
end

function SelectMonsterMgr:HideMainPanel()
    _G.UIViewMgr:HideView(UIViewID.SelectMonsterMainPanel)
    self.MainPanel = nil

    self:StopTickTimer()
end

function SelectMonsterMgr:OnGameEventPWorldExit(Params)
    self:OnEnd()
end

function SelectMonsterMgr:StartTickTimer()
    if not self.UpdateListTimerID then
        self.UpdateListTimerID = self:RegisterTimer(self.UpdateInteractorList, 0, 0.5, 0)
    end
end

function SelectMonsterMgr:StopTickTimer()
    if self.UpdateListTimerID then
        _G.TimerMgr:CancelTimer(self.UpdateListTimerID)
        self.UpdateListTimerID = nil
    end
end

--tick 刷新距离、刷新ui
function SelectMonsterMgr:UpdateInteractorList()
    for _, MonsterInfo in ipairs(self.MonsterList) do
        MonsterInfo.Distance = ActorUtil.GetActorByEntityID(MonsterInfo.EntityID):GetDistanceToMajor()
    end

    table.sort(self.MonsterList, function(a, b) return a.Distance < b.Distance end)
    
    self:UpdateUI()
end

--进视野的时候确定TagIndex
function SelectMonsterMgr:OnGameEventVisionEnter(Params)
    local ActorType = Params.IntParam1
    if ActorType == _G.UE.EActorType.Monster then
        local EntityID = Params.ULongParam1
        local ResID = Params.IntParam2
    
        if self:IsClickSelectMonsterMap(ResID) then
            local Idx = self:GetTagIndex(EntityID)
            self.EntityIDToTagIndexMap[EntityID] = Idx 
            self.TagIndexToEntityIDMap[Idx] = EntityID
            FLOG_INFO("SelectMonsterMgr VisionEnter EntityID:%d TagIndex:%d", EntityID, self.EntityIDToTagIndexMap[EntityID])
        end
    end
end

function SelectMonsterMgr:OnGameEventVisionLeave(Params)
    local ActorType = Params.IntParam1
    if ActorType == _G.UE.EActorType.Monster then
        local EntityID = Params.ULongParam1

        local Idx = self.EntityIDToTagIndexMap[EntityID]
        if Idx then
            self.TagIndexToEntityIDMap[Idx] = nil
        end

        self.EntityIDToTagIndexMap[EntityID] = nil

        for Index, MonsterInfo in ipairs(self.MonsterList) do
            if MonsterInfo.EntityID == EntityID then
                table.remove(self.MonsterList, Index)
                FLOG_INFO("SelectMonsterMgr VisionLeave EntityID:%d TagIndex:%d", EntityID, MonsterInfo.TagIndex)

                self:UpdateUI()
                break
            end
        end
    end
end

function SelectMonsterMgr:OnGameEventEnterInteractionRange(Params)
    -- local  EntityID = Params.ULongParam1
    -- local ResID = Params.ULongParam2

    local DistanceToMajor = ActorUtil.GetActorByEntityID(Params.ULongParam1):GetDistanceToMajor()
    local MonsterInfo = {EntityID = Params.ULongParam1
        , ResID = Params.ULongParam2
        , Distance = DistanceToMajor
        , TagIndex = self:GetTagIndex(Params.ULongParam1)}
    table.insert(self.MonsterList, MonsterInfo)

    if not self.MainPanel or not self.MainPanel:IsVisible() then
        self:ShowMainPanel()
    end
end

function SelectMonsterMgr:OnGameEventLeaveInteractionRange(Params)
    local  EntityID = Params.ULongParam1
    -- local ResID = Params.ULongParam2

    if self.MonsterList then
        for Index, MonsterInfo in ipairs(self.MonsterList) do
            if MonsterInfo.EntityID == EntityID then
                table.remove(self.MonsterList, Index)
                break
            end
        end
    end

    self:UpdateUI()
end

--todo 刷新ui
function SelectMonsterMgr:UpdateUI()
    if not self.MonsterList then
        self:HideMainPanel()
        return 
    end

    local Count = #self.MonsterList
    if Count > 0 then
        if Count > 3 then
            local Tmp = {}
            for index = 1, 3 do
                table.insert(Tmp, self.MonsterList[index])
            end
            SelectMonsterMainPanelVM:SetMonsters(Tmp)
        else
            SelectMonsterMainPanelVM:SetMonsters(self.MonsterList)
        end
    else
        self:HideMainPanel()
    end
end

function SelectMonsterMgr:SelectMonster(EntityID)
	_G.SwitchTarget:SwitchToTarget(EntityID)
    -- self.CurSelectIndex = self:GetTagIndex(EntityID)
    _G.EventMgr:SendEvent(_G.EventID.SelectMonsterIndex, EntityID)
end

function SelectMonsterMgr:GetTagIndex(EntityID)
    self.EntityIDToTagIndexMap = self.EntityIDToTagIndexMap or {}
    self.TagIndexToEntityIDMap = self.TagIndexToEntityIDMap or {}

    local Index = self.EntityIDToTagIndexMap[EntityID]
    
    if not Index then
        Index = math.fmod(EntityID, self.StrTagNum)

        --已经被占用了，重复了的
        if self.TagIndexToEntityIDMap[Index] then
            FLOG_INFO("SelectMonsterMgr:GetTagIndex EntityID:%d Index:%d has used", EntityID, Index)
            for i = Index, self.StrTagNum do
                if not self.TagIndexToEntityIDMap[i] then
                    Index = i
                    break
                end
            end
        end
   
       self.EntityIDToTagIndexMap[EntityID] = Index
       FLOG_INFO("SelectMonsterMgr:GetTagIndex EntityID:%d TagIndex:%d", EntityID, Index)
    end

    return Index
end

function SelectMonsterMgr:GetMonsterNameHasTagStr(ResID, EntityID, ActorName)
    if string.isnilorempty(ActorName) then
        return ""
    end

    local PostStr = self:GetMonsterStrTag(ResID, EntityID)
    if PostStr ~= "" then
        return string.format("%s%s", ActorName, PostStr)
    end

    return ActorName
end

function SelectMonsterMgr:GetMonsterStrTag(ResID, EntityID)
    if not self:IsClickSelectMonsterMap(ResID) then
        return ""
    end

    local Index = self:GetTagIndex(EntityID) + 1
    local PostStr =  self.StrTag[Index]

    return PostStr
end

function SelectMonsterMgr:IsClickSelectMonsterMap(ResID)
    local Result = self.ClickSelectMonsterMap[ResID]
    if Result ~= nil then
        return Result
    end

    local Cfg = MonsterCfg:FindCfgByKey(ResID)
    if Cfg and Cfg.InteractiveID and Cfg.InteractiveID > 0 then
        local CfgDesc = InteractivedescCfg:FindCfgByKey(Cfg.InteractiveID)
        if CfgDesc and CfgDesc.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_CLICK_SELECT_MONSTER then
            FLOG_INFO("SelectMonsterMgr ResID:%d is ClickSelectMonster", ResID)
            self.ClickSelectMonsterMap[ResID] = true
            return true
        end
    end

    self.ClickSelectMonsterMap[ResID] = false
    return false
end

return SelectMonsterMgr