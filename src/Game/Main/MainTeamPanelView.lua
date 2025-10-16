---
--- Author: anypkvcai
--- DateTime: 2021-04-10 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local RollMgr = require("Game/Roll/RollMgr")
local UIViewMgr = require("UI/UIViewMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local ModuleOpenMgr = require("Game/ModuleOpen/ModuleOpenMgr")
local TeamVoiceMgr = require("Game/Team/TeamVoiceMgr")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local SignsMgr = require("Game/Signs/SignsMgr")
local SceneModeDef = ProtoCommon.SceneMode
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")
local CommonUtil = require("Utils/CommonUtil")
local FLinearColor = _G.UE.FLinearColor

local LSTR = _G.LSTR
---@deprecated
local TeamMgr = _G.TeamMgr
---@deprecated
local TeamRecruitVM = _G.TeamRecruitVM
local Checked = _G.UE.EToggleButtonState.Checked
local Tab = {
	Quest = 0,
	Team = 1,
	Card = 2,
	GameInfo = 3,
	Halloween = 4,
}

local ParentViewType = {
	Default = 1,
	Card = 2,
	GameInfo = 3,
	Halloween = 4,
}

local function ShowNoFuncTipsPWorld()
	_G.MsgTipsUtil.ShowTips(string.format(LSTR(1300011)))
end

-------------------------------------------------------------------------------------------------------
---@see 小队和副本小队显示策略

---@deprecated
---@class MainTeamShowPol
local MainTeamShowPol = LuaClass()

---@param View MainTeamPanelView
function MainTeamShowPol.OnClickTeamInvite(View)
	if not _G.TeamMgr:CheckCanOpTeam(true) then
		return
	end

	local TeamVM = View.PolTy.TeamVM
	if not TeamVM then
		return
	end

	if not TeamVM.IsCanOpInvite then
		_G.MsgTipsUtil.ShowTips(string.format(LSTR(1300012)))
		return
	end

	if TeamVM.bFull then
		_G.MsgTipsUtil.ShowTips(LSTR(1300013))
		return
	end

	UIViewMgr:ShowView(UIViewID.TeamInvite)
end

---@param View MainTeamPanelView
function MainTeamShowPol.OnClickTeamQuit(View)
	if not TeamMgr:CheckCanOpTeam(true) then
		return
	end

	if not TeamMgr:IsInTeam() then
		return
	end

	if View.LastOpQuitTime ~= nil and os.time() - View.LastOpQuitTime < 2 then
		_G.MsgTipsUtil.ShowTips(string.format(LSTR(1300014)))
		return
	end
	View.LastOpQuitTime = os.time()

    local strContent = LSTR(1300015) 
	if _G.TeamMgr:IsCaptain() then
		local Params = { MidBtnStyle = CommonBoxDefine.BtnStyleType.Yellow }
		MsgBoxUtil.ShowMsgBoxThreeOp(View, LSTR(1300017), strContent,
		View.DestroyTeam, View.LeaveTeam, nil, LSTR(1300018), LSTR(1300019), LSTR(1300020), Params)
	else
		MsgBoxUtil.ShowMsgBoxTwoOp(View, LSTR(1300002), strContent, View.LeaveTeam, nil, LSTR(1300018), LSTR(1300019), nil)
	end

	if _G.SignsMgr.SceneMarkersMainPanelIsShowing then
		_G.UIViewMgr:HideView(_G.UIViewID.SceneMarkersMainPanel)
	end
	if _G.SignsMgr.TargetSignsMainPanelIsShowing then
		_G.UIViewMgr:HideView(_G.UIViewID.TeamSignsMainPanel)
	end
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamRollPanel) then
		_G.UIViewMgr:HideView(_G.UIViewID.TeamRollPanel)
	end
end

---@param View MainTeamPanelView
function MainTeamShowPol.OnClickMic(View, Widget)
	local ShouldOn = not TeamVoiceMgr:IsCurMicOn()
	if ShouldOn and not TeamVoiceMgr:IsCurVoiceOn() then
		View:ShowChatTips(LSTR(1300021), Widget)
		CommonUtil.ReportTeamVoiceStatus(false)
		return
	end

	local bOpenMic = false
	if ShouldOn then
		bOpenMic = TeamVoiceMgr:UIOpenMic()
	else
		TeamVoiceMgr:UICloseMic()
	end
	CommonUtil.ReportTeamVoiceStatus(ShouldOn)
	View:ShowChatTips(bOpenMic and LSTR(1300022) or LSTR(1300023), Widget)
end

---@param View MainTeamPanelView
function MainTeamShowPol.OnClickVoice(View, Widget)
	local ShouldOn = not TeamVoiceMgr:IsCurVoiceOn()
	local Tip
	if ShouldOn then
		if TeamVoiceMgr:UIOpenSpeaker() then
			Tip = LSTR(1300024)
		end
	else
		TeamVoiceMgr:UICloseSpeaker()
		Tip = LSTR(1300025)
	end

	if Tip then
		View:ShowChatTips(Tip , Widget)
	end
end

---@deprecated
---@class TeamPol :  MainTeamShowPol
---@field TeamVM ATeamVM
local TeamPol = LuaClass(MainTeamShowPol)

function TeamPol:Reset()
	self.TeamVM = _G.TeamVM
end

---@class PWorldTeamPol :  MainTeamShowPol
local PWorldTeamPol = LuaClass(MainTeamShowPol)

function PWorldTeamPol:Reset()
	self.TeamVM = _G.PWorldTeamVM
end

function PWorldTeamPol.OnClickTeamInvite(self)
	ShowNoFuncTipsPWorld()
end

function PWorldTeamPol.OnClickTeamQuit(self)
	ShowNoFuncTipsPWorld()
end

---@class EntouragePol :  MainTeamShowPol
local EntouragePol = LuaClass(MainTeamShowPol)

function EntouragePol.OnClickTeamInvite(self)
	ShowNoFuncTipsPWorld()
end

function EntouragePol.OnClickTeamQuit(self)
	ShowNoFuncTipsPWorld()
