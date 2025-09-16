--
-- Author: chunfengluo
-- Date: 2022-10-09 10:33:17
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local BuffCfgTable = require("TableCfg/BuffCfg")
local SummonCfgTable = require("TableCfg/SummonCfg")
local SummonSkillCfgTable = require("TableCfg/SummonSkillCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local ProtoRes = require ("Protocol/ProtoRes")
local SummonMgr = LuaClass(MgrBase)

function SummonMgr:OnInit()

    -- SummonRecord = {
    --     [FollowEntityID] = {           // FollowEntityID下的BuffID对应一个召唤兽的信息
    --          [BuffID] = {
    --               ["SummonEntityID"] = SummonEntityID,
    --               ["ResID"] = SummonResID
    --          },
    --     ......
    --     }
    -- }

    self.SummonRecord = {}
    self.SummonMaster = {}
    self.PendingCreateQueue = {}
    self.PendingKillQueue = {}
    self.PendingCreateOnRide = {}
    self.QuerySummonRelatedBuff = {}
    self.SummonScale = SettingsTabRole.SummonScale
end

---SummonMgr.CreateSummon @创建召唤兽
---@param BuffID      @召唤兽对应的BuffID
---@param FollowID    @召唤兽附着的角色的EntityID
---@param GiverID     @召唤兽的创建者EntityID
function SummonMgr:CreateSummon(BuffID, FollowID, GiverID)
    local BuffCfg = BuffCfgTable:FindCfgByKey(BuffID)
    if nil == BuffCfg or BuffCfg.IsIndependent == 0 then return end

    local SummonResID = BuffCfg.SummonID      -- 召唤兽ResID
    if SummonResID == 0 then return end
    self.QuerySummonRelatedBuff[SummonResID] = BuffID

    local SummonCfg = SummonCfgTable:FindCfgByKey(SummonResID)
    if nil == SummonCfg then return end

    if self.SummonRecord[FollowID] == nil then
        self.SummonRecord[FollowID] = {}
    end

    local Follow = self.SummonRecord[FollowID]
    local FollowActor = ActorUtil.GetActorByEntityID(FollowID)
    local InitAngle = SummonCfg.InitAngle;
    local InitRadius = SummonCfg.InitRadius;

    local InheritID = SummonCfg.InheritID
    local InheritBuffIDList = {}
    local InheritBuffID = 0
    if InheritID and InheritID > 0 then
        for index, value in pairs(self.QuerySummonRelatedBuff) do
            if BuffID ~= value then
                local SummonCfg = SummonCfgTable:FindCfgByKey(index)
                if SummonCfg.InheritID == InheritID then
                    table.insert(InheritBuffIDList, value)
                end
            end
        end
    end
    local ListNum = #InheritBuffIDList
    if ListNum > 0 then
        for _, value in pairs(InheritBuffIDList) do
            if Follow[value] ~= nil and ActorUtil.GetActorByEntityID(Follow[value].EntityID) ~= nil
            and not ActorUtil.IsDeadState(Follow[value].EntityID) then
                InheritBuffID = value
                break
            end
        end
    end

    --local InheritBuffID = self.QuerySummonRelatedBuff[InheritID]

    local SummonLocation
    local SummonRotation
    
    if InheritBuffID ~= nil and InheritBuffID > 0 and Follow[InheritBuffID] ~= nil then
        --继承召唤兽的位置
        local OldSummonActor = ActorUtil.GetActorByEntityID(Follow[InheritBuffID].EntityID)
        if OldSummonActor ~= nil then
            --如果旧的召唤兽还存在，读取其位置
            SummonLocation = OldSummonActor:FGetActorLocation()
            SummonRotation = OldSummonActor:FGetActorRotation()
        --else
            --如果旧的召唤兽不存在，读取记录在SummonRecord中的location和rotation
            --SummonLocation = Follow[InheritBuffID].ActorLocation
            --SummonRotation = Follow[InheritBuffID].ActorRotation
        end
    end

    if SummonLocation == nil or SummonRotation == nil then
        --初始位置赋值失败，使用召唤表中的召唤兽初始化逻辑：半径、角度
        local RelOffset = _G.UE.FRotator(0, InitAngle, 0):RotateVector(_G.UE.FVector(InitRadius, 0, 0))
		if nil ~= FollowActor then
        	SummonLocation = FollowActor:FGetLocation(_G.UE.EXLocationType.ServerLoc) + 2 + FollowActor:FGetActorRotation():RotateVector(RelOffset)
		else
			SummonLocation = _G.UE.FVector(0, 0, 0)
		end
        SummonRotation = _G.UE.FRotator(0, 0, 0)
    end

    local function Create()
        if self.SummonRecord[FollowID] == nil
        or self.SummonRecord[FollowID][BuffID] == nil
        or self.SummonRecord[FollowID][BuffID].EntityID == nil
        or not self.SummonRecord[FollowID][BuffID].PendingCreate and ActorUtil.GetActorByEntityID(self.SummonRecord[FollowID][BuffID].EntityID) == nil then
            local SummonActorID = _G.UE.UActorManager:Get():CreateClientActorNextTick(
                _G.UE.EActorType.Summon, 0, SummonResID, SummonLocation, SummonRotation)
            self.SummonMaster[SummonActorID] = { FollowID = FollowID, GiverID = GiverID, SummonResID = SummonResID, BuffID = BuffID }
            if self.SummonRecord[FollowID] then
                self.SummonRecord[FollowID][BuffID] = { ["EntityID"] = SummonActorID, ["ResID"] = SummonResID, ["GiverID"] = GiverID, ["PendingCreate"] = true}
            end
        end
    end
     --理发屋屏蔽
     local CurrPWorldType = _G.PWorldMgr:GetCurrPWorldType()
     if CurrPWorldType == ProtoRes.pworld_type.PWORLD_CATEGORY_DEMO then
         return
     end

    local IsRide = false
    if FollowActor ~= nil and FollowActor:GetRideComponent() ~= nil then
        IsRide = FollowActor:GetRideComponent():IsInRide()
    end
    if InheritBuffID ~= nil and InheritBuffID > 0 and Follow[InheritBuffID] ~= nil
    and ActorUtil.GetActorByEntityID(Follow[InheritBuffID].EntityID) ~= nil
    and not ActorUtil.IsDeadState(Follow[InheritBuffID].EntityID) then
        --加入队列，等待被继承的召唤兽死亡时调用创建函数
        self.PendingCreateQueue[Follow[InheritBuffID].EntityID] = { ["Function"] = Create, ["BuffID"] = BuffID }
    elseif IsRide then
        self.PendingCreateOnRide[FollowID] =  { ["Function"] = Create, ["BuffID"] = BuffID }
    else
        --立即创建
        Create()
    end
end

function SummonMgr:RemoveSummon(BuffID, FollowID)
    if self.PendingCreateOnRide[FollowID] and self.PendingCreateOnRide[FollowID].BuffID == BuffID then
        self.PendingCreateOnRide[FollowID] = nil
    end
    if nil == self.SummonRecord[FollowID] then return end
    -- 移除的Buff还存在于等待创建的队列里
    local BuffList = self.SummonRecord[FollowID]
    for _, SummonInfo in pairs(BuffList) do
        if self.PendingCreateQueue[SummonInfo.EntityID] and self.PendingCreateQueue[SummonInfo.EntityID].BuffID == BuffID then
            self.PendingCreateQueue[SummonInfo.EntityID] = nil
        end
    end
    if nil == self.SummonRecord[FollowID][BuffID] then return end
    local SummonActorID = self.SummonRecord[FollowID][BuffID].EntityID
    if SummonActorID == nil or SummonActorID == 0 then return end

    local SummonActor = ActorUtil.GetActorByEntityID(SummonActorID)
    if SummonActor ~= nil then
        self.SummonRecord[FollowID][BuffID].ActorLocation = SummonActor:FGetActorLocation()
        self.SummonRecord[FollowID][BuffID].ActorRotation = SummonActor:FGetActorRotation()
        if SummonActor.SetDeath ~= nil then
            SummonActor:SetDeath()
        end
    else
        self.PendingKillQueue[SummonActorID] = { ["bKill"] = true }
    end
    self.SummonRecord[FollowID][BuffID] = nil
end

function SummonMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.UpdateBuff, self.OnGameEventUpdateBuff)
    self:RegisterGameEvent(EventID.RemoveBuff, self.OnGameEventRemoveBuff)
    self:RegisterGameEvent(EventID.SkillStart, self.OnGameEventSkillSing)
    self:RegisterGameEvent(EventID.SummonPlaySing, self.OnGameEventSummonPlaySing)
    self:RegisterGameEvent(EventID.SkillEnd, self.OnGameEventSkillEnd)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.SummonCreate, self.OnGameEventSummonCreate)
    self:RegisterGameEvent(EventID.SummonDead, self.OnGameEventSummonDead)
    self:RegisterGameEvent(EventID.MountCall, self.OnGameEventMountCall)			-- 上坐骑
	self:RegisterGameEvent(EventID.MountBack, self.OnGameEventMountBack)			-- 下坐骑
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventCharacterDead)
end

