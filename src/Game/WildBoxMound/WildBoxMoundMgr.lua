local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local WildBoxMoundCfg = require("TableCfg/WildBoxMoundCfg")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local AudioUtil = require("Utils/AudioUtil")
local EffectUtil = require("Utils/EffectUtil")
local EObjCfg = require("TableCfg/EobjCfg")
local DataReportUtil = require("Utils/DataReportUtil")
local MajorUtil = require("Utils/MajorUtil")

local CS_CMD = ProtoCS.CS_CMD
local UE = _G.UE
local EActorType = UE.EActorType
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

local PWorldMgr = nil
local GameNetworkMgr = nil
local ClientVisionMgr = nil
local SingBarMgr = nil
local AnimMgr = nil
local BagMgr = nil
local EventMgr = nil
local ClientSetupMgr = nil

local TickInterval = 0.2
local VfxFadeInTime = 0.25

local VFXVisionDistanceType = {
    Near = 1,
    Mid = 2,
    --Far = 3,
}

-- UE默认长度单位是cm
local VFXVisionDistanceMap = {
    [VFXVisionDistanceType.Near] = 200,
    [VFXVisionDistanceType.Mid] = 800,
    --[VFXVisionDistanceType.Far] = 1000,
}

local VFXPathMap = {
    [VFXVisionDistanceType.Near] = "VfxBlueprint'/Game/Assets/Effect/Particles/Sence/YWXB/VBP/BP_Xunbao_1_3_DS.BP_Xunbao_1_3_DS_C'",
    [VFXVisionDistanceType.Mid] = "VfxBlueprint'/Game/Assets/Effect/Particles/Sence/YWXB/VBP/BP_Xunbao_1_3_DS.BP_Xunbao_1_3_DS_C'",
    --[VFXVisionDistanceType.Far] = "",
}

---@class WildBoxMoundMgr : MgrBase
local WildBoxMoundMgr = LuaClass(MgrBase)

function WildBoxMoundMgr:OnInit()
    self:ResetData()
end

function WildBoxMoundMgr:OnBegin()
    PWorldMgr = _G.PWorldMgr
    GameNetworkMgr = _G.GameNetworkMgr
    ClientVisionMgr = _G.ClientVisionMgr
    SingBarMgr = _G.SingBarMgr
    AnimMgr = _G.AnimMgr
    BagMgr = _G.BagMgr
    EventMgr = _G.EventMgr
    ClientSetupMgr = _G.ClientSetupMgr
end

function WildBoxMoundMgr:OnEnd()
    PWorldMgr = nil
    GameNetworkMgr = nil
    ClientVisionMgr = nil
    SingBarMgr = nil
    AnimMgr = nil
    BagMgr = nil
    EventMgr = nil
    ClientSetupMgr = nil
end

function WildBoxMoundMgr:OnShutdown()
    self:ResetData()
end

function WildBoxMoundMgr:ResetData()
    self.WildBoxMap = {}
    self.OpenedBoxMap = {}
    self.WildBoxVFXMap = {}
    self.MoundTimelineTimerID = nil
    self.Sound1TimerID = nil
    self.Sound2TimerID = nil
end

function WildBoxMoundMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_WILD_BOX, ProtoCS.Game.WildBox.Cmd.Update, self.OnQueryRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_WILD_BOX, ProtoCS.Game.WildBox.Cmd.OpenBox, self.OnOpenBox)
end

function WildBoxMoundMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.EnterInteractionRange, self.OnGameEventEnterInteractionRange)
    self:RegisterGameEvent(EventID.PWorldReady, self.OnGameEventPWorldReady)
end

function WildBoxMoundMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, TickInterval, 0)
end

