--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-10-25 19:47:31
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-10-30 14:43:32
FilePath: \Script\Game\Interactive\FunctionItem\FunctionInteractiveDesc.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local MajorUtil = require("Utils/MajorUtil")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsID = require("Define/MsgTipsID")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local FuncCfg = require("TableCfg/FuncCfg")
local TransCfg = require("TableCfg/TransCfg")
local WildBoxMoundMgr = require("Game/WildBoxMound/WildBoxMoundMgr")
local UserDataID = require("Define/UserDataID")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local WeatherDefine = require("Game/Weather/WeatherDefine")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIViewID = require("Define/UIViewID")
local QuestHelper = require("Game/Quest/QuestHelper")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_NPC_CMD
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local InteractiveMgr = nil
local BagMgr = nil

--- @class FunctionInteractiveDesc : FunctionBase
local FunctionInteractiveDesc = LuaClass(FunctionBase)

--===================================
--服务器触发交互的 交互功能列表
--在这里配置了的，就不要自己主动触发读条了（服务器会回包，然后自动进入读条，读条结束后，服务器就会直接触发交互功能）

-- FuncsTableOfSvrStart = FuncsTableOfSvrStart or
-- {
--     --[functype, true]
--     [ProtoRes.interact_func_type.INTERACT_FUNC_TAKE_STAGEINTERACTION_S] = true,   --关卡交互
--     [ProtoRes.interact_func_type.INTERACT_FUNC_EXIT_PWORLD_S] = true,         --退出副本
-- }

--===================================

function FunctionInteractiveDesc:Ctor()
    self.FuncType = LuaFuncType.INTERACTIVEDESCC_FUNC
end

function FunctionInteractiveDesc:OnInit(DisplayName, FuncParams)
    InteractiveMgr = _G.InteractiveMgr
    BagMgr = _G.BagMgr
    self.FuncParams = FuncParams
    self.ListID = FuncParams.ListID
    self.InteractivedescCfg = InteractivedescCfg:FindCfgByKey(FuncParams.FuncValue)
    self.DisplayName = DisplayName
    if self.InteractivedescCfg then
        self.IconPath = self.InteractivedescCfg.IconPath
        if self.InteractivedescCfg.NotWeaponBack then
            self.WeaponBackWhenClick = false
        end

        local QuestOverwrite = _G.QuestMgr:GetQuestOverwriteInteract(self.InteractivedescCfg.ID, self.ResID)
        if QuestOverwrite then
            if QuestOverwrite.DisplayName ~= nil then
                self.DisplayName = QuestOverwrite.DisplayName
            end
            if QuestOverwrite.IconPath ~= nil then
                self.IconPath = QuestOverwrite.IconPath
            end
        end
    end

    if not string.isnilorempty(FuncParams.OverwriteIcon) then
        self.IconPath = FuncParams.OverwriteIcon
    end

    if self.InteractivedescCfg.ConfirmText and string.len(self.InteractivedescCfg.ConfirmText) > 0 then
        self.MessageBoxConfirmText = self.InteractivedescCfg.ConfirmText
    end

    -- 1：隐藏二级列表 2：返回一级列表  0：不做任何变化，保持在二级列表
    local funcType = self.InteractivedescCfg.FuncType
    if (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_GATHER_S) then
        self.UIOPWhenClick = 0
    end
end

