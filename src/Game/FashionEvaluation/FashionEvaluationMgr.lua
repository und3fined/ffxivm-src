--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:时尚品鉴Mgr

local LuaClass = require("Core/LuaClass")
local Json = require("Core/Json")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WardrobeMainPanelVM = require("Game/Wardrobe/VM/WardrobeMainPanelVM")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionEvaluationVM = require("Game/FashionEvaluation/VM/FashionEvaluationVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local ModuleID = ProtoCommon.ModuleID
local ClientSetupKey = ProtoCS.ClientSetupKey
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local PWorldMgr = _G.PWorldMgr
local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local Fashion_Evaluation_OP = ProtoCS.Game.FashionCheck.Cmd
local FashionEvaluationMgr = LuaClass(MgrBase)
local UActorManager = _G.UE.UActorManager.Get()
local EvaluateState = FashionEvaluationDefine.EvaluateState

function FashionEvaluationMgr:OnInit()
    self.EvaluateState = EvaluateState.Start
    self.IsStartEvaluate = false
    self.CreatedNPCList = {}
    self.TrackThemeID = 0
    self.CurThemeID = 0
    self.SequenceID = 0
    self.PreviewEquipList = {}
    self.IsLoadigFinished = false -- 过渡界面是否加载结束
    self.IsPrologueFinished = false -- 开场白是否播放完成
    self.IsFirstOpenWithinWeek = true -- 本周内第一次打开
    self.IsFashionSceneVisible = false -- 是否关闭主场景（用于判断LCut结束后是否还要继续结算）
end

function FashionEvaluationMgr:OnBegin()
end

function FashionEvaluationMgr:OnEnd()
end

function FashionEvaluationMgr:OnShutdown()
end

function FashionEvaluationMgr:OnRegisterNetMsg()
    -- 时尚品鉴信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FASHION_CHECK, Fashion_Evaluation_OP.Update, self.OnNetMsgFashionEvalutionUpdate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FASHION_CHECK, Fashion_Evaluation_OP.Check, self.OnNetMsgEvaluationResult)
end

function FashionEvaluationMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    --self:RegisterGameEvent(EventID.EnterInteractionRange, self.OnGameEventEnterInteractionRange)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.EnterInteractive, self.OnSingleInteractive)
    self:RegisterGameEvent(EventID.FinishDialog, self.OnFinishDialog)
    self:RegisterGameEvent(EventID.ClientSetupPost, self.OnClientSetupPost)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify) --系统解锁
    self:RegisterGameEvent(EventID.OnAppearanceTrackStateChanged, self.OnAppearanceTrackStateChanged)
    -- 衣橱解锁更新
	self:RegisterGameEvent(EventID.WardrobeUnlockUpdate, self.OnWardrobeUnlockUpdate)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
end

function FashionEvaluationMgr:OnGameEventLoginRes(Params)
    print("FashionEvaluationMgr:OnGameEventLoginRes")
    local bReconnect = Params.bReconnect
    if (bReconnect) then
        self:OnExitFashionEvaluation()
    end
end

--- @type 进入副本时 拉取大赛数据，供其它模块调用
function FashionEvaluationMgr:OnPWorldReady()
    if PWorldMgr == nil or PWorldMgr.BaseInfo == nil then
        return
    end

    -- 进入金蝶场景时
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if BaseInfo.CurrMapResID == FashionEvaluationDefine.JDMapID then
        self:SendMsgGetFashionEvaluationInfo()
    end
end

---@type 时尚品鉴解锁
function FashionEvaluationMgr:OnModuleOpenNotify(InModuleID)
    if InModuleID == ModuleID.ModuleIDFashionCheck then
        self:SendMsgGetFashionEvaluationInfo()
    end
end

function FashionEvaluationMgr:GetRedDotName(AppID)
    if AppID == nil then
        return FashionEvaluationDefine.TrackRedDotName
    end
	local RedDotName = string.format(FashionEvaluationDefine.TrackRedDotName..'/'..AppID)
	return RedDotName
end

--- @type 点击一级交互开启对话
function FashionEvaluationMgr:OnSingleInteractive(EntranceItem)
	if EntranceItem == nil then
		return
	end

	self.EntranceItem = EntranceItem
    local NpcID = FashionEvaluationDefine.EvaluationNPCID
    if self.EntranceItem.ResID ~= NpcID then
        return
    end
    self.EvaluationNPCEntityID = self.EntranceItem.EntityID
    self.IsStartEvaluate = false
end

--- @type 完成对话框时
function FashionEvaluationMgr:OnFinishDialog(FinishDialogParams)
    if _G.NpcDialogMgr:IsDialogPlaying() then
        return
    end
	if self.EntranceItem == nil then
		return
	end
    if self.EntranceItem.ResID == nil then
        return
    end
    local NpcID = FashionEvaluationDefine.EvaluationNPCID
    if self.EntranceItem.ResID ~= NpcID then
        return
    end

    if self.IsStartEvaluate == false then
        return
    end
    --临时处理，这里完成对话直接进入下个流程，实际情况后面再确定
    if self.EvaluateState == EvaluateState.Start then
        self:OnFashionNPCEvaluation() 
    elseif self.EvaluateState == EvaluateState.FashionShow then
        self:OnFashionShowInProgress() -- 展示过程
        self:OnFashionNPCEvaluationEnd()
    elseif self.EvaluateState == EvaluateState.FashionShowEnd then
        self:OnEvaluateInProgress() -- 打分过程
        self:OnFashionNPCResultFeedback()
    elseif self.EvaluateState == EvaluateState.Result then
        self:OnEvaluateEnd()
    end
