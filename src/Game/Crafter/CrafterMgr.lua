local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
-- local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local AudioUtil = require("Utils/AudioUtil")
local CommonUtil = require("Utils/CommonUtil")
local TeamMgr = require("Game/Team/TeamMgr")
local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD
local RandomEventCfg = require("TableCfg/RandomEventCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
-- local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
-- local RPNGenerator = require("Game/Skill/SelectTarget/RPNGenerator")
-- local LifeSkillConditionCfg = require("TableCfg/LifeSkillConditionCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local ItemCfg = require("TableCfg/ItemCfg")
local RecipeCfg = require("TableCfg/RecipeCfg")
-- local AnimationUtil = require("Utils/AnimationUtil")

-- local AnimDefines = require("Game/Anim/AnimDefines")
local RecipetoolAnimCfg = require("TableCfg/RecipetoolAnimatiomCfg")
local UIViewID = require("Define/UIViewID")
local CrafterConfig = require("Define/CrafterConfig")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local TipsQueueDefine = require("Game/TipsQueue/TipsQueueDefine")
local MainPanelVM = require("Game/Main/MainPanelVM")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local CrafterActionID = 21

local SkillCheckErrorCode = CrafterConfig.SkillCheckErrorCode

local LifeSkillActionType = ProtoRes.LIFESKILL_ACTION_TYPE
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO
local FVector = _G.UE.FVector
local AnimMgr

local LSTR
--各职业通用的部分：包括统一的对外接口和统一的功能
--首先会有ProfConfig按职业的配置
--1、各职业从制作手册打开制作界面（简易、正常、训练）的接口都统一到这里了
--   目前正常、训练还会统一发送开始制作的协议;
--   等到回包再打开制作界面，同时参数传给view的是StartMake，用于各职业刷新制作界面。    CrafterMgr会记录该回包self.StartMakeRsp(只记自己的)
--2、点关闭按钮或者终止制作 放弃制作，包括发协议、关节面
--   需要各职业关闭按钮时调用CrafterMgr:QuitMake()
--3、各职业制作的结果：成功、失败、获得的制作物品            包括第三方的
--   各职业可以不用管，除非有特殊的，比如炼金的爆炸
--4、技能的回包 LIFE_SKILL_CRAFTER_SKILL        CrafterMgr会记录该回包self.LastCrafterSkillRsp(只记自己的)
--   主要用于界面刷新，而第三方玩家的包可以忽略；有特殊的话再处理
--   来包后会触发事件通知，各职业监听事件即可，参数是MsgBody（仅仅是制作者本身的技能回包才会触发，第三方的没必要关心）
--      事件是 CrafterSkillRsp = 14102,		--生产职业技能回包的事件通知

--5、各个职业释放技能统一使用这个接口 CrafterMgr:CastLifeSkill
--   这里也会进行技能的cd管理（cd是工次）
--   找到技能在技能组中的配置，根据index触发
--   _G.CrafterMgr:CastLifeSkill(1)
--6、进入制作、退出制作的动作也是按db配置统一处理的
--   走VisionSpellStateChgRsp广播的，InteractiveData中的SpellID就是制作物id，StatBits=1表示是生产状态
--   进入视野的视野包也会有InteractiveData数据
--7、各个职业的生产界面上的技能释放按钮需要处理禁用和非禁用状态
    --以控制技能释放过程中不能再次释放技能和CD
    --可以依据CrafterSkillCheckMgr
--8、CrafterSkillCheckMgr 主要有以下内容
--  a、刷新技能mask状态
--	    判定是否是生产职业的生产技能、是不是技能ing、cd（工次）是否ok、技能条件、技能消耗是否足够
--  b、cd相关管理
--  c、CheckSkillCost消耗判定，技能流程可以直接调用：比如耐久、制作力、

--客户端状态
local CraferStatus = CraferStatus or
{
    None = 0,
    Simple = 1,     --简易制作
    Noraml = 2,     --常规制作
    Train  = 3,     --训练制作
    FastMake = 4,   --快速制作
}

local TargetEffectPath = CrafterConfig.WeaverCircleEffectPath.NormalEffectPath
local SkillSuccessEffectPath = CrafterConfig.EffectPaths.SkillSuccessEffectPath
local SkillHotForgeEffectPath = CrafterConfig.EffectPaths.SkillHotForgeEffectPath
local SkillFailedEffectPath = CrafterConfig.EffectPaths.SkillFailedEffectPath
local ResultSuccessEffectPath = CrafterConfig.EffectPaths.ResultSuccessEffectPath
local ResultFailedEffectPath = CrafterConfig.EffectPaths.ResultFailedEffectPath
local HQResultSuccessEffectPath = CrafterConfig.EffectPaths.HQResultSuccessEffectPath

local SkillSuccessSoundPath = CrafterConfig.SoundPaths.SkillSuccessSoundPath
local SkillFailedSoundPath = CrafterConfig.SoundPaths.SkillFailedSoundPath
local ResultSuccessSoundPath = CrafterConfig.SoundPaths.ResultSuccessSoundPath
local ResultFailedSoundPath = CrafterConfig.SoundPaths.ResultFailedSoundPath
local HQResultSuccessSoundPath = CrafterConfig.SoundPaths.HQResultSuccessSoundPath

local SuccessEventType = 102
local FailedEventType = 103
local attr_mk = ProtoCommon.attr_type.attr_mk

--每个职业的配置，可以功能通用，比如从制作手册打开制作界面
local ProfConfig = CrafterConfig.ProfConfig

local CircleStateIndex = {
	Normal = 1,
	Green = 2,
	Yellow = 4,
	Red = 8,
	Double = 9, -- 老版本双色球统一特效，后续修改为播放右边的球的特效，暂时弃用
    GreenYellow = 6,
    GreenRed = 10,
    YellowRed = 12
}

local WeaverCircleEffectPath = {
    [CircleStateIndex.Normal] = CrafterConfig.WeaverCircleEffectPath.NormalEffectPath,
    [CircleStateIndex.Green] = CrafterConfig.WeaverCircleEffectPath.GreenEffectPath,
    [CircleStateIndex.Yellow] = CrafterConfig.WeaverCircleEffectPath.YellowEffectPath,
    [CircleStateIndex.Red] = CrafterConfig.WeaverCircleEffectPath.RedEffecttPath,
    [CircleStateIndex.Double] = CrafterConfig.WeaverCircleEffectPath.DoubleEffectPath,
    [CircleStateIndex.GreenYellow] = CrafterConfig.WeaverCircleEffectPath.YellowEffectPath,
    [CircleStateIndex.GreenRed] = CrafterConfig.WeaverCircleEffectPath.RedEffecttPath,
    [CircleStateIndex.YellowRed] = CrafterConfig.WeaverCircleEffectPath.RedEffecttPath,
}

--通用状态
-- local FishNetStat = ProtoCommon.CommStatID.COMM_STAT_FISH

---@class CrafterMgr : MgrBase
local CrafterMgr = LuaClass(MgrBase)

--等待技能回包的保护性措施，以防界面无法操作；但这个时候网络也算是有问题了
CrafterMgr.WaitingSkillRspTime = 6
CrafterMgr.EnterStateTime = 1.4
--播放代表制作物的白球特效（可能挂在武器附件，也可能挂在武器上） EID_CRAFT_MAT
CrafterMgr.DelayPlayTargetEffectTime = 0.4
CrafterMgr.DelayPlayResultEffTime = 0.6
CrafterMgr.DelayDoSkillEnd = 1.4
CrafterMgr.DelayShowLogViewTime = 1.8
CrafterMgr.DelayPlayExitAnimTime = 0.7

local AvatarType_Hair <const> = _G.UE.EAvatarPartType.NAKED_BODY_HAIR
local HairRenderPriority <const> = -1

--------------  能工巧匠 各个职业通用的接口部分begin ------------------------
--下面收发协议也是通用的
-------- 生产职业对于制作手册是统一的start接口
function CrafterMgr:PreCheck(RecipeID)
    if not self.ProfID then
        FLOG_ERROR("Crafter self.ProfID is nil")
        return false
    end

	local IsCrafterProf = MajorUtil.IsCrafterProf()
    if not IsCrafterProf then
        FLOG_WARNING("CrafterMgr not CrafterProf")
        return false
    end

    local RecipeConfig = RecipeCfg:FindCfgByKey(RecipeID)
    if not RecipeConfig then
        FLOG_WARNING("CrafterMgr not Config RecipeID:%d", RecipeID)
        return false
    end

    if RecipeConfig.Craftjob ~= 0 and RecipeConfig.Craftjob ~= self.ProfID then
        FLOG_WARNING("CrafterMgr Need ProfID:%d", RecipeConfig.Craftjob)
        return false
    end
    --战斗、死亡、骑乘坐骑、观看视频、通用读条、排本确认中
    if MajorUtil.GetMajorCurHp() <= 0 then
        -- 死亡
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterCannotMakeWhenDead)
        return false
    end

    if MajorUtil.IsMajorCombat() then
        -- 战斗
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterCannotMakeWhenInBattle)
        return false
    end

	if _G.SingBarMgr:GetMajorIsSinging() then
        -- 读条
		MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterCannotMakeWhenSinging)
		return false
	end
    
    return true
end

--常规制作(不传参数或者传false）、训练制作（传参数true）
function CrafterMgr:StartMake(RecipeID, IsTrain, Num)
    -- 通用状态检测
    if CommonStateUtil.CheckBehavior(CrafterActionID, true) == false then
        return false
    end
    
    if not self:PreCheck(RecipeID) then
        return
    end

    if self.IsMaking then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterCannotReEnter)
        return 
    end
    
    if _G.SkillLogicMgr.bIsRequiringSkillList then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.OpIsQuickly)
        return
    end

    local function SendStartMake()
        -- _G.EventMgr:SendEvent(_G.EventID.StartCrafter)
        Num = Num or 1
    
        if not RecipeID then
            RecipeID = ProfConfig[self.ProfID].TestRecipeID
        end
    
        FLOG_INFO("CrafterMgr:StartMake RecipeID:%d  IsTrain:%s", RecipeID, tostring(IsTrain))
    
        -- 退出制作, 隐藏CrafterMainPanel后, 误触到普攻键可能导致CraftingLog提前ShowView, 此时应取消定时器
        if self.DelayShowLogViewTimerID then
            _G.TimerMgr:CancelTimer(self.DelayShowLogViewTimerID)
            self.DelayShowLogViewTimerID = nil
        end
    
        local MakeType = ProtoCS.MakeType.MakeTypeNormal
        self.CurState = CraferStatus.Noraml
        if IsTrain then
            MakeType = ProtoCS.MakeType.MakeTypeTrain
            self.CurState = CraferStatus.Train
        end
    
        _G.FishMgr:StartMoveAndTurnChange(0, true)

        -- 进入制作状态时清除玩家对其他目标的选中态
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.ULongParam1 = 0
        _G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)

    
        self:SendStartMakeReq(RecipeID, MakeType, Num)
        --回包再显示制作界面
    end

    if _G.MountMgr:IsInRide() then
        -- 坐骑
        local Major = MajorUtil.GetMajor()
        if Major:IsRideFlying() then 
            _G.MsgTipsUtil.ShowTips(LSTR(80073)) --坐骑飞行中，无法制作80073
            return false
        end
        _G.MountMgr:ForceSendMountCancelCall(SendStartMake)
    else
        SendStartMake()
    end
end

function CrafterMgr:SetCamera()
    -- _G.GMMgr:CrafterCamer(580,-12,120,0)
    local Major = MajorUtil.GetMajor()
    if not Major then
        return
    end

    local Camera = Major:GetCameraControllComponent()
    local CameraParams = _G.UE.FCameraResetParam()
    if Camera then
        CameraParams.Distance = 580
        CameraParams.Rotator = _G.UE.FRotator(-12, 120, 0)
        CameraParams.bRelativeRotator = true
        CameraParams.Offset = _G.UE.FVector(0, 0, 0)
        CameraParams.ResetType = _G.UE.ECameraResetType.Jump
        CameraParams.LagValue = 10
        Camera:ResetSpringArmByParam(_G.UE.ECameraResetLocation.RecordLocation, CameraParams)

    end

    local CamCtrComp = Major:GetCameraControllComponent()
    if CamCtrComp then
        CamCtrComp:SetIgnoreSocketOffset(true)
    end
    
end

--简易制作(快速制作与简易制作逻辑相同，只有协议传输MakeType不同)
function CrafterMgr:StartSimpleMake(RecipeID, TotalMakeCount, bFastCraft)
    if self.IsMaking then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterCannotReEnter)
        return 
    end
    
    -- 通用状态检测
    if CommonStateUtil.CheckBehavior(CrafterActionID, true) == false then
        return false
    end

    if _G.SkillLogicMgr.bIsRequiringSkillList then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.OpIsQuickly)
        return
    end

    self.CurState = CraferStatus.Simple
    FLOG_INFO("Crafter StartSimpleMake RecipeID:%d, TotalCount:%d", RecipeID, TotalMakeCount)

    local MakeType = bFastCraft and ProtoCS.MakeType.MakeTypeFast or ProtoCS.MakeType.MakeTypeSimple
    self:SendStartMakeReq(RecipeID, MakeType, TotalMakeCount)

    self.bSendRightAwayReq = false
    --正在简易制作ing，不能移动了，就不能触发移动打断了
    _G.FishMgr:StartMoveAndTurnChange(0, true)

    -- 进入制作状态时清除玩家对其他目标的选中态
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = 0
    _G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)
end

function CrafterMgr.IsCrafterLogViewOpen()
    return _G.UIViewMgr:IsViewVisible(UIViewID.CraftingLog)
end

function CrafterMgr:HideCraftingLogView()
    if self.IsCrafterLogViewOpen() then
        _G.CraftingLogMgr:SaveFastSearchInfo()
        _G.UIViewMgr:HideView(UIViewID.CraftingLog)
    end
end

