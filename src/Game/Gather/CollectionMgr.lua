local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SkillUtil = require("Utils/SkillUtil")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EventID = require("Define/EventID")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local EffectUtil = require("Utils/EffectUtil")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsID = require("Define/MsgTipsID")
local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
local CommonUtil = require("Utils/CommonUtil")
--local GatheringJobSkillPanelView = require("Game/GatheringJob/View/GatheringJobSkillPanelView")

local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD
local Delay = 0.4

local CollectionMgr = LuaClass(MgrBase)
function CollectionMgr:OnInit() 
    self.HideTimer = 0
    self.CollectionIconPath =
        "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Icon_Collect_png.UI_Comm_Icon_Collect_png'" 
end

function CollectionMgr:OnBegin()
    self.EffectNodeMap = {}
    self.SkillEffectIDMap = {}
    self.SkillIndex = -1
    self.OnClickCollectSkill = false
    self.LastTimeSkill = false
    self.UpdatePrivateGatherMsg = nil
    self.OnShowGatheringJobSkillPanel = nil
end

function CollectionMgr:OnEnd()
    self.EffectNodeMap = {}
    if self.SkillEffectIDMap then
        for _, value in pairs(self.SkillEffectIDMap) do
            EffectUtil.StopVfx(value)
        end
    end
    self.SkillEffectIDMap = {}
    self.LastTimeSkill = false
    self.UpdatePrivateGatherMsg = nil
end

function CollectionMgr:OnShutdown() 
end

function CollectionMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_COLLECTION_CMD, self.OnNetMsgCollection)
end

function CollectionMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnAddLifeSkillBuff)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorCreate)
    --self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
    self:RegisterGameEvent(EventID.GatherSkillEffect, self.OnSkillEffect)
end

function CollectionMgr:OnMajorCreate()
    if MajorUtil.IsGatherProf() then
        self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
    else
        self:UnRegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
    end
end

function CollectionMgr:OnNetMsgCollection(MsgBody)
    local CollectionRsp = MsgBody.Collection
    if CollectionRsp == nil then
        return
    end
    if CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_ENTER then
        self:OnEnterCollection(true, CollectionRsp)
    elseif CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_ENTER_FAIL then
        self:OnEnterCollection(false, CollectionRsp)
    elseif
        self.AddLifeSkillBuff and self.SkillIndex == 2 and
            CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_SCOUR
     then
        self.AddLifeSkillBuff = false
        self:DoGatherResult(MsgBody)
    else
        self:RefreshEffect(MsgBody)
    end
end

function CollectionMgr:RefreshEffect(MsgBody)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local EffectNode = self.EffectNodeMap[MsgBody.ObjID]
    --local EffectNode = self.EffectNodeMap[MajorEntityID]
    if EffectNode then
        local SkillID = MsgBody.LifeSkillID
        if SkillID == EffectNode.SkillID then
            if EffectNode.IsSkillEnd or EffectNode.IsDoneSkillEffectEvent then
                --如果技能表现已经结束了，则不进行特效表现了;  直接进行结果表现
                self:DoGatherResult(MsgBody)
                self.EffectNodeMap[MsgBody.ObjID] = nil
            else
                --技能还在进行中
                --先缓存，等技能表现结束的时候再播放技能结果的特效
                EffectNode.Msg = MsgBody
                self.EffectNodeMap[MsgBody.ObjID] = EffectNode
            end
        end
    else
        --主角：没找到这种情况应该是不存在的：cast的时候有，skillend只是标记
        --第三方同步过来的
        if MsgBody.ObjID ~= MajorEntityID then
            self.EffectNodeMap[MsgBody.ObjID] = {Msg = MsgBody, IsSkill = true, SkillID = MsgBody.LifeSkillID}
        end
    end
end