function WildBoxMoundMgr:OnTimer()
    -- 宝箱只在野外，不在野外时不处理，减少耗时
    if not PWorldMgr:CurrIsInField() then return end

    local CurMapID = PWorldMgr:GetCurrMapResID()
    local WildBoxList = self:GetCurrentMapBoxList(CurMapID)
    if WildBoxList == nil then return end

    for _, WildBox in pairs(WildBoxList) do
        local EObjEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.EObjID, EActorType.EObj)
        if EObjEntityID and EObjEntityID > 0 then
            local EObjActor = ActorUtil.GetActorByEntityID(EObjEntityID)
            if EObjActor then
                local DistanceToMajor = EObjActor:GetDistanceToMajor()
                -- 目前只有一个特效距离，后续有需要再调整
                if DistanceToMajor > VFXVisionDistanceMap[VFXVisionDistanceType.Mid] then
                    self:StopVfx(WildBox.ID, VFXVisionDistanceType.Mid)
                else
                    local MoundEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.MoundListID, EActorType.Npc)
                    local MoundActor = ActorUtil.GetActorByEntityID(MoundEntityID)
                    if MoundActor then
                        if DistanceToMajor <= VFXVisionDistanceMap[VFXVisionDistanceType.Mid] then
                            self:TryPlayVfx(WildBox.ID, VFXVisionDistanceType.Mid, MoundActor)
                        end
                    end
                end
            end
        end
    end
end

function WildBoxMoundMgr:TryPlayVfx(WildBoxID, DistanceType, MoundActor)
    if self.WildBoxVFXMap[WildBoxID] and self.WildBoxVFXMap[WildBoxID][DistanceType] then return end

    local VfxID = self:PlayVfx(DistanceType, MoundActor)
    if VfxID then
        self.WildBoxVFXMap[WildBoxID] = {
            [DistanceType] = VfxID
        }
        FLOG_INFO("[WildBoxMoundMgr][TryPlayVfx]Play success wildBoxID:" .. WildBoxID)
    end
end

function WildBoxMoundMgr:PlayVfx(DistanceType, Actor)
    if DistanceType == nil or Actor == nil then return end

    local VfxParameter = UE.FVfxParameter()
    VfxParameter.VfxRequireData.EffectPath = VFXPathMap[DistanceType]
    VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
    VfxParameter.PlaySourceType= UE.EVFXPlaySourceType.PlaySourceType_UVfxComponent
    VfxParameter:SetCaster(Actor, 0, UE.EVFXAttachPointType.AttachPointType_Max, 0)
    local VfxID = EffectUtil.PlayVfx(VfxParameter, VfxFadeInTime)
    return VfxID
end

function WildBoxMoundMgr:StopVfx(WildBoxID, DistanceType)
    local VfxID = self.WildBoxVFXMap[WildBoxID] and self.WildBoxVFXMap[WildBoxID][DistanceType]
    if VfxID == nil then return end

    FLOG_INFO("[WildBoxMoundMgr][StopVfx]Stop success wildBoxID:" .. WildBoxID)
    EffectUtil.StopVfx(VfxID, VfxFadeInTime)
    self.WildBoxVFXMap[WildBoxID][DistanceType] = nil
end

function WildBoxMoundMgr:OnGameEventEnterInteractionRange(Params)
    local ActorType = Params.IntParam1
    if ActorType ~= UE.EActorType.EObj then return end

    local ResID = Params.ULongParam2 or 0
    local Cfg = EObjCfg:FindCfgByKey(ResID)
    if Cfg == nil or Cfg.EObjType ~= ProtoRes.ClientEObjType.ClientEObjTypeWildBox then return end

    local EntityID = Params.ULongParam1
    local EObjID = ClientVisionMgr:GetMapEditorIDByEntityID(EntityID)
    if EObjID == nil then return end

    local WildBox = self:FindWildBox(PWorldMgr:GetCurrMapResID(), EObjID)
    if WildBox == nil then return end

    self:ReportTLOG(1, WildBox.ID, 0, 0)
end

function WildBoxMoundMgr:OnGameEventPWorldReady()
    self:QueryData()
end

function WildBoxMoundMgr:QueryData()
    if not PWorldMgr:CurrIsInField() then return end
    
    -- 查询当前地图已开启宝箱
    local MapID = PWorldMgr:GetCurrMapResID()
    self:GetCurrentMapBoxList(MapID)
    self:SendQueryReq(MapID, true)
end