end

---@type 与NPC交互开始时尚品鉴
function FashionEvaluationMgr:OnEnterFashionEvaluation()
    -- 进入品鉴场景
    self:SendMsgGetFashionEvaluationInfo(true)
end

---@type 退出时尚品鉴返回金蝶
function FashionEvaluationMgr:OnExitFashionEvaluation()
    self:ShowFashionActorScene(false)
    if _G.StoryMgr:GetCurrentSequenceID() == self.SequenceID then
        _G.StoryMgr:StopSequence()
    end
    self:RestoreRoleAvatar()
end

---@type 时尚品鉴主界面显示状态
function FashionEvaluationMgr:OnFashionSceneVisibleChanged(IsVisible)
    self.IsFashionSceneVisible = IsVisible
    if IsVisible then
        self:OnLoadingStart()
	    self:OnPrologueStart()
    else
        FashionEvaluationVM:SetMainViewVisible(false)
        self:RemoveCreatedNPCList()
    end
end

---@type 品鉴是否开启
function FashionEvaluationMgr:IsFashionEvaluationActive()
    return false
end

---@type 品鉴开启与结束时间 
function FashionEvaluationMgr:GetEvaluationDate()
    local DataInfo = {
        StartTime = 0,
        EndTime = 0,
    }

    return DataInfo
end

---@type 是否完成
function FashionEvaluationMgr:IsFinishedEvaluation()
    -- 数据未更新
    if self.CurThemeID <= 0 then
        return false
    end
    --没有了次数或领取了最高奖励
    local IsGetMaxAward = FashionEvaluationVM:IsGetMaxAward()
    local RemainTimes = FashionEvaluationVM:GetReaminTimes()
    return IsGetMaxAward or RemainTimes <= 0
end

---@type 是否参与过时尚评分
function FashionEvaluationMgr:IsEvaluated()
    --参与过且没有拿到所有奖励
    local RemainTimes = FashionEvaluationVM:GetReaminTimes()
    local IsEvaluted = RemainTimes and RemainTimes < FashionEvaluationVMUtils.GetWeekMaxEvaluateTimes()
    local IsGetMaxAward = FashionEvaluationVM:IsGetMaxAward()
    return IsEvaluted and not IsGetMaxAward
end

---@type 是否即将结束
function FashionEvaluationMgr:IsNearlyOverEvaluation()
    --活动还有一天就刷新了
    local NextUpdateRemainSecs = self:GetEvaluationRemainTime() --距离下次服务器刷新时间
    return NextUpdateRemainSecs <= 24 * 3600
end

---@type 是否可以显示成就弹窗
function FashionEvaluationMgr:CanShowAchievementLeftBar()
    return not self.IsStartEvaluate  -- 不在播放评分LCut中时
end

---@type 获取时尚品鉴剩余时间
function FashionEvaluationMgr:GetEvaluationRemainTime()
    return FashionEvaluationVMUtils.GetRemainSecondTime()
end

---@type 获取时尚品鉴信息
---@return table
function FashionEvaluationMgr:GetEvaluationInfo()
    return FashionEvaluationVM:GetFashionEvaluationSingleInfo()
end

---@type 获取时尚品鉴主题名字
---@return table
function FashionEvaluationMgr:GetThemeName()
    return FashionEvaluationVM:GetThemeName()
end

function FashionEvaluationMgr:GetIsFirstOpenWithinWeek()
    return self.IsFirstOpenWithinWeek
end

function FashionEvaluationMgr:SetIsFirstOpenWithinWeek(Value)
    self.IsFirstOpenWithinWeek = Value
    self:SaveLastEquipAndTrackEquip()
end

---@type 追踪列表是否存在可解锁外观
function FashionEvaluationMgr:IsExistUnlockableAppInTrackList()
    local TrackVM = FashionEvaluationVM:GetTrackVM()
    if TrackVM == nil then
        return false
    end
    return TrackVM:IsExistUnlockableAppInTrackList()
end

---@type 选中NPC
function FashionEvaluationMgr:OnSelectedNPC(NPCIndex)
    local EntityID = self.CreatedNPCList[NPCIndex]
    local Params = {
        NPCIndex = NPCIndex,
        NPCEntityID = EntityID,
    }

    if EntityID then
        self:ShowFashionNPCView(true, Params)
    end
end

---@type 获取选中时尚达人
function FashionEvaluationMgr:GetSelectedNPCActor()
    local SelectNPCIndex = FashionEvaluationVM.CurSelectNPCIndex
    if SelectNPCIndex and SelectNPCIndex > 0 then
        local CreatedNPCEntityID = self.CreatedNPCList and self.CreatedNPCList[SelectNPCIndex] or nil
        if CreatedNPCEntityID then
            return ActorUtil.GetActorByEntityID(CreatedNPCEntityID)
        end
    end
    return nil
end

local function UpdateSelectedNPCRotation(Yaw)
    local CurSelectedNPC = _G.FashionEvaluationMgr:GetSelectedNPCActor()
    if CurSelectedNPC then
        CurSelectedNPC:K2_SetActorRotation(_G.UE.FRotator(0, Yaw, 0), false)
    end
end

---@type 过渡界面开始加载
function FashionEvaluationMgr:OnLoadingStart()
    self.IsLoadigFinished = false
    _G.UIViewMgr:ShowView(UIViewID.FashionEvaluationLoadingPanel)
end

