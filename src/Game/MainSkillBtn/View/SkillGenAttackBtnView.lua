---
--- Author: chaooren
--- DateTime: 2022-03-22 17:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local SkillButtonStateMgr = require("Game/Skill/SkillButtonStateMgr")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local UIViewID = require("Define/UIViewID")
local AudioUtil = require("Utils/AudioUtil")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local CrafterConfig = require("Define/CrafterConfig")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillBtnState = SkillButtonStateMgr.SkillBtnState
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local ProfConfig = CrafterConfig.ProfConfig
---@class SkillGenAttackBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Attack UFButton
---@field Img_ProfSign UImage
---@field AnimClick UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillGenAttackBtnView = LuaClass(UIView, true)

function SkillGenAttackBtnView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn_Attack = nil
    --self.Img_ProfSign = nil
    --self.AnimClick = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillGenAttackBtnView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillGenAttackBtnView:OnInit()
    self.ButtonIndex = 0
    self.LongPressTimer = 0
    self.RestorePressTimer = 0
    self.CanPress = true    --脱战后0.5s内不可按下
end

function SkillGenAttackBtnView:OnDestroy()
end

function SkillGenAttackBtnView:OnEntityIDUpdate(EntityID, bMajor)
    self.EntityID = EntityID
    self.bMajor = bMajor
end

function SkillGenAttackBtnView:OnShow()
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
    if LogicData == nil then
        --这里直接返回，避免卡loading
        FLOG_WARNING("[AttackBtn] LogicData is nil, EntityID: " .. tostring(self.EntityID or 0))
        return
    end
    local SkillID = LogicData:GetBtnSkillID(self.ButtonIndex)
    self.BtnSkillID = 0 --相同SkillID的技能不会执行替换流程，因此这里将BtnSkillID设为0以确保替换流程顺利执行
    self.CanPress = true
    self:OnSkillReplace({SkillIndex = self.ButtonIndex, SkillID = SkillID})
end

function SkillGenAttackBtnView:OnHide()
    _G.UIAsyncTaskMgr:UnRegisterTask(self.GameEventMajorUseSkillTaskID)
    _G.UIAsyncTaskMgr:UnRegisterTask(self.GameEventSkillReplaceTaskID)
    self:EndLongPressTimer()
end

function SkillGenAttackBtnView:OnRegisterUIEvent()
    UIUtil.AddOnReleasedEvent(self, self.Btn_Attack, self.OnReleasedButtonSkill, 0)
    UIUtil.AddOnPressedEvent(self, self.Btn_Attack, self.OnPressedButtonSkill, 0)

    SkillUtil.RegisterPressScaleEvent(self, self.Btn_Attack, SkillCommonDefine.SkillBtnClickFeedback)

    --长按输入只希望主角用，技能系统没预输入和权重不能用
    UIUtil.AddOnLongClickedEvent(self, self.Btn_Attack, self.OnLongClickedEvent)
    UIUtil.AddOnLongClickReleasedEvent(self, self.Btn_Attack, self.OnLongClickReleasedEvent)
end

function SkillGenAttackBtnView:OnRegisterGameEvent()
    if self.bMajor then
        self:RegisterGameEvent(EventID.InputActionSkillPressed, self.OnPressedButtonSkill)
        self:RegisterGameEvent(EventID.InputActionSkillReleased, self.OnReleasedButtonSkill)
        self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldMapEnter)
        self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
		self:RegisterGameEvent(EventID.MajorSkillCastFailed, self.OnSkillCastFailed)
        self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)

        local IsInField = _G.PWorldMgr:CurrIsInField()
	    --仅野外支持
        if IsInField then
            self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
        end

        self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
        self:OnEventMajorProfSwitch()   --处理MajorUseSkill事件

        self:RegisterGameEvent(EventID.SimulateMajorSkillCast, self.OnSimulateMajorSkillCast)
    end
end

function SkillGenAttackBtnView:OnRegisterBinder()
end

function SkillGenAttackBtnView:OnPWorldMapEnter(_)
	--切换副本后，如果界面仍显示，则手动执行一次OnShow里的逻辑
	self:OnShow()
end

function SkillGenAttackBtnView:OnEventMajorProfSwitch()
    self:UnRegisterGameEvent(EventID.MajorUseSkill, self.OnGameEventMajorUseSkill)

    if not MajorUtil.IsCrafterProf() then
        self:RegisterGameEvent(EventID.MajorUseSkill, self.OnGameEventMajorUseSkill)
    else
        -- self:UnRegisterGameEvent(EventID.MajorUseSkill, self.OnGameEventMajorUseSkill)
    end
end