end

function EntouragePol:Reset()
	self.TeamVM = _G.PWorldEntourageTeamVM
end

---@deprecated
local DefPol = {
	Team = TeamPol,
	PWorldTeam = PWorldTeamPol,
	EntourageTeam = EntouragePol,
}

---@class MainTeamPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AddBtn UFButton
---@field AddMemberBar UFWidgetSwitcher
---@field BtnAddMember UFButton
---@field BtnBeginsCD UFButton
---@field BtnCD UFButton
---@field BtnCheck UFButton
---@field BtnFold UToggleButton
---@field BtnInfo UFButton
---@field BtnInvite UFButton
---@field BtnMic UFButton
---@field BtnQuit UFButton
---@field BtnRecurit UFButton
---@field BtnScenMark UFButton
---@field BtnSceneMark UFButton
---@field BtnSigns UFButton
---@field BtnTargetSigns UFButton
---@field BtnVoice UFButton
---@field CardsStageInfo CardsStageInfoPanelView
---@field FunctionBar UFCanvasPanel
---@field HorizontalGold UFHorizontalBox
---@field HorizontalObtain UFHorizontalBox
---@field HorizontalObtain1 UFHorizontalBox
---@field HorizontalTitle UFHorizontalBox
---@field IconAddMember UFImage
---@field IconCheck UFImage
---@field IconCountDown UFImage
---@field IconGame UFImage
---@field IconInvite UFImage
---@field IconMicOff UFImage
---@field IconMicOn UFImage
---@field IconQuit UFImage
---@field IconRecruit UFImage
---@field IconScene UFImage
---@field IconTarget UFImage
---@field IconVoiceOff UFImage
---@field IconVoiceOn UFImage
---@field ImgArrow UFImage
---@field ImgCDOff UFImage
---@field ImgCDOn UFImage
---@field ImgCards UFImage
---@field ImgCardsSelect UFImage
---@field ImgCardsSelect_1 UFImage
---@field ImgCardsSelect_2 UFImage
---@field ImgCards_1 UFImage
---@field ImgCards_2 UFImage
---@field ImgPriceIcon UFImage
---@field ImgQuest UFImage
---@field ImgQuestSelect UFImage
---@field ImgSceneMarkDisabled UFImage
---@field ImgSceneMarkOff UFImage
---@field ImgSceneMarkOn UFImage
---@field ImgSignsOff UFImage
---@field ImgSignsOn UFImage
---@field ImgTeam UFImage
---@field ImgTeamSelect UFImage
---@field ImgTeamVoiceBg UFImage
---@field MI_DX_Common_GoldSaucer_4 UFImage
---@field MainQuestPanel MainQuestPanelView
---@field PWorldStageInfo PWorldStageInfoPanelView
---@field PanelAddMember UFCanvasPanel
---@field PanelChatTips UFCanvasPanel
---@field PanelCheck UFCanvasPanel
---@field PanelCountdown UFCanvasPanel
---@field PanelFunction UFCanvasPanel
---@field PanelGuide UFCanvasPanel
---@field PanelLeader UFCanvasPanel
---@field PanelMember UFCanvasPanel
---@field PanelQuestTeam UFCanvasPanel
---@field PanelQuit UFCanvasPanel
---@field PanelTeamVoice UFCanvasPanel
---@field RichTextClue URichTextBox
---@field RichTextTask URichTextBox
---@field SwitcherTab UFWidgetSwitcher
---@field SwitcherTeamStat UFWidgetSwitcher
---@field TableViewMember UTableView
---@field TableView_39 UTableView
---@field TeamStatInTeam UVerticalBox
---@field TeamStatOutTeam UVerticalBox
---@field TextAdd UFTextBlock
---@field TextAdding UFTextBlock
---@field TextBeginsCD UFTextBlock
---@field TextChatTips UFTextBlock
---@field TextExpand UFTextBlock
---@field TextGameName UFTextBlock
---@field TextGameName_1 UFTextBlock
---@field TextInvite UFTextBlock
---@field TextNumber UFTextBlock
---@field TextNumber1 UFTextBlock
---@field TextRecuritBarBtn UFTextBlock
---@field TextScenMark UFTextBlock
---@field TextTargetSigns UFTextBlock
---@field TextTeamNormal UFTextBlock
---@field TextTeamSelect UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnCards UToggleButton
---@field ToggleBtnGameInfo UToggleButton
---@field ToggleBtnHelloween UToggleButton
---@field ToggleBtnPackUp UToggleButton
---@field ToggleBtnQuest UToggleButton
---@field ToggleBtnTeam UToggleButton
---@field ToggleGroup UToggleGroup
---@field ToggleTeamNormal UFCanvasPanel
---@field ToggleTeamSelect UFCanvasPanel
---@field nforBtn CommInforBtnView
---@field AnimGuideLoop UWidgetAnimation
---@field AnimObtainNumberIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainTeamPanelView = LuaClass(UIView, true)


function MainTeamPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AddBtn = nil
	--self.AddMemberBar = nil
	--self.BtnAddMember = nil
	--self.BtnBeginsCD = nil
	--self.BtnCD = nil
	--self.BtnCheck = nil
	--self.BtnFold = nil
	--self.BtnInfo = nil
	--self.BtnInvite = nil
	--self.BtnMic = nil
	--self.BtnQuit = nil
	--self.BtnRecurit = nil
	--self.BtnScenMark = nil
	--self.BtnSceneMark = nil
	--self.BtnSigns = nil
	--self.BtnTargetSigns = nil
	--self.BtnVoice = nil
	--self.CardsStageInfo = nil
	--self.FunctionBar = nil
	--self.HorizontalGold = nil
	--self.HorizontalObtain = nil
	--self.HorizontalObtain1 = nil
	--self.HorizontalTitle = nil
	--self.IconAddMember = nil
	--self.IconCheck = nil
	--self.IconCountDown = nil
	--self.IconGame = nil
	--self.IconInvite = nil
	--self.IconMicOff = nil
	--self.IconMicOn = nil
	--self.IconQuit = nil
	--self.IconRecruit = nil
	--self.IconScene = nil
	--self.IconTarget = nil
	--self.IconVoiceOff = nil
	--self.IconVoiceOn = nil
	--self.ImgArrow = nil
	--self.ImgCDOff = nil
	--self.ImgCDOn = nil
	--self.ImgCards = nil
	--self.ImgCardsSelect = nil
	--self.ImgCardsSelect_1 = nil
	--self.ImgCardsSelect_2 = nil
	--self.ImgCards_1 = nil
	--self.ImgCards_2 = nil
	--self.ImgPriceIcon = nil
	--self.ImgQuest = nil
	--self.ImgQuestSelect = nil
	--self.ImgSceneMarkDisabled = nil
	--self.ImgSceneMarkOff = nil
	--self.ImgSceneMarkOn = nil
	--self.ImgSignsOff = nil
	--self.ImgSignsOn = nil
	--self.ImgTeam = nil
	--self.ImgTeamSelect = nil
	--self.ImgTeamVoiceBg = nil
	--self.MI_DX_Common_GoldSaucer_4 = nil
	--self.MainQuestPanel = nil
	--self.PWorldStageInfo = nil
	--self.PanelAddMember = nil
	--self.PanelChatTips = nil
	--self.PanelCheck = nil
	--self.PanelCountdown = nil
	--self.PanelFunction = nil
	--self.PanelGuide = nil
	--self.PanelLeader = nil
	--self.PanelMember = nil
	--self.PanelQuestTeam = nil
	--self.PanelQuit = nil
	--self.PanelTeamVoice = nil
	--self.RichTextClue = nil
	--self.RichTextTask = nil
	--self.SwitcherTab = nil
	--self.SwitcherTeamStat = nil
	--self.TableViewMember = nil
	--self.TableView_39 = nil
	--self.TeamStatInTeam = nil
	--self.TeamStatOutTeam = nil
	--self.TextAdd = nil
	--self.TextAdding = nil
	--self.TextBeginsCD = nil
	--self.TextChatTips = nil
	--self.TextExpand = nil
	--self.TextGameName = nil
	--self.TextGameName_1 = nil
	--self.TextInvite = nil
	--self.TextNumber = nil
	--self.TextNumber1 = nil
	--self.TextRecuritBarBtn = nil
	--self.TextScenMark = nil
	--self.TextTargetSigns = nil
	--self.TextTeamNormal = nil
	--self.TextTeamSelect = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.ToggleBtnCards = nil
	--self.ToggleBtnGameInfo = nil
	--self.ToggleBtnHelloween = nil
	--self.ToggleBtnPackUp = nil
	--self.ToggleBtnQuest = nil
	--self.ToggleBtnTeam = nil
	--self.ToggleGroup = nil
	--self.ToggleTeamNormal = nil
	--self.ToggleTeamSelect = nil
	--self.nforBtn = nil
	--self.AnimGuideLoop = nil
	--self.AnimObtainNumberIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.AdapterTableView = nil
end

function MainTeamPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CardsStageInfo)
	self:AddSubView(self.MainQuestPanel)
	self:AddSubView(self.PWorldStageInfo)
	self:AddSubView(self.nforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainTeamPanelView:OnPostInit()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewMember, nil, true, nil, true, true, true)
	self.ToggleBtnPackUp:SetChecked(true, true)

	self:SetPolType(DefPol.Team)
	self.AnimObtainNumberInCallBack = nil -- 小游戏面板奖励变化动画回调
	self.ParentViewType = ParentViewType.Default

	local function ToTeamNumberText(n)
		return tostring(n)
	end

	local function IsShowTeamNumberInfo(n)
		return (n or 0) > 1
	end

	local function IsTeamNumberFull(n)
		return n and n >= 8
	end

	local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
	local UIBinderSetImageBrushByResFunc = require("Binder/UIBinderSetImageBrushByResFunc")

	local BinderInviteIcon <const> = UIBinderSetImageBrushByResFunc.NewByResFunc(function()
		if _G.TeamRecruitMgr:IsRecruiting() then
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Btn_InviteShare_png.UI_Main_Team_Btn_InviteShare_png'"
		else
			if not self:IsCaptain() then
				return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Btn_InviteDisable_png.UI_Main_Team_Btn_InviteDisable_png'"
			end
		end

		return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Btn_Invite_png.UI_Main_Team_Btn_Invite_png'"
	end, self, self.IconAddMember)

	local BinderRecruitIcon <const> = UIBinderSetImageBrushByResFunc.NewByResFunc(function()
		if _G.TeamRecruitMgr:IsRecruiting() then
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Btn_OpenRecruit_png.UI_Main_Team_Btn_OpenRecruit_png'"
		else
			if self:IsCaptain() then
				return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Btn_Recruit_png.UI_Main_Team_Btn_Recruit_png'"
			end
		end

		return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Btn_RecruitDisable_png.UI_Main_Team_Btn_RecruitDisable_png'"
	end, self, self.IconCheck)

	self.BinderShowPanelVoice = UIBinderValueChangedCallback.New(self, nil, function()
		local bTeam = (self.PolTy and self.PolTy.TeamVM and self.PolTy.TeamVM.IsTeam)
		local bShow =  bTeam and self.ToggleBtnTeam:GetChecked() and self.ToggleBtnPackUp:GetChecked() and (self.PolTy.TeamVM.MemberNumber or 0) > 1 and self.PolTy ~= DefPol.EntourageTeam
		UIUtil.SetIsVisible(self.PanelTeamVoice, bShow, false, not self.ToggleBtnPackUp:GetChecked() and self.ToggleBtnTeam:GetChecked() and bTeam and self.PolTy ~= DefPol.EntourageTeam)
	end)

	local function IsShowInviteOrRecruit()
		return self:IsShowInviteOrRecruit()
	end

	self.InviteBtnBinder = UIBinderSetIsVisiblePred.NewByPred(IsShowInviteOrRecruit, self, self.BtnAddMember, false, true)
	self.RecruitBtnBinder = UIBinderSetIsVisiblePred.NewByPred(IsShowInviteOrRecruit, self, self.BtnCheck, false, true)

	self.TeamBinders = {
		{ "IsTeam", UIBinderSetActiveWidgetIndex.New(self, self.SwitcherTeamStat)},
		{ "IsTeam", UIBinderSetImageBrushByResFunc.NewByResFunc(function(V)
			if V then
				return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Tab_TeamNormal_png.UI_Main_Team_Tab_TeamNormal_png'"
			end
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Tab_NoTeamNormal_png.UI_Main_Team_Tab_NoTeamNormal_png'"
		end, self, self.ImgTeam)},
		{ "IsTeam", UIBinderSetImageBrushByResFunc.NewByResFunc(function(V)
			if V then
				return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Tab_TeamSelect_png.UI_Main_Team_Tab_TeamSelect_png'"
			end
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Tab_NoTeamSelect_png.UI_Main_Team_Tab_NoTeamSelect_png'"
		end, self, self.ImgTeamSelect)},
		{ "IsTeam", self.BinderShowPanelVoice},
		{ "IsTeam", UIBinderValueChangedCallback.New(self, nil,self.UpdateTeamTimer)},
		{ "MemberNumber", self.BinderShowPanelVoice},

		{ "BindableListMember", 			UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
		{ "FunctionBarVisible", 			UIBinderSetIsVisible.New(self, self.FunctionBar, false, true) },
		{ "FunctionBarVisible", 			UIBinderValueChangedCallback.New(self, nil, self.UpdateButtonFold)},
		{ "IsShowBtnBar", 					UIBinderSetIsVisible.New(self, self.PanelFunction) },

		{ "IsOnVoice", 			UIBinderSetIsVisible.New(self, self.IconVoiceOff, true) },
		{ "IsOnVoice", 			UIBinderSetIsVisible.New(self, self.IconVoiceOn) },
		{ "IsOnMic", 			UIBinderSetIsVisible.New(self, self.IconMicOff, true) },
		{ "IsOnMic", 			UIBinderSetIsVisible.New(self, self.IconMicOn) },
		{ "bFull", 				UIBinderValueChangedCallback.New(self, nil, self.OnTeamFull)},
		{ "MemberNumber", 		UIBinderSetText.New(self, self.TextTeamNormal, ToTeamNumberText)},
		{ "MemberNumber", 		UIBinderSetText.New(self, self.TextTeamSelect, ToTeamNumberText)},
		{ "MemberNumber", 		UIBinderSetIsVisiblePred.NewByPred(IsShowTeamNumberInfo, self, self.TextTeamNormal)},
		{ "MemberNumber", 		UIBinderSetIsVisiblePred.NewByPred(IsShowTeamNumberInfo, self, self.TextTeamSelect)},
		{ "MemberNumber", 		self.InviteBtnBinder},
		{ "MemberNumber", 		self.RecruitBtnBinder},
		{ "CaptainID",	BinderInviteIcon},
		{ "CaptainID",  BinderRecruitIcon},
	}

	self.RecruitBinders = {
		{ "IsRecruiting",  BinderInviteIcon},
		{ "IsRecruiting",  BinderRecruitIcon},
		{ "IsRecruiting",  UIBinderSetImageBrushByResFunc.NewByResFunc(function(V)
			if V then
				return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Invite2_png.UI_Main_Team_Icon_Invite2_png'"
			end
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Invite_png.UI_Main_Team_Icon_Invite_png'"
		end, self, self.IconInvite)},
		{ "IsRecruiting",  UIBinderSetImageBrushByResFunc.NewByResFunc(function(V)
			if V then
				return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Recruit2_png.UI_Main_Team_Icon_Recruit2_png'"
			end
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Icon_Recruit_png.UI_Main_Team_Icon_Recruit_png'"
		end, self, self.IconRecruit)},
		{ "IsRecruiting",  UIBinderSetText.New(self, self.TextInvite, function(V)
			return V and LSTR(1300069) or LSTR(1300050)
		end)},
		{ "IsRecruiting",  UIBinderSetText.New(self, self.TextRecuritBarBtn, function(V)
			return V and LSTR(1300070) or LSTR(1300051)
		end)},
	}

	self.MainBinders = {
		{ "QuestTrackVisible", UIBinderSetIsVisible.New(self, self.MainQuestPanel) },
		---{ "PWorldStageVisible", UIBinderSetIsVisible.New(self, self.PWorldStageInfo) },
		{ "bPackupToggleChecked", self.BinderShowPanelVoice},
	}

	self.PWorldTeamBinders = {
		{ "IsSupplementing", 		UIBinderSetActiveWidgetIndex.New(self, self.AddMemberBar) },
	}

	self.QuestBinders = {
		{ "IsShowSup", 				UIBinderSetIsVisible.New(self, self.AddMemberBar) },
	}

	-- text for button
	self.TextInvite:SetText(LSTR(1300050))
	self.TextRecuritBarBtn:SetText(LSTR(1300051))

	self.TextAdd:SetText(LSTR(1300052))
	self.TextAdding:SetText(LSTR(1300053))
end

function MainTeamPanelView:OnShow()
	self:OnChangeBtnOpenState()
	self:OnTeamBtnStateChanged()
	UIUtil.SetIsVisible(self.PanelChatTips, false)
	self.PrevToggleIdx = nil

	self:UpdateToggleBtnPackup()

	self:UpdPol()
	self:UpdateButtonFold()
	self:UpdateBPText_LocalStr()
end

--- 初始化Toggle可视状态
---@param ActiveTab Tab@Tab类型枚举
function MainTeamPanelView:InitToggleVisibleState(ActiveTab)
	UIUtil.SetIsVisible(self.ToggleBtnQuest, ActiveTab == Tab.Quest, true)
	UIUtil.SetIsVisible(self.ToggleBtnCards, ActiveTab == Tab.Card, true)
	UIUtil.SetIsVisible(self.ToggleBtnGameInfo, ActiveTab == Tab.GameInfo, true)
	UIUtil.SetIsVisible(self.ToggleBtnHelloween, ActiveTab == Tab.Halloween, true)
end

-- 显示卡片相关，包括卡片，组队
function MainTeamPanelView:SetShowCardMode()
	self.CardsStageInfo:OnShow()
	self.ToggleBtnCards:SetChecked(true, true)
	self:InitToggleVisibleState(Tab.Card)
	self:SwitchTab(Tab.Card)
	self.ParentViewType = ParentViewType.Card
end

-- 显示任务相关，包括任务， 组队
function MainTeamPanelView:SetShowQuest()
	self:InitToggleVisibleState(Tab.Quest)
	self.ToggleBtnCards:SetChecked(false, false)
	self.ToggleBtnQuest:SetChecked(true, true)
	self:SwitchTab(Tab.Quest)
end

-- 显示小游戏相关，包括GameInfo， 组队
function MainTeamPanelView:SetShowGameInfo()
	self:InitToggleVisibleState(Tab.GameInfo)
	self.ToggleBtnGameInfo:SetChecked(true, true)
	self.ToggleBtnTeam:SetChecked(false, false)
	self:SwitchTab(Tab.GameInfo)
	self.ParentViewType = ParentViewType.GameInfo
	self.ToggleGroup:SetCheckedIndex(2)

	UIUtil.SetIsVisible(self.ToggleTeamNormal, true)
	UIUtil.SetIsVisible(self.ToggleTeamSelect, false)
end

function MainTeamPanelView:SetShowHalloween()
	self:InitToggleVisibleState(Tab.Halloween)
	self.ToggleBtnHelloween:SetChecked(true, true)
	self.ToggleBtnTeam:SetChecked(false, false)
	self:SwitchTab(Tab.Halloween)
	self.ParentViewType = ParentViewType.Halloween
	self.ToggleGroup:SetCheckedIndex(3)

	UIUtil.SetIsVisible(self.ToggleTeamNormal, true)
	UIUtil.SetIsVisible(self.ToggleTeamSelect, false)
end

function MainTeamPanelView:OnHide()
	self:StopVoiceTipsTimerID()
end

function MainTeamPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnToggleButtonStateChanged)

	-- UIUtil.AddOnClickedEvent(self, self.RecruitingBtn, self.OnClickButtonRecruitDetail)

	UIUtil.AddOnClickedEvent(self, self.BtnRecurit,
	function()
		self:NavToRecruitView()
	end
)

	UIUtil.AddOnClickedEvent(self, self.BtnInvite, 			self.OnClickBtnInvite)
	UIUtil.AddOnClickedEvent(self, self.BtnAddMember, 		self.OnFuncBtnAddClick)

	UIUtil.AddOnClickedEvent(self, self.BtnQuit, 			self.OnClickBtnQuit)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, 			self.OnClickButtonMore)
	
	UIUtil.AddOnClickedEvent(self, self.BtnTargetSigns, 	self.OnClickBtnTargetSigns)
	UIUtil.AddOnClickedEvent(self, self.BtnSigns, 			self.OnClickBtnTargetSigns)
	
	UIUtil.AddOnClickedEvent(self, self.BtnScenMark, 		self.OnClickBtnScenMark)
	UIUtil.AddOnClickedEvent(self, self.BtnSceneMark, 		self.OnClickBtnScenMark)
	
	UIUtil.AddOnClickedEvent(self, self.BtnBeginsCD, 		self.OnClickBtnBeginsCD)
	UIUtil.AddOnClickedEvent(self, self.BtnCD, 				self.OnClickBtnBeginsCD)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroup, function()
		self.BinderShowPanelVoice:OnValueChanged()
	end)
	
	-- 对于在ToggleGroup里的ToggleBtn，OnStateChanged在区分状态变化上还有点问题
	-- 用OnClicked事件处理Tab切换需求，ToggleBtn的OnClicked会晚于OnStateChanged触发
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnQuest,
		function()
			if self.PrevToggleIdx == Tab.Quest then
				UIViewMgr:ShowView(UIViewID.QuestLogMainPanel)
			end
			self.PrevToggleIdx = nil
		end
	)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnTeam,
		function()
			if self.PrevToggleIdx == Tab.Team then
				UIViewMgr:ShowView(UIViewID.TeamMainPanel)
			end
			self.PrevToggleIdx = nil
		end
	)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnCards,
		function()
			if self.PrevToggleIdx == Tab.Card then
				UIViewMgr:ShowView(UIViewID.MagicCardRulePanelView)
			end
			self.PrevToggleIdx = nil
		end
	)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnGameInfo,
		function()
			if self.PrevToggleIdx == Tab.GameInfo then
				--UIViewMgr:ShowView(UIViewID.MagicCardRulePanelView)
			end
			self.PrevToggleIdx = nil
		end
	)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnHelloween, function() self.PrevToggleIdx = nil end)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnQuest,
		function(_, _, Stat)
			if Stat ~= Checked then return end
			self:SwitchTab(Tab.Quest)
		end
	)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnTeam,
		function(_, _, Stat)
			UIUtil.SetIsVisible(self.ToggleTeamNormal, Stat ~= Checked)
			UIUtil.SetIsVisible(self.ToggleTeamSelect, Stat == Checked)
			if Stat ~= Checked then return end
			self:SwitchTab(Tab.Team)
			UIViewMgr:HideView(UIViewID.TeamMenu)
		end
	)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnCards,
		function(_, _, Stat)
			if Stat ~= Checked then return end
			self:SwitchTab(Tab.Card)
		end
	)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnGameInfo,
		function(_, _, Stat)
			if Stat ~= Checked then return end
			self:SwitchTab(Tab.GameInfo)
		end
	)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnHelloween,
		function(_, _, Stat)
			if Stat ~= Checked then return end
			self:SwitchTab(Tab.Halloween)
		end
	)

	UIUtil.AddOnClickedEvent(self, self.AddBtn,
		function()
			if _G.PWorldQuestVM.CanSupplement then
				_G.UIViewMgr:ShowView(_G.UIViewID.PWorldAddMember)
			end
		end
	)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnPackUp,
		function(_, _, Stat)
			UIUtil.SetIsVisible(self.PanelQuestTeam , Stat == Checked)
			self:UpdateToggleBtnPackup()
		end
	)

	UIUtil.AddOnClickedEvent(self, self.BtnVoice, self.OnClickedButtonVoice)
	UIUtil.AddOnClickedEvent(self, self.BtnMic, self.OnClickedButtonMic)