---@type 过渡界面开始加载结束
function FashionEvaluationMgr:OnLoadingEnd()
    _G.UIViewMgr:HideView(UIViewID.FashionEvaluationLoadingPanel)
    self.IsLoadigFinished = true
end

---@type 开场白播放开始
function FashionEvaluationMgr:OnPrologueStart()
    self.IsPrologueFinished = false
end

---@type 开场白播放结束
function FashionEvaluationMgr:OnPrologueEnd()
    self.IsPrologueFinished = true
    self:SetIsFirstOpenWithinWeek(false)
	self:ShowFashionMainView(true)
end

function FashionEvaluationMgr:GetIsLoadingEnd()
    return self.IsLoadigFinished
end

function FashionEvaluationMgr:GetIsPrologueEnd()
    return self.IsPrologueFinished
end

---@type 显示时尚品鉴场景
function FashionEvaluationMgr:ShowFashionActorScene(IsVisible)
    if IsVisible then
        local View = UIViewMgr:ShowView(UIViewID.FashionEvaluationMainPanel)
        if View then
            self.Render2DView = View.Render2D
            self.Render2DView.CallBackRotate = UpdateSelectedNPCRotation
            self:RestoreUICharacterAvatar()
            self.Render2DView:HidePlayer(true)
        end
    else
        if UIViewMgr:IsViewVisible(UIViewID.FashionEvaluationMainPanel) then
            UIViewMgr:HideView(UIViewID.FashionEvaluationMainPanel)
        end
    end
end

---@type 显示时尚品鉴主界面
function FashionEvaluationMgr:ShowFashionMainView(IsVisible)
    FashionEvaluationVM:SetMainViewVisible(IsVisible)
end

---@type 显示试衣服界面
---@param IsVisible 是否显示
---@param IsMutualWithMainView 是否和主界面互斥显示
function FashionEvaluationMgr:ShowFittingView(IsVisible, IsMutualWithMainView)
    if IsVisible then
        UIViewMgr:ShowView(UIViewID.FashionEvaluationFittingPanel)
    else
        UIViewMgr:HideView(UIViewID.FashionEvaluationFittingPanel)
    end
    FashionEvaluationVM:SetFittingViewVisible(IsVisible, IsMutualWithMainView)
end

---@type 显示时尚达人NPC界面
function FashionEvaluationMgr:ShowFashionNPCView(IsVisible, Params)
    FashionEvaluationVM:SetNPCEquipViewVisible(IsVisible)

    if IsVisible == true and Params then
        FashionEvaluationVM:OnSelectedNPC(Params)
        UIViewMgr:ShowView(UIViewID.FashionEvaluationNPCPanel, Params)
    else
        UIViewMgr:HideView(UIViewID.FashionEvaluationNPCPanel)
    end
end

---@type 显示追踪目标界面
function FashionEvaluationMgr:ShowTrackTargetView()
    local TrackVM = FashionEvaluationVM:GetTrackVM()
    if TrackVM then
        TrackVM:UpdateTrackAppearanceList(self.TrackAppearanceIDList)
    end
    UIViewMgr:ShowView(UIViewID.FashionEvaluationTrackerPanel)
end

---@type 显示挑战记录界面
function FashionEvaluationMgr:ShowHistoryScoreView(IsVisible)
    if IsVisible then
        UIViewMgr:ShowView(UIViewID.FashionEvaluationHistoryPanel)
        self:ShowFittingView(false, false)
    else
        UIViewMgr:HideView(UIViewID.FashionEvaluationHistoryPanel)
        self:ShowFittingView(true, false)
    end
    FashionEvaluationVM:SetRecordViewVisible(IsVisible)
end

---@type 开始评分按钮点击
function FashionEvaluationMgr:OnStartEvaluateClicked()
    local FittingVM = FashionEvaluationVM:GetFittingVM()
    if FittingVM == nil then
        return
    end
    local IsNotChange = FittingVM:IsSameWithLastEquipList()
    local IsComplete = FittingVM:IsEquipedComplete()
    if not IsNotChange and IsComplete then
        self:OnStartEvaluate()
        return
    end

    local function LeftCallBack()
        MsgBoxUtil.CloseMsgBox()
    end
    local TipContent = ""
    if IsNotChange then
        TipContent = FashionEvaluationDefine.EquipNotChangeTipText
    elseif not IsComplete then
        TipContent = FashionEvaluationDefine.EquipNotCompleteTipText
    end

    MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(FashionEvaluationDefine.ChallengeConfirmUKey), TipContent, self.OnStartEvaluate, LeftCallBack, 
    LSTR(FashionEvaluationDefine.CancelUkey), LSTR(FashionEvaluationDefine.ConfirmUKey))
end

---@type 开始评分流程
function FashionEvaluationMgr:OnStartEvaluate()
    if self.FashionEvalutionInfo then
        local ThemeID = self.FashionEvalutionInfo.ThemeID
        local FittingVM = FashionEvaluationVM:GetFittingVM()
        if FittingVM then
            local AppearanceList = FittingVM:GetPartEquipList()
            self.PreviewEquipList = AppearanceList
            self.IsStartEvaluate = true
            self:SendMsgGetEvaluationResult(ThemeID, AppearanceList)
        end
    end
end

---@type 罗斯评价对话
function FashionEvaluationMgr:OnFashionNPCEvaluation()
    self.EvaluateState = EvaluateState.FashionShow
    self:OnEvaluateStateChanged(self.EvaluateState)
end