function WildBoxMoundMgr:GetCurrentMapBoxList(MapID)
    -- 没查过再查吧，配在表里的，单次游戏也不会变
    if nil == self.WildBoxMap[MapID] then
        local Cfgs = WildBoxMoundCfg:FindAllCfg(string.format("MapID=%d", MapID))
        local DataList = {}
        for _, Cfg in pairs(Cfgs) do
            local Data = {
                ID = Cfg.ID,
                MoundListID = Cfg.MoundListID,
                AnimalID = Cfg.AnimalListID,
                EObjID = Cfg.EmptyListID,
                DropID = Cfg.DropID,
                StartAnimID = Cfg.StartAnimID,
                EndAnimID = Cfg.EndAnimID,
                Sound1PlayTime = Cfg.Sound1PlayTime,
                Sound1Path = Cfg.Sound1Path,
                Sound2PlayTime = Cfg.Sound2PlayTime,
                Sound2Path = Cfg.Sound2Path,
            }
            table.insert(DataList, Data)
        end
        self.WildBoxMap[MapID] = DataList
    end
    return self.WildBoxMap[MapID]
end

--- 请求地图野外宝箱数据
---@param MapID uint32 地图ID
---@param ForceSend boolean 是否强制发送请求，外部模块理论上不需要true，切图时内部true刷新数据
function WildBoxMoundMgr:SendQueryReq(MapID, ForceSend)
    if MapID == nil or MapID == 0 then
        FLOG_ERROR("[WildBoxMoundMgr]Send query with invalid map id")
        return
    end

    if not ForceSend then
        if self.OpenedBoxMap[MapID] ~= nil then -- 已有数据的不需要发请求
            EventMgr:SendEvent(EventID.LoadWildBoxRangeCheckData, MapID)
            return
        end
    end

	local MsgID = CS_CMD.CS_CMD_WILD_BOX
	local SubMsgID = ProtoCS.Game.WildBox.Cmd.Update
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.UpdateReq = {MapID = MapID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function WildBoxMoundMgr:OnQueryRsp(MsgBody)
    local UpdateRsp = MsgBody.UpdateRsp
    local MoundIDs = UpdateRsp.OpenMoundIDs
    local MapID = UpdateRsp.MapID
    self.OpenedBoxMap[MapID] = MoundIDs
    -- 销毁当前已经挖掘的土堆&小动物&交互空eobj
    self:DestroyOpenedWildBox(MapID, MoundIDs)
    EventMgr:SendEvent(EventID.LoadWildBoxRangeCheckData, MapID)
end

function WildBoxMoundMgr:DestroyOpenedWildBox(MapID, MoundIDs)
    if nil ~= MoundIDs then
        for i = 1, #MoundIDs do
            local WildBoxList = self:GetCurrentMapBoxList(MapID)
            for _, WildBox in ipairs(WildBoxList) do
                if (WildBox.ID == MoundIDs[i]) then
                    if WildBox.MoundListID and WildBox.MoundListID > 0 then
                        local MoundEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.MoundListID, EActorType.Npc)
                        if MoundEntityID and MoundEntityID > 0 then
                            ClientVisionMgr:DestoryClientActor(MoundEntityID, EActorType.Npc)
                        end
                    end
                    if WildBox.AnimalID and WildBox.AnimalID > 0 then
                        local AnimalEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.AnimalID, EActorType.Npc)
                        if AnimalEntityID and AnimalEntityID > 0 then
                            ClientVisionMgr:DestoryClientActor(AnimalEntityID, EActorType.Npc)
                        end
                    end
                    if WildBox.EObjID and WildBox.EObjID > 0 then
                        local EObjEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.EObjID, EActorType.EObj)
                        if EObjEntityID and EObjEntityID > 0 then
                            ClientVisionMgr:DestoryClientActor(EObjEntityID, EActorType.EObj)
                            FLOG_INFO("[WildBoxMoundMgr][DestroyOpenedWildBox]Stop vfx box:" .. WildBox.ID)
                            self:StopVfx( WildBox.ID, VFXVisionDistanceType.Mid)
                        end
                    end
                end
            end
        end
    end
end