function CollectionMgr:OnSkillEffect(Params)
    FLOG_INFO("CollectionMgr OnSkillEffect")
    local EntityID = Params.ULongParam1 --MajorEntityID 技能释放者

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        EffectNode.IsDoneSkillEffectEvent = true

        local CurEffectID = self.SkillEffectIDMap[EntityID]
        if CurEffectID then
            EffectUtil.StopVfx(CurEffectID) -- 打断之前的效果
        end

        local GatherToolID = _G.ActorMgr:GetTool(EntityID) --使用的工具
        local MajorProfID = MajorUtil.GetMajorProfID()
        local Config = _G.GatherMgr.ProfConfig[MajorProfID] --本职业的效果的配置
        if not Config then
            return
        end

        --1：成功 2：miss 3：收藏品 4：优质采集
        local SkillEffectList = Config.MainSkillEffect
        local SoundList = Config.MainSkillSound
        -----如果使用的工具是副手，就换副手的效果配置
        if Config.SecondWeapon == GatherToolID then
            SkillEffectList = Config.SecondSkillEffect
            SoundList = Config.SecondSkillSound
        end

        --播放技能成功、失败的特效
        local SkillEffectPath = nil
        local SoundPath = nil

        if EffectNode.Msg then
            if EffectNode.Msg.Collection.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_FAIL then
                SkillEffectPath = SkillEffectList[2]
                SoundPath = SoundList[2]
            elseif EffectNode.Msg.Collection.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_COLLECT then
                SkillEffectPath = SkillEffectList[1]
                SoundPath = SoundList[1]
            elseif EffectNode.Msg.Collection.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_SCOUR then
                if self.SkillIndex ~= -1 then
                    if EffectNode.Msg.Collection.ValueUp then
                        if self.SkillIndex == 3 or self.SkillIndex == 5 then
                            SkillEffectPath = Config.CollectionEffect[2]
                        elseif self.SkillIndex == 4 then
                            SkillEffectPath = Config.CollectionEffect[3]
                        end
                        SoundPath = Config.CollectionSound[2]
                    else
                        SkillEffectPath = Config.CollectionEffect[1]
                        SoundPath = Config.CollectionSound[1]
                    end
                end
            end

            if SkillEffectPath then
                self:PlayEffect(EntityID, SkillEffectPath, self.SkillEffectIDMap, nil)
            end
            if SoundPath then
                AudioUtil.LoadAndPlaySoundEvent(EntityID, SoundPath)
            end
        else
            FLOG_WARNING("=========CollectionMgr OnSkillEffectEvent, bug Msg is nil")
        end

        --技能特效结束后的处理
        local function OnSkillEffectOver()
            --如果有记录结果，则进行结果的表现
            EffectNode = self.EffectNodeMap[EntityID]
            if not EffectNode then
                return
            end

            if EffectNode.Msg then
                FLOG_INFO("====CollectionMgr OnSkillEffectOver, to play Result Effect")
                self:DoGatherResult(EffectNode.Msg)
                --self.EffectNodeMap[EntityID] = nil
                --不能在这里变成nil，等skillend再变，不然连续触发的时候在self.CastSkilll()方法里,self.EffectNodeMap[EntityID]会被替换为一个没有Msg的EffectNode
            else
                FLOG_INFO("====CollectionMgr OnSkillEffectOver, but msg is nil")
            end
            EffectNode.DelayResultDisplayTimerID = nil
        end

        EffectNode.DelayResultDisplayTimerID =
        self:RegisterTimer( OnSkillEffectOver, _G.GatherMgr.DelayResultDisplayTime, 1, 1)
    end
end

function CollectionMgr:DoGatherResult(MsgBody)
    if self.IsCollectionState == false then
        return --已经手动退出了
    end
    FLOG_INFO("CollectionMgr:DoGatherResult")
    local CollectionRsp = MsgBody.Collection
    if CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_SCOUR then --提纯类技能
        self:OnCollectionScour(CollectionRsp)
    elseif CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_COLLECT then --收藏品采集成功战利品
        self.SkillIndex = -1
        self.OnClickCollectSkill = false
        self:OnCollectionSkillRlt(CollectionRsp)
        self:OnCollectionScour(CollectionRsp)
    elseif CollectionRsp.OP_Type == ProtoCS.Gather_Collection_OP.COLLECTION_FAIL then --采集失败
        self.SkillIndex = -1
        self.OnClickCollectSkill = false
        --采集成功率100%
        FLOG_ERROR("CollectionRsp.OP_Type is ProtoCS.Gather_Collection_OP.COLLECTION_FAIL")
    end
    --这里不能执行刷新采集点的消息，否则会在收藏品进度刷新前就界面关闭了
end