---@type 罗斯结束语对话
function FashionEvaluationMgr:OnFashionNPCEvaluationEnd()
    self.EvaluateState = EvaluateState.FashionShowEnd
    self:OnEvaluateStateChanged(self.EvaluateState)
end

---@type 罗斯结果反馈对话
function FashionEvaluationMgr:OnFashionNPCResultFeedback()
    self.EvaluateState = EvaluateState.Result
    self:OnEvaluateStateChanged(self.EvaluateState)
end

---@type 时装展示过程
function FashionEvaluationMgr:OnFashionShowInProgress()
    -- TODO 镜头动画

end

---@type 评分过程
function FashionEvaluationMgr:OnEvaluateInProgress()
    if self.FashionEvalutionInfo == nil then
        return
    end
    local CheckResult = self.FashionEvalutionInfo.CheckResult
    if CheckResult == nil then
        return
    end

    -- 给玩家主体角色装备上品鉴外观
    local FittingVM = FashionEvaluationVM:GetFittingVM()
    if FittingVM then
        local Equips = {}
        if self.PreviewEquipList then
            for Part, Appearance in pairs(self.PreviewEquipList) do
                if Appearance.AppearanceID > 0 then
                    Equips[Part] = {Part = Part, AppearanceID = Appearance.AppearanceID, DefaultEquipID = 0}
                end
            end
        end
        self:WearAppearanceList(Equips, true)
        local MajorAvatarComponent = MajorUtil.GetMajorAvatarComponent()
        if (MajorAvatarComponent ~= nil) then
            self:TakeOffWeapon(MajorAvatarComponent, true)
        end
    end
    
    ---@type 评分结束
    local function OnEvaluateEnd()
        self.IsStartEvaluate = false
        if self.IsFashionSceneVisible then
            -- 隐藏试衣界面和主界面
            self:ShowFittingView(false, false)
            self:ShowFashionMainView(false)
        
            -- 显示结算界面
            UIViewMgr:ShowView(UIViewID.FashionEvaluationSettlementPanel)
            FashionEvaluationVM:SetSettlementViewVisible(true)
        end
        
        if self.CommentTimer then
            self:UnRegisterTimer(self.CommentTimer)
            self.CommentTimer = nil
        end

        FashionEvaluationVM:ClearCommentList()
        _G.EventMgr:SendEvent(_G.EventID.OnFashionEvaluationStart, false)
    end
    local ResultScore = CheckResult.TotalScore
    self.SequenceID = FashionEvaluationVMUtils.GetLCutSequence(ResultScore)
    FLOG_INFO("播放时尚品鉴LCut ID:"..self.SequenceID)
    _G.EventMgr:SendEvent(_G.EventID.OnFashionEvaluationStart, true)
    _G.StoryMgr:PlayDialogueSequence(self.SequenceID, OnEvaluateEnd, nil, OnEvaluateEnd)
    self.EvaluateState = EvaluateState.Start
    self.IsStartEvaluate = true
    self:OnEvaluateStateChanged(self.EvaluateState)
end

---@type 还原玩家主体角色（非预览）装备
function FashionEvaluationMgr:RestoreRoleAvatar()
    local MajorAvatarComponent = MajorUtil.GetMajorAvatarComponent()
    if (MajorAvatarComponent ~= nil) then
        MajorAvatarComponent:ForceUpdateCurRoleAvatar()
    end
end

---@type 刷新NPC弹幕
function FashionEvaluationMgr:UpdateComment()
    local CheckResult = self.FashionEvalutionInfo and self.FashionEvalutionInfo.CheckResult
    if CheckResult == nil then
        return
    end
    local Score = CheckResult.TotalScore
    local Interanl = FashionEvaluationVMUtils.GetCommentInternal(Score)
    if self.CommentTimer then
        self:UnRegisterTimer(self.CommentTimer)
        self.CommentTimer = nil
    end
    local function AddComment()
        FashionEvaluationVM:AddComment()
    end
    self.CommentTimer = self:RegisterTimer(AddComment, Interanl, Interanl, -1)
end

---@type 评分结束
function FashionEvaluationMgr:OnEvaluateEnd()
    -- TODO 显示结算界面
    UIViewMgr:ShowView(UIViewID.FashionEvaluationSettlementPanel)
    FashionEvaluationVM:SetSettlementViewVisible(true)
    self.IsStartEvaluate = false

    if self.CommentTimer then
        self:UnRegisterTimer(self.CommentTimer)
        self.CommentTimer = nil
    end
    FashionEvaluationVM:ClearCommentList()
end

---@type 评分状态改变 --TODO 二期使用LCut,暂弃用
function FashionEvaluationMgr:OnEvaluateStateChanged(EvaluateState)
  
end

---@type 目标按钮点击
---@param AppearanceID number
---@param IsChecked 按钮状态
function FashionEvaluationMgr:OnEquipTrackClicked(AppearanceID, IsChecked)
    if AppearanceID == nil or AppearanceID <= 0 then
        return false
    end
    local TrackVM = FashionEvaluationVM:GetTrackVM()
    if TrackVM == nil then
        return false
    end
    local OprateSuccess = true
    local IsTracked = TrackVM:IsTracked(AppearanceID)
    local ActualIsTrack = not IsTracked
    if ActualIsTrack then
        if TrackVM:CanAddEquipToTrackList() then
            ActualIsTrack = TrackVM:AddEquipToTrackList(AppearanceID)
        else --追踪数量达到上限提示
            if IsChecked then
                MsgTipsUtil.ShowTips(FashionEvaluationDefine.TrackNumFullTipText)
            end
            ActualIsTrack = false
            OprateSuccess = false
        end
    else
        TrackVM:RemoveEquipFromTrackList(AppearanceID)
    end
    
    local FittingVM = FashionEvaluationVM:GetFittingVM()
    if FittingVM then
        FittingVM:OnAppearanceTrackChanged(AppearanceID, ActualIsTrack)
    end

    return OprateSuccess