---@param Params FEventParams
function SummonMgr:OnGameEventUpdateBuff(Params)
    local BuffID = Params.IntParam1
    local FollowID = Params.ULongParam1    -- 被跟随的角色
    local GiverID = Params.ULongParam2     -- Buff的施放者
    self:CreateSummon(BuffID, FollowID, GiverID)
end

---@param Params FEventParams
function SummonMgr:OnGameEventRemoveBuff(Params)
    local BuffID = Params.IntParam1
    -- 版本临时处理一下，用GiverID,当前版本GiverID和FollowID 是同一个
    --local FollowID = Params.ULongParam1
    --self:RemoveSummon(BuffID, FollowID)
    local GiverID = Params.ULongParam2     -- Buff的施放者
    self:RemoveSummon(BuffID, GiverID)
    
end

function SummonMgr:OnGameEventSummonDead(Params)
    local SummonEntityID = Params.ULongParam1
    if not self.PendingCreateQueue[SummonEntityID] then
        return
    end
    local SummonDeadCallback = self.PendingCreateQueue[SummonEntityID].Function
    if SummonDeadCallback ~= nil then
        SummonDeadCallback()
    end
    self.PendingCreateQueue[SummonEntityID] = nil
end


---@param Params FEventParams
function SummonMgr:OnGameEventSkillSing(Params)
    local EntityID = Params.ULongParam1
    local SkillID = Params.IntParam1
    local PlayRate = Params.FloatParam1
    --_G.FLOG_INFO("--------------Entity %s Start Skill %s", tostring(EntityID), tostring(SkillID))

    if self.SummonRecord[EntityID] == nil then return end

    for BuffID, SummonInfo in pairs(self.SummonRecord[EntityID]) do
        local SearchConditions = string.format("ID = %d AND SkillID = %d", SummonInfo.ResID, SkillID)
        local SummonSkillCfg = SummonSkillCfgTable:FindCfg(SearchConditions)
        if SummonSkillCfg ~= nil then
            local SingID = SummonSkillCfg.SingID
            _G.FLOG_INFO("Summon %d Play Effect %d PlayRate = %f", SummonInfo.EntityID, SingID, PlayRate)
            local SummonActor = ActorUtil.GetActorByEntityID(SummonInfo.EntityID)
            if SummonActor ~= nil and SummonActor.SetFloorSocket ~= nil then
                SummonActor:SetFloorSocket()
            end
            _G.SkillSingEffectMgr:PlaySingEffect(SummonInfo.EntityID, SingID, nil, PlayRate)
        end
    end