--[[快速制作，正式版本没用；用于送审版本时，非炼金的职业能快速制作（原快速制作，废弃）
function CrafterMgr:StartFastMake(RecipeID, Num)
    if not self:PreCheck(RecipeID) then
        return
    end

    self:HideCraftingLogView()
    self:CancelFastMakeTimers()

    Num = Num or 1

    if not RecipeID then
        RecipeID = ProfConfig[self.ProfID].TestRecipeID
    end

    -- FLOG_ERROR("Crafter : %s", CommonUtil.GetLuaTraceback())

    self.FastMakeRecipeID = RecipeID
    FLOG_INFO("CrafterMgr:StartQuickMak RecipeID:%d", RecipeID)

    self.CurState = CraferStatus.FastMake
    --正在临时制作ing，不能移动了，就不能触发移动打断了
    _G.FishMgr:StartMoveAndTurnChange(0, true)

    local function EnterAnimFinish()
        -- self.FastMakeTimerID = nil

        self:CastLifeSkill(1)
    end
    
    --临时功能，就写死1.4s了
    self.FastMakeTimerID = _G.TimerMgr:AddTimer(nil, EnterAnimFinish, CrafterMgr.EnterStateTime, 1, 1)

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    self:EnterRecipeState(MajorEntityID, RecipeID)

    local function WaitResultTimeOut()
        self.FastMakeTimeOutTimerID = nil
        FLOG_INFO("CrafterMgr fastmake WaitResultTimeOut")

        _G.FishMgr:StartMoveAndTurnChange(0, true)
        self:ExitRecipeState(MajorEntityID, self.FastMakeRecipeID)
        self:Reset()
    end
    
    local MakeType = ProtoCS.MakeType.MakeTypeFast
    self:SendStartMakeReq(RecipeID, MakeType, Num)

    --临时功能，就写死1.4s了
    self.FastMakeTimeOutTimerID = _G.TimerMgr:AddTimer(nil, WaitResultTimeOut, 7, 1, 1)
end]]

--如果材料不足，服务器没逻辑的回包，所以此刻状态是有点问题，不是none了
function CrafterMgr:IsProduceState()
    return self.CurState
end

--是不是正在制作ing，处于制作动作ing的
function CrafterMgr:GetIsMaking()
    return self.IsMaking
end

--各个职业的界面调用过来，放弃、退出制作
function CrafterMgr:QuitMake()
    self:SendStartQuitMakeReq()
end

--技能施放中发送立即完成请求
function CrafterMgr:SendRightAwayReq(SubSkillID, Num)
    FLOG_ERROR("37Craft:SendRightAwayReq")

    --先获取一次已经释放的技能的奖励
    self:OnSkillGameEventGetReward()

    self.bSendRightAwayReq = true

    local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
    local SkillID = LogicData:GetBtnSkillID(0)
    --不走技能，只走协议
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_ACTION_CMD
    local MsgBody = {
        Cmd = SubMsgID,
        Action = { LifeSkillID = SkillID, SubLifeSkillID = SubSkillID, Simple = { Num = Num }}
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


--释放生产职业技能
function CrafterMgr:CastLifeSkill(Index, SkillID, ExtraParams)
    if self.bSendQuitMakeReq and self.CurState ~= CraferStatus.Simple then   --有结果了，就是本次制作结束，忽略频繁点击的技能
        return false
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if not SkillID then
        self.LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
        if self.LogicData == nil then
            FLOG_ERROR("Crafter CastLifeSkill, but Major LogicData is nil")
            return false
        end
    
        SkillID = self.LogicData:GetBtnSkillID(Index)
    end

    if SkillID and SkillID > 0 then
        local IsValid, Reason
        if self.CurState == CraferStatus.Simple then
            IsValid = true
            
            local CurSkillWeight = _G.SkillPreInputMgr:GetCurrentSkillWeight()
            if CurSkillWeight then
                local SubSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, MajorUtil.GetMajorEntityID())
                local ToCastSkillWeight = _G.SkillPreInputMgr:GetInputSkillWeight(SubSkillID)
                if ToCastSkillWeight and ToCastSkillWeight <= CurSkillWeight then
                    FLOG_INFO("Crafter Simple CurSkillWeight: %d ToCastSkillWeight: %d", CurSkillWeight, ToCastSkillWeight)
                    IsValid = false
                    Reason = SkillCheckErrorCode.SkillWeight
                end
            end
        else
            IsValid, Reason = _G.CrafterSkillCheckMgr:CrafterSkillValid(Index, SkillID, ExtraParams)
        end

        if IsValid then
            FLOG_INFO("Crafter CastLifeSkill index:%d, skillID:%d", Index, SkillID)

            local OldEffectNode = self.EffectNodeMap[MajorEntityID]
            if OldEffectNode then
                if OldEffectNode.Msg and not OldEffectNode.bProcessSkillMsg then
                    self:DoSkillEffectWhenSkillEnd(OldEffectNode, OldEffectNode.Msg);
                end

                if OldEffectNode.CacheExitState then
                    FLOG_WARNING("Crafter Already Exit, so ignore skill")
                    return 
                end
            end
            
            SkillUtil.CastLifeSkill(Index, SkillID, ExtraParams)
            self:StartWaitintSkillTime()

            --刷新技能按钮的是否可点的状态
            _G.CrafterSkillCheckMgr:RefreshSkillState()

            -- FLOG_INFO("Crafter CastLifeSkill NewEffectNode, skillID:%d", SkillID)
            local EffectNode = {
                EntityID = MajorEntityID,
                Msg = nil,
                CulinaryOrigin = nil,
                PassiveEffectNotify = nil,
                IsSkill = true,
                SkillID = SkillID,
            }
            --先缓存，等技能表现结束的时候再播放技能结果的特效
            self.EffectNodeMap[MajorEntityID] = EffectNode
        else
            Reason = Reason or SkillCheckErrorCode.UnKnown
            FLOG_INFO("Crafer CastLifeSkill skillID:%d, but failed(Reason:%d)", SkillID, Reason)
            if Reason == SkillCheckErrorCode.SkillCondition then
                local TipsID = SkillMainCfg:FindValue(SkillID, "LifeSkillConditionTipsID")
                if TipsID and TipsID > 0 then
                    MsgTipsUtil.ShowTipsByID(TipsID)
                else
                    MsgTipsUtil.ShowTips(LSTR(150062), nil, 1)  -- 条件不满足
                end
            elseif Reason == SkillCheckErrorCode.RandomEvent then
                MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherCurStateInvalid)
            end
            -- if Reason == -1 then
            --     FLOG_ERROR("Crafter 客户端：正在等技能回包ing，不可释放技能")
            -- elseif Reason == -2 then
            --     FLOG_ERROR("Crafter 客户端：技能正在cd中，不可释放技能")
            -- elseif Reason == -3 then
            --     FLOG_ERROR("Crafter 客户端：技能消耗不满足，请检查耐久、制作力等属性")
            -- elseif Reason == -4 then
            --     FLOG_ERROR("Crafter 客户端：LifeSkillCondition条件不满足")
            -- elseif Reason == -5 then
            --     FLOG_ERROR("Crafter 客户端：不是生产技能")
            -- elseif Reason == -6 then
            --     FLOG_ERROR("Crafter 客户端：不是制作职业")
            -- elseif Reason == -8 then
            --     FLOG_ERROR("Crafter 客户端：热锻状态下不能释放技能")
            -- end
        end

        return IsValid
    else
        FLOG_ERROR("Crafter CastLifeSkill, but index %d no skill", Index)
    end

    return false
end

function CrafterMgr:GetFeatureValue(FeatureType) 
    local Features = self:GetFeatures()
    if Features then
        return Features[FeatureType] or 0
    end
    return 0
end

function CrafterMgr:GetFeatures()
    local Features = nil
    if self.CurState ~= CraferStatus.None then
        if self.LastCrafterSkillRsp then
            Features = self.LastCrafterSkillRsp.Features
        elseif self.StartMakeRsp then
            Features = self.StartMakeRsp.Features
        end
    end

    return Features
end

--获取当前制作物的  最大耐久
function CrafterMgr:GetCurTargetMaxDuration()
    if self.StartMakeRsp and self.CurState ~= CraferStatus.None then
        local RecipeID = self.StartMakeRsp.RecipeID
        if RecipeID then
            local RecipeConfig = RecipeCfg:FindCfgByKey(RecipeID)
            if RecipeConfig then
                if RecipeConfig.Durability == 0 then
                    FLOG_ERROR("Crafter db error, MaxDuration = 0, RecipeID :%d", RecipeID)
                end

                return RecipeConfig.Durability
            end
        end
    end

    FLOG_ERROR("Crafter GetCurTargetMaxDuration = 0")
    return 0
end

function CrafterMgr:GetCurTargetMaxProgress()
    if self.StartMakeRsp and self.CurState ~= CraferStatus.None then
        local RecipeID = self.StartMakeRsp.RecipeID
        if RecipeID then
            local RecipeConfig = RecipeCfg:FindCfgByKey(RecipeID)
            if RecipeConfig then
                return RecipeConfig.ProgressMax
            end
        end
    end

    return 0
end

--------------  能工巧匠 各个职业通用的部分end ------------------------
---
function CrafterMgr:OnInit()
    AnimMgr = _G.AnimMgr
    self.LastRegisterProfID = 0
    self:Reset()
end

function CrafterMgr:OnBegin()
    self.TargetEffectIDMap = {}
    self.SkillEffectIDMap = {}
    self.RandomEventEffectIDMap = {}
    self.SkillViewMap = {}
    -- self.ResultEffectMap = {}
    
    --制作时候白球的PosKey，技能成功失败、制作成功失败也都是在这个PosKey播放特效的
    self.PosKeyMap = {}

    self.EffectNodeMap = {}

    -- 当前简易制作数量
    self.NowSimpleMakeCount = 0
    LSTR = _G.LSTR

    self.bShouldHideOtherPlayer = true
    self.HidedPlayerList = {}

    -- self.bIsQueryCommStat = true
    self.bSendQuitMakeReq = false
end

function CrafterMgr:OnEnd()
    if self.TargetEffectIDMap then
        for key, value in pairs(self.TargetEffectIDMap) do
            self:ClearVfx(key)
        end
    end

    if self.SkillEffectIDMap then
        for _, value in pairs(self.SkillEffectIDMap) do
            EffectUtil.StopVfx(value, 0, 0)
        end
    end

    if self.RandomEventEffectIDMap then
        for _, value in pairs(self.RandomEventEffectIDMap) do
            EffectUtil.StopVfx(value, 0, 0)
        end
    end
    -- if self.ResultEffectMap then
    --     for _, value in pairs(self.ResultEffectMap) do
    --         EffectUtil.BreakEffect(value)
    --     end
    -- end
    
    self.TargetEffectIDMap = {}
    self.SkillEffectIDMap = {}
    self.RandomEventEffectIDMap = {}
    -- self.ResultEffectMap = {}
    self.PosKeyMap = {}
    self.EffectNodeMap = {}

    if self.LastRegisterProfID and self.LastRegisterProfID > 0 then
        LifeSkillConfig.UnRegisterCastSkillCallback(self.LastRegisterProfID)
    end
    self:Reset()

    self.bRegisterHidePlayerEvents = false
    self.bRegisterMajorEvents = false
end

function CrafterMgr:OnShutdown()
    self.LastRegisterProfID = 0

end

function CrafterMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_ACTION_CMD, self.OnLifeSkillAction)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_START_MAKE, self.OnNetMsgStartMake)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_SKILL, self.OnNetMsgCrafterSkill)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_QUIT_MAKE, self.OnNetMsgQuitMake)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_RESULT, self.OnNetMsgResult)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_CULINARY_ORIGIN, self.OnNetMsgCulinaryOrigin)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_CULINARY_STORM, self.OnNetMsgCulinaryStorm)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_EFFECT_NOTICE, self.OnNetMsgPassiveEffectNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_CRAFTER_GET, self.OnNetMsgCrafterGet)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMM_STAT, ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS, self.OnNetMsgQueryCommStatRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_ATTR_UPDATE, self.OnCombatAttrUpdate)
end

function CrafterMgr:OnRegisterGameEvent()
    local EventID = _G.EventID
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
	--self:RegisterGameEvent(EventID.MajorFirstMove, self.MajorFirstMove)
    self:RegisterGameEvent(EventID.PlayUMGAnim, self.OnPlayUMGAnim)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    -- 这个事件, P3也用到, 不能只在主角职业为生产的时候注册
    self:RegisterGameEvent(EventID.CrafterSkillEffect, self.OnSkillEffect)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnRelayConnectedMajorCreate)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead) --主角死亡
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnRelayConnected)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnEventActorLeaveVision)
    -- self:RegisterGameEvent(EventID.MajorLifeSkillActionRsp, self.OnMajorLifeSkillActionRsp)
end

--[[临时功能begin，送审版本才会
function CrafterMgr:MajorFirstMove()
	if self.CurState == CraferStatus.FastMake then
        if self.FastMakeTimerID then
            FLOG_INFO("CrafterMgr cancel fastmake, because major begin move")

            local MajorEntityID = MajorUtil.GetMajorEntityID()
            _G.FishMgr:StartMoveAndTurnChange(0, true)
            self:ExitRecipeState(MajorEntityID, self.FastMakeRecipeID)
            self:Reset()
        else
            FLOG_INFO("CrafterMgr CancelFastMakeTimers MajorFirstMove")
        end

        self:CancelFastMakeTimers()
	end
end]]

function CrafterMgr:OnPlayUMGAnim(Params)
    local AnimPath = Params.StringParam1
    local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    if nil == AnimPath or nil == EntityID or MajorEntityID ~= EntityID then
        return
    end
    local bIsAnimPlayOnlyWhenSkillSuccessfullyCast = Params.BoolParam1

    if bIsAnimPlayOnlyWhenSkillSuccessfullyCast then
        local EffectNode = self.EffectNodeMap[EntityID]
        if not EffectNode then
            return
        end

        local Msg = EffectNode.Msg
        if not Msg then
            return
        end

        if not Msg.CrafterSkill.Success then
            return
        end
    end



    local AnimPathList = string.split(AnimPath, '.')
    if AnimPathList == nil then
        return
    end
    local ListLen = #AnimPathList

    local UIViewMgr = _G.UIViewMgr
    local View = UIViewMgr:FindVisibleView(UIViewID[AnimPathList[1]])
    if nil == View then
        return
    end

    local Widget = View
    for Index, Section in ipairs(AnimPathList) do
        if Index ~= 1 and Index ~= ListLen then
            Widget = Widget[Section]
        end

        if nil == Widget then
            return
        end
    end

    local Anim = Widget[AnimPathList[ListLen]]
    if Anim then
        Widget:PlayAnimation(Anim)
    end
end

--正式功能也要用到
local function OnResultEffectOver()
    FLOG_INFO("====CrafterMgr OnResultEffectOver")
    if CrafterMgr.CrafterResultRsp then
        CrafterMgr.SkillEffectIDMap[CrafterMgr.CrafterResultRsp.ObjID] = nil
        CrafterMgr.CrafterResultRsp = nil
        _G.CraftingLogSimpleCraftWinVM:OnSimpleMakeOver()
    end
end