end

function FashionEvaluationMgr:OnAppearanceTrackStateChanged(AppearanceID, IsTrack)
    self:SaveLastEquipAndTrackEquip()
    local FittingVM = FashionEvaluationVM:GetFittingVM()
    if FittingVM then
        FittingVM:OnAppearanceTrackChanged(AppearanceID, IsTrack)
    end

    --追踪标记成功提示
    local AddTipContent = FashionEvaluationDefine.TrackTipText
    --移除追踪标记提示
    local RemoveTipContent = FashionEvaluationDefine.TrackCancelTipText

    local TipContent = IsTrack and AddTipContent or RemoveTipContent
    MsgTipsUtil.ShowTips(TipContent)
end

function FashionEvaluationMgr:OnWardrobeUnlockUpdate(Params)
	local TrackVM = FashionEvaluationVM:GetTrackVM()
    if TrackVM == nil then
        return
    end

	-- 更新红点
	local UnlockAppearanceList = Params.UnlockAppearanceList
	for _, v in ipairs(UnlockAppearanceList) do
        TrackVM:UpdateRedDot(v.AppearanceID)
	end
    _G.EventMgr:SendEvent(_G.EventID.OnFashionEvaluationTrackUpdate)
end

function FashionEvaluationMgr:OnBagUpdate(Params)
    -- 更新红点
	if nil == Params then
		return
	end
    local IsAddEquip = false
	for _, Value in pairs(Params) do
		local Item = Value.PstItem
        if Item.Attr and Item.Attr.ItemType == ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP then
            IsAddEquip = true
            break
        end
	end

    if IsAddEquip then
        local TrackVM = FashionEvaluationVM:GetTrackVM()
        if TrackVM then
            TrackVM:UpdateTrackAppearanceList(self.TrackAppearanceIDList)
        end
        _G.EventMgr:SendEvent(_G.EventID.OnFashionEvaluationTrackUpdate)
    end
end

---@type 保存
function FashionEvaluationMgr:SaveLastEquipAndTrackEquip()
    local TrackVM = FashionEvaluationVM:GetTrackVM()
    if TrackVM == nil then
        return
    end
    local CurThemeID = FashionEvaluationVM.ThemeID
    local TrackEquipIDList = TrackVM:GetTrackAppList()
    local SaveData = {
        ThemeID = CurThemeID,
        IsFirstOpenWithinWeek = self.IsFirstOpenWithinWeek,
        TrackList = TrackEquipIDList
    }
    local TrackEquipIDStr = Json.encode(SaveData)
    self:SendMsgSetTrackEquip(TrackEquipIDStr)
end

---@type 创建5个时尚达人NPC
function FashionEvaluationMgr:CreateAllNPC()
    if self.CreatedNPCList and #self.CreatedNPCList > 0 then
        return
    end

    local NpcList = FashionEvaluationVMUtils.GetNPCInfos()
    if NpcList == nil then
        return
    end

    self.AllNpcDefaultTransform = {}
    for Index, NpcInfo in ipairs(NpcList) do
        local NpcLocation = NpcInfo.Location
        local NpcRotation = NpcInfo.Rotation
        local NpcID = NpcInfo.NPCID
        
	    local Params = UE.FCreateClientActorParams()
	    Params.bUIActor = true
        Params.bAsync = true
        local CreatedNPCEntityID = _G.UE.UActorManager.Get():CreateClientActorByParams(_G.UE.EActorType.Npc, 0, NpcID, NpcLocation, NpcRotation, Params) 
        local _npcActor = ActorUtil.GetActorByEntityID(CreatedNPCEntityID)
        if (_npcActor ~= nil) then
            _G.UE.UVisionMgr.Get():RemoveFromVision(_npcActor)
            local _avatarComponent = _npcActor:GetAvatarComponent()
            if (_avatarComponent ~= nil) then
                _avatarComponent:SetForcedLODForAll(1)
                local NPCAppList = self.FashionEvalutionInfo and self.FashionEvalutionInfo.NPCList
                if NPCAppList then
                    local NPCApp = NPCAppList[Index]
                    if NPCApp then
                        local AppMap = NPCApp.EquipMap
                        self:WearEquipsForNPC(_avatarComponent, AppMap)
                        self:TakeOffWeapon(_avatarComponent, true)
                    end   
                end
            end
            _npcActor:AdjustGround(false)
            self.AllNpcDefaultTransform[CreatedNPCEntityID] = {
                Location = NpcLocation,
                Rotation = NpcRotation,
            }
            table.insert(self.CreatedNPCList, CreatedNPCEntityID)
        else
            _G.FLOG_WARNING("错误，加载角色失败，请检查！")
        end 
    end
end

function FashionEvaluationMgr:WearEquipsForNPC(AvatarComp, AppMap)
    if AvatarComp == nil then
        return
    end

    if AppMap == nil then
        return
    end

    for Part, Appearance in pairs(AppMap) do
        local Part = Part
        local AppearanceID = Appearance.AppearanceID
        local AppPart = WardrobeUtil.GetPartByAppearanceID(AppearanceID)
        if Part == AppPart then
            local EquipID = FashionEvaluationVMUtils.GetEquipIDByAppearanceID(AppearanceID)
            if EquipID then
                AvatarComp:HandleAvatarEquip(EquipID, Part, -1, false, nil, false)
                AvatarComp:AddAllNakedBody()
                AvatarComp:StartLoad(true)
            end
        end
    end
