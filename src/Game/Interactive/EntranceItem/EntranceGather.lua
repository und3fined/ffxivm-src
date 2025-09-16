
local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local NpcCfg = require("TableCfg/NpcCfg")
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsID = require("Define/MsgTipsID")
local MajorUtil = require("Utils/MajorUtil")

local EntranceGather = LuaClass(EntranceBase)
function EntranceGather:Ctor()
    self.TargetType = _G.UE.EActorType.Gather
end

--计算Distance、入口的显示字符串
function EntranceGather:OnInit()
    --ResID仅仅是该入口的1个采集物，但是是相同类型的
	local Cfg = GatherPointCfg:FindCfgByKey(self.ResID)
    if not Cfg then
        return
    end

    --显示的入口名字，按职业来： 采矿工为矿脉，园艺工为植被
    -- local JobName = GatherMgr.GatherTypeName[Cfg.GatherType]
    -- if not JobName then
    --     JobName = Cfg.Name
    -- end

    -- if not JobName then
    --     JobName = "UnKnown"
    -- end

    self.IconPath = _G.GatherMgr.GatherInteractiveConfig[Cfg.GatherType].Icon

    self.DisplayName = Cfg.Name--JobName
    --self.TargetName = Cfg.Name
    self.IsNoExitFunction = false
    self.IsSelectOtherGatherPoint = false

    self.Cfg = Cfg
    self.GatherType = Cfg.GatherType
    if not self.Distance or self.Distance <= 0 and self.EntityID then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        end
    end
end

function EntranceGather:CheckInterative(EnableCheckLog)
    if self.IsSelectOtherGatherPoint then
        return false
    end
    
    return true
end

function EntranceGather:OnUpdateDistance()
    if self.EntityID > 0 then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)

        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        else
            self.EntityID = 0
        end
    end
end

--Entrance的响应逻辑
function EntranceGather:OnClick()
    if MajorUtil.IsMajorCombat() then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherCombatState)
        return true
    end

    local MoveComp = MajorUtil.GetMajor():GetMovementComponent()
    if MoveComp then
       if MoveComp:IsFalling() then
            -- 在空中时无法
            _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.CurPosCannotGather)
            return true
       end
    end

    if self.GatherType == nil then
        return true
    end

    _G.UE.UActorManager.Get():SetVirtualJoystickIsSprintLocked(false)

    if self.GatherType == ProtoRes.GATHER_POINT_TYPE.GATHER_POINT_TYPE_STONE or
        self.GatherType == ProtoRes.GATHER_POINT_TYPE.GATHER_POINT_TYPE_GRASS then
        local IsEquitSlaveHandPart = _G.EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND)
        if IsEquitSlaveHandPart then
            _G.GatherMgr:SendEnterGatherState(self)
        else
            if self.GatherType == ProtoRes.GATHER_POINT_TYPE.GATHER_POINT_TYPE_STONE then
                _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherStoneNoSlaveTool, nil)
            elseif self.GatherType == ProtoRes.GATHER_POINT_TYPE.GATHER_POINT_TYPE_GRASS then
                _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherGrassNoSlaveTool, nil)
            end
    
            return true
        end
    else
        _G.GatherMgr:SendEnterGatherState(self)
    end
    -- --GatherMgr直接弹出二级交互，不在由EntranceGather:OnGenFunctionList产生二级列表了
    -- local FunctionList = self:GenFunctionList()

    -- if #FunctionList > 0 then
    --     -- 展示功能选项列表
    --     InteractiveMgr:SetFunctionList(FunctionList)
    --     _G.GatherMgr:SendEnterGatherState(self.EntityID)
    -- end
    return true
end

function EntranceGather:OnGenFunctionList()
    --现在用不到了，GatherMgr收到进入状态的回包直接Gen二级列表
    return {}
    -- return GatherMgr:OnGenFunctionList(self, self.IsNoExitFunction)
end

return EntranceGather