--技能特效结束后的处理
local function OnSkillEffectOver(EntityID) 
    FLOG_INFO("====CrafterMgr OnSkillEffectOver, to play Result Effect")
    if CrafterMgr.bResultShown then
        return 
    end
    if CrafterMgr.CurState == CraferStatus.Simple and EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end
    --如果有记录结果，则播放结果的表现
    local CrafterResultRsp = CrafterMgr.CrafterResultRsp
    if CrafterResultRsp then
        CrafterMgr.bResultShown = true
        local ResultEffectPath = ResultSuccessEffectPath
        local ResultSoundPath = ResultSuccessSoundPath
        local Result = CrafterResultRsp.Result
        local ResultTipsParams = { EventType = SuccessEventType, Title = LSTR(150063) }  -- 制作成功

        --有可能走到这时已经Reset(),CurState=CraferStatus.None了
        if not Result.SimpleRsp then        --非简易制作
            if Result.Success ~= true then
                ResultEffectPath = ResultFailedEffectPath
                ResultSoundPath = ResultFailedSoundPath
                ResultTipsParams = { EventType = FailedEventType, Title = LSTR(150064) }  -- 制作失败
            else
                if Result.Award and Result.Award.HQ == true then
                    ResultEffectPath = HQResultSuccessEffectPath
                    ResultSoundPath = HQResultSuccessSoundPath
                end
                if Result.Award then
                    _G.CraftingLogMgr:SendTutorialFirstCrafted() 
                end
            end
        else                       --简易制作特殊处理下
            _G.FLOG_INFO("Crafter SimpleMake Rlt, FailedNum:%d, successNum:%d, HQNum:%d"
                , Result.SimpleRsp.FailNum, Result.SimpleRsp.SuccessNum, Result.SimpleRsp.HQNum)

            if Result.SimpleRsp.SuccessNum == 0 and Result.SimpleRsp.FailNum > 0 then
                ResultEffectPath = ResultFailedEffectPath
                ResultSoundPath = ResultFailedSoundPath
                ResultTipsParams = { EventType = FailedEventType, Title = LSTR(150064) }  -- 制作失败
            elseif Result.SimpleRsp.HQNum > 0 then
                ResultEffectPath = HQResultSuccessEffectPath
                ResultSoundPath = HQResultSuccessSoundPath
            end

            _G.CraftingLogSimpleCraftWinVM:OnSimpleMakeRltCounts(Result.SimpleRsp) 
        end

        AudioUtil.LoadAndPlaySoundEvent(EntityID, ResultSoundPath)
        CrafterMgr:ShowStateTips(ResultTipsParams, true)

        local ResSoftPath = _G.UE.FSoftObjectPath()
        ResSoftPath:SetPath(ResultEffectPath)
        if _G.UE.UCommonUtil.IsObjectExist(ResSoftPath) then
            local ObjID = CrafterResultRsp.ObjID
            CrafterMgr:PlayEffectByPosKey(ObjID, CrafterMgr.PosKeyMap[ObjID]
                , ResultEffectPath
                , "EID_CRAFT_MAT"
                , CrafterMgr.SkillEffectIDMap, OnResultEffectOver)
        else
            OnResultEffectOver()
        end

        local EffectNode = CrafterMgr.EffectNodeMap[EntityID]
        if EffectNode then
            EffectNode.PlayResultEffTimerID = nil
        end
    end
end

function CrafterMgr:ForEachCrafterSkillView(Func)
    local SkillViewMap = self.SkillViewMap or {}
    local ProfSkillViewMap = SkillViewMap[self.ProfID] or {}
    for _, Views in pairs(ProfSkillViewMap) do
        for _, View in pairs(Views) do
            Func(View)
        end
    end
end

function CrafterMgr:OnSkillStart(Params)
    -- 添加技能使用中的遮罩
    local EntityID = Params.ULongParam1
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end

    self:ForEachCrafterSkillView(function(View)
        if View.UpdateMaskFlag then
            local EMaskType = View:GetEMaskType()
            View:UpdateMaskFlag(true, EMaskType.OtherSkillCasting)
        end
    end)
end

function CrafterMgr:OnSkillEnd(Params)
	local SkillID = Params.IntParam2
	local EntityID = Params.ULongParam1

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode and SkillID == EffectNode.SkillID then
        if EffectNode.DoSkillEndTimerID then
            _G.TimerMgr:CancelTimer(EffectNode.DoSkillEndTimerID)
        end

        EffectNode.IsSkillEnd = true
        if not EffectNode.IsDoneSkillEnd  then
            self:DoSkillEnd({EntityID = EntityID, SkillID = SkillID})
        end
    else
        FLOG_INFO("CrafterMgr OnSkillEnd Ignore SkillID:%d", SkillID)
    end

    -- 移除技能使用中的遮罩
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end

    self:ForEachCrafterSkillView(function(View)
        if View.UpdateMaskFlag then
            local EMaskType = View:GetEMaskType()
            View:UpdateMaskFlag(false, EMaskType.OtherSkillCasting)
        end
    end)
end

--正式功能也要用到
function CrafterMgr:OnSkillEffect(Params)
	local SkillID = Params.IntParam1
	local EntityID = Params.ULongParam1

    local AddBuffAnimDelay = Params.FloatParam1
    local FlyTextDelay = Params.FloatParam2

    -- FLOG_INFO("Crafter OnSkillEffect, SkillID:%d", SkillID)

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        EffectNode.bProcessSkillEffect = true
        -- self:DoSkillEffectWhenSkillEnd(EffectNode, EffectNode.Msg, Params)   这里的子集；  2部分逻辑需要同时改
        --播放技能成功、失败的特效
        local SkillEffectPath = SkillFailedEffectPath
        local SoundPath = SkillFailedSoundPath
        if EffectNode.Msg then
            EffectNode.bProcessSkillMsg = true
            if not EffectNode.Msg.CrafterSkill or EffectNode.Msg.CrafterSkill.Success then
                SkillEffectPath = SkillSuccessEffectPath
                SoundPath = SkillSuccessSoundPath

                local ProfType = ProtoCommon.prof_type
                if self.ProfID == ProfType.PROF_TYPE_BLACKSMITH or self.ProfID == ProfType.PROF_TYPE_ARMOR then
                    local ProfMainPanelView = _G.UIViewMgr:FindVisibleView(ProfConfig[self.ProfID].MainPanelID)
                    if ProfMainPanelView and ProfMainPanelView.IsHotForgeSkill(SkillID) then
                        SkillEffectPath = SkillHotForgeEffectPath
                    end
                end
            else
                self:SkillUseFailedTip(EffectNode.SkillID, EntityID)
            end

            --第三方立即处理了，主角要滞后一点于技能特效的表现
            if EntityID == MajorUtil.GetMajorEntityID() then
                local function DelayCrafterSkillRsp()
                    --要早于随机事件的处理
                    local EventMgr = _G.EventMgr
                    local EventID = _G.EventID
                    EventMgr:SendEvent(EventID.CrafterCulinaryOrigin, EffectNode.CulinaryOrigin)
                    EventMgr:SendEvent(EventID.CrafterSkillRsp, EffectNode.Msg, AddBuffAnimDelay, FlyTextDelay)
                    self:DoPassiveEffect(EffectNode.PassiveEffectNotify)
                    self:DoRandomEvent(EffectNode.Msg)
                end

                self.DelayCrafterSkillRspTimerID = _G.TimerMgr:AddTimer(nil, DelayCrafterSkillRsp, 0.3, 1, 1)
            end
            -- 裁衣匠球特效处理
            if EffectNode.Msg.CrafterSkill then
                if EffectNode.Msg.CrafterSkill.Weaver then
                    local function DelayCrafterWeaverCircleEffect()
                        local Step = EffectNode.Msg.CrafterSkill.Weaver.Index - EffectNode.Msg.CrafterSkill.Weaver.PreIndex
                        -- 存在重置序列的情况，此处Step会小于0，因此特殊处理
                        Step = Step > 0 and Step or 0
                        local State = EffectNode.Msg.CrafterSkill.Weaver.Balls[1 + Step]
                        if nil ~= WeaverCircleEffectPath[State] then
                            self:PlayWeaverCircleEffect(EntityID,State)
                        else
                            FLOG_WARNING("=========Crafter OnSkillEffectEvent WeaverCircle State Error")
                        --     self:PlayWeaverCircleEffect(EntityID,CircleStateIndex.Double)
                        end
                    end
                    _G.TimerMgr:AddTimer(nil, DelayCrafterWeaverCircleEffect, 0.2, 1, 1)
                end
            end
        -- 没收到回包, 暂时不做表现
        else
            -- _G.MsgTipsUtil.ShowTips(_G.LSTR("网络不稳定"), nil, 1)
            return
        end

        local CurEffectID = self.SkillEffectIDMap[EntityID]
        if CurEffectID then
            EffectUtil.StopVfx(CurEffectID,0,0)
        --   EffectUtil.BreakEffect(CurEffectID)
        end

        -- FLOG_INFO("=========Crafter OnSkillEffectEvent to Play SkillRltEff")
        AudioUtil.LoadAndPlaySoundEvent(EntityID, SoundPath)
        self:PlayEffectByPosKey(EntityID, self.PosKeyMap[EntityID]
            , SkillEffectPath
            , "EID_CRAFT_MAT"
            , self.SkillEffectIDMap)--, OnSkillEffectOver)

        -- if self.CrafterResultRsp then 
            EffectNode.PlayResultEffTimerID =
                _G.TimerMgr:AddTimer(nil, OnSkillEffectOver, self.DelayPlayResultEffTime, 1, 1, EntityID)
        -- end

        EffectNode.DoSkillEndTimerID = 
            _G.TimerMgr:AddTimer(self, self.DoSkillEnd, CrafterMgr.DelayDoSkillEnd, 1, 1
                , {EntityID = EntityID, SkillID = SkillID})
    else
        FLOG_WARNING("Crafter OnSkillEffect, EffectNode is nil")
    end
end
--临时功能end

function CrafterMgr:DoSkillEnd(Params)
    local EntityID = Params.EntityID
    local SkillID = Params.SkillID
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    
    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        EffectNode.IsDoneSkillEnd = true
        EffectNode.DoSkillEndTimerID = nil

        if EffectNode.CacheExitState then
            self:ExitRecipeState(EntityID, EffectNode.RecipeID)
        end

        -- FLOG_WARNING("Crafter EffectNode set nil DoSkillEnd")
        -- self.EffectNodeMap[EntityID] = nil
    end
    -- self.LastCrafterSkillRsp = nil

    -- FLOG_INFO("CrafterMgr DoSkillEnd(%d)  %d", SkillID, EntityID)

    if EntityID == MajorEntityID then
        -- if self.CrafterResultRsp then
        --     if self.CurState ~= CraferStatus.Train then
        --         local Result = self.CrafterResultRsp.Result
        --         self:OnNetMakeResult(Result)
        --     end
        -- end

        if self.bSendRightAwayReq then
            FLOG_INFO("CrafterMgr Major bSendRightAwayReq = true DoSkillEnd(%d)", SkillID)
            self:OnSkillGameEventGetReward()
        end

        if self:CheckMakeFinish() then
            FLOG_INFO("CrafterMgr Major CheckMakeFinish DoSkillEnd(%d)", SkillID)
            self:SendStartQuitMakeReq()
        end
        
        if CrafterMgr.CurState == CraferStatus.Simple and _G.CraftingLogSimpleCraftWinVM.IsClickCloseBtn then
            FLOG_INFO("CrafterMgr Major Simple QuitMake")
            self:SendStartQuitMakeReq()
        end

        --[[self.LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
        if self.LogicData == nil then
            FLOG_ERROR("Crafter DoSkillEnd, but Major LogicData is nil")
            return
        end

        local FastMakeSkillID = self.LogicData:GetBtnSkillID(1)
        if not FastMakeSkillID or FastMakeSkillID == 0 then
            FLOG_ERROR("Crafter FastMakeSkillID error")
            return 
        end

        if self.CurState == CraferStatus.FastMake and SkillID == FastMakeSkillID then
            if self.FastMakeTimeOutTimerID then
                _G.TimerMgr:CancelTimer(self.FastMakeTimeOutTimerID)
            end
            self.FastMakeTimeOutTimerID = nil
            FLOG_INFO("CrafterMgr fastmake exit DoSkillEnd")

            _G.FishMgr:StartMoveAndTurnChange(0, true)
            self:ExitRecipeState(MajorEntityID, self.FastMakeRecipeID)
            self:Reset()
        end]]
    else    --第三方
        local RecipeID = self.OtherPlayerCrafterMap[EntityID]
        if RecipeID and RecipeID > 0 then
            -- FLOG_INFO("CrafterMgr OtherPlayer %d DoSkillEnd recipeID:%d", EntityID, RecipeID)
            self:ExitRecipeState(EntityID, RecipeID)
            self.OtherPlayerCrafterMap[EntityID] = nil
        else
            -- FLOG_ERROR("Crafter OtherPlayerCrafterMap no %d", EntityID)
        end
    end
end

function CrafterMgr:OnStateChange(Params)
	local Stat = Params.IntParam1
	if Stat == ProtoCommon.CommStatID.COMM_STAT_MAX then
        local StateComp = MajorUtil.GetMajorStateComponent()
        if StateComp and not StateComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_PICKUP) then
            CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatCraft, false)
            self:UnRegisterGameEvent(_G.EventID.StateChange, self.OnStateChange)
        end
	end
end

function CrafterMgr:OnEventMajorProfSwitch()
    self:Reset()

    self:OnGameEventMajorCreate()
end

function CrafterMgr:OnGameEventMajorCreate()
    local ProfID = MajorUtil.GetMajorProfID()
    self.ProfID = ProfID

    if self.LastRegisterProfID and self.LastRegisterProfID > 0 then
        LifeSkillConfig.UnRegisterCastSkillCallback(self.LastRegisterProfID)
    end

    --临时功能begin
    local EventID = _G.EventID
    if ProfID and MajorUtil.IsCrafterProfByProfID(ProfID) then
        self.LastRegisterProfID = ProfID

        --临时功能begin：送审版本才会
        -- FLOG_INFO("CrafterMgr RegisterGameEvent SkillEnd")
        if not self.bRegisterMajorEvents then
            self.bRegisterMajorEvents = true
            self:RegisterGameEvent(EventID.SkillStart, self.OnSkillStart)
            self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
            self:RegisterGameEvent(EventID.SkillGameEventGetReward, self.OnSkillGameEventGetReward)
        end
        --临时功能end

        LifeSkillConfig.RegisterCastSkillCallback(ProfID, self, self.OnCastLifeSkill)
        -- self:RegisterGameEvent(_G.EventID.InputRangeChange, self.OnInputRangeChange)

        FLOG_INFO("CrafterMgr OnMajorCreate profID: " .. self.LastRegisterProfID)
    else
        --临时功能begin：送审版本才会
        -- FLOG_INFO("CrafterMgr UnRegisterGameEvent SkillEnd")
        self.bRegisterMajorEvents = false
        self:UnRegisterGameEventDynamic()
        --临时功能end
        
        -- self:UnRegisterGameEvent(_G.EventID.InputRangeChange, self.OnInputRangeChange)
    end
    --临时功能end