end

function MainTeamPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, 				self.OnEveMapEnter)
	self:RegisterGameEvent(EventID.TargetChangeMajor, 			self.OnGameEventTargetChangeMajor)
	self:RegisterGameEvent(EventID.PWorldExit, 					self.OnPWorldExit)
	self:RegisterGameEvent(EventID.TeamRollItemSelectEvent, 	self.ShowTeamRollResult)
	self:RegisterGameEvent(EventID.RollExpireNotify, 			self.OnRollExpireNotify)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, 			self.OnModuleOpenNotify)
	self:RegisterGameEvent(EventID.ModuleOpenGMBtnEvent, 		self.OnChangeBtnOpenState)
	self:RegisterGameEvent(EventID.TeamBtnStateChanged, 		self.OnTeamBtnStateChanged)
	self:RegisterGameEvent(EventID.NetStateUpdate, 				self.OnCombatStateUpdate)
	self:RegisterGameEvent(EventID.SelectMainTeamPanelQuest,    self.OnSelectMainTeamPanelQuest)
	self:RegisterGameEvent(EventID.TeamMemberMicSyncStateChanged, self.OnMicSyncChanged)
end

function MainTeamPanelView:OnRegisterBinder()
	if not self.PolTy then
		_G.FLOG_ERROR("MainTeamPanelView:OnRegisterBinder self.PolTy = nil")
		return
	end

	self:RegisterBinders(self.PolTy.TeamVM, self.TeamBinders)
	self:RegisterBinders(TeamRecruitVM, self.RecruitBinders)
	self:RegisterBinders(MainPanelVM, self.MainBinders)

	do
		local IsInDoug = _G.PWorldMgr:CurrIsInDungeon()
		UIUtil.SetIsVisible(self.AddMemberBar, IsInDoug)
		if IsInDoug then
			self:RegisterBinders(_G.PWorldTeamVM, self.PWorldTeamBinders)
			self:RegisterBinders(_G.PWorldQuestVM, self.QuestBinders)
		end
	end
