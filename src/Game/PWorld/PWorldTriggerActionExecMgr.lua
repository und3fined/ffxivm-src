--
-- Author: haialexzhou
-- Date: 2021-4-27
-- Description:副本触发行为执行管理
--

local ProtoRes = require ("Protocol/ProtoRes")
local MapDyneffectCfg = require("TableCfg/MapDyneffectCfg")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIViewConfig = require("Define/UIViewConfig")
local ActorUtil = require("Utils/ActorUtil")
local UIUtil = require("Utils/UIUtil")
local LineVoiceCfg = require("TableCfg/LineVoiceCfg")
local AudioUtil = require("Utils/AudioUtil")
local UILayer = require("UI/UILayer")

local PWorldTriggerActionExecMgr = {}
local ContentSgMgr = _G.UE.UContentSgMgr
local ShowUITimer = nil
local ViewList = {}

local function GetActionStrParamValue(StrParamList, Index)
    if (#StrParamList >= Index) then
        local StrParamList1 = string.split(StrParamList[Index], '=')
        if (#StrParamList1 == 2) then
            local Value = StrParamList1[2]
            local IntValue = tonumber(Value)
            if (IntValue == nil) then
                return Value
            else
                return IntValue
            end
        end
    end
    return 0
end

--显示或者隐藏UI
local function OnShowUIAction(ActionParams)
    --FLOG_WARNING("OnShowUIAction ActionParams.StrParam=%s",ActionParams.StrParam)

    --过场动画执行中，不执行其他显示或者隐藏UI逻辑
    if  _G.StoryMgr:SequenceIsPlaying() then
		return
	end

    local SpecifyUI = false
    local StrParamList = {}
    if (ActionParams.StrParam ~= nil and ActionParams.StrParam ~= "") then
        if(string.find(ActionParams.StrParam, ',')) then
            StrParamList = string.split(ActionParams.StrParam, ',')
        else
            table.insert(StrParamList, ActionParams.StrParam)
        end
        SpecifyUI = true
    end

    local bShowView = ActionParams.Param2 == 1
    local bIncludeJoyStick = ActionParams.ParamBool

    if (SpecifyUI) then
        --FLOG_WARNING("OnShowUIAction SpecifyUI")
        ViewList = {}
        for _, ParamName in ipairs(StrParamList) do
            local ViewName = ParamName
            if(string.find(ParamName, '/')) then
                local firstPart = nil
                local ViewParts = {}
                for part in string.gmatch(ParamName, "([^/]+)") do
                    -- 修剪字符串两端的空白字符
                    local part = string.match(part, "^%s*(.-)%s*$")
                    if not firstPart then
                        firstPart = part
                    else
                        table.insert(ViewParts, part)
                    end
                end

                for k, v in pairs(UIViewConfig) do
                    local lastSlashIndex = v.BPName:find("/[^/]*$")
                    local lastName= v.BPName:sub(lastSlashIndex + 1)

                    if lastName == firstPart then
                        ViewList[k] = ViewParts
                        if(bShowView) then
                            --FLOG_WARNING("OnShowUIAction bShowView k=%s",k)
                            _G.UIViewMgr:ShowView(k)
                        else
                            local FindView = _G.UIViewMgr:FindView(k)
                            if(FindView ~= nil) then
                                for i, value in ipairs(ViewParts) do
                                    
                                    local foundWidget = FindView:GetWidgetFromName(value)
                                    if foundWidget ~= nil then
                                        --FLOG_WARNING("OnShowUIAction SetIsVisible foundWidget1111111=%s,value=%s",foundWidget,value)
                                        UIUtil.SetIsVisible(foundWidget, false)
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            else
                for k, v in pairs(UIViewConfig) do
                    local lastSlashIndex = v.BPName:find("/[^/]*$")
                    local lastName= v.BPName:sub(lastSlashIndex + 1)
                     if lastName == ViewName then
                        ViewList[k] = ""
                        if(bShowView) then
                            _G.UIViewMgr:ShowView(k)
                        else
                            _G.UIViewMgr:HideView(k)  
                        end
                        break
                    end
                end
            end
        end
        if(bIncludeJoyStick) then
            CommonUtil.DisableShowJoyStick(false)
            if(bShowView) then 
                CommonUtil.ShowJoyStick()
                CommonUtil.DisableShowJoyStick(true)
            else
                CommonUtil.HideJoyStick()
                CommonUtil.DisableShowJoyStick(true)
            end
        end
        if(ActionParams.Param3 > 0) then
            if ShowUITimer ~= nil then
                _G.TimerMgr:CancelTimer(ShowUITimer)
                ShowUITimer = nil
            end
            local function ShowSpecifyUIFinish(Params)
                if(Params.bIncludeJoyStick) then
                    if(Params.bShowView) then
                        CommonUtil.DisableShowJoyStick(false) 
                        CommonUtil.HideJoyStick()
                    else
                        CommonUtil.DisableShowJoyStick(false)
                        CommonUtil.ShowJoyStick()
                    end
                end
                for Key, UIView in pairs(Params.ViewList) do
                    if(Params.bShowView) then
                        --FLOG_WARNING("OnShowUIAction bShowView Key=%s",Key)
                        _G.UIViewMgr:HideView(Key)
                    else
                        local View = _G.UIViewMgr:FindView(Key)

                        if(View == nil) then
                            _G.UIViewMgr:ShowView(Key)
                            --FLOG_WARNING("OnShowUIAction not bShowView Key=%s",Key)
                            View = _G.UIViewMgr:FindView(Key)
                        end
                        if(UIView ~= "" and View ~= nil) then
                            for _, value in pairs(UIView) do
                                local foundWidget = View:GetWidgetFromName(value)
                                if foundWidget ~= nil then
                                    UIUtil.SetIsVisible(foundWidget, true)
                                    --FLOG_WARNING("OnShowUIAction SetIsVisible foundWidget=%s,value=%s",foundWidget,value)
                                end
                            end
                        else
                            _G.UIViewMgr:ShowView(Key)
                        end
                    end
                end
            end
            ShowUITimer = _G.TimerMgr:AddTimer(nil, ShowSpecifyUIFinish, ActionParams.Param3,1,1,{ViewList = ViewList, bShowView = bShowView,bIncludeJoyStick = bIncludeJoyStick})
        end
    else
        if (bShowView) then
            _G.UIViewMgr:ShowAllLayer()
            if(bIncludeJoyStick) then
                CommonUtil.ShowJoyStick()
                CommonUtil.DisableShowJoyStick(true)
            end
            
            if(ActionParams.Param3 > 0) then
                if ShowUITimer ~= nil then
                    _G.TimerMgr:CancelTimer(ShowUITimer)
                    ShowUITimer = nil
                end
                local function ShowUIFinish(bIncludeJoyStick)
                    _G.UIViewMgr:HideAllLayer()
                    if(bIncludeJoyStick) then
                        CommonUtil.DisableShowJoyStick(false)
                        CommonUtil.HideJoyStick()
                    end
                end
                ShowUITimer = _G.TimerMgr:AddTimer(nil, ShowUIFinish, ActionParams.Param3,1,1,bIncludeJoyStick)
            else
                FLOG_WARNING("OnShowUIAction ShowAllLayer No Timelimit!")
            end
        else
            --_G.UIViewMgr:HideAllLayer()
            _G.UIViewMgr:UpdateLayerBit(UILayer.Tips)
            if(bIncludeJoyStick) then
                CommonUtil.HideJoyStick()
                CommonUtil.DisableShowJoyStick(true)
            end

            if(ActionParams.Param3 > 0) then
                if ShowUITimer ~= nil then
                    _G.TimerMgr:CancelTimer(ShowUITimer)
                    ShowUITimer = nil
                end
                local function HideUIFinish(bIncludeJoyStick)
                     _G.UIViewMgr:ShowAllLayer()
                     if(bIncludeJoyStick) then
                        CommonUtil.DisableShowJoyStick(false)
                        CommonUtil.ShowJoyStick()
                    end
                end
                ShowUITimer = _G.TimerMgr:AddTimer(nil, HideUIFinish, ActionParams.Param3,1,1,bIncludeJoyStick)
            else
                FLOG_WARNING("OnShowUIAction HideAllLayer No Timelimit!")
            end
        end
    end
end

--显示或者隐藏玩家
local function OnShowActorAction(ActionParams)
    local bIsHide = ActionParams.Param1 == 0
    local UActorManager = _G.UE.UActorManager:Get()
    UActorManager:HideAllPlayer(bIsHide);
    UActorManager:HideMajor(bIsHide)

    local IsVisible = ActionParams.Param2 > 0
    _G.HUDMgr:SetPlayerInfoVisible(IsVisible)
end

--播放摄像机特效
local function OnPlayCameraEffectAction(ActionParams)
    if (ActionParams.ParamBool) then
        local ColorR = ActionParams.Param1
        local ColorG = ActionParams.Param2
        local ColorB = ActionParams.Param3
        local TargetColor = _G.UE.FColor(ColorR,ColorG,ColorB)
        local Duration = ActionParams.Param4
        local ExistDuration = ActionParams.Param5
        local TotalDuration = Duration + ActionParams.Param6
        local ResetCamera = ActionParams.Param8

        if(ResetCamera == ProtoRes.action_change_state_type.ACTION_CHANGE_STATE_TYPE_OPEN) then
            local Major = MajorUtil.GetMajor()
            if (Major ~= nil) then
                Major:GetCameraControllComponent():ResetSpringArmToDefault()
            end
        end

        local UCameraPostEffectMgr = _G.UE.UCameraPostEffectMgr.Get()
        if (UCameraPostEffectMgr ~= nil) then
            UCameraPostEffectMgr:SetCameraColorFadeWithExit(TargetColor, Duration, ExistDuration, TotalDuration)
        end
    else
        if (ActionParams.Param1 <= 0) then
            return
        end
        local EffectCfg = MapDyneffectCfg:FindCfgByKey(ActionParams.Param1)
        if (not EffectCfg.EffectPath) then
            return
        end
    
        local PosX = ActionParams.Param2
        local PosY = ActionParams.Param3
        local PosZ = ActionParams.Param4
        local RotatorX = ActionParams.Param5
        local RotatorY = ActionParams.Param6
        local RotatorZ = ActionParams.Param7
        local PosVector = _G.UE.FVector(PosX, PosY, PosZ)
        local Rotator = _G.UE.FRotator(RotatorX, RotatorY, RotatorZ)
        local ResetCamera = ActionParams.Param8

        if(ResetCamera == ProtoRes.action_change_state_type.ACTION_CHANGE_STATE_TYPE_OPEN) then
            local Major = MajorUtil.GetMajor()
            if (Major ~= nil) then
                Major:GetCameraControllComponent():ResetSpringArmToDefault()
            end
        end

        local UCameraMgr = _G.UE.UCameraMgr.Get()
        if (UCameraMgr ~= nil) then
            UCameraMgr:PlayCameraEffect(EffectCfg.EffectPath, PosVector, Rotator)
        end
    end

end

--副本回档
local function OnPWorldSnapshot(ActionParams)
    --print("OnPWorldAceAction ResetSpringArmByParam!!!!!!!!!!!!!!!!!!!!!!!!!!! ActionParams.Param1=" .. ActionParams.Param1)
    if (ActionParams.Param1 == 1) then
        local Major = MajorUtil.GetMajor()
        if (Major ~= nil) then
            local CameraParams = _G.UE.FCameraResetParam()
            CameraParams.ResetType = _G.UE.ECameraResetType.Interp
            Major:GetCameraControllComponent():ResetSpringArmByParam(_G.UE.ECameraResetLocation.Default, CameraParams)
        end

        --reset ui
        _G.UIViewMgr:ShowAllLayer()
        _G.HUDMgr:SetPlayerInfoVisible(true)
    end
end

--动态物件状态变化
local function OnSgVisibilityStateChange(ActionParams)
    -- FLOG_WARNING(ActionParams.Param1)
    -- FLOG_WARNING(ActionParams.Param2)
    -- FLOG_WARNING(ActionParams.Param4)

    --FLOG_WARNING("OnSgVisibilityStateChange ActionParams.Param1=%d, ActionParams.Param2=%d, ActionParams.Param4=%d", ActionParams.Param1,ActionParams.Param2, ActionParams.Param4)
    --参数1为2是动态物件显隐变化
    if (ActionParams.Param1 ~= 2) then
        return
    end

    local SgEditorID = ActionParams.Param2
    local Visibility = ActionParams.Param4

    if SgEditorID > 0 and (Visibility == ProtoRes.action_ui_operate_type.ACTION_UI_OPERATE_TYPE_SHOW or Visibility == ProtoRes.action_ui_operate_type.ACTION_UI_OPERATE_TYPE_HIDE) then
        local ContentSgMgrInstance = ContentSgMgr:Get()

        if Visibility == ProtoRes.action_ui_operate_type.ACTION_UI_OPERATE_TYPE_SHOW then
            Visibility = true
        else
            Visibility = false
        end

        if ContentSgMgrInstance ~= nil then
            ContentSgMgrInstance:ChangeSgVisibilityFromLua(SgEditorID,Visibility)
        end
    end
end

--实体气泡
local function OnPWorldBubble(ActionParams)
    --FLOG_WARNING("OnPWorldBubble ActionParams.Param1=%d, ActionParams.Param7=%d, ActionParams.Param8=%d", ActionParams.Param1,ActionParams.Param7, ActionParams.Param8)

    local BubbleID = 0
    local BubbleGroupID = 0

    if(ActionParams.Param7 == 1) then
        BubbleID = ActionParams.Param8
    else
        BubbleGroupID = ActionParams.Param8
    end

    local function ShowBubble(EntityID,BubbleID,BubbleGroupID)
        if BubbleID > 0 then
            _G.SpeechBubbleMgr:ShowBubbleByID(EntityID,BubbleID)
        else
            _G.SpeechBubbleMgr:ShowBubbleGroup(EntityID,BubbleGroupID)
        end
    end
    
    if (ActionParams.Entities ~= nil and #ActionParams.Entities > 0) then
        for _, EntityID in pairs(ActionParams.Entities) do
            ShowBubble(EntityID,BubbleID,BubbleGroupID)
        end
    elseif ActionParams.TriggerEntityID ~= nil then
        ShowBubble(ActionParams.TriggerEntityID,BubbleID,BubbleGroupID)
    end

    -- 玩家
    -- if ActionParams.Param1 == ProtoRes.trigger_entity_type.TRIGGER_ENTITY_TYPE_PLAYER then
    --     local Major = MajorUtil.GetMajor()
    --     if (Major ~= nil) then
    --         local Profession = ActionParams.Param4
    --         if (Profession > 0 and MajorUtil.GetMajorProfID() == Profession) or Profession == 0 then
    --             EntityID = _G.SpeechBubbleMgr:GetActorEntityIDByActor(Major)
    --         end
    --     end

    --     ShowBubble(EntityID,BubbleID,BubbleGroupID)
    -- -- 怪物
    -- elseif ActionParams.Param1 == ProtoRes.trigger_entity_type.TRIGGER_ENTITY_TYPE_MONSTER then
    --     local CampType = ActionParams.Param2
    --     local Monstertype = ActionParams.Param3 --怪物ID类型
    --     local Monsters = {}

    --     --根据怪物的ListID来找怪，这里LISTID不能为0
    --     if Monstertype == ProtoRes.trigger_monster_type.TRIGGER_MONSTER_TYPE_LIST then
    --         if ActionParams.Param4 > 0 then
    --             local Monster = _G.UE.UActorManager:Get():GetMonsterByListID(ActionParams.Param4)
    --             if Monster ~= nil then
    --                 EntityID = _G.SpeechBubbleMgr:GetActorEntityIDByActor(Monster)
    --             end

    --             ShowBubble(EntityID,BubbleID,BubbleGroupID)
    --         end
    --     --根据怪物的ResID来找怪,ResID不能为0
    --     elseif Monstertype == ProtoRes.trigger_monster_type.TRIGGER_MONSTER_TYPE_ID then
    --         if ActionParams.Param4 > 0 then
    --             if CampType == ProtoRes.trigger_camp_type.TRIGGER_CAMP_TYPE_MONSTER then
    --                 Monsters = _G.UE.UActorManager:Get():GetMonsterByResID(ActionParams.Param4,ProtoRes.camp_relation.camp_relation_enemy)
    --             elseif CampType == ProtoRes.trigger_camp_type.TRIGGER_CAMP_TYPE_NEUTRAL then
    --                 Monsters = _G.UE.UActorManager:Get():GetMonsterByResID(ActionParams.Param4,ProtoRes.camp_relation.camp_relation_neutral)
    --             elseif CampType == ProtoRes.trigger_camp_type.TRIGGER_CAMP_TYPE_PLAYER then
    --                 Monsters = _G.UE.UActorManager:Get():GetMonsterByResID(ActionParams.Param4,ProtoRes.camp_relation.camp_relation_ally)
    --             else
    --                 Monsters = _G.UE.UActorManager:Get():GetMonsterByResID(ActionParams.Param4,ProtoRes.camp_relation.camp_relation_none)
    --             end
    --         end
    --     elseif Monstertype == ProtoRes.trigger_monster_type.TRIGGER_MONSTER_TYPE_IGNORE then
    --         if CampType == ProtoRes.trigger_camp_type.TRIGGER_CAMP_TYPE_MONSTER then
    --             Monsters = _G.UE.UActorManager:Get():GetMonsterByCamp(ProtoRes.camp_relation.camp_relation_enemy)
    --         elseif CampType == ProtoRes.trigger_camp_type.TRIGGER_CAMP_TYPE_NEUTRAL then
    --             Monsters = _G.UE.UActorManager:Get():GetMonsterByCamp(ProtoRes.camp_relation.camp_relation_neutral)
    --         elseif CampType == ProtoRes.trigger_camp_type.TRIGGER_CAMP_TYPE_PLAYER then
    --             Monsters = _G.UE.UActorManager:Get():GetMonsterByCamp(ProtoRes.camp_relation.camp_relation_ally)
    --         else
    --             Monsters = _G.UE.UActorManager:Get():GetMonsterByCamp(ProtoRes.camp_relation.camp_relation_none)
    --         end
    --     end

    --     for _, Monster in pairs(Monsters) do
    --         EntityID = _G.SpeechBubbleMgr:GetActorEntityIDByActor(Monster)
    --         ShowBubble(EntityID,BubbleID,BubbleGroupID)
    --     end
    -- -- NPC
    -- elseif ActionParams.Param1 == ProtoRes.trigger_entity_type.TRIGGER_ENTITY_TYPE_NPC then
    --     local NPCType = ActionParams.Param2
    --     if NPCType == ProtoRes.trigger_npc_type.TRIGGER_NPC_TYPE_IGNORE then
    --     elseif NPCType == ProtoRes.trigger_npc_type.TRIGGER_NPC_TYPE_NPCLIST then
    --         local NPCListID = ActionParams.Param3
    --         if NPCListID > 0 then
    --             local NPC = _G.UE.UActorManager:Get():GetNpcByListID(NPCListID)

    --             if NPC ~= nil then
    --                 EntityID = _G.SpeechBubbleMgr:GetActorEntityIDByActor(NPC)
    --                 FLOG_WARNING("OnPWorldAceAction OnPWorldBubble NpcList EntityID=%d,ResID=%d,ActionParams.Time=%s",EntityID,NPCListID,tostring(TimeUtil.GetServerTime()))
    --                 ShowBubble(EntityID,BubbleID,BubbleGroupID)
    --             end
    --         end
    --     elseif NPCType == ProtoRes.trigger_npc_type.TRIGGER_NPC_TYPE_NPCID then
    --         local NPCResID = ActionParams.Param3
    --         local NPCs = _G.UE.UActorManager:Get():GetNpcByResID(NPCResID)

    --         for _, NPC in pairs(NPCs) do
    --             EntityID = _G.SpeechBubbleMgr:GetActorEntityIDByActor(NPC)
    --             FLOG_WARNING("OnPWorldAceAction OnPWorldBubble Npc EntityID=%d,ResID=%d,ActionParams.Time=%s",EntityID,NPCResID,tostring(TimeUtil.GetServerTime()))
    --             ShowBubble(EntityID,BubbleID,BubbleGroupID)
    --         end
    --     end
    -- end
end

local function ExecFadeAction(JsonReader)
    if JsonReader ~= nil and JsonReader.ClassName == "FadeAction" then
        local TargetType = JsonReader.targetType
        local Duration = JsonReader.duration
        local AnimType = JsonReader.animType
        local ExitTargetType = JsonReader.exitTargetType
        local ExitDuration = JsonReader.exitDuration
        local ExitAnimType = JsonReader.exitAnimType
        --local IsMajorShow = JsonReader.isMajorShow
        local StartTime = JsonReader.m_StartTime
        local EndTime = JsonReader.m_EndTime
        local TotleTime = EndTime - StartTime
        local UCameraPostEffectMgr = _G.UE.UCameraPostEffectMgr.Get()
        if (UCameraPostEffectMgr ~= nil) then
            UCameraPostEffectMgr:SetColorFadeWithExit(TargetType, Duration, AnimType, ExitTargetType, ExitDuration, ExitAnimType, TotleTime)
        end
    end
end

--副本转场
local function OnPWorldTransition(ActionParams)
    -- if (ActionParams.Param1 <= 0) then
    --     return
    -- end

    -- -- 字符串参数="IsShowPlayerModel=0,IsShowPlayerTop=1,IsShowUI=0"
    -- if (ActionParams.StrParam ~= nil and ActionParams.StrParam ~= "") then
    --     local StrParamList = string.split(ActionParams.StrParam, ',')
    --     local IsShowPlayerModel = GetActionStrParamValue(StrParamList, 1)
    --     local IsShowPlayerTop = GetActionStrParamValue(StrParamList, 2)
    --     local IsShowUI = GetActionStrParamValue(StrParamList, 3)
    
    --     OnShowUIAction({Param2=IsShowUI})
    --     OnShowActorAction({Param1=IsShowPlayerModel, Param2=IsShowPlayerTop})
    -- end
    
    -- --播放G6配置的技能屏幕效果（黑屏，模糊等）
    -- local SkillUtil = require("Utils/SkillUtil")
    -- local SubSkillID = SkillUtil.MainSkill2SubSkill(ActionParams.Param1)
    -- local CellDataList = _G.SkillActionMgr:GetCellDataList(SubSkillID)
    -- for _, JsonReader in pairs(CellDataList) do
    --     ExecFadeAction(JsonReader)
    -- end
end

local function OnChangeExpHeightFog(ActionParams)
    local HeightFogController = _G.NewObject(_G.UE.UExponentialHeightFogController)
    if (HeightFogController ~= nil) then
        HeightFogController:Update(ActionParams.Param1, ActionParams.Param2)
    end
end

local function OnPWorldATLSwitch(ActionParams)
    --local EntityID = 0
    local TimelineID = ActionParams.Param7

    local function ATLSwitch(EntityID,TimelineID)
        if (EntityID == nil) then
            return
        end
        local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
        if (AnimComp == nil) then
            --FLOG_ERROR("无法找到角色，EntityID : "..tostring(EntityID))
            return
        end
        --FLOG_INFO(string.format("OnPWorldATLSwitch , EntityID : [%s],  TimelineID : [%s]", EntityID, TimelineID))
        AnimComp:PlayActionTimeline(TimelineID, 1.0, 0.25, 0.25, true, 99999, true)
    end

    if (ActionParams.Entities ~= nil and #ActionParams.Entities > 0) then
        for _, EntityID in pairs(ActionParams.Entities) do
            ATLSwitch(EntityID,TimelineID)
        end
    elseif (ActionParams.Param1 == ProtoRes.trigger_entity_type.TRIGGER_ENTITY_TYPE_TRIGGER) then
        ATLSwitch(ActionParams.TriggerEntityID,TimelineID)
    end
end

local function OnSetCameraParamsAction(ActionParams)
    local Major = MajorUtil.GetMajor()
    if Major ~= nil then
        local Camera = Major:GetCameraControllComponent()
        if Camera ~= nil then
            local ArmLength = ActionParams.Param1
            local MaxLength = ActionParams.Param2
            Camera:SetMaxCameraDistance(MaxLength)
            Camera:SetTargetArmLength(ArmLength)
            Camera:SetCameraBoomRelativeRotation(_G.UE.FRotator(ActionParams.Param4, ActionParams.Param5, ActionParams.Param3))
        end
    end
end

local function OnExecuteUIChange(ActionParams)
    --FLOG_ERROR("OnExecuteUIChange : "..tostring(EntityID))

    local UIType = ActionParams.Param1      --ProtoRes.action_change_ui_type
    local ResultType = ActionParams.Param2  --ProtoRes.action_challenge_result_type

    --FLOG_WARNING("OnExecuteUIChange UIType=%d", UIType)
    --FLOG_WARNING("OnExecuteUIChange ResultType=%d", ResultType)

    _G.EventMgr:SendEvent(_G.EventID.PWorldUIChange, UIType, ResultType)
end

local function OnSkillButtonTips(ActionParams)
    local SkillButtonID = ActionParams.Param1
    _G.EventMgr:SendEvent(_G.EventID.PWorldSkillTip, SkillButtonID)
end

local function OnScreenShake(ActionParams)
    if (ActionParams.StrParam ~= nil and ActionParams.StrParam ~= "") then
        local StrParam = string.match(ActionParams.StrParam, "^%s*(.-)%s*$")
        local ResPath = string.sub(StrParam, 1, -2).."_C'"

        --FLOG_WARNING("PlayCameraShake=%s",ResPath)
        _G.UE.UCameraMgr:Get():PlayCameraShake(ResPath)
    else
        FLOG_ERROR("角色震屏显示行为没有配置特效路径！")
    end
end

local EObjectGC_NoCache <const> = _G.UE.EObjectGC.NoCache

local function OnChangeAudio(ActionParams)
    local ID = ActionParams.StrParam
    if ID and ID ~= "" then
        local EventPath = LineVoiceCfg:FindValue(tonumber(ID), "EventPath")
        if not EventPath then
            return
        end
        AudioUtil.LoadAndPlay2DSound(EventPath, EObjectGC_NoCache)
    end
end

--动态物件状态变化
local function OnSgStateChange(ActionParams)
    FLOG_WARNING("OnSgStateChange ActionParams.Param1=%d, ActionParams.Param2=%d, ActionParams.Param4=%d, ActionParams.Param5=%d", ActionParams.Param1,ActionParams.Param2, ActionParams.Param4, ActionParams.Param5)
    --参数1为2是动态物件
    if (ActionParams.Param1 ~= 2) then
        return
    end

    local SgEditorID = ActionParams.Param2
    local State = ActionParams.Param4
    local PlayState = ActionParams.Param5

    if SgEditorID > 0 then
        local ContentSgMgrInstance = ContentSgMgr:Get()
        if ContentSgMgrInstance ~= nil then
            ContentSgMgrInstance:ChangeSgStateFromLua(SgEditorID,State,PlayState)
        end
    end
end



local TriggerActionRespFunctions = {
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_SHOW_UI] = OnShowUIAction,
    --[ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_SHOW_ACTOR] = OnShowActorAction,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_CAMERA_COLOR] = OnPlayCameraEffectAction,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_PWORLD_SNAPSHOT] = OnPWorldSnapshot,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_TRANSITION] = OnPWorldTransition,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_ENTITY_ADD_BUBBLE] = OnPWorldBubble,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_ENTITY_ATL_SWITCH] = OnPWorldATLSwitch,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_CAMERA_PARAMS] = OnSetCameraParamsAction,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_EXEC_UI_CHANGE] = OnExecuteUIChange,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_SKILL_BTN_TIPS] = OnSkillButtonTips,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_EOBJ_VISIABLE_STATE] = OnSgVisibilityStateChange,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_SCREEN_SHAKE] = OnScreenShake,    
    --[ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_EXP_HEIGHTFOG_CHANGE] = OnChangeExpHeightFog,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_CHANGE_AUDIO] = OnChangeAudio,
    [ProtoRes.trigger_action_type.TRIGGER_ACTION_TYPE_CLIENT_CHANGE_EOBJ_STATE] = OnSgStateChange,
}

function PWorldTriggerActionExecMgr:OnTriggerActionExec(ActionType, ActionParams)
    local RespFunction = TriggerActionRespFunctions[ActionType]
    if (RespFunction) then
        RespFunction(ActionParams)
    end
end

return PWorldTriggerActionExecMgr