end

function FashionEvaluationMgr:TakeOffWeapon(AvatarComp, IsTakeOff)
    if AvatarComp == nil then
        return
    end
    AvatarComp:SetAvatarHiddenInGame(_G.UE.EAvatarPartType.WEAPON_MASTER_HAND, IsTakeOff, false, false)
    AvatarComp:SetAvatarHiddenInGame(_G.UE.EAvatarPartType.WEAPON_SLAVE_HAND, IsTakeOff, false, false)
end

function FashionEvaluationMgr:GetCreatedNPCList()
    return self.CreatedNPCList
end

---@type 移除所有时尚达人
function FashionEvaluationMgr:RemoveCreatedNPCList()
    if self.CreatedNPCList == nil then
        return
    end

    for _, EntityID in ipairs(self.CreatedNPCList) do
        local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
        if NpcActor then
            _G.UE.UActorManager.Get():RemoveClientActor(EntityID)
        end
    end
    self.CreatedNPCList = {}
    self.AllNpcDefaultTransform = nil
end

---@type 隐藏或显示所有时尚达人
function FashionEvaluationMgr:HideCreatedNPCList(IsHide)
    if self.CreatedNPCList == nil then
        return
    end

    for _, EntityID in ipairs(self.CreatedNPCList) do
        local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
        if NpcActor then
            _G.UE.UActorManager.Get():HideActor(EntityID, IsHide)
            if not IsHide then
                self:SetNPCToDefaultTransform(EntityID)
                NpcActor:AdjustGround(false)
            end
        end
    end
end

---@type 显示或创建所有时尚达人
function FashionEvaluationMgr:ShowOrCreateAllNPC()
    if self.CreatedNPCList == nil or #self.CreatedNPCList <= 0 then
        self:CreateAllNPC()
        return
    end

    self:HideCreatedNPCList(false)
end

---@type 获取NPC校准后的初始位置数据
---@param EntityID number NPC 实例ID，为空时返回所有NPC变换数据
function FashionEvaluationMgr:GetNPCDefaultTransform(EntityID)
    return self.AllNpcDefaultTransform and self.AllNpcDefaultTransform[EntityID]
end

---@type 设置NPC到初始位置
function FashionEvaluationMgr:SetNPCToDefaultTransform(EntityID)
    local DefaultTransform = self:GetNPCDefaultTransform(EntityID)
    if DefaultTransform == nil then
        return
    end

    local NewLocation = DefaultTransform.Location
    local NewRotation = DefaultTransform.Rotation

    local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
    if NpcActor == nil then
        return
    end

    if NewLocation then
        NpcActor:K2_SetActorLocation(NewLocation, false, nil, false)
    end
    if NewRotation then
        NpcActor:K2_SetActorRotation(NewRotation, false)
    end
end

function FashionEvaluationMgr:GetUIComplexCharacter()
	if not self.Render2DView then
		return nil
	end

	return self.Render2DView.UIComplexCharacter
end

---@type 试穿单个外观
function FashionEvaluationMgr:WearAppearance(Part, AppearanceID, InEquipID, IsMajorCharacter)
    if Part == nil then
        return
    end

    local EquipID = 0
    if InEquipID and InEquipID > 0 then
        EquipID = InEquipID
    else
        EquipID = FashionEvaluationVMUtils.GetEquipIDByAppearanceID(AppearanceID)
    end
    
    if IsMajorCharacter then
        -- 实际玩家，非预览角色
        local Major = MajorUtil.GetMajor()
        local MajorAvatarComponent = Major and Major:GetAvatarComponent()
        if (MajorAvatarComponent ~= nil) then
            if EquipID and EquipID > 0 then
                MajorAvatarComponent:HandleAvatarEquip(EquipID, Part, -1, false, nil, false)
            else
                local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
                local PosKey = EquipmentDefine.EquipmentTypeMap[Part]
                MajorAvatarComponent:TakeOffAvatarPart(PosKey, true)
            end
            MajorAvatarComponent:AddAllNakedBody()
            MajorAvatarComponent:StartLoad(true)
        end
    else
        local UIComplexCharacter = self:GetUIComplexCharacter()
        if not UIComplexCharacter then
            return 
        end
        if EquipID and EquipID > 0 then
            UIComplexCharacter:PreViewEquipment(EquipID, Part, 0)
        else
            UIComplexCharacter:PreViewEquipment(0, Part, 0)
        end
        UIComplexCharacter:HideWeapon(true)
    end
end

---@type 试穿外观列表
function FashionEvaluationMgr:WearAppearanceList(AppearanceList, IsMajorCharacter)
	if AppearanceList == nil then
		return
	end

	for _, Appearance in pairs(AppearanceList) do
		local Part = Appearance.Part
		local AppearanceID = Appearance.AppearanceID
        local EquipID = 0
        if AppearanceID == nil or AppearanceID <= 0 then
            EquipID = Appearance.DefaultEquipID
        end
        self:WearAppearance(Part, AppearanceID, EquipID, IsMajorCharacter)
	end
end

---@type 恢复预览角色默认外观
function FashionEvaluationMgr:RestoreUICharacterAvatar()
	if not self.Render2DView or not _G.CommonUtil.IsObjectValid(self.Render2DView) then
		return nil
	end

    local EntityID = MajorUtil.GetMajorEntityID()
	self.Render2DView:SetUICharacterByEntityID(EntityID)