function CollectionMgr:PlayEffect(EntityID, EffectPath, EffectIDMap, CompleteCallBack)
    --_G.EventMgr:SendEvent(EventID.OnCastSkillUpdateMask, true)
    local CasterActor = ActorUtil.GetActorByEntityID(EntityID)
    if not CasterActor then
        return
    end

     local TargetEffectID = EffectIDMap[EntityID]
    if TargetEffectID then
        EffectUtil.StopVfx(TargetEffectID,0,0)
    end
    
    local VfxParameter = _G.UE.FVfxParameter()
    local MajorID = MajorUtil.GetMajorEntityID()
    if MajorID ~= EntityID then
        VfxParameter.LODLevel = EffectUtil.GetPlayerEffectLOD()
    else
        VfxParameter.LODLevel = EffectUtil.GetMajorEffectLOD()
    end

    local Path = CommonUtil.ParseBPPath(EffectPath)
    VfxParameter.VfxRequireData.EffectPath = Path

    local GatherActor = ActorUtil.GetActorByEntityID(_G.GatherMgr.CurActiveEntityID)
    local TargetTransform = _G.UE.FTransform()
    if GatherActor then
        TargetTransform:SetLocation(GatherActor:FGetActorBaseLocation())
    end
    VfxParameter.VfxRequireData.VfxTransform = TargetTransform
    --VfxParameter.VfxRequireData.VfxTransform = GatherActor:GetTransform()
    --无EID的物体 不传Caster和Target 通过Transform来指定
    --VfxParameter:SetCaster(GatherActor, 0, 0, 0)
    --VfxParameter:AddTarget(GatherActor, 0, 0, 0)
    TargetEffectID = EffectUtil.PlayVfx(VfxParameter)
    EffectIDMap[EntityID] = TargetEffectID
end

function CollectionMgr:OnSkillEnd(Params)
    local EntityID = Params.ULongParam1
    --FLOG_INFO("CollectionMgr OnSkillEnd")

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        EffectNode.IsSkillEnd = true
        self.EffectNodeMap[EntityID] = nil
    end
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID == EntityID then
        _G.EventMgr:SendEvent(EventID.OnCastSkillUpdateMask, false)
    end
end

function CollectionMgr:CastSkill(index, SkillID, IsExpendDurability)
    if IsExpendDurability then
        --如果释放(消耗耐久的)技能时是最后一次耐久，LIFE_SKILL_PRIVATE_GATHER_CMD消息要最后执行（会移除采集点，退出采集状态，在此之前保证收藏面板的刷新，收藏状态的退出）
        local LeftTimes = _G.GatheringJobSkillPanelVM.LeftTimes
        if type(LeftTimes) == "number" and LeftTimes == 1 then
            self.LastTimeSkill = true
        end
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if self.EffectNodeMap[MajorEntityID] ~= nil then
        _G.FLOG_ERROR("CollectionMgr:CastSkill self.EffectNodeMap[MajorEntityID] ~= nil")
        return false
    end
    local EffectNode = {EntityID = MajorEntityID, Msg = nil, IsSkill = true, SkillID = SkillID}
    --先缓存，等技能表现结束的时候再播放技能结果的特效
    self.EffectNodeMap[MajorEntityID] = EffectNode

    SkillUtil.CastLifeSkill(index, SkillID)
    _G.EventMgr:SendEvent(_G.EventID.OnCastSkillUpdateMask, true)
    return true
end

function CollectionMgr:OnAddLifeSkillBuff(BuffInfo)
    FLOG_INFO(string.format("CollectionMgr:OnAddLifeSkillBuff(%d)", BuffInfo.BuffID))
    local CollectionRsp = _G.GatheringJobSkillPanelVM.CollectionRsp
    _G.GatheringJobSkillPanelVM:OnCollectionScourSkill(CollectionRsp, true)
    self.AddLifeSkillBuff = true
end

function CollectionMgr:UpdateGatherMsg()
    if self.LastTimeSkill then
        self.LastTimeSkill = false
        if self.UpdatePrivateGatherMsg ~= nil then
            --执行刷新采集点，刷新采集物和上方耐久条，关闭界面
            _G.GatherMgr:OnNetMsgUpdatePrivateGather(self.UpdatePrivateGatherMsg)
            self.UpdatePrivateGatherMsg = nil
            _G.GatheringJobSkillPanelVM:OnExitCollection()
        else
            FLOG_ERROR("CollectionMgr UpdatePrivateGatherMsg is nil")
        end
    end
end

function CollectionMgr:DelayExitCollectionStateReq()
    if self.HideTimer > 0 then
        self:UnRegisterTimer(self.HideTimer)
    end
    self.HideTimer = self:RegisterTimer(self.UpdateGatherMsg, Delay, 1, 1)
end

--退出收藏品采集状态
function CollectionMgr:ExitCollectionStateReq()
    if self.LastTimeSkill == true then
        return
    end
    MsgBoxUtil.MessageBox(
        LSTR(160035), --"是否确认退出？\n退出后将无法获取当前收藏品"
        LSTR(10002), --"确定"
        LSTR(10003), --"取消"
        function()
            self:DoExitCollectionStateReq(true)
        end,
        function()
        end,
        false
    )