end

function CrafterMgr:UnRegisterGameEventDynamic()
    self:UnRegisterGameEvent(_G.EventID.SkillStart, self.OnSkillStart)
    self:UnRegisterGameEvent(_G.EventID.SkillEnd, self.OnSkillEnd)
    self:UnRegisterGameEvent(_G.EventID.SkillGameEventGetReward, self.OnSkillGameEventGetReward)
end

function CrafterMgr:Reset()
    self.CurState = CraferStatus.None
    self.StartMakeRsp = nil
    self.IsMaking = false
    --self.bResultShown = false 设为true后会立马Reset()

    --做保护，以防界面无法操作
    self:CancelWaitintSkillTime()

    _G.CrafterSkillCheckMgr:Reset()

	_G.ActorMgr:ResetToolMap()

    --self:CancelFastMakeTimers()

    self.LastCrafterSkillRsp = nil
    --临时代码
    self.OtherPlayerCrafterMap = {}

    -- 当前简易制作数量
    self.NowSimpleMakeCount = 0

    if self.DelayCrafterSkillRspTimerID then
        _G.TimerMgr:CancelTimer(self.DelayCrafterSkillRspTimerID)
        self.DelayCrafterSkillRspTimerID = nil
    end
end

--[[function CrafterMgr:CancelFastMakeTimers()
    if self.FastMakeTimerID then
        _G.TimerMgr:CancelTimer(self.FastMakeTimerID)
    end
    self.FastMakeTimerID = nil

    if self.FastMakeTimeOutTimerID then
        _G.TimerMgr:CancelTimer(self.FastMakeTimeOutTimerID)
    end
    self.FastMakeTimeOutTimerID = nil
end]]

function CrafterMgr:OnWaitintSkillTimeOver()
    self.IsWaitingSkillRsp = false
    self.WaitingSkillTimeID = nil
    -- FLOG_ERROR("Crafter OnWaitintSkillTimeOver")
end

function CrafterMgr:StartWaitintSkillTime()
    -- FLOG_INFO("Crafter StartWaitintSkillTime")
    self.IsWaitingSkillRsp = true
    self.WaitingSkillTimeID = _G.TimerMgr:AddTimer(self, self.OnWaitintSkillTimeOver
        , CrafterMgr.WaitingSkillRspTime, 1, 1)
end

function CrafterMgr:CancelWaitintSkillTime()
    -- FLOG_INFO("Crafter CancelWaitintSkillTime")
    self.IsWaitingSkillRsp = false
    if self.WaitingSkillTimeID then
        _G.TimerMgr:CancelTimer(self.WaitingSkillTimeID)
        self.WaitingSkillTimeID = nil
    end
end

--目前炼金没有用到，这个通道暂时保留
--将来8个生产职业都没用到的时候再干掉也可以
function CrafterMgr:OnCastLifeSkill(Params)
    local SkillID = Params.IntParam1
    local Major = MajorUtil.GetMajor()
    if not Major then
        return false
    end

    if self.CurState == CraferStatus.Simple then
        Params.IntParam3 = self.SkillMakeCount or 1
        FLOG_INFO("Crafter SimpleMake SkillMakeCount:%d", Params.IntParam3)
    end
end

function CrafterMgr:SetSkillMakeCount(Num)
    self.SkillMakeCount = Num
end

--------------------- 协议收发 -------------------------------
--开始制作
function CrafterMgr:SendStartMakeReq(RecipeID, MakeType, Num)
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_CRAFTER_START_MAKE
    
    _G.UE.UActorManager.Get():SetVirtualJoystickIsSprintLocked(false)

    Num = Num or 1
    local MsgBody = {
        Cmd = SubMsgID,
        StartMake = {RecipeID = RecipeID, MakeType = MakeType, Batch = Num}
    }

    --快速制作与简易制作逻辑相同，只有协议传输MakeType不同
    if MakeType == ProtoCS.MakeType.MakeTypeSimple or MakeType == ProtoCS.MakeType.MakeTypeFast then
        MsgBody.StartMake.Simple = {TotalNum = Num}
    end

    self.CrafterLogbAlreadyOpend = false  
    self.bSendQuitMakeReq = false
    self.CrafterResultRsp = nil
    self.LastCrafterSkillRsp = nil
    self.DoSimpleSkillEffectWhenSkillEnd = false
    self.ReqMakeNum = Num
    self.bResultShown = false
    FLOG_INFO("Crafter SendStartMakeReq:%d, MakeType:%d Num:%d", RecipeID, MakeType, Num)
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CrafterMgr:OnLifeSkillAction(MsgBody)
    if MsgBody.ErrorCode then
        local EffectNode = self.EffectNodeMap[MajorUtil.GetMajorEntityID()]
        if EffectNode then
            EffectNode.IsDoneSkillEnd = true
        end
        if self.CurState == CraferStatus.Simple then
            if MsgBody.ErrorCode == 100001 then -- "simple make finished"
                _G.EventMgr:SendEvent(_G.EventID.CraftingSimpleFinished) --退出
            end
        end
    end
end

function CrafterMgr:OnNetMsgStartMake(MsgBody)
    if not MsgBody then
        return 
    end

	if MsgBody.ErrorCode then
        _G.FishMgr:StartMoveAndTurnChange(0, false)
        FLOG_ERROR("Crafter StartMake ErrorCode %s", tostring(MsgBody.ErrorCode))
        return 
    end

    if not MsgBody.StartMake then
        FLOG_ERROR("Crafter StartMake is nil")
        return 
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    
    local StartMake = MsgBody.StartMake
    if MajorEntityID == MsgBody.ObjID then
        self.StartMakeRsp = StartMake
        self:SetCamera()
        

        --主角开始制作的时候，记录下是否打开采集笔记
        -- self:HideCraftingLogView()
    end

    --[[临时代码begin
    --对于快速制作，服务器只能先出结果的回包，然后再是StartMake的回包，而且还必须得回
    if MajorEntityID == MsgBody.ObjID then
        FLOG_INFO("Crafter Major OnNetMsgStartMake:%d", MsgBody.StartMake.RecipeID)

        if self.CurState == CraferStatus.FastMake then
            -- self:Reset()
            return 
        end
    else
        FLOG_INFO("Crafter OtherPlayer:%d, OnNetMsgStartMake:%d", MsgBody.ObjID, MsgBody.StartMake.RecipeID)

        --只有快速制作才会同步给第三方StartMake
        self.OtherPlayerCrafterMap[MsgBody.ObjID] = MsgBody.StartMake.RecipeID
        
        local function OtherPlayerEnterAnimFinish()
            local AttrCmp = ActorUtil.GetActorAttributeComponent(MsgBody.ObjID)
            if AttrCmp and ProfConfig[AttrCmp.ProfID] then
                local FastMakeSkillID = ProfConfig[AttrCmp.ProfID].FastMakeSkillID
                _G.UE.UActorUtil.ClientLifeSkillAction(MsgBody.ObjID, FastMakeSkillID)
                FLOG_INFO("Crafter OtherPlayer:%d Begin FastMake :%d, skill:%d", MsgBody.ObjID, MsgBody.StartMake.RecipeID, FastMakeSkillID)
            end
        end

        self.EffectNodeMap[MsgBody.ObjID] = {Msg = nil, IsSkill = true, SkillID = MsgBody.LifeSkillID}

        --临时功能，就写死1.4s了; 也不管打断的情况了
        _G.TimerMgr:AddTimer(nil, OtherPlayerEnterAnimFinish, CrafterMgr.EnterStateTime, 1, 1)

        -- local function CallBack(Params)
        --     local AttrCmp = ActorUtil.GetActorAttributeComponent(MsgBody.ObjID)
        --     if AttrCmp then
        --         local FastMakeSkillID = ProfConfig[AttrCmp.ProfID].FastMakeSkillID
        --         _G.UE.UActorUtil.ClientLifeSkillAction(MsgBody.ObjID, FastMakeSkillID)
        --         FLOG_INFO("Crafter OtherPlayer:%d Begin FastMake :%d, skill:%d", MsgBody.ObjID, MsgBody.StartMake.RecipeID, FastMakeSkillID)
        --     end
        -- end
        
        self:EnterRecipeState(MsgBody.ObjID, MsgBody.StartMake.RecipeID)
    end

    --临时代码end]]

    if MajorEntityID == MsgBody.ObjID and self.CurState == CraferStatus.Noraml then  --需要界面刷新
        FLOG_INFO("Crafter OnNetMsgStartMakeRsp,CraferStatus.Noraml")
        local ViewID = ProfConfig[self.ProfID].MainPanelID
        if not ViewID then
            FLOG_ERROR("Crafter ProfID:%d, ViewID is nil", self.ProfID)
            return 
        end

        _G.UIViewMgr:ShowView(ViewID, StartMake)
        _G.UIViewMgr:ShowView(UIViewID.CrafterMainPanel, StartMake)
        self:HideCraftingLogView()
        _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
        _G.UIViewMgr:HideView(UIViewID.Main2ndPanel)
        _G.EventMgr:SendEvent(_G.EventID.CrafterOnNormalMakeStart)
    elseif MajorEntityID == MsgBody.ObjID and self.CurState == CraferStatus.Train then
        local ViewID = ProfConfig[self.ProfID].MainPanelID
        if not ViewID then
            FLOG_ERROR("Crafter ProfID:%d, ViewID is nil", self.ProfID)
            return 
        end

        _G.UIViewMgr:ShowView(ViewID, StartMake)
        _G.UIViewMgr:ShowView(UIViewID.CrafterMainPanel, StartMake)
        self:HideCraftingLogView()
        _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
        _G.UIViewMgr:HideView(UIViewID.Main2ndPanel)
        _G.EventMgr:SendEvent(_G.EventID.CrafterOnNormalMakeStart)
    elseif MajorEntityID == MsgBody.ObjID and self.CurState == CraferStatus.Simple then
        FLOG_INFO("Crafter OnNetMsgStartMakeRsp,CraferStatus.Simple")
        local Params = nil
        if StartMake.bIsReconnect == true then
            Params = {bIsReconnect = true}
        end
        _G.CraftingLogMgr:SaveFastSearchInfo()
        _G.UIViewMgr:ShowView(UIViewID.CraftingLogSimpleWorkPanel, Params)
	    _G.UIViewMgr:HideView(UIViewID.CraftingLogSetCraftTimesWinView)
        if _G.UIViewMgr:IsViewVisible(UIViewID.Main2ndPanel) then
            _G.UIViewMgr:HideView(UIViewID.Main2ndPanel)
        end
    end
end

function CrafterMgr:OnNetMsgCrafterSkill(MsgBody) 
    if not MsgBody or not MsgBody.ObjID then
        FLOG_ERROR("Crafter OnNetMsgCrafterSkill Msg Error")
        return 
    end

    --快速制作才会这样
    -- if MsgBody.LifeSkillID == 0 then
    --     local ProfID = ActorUtil.GetActorProfID(MsgBody.ObjID)
    --     if ProfID and ProfConfig[ProfID] then
    --         MsgBody.LifeSkillID = ProfConfig[ProfID].FastMakeSkillID
    --     end
    -- end

    --快速制作第三方玩家没收到技能回包
    -- FLOG_INFO("Crafter OnNetMsgCrafterSkill %d skill:%d", MsgBody.ObjID, MsgBody.LifeSkillID)

    local bNeedCheckMakeFinish = false
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local EffectNode = self.EffectNodeMap[MsgBody.ObjID]
    if EffectNode and MsgBody.ObjID == MajorEntityID then
        local SkillID = MsgBody.LifeSkillID
        if SkillID == EffectNode.SkillID then
            if EffectNode.IsSkillEnd or EffectNode.bProcessSkillEffect then
                EffectNode.Msg = MsgBody
                self:DoSkillEffectWhenSkillEnd(EffectNode, MsgBody)
                --如果技能表现已经结束了，则不进行特效表现了
                if CrafterMgr.CurState ~= CraferStatus.Simple then
                    self.EffectNodeMap[MsgBody.ObjID] = nil
                else
                    self.DoSimpleSkillEffectWhenSkillEnd = true
                end
                
                if MsgBody.ObjID == MajorEntityID then
                    bNeedCheckMakeFinish = true
                end
            else
                --技能还在进行中
                --先缓存，等技能表现结束的时候再播放技能结果的特效
                if EffectNode.SkillID == SkillID then
                    EffectNode.Msg = MsgBody
                    EffectNode.bProcessSkillMsg = false
                    self.EffectNodeMap[MsgBody.ObjID] = EffectNode
                end
            end
        end
    else
        --主角：没找到这种情况应该是不存在的：cast的时候有，skillend只是标记
        --第三方同步过来的
        if MsgBody.ObjID ~= MajorEntityID then
            self.EffectNodeMap[MsgBody.ObjID] = {Msg = MsgBody, IsSkill = true, SkillID = MsgBody.LifeSkillID, EntityID = MsgBody.ObjID}
        else
            FLOG_WARNING("Crafter EffectNode is nil OnNetMsgCrafterSkill")
            self:DoSkillEffectWhenSkillEnd(nil, MsgBody)

            bNeedCheckMakeFinish = true
        end
    end
    -- --播放技能成功、失败的特效
    -- local SkillEffectPath = SkillFailedEffectPath
    -- if not MsgBody.CrafterSkill or MsgBody.CrafterSkill.Success then
    --     SkillEffectPath = SkillSuccessEffectPath
    -- end

    -- self:PlayEffectByPosKey(MsgBody.ObjID, self.PosKeyMap[MsgBody.ObjID]
    --     , SkillEffectPath
    --     , "EID_CRAFT_MAT"
    --     , self.SkillEffectIDMap, OnSkillEffectOver)

    --技能结果逻辑
    if MajorEntityID == MsgBody.ObjID then
        self:CancelWaitintSkillTime()
        self.LastCrafterSkillRsp = MsgBody.CrafterSkill

        if bNeedCheckMakeFinish and self:CheckMakeFinish() then
            FLOG_INFO("CrafterMgr Major CheckMakeFinish OnNetMsgCrafterSkill")
            self:SendStartQuitMakeReq()
        end

        if not MsgBody.CrafterSkill then    --快速制作的快速制作技能才没有这个结构体；常规制作是有的
            return
        end

        if MsgBody.CrafterSkill.Success then
            -- FLOG_INFO("Crafter major OnNetMsgCrafterSkill Success")
        else
            FLOG_ERROR("Crafter major OnNetMsgCrafterSkill failed")
            return
        end

        -- --要早于随机事件的处理
        -- _G.EventMgr:SendEvent(_G.EventID.CrafterSkillRsp, MsgBody)
        -- self:DoRandomEvent(MsgBody)

        
        --刷新技能按钮的是否可点的状态
        -- _G.CrafterSkillCheckMgr:RefreshSkillState()

    else
        --第三方暂时不需要处理，因为技能有同步表现动作；不需要界面的表现
        -- FLOG_INFO("Crafter3 OnNetMsgCrafterSkill")
        self:DoRandomEvent(MsgBody)
    end
    