--脱战1s内不能使用普攻
local YanruConfigTime = 1
function SkillGenAttackBtnView:OnNetStateUpdate(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    local StateType = Params.IntParam1
    if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
        return
    end
    if Params.BoolParam1 == false then
        self:EndLongPressTimer()
        self.CanPress = false

        if self.RestorePressTimer > 0 then
            self:UnRegisterTimer(self.RestorePressTimer)
        end

        --脱战1s内不能使用普攻
        self.RestorePressTimer = self:RegisterTimer(self.RestorePress, YanruConfigTime, 0, 1)
    end
end

function SkillGenAttackBtnView:RestorePress()
    self.CanPress = true
end

function SkillGenAttackBtnView:OnSimulateMajorSkillCast(Index)
    if Index == self.ButtonIndex then
        self:OnPrepareCastSkill()
        self:OnCastSkill()
    end
end

function SkillGenAttackBtnView:LongPressStart()
    self:OnPrepareCastSkill()
    self:OnCastSkill()
end

function SkillGenAttackBtnView:OnLongClickedEvent()
    if self.bMajor == false then
        return
    end

    local SkillType = SkillMainCfg:FindValue(self.BtnSkillID, "SkillFirstClass")
    --生活技能没有长按逻辑
    if SkillType ~= ProtoRes.skill_first_class.LIFE_SKILL and SkillType ~= ProtoRes.skill_first_class.PRODUCTION_SKILL then
        self:StartLongPressTimer()
    end
end

function SkillGenAttackBtnView:OnGameEventUnSelectTarget(Params)
    self:EndLongPressTimer()
end

function SkillGenAttackBtnView:OnSkillCastFailed(Index)
	if Index == 0 then
        self:EndLongPressTimer()
	end
end

function SkillGenAttackBtnView:StartLongPressTimer()
    if not self.LongPressTimer or self.LongPressTimer == 0 then
        self.LongPressTimer = self:RegisterTimer(self.LongPressStart, 0, 0.5, 0)
    end
end

function SkillGenAttackBtnView:EndLongPressTimer()
    if self.LongPressTimer > 0 then
        self:UnRegisterTimer(self.LongPressTimer)
        self.LongPressTimer = 0
    end
end

function SkillGenAttackBtnView:OnLongClickReleasedEvent()
    if self.bMajor == false then
        return
    end

    self:EndLongPressTimer()
end

function SkillGenAttackBtnView:OnPressedButtonSkill(Params)
    if Params ~= 0 then
        return
    end
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
    if LogicData == nil then
        return
    end
    if not self.bMajor then
        local SkillSystemMgr = _G.SkillSystemMgr
        if SkillSystemMgr.PressedButtonIndex ~= nil then
            return
        end
        SkillSystemMgr.PressedButtonIndex = 0
    end
    LogicData:SetSkillPressFlag(self.ButtonIndex, true)
    self.PressSkill = self.BtnSkillID
    self:OnPrepareCastSkill()
end

function SkillGenAttackBtnView:OnPrepareCastSkill()
    if self.bMajor then
        --要不要调主角的PrepareCast
    else
        SkillUtil.PlayerPrepareCastSkill(self.EntityID, 0, self.BtnSkillID)
    end
end

function SkillGenAttackBtnView:OnReleasedButtonSkill(Params)
    
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
    if Params ~= 0 or LogicData == nil then
        return
    end

    _G.EventMgr:SendEvent(EventID.SkillGenAttack)

    if not self.bMajor then
        local SkillSystemMgr = _G.SkillSystemMgr
		if SkillSystemMgr.PressedButtonIndex ~= 0 then
			return
		end
		SkillSystemMgr.PressedButtonIndex = nil
	end
    LogicData:SetSkillPressFlag(self.ButtonIndex, false)
    if self.LongPressTimer > 0 then
        --处于长点击状态的技能不走正常的技能释放流程
        return
    end
    if self.PressSkill ~= self.BtnSkillID then
        return
    end
    self:OnCastSkill()
end

function SkillGenAttackBtnView:OnCastSkill()
    _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, true,MajorUtil.IsCrafterProf())
    if not self.CanPress then
        _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, false) -- 临时代码，没有打开，但是前面发送了打开消息，这里发送一下关闭消息
        return
    end
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
    if LogicData == nil then
        _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, false) -- 临时代码，没有打开，但是前面发送了打开消息，这里发送一下关闭消息
        return
    end
    local bMajor = self.bMajor
    if bMajor and not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_USE_SKILL, true) then
        _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, false) -- 临时代码，没有打开，但是前面发送了打开消息，这里发送一下关闭消息
        return
    end

    if _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith() then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CannotFightSkillPanel)
        _G.EventMgr:SendEvent(EventID.FightSkillPanelShowed, false) -- 临时代码，没有打开，但是前面发送了打开消息，这里发送一下关闭消息
        return 
    end

    if bMajor and MajorUtil.IsCrafterProf() then
        local IsAutoPathMovingState = _G.AutoPathMoveMgr:IsAutoPathMovingState()
        if IsAutoPathMovingState then
            _G.AutoPathMoveMgr:StopAutoPathMoving()
        end 
        AudioUtil.LoadAndPlayUISound(GatheringLogDefine.SkillAttackBtnSoundPath)
        _G.UIViewMgr:ShowView(UIViewID.CraftingLog)
        return
    end

    if bMajor then
        local IsGatherProf = MajorUtil.IsGatherProf()
        if IsGatherProf then
            AudioUtil.LoadAndPlayUISound(GatheringLogDefine.SkillAttackBtnSoundPath)
            if _G.MainPanelVM.IsFightState then
                _G.UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
                return
            end
        end

        local EventParams = {BtnIndex = self.ButtonIndex, SkillID = self.BtnSkillID, UIState = false}
        _G.EventMgr:SendEvent(EventID.SkillBtnClick, EventParams)
        if EventParams.UIState == false then
            --制作职业直接打开 炼金的制作界面(目前是临时处理，将来要打开制作手册的)
            if MajorUtil.IsCrafterProf() then
                _G.CrafterMgr:StartMake(nil, false)
            end

            return
        end

        if IsGatherProf and not _G.GatherMgr.IsGathering then
            return
        end

        local SkillType =
            SkillMainCfg:FindValue(self.BtnSkillID, "SkillFirstClass") == ProtoRes.skill_first_class.LIFE_SKILL

        if not LogicData:CanCastSkill(0, true, SkillBtnState.SkillWeight) then
            if SkillType == true then
            --MsgTipsUtil.ShowTips(LSTR("条件不满足"))
            end

            return
        end

        if _G.SkillStorageMgr:GetSkillID() > 0 then
            return
        end

        if SkillType == true then
            SkillUtil.CastLifeSkill(self.ButtonIndex, self.BtnSkillID)
            return
        end
        
        if _G.SkillLogicMgr.bAutoGenSkillAttack then
            FLOG_INFO("Enter AutoGenAttack")
            self:StartLongPressTimer()
        end

        SkillUtil.CastSkill(self.EntityID, 0, self.BtnSkillID)
    else
        local bJoyStick = SkillMainCfg:FindValue(self.BtnSkillID, "IsEnableSkillJoyStick")
        SkillUtil.PlayerCastSkill(self.EntityID, 0, self.BtnSkillID, bJoyStick)
    end