--！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
--
--重要说明：新增的二级交互项功能，需要考虑功能执行后，是否要退出当前交互流程或者保留二级交互项
--         如要退出当前交互，请添加 self:ExitInteractive()
--
--重要说明：新增的二级交互项功能，需要考虑功能执行后，是否要退出当前交互流程或者保留二级交互项
--         如要退出当前交互，请添加 self:ExitInteractive()
--
--重要说明：新增的二级交互项功能，需要考虑功能执行后，是否要退出当前交互流程或者保留二级交互项
--         如要退出当前交互，请添加 self:ExitInteractive()
--
--！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
function FunctionInteractiveDesc:OnClick()
    -- 如果是任务交互并锁定状态
    local LockMask = self.LockMask
    if LockMask == 1 then
        QuestHelper.PlayRestrictedDialog(self.QuestID, self.TargetID)
        return
    end

    if self.FuncParams and self.FuncParams.IsEntranceItem then
        _G.NpcDialogMgr:OnlySwitchCameraOrTurn(self.FuncParams.CameraData)
    end
    local ConditionID = self.InteractivedescCfg and self.InteractivedescCfg.ConditionID
    local CondRlt, _, _ = ConditionMgr:CheckConditionByID(ConditionID, nil, true)

    local funcType = self.InteractivedescCfg and self.InteractivedescCfg.FuncType
    local InteractiveID = self.InteractivedescCfg and self.InteractivedescCfg.ID
    local FuncID = self.InteractivedescCfg and self.InteractivedescCfg.FuncID
    if FuncID and FuncID > 0 and not self.FuncCfg then
        self.FuncCfg = FuncCfg:FindCfgByKey(FuncID)
    end

    local Values = {}
    if self.FuncCfg then
        Values = self.FuncCfg.Func[1].Value
    else
        Values = self.InteractivedescCfg and self.InteractivedescCfg.FuncValue
    end

    --目前还没有需要带业务模块交互数据的，如果有的话，构造下table，同时也要扩展协议
    local LoginDataTable = nil
    local NeedSendMsg = false
    if funcType == ProtoRes.interact_func_type.INTERACT_FUNC_DIALOGG then
        _G.NpcDialogMgr:PlayDialogLib(Values[1], nil)
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_DIALOG_AND_OPENUI then
        local DialogID = Values[1]
        local ViewID = Values[2]
        if ViewID and ViewID ~= 0 and DialogID and DialogID ~= 0 then
            local DialogCallBack = function ()
                _G.UIViewMgr:ShowView(ViewID)
                self:ExitInteractive()
            end
            _G.NpcDialogMgr:PlayDialogLib(DialogID, self.EntityID, false, DialogCallBack)
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_UI) then
        InteractiveMgr:SetNeedRecoveryInteractiveEntrance(true)
        if self.FuncParams and self.FuncParams.IsTransferInterAct then
            InteractiveMgr:ShowView(_G.UIViewID.WorldVisitPanel, true,  {CrystalID = self.FuncParams.CrystalID})
            self:ExitInteractive()
        end

        local ViewID = Values[1]
        if ViewID == _G.UIViewID.MusicPlayerMainPanelView then
            _G.MusicPlayerMgr:OpenMusicPlayer()
            return
        end

        if ViewID == _G.UIViewID.WardrobeMainPanel then
            _G.WardrobeMgr:OpenWardrobeMainPanel(true)
            return
        end

        if ViewID == _G.UIViewID.WeatherForecastMainPanel then
            _G.WeatherMgr:OpenWeahterForecastUI({Source = WeatherDefine.Source.Npc})
            return
        end

        if ViewID == _G.UIViewID.ChocoboNameWinView then
            _G.ChocoboMgr:OpenNameView(ChocoboDefine.SOURCE.NPC)
            self:ExitInteractive()
            return
        end

        if ViewID == _G.UIViewID.ChocoboMainPanelView then
            self:ExitInteractive()
            _G.ChocoboMgr:ShowChocoboMainPanelView()
            return
        end

        if ViewID == _G.UIViewID.ChocoboBorrowPanelView then
            self:ExitInteractive()
            _G.ChocoboMgr:OpenChocoboBorrowPanel()
            return
        end

        if (ViewID ~= nil) then
            if ViewID == _G.UIViewID.EmotionMainPanel then
                local CurSelectedPlayerEntityID = InteractiveMgr:GetCurrSelectedPlayerEntityID()
                if CurSelectedPlayerEntityID ~= 0 then
                    --InteractiveMgr:ShowView(ViewID, true, { EntityID = CurSelectedPlayerEntityID })
                    _G.EmotionMgr:ShowEmotionMainPanel({ EntityID = CurSelectedPlayerEntityID })
                else
                    --InteractiveMgr:ShowView(ViewID, true, Values)
                    _G.EmotionMgr:ShowEmotionMainPanel(Values)
                end
            else
                InteractiveMgr:ShowView(ViewID, true, Values)
                self:ExitInteractive()
            end
            -- if ViewID == _G.UIViewID.PWorldEntouragePanel then
            --     self:ExitInteractive()
            -- end
        end

        -- 打开魔纹，进入副本
        _G.TreasuryMgr:OnInteractiveClick(FuncID,self.FuncParams)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_TAKE_STAGEINTERACTION_S) then
        if (_G.FateMgr:CheckIsFateCollectItem(InteractiveID)) then
            if (_G.FateMgr:CheckCanInteractiveCollectItem(InteractiveID)) then
                NeedSendMsg = true
            else
                NeedSendMsg = false
            end
        else
            NeedSendMsg = true
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_PWORLD_UI) then
        local EntID = Values[1]
        -- local InMapID = Values[2]

        if not EntID then
            self:ExitInteractive()
            return
        end

        local PWCfg = SceneEnterCfg:FindCfgByKey(EntID)
        if PWCfg then
            local Params = {
                EID = EntID,
                TypeID = PWCfg.TypeID,
            }

            InteractiveMgr:ShowView(_G.UIViewID.PWorldEntranceSelectPanel, true, Params)
        else
            FLOG_ERROR("ShowPWorldEntViewNM PWCfg = nil EntID = " .. tostring(EntID))
        end
        self:ExitInteractive()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_SINGLE_SCENE_S) then
        -- 单人副本
        local Data = {
            NormalID = tonumber(Values[1]),
            EasyID = tonumber(Values[2]),
            EasiestID = tonumber(Values[3]),
            FromTargetID = self.FromTargetID
        }
        _G.UIViewMgr:ShowView(_G.UIViewID.PWorldMainlinePanel, Data)
        -- add by sammrli 单人副本需要上报
        InteractiveMgr:SendReport(self)

    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_FANTASYCARD) then
        if (_G.MagicCardMgr:HasFinishTargetQuest()) then
            local ReqInfo = {
                NPCID = self.ResID,
                NPCEntityID = self.EntityID,
                IsTournament = false,
            }
            _G.EventMgr:SendEvent(_G.EventID.MagicCardGameStartReq, ReqInfo)
        else
            -- 没有完成任务，那么播放默认的对话内容
            _G.MagicCardMgr:PlayDefaultDialog(self.ResID, self.EntityID, nil)
        end

    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_GATHER_S) then
		--FLOG_INFO("Interactive Function Click CastSkill")
        local Major = MajorUtil:GetMajor()
        if Major then
            if Major:IsSwimming() then
                _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherCurStateInvalid)
                return
            end

            local NoteCfg = GatherNoteCfg:FindCfgByItemID(self.ResID)
            if NoteCfg then
                local MajorAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gathering)
                if NoteCfg.MinAcquisition > MajorAttr then
                    _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatheringNotEnough)
                else
                    if not _G.GatherMgr.IsGathering then
                        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherNotInState)
                    else
                        _G.SkillLogicMgr:CastMainAttackSkill()
                    end
                end
            end
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_CRYSTALTRANSFERSPELL_S) then
		--FLOG_INFO("Interactive Function Click CrystalTransfer")
        --_G.PWorldMgr:GetCrystalPortalMgr():TransferByInteractive(self.FuncParams.FromCrystal, self.FuncParams.ToCrystal)
        if not self.FuncParams or nil == self.FuncParams.IsSwitchPWorldBranch then
            _G.WorldMapMgr:ShowWorldMap()
        else
            _G.UIViewMgr:ShowView(_G.UIViewID.PWorldBranchPanel)
        end
        InteractiveMgr:ExitInteractive()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_MINICACTPOT) then
        --参加微彩的交互
        _G.MiniCactpotMgr:OnInteractiveClick(self.ResID, self.EntityID, FuncID, Values)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_FANTASYCARD_TOURNEY) then
        --参加幻卡大赛的交互
        _G.MagicCardTourneyMgr:OnStartMagicCardTourneyWithNPC(self.ResID, self.EntityID, FuncID, Values)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_FASHIONCHECK) then
        _G.FashionEvaluationMgr:OnEnterFashionEvaluation()
        _G.NpcDialogMgr:EndInteraction()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_MYSTER_MERCHANT then
        --神秘商人交互
        _G.MysterMerchantMgr:OnInteractiveClick(self.ResID, self.EntityID, InteractiveID, Values)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTERTAIN_GATE_SIGNUP) then --
        _G.GoldSauserMgr:InteractWithReleNpcs(self.ResID, self.EntityID)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_START_FATE) then
        --开启Fate交互
        _G.FateMgr:OnStartFateInteractiveClick(self.ResID, self.EntityID)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_FAIRYCOLOR) then
        _G.JumboCactpotMgr:OnJumbInteractive(self.ResID, self.InteractivedescCfg)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_GOLDSAUSER_COMMFUNC) then
        _G.GoldSauserMgr:OnExchangeJDCoinInteractive(self.ResID, self.InteractivedescCfg, FuncID)
        -- 指导者交互
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_GUIDE) then
        -- 0 指导认证  1 请辞指导者身份
        local SubFunID = tonumber(Values[1])
          -- SubFunID = 0 时 Param值对应  MentorDefine.GuideType
        local Param = tonumber(Values[2])
        if  0 == SubFunID then
            _G.MentorMgr:OpenMentorConditionUI(Param)
        elseif 1 == SubFunID then
            _G.MentorMgr:OpenResignMentorUI()
        else
            FLOG_ERROR("Interactive Guide FuncValue[0]  is error!")
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_NEWBIE_AUTH) then
        _G.NewbieMgr:NewbieAttestationReq()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_SCENE_S) then
        local TransConfig = TransCfg:FindCfgByKey(Values[1])
        if CondRlt then
            ---满足条件
            local DialogCallBack = function ()
                if TransConfig and TransConfig.Question ~= "" then
                    local function SendInteractive()
                        _G.NpcDialogMgr:EndInteraction()
                        self:SendInteractiveReq()
                    end
                    local function CancelCallBack()
                        _G.NpcDialogMgr:EndInteraction()
                        InteractiveMgr:StartTickTimer()
                    end
                    _G.HUDMgr:ShowAllActors()
                    MsgBoxUtil.MessageBox(TransConfig.Question, _G.LSTR(10002), _G.LSTR(10003), SendInteractive, CancelCallBack)
                else
                    _G.HUDMgr:ShowAllActors()
                    self:SendInteractiveReq()
                end
            end
            if TransConfig then
                if TransConfig.QualifiedPreTalk and TransConfig.QualifiedPreTalk > 0 then
                    _G.NpcDialogMgr:PlayDialogLib(TransConfig.QualifiedPreTalk, self.EntityID, false, DialogCallBack)
                else
                    DialogCallBack()
                end
                if TransConfig.SceneID then
                    _G.HotelMgr:CheckNeedReport(TransConfig.SceneID)
                end
            end
        else
            --不满足条件
            if TransConfig then
                _G.NpcDialogMgr:PlayDialogLib(TransConfig.UnqualifiedPreTalk)
            end
        end
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_GOLDSAUCERGAME  then
        -- 金碟小游戏进入逻辑
        local MiniGameType = Values[1] -- ProtoCS.ACTIVITY_TYPE
        if  self.FuncParams and self.FuncParams.EntityID then
            _G.GoldSaucerMiniGameMgr:InteractEnterTheGoldSaucerMiniGame(MiniGameType, self.FuncParams.EntityID)
        end
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_EXPLORENOTE_EMOTIONREQ then
        -- 探索笔记情感交互逻辑
        local EObjID = self.ResID or 0
        local NoteItemID = _G.DiscoverNoteMgr:GetTheNoteIDByEobjResID(EObjID)
        local InteractiveID = self.FuncParams and self.FuncParams.FuncValue or 0
        local EntityID = self.EntityID
        local bPerfectPoint = _G.DiscoverNoteMgr:IsPerfectNotePoint(EObjID)
        if not bPerfectPoint then -- 非完美探索点为普通流程
            _G.DiscoverNoteMgr:EmotionInteractReq(NoteItemID, InteractiveID, EntityID)
        else
            _G.DiscoverNoteMgr:OpenPerfectEmotionView(NoteItemID, EntityID)
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_STORE) then
        _G.ShopMgr:OpenShop(Values[2], nil, false, 2)
        self:ExitInteractive()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_PROCESS_FATE) then
        -- 在进行中的对话
        _G.FateMgr:OnProcessingInteractiveClick(self.ResID, self.EntityID)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_LEVEQUEST) then
        _G.UIViewMgr:ShowView(_G.UIViewID.LeveQuestMainPanel)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_MAIL) then
        _G.MailMgr:OpenMailMainView()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_START_FANTASIA) then
        if CondRlt then
            --满足条件，播放动画后传送
            local function SequenceCallBack()
                --在动画结束时显示Loading，防止穿帮
                _G.WorldMsgMgr:ShowLoadingView(_G.WorldMsgMgr.CurWorldName)
                self:SendInteractiveReq()
            end
            local PlaybackSettings = {
                bDisableMovementInput = true,
                bDisableLookAtInput = true,
                bPauseAtEnd = false,
            }
            -- 测试用ID
            --根据交互时当前的地图名，获取使用的SequenceID
            local SequenceID = _G.Fantasia_Sequence_Sleep[_G.WorldMsgMgr.CurWorldName]
            if SequenceID then
                _G.StoryMgr:PlayDialogueSequence(SequenceID, SequenceCallBack, SequenceCallBack, SequenceCallBack, PlaybackSettings)
            else
                SequenceCallBack()
            end
        else
            --不满足条件，弹Tips提示
            _G.MsgTipsUtil.ShowErrorTips(LSTR(90016))
            --这里主动退出交互，显示主Panel。如果不这么做，第一次ShowTips的时候会由ShowView触发恢复控制(SetInputMode_GameAndUI)，
            --第二次ShowTips时，TipsView并没有Hide(似乎显示后永远都不会Hide)，导致没有走ShowView流程，无法恢复控制
            --这里退出交互、恢复控制不应该依赖于Tips的显示，因此主动退出交互
            self:ExitInteractive()
            return
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_START_HAIRCUT) then
        if CondRlt then
            -- 获取当前地图ID
            local MapID = _G.PWorldMgr:GetCurrMapResID()
            --满足条件，播放动画后传送
            local function SequenceCallBack()
                _G.WorldMsgMgr:ShowLoadingView(_G.WorldMsgMgr.CurWorldName)
                _G.HaircutMgr:SetEnterMap(MapID)
                self:SendInteractiveReq()
            end
            local PlaybackSettings = {
                bDisableMovementInput = true,
                bDisableLookAtInput = true,
                bPauseAtEnd = false,
            }

            local SequenceID = _G.HaircutMgr:GetLcutID(MapID, _G.HaircutMgr.HaircutInSeq)
            if SequenceID > 0 then
                _G.StoryMgr:PlayDialogueSequence(SequenceID, SequenceCallBack, 
                    nil, SequenceCallBack, PlaybackSettings)
            else
                SequenceCallBack()
            end
        else
            --不满足条件，弹Tips提示
            self:ExitInteractive()
            InteractiveMgr:SetNeedRecoveryInteractiveEntrance(true)
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_PWORLD_UI_S) then
        self:SendInteractiveReqWithoutObj()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_RIDE_MOUNT) then
        --乘上搭档（主角骑乘搭档实际是骑乘坐骑, 骑乘的坐骑应该是坐骑id=1的专属陆行鸟）
        InteractiveMgr:CancelTargetInteractive()
        _G.MountMgr:SendMountCall(1)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_LEAVE_MOUNT) then
        --让搭档离开
        InteractiveMgr:CancelTargetInteractive()
        _G.BuddyMgr:SendBuddyCallMessage(false)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_SWITCH_COMPANION) then
        --随机切换宠物
        InteractiveMgr:CancelTargetInteractive()
        local NextCallOutCompanion = _G.CompanionMgr:GetCompanionFromRandom()
        _G.CompanionMgr:CallOutCompanion(NextCallOutCompanion)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_LEAVE_COMPANION) then
        --让宠物离开
        InteractiveMgr:CancelTargetInteractive()
        _G.CompanionMgr:CallBackCompanion()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_PERSONAL_INFO) then
        --打开其他玩家铭牌界面
        local CurSelectedPlayerEntityID = InteractiveMgr:GetCurrSelectedPlayerEntityID()
        if CurSelectedPlayerEntityID ~= 0 then
            InteractiveMgr:ShowPersonalSimpleInfoView(CurSelectedPlayerEntityID)
        else
            InteractiveMgr:ShowPersonalSimpleInfoView(self.EntityID)
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_TAKE_DUEL) then
        --对其他玩家发起决斗
        local TargetID = ActorUtil.GetRoleIDByEntityID(self.EntityID)
        _G.WolvesDenPierMgr:InviteDuel(TargetID)
        _G.InteractiveMgr:HideSelectedTargetFunctionPanel()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_MAJOR_TRANSFORM) then
        --主角变身上buff

    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_RECALL_SUMMONED_BEAST) then
        --召回召唤兽
        InteractiveMgr:RecallSummonedBeast(self.ResID)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_FATE_PUZZLE_JIGSAW) then
        --FATE拼图游戏,这里要判断一下，如果玩家不是加入FATE的状态，那么提示一下
        if (not _G.FateMgr:IsJoinFate()) then
            local MsgID = 334029
            MsgTipsUtil.ShowTipsByID(MsgID)
            return
        end
        local EntityID = self.EntityID
        local ResID = self.ResID
        _G.FateMgr:SendFateStartPuzzleReq(EntityID, ResID)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_FATE_PUZZLE_EMOTION) then
        --FATE情感动作，这里要判断一下，如果玩家不是加入FATE的状态，那么提示一下
        if (not _G.FateMgr:IsJoinFate()) then
            local MsgID = 334029
            MsgTipsUtil.ShowTipsByID(MsgID)
            return
        end
        local Params = {}
        local EntityID = self.EntityID
        Params.ClickCallback = function(InEmotionID)
            _G.FateMgr:SendFateDanceReq(EntityID, InEmotionID)
        end
        Params.EntityID = EntityID
        _G.EmotionMgr:ShowEmotionMainPanel(Params)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_SELECT_PLAYER) then
        --选择玩家列表中的玩家
        --InteractiveMgr:RefreshFixedFunctionItemList(self.EntityID)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_ARMY_LOCKERS) then
        -- 打开部队储物柜界面
        _G.ArmyMgr:OpenArmyStore(true)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_EMOTION) then
        --情感动作场景交互
        self:ExitInteractive()
        _G.EmotionMgr:SendEmotionReq(88)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_RIDE_MOUNT_TEMPORARY) then
        --坐骑试骑
        if FuncID == 1101 then
            --坐骑试骑，此处仅监测记录一次交互变量
            print("====== 光之盛典-坐骑试骑活动-召唤兜兜企鹅坐骑 ====== ")
            local MountVM = require("Game/Mount/VM/MountVM")
            if MountVM then
                MountVM.bRideProbationState = true
            end
        end
        NeedSendMsg = true
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_SURVEY_S) then
        if InteractiveID == 100017 and FuncID == 1101 then
            --坐骑试骑，此处仅监测记录一次交互变量
            print("====== 光之盛典-坐骑试骑活动-召唤兜兜企鹅坐骑 ====== ")
            local MountVM = require("Game/Mount/VM/MountVM")
            if MountVM then
                MountVM.bRideProbationState = true
            end
        end
        NeedSendMsg = true
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_WILD_TREASUREBOX) then
        -- 同一个位置种宝箱，土堆，空eobj，交互放在空eobj上。
        -- 最终表现就是，玩家和空的eobj交互，交互读条结束，空eobj回收，土堆裂开，宝箱出现自动打开，时间到了回收土堆
        if self.ListID and self.ListID > 0 then
            InteractiveMgr:SetCurrentSingInteractionId(0)
            _G.WildBoxMoundMgr:OpenBox(InteractiveID, self.EntityID, self.ListID)
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_PLAY_LCUT) then
        local AudioUtil = require("Utils/AudioUtil")
        local SaveKey = require("Define/SaveKey")
        _G.UE.UAudioMgr.Get():StopSceneBGM()
        local EntityID = MajorUtil.GetMajorEntityID()
        local AudioID = AudioUtil.SyncLoadAndPlayUISound(EntityID, "/Game/WwiseAudio/Events/sound/zingle/Zingle_Sleep/Play_Zingle_Sleep.Play_Zingle_Sleep")
        _G.HotelMgr:CheckPlayHistory(SaveKey.HotelSleep)
        local PlaybackSettings = {
            bDisableMovementInput = true,
            bDisableLookAtInput = true,
            bPauseAtEnd = true,
        }
        local CallBack = function()
            _G.LoginMgr:ReturnToLogin(true)
            _G.HotelMgr:SavePlayHistory(SaveKey.HotelSleep)
            AudioUtil.StopSound(AudioID)
        end
        local pWorldCfg =  _G.PWorldMgr:GetCurrPWorldTableCfg()
        DataReportUtil.ReportHotelData("HotelInfo", _G.HotelMgr.ReportDefine.Leave, pWorldCfg.ID or 0)
        _G.StoryMgr:PlayDialogueSequence(Values[1], CallBack, nil, CallBack, PlaybackSettings)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_TREASUREHUNT) then
        local RoleSimple = MajorUtil.GetMajorRoleSimple()
        local CurrProf = RoleSimple.Prof
        local bCombatProf = _G.ProfMgr.CheckProfClass(CurrProf, ProtoCommon.class_type.CLASS_TYPE_COMBAT)
        if not bCombatProf then
            --[[local function Callback()
                self:SendInteractiveReq()
            end
            local function SwitchProf()
                _G.ProfMgr.ShowProfSwitchTab()
            end
            local MsgContent = LSTR(90017)
            MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), MsgContent, Callback, SwitchProf, LSTR(90018), LSTR(90019))]]
            _G.MsgTipsUtil.ShowTips(LSTR(90032))
            return
        end

        local MajorRoleID = MajorUtil.GetMajorRoleID()
        local BoxUserData = ActorUtil.GetUserData(self.EntityID, UserDataID.TreasureHuntBox)
        if BoxUserData then
            if BoxUserData.RoleID > 0 then
                if BoxUserData.RoleID ~= MajorRoleID then
                    _G.MsgTipsUtil.ShowTipsByID(109204)
                    return
                end
            else
                if _G.TreasureHuntMgr:IsTreasureHuntBoxOpened(self.EntityID) then
                    MsgTipsUtil.ShowTipsByID(109217)    -- 已打开宝箱，淡出中不允许交互
                    return
                end
            end
        end

        local Major = MajorUtil.GetMajor()
        if Major:IsInFly() then 
            _G.MsgTipsUtil.ShowTips(LSTR(90020))
            return 
        end

        _G.TreasureHuntMgr:OpenWildBoxReq(self.ResID, self.EntityID)
        InteractiveMgr:DelayShowEntrance(1)
        --NeedSendMsg = false
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ARMY_TRANSFER) then
        InteractiveMgr:SetNeedRecoveryInteractiveEntrance(true)
        local ViewID = Values[1] or 0 
        InteractiveMgr.CurrentFunctionViewID = ViewID
        _G.CompanySealMgr:OpenCompanyTransferView(Values[2])
        self:ExitInteractive()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ARMY_RANK) then
        InteractiveMgr:SetNeedRecoveryInteractiveEntrance(true)
        local ViewID = Values[1] or 0 
        InteractiveMgr.CurrentFunctionViewID = ViewID
        _G.CompanySealMgr:OpenCompanyRankView(Values[2])
        self:ExitInteractive()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ARMY_RANK_PROMOTION) then
        InteractiveMgr:SetNeedRecoveryInteractiveEntrance(true)
        local ViewID = Values[1] or 0 
        InteractiveMgr.CurrentFunctionViewID = ViewID
        _G.CompanySealMgr:OpenPromotionView(Values[2])
        self:ExitInteractive()
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ARMY_PREPARATORY) then
        InteractiveMgr:SetNeedRecoveryInteractiveEntrance(true)
        local ViewID = Values[1] or 0 
        InteractiveMgr.CurrentFunctionViewID = ViewID
        _G.CompanySealMgr:OpenCompanyTaskView()
        self:ExitInteractive()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_CHOCOBO_RACE_MATCH_UI then
        _G.ChocoboMgr:OpenChocoboMatchPanel()
        self:ExitInteractive()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_HELP_INFO_UI then
        local HelpInfoUtil = require("Utils/HelpInfoUtil")
        local HelpID = Values[1] or 0
        HelpInfoUtil.ShowHelpInfoByID(HelpID)
        self:ExitInteractive()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_CHOCOBO_RACE_NPC_CHALLENGE then
        _G.ChocoboRaceMgr:OpenChocoboRaceNpcChallenge(self.ResID, self.EntityID)
        self:ExitInteractive()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_CHOCOBO_NEW_BORN then
        local IsExitInteractive = _G.ChocoboMgr:OpenMatingReceivePanel(true)
        if IsExitInteractive then
            self:ExitInteractive()
        else
            _G.NpcDialogMgr:PlayDialogLib(18574, self.EntityID, false, nil)
        end
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_CHOCOBO_MATING then
        local IsExitInteractive = _G.ChocoboMgr:OpenChocoboBreedPanel(true)
        if IsExitInteractive then
            self:ExitInteractive()
        else
            _G.NpcDialogMgr:PlayDialogLib(18572, self.EntityID, false, nil)
        end
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_CHOCOBO_ADPOT then
        if _G.ChocoboMgr:CanOpenChocoboAdopt() then
            InteractiveMgr:ShowView(_G.UIViewID.ChocoboSelectSexView, true,  {Source = ChocoboDefine.SOURCE.ADOPT})
        end
        self:ExitInteractive()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_ARMY_UI then
        ---部队打开指定界面
        local Params
        if #Values > 1 then
            Params = {}
            for Index, Value in ipairs(Values) do
                if Index > 1 then
                    table.insert(Params, Value)
                end
            end
        end
        _G.ArmyMgr:OpenUIPanel(Values[1], Params)
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_MATERAIL_EXCHANGE then
        local ItemID = _G.EquipmentMgr:GetFristInVersionMaterial()
        if ItemID then
            _G.UIViewMgr:ShowView(UIViewID.EquipmentExchangeWinView, {ItemID = ItemID})
        else
            MsgTipsUtil.ShowErrorTips(_G.LSTR(90021))
        end
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_LEAP_OF_FAITH_EXIT_UI) then
        -- 跳跳乐到达终点的离开交互ID
        _G.GoldSauserLeapOfFaithMgr:ShowLeaveConfirm()
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_DISCOVERNOTE_NPC_CLUE then
        local DialogID = Values[1]-- npc对话表配置ID
        _G.NpcDialogMgr:PlayDialogLib(DialogID, self.EntityID, false, function()
            self:SendInteractiveReq()
        end)
    elseif funcType == ProtoRes.interact_func_type.INTERACT_FUNC_TREASUREHUNT_PWORLD_GATE then
        local InRolling = _G.RollMgr:HasAssignedReward()
        NeedSendMsg = not InRolling

        if InRolling then
            _G.MsgTipsUtil.ShowTipsByID(40866)
        end
    else
        NeedSendMsg = true
        --没有处理的部分
        -- return false
    end

    if NeedSendMsg then
        if funcType == ProtoRes.interact_func_type.INTERACT_FUNC_EXIT_PWORLD_S then
            if _G.PWorldQuestMgr.IsRolling then
                _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(1320270), _G.LSTR(1320269), function()
                    self:SendInteractiveReq()
                end,
                nil, _G.LSTR(1320271), _G.LSTR(1320272), nil, function()
                    self:ExitInteractive()
                end)
            else
                self:SendInteractiveReq()
            end
        else
            self:SendInteractiveReq()
        end
        -- local function CheckNextInteractive()
        --     InteractiveMgr:StartTickTimer()
        -- end
        -- _G.TimerMgr:AddTimer(nil, CheckNextInteractive, 0.2)
        return true
    end

    -- 若有任务需要完成客户端交互，则通知后台
    if self.InteractivedescCfg and funcType < ProtoRes.interact_func_type.INTERACT_FUNC_CLIENT_MAX then
        _G.EventMgr:SendEvent(_G.EventID.ClientInteraction, self.ResID, InteractiveID)
    end

    return true
end

function FunctionInteractiveDesc:ExitInteractive()
    _G.NpcDialogMgr:EndInteraction()
    InteractiveMgr:ExitInteractive()
    InteractiveMgr:ShowOrHideMainPanel(true)
end

function FunctionInteractiveDesc:SendInteractiveReq()
    InteractiveMgr:SendInteractiveStartReq(self.FuncParams.FuncValue, self.EntityID)
    if nil ~= self.InteractivedescCfg.IsForceExitInteractive and self.InteractivedescCfg.IsForceExitInteractive == 1 then
        self:ExitInteractive()
    end
end

-- 直接通过UI执行交互，没有交互对象的情况
function FunctionInteractiveDesc:SendInteractiveReqWithoutObj()
    InteractiveMgr:SendInteractiveStartReqWithoutObj(self.FuncParams.FuncValue)
end

return FunctionInteractiveDesc