end

--主角
function CrafterMgr:DoSkillEffectWhenSkillEnd(EffectNode, MsgBody, Params)
    local EntityID = MajorUtil.GetMajorEntityID()
    
    local AddBuffAnimDelay = Params and Params.FloatParam1 or 0
    local FlyTextDelay = Params and Params.FloatParam2 or 0
    local EventMgr = _G.EventMgr
    local EventID = _G.EventID

    if EffectNode then
        FLOG_INFO("Crafter Major DoSkillEffectWhenSkillEnd1") 
        local SkillID = EffectNode.SkillID
        --播放技能成功、失败的特效
        -- local SkillEffectPath = SkillFailedEffectPath
        local SoundPath = SkillFailedSoundPath
        if EffectNode.Msg then
            if not EffectNode.Msg.CrafterSkill or EffectNode.Msg.CrafterSkill.Success then
                -- SkillEffectPath = SkillSuccessEffectPath
                SoundPath = SkillSuccessSoundPath

                local ProfType = ProtoCommon.prof_type
                if self.ProfID == ProfType.PROF_TYPE_BLACKSMITH or self.ProfID == ProfType.PROF_TYPE_ARMOR then
                    local ProfMainPanelView = _G.UIViewMgr:FindVisibleView(ProfConfig[self.ProfID].MainPanelID)
                    if ProfMainPanelView and ProfMainPanelView.IsHotForgeSkill(SkillID) then
                        -- SkillEffectPath = SkillHotForgeEffectPath
                    end
                end
            else
                self:SkillUseFailedTip(EffectNode.SkillID, MsgBody.ObjID)
            end

            --第三方立即处理了，主角要滞后一点于技能特效的表现
            if EntityID == MajorUtil.GetMajorEntityID() then
                EventMgr:SendEvent(EventID.CrafterCulinaryOrigin, EffectNode.CulinaryOrigin)
                EventMgr:SendEvent(EventID.CrafterSkillRsp, EffectNode.Msg, AddBuffAnimDelay, FlyTextDelay)
                self:DoPassiveEffect(EffectNode.PassiveEffectNotify)
                self:DoRandomEvent(EffectNode.Msg)
            end

            -- 裁衣匠球特效处理
            if EffectNode.Msg.CrafterSkill then
                if EffectNode.Msg.CrafterSkill.Weaver then
                    local Step = EffectNode.Msg.CrafterSkill.Weaver.Index - EffectNode.Msg.CrafterSkill.Weaver.PreIndex
                    -- 存在重置序列的情况，此处Step会小于0，因此特殊处理
                    Step = Step > 0 and Step or 0
                    local State = EffectNode.Msg.CrafterSkill.Weaver.Balls[1 + Step]
                    if nil ~= WeaverCircleEffectPath[State] then
                        self:PlayWeaverCircleEffect(EntityID, State)
                    else
                        FLOG_WARNING("=========Crafter OnSkillEffectEvent WeaverCircle State Error")
                    --     self:PlayWeaverCircleEffect(EntityID,CircleStateIndex.Double)
                    end
                end
            end
        end
    else
        FLOG_INFO("Crafter Major DoSkillEffectWhenSkillEnd2")
        -- EventMgr:SendEvent(EventID.CrafterCulinaryOrigin, EffectNode.CulinaryOrigin)
        EventMgr:SendEvent(EventID.CrafterSkillRsp, MsgBody, AddBuffAnimDelay, FlyTextDelay)
        self:DoRandomEvent(MsgBody)
    end
end

--- 技能失败飘字
---@param SkillID 技能id
function CrafterMgr:SkillUseFailedTip(SkillID, ObjID)
    local EntityID = MajorUtil.GetMajorEntityID()
    if EntityID ~= ObjID then
        return
    end

    local SkillFailedTipID = MsgTipsID.CrafterCastSkillFailed
    local CostList = SkillMainCfg:FindValue(SkillID, "CostList") or {}
    for _, Cost in pairs(CostList) do
        if Cost.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_CATALYST then
            SkillFailedTipID = MsgTipsID.CrafterCastCatalystFailed
            break
        end
    end
    MsgTipsUtil.ShowTipsByID(SkillFailedTipID)
end

function CrafterMgr:OnNetMsgCulinaryOrigin(MsgBody)
    if not MsgBody then
        return
    end
    if not MsgBody.Origin then
        return
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID ~= MsgBody.ObjID then
        return
    end

    local EffectNode = self.EffectNodeMap[MsgBody.ObjID]
    if EffectNode then
        EffectNode.CulinaryOrigin = MsgBody
        
        if EffectNode.IsSkillEnd then
            _G.EventMgr:SendEvent(_G.EventID.CrafterCulinaryOrigin, EffectNode.CulinaryOrigin)
        end
    end
end

function CrafterMgr:OnNetMsgCulinaryStorm(MsgBody)
    if not MsgBody or not MsgBody.Storm then
        return
    end
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID ~= MsgBody.ObjID then
        return
    end
    _G.EventMgr:SendEvent(_G.EventID.CrafterCulinaryStorm, MsgBody.Storm)
end

function CrafterMgr:OnNetMsgPassiveEffectNotify(MsgBody)
    if not MsgBody then
        return
    end

    local PassiveEffectNotify = MsgBody.EffectNotice
    if not PassiveEffectNotify then
        return
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local ObjID = MsgBody.ObjID
    if MajorEntityID ~= ObjID then
        return
    end

    local EffectNode = self.EffectNodeMap[ObjID]
    if EffectNode then
        EffectNode.PassiveEffectNotify = PassiveEffectNotify
    end
end

function CrafterMgr:ShowStateTips(Params, bHideOtherTips)
    local UIViewMgr = _G.UIViewMgr
    local function ShowTipsCallback(CbParams)
        if CbParams.bHideOtherTips then
            UIViewMgr:HideView(UIViewID.CrafterStateTips)
        end
        UIViewMgr:ShowView(UIViewID.CrafterStateTips, CbParams.Params)
    end

	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.CrafterStateTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.CrafterStateTips)
			return true
		end
	end

    local Config = {Type = ProtoRes.tip_class_type.TIP_COMPLETE_PRODUCE, Callback = ShowTipsCallback}
    Config.Params = {Params = Params, bHideOtherTips = bHideOtherTips}
    Config.StopCallback = HideTipsCallback

    -- if bHideOtherTips then
    --     _G.TipsQueueMgr:Stop(true, true, TipsQueueDefine.STOP_REASON.NEWTIPS)
    -- end

    _G.TipsQueueMgr:AddPendingShowTips(Config) 
    
end

function CrafterMgr:DoPassiveEffect(PassiveEffectNotify)
    if not PassiveEffectNotify then
        return
    end

    local NoticeList = PassiveEffectNotify.Notices
    local NoticeTriggeredList = {}  -- 去重

    for _, TipsID in pairs(NoticeList) do
        if TipsID and not NoticeTriggeredList[TipsID] then
            MsgTipsUtil.ShowTipsByID(TipsID)
            NoticeTriggeredList[TipsID] = true
        end
    end
end

function CrafterMgr:UpdateRandomEventMaskInternal(bHasMask)
    CrafterSkillCheckMgr.bRandomEventLock = bHasMask
    self:ForEachCrafterSkillView(function(View)
        if View.UpdateMaskFlag then
            local EMaskType = View:GetEMaskType()
            View:UpdateMaskFlag(bHasMask, EMaskType.RandomEvent)
        end
    end)
end

function CrafterMgr:UpdateRandomEventMask(LockSkillTime)
    self:UpdateRandomEventMaskInternal(true)
    TimerMgr:AddTimer(self, self.UpdateRandomEventMaskInternal, LockSkillTime, 0, 1, false, "UpdateRandomEventMask")
end

function CrafterMgr:DoRandomEvent(MsgBody)
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    local EventID = nil
    local EventIDs = MsgBody.CrafterSkill.EventIDs
    if EventIDs and #EventIDs > 0 then
        for index = 1, #EventIDs do
            EventID = EventIDs[index]

            local Cfg = RandomEventCfg:FindCfgByKey(EventID)
            --只有随机事件的处理
            if Cfg then
                if MajorEntityID == MsgBody.ObjID then
                    local Params = { EventType = EventID }
                    if Cfg.Desc and string.len(Cfg.Desc) > 0
                        and Cfg.ColorID and Cfg.ColorID > 0 then
                        self:ShowStateTips(Params)
                        _G.EventMgr:SendEvent(_G.EventID.CrafterRandomEvent, Params)
                        FLOG_INFO("----------Crafter major 随机事件 EventID:%d", EventID)
                    end

                    local LockSkillTime = Cfg.LockSkillTime
                    if LockSkillTime and LockSkillTime > 0 then
                        self:UpdateRandomEventMask(LockSkillTime)
                    end

                    _G.EventMgr:SendEvent(_G.EventID.MajorCrafterRandomEvent, Params)
                end

                if Cfg.SoundPath and string.len(Cfg.SoundPath) > 0 then
                    AudioUtil.LoadAndPlaySoundEvent(MsgBody.ObjID, Cfg.SoundPath)
                end
                
                if Cfg.EffectPath and Cfg.EffectEID then
                    local PosKey = Cfg.EffectPosKey
                    if PosKey and PosKey == 0 then
                        PosKey = self.PosKeyMap[MsgBody.ObjID]
                    end

                    if EventID == ProtoRes.EVENT_TYPE.EVENT_TYPE_BOOM then
                        PosKey = self.PosKeyMap[MsgBody.ObjID]
                        self:PlayVfxOnMeshSocket(MsgBody.ObjID, PosKey
                            , Cfg.EffectPath, 0
                            , self.RandomEventEffectIDMap)

                        local AvatarCmp = ActorUtil.GetActorAvatarComponent(MsgBody.ObjID)
                        if AvatarCmp then
                            -- AvatarCmp:StartCharaColor(FVector(0, 0, 0), FVector(0, 0, 0), 1, 1, 1, 1, 0, 0
                            --     , 1.1, false, true);

                            -- local function DelayStartCharaColor()
                            --     AvatarCmp:StartCharaColor(FVector(0, 0, 0), FVector(1, 1, 1), 1, 1, 1, 0, 0, 1
                            --         , 0.8, false, true);
                            -- end
                            -- _G.TimerMgr:AddTimer(nil, DelayStartCharaColor, 1, 1, 1)
							local Curve = _G.ObjectMgr:LoadObjectSync("CurveVector'/Game/Assets/Effect/BluePrint/Character/Blacken/C_BlackenParams.C_BlackenParams'")
							AvatarCmp:StartBlacken(Curve)
                        end
                    else
                        self:PlayEffectByPosKey(MsgBody.ObjID, PosKey
                            , Cfg.EffectPath
                            , Cfg.EffectEID
                            , self.RandomEventEffectIDMap)
                    end
                end
            end
        end
    end
end

--退出、放弃制作
function CrafterMgr:SendStartQuitMakeReq()
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_CRAFTER_QUIT_MAKE

    local MsgBody = {
        Cmd = SubMsgID,
        QuitMake = {}
    }

    self.bSendQuitMakeReq = true
    -- self.EffectNodeMap[MajorUtil.GetMajorEntityID()] = nil
    FLOG_INFO("Crafter SendStartQuitMakeReq")
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

    -- self:Reset()
end

--退出的回包，自己的话不用管，只处理第三方的就好了
function CrafterMgr:OnNetMsgQuitMake(MsgBody)
    if not MsgBody or not MsgBody.ObjID then
        FLOG_ERROR("Crafter OnNetMsgQuitMake Msg Error")
        return 
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID ~= MsgBody.ObjID then
        FLOG_INFO("Crafter3 OnNetMsgQuitMake")
    end
end

function CrafterMgr:GetResultRsp()
    return self.CrafterResultRsp
end

--制造结果
function CrafterMgr:OnNetMsgResult(MsgBody)
    if not MsgBody or not MsgBody.ObjID then
        FLOG_ERROR("Crafter OnNetMsgResult Msg Error")
        return 
    end
   
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local Result = MsgBody.Result
    
    -- local function DelayClearCrafterResult()
    --     self.CrafterResultRsp = nil
    -- end
    -- _G.TimerMgr:AddTimer(nil, DelayClearCrafterResult, 1.5, 1, 1)


    -- 原来爆炸就失败，现在爆炸不一定失败，所以当做Event来通知客户端了，所以就没有AlchemyResult了
    -- --炼金的特殊处理，其他职业也是走类似的分支
    -- if Result.AlchemyResult then
    --     _G.AlchemistMgr:OnNetMsgResult(MsgBody)
    -- end

    if MajorEntityID ~= MsgBody.ObjID then
        if Result.Success == true then
            FLOG_INFO("Crafter3 success")
        else
            FLOG_INFO("Crafter3 failed")
        end

        return
    end

    --[[临时代码begin --其实快速制作走不进去的
    if self.CurState == CraferStatus.FastMake then
        -- self.LastFastMakeRsp = MsgBody
        --本地玩家
        self:Reset()
        return 
    end
    --临时代码end]]

    if MajorEntityID == MsgBody.ObjID then
        self.CrafterResultRsp = MsgBody
        if self.CurState ~= CraferStatus.Train then
            local Result = self.CrafterResultRsp.Result

            if self.CurState == CraferStatus.Noraml then
                OnSkillEffectOver(MajorEntityID)
            end
            
            self:OnNetMakeResult(Result)
        end
       
        if self.CurState == CraferStatus.Simple then
            if Result.SimpleRsp then
                if self.DoSimpleSkillEffectWhenSkillEnd then
                    FLOG_INFO("========= Crafter DoSimpleSkillEffectWhenSkillEnd RltMsg, FailedNum:%d, successNum:%d, HQNum:%d"
                        , Result.SimpleRsp.FailNum, Result.SimpleRsp.SuccessNum, Result.SimpleRsp.HQNum)

                    _G.CraftingLogSimpleCraftWinVM:OnSimpleMakeRltCounts(Result.SimpleRsp) 
                    _G.TimerMgr:AddTimer(nil, OnResultEffectOver, 0.5, 1, 1)
                    self.DoSimpleSkillEffectWhenSkillEnd = false
                end
            end
        end

        return 
    end

    --本地玩家
    self:Reset()
end

