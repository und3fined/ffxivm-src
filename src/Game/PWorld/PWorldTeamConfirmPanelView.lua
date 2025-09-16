--
-- Author: anypkvcai
-- Date: 2020-12-31 14:23:59
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")

local PWorldMatchMgr
local ProfUtil = require("Game/Profession/ProfUtil")
local PWorldVoteVM
local PWorldVoteMgr
local MagicCardTourneyVM

local ProtoCS = require ("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local LSTR = _G.LSTR
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")

---@class PWorldTeamConfirmPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AfterJobSlot CommPlayerSimpleJobSlotView
---@field BtnKeep CommBtnLView
---@field BtnReady CommBtnLView
---@field BtnRefuse CommBtnLView
---@field BtnTransform CommBtnLView
---@field CurrentJobSlot CommPlayerSimpleJobSlotView
---@field FinderSlot CommSceneModeSlotView
---@field ImgBkg UFImage
---@field ImgFrame UFImage
---@field ImgFrameLight UFImage
---@field ImgPworldIcon UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field PanelFinder UFCanvasPanel
---@field PanelMatchFailed UFCanvasPanel
---@field PanelNoRewardsTips UFCanvasPanel
---@field PanelNonPVPMember UFCanvasPanel
---@field PanelPVPMember UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field PanelTitle UHorizontalBox
---@field PanelTransformTips UFCanvasPanel
---@field ProgressBarLoading UProgressBar
---@field RichTextNoRewards URichTextBox
---@field TableMem UTableView
---@field TableMem_2 UTableView
---@field TableViewCrystallineMember UTableView
---@field TextAfterJob UFTextBlock
---@field TextCurrentJob UFTextBlock
---@field TextJob UFTextBlock
---@field TextMatchFailed UFTextBlock
---@field TextPworldLevel UFTextBlock
---@field TextPworldName UFTextBlock
---@field TextType UFTextBlock
---@field VerticaBoxMember UFVerticalBox
---@field VerticaBoxMember_1 UFVerticalBox
---@field AnimChangeJob UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---@field AnimShowAgain UWidgetAnimation
---@field AnimShowFirst UWidgetAnimation
---@field backupAnimIn UWidgetAnimation
---@field SoundEvent_Enter SoftObjectPath
---@field SoundEvent_CountDown SoftObjectPath
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeamConfirmPanelView = LuaClass(UIView, true)

function PWorldTeamConfirmPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AfterJobSlot = nil
	--self.BtnKeep = nil
	--self.BtnReady = nil
	--self.BtnRefuse = nil
	--self.BtnTransform = nil
	--self.CurrentJobSlot = nil
	--self.FinderSlot = nil
	--self.ImgBkg = nil
	--self.ImgFrame = nil
	--self.ImgFrameLight = nil
	--self.ImgPworldIcon = nil
	--self.JobSlot = nil
	--self.PanelFinder = nil
	--self.PanelMatchFailed = nil
	--self.PanelNoRewardsTips = nil
	--self.PanelNonPVPMember = nil
	--self.PanelPVPMember = nil
	--self.PanelProBar = nil
	--self.PanelTitle = nil
	--self.PanelTransformTips = nil
	--self.ProgressBarLoading = nil
	--self.RichTextNoRewards = nil
	--self.TableMem = nil
	--self.TableMem_2 = nil
	--self.TableViewCrystallineMember = nil
	--self.TextAfterJob = nil
	--self.TextCurrentJob = nil
	--self.TextJob = nil
	--self.TextMatchFailed = nil
	--self.TextPworldLevel = nil
	--self.TextPworldName = nil
	--self.TextType = nil
	--self.VerticaBoxMember = nil
	--self.VerticaBoxMember_1 = nil
	--self.AnimChangeJob = nil
	--self.AnimLoop = nil
	--self.AnimProgress = nil
	--self.AnimShowAgain = nil
	--self.AnimShowFirst = nil
	--self.backupAnimIn = nil
	--self.SoundEvent_Enter = nil
	--self.SoundEvent_CountDown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeamConfirmPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AfterJobSlot)
	self:AddSubView(self.BtnKeep)
	self:AddSubView(self.BtnReady)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.BtnTransform)
	self:AddSubView(self.CurrentJobSlot)
	self:AddSubView(self.FinderSlot)
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeamConfirmPanelView:OnInit()
	MagicCardTourneyVM = _G.MagicCardTourneyVM
	PWorldVoteVM = _G.PWorldVoteVM
	PWorldVoteMgr = _G.PWorldVoteMgr
	PWorldMatchMgr = _G.PWorldMatchMgr
	self.AdaMem4 = UIAdapterTableView.CreateAdapter(self, self.TableMem)
	self.AdaMem8 = UIAdapterTableView.CreateAdapter(self, self.TableMem_2)
	self.AdaCrystalline = UIAdapterTableView.CreateAdapter(self, self.TableViewCrystallineMember)

	self.MajorBinders = {
		{ "Prof", UIBinderValueChangedCallback.New(self, nil, function(_, Prof)
			local MajorVM = MajorUtil.GetMajorRoleVM(true)
			local EntID = PWorldVoteMgr:GetEnterSceneID()
			local PollType = PWorldVoteMgr:GetCurPollType()
			
			local Item = PWorldVoteMgr:GetEnterSceneMajorInfo()
			if not Item then
				return
			end

			if MajorVM == nil then
				return
			end

			local ShowChangeProfPanel = (Prof ~= Item.Prof and Prof ~= ProfUtil.GetAdvancedProf(Item.Prof))
			if PollType == ProtoCS.PollType.PollType_Chocobo or PollType == ProtoCS.PollType.PoolType_Tournament then
				ShowChangeProfPanel = false
			end

			local Mode = PWorldVoteMgr.Model

			UIUtil.SetIsVisible(self.PanelMatchFailed, ShowChangeProfPanel)
			UIUtil.SetIsVisible(self.BtnReady, not ShowChangeProfPanel, true)

			if Item.Prof then
				local ProfIcon = ProfUtil.Prof2Icon(Item.Prof) or ""
				UIUtil.ImageSetBrushFromAssetPath(self.JobSlot.ImgJob, ProfIcon)
				local ProfName = ProfUtil.Prof2Name(Item.Prof) or ""
				self.TextJob:SetText(ProfName)
			end

			self.JobSlot.TextLevel:SetText(Item.Level or "")

			if ShowChangeProfPanel then
				self.ProfCache = {
					Prof = MajorVM.Prof,
					Level = MajorVM.Level,
				}
			end
		end) },
	}

	self.Binders = {
		{ "SceneBG", 			UIBinderSetBrushFromMaterial.New(self, self.ImgBkg, "MainTexture") },
		{ "SneceIcon", 			UIBinderSetBrushFromMaterial.New(self, self.ImgPworldIcon)},
		{ "SceneName", 			UIBinderSetText.New(self, self.TextPworldName) },
		{ "SceneLevelDesc", 	UIBinderSetText.New(self, self.TextPworldLevel) },

		{ "IsMajorReady", 		UIBinderValueChangedCallback.New(self, nil, function(_, IsReady)
			self.BtnRefuse:SetIsEnabled(not IsReady)
			self.BtnReady:SetIsEnabled(not IsReady)
			self.BtnReady:SetButtonText(IsReady and LSTR(1320094) or LSTR(1320095))
		end) },

		{ "Model", 				UIBinderValueChangedCallback.New(self, nil, function(_, Mode)
			local Icon = PWorldQuestUtil.GetSceneModeIcon(Mode) or ""
			local Name = PWorldQuestUtil.GetSceneModeName(Mode) or ""
			UIUtil.ImageSetBrushFromAssetPath(self.FinderSlot.ImgIcon, Icon, false, true, true)
			self.TextType:SetText(Name)
			-- if string.isnilorempty(Icon) then
			-- 	UIUtil.SetIsVisible(self.PanelFinder, false)
			-- end

			self.bShowModeIcon = not string.isnilorempty(Icon)
			self:UpdateShowMode()
		end) },
		{ "IsRand", UIBinderSetIsVisible.New(self, self.PanelTitle, true)},

		{ "IsMem4",        		UIBinderSetIsVisible.New(self, self.VerticaBoxMember, false) },
		{ "IsMem4",        		UIBinderSetIsVisible.New(self, self.VerticaBoxMember_1, true) },
		{ "IsPVP",       	UIBinderSetIsVisible.New(self, self.PanelPVPMember) },
		{ "IsPVP",        		UIBinderSetIsVisible.New(self, self.PanelNonPVPMember, true) },
		{ "TypeID", UIBinderValueChangedCallback.New(self, nil, self.OnTypeIDChanged) },
	}

	self.BtnRefuse:SetText(_G.LSTR(1320150))
	self.BtnKeep:SetText(_G.LSTR(1320151))
	self.BtnReady:SetText(_G.LSTR(1320152))
	self.BtnTransform:SetText(_G.LSTR(1320199))
	self.TextMatchFailed:SetText(_G.LSTR(1320212))