end

function SummonMgr:OnGameEventSummonPlaySing(Params)
    local EntityID = Params.ULongParam1
    local SummonID = Params.IntParam2
    local SingID = Params.IntParam3

    if self.SummonRecord[EntityID] == nil then
        return
    end
    local SummonList = self.SummonRecord[EntityID]
    for _, SummonInfo in pairs(SummonList) do
        if SummonInfo.ResID == SummonID then
            local SummonActor = ActorUtil.GetActorByEntityID(SummonInfo.EntityID)
            if SummonActor ~= nil then
                SummonActor:SetFloorSocket()
            end

            _G.SkillSingEffectMgr:PlaySingEffect(SummonInfo.EntityID, SingID, nil, PlayRate)
            return
        end
    end
end

---@param Params FEventParams
function SummonMgr:OnGameEventSkillEnd(Params)
    --_G.FLOG_INFO("--------------Skill end")
end

function SummonMgr:OnGameEventEnterWorld(Params)
    --切换关卡的时候召唤兽被删除了，但是Buff还在，需要重新生成
    for Follow, BuffList in pairs(self.SummonRecord) do
        local FollowActor = ActorUtil.GetActorByEntityID(Follow)
        if FollowActor == nil then
            self.SummonRecord[Follow] = nil
        else
        --     for BuffID, SummonInfo in pairs(BuffList) do
        --         _G.FLOG_INFO("[Summon] Enter World, Follow Entity: %s, Buff %s, SummonInfo %s", tostring(Follow), tostring(BuffID), tostring(SummonInfo.EntityID))
        --         if SummonInfo.EntityID > 0 and ActorUtil.GetActorByEntityID(SummonInfo.EntityID) == nil then
        --             -- 召唤兽被删除了，重新创建
        --             -- TODO: 需要等关卡切换时Buff保留的功能完成后再做
        --             -- local BuffCom = FollowActor:GetBuff
        --             -- if BuffCom and BuffCom.IsExistBuffForBuffID(BuffID) then
        --             -- --if true then
        --             --     self:CreateSummon(BuffID, Follow, SummonInfo.GiverID)
        --             -- else --Buff列表中不存在召唤兽Buff，清除
        --             --     BuffList[BuffID] = nil
        --             -- end
        --         end
        --     end
        end
    end
