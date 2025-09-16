
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local MsgTipsID = require("Define/MsgTipsID")
local TimeUtil = require("Utils/TimeUtil")
local NpcCfg = require("TableCfg/NpcCfg")

---@class EntranceBase
local EntranceBase = LuaClass()
local EActorType = _G.UE.EActorType

-- 需要子类实现的有，可以参考EntranceNpc
-- OnInit               计算Distance、入口的显示字符串
-- OnUpdateDistance     计算Distance，以供排序用
-- OnGenFunctionList    获取该入口的二级交互列表
--                      一般是交互表中配置，再或者是新增Function类型，如果QUEST_FUNC那样，最后新增一个QUIT_FUNC类型的Function
-- OnClick              入口点击的响应逻辑；可以转掉新系统的mgr去处理，也可以直接处理
--                      InteractiveMgr:OnEntranceClick会有个优先处理相应的机会

function EntranceBase:Ctor()
    self.DisplayName = ""
    self.Distance = 0
    self.IconPath = "PaperSprite'/Game/UI/Atlas/NPCTalk/Frames/UI_Icon_NPC_Dialogue_png.UI_Icon_NPC_Dialogue_png'"
    self.SelectPriority = 0
    self.InteractivePriority = 0
    self.IsWithMainQuest = 0
    self.TargetName = ""
    self.EnableSwitch = true
    self.EntranceClickInterval = 200  --毫秒
end

function EntranceBase:Init(EntranceParams, ExtraParam)
    --目前有Npc、Gather等Actor类型
    --虚拟的就从1000开始定义，比如矿场：1001
    self.TargetType = EntranceParams.IntParam1
    self.EntityID = EntranceParams.ULongParam1
    self.ResID = EntranceParams.ULongParam2
    self.ListID = EntranceParams.ULongParam3
    -- click时，默认立即转向
    self.DefaultTurn = true

    --根据初始参数，预先计算出来或者设置上
    --计算Distance、DisplayName
    if nil ~= ExtraParam then
        self:OnInit(ExtraParam)
    else
        self:OnInit()
    end
end

function EntranceBase:UpdateDistance()
    --计算Distance，以供排序用
    self:OnUpdateDistance()
end

function EntranceBase:CanInterative(EnableCheckLog)
    return self:CheckInterative(EnableCheckLog)
end

--false：有阻挡  true：无eyeline阻挡
function EntranceBase:CheckEyeLineBlock()
    local EntranceActor = ActorUtil.GetActorByEntityID(self.EntityID)
    if not EntranceActor then
        return false
    end

    -- local Major = MajorUtil.GetMajor()
    -- if Major then
    --     -- local EntranceHalf = EntranceActor:GetCapsuleHalfHeight()
    --     -- local MajorHalf = Major:GetCapsuleHalfHeight()
    --     -- local ZMax = EntranceHalf
    --     -- if MajorHalf > EntranceHalf then
    --     --     ZMax = MajorHalf
    --     -- end

    --     -- local Offset = _G.UE.FVector(0, 0, ZMax + 20)
    --     local EntranceActorPos = EntranceActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    --     local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
    --     if  _G.UE.UActorUtil.EyeLineTraceByPos(MajorPos, EntranceActorPos) then
    --         -- FLOG_WARNING("InteractiveMgr %d Cann't See", self.EntityID)
    --         return false
    --     end
    -- end

    return true
end

function EntranceBase:UpdateUI()
    _G.EventMgr:SendEvent(EventID.EntranceItemChanged, self)
end

function EntranceBase:GenFunctionList()
    return self:OnGenFunctionList()
end