end

function PWorldTeamConfirmPanelView:OnShow()
	AudioUtil.LoadAndPlayUISound(self.SoundEvent_Enter:ToString())
	self.CountDownSoundPlayingID = AudioUtil.SyncLoadAndPlayUISound(self.SoundEvent_CountDown:ToString())

	-- inflate animation goes first
	if self.Params and self.Params.bFromSidebar then
		self:PlayAnimation(self.AnimShowAgain)
	else
		self:PlayAnimation(self.AnimShowFirst)
	end
	
	self:UpdateVoteProgressAnimation()

	local bPrettyHard = PWorldEntUtil.IsPrettyHardPWorld(_G.PWorldVoteMgr:GetEnterSceneID())
	UIUtil.SetIsVisible(self.PanelNoRewardsTips, bPrettyHard)
	if bPrettyHard then
		local Count = _G.PWorldVoteMgr:GetWeeklyRewardUnpickedCount()
		local Text
		if Count >= 8 then
			Text = _G.LSTR(1320223)
		elseif Count >= 4 then
			Text = _G.LSTR(1320224)
		else
			Text = _G.LSTR(1320225)
		end
		
		self.RichTextNoRewards:SetText(Text)
	end

	---发送副本确认界面打开的消息
	_G.EventMgr:SendEvent(_G.EventID.EnterLevelConfirmView)