function WildBoxMoundMgr:OnOpenBox(MsgBody)
    -- 新手引导处理
    self:HandleTutorial()

    local Rsp = MsgBody.OpenBoxRsp
    if Rsp == nil then return end

    local MapID = Rsp.MapID
    local OpenedID = Rsp.MoundID
    WildBoxMoundMgr:SetOpenedBox(MapID, OpenedID)

    local WildBox = self:FindWildBox(MapID, nil, OpenedID)
    if WildBox == nil then return end

    -- 刪除EObj
    local ListID = WildBox.EObjID
    local EObjEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(ListID, EActorType.EObj)
    if EObjEntityID then
        ClientVisionMgr:DestoryClientActor(EObjEntityID, EActorType.EObj)
        EventMgr:SendEvent(EventID.RemoveWildBoxRangeCheckDataByBoxOpened, EObjEntityID, ListID)
        -- 打开宝箱后停止特效
        FLOG_INFO("[WildBoxMoundMgr][OnOpenBox]Stop vfx box:" .. WildBox.ID)
        self:StopVfx(WildBox.ID, VFXVisionDistanceType.Mid)
    end

    -- 设置土堆动画
    local MoundEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.MoundListID, EActorType.Npc)
    if MoundEntityID then
        local MoundActor = ActorUtil.GetActorByEntityID(MoundEntityID)
        if MoundActor then
            local AnimationComponent = ActorUtil.GetActorAnimationComponent(MoundEntityID)
            if AnimationComponent then
                -- 宝箱打开后，默认idle动画设置为宝箱打开动画
                AnimationComponent:SetIdleActionTimeline(50045)
            end
        end
    end

    self:ReportTLOG(2, OpenedID, 1, 0)

    -- 使用通用储存功能记录是否开启过任意宝箱
    local RecordContent = ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ProtoCS.ClientSetupKey.CSKWildBoxOpen)
    if string.isnilorempty(RecordContent) then
        ClientSetupMgr:SetWildBoxOpen("TRUE")
    end
end

function WildBoxMoundMgr:HandleTutorial()
    --新手引导野外宝箱处理
    local function OnDiggingMoundTutorial(Params)
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.DiggingMound--新手引导触发类型
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnDiggingMoundTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

function WildBoxMoundMgr:SendOpenBoxReq(MoundId)
	local MsgID = CS_CMD.CS_CMD_WILD_BOX
	local SubMsgID = ProtoCS.Game.WildBox.Cmd.OpenBox
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    MsgBody.OpenBoxReq = {MoundID = MoundId}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 设置当前ID已被挖
function WildBoxMoundMgr:SetOpenedBox(MapID, ID)
    local OpenedBoxMap = self.OpenedBoxMap[MapID]
    if not OpenedBoxMap then
        self.OpenedBoxMap[MapID] = {}
    end
    if not table.contain(self.OpenedBoxMap[MapID], ID) then
        table.insert(self.OpenedBoxMap[MapID], ID)
    end
end

function WildBoxMoundMgr:IsMoundOpened(ID)
    local MapID = PWorldMgr:GetCurrMapResID()
    local OpenedBoxMap = self.OpenedBoxMap and self.OpenedBoxMap[MapID]
    if not OpenedBoxMap then
        return false
    end
    return table.contain(OpenedBoxMap, ID)
end

---判断是否可显示NPC
---@param EObjID int32
---@return boolean
function WildBoxMoundMgr:CanShowNPC(MapID, NpcID)
    if not PWorldMgr:CurrIsInField() then return false end

    local WildBoxList = self:GetCurrentMapBoxList(MapID)
    if WildBoxList == nil then return false end
    local OpenedBoxMap = self.OpenedBoxMap[MapID]
    if OpenedBoxMap == nil then return true end

    for _, ID in pairs(OpenedBoxMap) do
        for _, WildBox in pairs(WildBoxList) do
            if ID == WildBox.ID then
                if WildBox.MoundListID == NpcID or WildBox.AnimalID == NpcID then
                    return false
                end
            end
        end
    end

    return true
end