function EntranceBase:Click()
    local CurServerTime = TimeUtil.GetServerTimeMS()
    local EntranceLastClickTime = InteractiveMgr:GetEntranceLastClickTime()
	if (CurServerTime - EntranceLastClickTime) < self.EntranceClickInterval then
        _G.FLOG_WARNING("EntranceBase:Click, click too fast!")
		return
	end

    InteractiveMgr:SetEntranceLastClickTime(CurServerTime)

    local ActorName = ActorUtil.GetActorName(self.EntityID)
    InteractiveMgr:PrintInfo("Interactive EntranceBase %s Click, Target: %s, TargetType:%d", self.DisplayName, ActorName, self.TargetType)
    
    local Major = MajorUtil.GetMajor()
    if Major and Major:IsInFly() then
        MsgTipsUtil.ShowTips(_G.LSTR(90033))
        return 
    end

    -- 检查主角当前的状态是否可以进行交互操作
    if not InteractiveMgr:IsCanDoBehavior() then
        return
    end

    -- 死亡状态下不支持交互操作
    -- if MajorUtil.IsMajorDead() == true then
    --     _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.DeadStateCantInteraction)
    --     return
    -- end
    
    if self.EntityID and self.DefaultTurn then
        -- 设置一下速度
        local ZeroVector = _G.UE.FVector(0, 0, 0)
        Major:SetCharacterMove(ZeroVector, 0, true, false)
        MajorUtil.LookAtActor(self.EntityID)
        --InteractiveMgr:LookAtTarget(self.EntityID)
    end

    --主角在坐骑上时，点击交互先下坐骑，然后再触发
    if Major ~= nil and Major:GetRideComponent() ~= nil then
        local RideComp = Major:GetRideComponent()
        if RideComp:IsInRide() then
            if Major.CharacterMovement then
                if Major.CharacterMovement.Velocity.Z ~= 0 then
                    MsgTipsUtil.ShowTips(_G.LSTR(90004))
                    return
                end
            end
         
            --在坐骑上不能坐椅子
            if self.SitDownEmotionID == 50 then
                MsgTipsUtil.ShowTips(_G.LSTR(90005))
                return
            end

            local function CancelCallback()
                -- 检测一下当前是否出交互距离
                local ActorType = ActorUtil.GetActorType(self.EntityID)
                if ActorType == EActorType.NPC then 
                    local MajorActor = MajorUtil.GetMajor()
                    local NPCActor = ActorUtil.GetActorByEntityID(self.EntityID)
                    local Cfg = NpcCfg:FindCfgByKey(self.ResID)
                    if MajorActor == nil or NPCActor == nil or Cfg == nil then
                        return
                    end

                    local MajorPos = MajorActor:FGetActorLocation()
                    local NPCActorPos = NPCActor:FGetActorLocation()
                    local NPCDistanceToMajor = ((NPCActorPos.X - MajorPos.X) ^ 2) + ((NPCActorPos.Y - MajorPos.Y) ^ 2) + ((NPCActorPos.Z - MajorPos.Z) ^ 2)
                    if NPCDistanceToMajor > Cfg.InteractionRange ^ 2 then
                        MsgTipsUtil.ShowTips(_G.LSTR(90031))
                        return
                    end
                end
                if self.EntityID and self.DefaultTurn then
                    MajorUtil.LookAtActor(self.EntityID)
                    --InteractiveMgr:LookAtTarget(self.EntityID)
                end
                local rlt = nil
                if not InteractiveMgr:OnEntranceClick(self) then
                    rlt = self:OnClick()
                end
                --InteractiveMgr:SetCancelMountingState(false)
            end
            --InteractiveMgr:SetCancelMountingState(true)
            _G.MountMgr:SendMountCancelCall(CancelCallback)
            _G.EventMgr:SendEvent(EventID.ClickEntranceItems)
            return
        end
    end

    --先给Mgr一个处理的机会，如果处理过了，就不用到子类的了
    --也要给InteractiveMgr一个预处理的机会，比如记录当前交互的EntityID，如果以后有需要，就记录EntranceBase
    local rlt = nil
    if not InteractiveMgr:OnEntranceClick(self) then
        rlt = self:OnClick()
    end

    --隐藏一级交互列表
    if not rlt then
        _G.EventMgr:SendEvent(EventID.ClickEntranceItems)
    end
end

function EntranceBase:AdapterOnGetWidgetIndex()
    --现在只有一种入口，所以只是提供这一个接口，固定的返回0了
    --以后有需要可以类似FunctionBase那样处理，让外部创建的时候指定EntryWidgetIndex

	return 0
end

function EntranceBase:GetEntranceItemSizeY()
    if self.EntryWidgetIndex == 0 then
        return 100
    else
        return 125
    end
end

function EntranceBase:SetSelectPriority(Priority)
    self.SelectPriority = Priority
end

---GetIconPath
---@return string
function EntranceBase:GetIconPath()
    return self.IconPath
end

function EntranceBase:MergeIdList(IdListOne, IdListTwo)
    local MergedIdList = {}
    local ProcessedValues = {}

    if nil ~= IdListOne then
        for _, value in ipairs(IdListOne) do
            MergedIdList[#MergedIdList + 1] = value
            ProcessedValues[value] = true
        end
    end

    if nil ~= IdListTwo then
        for _, value in ipairs(IdListTwo) do
            if not ProcessedValues[value] then
                MergedIdList[#MergedIdList + 1] = value
                ProcessedValues[value] = true
            end
        end
    end

    return MergedIdList
end

return EntranceBase