end

function MainTeamPanelView:OnRegisterTimer()
	self:RegisterTimer(function ()
		self.PolTy.TeamVM:UpdateMajorMicState()
	end, 0.2, 0.2, 0, nil)
end

function MainTeamPanelView:OnEveMapEnter()
	self:UpdPol()
end

function MainTeamPanelView:UpdPol()
	local IsDungeon = _G.PWorldMgr:CurrIsInDungeon()
	local Ty
	if IsDungeon then
		local Mode = _G.PWorldMgr:GetMode()
		if Mode == SceneModeDef.SceneModeStory then
			Ty = DefPol.EntourageTeam
		else
			Ty = DefPol.PWorldTeam
		end
	else
		Ty = DefPol.Team
	end
	self:SetPolType(Ty)
	self:UnRegisterAllBinder()
	self:OnRegisterBinder()

	if IsDungeon and ((_G.PWorldMgr:GetCurrPWorldTableCfg() or {}).MaxPlayerNum or 0) > 1 then
		self.ToggleGroup:SetCheckedIndex(4)
		self.PrevToggleIdx = Tab.Quest
	else
		local ParentType = self.ParentViewType
		if ParentType ~= ParentViewType.GameInfo and ParentType ~= ParentViewType.Card then
			self.PrevToggleIdx = nil
			self:SetShowQuest()
			self.PrevToggleIdx = nil
			self.ToggleGroup:SetCheckedIndex(0)
		end
	end
end

function MainTeamPanelView:SetPolType(Ty)
	if self.PolTy == Ty then
		return
	end

	---@deprecated
	self.PolTy = Ty
	self.PolTy:Reset()

	if self.RecruitBtnBinder then
		self.RecruitBtnBinder:OnValueChanged(self:IsShowInviteOrRecruit())
	end
	
	if self.InviteBtnBinder then
		self.InviteBtnBinder:OnValueChanged(self:IsShowInviteOrRecruit())
	end

	UIUtil.SetRenderOpacity(self.BtnQuit, Ty == DefPol.Team and 1 or 0.5)
end

function MainTeamPanelView:OnGameEventTargetChangeMajor(TargetID)
	if self.PolTy then
		self.PolTy.TeamVM:UpdateTarget(TargetID)
	end
end

function MainTeamPanelView:OnToggleButtonStateChanged()
	self.PolTy.TeamVM:ToggleFunctionBar()
end

function MainTeamPanelView:UpdateButtonFold()
	if self.PolTy.TeamVM.FunctionBarVisible then
		self.BtnFold:SetChecked(true, false)
	else
		self.BtnFold:SetChecked(false, false)
	end
end

function MainTeamPanelView:RegisterHalloweenBinder(ViewModel)
	if not self.HalloweenAdapterTableView then
		self.HalloweenAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_39)
	end
	if not self.HalloweenBinders then
		self.HalloweenBinders = {
			{ "Title",    				UIBinderSetText.New(self, self.TextTitle)},
			{ "TaskDesc",    			UIBinderSetText.New(self, self.RichTextTask)},
			{ "ClueTitle",    			UIBinderSetText.New(self, self.RichTextClue)},
			{ "ClueList",    			UIBinderUpdateBindableList.New(self, self.HalloweenAdapterTableView)},
		}
	end
	self:UnRegisterBinders(ViewModel, self.HalloweenBinders)
	self:RegisterBinders(ViewModel, self.HalloweenBinders)
end

function MainTeamPanelView:OnClickBtnInvite()
	self:InviteOrShare()
end