--- 判断宝箱是否已打开
---@param MapID int32
---@param EObjID int32
---@return boolean
function WildBoxMoundMgr:IsBoxOpened(MapID, EObjID)
    local WildBoxList = self:GetCurrentMapBoxList(MapID)
    for _, WildBox in ipairs(WildBoxList) do
        if WildBox.EObjID == EObjID then
            if nil == self.OpenedBoxMap[MapID] then return false end

            return table.contain(self.OpenedBoxMap[MapID], WildBox.ID)
        end
    end

    return false
end

---判断是否可显示空EObj
---@param EObjID int32
---@return boolean
function WildBoxMoundMgr:CanCreateEObj(MapID, EObjID)
    if not PWorldMgr:CurrIsInField() then return false end

    return not self:IsBoxOpened(MapID, EObjID)
end

function WildBoxMoundMgr:OpenBox(InteractiveDescID, InteractiveEntityID, ListID)
    local function CallBack(IsBreak, EntityID, ListID)
        self:SingBarEndCallback(IsBreak, EntityID, ListID)
    end

    local MapID = PWorldMgr:GetCurrMapResID()
    local WildBox = self:FindWildBox(MapID, ListID)
    if WildBox == nil then return end

    -- 挖掘前判断玩家是否有足够背包空位
    if self:IsBagSpaceEnough(WildBox.DropID) then
        local InteractSuccess = SingBarMgr:MajorSingByInteractiveID(InteractiveDescID, InteractiveEntityID, ListID, CallBack)
        if not InteractSuccess then return end

        local MoundEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.MoundListID, EActorType.Npc)
        -- 土堆抖动动画
        local MoundStartActiontimelineCfg = ActiontimelinePathCfg:FindCfgByKey(WildBox.StartAnimID)
        if MoundStartActiontimelineCfg then
            AnimMgr:PlayActionTimeLine(MoundEntityID, MoundStartActiontimelineCfg.Filename)
        end

        -- 过1.5秒播放宝箱弹出动画
        local DelayTime = 1.5
        local MoundEndActiontimelineCfg = ActiontimelinePathCfg:FindCfgByKey(WildBox.EndAnimID)
        if MoundEndActiontimelineCfg then
            self.MoundTimelineTimerID = self:RegisterTimer(function()
                AnimMgr:PlayActionTimeLine(MoundEntityID, MoundEndActiontimelineCfg.Filename)
            end, DelayTime)
        end

        if not string.isnilorempty(WildBox.Sound1Path) then
            self.Sound1TimerID = self:RegisterTimer(function()
                AudioUtil.LoadAndPlayUISound(WildBox.Sound1Path)
            end, WildBox.Sound1PlayTime)
        end
        if not string.isnilorempty(WildBox.Sound2Path) then
            self.Sound2TimerID = self:RegisterTimer(function()
                AudioUtil.LoadAndPlayUISound(WildBox.Sound2Path)
            end, WildBox.Sound2PlayTime)
        end
    else
        MsgTipsUtil.ShowTipsByID(MsgTipsID.WildBoxBagFull)
    end
end

function WildBoxMoundMgr:SingBarEndCallback(IsBreak, EntityID, ListID)
    local MapID = PWorldMgr:GetCurrMapResID()
    local WildBox = nil
    if ListID and ListID > 0 then
        WildBox = self:FindWildBox(MapID, ListID)
    end

    -- IsBreak参数  ture：被打断了  false：正常结束
    if IsBreak then
        if WildBox then
            local MoundEntityID = ClientVisionMgr:GetEntityIDByMapEditorID(WildBox.MoundListID, EActorType.Npc)
            if (MoundEntityID ~= nil) then
                local MoundActor = ActorUtil.GetActorByEntityID(MoundEntityID)
                if MoundActor then
                    -- 打断交互后停止动画
                    local AnimationComponent = ActorUtil.GetActorAnimationComponent(MoundEntityID)
                    if AnimationComponent then
                        local AnimationInstance = AnimationComponent:GetAnimInstance()
                        local BlendOutTime = 0.25
                        if AnimationInstance then
                            AnimationInstance:Montage_Stop(BlendOutTime)
                        end
                    end

                    -- 打断交互后复原沙堆外观
                    local AvatarComponent = MoundActor:GetAvatarComponent()
                    if AvatarComponent then
                        AvatarComponent:ShowPartMaterialSection(99999, UE.EAvatarCustomizeOption.PART_ALL)
                    end
                end
            end

            self:ReportTLOG(2, WildBox.ID, 2, 1)
        end

        self:ClearTimers()
        return
    end

    if WildBox then
        -- 请求发奖
        WildBoxMoundMgr:SendOpenBoxReq(WildBox.ID)
    end