end

function SummonMgr:OnGameEventExitWorld(Params)

end

function SummonMgr:OnGameEventVisionEnter(Params)

end

function SummonMgr:OnGameEventVisionLeave(Params)
    local EntityID = Params.ULongParam1
    local BuffList = self.SummonRecord[EntityID]
    if BuffList == nil then return end
    for BuffID, SummonInfo in pairs(BuffList) do
        self:RemoveSummon(BuffID, EntityID)
    end
    self.SummonRecord[EntityID] = nil
end

function SummonMgr:OnGameEventSummonCreate(Params)
    local SummonActorID = Params.ULongParam1
    local SummonActor = ActorUtil.GetActorByEntityID(SummonActorID)
    if SummonActor ~= nil and self.PendingKillQueue[SummonActorID] ~= nil and self.PendingKillQueue[SummonActorID].bKill and SummonActor ~= nil and SummonActor.SetDeath ~= nil then
        if SummonActor ~= nil and self.SummonMaster[SummonActorID] then
            local FollowID = self.SummonMaster[SummonActorID].FollowID
            SummonActor:SetFollowEntityID(FollowID)
            SummonActor:SetDeath()
        end
        self.PendingKillQueue[SummonActorID] = nil
        return
    end

    if SummonActor ~= nil and self.SummonMaster[SummonActorID] then
        local FollowID = self.SummonMaster[SummonActorID].FollowID
        local GiverID = self.SummonMaster[SummonActorID].GiverID
        local BuffID = self.SummonMaster[SummonActorID].BuffID
        local SummonResID = self.SummonMaster[SummonActorID].SummonResID
        if SummonActor.SetFollowEntityID ~= nil or SummonActor.SetOwnerEntityID ~= nil or SummonActor.SetBuffID ~= nil then
            SummonActor:SetFollowEntityID(FollowID)
            SummonActor:SetOwnerEntityID(GiverID)
            SummonActor:SetBuffID(BuffID)
        else
            _G.FLOG_WARNING("SummonActor.SetFollowEntityID ~= nil or SummonActor.SetOwnerEntityID ~= nil")
        end
        if self.SummonRecord[FollowID] and self.SummonRecord[FollowID][BuffID] then
            self.SummonRecord[FollowID][BuffID].PendingCreate = false
        end
    else
        _G.FLOG_ERROR("SummonActor is nil, SummonActorID = %s", tostring(SummonActorID))
    end
    -- 有可能出现进入Sequence之后才创建出来Summon, 需要额外隐藏一下
    if SummonActor ~= nil and _G.StoryMgr:SequenceIsPlaying() then
        _G.UE.UActorManager.Get():HideActor(SummonActorID, true)
    end
end

-- 1 = 大
-- 2 = 中
-- 3 = 小

function SummonMgr:SetSummonScale(ScaleType)
    self.SummonScale = ScaleType
    local SummonList = self.SummonRecord
    for _, FollowInfo in pairs(SummonList) do
        for _,SummonInfo in pairs(FollowInfo) do
            local SummonActor = ActorUtil.GetActorByEntityID(SummonInfo.EntityID)
            if SummonActor ~= nil then
                SummonActor:SetScaleFactor(self:GetTrueSummonScale(SummonInfo.ResID),true)
            end
        end
    end