function MainTeamPanelView:InviteOrShare(...)
	if _G.TeamRecruitMgr:IsRecruiting() then
		UIViewMgr:ShowView(UIViewID.TeamInvite, {RecruitShare=true})
	else
		self.PolTy.OnClickTeamInvite(self)
	end
end

function MainTeamPanelView:OnFuncBtnAddClick()
	self:InviteOrShare()
end

function MainTeamPanelView:OnClickBtnQuit()
	self.PolTy.OnClickTeamQuit(self)
end

function MainTeamPanelView:OnClickButtonMore()
	self:NavToRecruitView()
end

function MainTeamPanelView:NavToRecruitView()
	if _G.PWorldMgr:CurrIsInDungeon() then
		_G.MsgTipsUtil.ShowTipsByID(301024)
		return
	end

	if not _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDTeamRecruit) then
		return
	end

	if _G.TeamRecruitMgr:IsRecruiting() then
		_G.TeamRecruitMgr:ShowRecruitDetailView(_G.TeamRecruitMgr.RecruitID, {bNoLimit=true})
	else
		local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	    TeamRecruitUtil.TryOpenTeamRecruitView(TeamRecruitDefine.DefaultRecruitType)
	end
end

function MainTeamPanelView:OnClickButtonRecruitDetail()
	--更新招募类型列表
	TeamRecruitVM:UpdateTeamRecruitTypeVMList()
	_G.TeamRecruitMgr:OpenSelfRecruitDetailView()
end

--- 目标标记点击回调
function MainTeamPanelView:OnClickBtnTargetSigns()
	SignsMgr:ShowTargetSignsPanel()
end

--- 场景标记点击回调
function MainTeamPanelView:OnClickBtnScenMark()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
    local bIsCombat = ActorUtil.IsCombatState(MajorEntityID)
	if bIsCombat then
		local MsgTipsUtil = require("Utils/MsgTipsUtil")
		MsgTipsUtil.ShowTipsByID(103049)
		return
	end
	SignsMgr:ShowSceneMarkersPanel()
end

--- 倒计时点击回调
function MainTeamPanelView:OnClickBtnBeginsCD()
	-- 狼狱停船场禁用
	if _G.PWorldMgr:CurrIsWolvesDenPierStage() then
		_G.MsgTipsUtil.ShowTipsByID(338038) -- 当前场景无法进行此操作
		return
	end
	
	local ServerTime = _G.TimeUtil.GetServerTimeMS()
	if ServerTime - SignsMgr.LastClickedCDTimeMS < 1000 then
		return
	end
	if SignsMgr.IsDuringCountDown then
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self, 
			LSTR(1240051), 	--- "终止倒计时"
			LSTR(1240052),	--- "确认终止战斗开始倒计时吗？"
			function()
				PWorldMgr:SendCountDown(0)
			end,
			nil,
			LSTR(1240011),	--- "取  消"
			LSTR(1240012)	--- "确  认"
		)
	else
		UIViewMgr:ShowView(UIViewID.TeamBeginsCDWin)
		SignsMgr.LastClickedCDTimeMS = ServerTime
	end
end

function MainTeamPanelView:OnTeamFull(bFull)
	self.BtnAddMember:SetBackgroundColor(bFull and FLinearColor(0.2,0.2,0.2,1.0) or FLinearColor(1, 1, 1, 1))
end

function MainTeamPanelView:OnPWorldExit()
	RollMgr.AwardMap = {}
end

function MainTeamPanelView:LeaveTeam()
	if not _G.TeamMgr:CheckCanOpTeam(true) then
		return
	end

	_G.TeamMgr:QuitTeamFromUI(self)
end

function MainTeamPanelView:DestroyTeam()
	if not _G.TeamMgr:CheckCanOpTeam(true) then
		return
	end

	_G.TeamMgr:DestroyTeamFromUI(self)
end

function MainTeamPanelView:SwitchTab(Idx)
	if self.PrevToggleIdx == nil then
		self.PrevToggleIdx = self.SwitcherTab:GetActiveWidgetIndex()
	end
	self.SwitcherTab:SetActiveWidgetIndex(Idx)
	self.CurTabIndex = Idx
	self:UpdateTeamTimer()
end

function MainTeamPanelView:UpdateTeamTimer()
	if self.TimerIDUpdateTeam then
		self:UnRegisterTimer(self.TimerIDUpdateTeam)
		self.TimerIDUpdateTeam = nil
	end
	local bShowTeam = self.CurTabIndex == Tab.Team and (self:GetTeamVM() or {}).IsTeam
	if bShowTeam then
		self.TimerIDUpdateTeam = self:RegisterTimer(function()
			local TeamVM = self:GetTeamVM()
			if TeamVM then
				TeamVM:OnTimerUpdate()
			end
		end, 0.2, 1, 0)
	end

	_G.FLOG_INFO("MainTeamPanelView:SwitchTab show team %s", bShowTeam)
end

function MainTeamPanelView:ShowTeamRollResult(Params)--是否在奖励品中切换
	self.PolTy.TeamVM:UpdateTeamRollResult(Params.AwardID, Params.IsSwitch, false, Params.AwardNotifyReslut, Params.TeamID) --MainTeamPanelVM.IsSwitch
end

-- 掉落物过期通知
function MainTeamPanelView:OnRollExpireNotify(Params)
	self.PolTy.TeamVM.ShowResults = nil

	self.PolTy.TeamVM:UpdateTeamRollResult(0, 0, true) --MainTeamPanelVM.IsSwitch
end

-------------------------------------------------------------------------------------------------------
---队伍语音

function MainTeamPanelView:StopVoiceTipsTimerID()
	local TimerID = self.VoiceTipsTimerID 
	if TimerID then
		self:UnRegisterTimer(TimerID)
		self.VoiceTipsTimerID = nil
	end
end