end

--- 检查背包是否有足够空位获取奖励
---@param DropID int32 掉落ID
---@return bool 是否有空位
function WildBoxMoundMgr:IsBagSpaceEnough(DropID)
    local BagSpace = BagMgr:GetBagLeftNum()
    local IgnoreList = {
        19000002,   -- 金币
        19000099,   -- 经验
    }

    local LootMappingCfgs = LootMappingCfg:FindAllCfg(string.format("ID = %d", DropID))
    for _, LootMappingCfg in ipairs(LootMappingCfgs or {}) do
        if LootMappingCfg then
            for _, Program in pairs(LootMappingCfg.Programs) do
                local LootID = Program.ID
                if LootID ~= 0 then
                    local RewardItemTotalCount = 0
                    local RewardItemList = ItemUtil.GetLootItems(LootID)
                    for _, Item in ipairs(RewardItemList) do
                        if not table.contain(IgnoreList, Item.ResID) then -- IgnoreList以外的物品才算空间
                            RewardItemTotalCount = RewardItemTotalCount + Item.Num
        
                            if RewardItemTotalCount > BagSpace then
                                return false
                            end
                        end
                    end
                end
            end
        end
    end

    return true
end

function WildBoxMoundMgr:ClearTimers()
    if self.MoundTimelineTimerID then
        self:UnRegisterTimer(self.MoundTimelineTimerID)
        self.MoundTimelineTimerID = nil
    end

    if self.Sound1TimerID then
        self:UnRegisterTimer(self.Sound1TimerID)
        self.Sound1TimerID = nil
    end

    if self.Sound2TimerID then
        self:UnRegisterTimer(self.Sound2TimerID)
        self.Sound2TimerID = nil
    end
end

--- 透过EObjID找到对应宝箱
---@param MapID uint32 地图ID
---@param EObjID uint32 交互物ListID
---@param WildBoxID uint32 宝箱ID
---@return table 宝箱数据
function WildBoxMoundMgr:FindWildBox(MapID, EObjID, WildBoxID)
    local WildBox = nil
    if EObjID == nil and WildBoxID == nil then return WildBox end

    local BoxList = self:GetCurrentMapBoxList(MapID)
    for _, Box in ipairs(BoxList or {}) do
        if EObjID then
            if Box.EObjID == EObjID then
                WildBox = Box
                break
            end
        elseif WildBoxID then
            if Box.ID == WildBoxID then
                WildBox = Box
                break
            end
        end
    end

    return WildBox
end

--- 是否开启过任意宝箱
---@return boolean
function WildBoxMoundMgr:IsOpenAnyBox()
    local IsOpen = ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ProtoCS.ClientSetupKey.CSKWildBoxOpen)
    if not string.isnilorempty(IsOpen) then
        return IsOpen == "TRUE"
    end

    return false
end

--- 获取地图已开启宝箱ID列表
---@return table 宝箱IDList
function WildBoxMoundMgr:GetOpenedBoxList(MapID)
    local OpenedList = self.OpenedBoxMap and self.OpenedBoxMap[MapID]
    if OpenedList == nil then return end

    local Result = {}
    for _, ID in ipairs(OpenedList) do
        table.insert(Result, ID)
    end

    return Result
end

function WildBoxMoundMgr:ReportTLOG(OpType, BoxID, Result, Reason)
    DataReportUtil.ReportData("WildBoxFlow", true, false, true,
		"OpType", tostring(OpType),
		"BoxID", tostring(BoxID),
        "Result", tostring(Result),
        "Reason", tostring(Reason))
end

return WildBoxMoundMgr