end

---@type 播放对应动作
function FashionEvaluationMgr:PlayMajorAnimation(Score)
	local UIComplexCharacter = self:GetUIComplexCharacter()
	if UIComplexCharacter == nil then
		return
	end
	local AnimComp = UIComplexCharacter:GetAnimationComponent()
	if AnimComp == nil then
		return
	end
	local AnimPath = FashionEvaluationVMUtils.GetAnimPathByScore(Score, UIComplexCharacter)
	if not string.isnilorempty(AnimPath) then
		AnimComp:PlayAnimation(AnimPath, 1.0, 0.25, 0.25, true)
	end
end

function FashionEvaluationMgr:PlayMajorAnimByTimeline(TimelineID, bStopAllMontages)
    local UIComplexCharacter = self:GetUIComplexCharacter()
	if UIComplexCharacter == nil then
		return 0
	end
	local AnimComp = UIComplexCharacter:GetAnimationComponent()
	if AnimComp == nil then
		return 0
	end
    local Montage = AnimComp:PlayActionTimeline(TimelineID, 1.0, 0.25, 0.25, bStopAllMontages)
    return self:GetMontageLength(Montage)
end

function FashionEvaluationMgr:GetMontageLength(Montage)
    if Montage == nil then
        return 0
    end
    local Length = AnimationUtil.GetAnimMontageLength(Montage)
    return Length * 0.7  --实际时间更短，因为混合0.25会减少时长
end

function FashionEvaluationMgr:OnGoToUnlockAppearanceView(AppearanceID)
    if AppearanceID == nil then
        return
    end

    _G.WardrobeMgr:OpenWardrobeUnlockPanel(AppearanceID)
end

--region NetMsg---------------------------------------------------------------

---@type 获取评分结果请求
function FashionEvaluationMgr:SendMsgGetEvaluationResult(ThemeID, AppearanceList)
    local MsgID = CS_CMD.CS_CMD_FASHION_CHECK
    local SubMsgID = Fashion_Evaluation_OP.Check

    local MsgBody = {}
    MsgBody.Cmd = Fashion_Evaluation_OP.Check
    MsgBody.CheckReq = {}
    MsgBody.CheckReq.ThemeID = ThemeID
    MsgBody.CheckReq.TryOnEquipMap = AppearanceList
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 获取时尚品鉴信息请求
function FashionEvaluationMgr:SendMsgGetFashionEvaluationInfo(IsReqEnterFashionScene)
    if not _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDFashionCheck) then
        return
    end
    self.IsReqEnterFashionScene = IsReqEnterFashionScene

    local MsgID = CS_CMD.CS_CMD_FASHION_CHECK
    local SubMsgID = Fashion_Evaluation_OP.Update

    local MsgBody = {}
    MsgBody.Cmd = Fashion_Evaluation_OP.Update

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 时尚品鉴信息更新
function FashionEvaluationMgr:OnNetMsgFashionEvalutionUpdate(MsgBody)
    if MsgBody == nil then
        return
    end
    local InfoRsp = MsgBody.UpdateRsp
    if InfoRsp == nil then
        return
    end

    -- 后台返回顺序是乱的，按NPC配置表ID 排序
    local function NpcAppearancesSort(NpcA, NpcB)
        if NpcA.BigNpcID and NpcB.BigNpcID then
            return NpcA.BigNpcID < NpcB.BigNpcID
        end
        return false
    end

    table.sort(InfoRsp.NpcAppearances, NpcAppearancesSort)
    
    local BaseInfo = InfoRsp.BaseInfo
    self.FashionEvalutionInfo = {
        ThemeID = BaseInfo.ThemeID,
        RemainEvaluateTimes = BaseInfo.RemainCheckTimes, -- 本周剩余挑战次数
        BestEvaluationResult = BaseInfo.BestResult,    -- 最高分时的装备
        EvaluationHistorys = BaseInfo.Historys, -- 历史评分结果{TotalScore, SectionEquipList, OwnScore}

        Difficulty = InfoRsp.Difficulty, -- 难度等级
        NPCList = self:GetCorrectNPCEquipList(InfoRsp.NpcAppearances), --时尚达人外观
        RecommendEquips = self:GetRecommendEquipList(InfoRsp.RecommendEquipMap), -- 推荐外观
    }
    self.CurThemeID = BaseInfo and BaseInfo.ThemeID or 0
    FashionEvaluationVM:UpdateFashionEvaluationInfo(self.FashionEvalutionInfo)
    _G.GoldSauserMainPanelMgr:SetTheMsgUpdateState(GoldSauserGameClientType.GoldSauserGameTypeFashionCheck, true)

    if self.IsReqEnterFashionScene then
        self:ShowFashionActorScene(true)
        self.IsReqEnterFashionScene = false
    end
    _G.ClientSetupMgr:SendQueryReq({ClientSetupKey.CSFashionCheckTrackEqiu})
end