function MainTeamPanelView:ShowChatTips( TextTips, AnchorWidget )
	UIViewMgr:HideView(UIViewID.MainTeamChatTip)

	if string.isnilorempty(TextTips) then
		return
	end

	local Pos = UIUtil.CanvasSlotGetPosition(AnchorWidget)
	UIUtil.CanvasSlotSetPosition(self.PanelChatTips, Pos)
	
	--提示文本
	self.TextChatTips:SetText(TextTips)
	-- UIUtil.SetIsVisible(self.PanelChatTips, true)

	-- 
	local Params = {
		Anchor = AnchorWidget,
		Text = TextTips,
		Offset = {X = 90, Y = 15}
	}

	-- first uses a simple method 
	UIViewMgr:ShowView(UIViewID.MainTeamChatTip, Params)

	self:StopVoiceTipsTimerID()
	self.VoiceTipsTimerID  = self:RegisterTimer(self.OnVoiceTipsTimer, 2)
end

function MainTeamPanelView:OnVoiceTipsTimer(  )
	self.TextChatTips:SetText("")
	-- UIUtil.SetIsVisible(self.PanelChatTips, false)
	UIViewMgr:HideView(UIViewID.MainTeamChatTip)
	self:StopVoiceTipsTimerID()
end

function MainTeamPanelView:OnClickedButtonVoice()
	self.PolTy.OnClickVoice(self, self.BtnVoice)
end

function MainTeamPanelView:OnClickedButtonMic()
	self.PolTy.OnClickMic(self, self.BtnMic)
end

function MainTeamPanelView:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDTeamRecruit then
		self:OnChangeBtnOpenState()
	end
end

function MainTeamPanelView:OnChangeBtnOpenState()
	UIUtil.SetIsVisible(self.BtnRecurit, ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDTeamRecruit), true)
	
end

--管理场景标记、目标标记、倒计时按钮状态
function MainTeamPanelView:OnTeamBtnStateChanged()
	--目标标记
	UIUtil.SetIsVisible(self.BtnSigns, SignsMgr:GetIsEnableTargetMarker(), true)
	UIUtil.SetIsVisible(self.BtnTargetSigns, SignsMgr:GetIsEnableTargetMarker(), true)
	UIUtil.SetIsVisible(self.ImgSignsOn, SignsMgr.IsDuringTargetMarking)
	--场景标记
	UIUtil.SetIsVisible(self.BtnScenMark, SignsMgr:GetIsEnableSceneMarker(), true)
	UIUtil.SetIsVisible(self.BtnSceneMark, SignsMgr:GetIsEnableSceneMarker(), true)
	UIUtil.SetIsVisible(self.ImgSceneMarkOn, SignsMgr.IsDuringSceneMarking)
	-- 战斗状态下置灰
	--倒计时
	UIUtil.SetIsVisible(self.BtnBeginsCD, SignsMgr:GetIsEnableCountDown(), true)
	UIUtil.SetIsVisible(self.BtnCD, SignsMgr:GetIsEnableCountDown(), true)
	UIUtil.SetIsVisible(self.ImgCDOn, SignsMgr.IsDuringCountDown)
end

--- 赋值蓝图多语言文本
function MainTeamPanelView:UpdateBPText_LocalStr()
	self.TextTargetSigns:SetText(LSTR(1240019))	---	目标标记
	self.TextScenMark:SetText(LSTR(1240001))	---	场景标记
	self.TextBeginsCD:SetText(LSTR(1240043))	---	战斗开始倒计时
end

function MainTeamPanelView:OnCombatStateUpdate(Params)
	if MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local bIsCombat = ActorUtil.IsCombatState(MajorEntityID)
		UIUtil.SetIsVisible(self.ImgSceneMarkDisabled, bIsCombat)
		UIViewMgr:HideView(UIViewID.SceneMarkersMainPanel)
	end
end

function MainTeamPanelView:OnSelectMainTeamPanelQuest(Params)
	self.ToggleBtnPackUp:SetChecked(true, true)
	self.ToggleGroup:SetCheckedIndex(Tab.Quest)
	self.PrevToggleIdx = nil
end

function MainTeamPanelView:OnMicSyncChanged(_, RoleID, Value)
	if ((Value or 0) & 1) == 1 and not _G.TeamVoiceMgr:IsCurVoiceOn() and self.PolTy and self.PolTy.TeamVM then
		local Mgr = self.PolTy.TeamVM:GetOwnerMgr()
		if Mgr:IsTeamMemberByRoleID(RoleID) and RoleID ~= MajorUtil.GetMajorRoleID() then
			if self.LastTipOpenMicTeamID ~= Mgr:GetTeamID() then
				self.LastTipOpenMicTeamID = Mgr:GetTeamID()
				self:ShowChatTips(LSTR(1300067), self.BtnVoice)
				_G.MsgTipsUtil.ShowTipsByID(103100)
			end
		end
	end
end

--- 动画结束统一回调
function MainTeamPanelView:OnAnimationFinished(Animation)
	if Animation == self.AnimObtainNumberIn then
		local CallBack = self.AnimObtainNumberInCallBack
		if CallBack then
			CallBack()
			self.AnimObtainNumberInCallBack = nil
		end
	end
end

---@return ATeamMgr | nil
function MainTeamPanelView:GetTeamMgr()
	if self.PolTy then
		return self.PolTy.TeamVM:GetOwnerMgr()
	end
end

function MainTeamPanelView:IsCaptain()
	local Mgr = self:GetTeamMgr()
	return Mgr and Mgr:IsCaptain()
end

function MainTeamPanelView:UpdateToggleBtnPackup()
	MainPanelVM:SetPackupToggleChecked(self.ToggleBtnPackUp:GetChecked())
end

---@deprecated
function MainTeamPanelView:IsShowInviteOrRecruit()
	if not self.PolTy then
		return false
	end

	local TeamVM = self.PolTy.TeamVM
	if TeamVM == nil then
		return false
	end
	if TeamVM and TeamVM.MemberNumber >= 8 then
		return false
	end

	if TeamVM ~= _G.TeamVM then
		return false
	end

	return true
end

---@return ATeamVM | nil
function MainTeamPanelView:GetTeamVM()
	if self.PolTy then
		return self.PolTy.TeamVM
	end
	return nil
end

return MainTeamPanelView