end
function SummonMgr:GetTrueSummonScale(ResID)
    local SummonCfg = SummonCfgTable:FindCfgByKey(ResID)
    if SummonCfg == nil then
        return 1;
    end
    if self.SummonScale == 1 then
        if SummonCfg.ScaleBig and SummonCfg.ScaleBig > 0 then
            return SummonCfg.ScaleBig /100
        else
            return 1
        end
    end    
    if self.SummonScale == 2 then
        if SummonCfg.ScaleMiddle and SummonCfg.ScaleMiddle > 0 then
            return SummonCfg.ScaleMiddle /100
        else
            return 1
        end
    end    
    if self.SummonScale == 3 then
        if SummonCfg.ScaleSmall and SummonCfg.ScaleSmall > 0 then
            return SummonCfg.ScaleSmall /100
        else
            return 1
        end
    end
end

function SummonMgr:OnGameEventMountCall(Params)
    if Params.EntityID and Params.EntityID > 0 then
        local FollowID = Params.EntityID
        local BuffList = self.SummonRecord[FollowID]
        if BuffList == nil then
            return
        end
        for BuffID,SummonInfo in pairs(BuffList) do
            if SummonInfo.EntityID and SummonInfo.EntityID > 0 then
                local SummonActor = ActorUtil.GetActorByEntityID(SummonInfo.EntityID)
                if SummonActor and SummonActor.SetDeath ~= nil then
                    SummonActor:SetDeath()
                end
            end
        end
    end
end

function SummonMgr:OnGameEventMountBack(Params)
    if Params.EntityID  and Params.EntityID > 0 then
        local FollowID = Params.EntityID
        local BuffList = self.SummonRecord[FollowID]
        local Buffcom = ActorUtil.GetActorBuffComponent(FollowID)
        if BuffList then
            for BuffID,SummonInfo in pairs(BuffList) do
                if SummonInfo.EntityID and  SummonInfo.EntityID > 0 then
                    if Buffcom and Buffcom:IsExistBuffForBuffID(BuffID) then
                        --召唤兽不存在实体了或处在死亡状态
                        if ActorUtil.GetActorByEntityID(SummonInfo.EntityID) == nil or ActorUtil.IsDeadState(SummonInfo.EntityID) then
                            self:CreateSummon(BuffID,FollowID,SummonInfo.GiverID)
                        else
                            _G.FLOG_INFO("[SummonMgr] MountBack buffid = %s EntityID = %s Actor is not nil", tostring(BuffID), tostring(SummonInfo.EntityID))
                        end
                    else
                        BuffList[BuffID] = nil
                    end
                end
            end
        end
        if self.PendingCreateOnRide[FollowID] then
            local BuffID = self.PendingCreateOnRide[FollowID].BuffID
            if Buffcom and Buffcom:IsExistBuffForBuffID(BuffID) then
                local SummonCreateFunction = self.PendingCreateOnRide[FollowID].Function
                if SummonCreateFunction then
                    SummonCreateFunction()
                end
            end
            self.PendingCreateOnRide[FollowID] = nil
        end
    end
end

-- 主角死亡
function SummonMgr:OnGameEventMajorDead()
    local EntityID = MajorUtil.GetMajorEntityID()
    if EntityID and EntityID > 0 then
        self:Clear(EntityID)
    end
end
--其他玩家死亡
function SummonMgr:OnGameEventCharacterDead(Params)
    local EntityID = Params.ULongParam1
    if EntityID and EntityID > 0 then
        self:Clear(EntityID)
    end
end

-- function SummonMgr:OnGameEventSkillSystemLeave()
--     local EntityID = Params.ULongParam1
--     if EntityID and EntityID > 0 then
--         self:Clear(EntityID)
--     end
-- end

function SummonMgr:Clear(EntityID)
    local BuffList = self.SummonRecord[EntityID]
    if BuffList == nil then
        return
    end
    for BuffID, SummonInfo in pairs(BuffList) do
        if SummonInfo.EntityID and SummonInfo.EntityID > 0 then
            self.PendingCreateQueue[SummonInfo.EntityID] = nil
            local SummonActor = ActorUtil.GetActorByEntityID(SummonInfo.EntityID)
            if SummonActor and SummonActor.SetDeath ~= nil then
                SummonActor:SetDeath()
                BuffList[BuffID] = nil
            end
            
        end
    end
end

return SummonMgr