---@type 获取NPC外观 后台经常返回异常数据，所有这里过滤一遍
function FashionEvaluationMgr:GetCorrectNPCEquipList(NpcAppearances)
    if NpcAppearances == nil or next(NpcAppearances) == nil then
        return
    end
    local NewNpcAppearances = NpcAppearances
    for Index = 1, #NewNpcAppearances do
        local AppMap = NpcAppearances[Index].EquipMap
        if AppMap then
            for Part, Appearance in pairs(AppMap) do
                local AppearanceID = Appearance.AppearanceID
                local AppPart = tonumber(WardrobeUtil.GetPartByAppearanceID(AppearanceID) or 0)
                local PartName = FashionEvaluationDefine.EquipPartName[Part] or ""
                if AppearanceID <= 0 then
                    FLOG_WARNING(string.format("后台返回的NPC %s %s %s部位的外观为0!!!", Index, PartName, Part))
                elseif AppPart and AppPart > 0 then
                    if AppPart ~= Part then
                        Appearance.AppearanceID = 0  --外观和部位不符
                        FLOG_WARNING(string.format("后台返回的NPC %s的外观%s和部位%s %s不符!!!", Index, AppearanceID, PartName, Part))
                    end
                else
                    Appearance.AppearanceID = 0 --外观不存在
                    FLOG_WARNING(string.format("无法获取时尚品鉴NPC外观%s的部位，可能不存在,请检查！！！", AppearanceID))
                end
            end
        end
    end
    return NewNpcAppearances
end

---@type 获取推荐外观 后台经常返回异常数据，所有这里过滤一遍
function FashionEvaluationMgr:GetRecommendEquipList(RecommendEquipMap)
    local RecommendEquipList = {}
    for Part, EquipInfo in pairs(RecommendEquipMap) do
        local Equips = EquipInfo.Equips
        local AppearanceList = {}
        if Equips then
            for _, Equip in ipairs(Equips) do
                local AppearanceID = Equip.AppearanceID
                local AppPart = tonumber(WardrobeUtil.GetPartByAppearanceID(AppearanceID) or 0)
                local PartName = FashionEvaluationDefine.EquipPartName[Part] or ""
                if AppearanceID <= 0 then
                    FLOG_WARNING(string.format("后台推荐 %s %s部位的外观为0!!!", PartName, Part))
                elseif AppPart and AppPart > 0 then
                    if AppPart == Part then
                        table.insert(AppearanceList, AppearanceID)
                    else
                        FLOG_WARNING(string.format("后台推荐外观 %s和部位 %s %s不符!!!", AppearanceID, PartName, Part))
                    end
                else
                    FLOG_WARNING(string.format("无法获取推荐外观%s的部位，可能不存在或与版本不符,请检查！！！", AppearanceID))
                end
            end
        end
        local NewEquipInfo = {
            Part = Part,
            AppIDList = AppearanceList,
        }
        
        table.insert(RecommendEquipList, NewEquipInfo)
    end
    return RecommendEquipList
end

---@type 评分结果
function FashionEvaluationMgr:OnNetMsgEvaluationResult(MsgBody)
    if MsgBody == nil then
        return
    end
    local CheckInfo = MsgBody.CheckRsp
    if CheckInfo == nil then
        return
    end
    local BaseInfo = CheckInfo.BaseInfo
    self.FashionEvalutionInfo = {
        ThemeID = BaseInfo.ThemeID,
        RemainEvaluateTimes = BaseInfo.RemainCheckTimes, -- 本周剩余挑战次数
        BestEvaluationResult = BaseInfo.BestResult, -- 最高分时的装备
        EvaluationHistorys = BaseInfo.Historys, -- 历史评分结果{TotalScore, SectionEquipList, OwnScore}

        CheckResult = CheckInfo.CheckResult,  --时装品鉴装备评分结果
        Coins = CheckInfo.Coins, --获得金碟币数量
    }

    FashionEvaluationVM:UpdateSettlementInfo(self.FashionEvalutionInfo)
    FashionEvaluationVM:UpdateFashionEvaluationInfo(self.FashionEvalutionInfo)

    self:OnEvaluateInProgress() -- 进入评分界面
end


---@type 设置追踪外观
function FashionEvaluationMgr:SendMsgSetTrackEquip(EquipResIDStr)
    _G.ClientSetupMgr:SendSetReq(ClientSetupKey.CSFashionCheckTrackEqiu, EquipResIDStr)
end

---@type 设置追踪外观或查询回包
function FashionEvaluationMgr:OnClientSetupPost(EventParams)
    local Key = EventParams.IntParam1
	local Value = EventParams.StringParam1
    local IsSet = EventParams.BoolParam1
	if Key == ClientSetupKey.CSFashionCheckTrackEqiu then
		self.TrackAppearanceIDList = {}
        if not string.isnilorempty(Value) then
            local SaveData = Json.decode(Value)
            if SaveData and type(SaveData) == "table" then
                self.IsFirstOpenWithinWeek = SaveData.IsFirstOpenWithinWeek
                self.TrackThemeID = SaveData.ThemeID or 0
                if self.CurThemeID > 0 then
                    if self.TrackThemeID == self.CurThemeID then
                        self.OpenTimes = SaveData.OpenTimes or 0
                        self.TrackAppearanceIDList = SaveData.TrackList
                    else
                        --主题刷新，追踪目标清空
                        local NewSaveData = {
                            IsFirstOpenWithinWeek = true,
                            ThemeID = self.CurThemeID,
                            TrackList = {},
                        }
                        local SaveStr = Json.encode(NewSaveData)
                        self:SendMsgSetTrackEquip(SaveStr)
                        self.TrackThemeID = self.CurThemeID
                    end
                end
            end
        end
        
        local TrackVM = FashionEvaluationVM:GetTrackVM()
        if TrackVM then
            TrackVM:UpdateTrackAppearanceList(self.TrackAppearanceIDList)
        end
	end
end


--endregion
return FashionEvaluationMgr