end

function CollectionMgr:DoExitCollectionStateReq(ShowGatheringJobPanel)
    --如果是主动退出收藏状态，再发送，被动退出的话（采集点消失时，后台已自动退出）就不发了
    if ShowGatheringJobPanel then
        local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
        local MsgBody = {}
        local SubMsgID = CS_SUB_CMD.LIFE_SKILL_EXIT_COLLECTION_CMD
        MsgBody.Cmd = SubMsgID
        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
    _G.UIViewMgr:HideView(UIViewID.MessageBox)
    self:ExitCollectionPanel(ShowGatheringJobPanel)
end

function CollectionMgr:OnNetMsgGetGatherData()
    self.IsCollectionState = false

    local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, true, "Collection")
    end
end

function CollectionMgr:ExitCollectionPanel(ShowGatheringJobPanel)
    self.IsCollectionState = false

    local StateComponent = MajorUtil.GetMajorStateComponent()
    if StateComponent ~= nil then
        StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, true, "Collection")
    end

    _G.UIViewMgr:HideView(UIViewID.GatheringJobSkillPanel, true)
    _G.GatheringJobSkillPanelVM:OnExitCollection()
    if ShowGatheringJobPanel then
        _G.UIViewMgr:ShowView(UIViewID.GatheringJobPanel, _G.GatherMgr.GatherJobPanelParams)
    end
    
    --如有存的采集点刷新消息要执行完
    self:UpdateGatherMsg()

    local CurActiveEntityID = _G.GatherMgr.CurActiveEntityID
    _G.SwitchTarget:ManualSwitchToTarget(CurActiveEntityID)
    _G.GatherMgr:RefreshSkillState()
    _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
    _G.EventMgr:SendEvent(_G.EventID.DeActiveGatherItemView, CurActiveEntityID)
    if not ShowGatheringJobPanel then
        _G.EventMgr:SendEvent(_G.EventID.ForcePeacePanel)
    end
   -- _G.EventMgr:SendEvent(_G.EventID.ExitGatherCollectionState)
end

--进入收藏品采集状态 成功或失败
function CollectionMgr:OnEnterCollection(IsSuccess, CollectionRsp)
    if IsSuccess then
        self.IsCollectionState = true

        --隐藏主角头顶的血条，名字等，交互主面板，主面板
        _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
        self.OnShowGatheringJobSkillPanel = true
        _G.UIViewMgr:ShowView(UIViewID.GatheringJobSkillPanel)
        FLOG_INFO("CollectionMgr:OnEnterCollection HideView(UIViewID.GatheringJobPanel)")
        _G.UIViewMgr:HideView(UIViewID.GatheringJobPanel)
        --初始化网络数据，Panel数据
        _G.GatheringJobSkillPanelVM:EnterCollection(CollectionRsp)

        local StateComponent = MajorUtil.GetMajorStateComponent()
        if StateComponent ~= nil then
            StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, false, "Collection")
        end
        
        _G.EventMgr:SendEvent(_G.EventID.EnterGatherCollectionState)
    else
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CollectionBeSeized)
    end
end

--提纯的回包
function CollectionMgr:OnCollectionScour(CollectionRsp)
    local LastVal = (_G.GatheringJobSkillPanelVM.CollectionRsp or {}).CurrentVal or 0

    _G.GatheringJobSkillPanelVM:OnCollectionScourSkill(CollectionRsp, true)

    local Params = {
        LastVal = LastVal,
        CurrentVal = CollectionRsp.CurrentVal,
        ValueUp = CollectionRsp.ValueUp
    }
    _G.EventMgr:SendEvent(EventID.GatheringJobCollectionScour, Params)
end

--收藏品采集战利品
function CollectionMgr:OnCollectionSkillRlt(CollectionRsp)
    local Rlt = CollectionRsp.Result
    local ItemCfg = ItemCfg:FindCfgByKey(Rlt.ResID)
    --local HQRichText = RichTextUtil.GetTexture(self.CollectionIconPath, 30, 30, nil)
    MsgTipsUtil.ShowTipsByID(MsgTipsID.CollectionSkillRlt, nil, ItemCfg.ItemName, "")
end

--记录下当前采集的产出物的资源id，用于采集技能填充
function CollectionMgr:SetGatherItem(funtionitem)
    self.funtionitem = funtionitem
end

function CollectionMgr:GetGatherItem()
    return self.funtionitem
end

return CollectionMgr