function CrafterMgr:OnNetMsgQueryCommStatRsp(MsgBody)
    local bReconnectWaitRsp = self.bReconnectWaitRsp
    if not bReconnectWaitRsp then
        return
    end

    FLOG_INFO("[CrafterMgr] OnNetMsgQueryCommStatRsp")
    self.bReconnectWaitRsp = false
    local MajorProfID = MajorUtil:GetMajorProfID()
	local ProfInfo = RoleInitCfg:FindCfgByKey(MajorProfID)
    if not ProfInfo then
        return
    end
     -- 采集有断线重连, 但是能工巧匠没有
    if self.CurState == CraferStatus.None and ProfInfo.Class ~= ProtoCommon.class_type.CLASS_TYPE_CARPENTER then
        return
    end

    local Status = MsgBody.Status
    if nil == Status then
        return
    end

    local bServerInState = Status.StatBits & (1 << ProtoCommon.CommStatID.COMM_STAT_PICKUP) > 0
    if bReconnectWaitRsp then
        if bServerInState then
            FLOG_INFO("[CrafterMgr] Reconnect GetReward1, in make state")
            self:OnSkillGameEventGetReward(true)
            self:OnReconnect(bServerInState)
        else
            -- 偶现断线重连后, 生产职业武器残留的bug, 这里强制隐藏一下武器
            FLOG_INFO("[CrafterMgr] Reconnect but not in server state,  IsMaking:%s", tostring(self.IsMaking))
            local Major = MajorUtil.GetMajor()
            if Major and self.IsMaking then
                -- Major:ClearCrafterWeaponState(false)
                local EntityID = MajorUtil.GetMajorEntityID()
                local SpellID = AnimMgr:GetCachedSpellID(EntityID, true)
                if not SpellID then
                    SpellID = self.CurRecipeID
                end

                if SpellID then
                    self:ExitRecipeState(EntityID, SpellID)
                end
            end
            self:Reset()
        end
        self.LoginResParams = nil
        return
    end
    if bServerInState then
        -- 临时处理, 进游戏发个quit请求?
        FLOG_INFO("[CrafterMgr] Reconnect GetReward2 before QuitState")
        self:QuitMakState()
        _G.FLOG_INFO("[Warning] Server is in craftering state while entering game, so sent QuitMake msg.")
    end
end
function CrafterMgr:QuitMakState()
    self:OnSkillGameEventGetReward(true)
    self:SendStartQuitMakeReq()
end

function CrafterMgr:SendMkChangeEvent(NewMkValue)
    local EventParams = {}
    EventParams.ULongParam4 = MajorUtil.GetMajorMaxMk()
    EventParams.ULongParam3 = NewMkValue
    EventParams.ULongParam1 = MajorUtil.GetMajorEntityID()
    EventParams.BoolParam1 = true
    _G.EventMgr:SendEvent(_G.EventID.Attr_Change_MK, EventParams)
end

function CrafterMgr:OnCombatAttrUpdate(MsgBody)
    local CombatAttrUpdate = MsgBody.AttrUpdate
	local EntityID = CombatAttrUpdate.ObjID
	if EntityID == MajorUtil.GetMajorEntityID() then
		local Attrs = CombatAttrUpdate.Attrs.KeyValue
        local AttrMk = attr_mk
		for _, v in pairs(Attrs) do
			if v.Attr == AttrMk then
                self:SendMkChangeEvent(v.Value)
                return
            end
		end
	end
end

function CrafterMgr:OnNetMakeResult(Result)
    if not Result then
        return
    end
    FLOG_INFO("CrafterMgr:OnNetMakeResult")
    
    local IsNormal = self.CurState == CraferStatus.Noraml
    --制作成功之后的批量提示，和已制作标志的改变
    _G.EventMgr:SendEvent(_G.EventID.CrafterOnMakeComplete, Result, IsNormal)

    --升级提示
    local function ShowTips()
        _G.ProfMgr:DoNetMsgLevelUpPreSaved(MajorUtil.GetMajorProfID())
    end
    self:RegisterTimer(ShowTips, 3, 0, 1, nil)
end

function CrafterMgr:GetProductNameAndCountStr(ItemID, Num)
    local Cfg = ItemCfg:FindCfgByKey(ItemID)
    if Cfg then
        local Content = string.format("\"%s\" x%d ", ItemCfg:GetItemName(self.ItemID), Num)
        return Content
    end

    return ""
end

--------------------- 进入、退出制作的动作表现 -------------------------------

function CrafterMgr:ShowRecipeWeapon(EntityID, RecipeID)
    local RecipeConfig = RecipeCfg:FindCfgByKey(RecipeID)
    if RecipeConfig then
        if EntityID == MajorUtil.GetMajorEntityID() then
            self.IsMaking = true
        end

        local ProfID = ActorUtil.GetActorProfID(EntityID)
        local ToolID = nil
        local ToolAnimCfg = self:GetRecipeToolAnimCfg(ProfID, RecipeConfig)
        if ToolAnimCfg == nil then
            FLOG_ERROR("[CrafterMgr RecipeID(%d)'s AnimID is invalid ", RecipeID)
            return
        else
            ToolID = ToolAnimCfg.Tool
        end
        
        if not ToolID then
            FLOG_ERROR("CrafterMgr Recipe(%d)'s Tool is error", RecipeID)
            return 
        end
        if ProfID and ProfConfig[ProfID] and ToolID then
            FLOG_INFO("Crafter ShowRecipeWeapon %d %d", ToolID, EntityID)
            -- print(EntityID)

            _G.ActorMgr:SetToolMap(EntityID, ToolID)

            -- local IsMainWeapon = ToolID == ProfConfig[ProfID].MainWeapon
            -- if IsMainWeapon then
            --     _G.UE.UActorUtil.AddHideAvatarPart(ProfConfig[ProfID].SecondWeapon, false)
            -- else
            --     _G.UE.UActorUtil.AddHideAvatarPart(ProfConfig[ProfID].MainWeapon, false)
            -- end
    
            -- --只update1次
            -- _G.UE.UActorUtil.RemoveHideAvatarPart(ToolID, true)
        end
    end
end

function CrafterMgr:HideRecipeWeapon(EntityID, RecipeID)
    local RecipeConfig = RecipeCfg:FindCfgByKey(RecipeID)
    if RecipeConfig then
        if EntityID == MajorUtil.GetMajorEntityID() then
            self.IsMaking = false
        end

        --恢复武器的显示
        --只update1次
        local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
        local ProfID = nil
        if nil ~= AttributeComponent then
            ProfID = AttributeComponent.ProfID
        end

        local ToolID = nil
        local ToolAnimCfg = nil
        if ProfID ~= nil then
            ToolAnimCfg = self:GetRecipeToolAnimCfg(ProfID, RecipeConfig)
        end
        if ToolAnimCfg == nil then
            FLOG_WARNING("[CrafterMgr RecipeID(%d)'s AnimID is invalid ", RecipeID)
            return
        else
            ToolID = ToolAnimCfg.Tool
        end
        
        if not ToolID then
            FLOG_WARNING("CrafterMgr Recipe(%d)'s Tool is error", RecipeID)
            return 
        end

        if ProfID and ProfConfig[ProfID] and ToolID then
            FLOG_WARNING("Crafter HideRecipeWeapon")
            _G.ActorMgr:SetToolMap(EntityID, nil)

            -- _G.UE.UActorUtil.RemoveHideAvatarPart(ProfConfig[ProfID].MainWeapon, false)
            -- _G.UE.UActorUtil.RemoveHideAvatarPart(ProfConfig[ProfID].SecondWeapon, true)
        end
    end
end

--获取制作物的AnimID
function CrafterMgr:GetRecipeToolAnimID(EntityID, RecipeID)
	local Recipe = RecipeCfg:FindCfgByKey(RecipeID)
	if Recipe == nil then
		FLOG_ERROR("[CrafterMgr:GetRecipeToolAnimID ] Recipe ID %d is invalid ", tostring(RecipeID))
		return
	end

	local ToolID = nil
	local ToolAnimCfg = self:GetRecipeToolAnimCfg(ActorUtil.GetActorProfID(EntityID), Recipe)
	if ToolAnimCfg == nil then
		FLOG_ERROR("[CrafterMgr MainSubTool(%d)'s AnimID is invalid ", Recipe.MainSubTool)
		return
    else
        ToolID = ToolAnimCfg.Tool
	end

	if not ToolID then
		FLOG_ERROR("CrafterMgr Recipe(%d)'s Tool is error", RecipeID)
		return 
	end
	
	return ToolAnimCfg.AnimID, ToolAnimCfg.TargetEffectPosKey
end

function CrafterMgr:GetRecipeToolAnimCfg(ProfID, RecipeCfg)
    if RecipeCfg then
        local MainSubTool = RecipeCfg.MainSubTool
        -- if MainSubTool == 1 and not _G.EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND) then
        --     MainSubTool = 0
        -- end
    
        local ToolAnimCfg = RecipetoolAnimCfg:FindCrafterTool(ProfID, MainSubTool)
        return ToolAnimCfg
    end

    return nil
end

function CrafterMgr:EnterRecipeState(EntityID, RecipeID, CallBack, NoLoop)
    if not RecipeID then
        FLOG_ERROR("CrafterMgr EnterRecipeState RecipeID is nil")
        return
    end

    if EntityID == MajorUtil.GetMajorEntityID() then
        CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatCraft, true)
        self:RegisterGameEvent(_G.EventID.StateChange, self.OnStateChange)
        
        local CameraMgr = _G.UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            CameraMgr:SwitchCamera(MajorUtil.GetMajor(), 0)
        end
        self.CurRecipeID = RecipeID
        
        _G.NaviDecalMgr:SetNavPathHiddenInGame(true)
        _G.NaviDecalMgr:DisableTick(true)
        _G.BuoyMgr:ShowAllBuoys(false)
        EffectUtil.SetIsInDialog(false) 
        MainPanelVM:SetEmotionVisible(false)
        MainPanelVM:SetPhotoVisible(false)
    end
    
	self:ShowRecipeWeapon(EntityID, RecipeID)
    
    

	local AnimID, TargetEffectPosKey = self:GetRecipeToolAnimID(EntityID, RecipeID)
	if not AnimID then
		return
	end

    local AvatarComp = ActorUtil.GetActorAvatarComponent(EntityID)
    if AvatarComp then
        AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, HairRenderPriority)
    end

    --允许移动打断
    -- if EntityID == MajorUtil.GetMajorEntityID() then
    --     FLOG_INFO("CrafterMgr Major EnterRecipeState")
    --     _G.FishMgr:StartMoveAndTurnChange(0, true)
    -- end

    self.PosKeyMap[EntityID] = TargetEffectPosKey

	AnimMgr:PlayEnterAnim(EntityID, AnimID, CallBack, NoLoop)
    
    --延迟播放代表制作物的白球特效
    --白球特效和裁衣的状态球特效使用的是同一个特效，由于裁衣球特效的特效的实现方案更新，因此顺带更新
    local function DelayPlayTargetEffect()
        self:PlayVfxOnCrafterWeapon(EntityID, 0, TargetEffectPosKey, TargetEffectPath, 0, self.TargetEffectIDMap)

        self.DelayTargetEffectTimerID = nil
    end

    self.DelayTargetEffectTimerID = _G.TimerMgr:AddTimer(nil, DelayPlayTargetEffect, CrafterMgr.DelayPlayTargetEffectTime, 1, 1)

    if EntityID == MajorUtil.GetMajorEntityID() then
        -- 处理Actor的显隐
        if self.bShouldHideOtherPlayer then
            self:HideOtherPlayers()
        end
        
        _G.EventMgr:SendEvent(_G.EventID.CrafterEnterRecipeState)
    end
    _G.EventMgr:SendEvent(_G.EventID.CrafterAllEnterRecipeState,EntityID)
    -- 修改头顶UI挂点
    _G.HUDMgr:SetEidMountPoint(EntityID, "EID_UI_NAME_CFT")
end

local EVFXEID = _G.UE.EVFXEID
function CrafterMgr:PlayEffectByPosKey(EntityID, PosKey, EffectPath, SocketName, EffectIDMap, CompleteCallBack)
    self:PlayVfxOnCrafterWeapon(EntityID, EVFXEID[SocketName], PosKey, EffectPath, 0, EffectIDMap, CompleteCallBack)
end

function CrafterMgr:ExitRecipeState(EntityID, RecipeID)
    local Major = MajorUtil.GetMajor()
    if not Major then
        return
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if EntityID == MajorEntityID then        
        self:UnRegisterGameEvent(_G.EventID.StateChange, self.OnStateChange)
        CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatCraft, false)
        local CamCtrComp = Major:GetCameraControllComponent()
        if CamCtrComp then
            CamCtrComp:SetIgnoreSocketOffset(false)
        end

        self:RestoreHidedPlayers()
        self.CurRecipeID = 0
    end

    if self.EffectNodeMap == nil then  -- AnimMgr那边可能在CrafterMgr没初始化的时候调用这个函数?
        return
    end
    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode and not EffectNode.CacheExitState and not EffectNode.IsDoneSkillEnd and  --表示当前正在技能表现，退出状态要等技能结束后再进行
       EntityID == MajorEntityID then  -- 第三方不需要CacheState, 直接退出
        EffectNode.CacheExitState = true
        EffectNode.RecipeID = RecipeID
        FLOG_INFO("Crafter CacheExitState skillID:%d", EffectNode.SkillID)
        return 
    else
        FLOG_INFO("Crafter ExitRecipteState")
    end

    if self.DelayTargetEffectTimerID then
        _G.TimerMgr:CancelTimer(self.DelayTargetEffectTimerID)
        self.DelayTargetEffectTimerID = nil
    end

    if EffectNode then
        if EffectNode.DoSkillEndTimerID then
            _G.TimerMgr:CancelTimer(EffectNode.DoSkillEndTimerID)
        end

        self.EffectNodeMap[EntityID] = nil
    end

    if EntityID == MajorEntityID then
        local UIViewMgr = _G.UIViewMgr
        FLOG_INFO("CrafterMgr Major ExitRecipeState")
        _G.FishMgr:StartMoveAndTurnChange(2, false)

        local CrafterMainPanelView = UIViewMgr:FindVisibleView(UIViewID.CrafterMainPanel)
        local ProfMainPanelView = self.ProfID and UIViewMgr:FindVisibleView(ProfConfig[self.ProfID].MainPanelID) or nil

        if not self.IsCrafterLogViewOpen() and not self.CrafterLogbAlreadyOpend then
            if not self.bResultShown and self.CrafterResultRsp then 
                FLOG_WARNING("[CrafterMgr] Exit crafting without result shown before.") 
                OnSkillEffectOver(EntityID)
            end
            -- 清除AnimOutTime避免重叠
            local function GetAnimOutTime()
                return 0
            end
            if CrafterMainPanelView then
                CrafterMainPanelView.GetAnimOutTime = GetAnimOutTime
                -- 播放退场动画
                CrafterMainPanelView:PlayAnimOutRecursively()
            end
            if ProfMainPanelView then
                ProfMainPanelView.GetAnimOutTime = GetAnimOutTime
                ProfMainPanelView:PlayAnimOutRecursively()

                if ProfMainPanelView.OnExitRecipeState then
                    ProfMainPanelView:OnExitRecipeState()
                end
            end
            self.DelayShowLogViewTimerID = 
                _G.TimerMgr:AddTimer(nil, self.DelayShowLogView, CrafterMgr.DelayShowLogViewTime, 1, 1)  
        else
            local CameraMgr = _G.UE.UCameraMgr.Get()
            if CameraMgr ~= nil then
                CameraMgr:ResumeCamera(0, true, Major)
            end
        end
        self.CrafterLogbAlreadyOpend = false  
        self:Reset()
    end

    if not RecipeID then
        FLOG_ERROR("CrafterMgr ExitRecipeState RecipeID is nil")
        return
    end

	local AnimID = self:GetRecipeToolAnimID(EntityID, RecipeID)
	if not AnimID then
		return
	end

    local AvatarComp = ActorUtil.GetActorAvatarComponent(EntityID)
    if AvatarComp then
        AvatarComp:SetPartTranslucencySortPriority(AvatarType_Hair, 0)
    end

    _G.EventMgr:SendEvent(_G.EventID.CrafterExitRecipeState, EntityID)

    _G.TimerMgr:AddTimer(nil, function()
        AnimMgr:PlayExitAnim(EntityID, AnimID,function()
            _G.EventMgr:SendEvent(_G.EventID.CrafterAllExitAllState,EntityID)
            end)
        self:HideRecipeWeapon(EntityID, RecipeID)

        -- 修改头顶UI挂点
        _G.HUDMgr:ResetEidMountPoint(EntityID)
    end, CrafterMgr.DelayPlayExitAnimTime, 1, 1)

    local TargetEffectID = self.TargetEffectIDMap[EntityID]
    if TargetEffectID then
        self:ClearVfx(EntityID)
        self.TargetEffectIDMap[EntityID] = nil
        -- FLOG_INFO("Crafter BreakEffect %d", TargetEffectID)
    end