end

function PWorldTeamConfirmPanelView:OnHide()
	if nil ~= self.CountDownSoundPlayingID then
		AudioUtil.StopSound(self.CountDownSoundPlayingID)
		self.CountDownSoundPlayingID = nil
	end

	if self:IsModuleMagicCardTourney() then
		--幻卡大赛对局匹配确认侧边栏
		if self.Params and self.Params.FoldUpCallBack then
			self.Params.FoldUpCallBack()
		end
	else
		_G.PWorldVoteMgr:SetVoteConfirmSidebarVisible(_G.PWorldVoteMgr:IsVoteEnterScenePending())
		_G.PWorldMatchMgr:TryResumeSideBar()
	end
	
	_G.SidebarMgr:TryOpenSidebarMainWin()
end

function PWorldTeamConfirmPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.AppEnterForeground, self.UpdateVoteProgressAnimation)
end

---@private
function PWorldTeamConfirmPanelView:UpdateVoteProgressAnimation()
	local Duration = 0
	local Pct = 0
	local StartTime = 0
	if self:IsModuleMagicCardTourney() then
		--幻卡大赛对局匹配确认倒计时
		Duration = self.Params.Duration
		StartTime = self.Params.StartTime
	else
		StartTime = PWorldVoteMgr:GetEnterSceneStartTime()
		Duration = PWorldVoteMgr:GetEnterSceneDuration()
		PWorldVoteVM:UpdMems()
	end
	
	Pct = math.clamp(((_G.TimeUtil.GetServerTime() - StartTime) / Duration) , 0, 1) 
	local AnimTime = self.AnimProgress:GetEndTime()
	local PlaySpeed = AnimTime / Duration
	local AnimPlayStartTime = Pct * AnimTime
	self:PlayAnimation(self.AnimProgress, AnimPlayStartTime, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed)

	local RemainSecs = Duration * (1 - Pct)
	if RemainSecs > 0 then
		if self.TimerIDVoteTimeOut then
			self:UnRegisterTimer(self.TimerIDVoteTimeOut)
		end
		self.TimerIDVoteTimeOut = self:RegisterTimer(function (_, VoteID)
			_G.PWorldVoteMgr:MarkTimeoutAndTip(VoteID) 
		end, RemainSecs + 2, 0, 1, _G.PWorldVoteMgr:GetEnterSceneVoteID())
	end
end

function PWorldTeamConfirmPanelView:OnActive()
	AudioUtil.LoadAndPlayUISound(self.SoundEvent_Enter:ToString())
end

function PWorldTeamConfirmPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse.Button, 	self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnReady.Button, 		self.OnClickButtonOK)
	UIUtil.AddOnClickedEvent(self, self.BtnKeep.Button, 		self.OnClickButtonRetain)
	UIUtil.AddOnClickedEvent(self, self.BtnTransform.Button, 	self.OnClickSwitchProf)
end

function PWorldTeamConfirmPanelView:OnRegisterBinder()
	self:UnRegisterAllBinder()
	
	if self:IsModuleMagicCardTourney() then
		--幻卡大赛对局匹配确认
		self:RegisterBinders(MagicCardTourneyVM, self.Binders)
		self:RegisterBinders(MagicCardTourneyVM, {
			{ "MatchMemberVMs", 		UIBinderUpdateBindableList.New(self, MagicCardTourneyVM.MatchMemberVMs:Length() <= 4 and self.AdaMem4 or self.AdaMem8) },
		})
	else
		--副本确认
		self:RegisterBinders(PWorldVoteVM, self.Binders)

		if not PWorldVoteVM.IsPVP then
			self:RegisterBinders(PWorldVoteVM, {
				{ "VoteMemberVMs", 		UIBinderUpdateBindableList.New(self, PWorldVoteVM.VoteMemberVMs:Length() <= 4 and self.AdaMem4 or self.AdaMem8) },
			})
		else
			if PWorldVoteVM.IsCrystalline then
				self:RegisterBinders(PWorldVoteVM, {
					{ "VoteMemberVMs", 		UIBinderUpdateBindableList.New(self, self.AdaCrystalline) },
				})
			end
		end

		local MajorVM = MajorUtil.GetMajorRoleVM()
		-- 绑定玩家职业，和参加记录的职业对比，是否显示更换职业
		self:RegisterBinders(MajorVM, self.MajorBinders) 
	end