end

function SkillGenAttackBtnView:OnGameEventMajorUseSkill(Params)
    local BtnIndex = Params.ULongParam1
    if BtnIndex ~= self.ButtonIndex or self.BtnSkillID == nil then
        return false
    end

    local co = coroutine.create(self.OnGameEventMajorUseSkillAsync)
    self.GameEventMajorUseSkillTaskID = _G.UIAsyncTaskMgr:RegisterTask(co, self)
end

function SkillGenAttackBtnView:OnGameEventMajorUseSkillAsync()
    if not MajorUtil.IsGatherProf() then
        self:PlayAnimation(self.AnimClick)
    end
end

function SkillGenAttackBtnView:OnPlayerUseSkill(Params)
    if not MajorUtil.IsGatherProf() then
        self:PlayAnimation(self.AnimClick)
    end
    
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
    LogicData:SkillMoveNext(Params.SkillID, Params.Index)
end

function SkillGenAttackBtnView:OnSkillReplace(Params)
    if Params.SkillIndex ~= 0 then
        return
    end

    local TargetSkillID = Params.SkillID
    -- if TargetSkillID == self.BtnSkillID then
    -- 	return
    -- end
    self.BtnSkillID = TargetSkillID
    local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
    if LogicData == nil then
        return
    end
    LogicData:RefreshAllAffectedFlag(Params.SkillIndex, Params.SkillID)
    LogicData:UpdateAllStateList(Params.SkillIndex, Params.SkillID)

    _G.UIAsyncTaskMgr:UnRegisterTask(self.GameEventSkillReplaceTaskID)

    local co = coroutine.create(self.OnSkillReplaceAsync)
    self.GameEventSkillReplaceTaskID = _G.UIAsyncTaskMgr:RegisterTask(co, self)
end

function SkillGenAttackBtnView:OnSkillReplaceAsync()
    if self.bMajor and (MajorUtil.IsCrafterProf() or (MajorUtil.IsGatherProf() and _G.GatherMgr.IsRealGathering)) then
        local ProfID = MajorUtil.GetMajorProfID()
        local Config = ProfConfig[ProfID]
        if Config then
            local Path = UIUtil.GetCommonIconPath(Config.EntranceIconID)
            -- FLOG_INFO("Crafter Entrance:%s", Path)
            UIUtil.ImageSetBrushFromAssetPath(self.Img_ProfSign, Path, true)
            UIUtil.SetIsVisible(self.Img_ProfSign, true)
        end
    else
        SkillUtil.ChangeSkillIcon(self.BtnSkillID, self.Img_ProfSign)
    end

    self.GameEventSkillReplaceTaskID = nil
end

return SkillGenAttackBtnView