end

function CrafterMgr:DelayShowLogView()
    local CameraMgr = _G.UE.UCameraMgr.Get()
    if CameraMgr ~= nil then
        CameraMgr:ResumeCamera(0, true, MajorUtil.GetMajor())
    end

    local UIViewMgr = _G.UIViewMgr
    UIViewMgr:HideView(UIViewID.CrafterMainPanel)
    if not (CrafterMgr.ProfID and ProfConfig[CrafterMgr.ProfID]) then
        CrafterMgr.ProfID = CraftingLogMgr.NowPropData and CraftingLogMgr.NowPropData.Craftjob
    end
    if CrafterMgr.ProfID and ProfConfig[CrafterMgr.ProfID] then
        UIViewMgr:HideView(ProfConfig[CrafterMgr.ProfID].MainPanelID)
    end
    UIViewMgr:HideView(UIViewID.CraftingLogSimpleWorkPanel)
    _G.SkillTipsMgr:HideCrafterSkillTips()
    _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
    UIViewMgr:ShowView(UIViewID.CraftingLog)
    if _G.CraftingLogMgr.OnShowSearchInfo ~= nil then
        _G.EventMgr:SendEvent(_G.EventID.CraftingLogFastSearch, _G.CraftingLogMgr.OnShowSearchInfo)
    end
    CrafterMgr.DelayShowLogViewTimerID = nil
    
    _G.NaviDecalMgr:SetNavPathHiddenInGame(false) 
    _G.NaviDecalMgr:DisableTick(false)
    _G.BuoyMgr:ShowAllBuoys(true)
    MainPanelVM:SetEmotionVisible(true)
    MainPanelVM:SetPhotoVisible(true)
end

--------------------- 简易制作 begin  -------------------------------
function CrafterMgr:GetSimpleCraftLimit(MaterialData, CrystalTypeData, SimpleCraftLimit)
    local UpperLimitCount = SimpleCraftLimit
    for _, value in pairs(MaterialData) do
        if value.ItemID ~= 0 then
            local PropHaveNumber = value.IsHQ and _G.BagMgr:GetItemHQNum(value.ItemID)
                                        or _G.BagMgr:GetItemNumWithHQ(value.ItemID)
            if PropHaveNumber >= value.ItemNum then
                local CanMakeCount = math.floor(PropHaveNumber / value.ItemNum)
                if UpperLimitCount > CanMakeCount then
                    UpperLimitCount = CanMakeCount
                end
            else
                return 0
            end
        end
    end

    for _, value in pairs(CrystalTypeData) do
        if value.ItemID ~= 0 then
            local PropHaveNumber = BagMgr:GetItemNum(value.ItemID)
            if PropHaveNumber >= value.ItemNum then
                local CanMakeCount = math.floor(PropHaveNumber / value.ItemNum)
                if UpperLimitCount > CanMakeCount then
                    UpperLimitCount = CanMakeCount
                end
            else
                return 0
            end
        end
    end

    return UpperLimitCount
end

---获取当前最大制作数量
function CrafterMgr:GetMaxSimpleMakeCount()
    local NowPropData = _G.CraftingLogMgr:GetNowPropData()
    if not NowPropData then
        self.NowSimpleMakeCount = 0
        return 0
    end
    
    local MaterialData = _G.CraftingLogMgr:GetPropMaterialData(NowPropData.Material
                            , NowPropData.IsRequireHQ or {})
    local CrystalType = NowPropData.CrystalType
    local SimpleCraftLimit = NowPropData.FastCraft == 1 and NowPropData.HQFastCraftLimit or NowPropData.SimpleCraftLimit

    local UpperLimitCount = self:GetSimpleCraftLimit(MaterialData, CrystalType, SimpleCraftLimit)
    local BagLeftNum = _G.BagMgr:GetBagLeftNum()
    if UpperLimitCount > BagLeftNum then
        local cfg = ItemCfg:FindCfgByKey(NowPropData.ProductID)
        if cfg.MaxPile and cfg.MaxPile > 1 then
            local HasNum = _G.BagMgr:GetItemNum(NowPropData.ItemID)
            local LeftPile = cfg.MaxPile - HasNum
            if LeftPile < UpperLimitCount then
                UpperLimitCount = LeftPile
            end
        else
            UpperLimitCount = BagLeftNum
        end
    end

    FLOG_INFO("Crafter SimpleMake UpperLimitCount:%d, BagLeftNum:%d, SimpleCraftLimit:%d"
        , UpperLimitCount, BagLeftNum, SimpleCraftLimit)

    return UpperLimitCount
end

function CrafterMgr:GetNowSimpleMakeCount()
    return self.NowSimpleMakeCount
end

function CrafterMgr:SetNowSimpleMakeCount(NowSimpleMakeCount)
    self.NowSimpleMakeCount = NowSimpleMakeCount
end
--------------------- 简易制作 end  ----------------------------------------

-- 根据Index获取对应的View
function CrafterMgr:RegisterSkillView(ProfID, Index, View)
	if Index == nil then
		return
	end

    local SkillViewMap = self.SkillViewMap
    if SkillViewMap[ProfID] == nil then
        SkillViewMap[ProfID] = {}
    end
    local ProfSkillViewMap = SkillViewMap[ProfID]
	local IndexItems = ProfSkillViewMap[Index]
	if IndexItems == nil then
		IndexItems = {}
		setmetatable(IndexItems, { __mode = "v" })
		ProfSkillViewMap[Index] = IndexItems
	end

    table.insert(IndexItems, View)
end

function CrafterMgr:UnRegisterSkillView(ProfID, Index, View)
    if Index == nil then
		return
	end

    -- UnRegister的时候, self.ProfID不一定是注册时候的ProfID了
    local ProfSkillViewMap = self.SkillViewMap[ProfID] or {}
	local IndexItems = ProfSkillViewMap[Index]
	if IndexItems == nil then
		return
	end

    table.remove_item(IndexItems, View)
end

function CrafterMgr:GetSkillViewsByIndex(Index)
    local ProfSkillViewMap = self.SkillViewMap[self.ProfID] or {}
    return ProfSkillViewMap[Index]
end

-- 裁衣清除原有特效
function CrafterMgr:ClearVfx(EntityID)
    local EffectID = self.TargetEffectIDMap[EntityID]
    if EffectID then
        EffectUtil.StopVfx(EffectID,0,0)
    end
end

-- 裁衣匠球特效播放
function CrafterMgr:PlayWeaverCircleEffect(EntityID,CircleState)
    -- 播放新特效
    local Path = WeaverCircleEffectPath[CircleState]
    local PosKey = self.PosKeyMap[EntityID]
    self:PlayVfxOnCrafterWeapon(EntityID, 0, PosKey, Path, 0, self.TargetEffectIDMap)
end

local AttachPointType_AvatarPartType = _G.UE.EVFXAttachPointType.AttachPointType_AvatarPartType
local CrafterPlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_Crafter
local AvatarTypeMaster = _G.UE.EAvatarPartType.MASTER

-- 生产工具特效播放，目前在裁衣匠中使用
function CrafterMgr:PlayVfxOnCrafterWeapon(EntityID, ElementID, PosKey, EffectPath, FadeInTime, EffectIDMap, CompleteCallBack)
    if not self:IsInCrafterStateFast(EntityID) then
        if CompleteCallBack then
            CompleteCallBack()
        end
        return
    end
    local ActorAvatarCmp = ActorUtil.GetActorAvatarComponent(EntityID)
    if not ActorAvatarCmp then
        return 
    end

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor or not PosKey then
        return 
    end
    -- 兼容之前的设计, 之前PosKey = 0表示使用Cache的PosKey, -1表示使用主Mesh
    if PosKey == -1 then
        PosKey = AvatarTypeMaster
    end

    local Path = CommonUtil.ParseBPPath(EffectPath)

    -- 清除上次播放的特效
    local TargetEffectID = EffectIDMap[EntityID]
    if TargetEffectID then
        EffectUtil.StopVfx(TargetEffectID,0,0)
    end
    local VfxParameter = _G.UE.FVfxParameter()
    
    VfxParameter.VfxRequireData.EffectPath = Path
    VfxParameter.PlaySourceType = CrafterPlaySourceType
    local Tranform = Actor:GetTransform()
    VfxParameter.VfxRequireData.VfxTransform = Tranform
    VfxParameter:SetCaster(Actor, ElementID, AttachPointType_AvatarPartType, PosKey)
    if CompleteCallBack then
        VfxParameter.OnVfxEnd = CommonUtil.GetDelegatePair(CompleteCallBack, true)
    end
    TargetEffectID = EffectUtil.PlayVfx(VfxParameter, FadeInTime)
    --如果特效不播也保证CompleteCallBack的执行，[简易制作]不卡连续制作的流程
    if TargetEffectID == 0 and CompleteCallBack then
        CompleteCallBack()
    end
    EffectIDMap[EntityID] = TargetEffectID 
end

-- 炼金爆炸特效
function CrafterMgr:PlayVfxOnMeshSocket(EntityID, PosKey, EffectPath, FadeInTime, EffectIDMap, CompleteCallBack)
    if not self:IsInCrafterStateFast(EntityID) then
        if CompleteCallBack then
            CompleteCallBack()
        end
        return
    end
    local ActorAvatarCmp = ActorUtil.GetActorAvatarComponent(EntityID)
    if not ActorAvatarCmp then
        return 
    end

    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor or not PosKey then
        return 
    end
    -- 兼容之前的设计, 之前PosKey = 0表示使用Cache的PosKey, -1表示使用主Mesh
    if PosKey == -1 then
        PosKey = AvatarTypeMaster
    end

    local Path = CommonUtil.ParseBPPath(EffectPath)

    -- 清除上次播放的特效
    local TargetEffectID = EffectIDMap[EntityID]
    if TargetEffectID then
        EffectUtil.StopVfx(TargetEffectID,0,0)
    end
    local VfxParameter = _G.UE.FVfxParameter()
    
    VfxParameter.VfxRequireData.EffectPath = Path
    VfxParameter.PlaySourceType = CrafterPlaySourceType
    local Tranform = Actor:GetTransform()

    local MeshComp = ActorAvatarCmp:GetMeshComponentByPosKey(PosKey)
    if MeshComp then
        Tranform = MeshComp:GetSocketTransform("Weapon_M")
    end

    VfxParameter.VfxRequireData.VfxTransform = Tranform
    -- VfxParameter:SetCaster(Actor, ElementID, AttachPointType_AvatarPartType, PosKey)
    if CompleteCallBack then
        VfxParameter.OnVfxEnd = CommonUtil.GetDelegatePair(CompleteCallBack, true)
    end
    TargetEffectID = EffectUtil.PlayVfx(VfxParameter, FadeInTime)
    EffectIDMap[EntityID] = TargetEffectID 
end



--------------- 第三方玩家显隐相关 ---------------
local EHideReason = _G.UE.EHideReason
local EventID = _G.EventID

function CrafterMgr:SetShouldHideOtherPlayer(bShouldHideOtherPlayer, _)
    if type(bShouldHideOtherPlayer) == "number" then
        bShouldHideOtherPlayer = bShouldHideOtherPlayer == 1 and true or false
    end

    if self.bShouldHideOtherPlayer == bShouldHideOtherPlayer then
        return
    end

    self.bShouldHideOtherPlayer = bShouldHideOtherPlayer
    if not self.IsMaking then
        return
    end

    if bShouldHideOtherPlayer then
        self:HideOtherPlayers()
    else
        self:RestoreHidedPlayers()
    end
end

function CrafterMgr:SetPlayerVisibilityByEntityID(EntityID, bVisible, bRemoveItem)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if Actor ~= nil and Actor:IsValid() then
        self:SetPlayerVisibility(Actor, bVisible, bRemoveItem)
    end
end

local HideReason <const> = EHideReason.Crafting
local function SetVisibilityInternal(Actor, bVisible)
    Actor:SetVisibility(bVisible, EHideReason, true)
end

function CrafterMgr:SetPlayerVisibility(Actor, bVisible, bRemoveItem)
    local EntityID = nil
    local AttrComp = Actor:GetAttributeComponent()
    if AttrComp then 
        EntityID = AttrComp.EntityID 
    end
    if not EntityID then
        return
    end

    local CompanionComp = Actor.CompanionComponent
    local CompanionActor = nil
    if CompanionComp then
        CompanionActor = CompanionComp:GetCompanion()
    end

    local bIsMajorOrTeamMem = MajorUtil.IsMajor(EntityID) or TeamMgr:IsTeamMemberByEntityID(EntityID)
    if not bVisible then
        if not bIsMajorOrTeamMem then
            SetVisibilityInternal(Actor, false)
        end
        if CompanionActor then
            SetVisibilityInternal(CompanionActor, false)
        end
        table.insert(self.HidedPlayerList, EntityID)
    else
        if bRemoveItem then
            if table.remove_item(self.HidedPlayerList, EntityID) == nil then
                return
            end
        end

        if not bIsMajorOrTeamMem then
            SetVisibilityInternal(Actor, true)
        end
        if CompanionActor then
            SetVisibilityInternal(CompanionActor, true)
        end
    end