end

function PWorldTeamConfirmPanelView:OnClickButtonCancel()
	if self:IsModuleMagicCardTourney() then
		if self.Params and self.Params.CancelCallBack then
			self.Params.CancelCallBack()
		end
	else
		PWorldVoteMgr:ReqVoteEnterPWorld(false)
	end
end

function PWorldTeamConfirmPanelView:OnClickButtonOK()
	if self:IsModuleMagicCardTourney() then
		if self.Params and self.Params.ConfirmCallBack then
			self.Params.ConfirmCallBack()
		end
	else
		PWorldVoteMgr:ReqVoteEnterPWorld(true)
	end
end

function PWorldTeamConfirmPanelView:OnClickButtonRetain()
	self:Hide()
end

function PWorldTeamConfirmPanelView:OnClickSwitchProf()
	local MajorInfo = PWorldVoteMgr:GetEnterSceneMajorInfo(true)
	if MajorInfo then
		local Prof = MajorInfo.Prof
		if Prof then
			_G.ProfMgr:SwitchProfByID(Prof)
			self:ShowSwitchProfEff()
		end
	end
end

function PWorldTeamConfirmPanelView:GetTeamStatusText(Num)
	if Num == 1 then
		return LSTR(1320096)
	end

	if Num == 4 then
		return LSTR(1320097)
	end

	if Num == 8 then
		return LSTR(1320098)
	end

	return LSTR(1320099)
end

function PWorldTeamConfirmPanelView:ShowSwitchProfEff()
	if self.TimerHdl then
		return
	end

	local MajorInfo = PWorldVoteMgr:GetEnterSceneMajorInfo(true)
	local Cache = self.ProfCache
	if Cache then
		local PreIcon = ProfUtil.Prof2Icon(Cache.Prof) or ""
		UIUtil.ImageSetBrushFromAssetPath(self.CurrentJobSlot.ImgJob, PreIcon)
		local PreName = ProfUtil.Prof2Name(Cache.Prof) or ""
		self.TextCurrentJob:SetText(PreName)
		self.CurrentJobSlot.TextLevel:SetText(Cache.Level or "")

		local CurIcon = ProfUtil.Prof2Icon(MajorInfo.Prof) or ""
		UIUtil.ImageSetBrushFromAssetPath(self.AfterJobSlot.ImgJob, CurIcon)
		local CurName = ProfUtil.Prof2Name(MajorInfo.Prof) or ""
		self.TextAfterJob:SetText(CurName)
		self.AfterJobSlot.TextLevel:SetText(MajorInfo.Level or "")
	end

	UIUtil.SetIsVisible(self.PanelTransformTips, true)
	self:PlayAnimation(self.AnimChangeJob)

	self.TimerHdl = self:RegisterTimer(function()
		UIUtil.SetIsVisible(self.PanelTransformTips, false)
		self.TimerHdl = nil
	end, 1.5)
end

---@type 是否幻卡大赛模块复用
function PWorldTeamConfirmPanelView:IsModuleMagicCardTourney()
	return self.Params and self.Params.ModuleID == ProtoCommon.ModuleID.ModuleIDFantasyCard
end

--- 有些模式不需要等级右边的模式，要等级居中，在这里处理
function PWorldTeamConfirmPanelView:OnTypeIDChanged(NewValue, OldValue)
	-- if NewValue == nil or NewValue == 0 then return end

	-- if PWorldEntUtil.IsCrystalline(NewValue) then
	-- 	UIUtil.SetIsVisible(self.PanelFinder, false)
	-- 	return
	-- end
	-- if NewValue == ProtoCommon.ScenePoolType.ScenePoolTreasureHuntBabyLibrary then
	-- 	UIUtil.SetIsVisible(self.PanelFinder, false)
	-- 	return
	-- end

	self.bShowModeByType = self:IsTypeShowMode(NewValue)
	self:UpdateShowMode()
end

function PWorldTeamConfirmPanelView:IsTypeShowMode(TypeID)
	if PWorldEntUtil.IsCrystalline(TypeID) then
		return false
	end

	if TypeID == ProtoCommon.ScenePoolType.ScenePoolTreasureHuntBabyLibrary then
		return false
	end

	return true
end

function PWorldTeamConfirmPanelView:UpdateShowMode()
	local bFlag = (self.bShowModeByType == false or self.bShowModeIcon == false)
	UIUtil.SetIsVisible(self.PanelFinder, not bFlag)
end

return PWorldTeamConfirmPanelView