end

local function GetMemberEntityIDList()
    local MemberRoleIDList = TeamMgr:GetMemberRoleIDList()
    local MemberEntityIDList = {}

    for _, RoleID in pairs(MemberRoleIDList) do
        table.insert(MemberEntityIDList, ActorUtil.GetEntityIDByRoleID(RoleID))
    end

    return MemberEntityIDList
end

function CrafterMgr:HideOtherPlayers()
    local _ <close> = CommonUtil.MakeProfileTag("CrafterMgr:HideOtherPlayers")
    if next(self.HidedPlayerList) then
        self:RestoreHidedPlayers()
    end
    local AllActorList = _G.UE.UActorManager:Get():GetAllActors()
    local ActorCnt = AllActorList:Length()
    for i = 1, ActorCnt do
        local Actor = AllActorList:Get(i)
        if Actor ~= nil and Actor:IsValid() and Actor:IsPlayerOrMajor() then
            self:SetPlayerVisibility(Actor, false)
        end
    end
    self.TeamMemberList = GetMemberEntityIDList()

    -- 注册相关的事件
    if not self.bRegisterHidePlayerEvents then
        self.bRegisterHidePlayerEvents = true
        self:RegisterGameEvent(EventID.PlayerCreate, self.OnPlayerCreate)
        self:RegisterGameEvent(EventID.TeamUpdateMember, self.OnTeamMemberChanged)
    end
end

function CrafterMgr:RestoreHidedPlayers()
    local _ <close> = CommonUtil.MakeProfileTag("CrafterMgr:RestoreHidedPlayers")
    local HidedPlayerList = self.HidedPlayerList
    for _, EntityID in pairs(HidedPlayerList) do
        self:SetPlayerVisibilityByEntityID(EntityID, true)
    end
    self.HidedPlayerList = {}

    -- 反注册相关的事件
    if self.bRegisterHidePlayerEvents then
        self.bRegisterHidePlayerEvents = false
        self:UnRegisterGameEvent(EventID.PlayerCreate, self.OnPlayerCreate)
        self:UnRegisterGameEvent(EventID.TeamUpdateMember, self.OnTeamMemberChanged)
    end
end

function CrafterMgr:OnPlayerCreate(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.IsMajor(EntityID) then
        return
    end

    self:SetPlayerVisibilityByEntityID(EntityID, false)
end

function CrafterMgr:OnTeamMemberChanged()
    local LastTeamMemberList = self.TeamMemberList or {}
    local CurrentTeamMemberList = GetMemberEntityIDList()

    -- 处理新加入小队的成员
    for _, EntityID in pairs(CurrentTeamMemberList) do
        if table.find_item(LastTeamMemberList, EntityID) == nil then
            self:SetPlayerVisibilityByEntityID(EntityID, true, true)
        end
    end

    -- 处理离开小队的成员
    for _, EntityID in pairs(LastTeamMemberList) do
        if table.find_item(CurrentTeamMemberList, EntityID) == nil then
            self:SetPlayerVisibilityByEntityID(EntityID, false)
        end
    end

    self.TeamMemberList = CurrentTeamMemberList
end



--------------- 断线重连相关 ---------------
function CrafterMgr:OnGameEventLoginRes(Params)
    if MajorUtil.IsCrafterProf() then
        if Params.bReconnect then
            self.LoginResParams = Params
            self.bReconnectWaitRsp = true
            
            if self:CheckMakeFinish() then
                FLOG_INFO("CrafterMgr Major CheckMakeFinish OnGameEventLoginRes")
                self:SendStartQuitMakeReq()
            end
            -- local Major = MajorUtil.GetMajor()
            -- -- 断线重连后World会重新加载，主角重新初始化，为了避免生产状态被清掉，如果此时Mesh没处理完，等处理完再执行逻辑
            -- if Major and not Major:IsMeshLoaded() then
            --     FLOG_WARNING("[CrafterMgr] OnGameEventLoginRes, but Major mesh not loaded.")
            --     self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.ReconnectSendQueryReq)
            -- else
            --     self:ReconnectSendQueryReq()
            -- end
        else
            self:QuitMakState()
        end
    end
end

function CrafterMgr:ReconnectStartMakeAndPullInfo()
    local StartMake = self.StartMakeRsp or {}
    StartMake.bIsReconnect = true
    StartMake.CachedReconnectionInfo = self.CachedReconnectionInfo

    self:OnNetMsgStartMake({
        StartMake = StartMake, ObjID = MajorUtil.GetMajorEntityID(), LifeSkillID = 0, SubLifeSkillID = 0 })

    -- 这里要保证, 收到断线重连回包之前, View一定要Show出来
    -- 因为此时, View刚刚被Hide, 根据 WidgetPool.lua中定义的时间, 至少要2分钟后Object才会被回收
    -- 因此, 能够保证本帧CrafterMainPanel和ProfPanel一定会执行到ShowView
    self:PullCrafterInfo()
end

function CrafterMgr:OnGameEventMajorDead()
    if self.IsMaking then
        FLOG_INFO("CrafterMgr OnGameEventMajorDead")
        self:QuitMakState()
    end
end

function CrafterMgr:OnReconnect(bServerInState)
    local Params = self.LoginResParams
    if not Params then
        return
    end
    FLOG_INFO("[CrafterMgr] OnReconnect")
    local bReconnect = Params and Params.bReconnect
    if bReconnect and self.IsMaking then
        -- 断线重连所有View都会Hide, 模拟一次重新StartMake的过程
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        _G.FishMgr:StartMoveAndTurnChange(0, true)
        self:EnterRecipeState(MajorEntityID, self.CurRecipeID)

        -- 说明SkillLogicData中的数据未更新
        if MainPanelVM.bControlPanelAttrExist == false then
            self:RegisterGameEvent(EventID.ControlPanelAttrExistChange, self.OnControlPanelAttrExistChange)
        else
            self:ReconnectStartMakeAndPullInfo()
        end
    elseif bReconnect and bServerInState and not self.IsMaking then    --重连的时候，本地不在制作状态，而服务器在制作状态
        self:QuitMakState()
        _G.FLOG_INFO("[Warning] Server is in craftering state while IsMaking = false, so sent QuitMake msg.")
    end
end

function CrafterMgr:OnControlPanelAttrExistChange(bExist)
    if bExist then
        self:UnRegisterGameEvent(EventID.ControlPanelAttrExistChange, self.OnControlPanelAttrExistChange)
        self:ReconnectStartMakeAndPullInfo()
    else
        FLOG_WARNING("[CrafterMgr:OnControlPanelAttrExistChange] bExist = false")
    end
end

-- function CrafterMgr:ReconnectSendQueryReq(Params)
--     if Params then
--         if MajorUtil.IsMajor(Params.ULongParam1) then
--             self:UnRegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.ReconnectSendQueryReq)
--         else
--             return
--         end
--     end

--     if self.IsMaking then
--         self.bReconnectWaitRsp = true
--         self:SendCommStatQueryReq()
--     end
-- end

function CrafterMgr:PullCrafterInfo()
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_CRAFTER_GET
    local MsgBody = { Cmd = SubMsgID }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CrafterMgr:OnNetMsgCrafterGet(MsgBody)
    local CrafterGet = MsgBody.CrafterGet
    if nil == CrafterGet then
        return
    end

    -- 处理制作力的变化
    -- self:SendMkChangeEvent(CrafterGet.MK)
    local AttrComp = MajorUtil.GetMajorAttributeComponent()
    if AttrComp then
        AttrComp:SetAttrValueByName(attr_mk, CrafterGet.MK, true)
    end

    -- 各个职业特定的处理(如果有的话)
    local ProfMainPanelView = _G.UIViewMgr:FindVisibleView(ProfConfig[self.ProfID].MainPanelID)
    if ProfMainPanelView and ProfMainPanelView.OnCrafterReconnectionRsp then
        ProfMainPanelView:OnCrafterReconnectionRsp(CrafterGet)
    end

    -- 模拟一次CrafterSkill回包
    local SkillMsgBody = {
        ObjID = MajorUtil.GetMajorEntityID(),
        LifeSkillID = 0,
        SubLifeSkillID = 0,
        CrafterSkill = {
            Success = true,
            Features = CrafterGet.Features,
            EventIDs = {},  -- for 炼金, 给个空通过if判断
            Culinary = CrafterGet.GetCulinary,
            Weaver = CrafterGet.Weaver,
        },
        bReconnectRsp = true,
    }
    _G.EventMgr:SendEvent(EventID.CrafterSkillRsp, SkillMsgBody)

     -- 处理工次, 因为模拟CrafterSkill回包会扣工次, 需要在它后面
     local SkillCDMap = CrafterGet.SkillCD
     if SkillCDMap then
         _G.CrafterSkillCheckMgr:OnReconnect(SkillCDMap)
     end
end

function CrafterMgr:OnRelayConnected(Params)
    -- 闪断/断线后, 各个角色会重新进入生产状态, 首先把生产相关残余的Vfx清理掉
    -- 闪断主角不会重拉视野, 所以闪断时排除主角
    self:StopAllVfx(Params.bRelay)

    if Params.bRelay then
        FLOG_INFO("CrafterMgr OnRelayConnected bRelay is true, IsMaking is %s", self.IsMaking and "true" or "false")
        if self.IsMaking and self.CurRecipeID and self.CurRecipeID ~= 0 then
            --简易制作如果断了，重新发起，点了关闭会退出
            if self.CurState == CraferStatus.Simple and CrafterMgr.CrafterResultRsp == nil then
                _G.CraftingLogSimpleCraftWinVM:OnSimpleMakeOver()   
            end
        end
    end
end

--别的玩家离开了
function CrafterMgr:OnEventActorLeaveVision(Params)
    local EntityID = Params.ULongParam1

    local TargetEffectID = self.TargetEffectIDMap[EntityID]
    if TargetEffectID then
        self:ClearVfx(EntityID)
        self.TargetEffectIDMap[EntityID] = nil
        -- FLOG_INFO("Crafter BreakEffect %d", TargetEffectID)
    end
end

-- 闪断重连会重新创建主角清掉动画状态, 恢复下
function CrafterMgr:OnRelayConnectedMajorCreate()
    local RecipeID = self.CurRecipeID
    if not self.IsMaking or not RecipeID or RecipeID == 0 then
        return
    end

    local EntityID = MajorUtil.GetMajorEntityID()
    local AnimID, TargetEffectPosKey = self:GetRecipeToolAnimID(EntityID, RecipeID)
    if not AnimID then
        return
    end

    -- _G.FishMgr:StartMoveAndTurnChange(0, true, true)
    self:PlayVfxOnCrafterWeapon(EntityID, 0, TargetEffectPosKey, TargetEffectPath, 0, self.TargetEffectIDMap)
    AnimMgr:PlayEnterAnim(EntityID, AnimID)
end

function CrafterMgr:OnPWorldExit()

    if self.IsMaking then
        self:Reset()
        local Major = MajorUtil.GetMajor()
        if Major then
            Major:ClearCrafterWeaponState(false)
        end
    end
end

-- 裁衣部分状态下某些技能不消耗耐久，在此判断
function CrafterMgr:CheckWeaverSkillCost(SkillID)
    local ProfID = self.ProfID
    if ProfID == ProtoCommon.prof_type.PROF_TYPE_WEAVER or ProfID == ProtoCommon.prof_type.PROF_TYPE_LEATHER_WORK then
        local CrafterSkillRsp = self.LastCrafterSkillRsp
        local ActionType = SkillMainCfg:FindValue(SkillID, "ActionType") or 0
        if CrafterSkillRsp and CrafterSkillRsp.Weaver then
            -- 由于裁衣每次制作推进的步长不固定，目前裁衣球的序列是从上次序列的第一个位置开始发
            local Weaver = CrafterSkillRsp.Weaver
            local Step = Weaver.Index - Weaver.PreIndex
            if Step < 0 then
                -- 存在重置序列的情况，此处Step会小于0，因此特殊处理
                Step = 0
            end
            local State = Weaver.Balls[1 + Step]
            -- 黄球免耐久消耗
            if State and State == CircleStateIndex.Yellow and ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FREECOST_YELLOW then
                return true
            end
            -- 红黄球免耐久消耗
            if State and (State == CircleStateIndex.Yellow or State == CircleStateIndex.Red) and ActionType == LifeSkillActionType.LIFESKILL_ACTION_TYPE_FREECOST_BOTH then
                return true
            end
        end
    end
    return false
end

local StopVfx = EffectUtil.StopVfx
local function StopVfxInMap(Map, ExcludedEntityID)
    if not Map then
        return
    end
    for EntityID, EffectID in pairs(Map) do
        if ExcludedEntityID ~= EntityID then
            StopVfx(EffectID, 0, 0)
        end
    end
end

function CrafterMgr:StopAllVfx(bExcludeMajor)
    local ExcludedEntityID = bExcludeMajor and MajorUtil.GetMajorEntityID() or nil
    StopVfxInMap(self.TargetEffectIDMap, ExcludedEntityID)
    StopVfxInMap(self.SkillEffectIDMap, ExcludedEntityID)
    StopVfxInMap(self.RandomEventEffectIDMap, ExcludedEntityID)
end

function CrafterMgr:IsInTrain()
    return self.CurState == CraferStatus.Train
end

function CrafterMgr:CheckMakeFinish()
    if self.CurState ~= CraferStatus.Simple then
        local Durability = self:GetFeatureValue(ProtoCS.FeatureType.FEATURE_TYPE_DURABILITY)
        local Progress = self:GetFeatureValue(ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS)
        if Durability <= 0 or Progress >= self:GetCurTargetMaxProgress() then
            return true
        end
    end

    return false
end

--只有简易制作才有获取奖励的发包
function CrafterMgr:OnSkillGameEventGetReward(bForce)
    if MajorUtil.IsCrafterProf() and (self.CurState == CraferStatus.Simple or bForce) then
        FLOG_INFO("CrafterMgr SkillGameEvent to get skill reward  bSendRightAwayReq(%s)"
            , tostring(self.bSendRightAwayReq))

        if self.bSendRightAwayReq then
            self.bSendRightAwayReq = false
        end

        local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
        local SubMsgID = 31--CS_SUB_CMD.LIFE_SKILL_CRAFTER_SIMPLE_SKILL_END

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID

        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

function CrafterMgr:IsInCrafterStateFast(EntityID)
    return AnimMgr.CachedCrafterStateMap[EntityID] ~= nil
end

return CrafterMgr