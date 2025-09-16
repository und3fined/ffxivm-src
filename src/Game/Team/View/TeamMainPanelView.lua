--[[
Author: xingcaicao
Date: 2023-05-08 16:59
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-01-02 14:16:57
FilePath: \Script\Game\Team\View\TeamMainPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamVM = require("Game/Team/VM/TeamVM")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")

local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local TeamMgr = require("Game/Team/TeamMgr")
local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local ModuleType = TeamDefine.ModuleType

local LSTR = _G.LSTR

local function ShowNoFuncTipsPWorld()
	_G.MsgTipsUtil.ShowTips(string.format(LSTR(1300011)))
end

-------------------------------------------------------------------------------------------------------
---@see 小队和副本小队显示策略

--#TODO DELETE
---@class APol
---@field TeamVM ATeamVM
local APol = LuaClass()

function APol.OnClickTeamInvite(_)
	if not TeamMgr:CheckCanOpTeam(true) then
		return
	end

	UIViewMgr:ShowView(UIViewID.TeamInvite)
end

--- OnClickTeamQuit
---@param ParentView TeamMainPanelView
function APol.OnClickTeamQuit(ParentView)
	if not _G.TeamMgr:CheckCanOpTeam(true) then
		return
	end

	if _G.TeamMgr:IsCaptain() then
		MsgBoxUtil.ShowMsgBoxThreeOp(
			ParentView, 
			LSTR(640047), --退出队伍
			LSTR(640048), --确认要退出小队吗？
			ParentView.DestroyTeam, 
			ParentView.LeaveTeam, 
			nil, 
			LSTR(10003), 
			LSTR(10010), 
			LSTR(10012))
	else
		MsgBoxUtil.ShowMsgBoxTwoOp(
			ParentView, 
			LSTR(640047), --退出队伍
			LSTR(640048), --确认要退出小队吗？
			ParentView.LeaveTeam, 
			nil, 
			LSTR(10003), 
			LSTR(10010))
	end
end

--- OnClickMic
---@param ParentView TeamMainPanelView
---@param AnchorWidget any
function APol.OnClickMic(ParentView, AnchorWidget)
	local TeamVoiceMgr = _G.TeamVoiceMgr

	local IsOn = not TeamVoiceMgr:IsCurMicOn()
	if IsOn and not TeamVoiceMgr:IsCurVoiceOn() then
		ParentView:ShowChatTips(LSTR(1300021), AnchorWidget)
		return
	end

	if IsOn then
		if not TeamVoiceMgr:UIOpenMic() then
			return 
		end
	else
		TeamVoiceMgr:UICloseMic()
	end

	ParentView:ShowChatTips(IsOn and LSTR(1300022) or LSTR(1300023), AnchorWidget)
end

--- OnClickVoice
---@param ParentView TeamMainPanelView
---@param AnchorWidget any
function APol.OnClickVoice(ParentView, AnchorWidget)
	local bShouldOn = not _G.TeamVoiceMgr:IsCurVoiceOn()
	local Tip
	if bShouldOn then
		if _G.TeamVoiceMgr:UIOpenSpeaker() then
			Tip = LSTR(1300024)
		end
	else
		_G.TeamVoiceMgr:UICloseSpeaker()
		Tip = LSTR(1300025)
	end

	if Tip then
		ParentView:ShowChatTips(Tip, AnchorWidget)
	end
end

--- OnClickTab
---@param ParentView TeamMainPanelView
---@param Index any
function APol.OnClickTab(ParentView, Index)
	local ModuleInfo = ParentView.ModuleVMList:Get(Index)
	if nil == ModuleInfo then
		return
	end

	local Type = ModuleInfo.Type
	if Type == ModuleType.Team then
		ParentView:SetTeamInfo()

	elseif Type == ModuleType.Recruit then
		ParentView:SetRecruitInfo()
	end
end

-- #TODO REFINE OR DELETE
local TeamPol = LuaClass(APol)

function TeamPol:Reset()
	self.TeamVM = _G.TeamVM
end

-- #TODO REFINE OR DELETE
local PWorldTeamPol = LuaClass(APol)

function PWorldTeamPol:Reset()
	self.TeamVM = _G.PWorldTeamVM
end

function PWorldTeamPol.OnClickTeamInvite(_)
	ShowNoFuncTipsPWorld()
end

function PWorldTeamPol.OnClickTeamQuit(_)
	ShowNoFuncTipsPWorld()
end

---@class TeamMainPanelView : UIView
---@field PolTy APol
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AttrIconFar UFImage
---@field AttrIconHealth UFImage
---@field AttrIconMagic UFImage
---@field AttrIconNear UFImage
---@field AttrIconTank UFImage
---@field Bkg CommonBkg01View
---@field BtnClose CommonCloseBtnView
---@field BtnInvite CommBtnLView
---@field BtnMic UFButton
---@field BtnQuitTeam UFButton
---@field BtnRefreshRecruitList UFButton
---@field BtnScreener CommScreenerBtnView
---@field BtnSearch UFButton
---@field BtnStartRecruit CommBtnLView
---@field BtnUpdateRecruit CommBtnLView
---@field BtnVoice UFButton
---@field ChatMsg CommChatMsgPanelView
---@field CommInforBtn CommInforBtnView
---@field CommSingleBox CommSingleBoxView
---@field CommTabs CommTabsView
---@field CommTabsModule CommVerIconTabsView
---@field CommonTitle CommonTitleView
---@field IconJob UFImage
---@field IconMicOff UFImage
---@field IconMicOn UFImage
---@field IconVoiceOff UFImage
---@field IconVoiceOn UFImage
---@field ImgBody UFImage
---@field ImgBodyArrow UFImage
---@field ImgClass UFImage
---@field ImgTitleBg UFImage
---@field ImgTitleBg2 UFImage
---@field PanelBtns UFCanvasPanel
---@field PanelListEmpty UFCanvasPanel
---@field PanelRecruit UFCanvasPanel
---@field PanelTeam UFCanvasPanel
---@field RichTextBuff URichTextBox
---@field RichTextJob URichTextBox
---@field RichTextLevel URichTextBox
---@field TableViewMember UTableView
---@field TableViewRecruitList UTableView
---@field TextChatTips UFTextBlock
---@field TextListEmpty UFTextBlock
---@field AnimEmptyIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimPanelIn1 UWidgetAnimation
---@field AnimPanelIn2 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamMainPanelView = LuaClass(UIView, true)

function TeamMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AttrIconFar = nil
	--self.AttrIconHealth = nil
	--self.AttrIconMagic = nil
	--self.AttrIconNear = nil
	--self.AttrIconTank = nil
	--self.Bkg = nil
	--self.BtnClose = nil
	--self.BtnInvite = nil
	--self.BtnMic = nil
	--self.BtnQuitTeam = nil
	--self.BtnRefreshRecruitList = nil
	--self.BtnScreener = nil
	--self.BtnSearch = nil
	--self.BtnStartRecruit = nil
	--self.BtnUpdateRecruit = nil
	--self.BtnVoice = nil
	--self.ChatMsg = nil
	--self.CommInforBtn = nil
	--self.CommSingleBox = nil
	--self.CommTabs = nil
	--self.CommTabsModule = nil
	--self.CommonTitle = nil
	--self.IconJob = nil
	--self.IconMicOff = nil
	--self.IconMicOn = nil
	--self.IconVoiceOff = nil
	--self.IconVoiceOn = nil
	--self.ImgBody = nil
	--self.ImgBodyArrow = nil
	--self.ImgClass = nil
	--self.ImgTitleBg = nil
	--self.ImgTitleBg2 = nil
	--self.PanelBtns = nil
	--self.PanelListEmpty = nil
	--self.PanelRecruit = nil
	--self.PanelTeam = nil
	--self.RichTextBuff = nil
	--self.RichTextJob = nil
	--self.RichTextLevel = nil
	--self.TableViewMember = nil
	--self.TableViewRecruitList = nil
	--self.TextChatTips = nil
	--self.TextListEmpty = nil
	--self.AnimEmptyIn = nil
	--self.AnimIn = nil
	--self.AnimPanelIn1 = nil
	--self.AnimPanelIn2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnInvite)
	self:AddSubView(self.BtnScreener)
	self:AddSubView(self.BtnStartRecruit)
	self:AddSubView(self.BtnUpdateRecruit)
	self:AddSubView(self.ChatMsg)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommSingleBox)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.CommTabsModule)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamMainPanelView:OnPostInit()
	self.TableAdapterMember = UIAdapterTableView.CreateAdapter(self, self.TableViewMember)
	self.TableAdapterRecruitList = UIAdapterTableView.CreateAdapter(self, self.TableViewRecruitList)

	self:SetPolType(TeamPol)

	local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
	self.BinderShowVoicePanel = UIBinderSetIsVisiblePred.NewByPred(function()
		if self.PolTy and self.PolTy.TeamVM then
			return self.PolTy.TeamVM.IsTeam and (self.PolTy.TeamVM.MemberNumber or 0) > 1
		end
	end, self, self.PanelBtns)
	self.TeamBinders =  {
		{ "ClassTypeTank", 		UIBinderSetIsVisible.New(self, self.AttrIconTank) },
		{ "ClassTypeHealth", 	UIBinderSetIsVisible.New(self, self.AttrIconHealth) },
		{ "ClassTypeNear", 		UIBinderSetIsVisible.New(self, self.AttrIconNear) },
		{ "ClassTypeFar", 		UIBinderSetIsVisible.New(self, self.AttrIconFar) },
		{ "ClassTypeMagic", 	UIBinderSetIsVisible.New(self, self.AttrIconMagic) },
		-- { "IsCanOpInvite", 		UIBinderSetIsVisible.New(self, self.BtnInvite, nil, true) },
		{ "MemberSimpleVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterMember) },
		{ "IsTeam", 			UIBinderValueChangedCallback.New(self, nil, self.OnIsTeamChanged) },
		{ "ClassTypeNum", 		UIBinderValueChangedCallback.New(self, nil, self.OnClassTypeNumChanged) },
		{ "MemberNumber", 		UIBinderValueChangedCallback.New(self, nil, self.OnMemberNumberChanged) },
		{ "IsOnVoice", 			UIBinderSetIsVisible.New(self, self.IconVoiceOff, true) },
		{ "IsOnVoice", 			UIBinderSetIsVisible.New(self, self.IconVoiceOn) },
		{ "IsOnMic", 			UIBinderSetIsVisible.New(self, self.IconMicOn) },
		{ "IsOnMic", 			UIBinderSetIsVisible.New(self, self.IconMicOff, true) },

		-- panel voice
		{ "MemberNumber", 		self.BinderShowVoicePanel},
		{ "IsTeam", 			self.BinderShowVoicePanel},
	}

	self.RecruiteBinders = {
		{ "IsRecruiting", 			UIBinderValueChangedCallback.New(self, nil, self.OnIsRecruitingChanged) },
		{ "IsRecruiting", 	UIBinderSetIsVisible.New(self, self.BtnStartRecruit, true, true) },
		{ "IsRecruiting", 	UIBinderSetIsVisible.New(self, self.BtnUpdateRecruit, false, true) },
		{ "ViewingRecruitItemVMList", 		UIBinderUpdateBindableList.New(self, self.TableAdapterRecruitList) },
		{ "IsRecruitListEmpty", 	UIBinderValueChangedCallback.New(self, nil, self.OnShowEmpty)},
		{ "TeamRecruitTypeVMList", 	UIBinderUpdateBindableList.New(self, self.CommTabsModule.AdapterTabs) },
		{ "CurSelectRecruitType", UIBinderValueChangedCallback.New(self, nil, self.UpdateSubTitle)},
		{ "bEnableConcreteFilter", UIBinderValueChangedCallback.New(self, nil, self.OnConcreteFilterChanged)}
	}

	self.MajorVMBinders = {
		{ "EquipScore", 	UIBinderSetText.New(self, self.RichTextLevel)},
		{ "Prof", 	   		UIBinderSetProfIcon.New(self, self.IconJob) },
		{ "Level",			UIBinderValueChangedCallback.New(self, nil, self.UpdateProfInfo)},
		{ "Prof",			UIBinderValueChangedCallback.New(self, nil, self.UpdateProfInfo)},
	}

	local function OnSelectChanged(_, ItemData)
		if ItemData then
			self:SetRecruitType(ItemData.TypeID)
		end
	end
	self.CommTabsModule.OnSelectionChanged:Clear()
	self.CommTabsModule.OnSelectionChanged:Add(self, OnSelectChanged)

	self.CommTabs:SetCallBack(self, self.OnSelectionChangedTabs)

	self.CommSingleBox:SetStateChangedCallback(self, self.OnFilterStateChanged)

	self.BtnStartRecruit:SetText(_G.LSTR(1310052))
end

function TeamMainPanelView:OnShow()
	self.TextChatTips:SetText("")
	self.ModuleVMList = self.PolTy.TeamVM.ModuleVMList
	self.BtnInvite:SetText(LSTR(1300026))
	self.CommSingleBox:SetText(_G.LSTR(1310107))

	if self.TextListEmpty then
		self.TextListEmpty:SetText(LSTR(1310051))
	end

	TeamRecruitVM:ClearFilter()

	self:OnChangeBtnOpenState()

	local TabIdx = 1 
	if self.Params then
		--模块类型
		local Type = self.Params.ModuleType
		if Type then
			local _, Idx = self.ModuleVMList:Find(function(e) return e.Type == Type end)
			TabIdx = Idx or 1
		end

		--默认招募类型
		if Type == TeamDefine.ModuleType.Recruit then
			self.DefaultRecruitType = self.Params.RecruitType or TeamRecruitMgr:GetRecruitingTypeID()
			TeamRecruitVM:SetPreSelectTask(self.Params.PreSelectTask)
			self:SetRecruitInfo()
		end
	end

	if self.Params == nil then
		self.Params = {}
	end
	self.Params.CommTabIndex = TabIdx
	self.CommTabs:UpdateItems({ 
		{ IconPathNormal = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_TeamNormal_png.UI_Team_Icon_TeamNormal_png'", 
		IconPathSelect = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_TeamSelect_png.UI_Team_Icon_TeamSelect_png'" }, 
		{ IconPathNormal = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_RecruitNormal_png.UI_Team_Icon_RecruitNormal_png'", 
		IconPathSelect = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_RecruitSelect_png.UI_Team_Icon_RecruitSelect_png'" } },
		 TabIdx)

	self:UpdPol()
	self:UpdateSubTitle()

	-- 查询工会信息
	local QueryList = TeamMgr:GetMemberRoleIDList()
	if table.empty(QueryList) then
		table.insert(QueryList, MajorUtil.GetMajorRoleID())
	end

	_G.ArmyMgr:GetArmySimpleDataByRoleIDs(QueryList)

	_G.UIViewMgr:HideView(_G.UIViewID.TeamInvite)

	local RelationRoleIDs = _G.TeamRecruitMgr:GetRelationRoleIDs()
	_G.RoleInfoMgr:GetOnlineRolesAndUpdate(RelationRoleIDs, true)
end

function TeamMainPanelView:OnHide()
	self.DefaultRecruitType = nil
	TeamRecruitVM:SetPreSelectTask(nil)
	TeamRecruitVM:Clear()

	self:StopVoiceTipsTimerID()
	collectgarbage("collect")
end

function TeamMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommInforBtn.BtnInfor, self.OnClickedButtonHelp)
	UIUtil.AddOnClickedEvent(self, self.BtnQuitTeam, 			self.OnClickedButtonQuitTeam)
	UIUtil.AddOnClickedEvent(self, self.BtnInvite, 				self.OnClickedButtonInvite)
	UIUtil.AddOnClickedEvent(self, self.BtnVoice, 				self.OnClickedButtonVoice)
	UIUtil.AddOnClickedEvent(self, self.BtnMic, 				self.OnClickedButtonMic)

	UIUtil.AddOnClickedEvent(self, self.BtnRefreshRecruitList, 	self.OnClickedRefreshRecruitList)
	UIUtil.AddOnClickedEvent(self, self.BtnStartRecruit, 		self.OnClickedStartRecruit)
	UIUtil.AddOnClickedEvent(self, self.BtnUpdateRecruit, 		self.OnClickedUpdateRecruit)

	UIUtil.AddOnClickedEvent(self, self.BtnSearch, self.OnBtnSwitchClick)

	UIUtil.AddOnScrolledToEndEvent(self, self.TableViewRecruitList, self.OnRecruitListScollToEnd)
	UIUtil.AddOnScrollToFirstItemEvent(self, self.TableViewRecruitList, self.OnRecruitListScrollToFirst)

	self:RegisterUIEvent(self.TableViewRecruitList, "OnTableViewTouchEnd", self.OnRecruitListTouchEnd)
end

function TeamMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(_G.EventID.RecuitCreate, self.OnRecruitCreate)
	self:RegisterGameEvent(_G.EventID.TeamRecruitOnQueryData, self.OnQueryData)
end

function TeamMainPanelView:OnRegisterBinder()
	if not self.PolTy then
		_G.FLOG_ERROR("MainTeamPanelView:OnRegisterBinder self.PolTy = nil")
		return
	end

	self:RegisterBinders(self.PolTy.TeamVM, self.TeamBinders)
	self:RegisterBinders(TeamRecruitVM, self.RecruiteBinders)
	local VM = MajorUtil.GetMajorRoleVM(true)
	if VM then
		self:RegisterBinders(VM, self.MajorVMBinders)
	end
end

function TeamMainPanelView:OnMouseButtonDown(InGeometry, InTouchEvent)
	local MousePosition = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	if UIUtil.IsUnderLocation(self.BtnScreener, MousePosition) then
		if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.TeamRecruitFilter) and self.BtnScreener:GetVisibility() ~= _G.UE.ESlateVisibility.Collapsed then
			_G.UIViewMgr:ShowView(_G.UIViewID.TeamRecruitFilter, {RecruitType=TeamRecruitVM.CurSelectRecruitType})
		end
		return _G.UE.UWidgetBlueprintLibrary.Handled()
	end

	return _G.UE.UWidgetBlueprintLibrary.Unhandled()
end

function TeamMainPanelView:UpdateProfInfo()
	local RoleInitCfg = require("TableCfg/RoleInitCfg")
	local Name = RoleInitCfg:FindRoleInitProfName(MajorUtil.GetMajorProfID())
	self.RichTextJob:SetText(string.sformat("%d%s", MajorUtil.GetMajorLevel() or 0, Name))
end

function TeamMainPanelView:UpdPol()
	self:SetPolType(_G.PWorldMgr:CurrIsInDungeon() and PWorldTeamPol or TeamPol)
	self:UnRegisterAllBinder()
	self:OnRegisterBinder()
end

--- SetPolType
---@param Ty APol
function TeamMainPanelView:SetPolType(Ty)
	if self.PolTy == Ty then
		return
	end

	self.PolTy = Ty
	self.PolTy:Reset()
end

--副标题
function TeamMainPanelView:UpdateSubTitle()
	if self:GetCurSelectViewType() == ModuleType.Team then
		local Num = self.PolTy.TeamVM.MemberNumber
		if nil == Num or Num <= 1 then
			self.CommonTitle:SetTextSubtitle(LSTR(1300027))
		else
			local Fmt = "" 
			if Num < 4 then
				Fmt = LSTR(1300028)
			elseif Num >= 8 then
				Fmt = LSTR(1300029) 
			else
				Fmt = LSTR(1300030) 
			end

			self.CommonTitle:SetTextSubtitle(string.sformat(Fmt, Num))
		end
		self.CommonTitle:SetTextTitleName(LSTR(1300038))
		self.CommonTitle:SetTitleIcon("Texture2D'/Game/UI/Texture/Icon/Title/UI_Icon_Title_Team.UI_Icon_Title_Team'")
	elseif self:GetCurSelectViewType() == ModuleType.Recruit then
		local TeamRecruitTypeCfg = require("TableCfg/TeamRecruitTypeCfg")
		local RecruitSubTitle = (TeamRecruitTypeCfg:GetRecruitTypeInfo(TeamRecruitVM.CurSelectRecruitType) or {}).Name
		self.CommonTitle:SetTextSubtitle(RecruitSubTitle)
		self.CommonTitle:SetTextTitleName(LSTR(1300039))
		self.CommonTitle:SetTitleIcon("Texture2D'/Game/UI/Texture/Icon/Title/UI_Icon_Title_Recruit.UI_Icon_Title_Recruit'")
	end
end

function TeamMainPanelView:OnConcreteFilterChanged(V)
	self.BtnScreener:SetChecked(V == true)
end

-------------------------------------------------------------------------------------------------------
---队伍

function TeamMainPanelView:SetTeamInfo()
	self:UpdateSubTitle()

	--更新成员角色信息
	self.PolTy.TeamVM:UpdateMemberSimpleVMLisRoleInfo()

	UIUtil.SetIsVisible(self.PanelRecruit, false)
	UIUtil.SetIsVisible(self.PanelTeam, true)
end

function TeamMainPanelView:OnIsTeamChanged(IsInTeam)
	UIUtil.SetIsVisible(self.BtnQuitTeam, IsInTeam, true)
	UIUtil.SetIsVisible(self.BtnVoice, IsInTeam, true)
	UIUtil.SetIsVisible(self.BtnMic, IsInTeam, true)
end

function TeamMainPanelView:OnClassTypeNumChanged(Num)
	if nil == Num then
		return
	end

	local fmt = Num > 0 and LSTR(1300033) or LSTR(1300034)
	self.RichTextBuff:SetText(string.sformat(fmt, Num))
end

function TeamMainPanelView:OnMemberNumberChanged(Num)
	if self:GetCurSelectViewType() ~= ModuleType.Team then
		return
	end

	self:UpdateSubTitle()
end

function TeamMainPanelView:LeaveTeam()
	if not _G.TeamMgr:CheckCanOpTeam(true) then
		return
	end

	_G.TeamMgr:QuitTeamFromUI(self)
end

function TeamMainPanelView:DestroyTeam()
	if not _G.TeamMgr:CheckCanOpTeam(true) then
		return
	end

	_G.TeamMgr:DestroyTeamFromUI(self)
end

function TeamMainPanelView:StopVoiceTipsTimerID()
	local TimerID = self.VoiceTipsTimerID 
	if TimerID then
		self:UnRegisterTimer(TimerID)
		self.VoiceTipsTimerID = nil
	end
end

function TeamMainPanelView:ShowChatTips( TextTips, AnchorWidget )
	if string.isnilorempty(TextTips) then
		return
	end

	local Pos = UIUtil.CanvasSlotGetPosition(AnchorWidget)
	Pos.X = Pos.X + 40
	Pos.Y = Pos.Y - 32
	UIUtil.CanvasSlotSetPosition(self.TextChatTips, Pos)

	--提示文本
	self.TextChatTips:SetText(TextTips)

	local Params = {
		Anchor = AnchorWidget,
		Text = TextTips,
		Offset = {X = 40, Y = -32}
	}

	UIViewMgr:ShowView(UIViewID.SceneMarkersMainPanel, Params)
	self:StopVoiceTipsTimerID()
	self.VoiceTipsTimerID  = self:RegisterTimer(self.OnVoiceTipsTimer, 2)
end

function TeamMainPanelView:OnVoiceTipsTimer(  )
	self.TextChatTips:SetText("")
	self:StopVoiceTipsTimerID()
end

-------------------------------------------------------------------------------------------------------
---招募

function TeamMainPanelView:SetRecruitInfo()
	self:UpdateSubTitle()
	self:SetRecruitBtnState()

	--更新招募类型列表
	TeamRecruitVM:UpdateTeamRecruitTypeVMList()

	UIUtil.SetIsVisible(self.PanelTeam, false)
	UIUtil.SetIsVisible(self.PanelRecruit, true)

	local Idx = 1
	local RecruitType = self.DefaultRecruitType or TeamRecruitMgr:GetRecruitingTypeID()
	if RecruitType then
		Idx = TeamRecruitVM:GetTeamRecruitTypeVMListIdx(RecruitType)
	end
	self.CommTabsModule:SetSelectedIndex(Idx)
end

function TeamMainPanelView:OnIsRecruitingChanged()
	self.BtnUpdateRecruit:SetText(_G.LSTR(_G.TeamRecruitMgr:IsMajorRecruiting() and 1310096 or 1310053))

	if self:GetCurSelectViewType() == ModuleType.Recruit then
		self:UpdateSubTitle()
		self:SetRecruitBtnState()
	end
end

function TeamMainPanelView:SetRecruitBtnState()
	UIUtil.SetIsVisible(self.BtnStartRecruit, not TeamRecruitVM.IsRecruiting, true)
	UIUtil.SetIsVisible(self.BtnUpdateRecruit, TeamRecruitVM.IsRecruiting, true)
end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

-------------- 队伍

function TeamMainPanelView:OnSelectionChangedTabs( Index )
	if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDTeamRecruit) then
		self.PolTy.OnClickTab(self, Index)
		self:PlayAnimation(self.AnimPanelIn1)

		local function PlayGuide()
			local USaveMgr = _G.UE.USaveMgr
			if USaveMgr == nil then
				return
			end
			local SaveKey = require("Define/SaveKey")
			if USaveMgr.GetInt(SaveKey.RecruitNewGuideShow, 0, true) ~= 1 then
				USaveMgr.SetInt(SaveKey.RecruitNewGuideShow, 1, true)
				_G.TutorialGuideMgr:PlayGuide(76)
			end
		end
	
		if Index == 2 then
			PlayGuide()
		end
	else
		if Index == 2 and not _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDTeamRecruit) then
			self.CommTabs:SetSelectedIndex(1)
			return
		end
	end

	self.DefaultRecruitType = nil
end

function TeamMainPanelView:OnClickedButtonHelp()
	UIViewMgr:ShowView(UIViewID.TeamAttriAddInfor)
end

function TeamMainPanelView:OnClickedButtonQuitTeam()
	self.PolTy.OnClickTeamQuit(self)
end

function TeamMainPanelView:OnClickedButtonInvite()
	if PWorldEntUtil.GoToPWorldEntranceUI() then
		self:Hide()
	end
end

function TeamMainPanelView:OnClickedButtonVoice()
	self.PolTy.OnClickVoice(self, self.BtnVoice)
end

function TeamMainPanelView:OnClickedButtonMic()
	self.PolTy.OnClickMic(self, self.BtnMic)
end

-------------- 招募 

function TeamMainPanelView:OnClickedRefreshRecruitList()
	if self.LastRefreshTime and (os.time() - self.LastRefreshTime) <= 3 then
		MsgTipsUtil.ShowTipsByID(301034)
		return
	end

	self.LastRefreshTime = os.time()
	TeamRecruitMgr:UIRefreshCurrentRecruit()
end

function TeamMainPanelView:OnClickedStartRecruit()
    if TeamMgr:IsInTeam() and not TeamMgr:IsCaptain() then
		MsgTipsUtil.ShowTips(LSTR(1300035))
		return
    end

	if TeamVM:IsFullMember() then
		MsgTipsUtil.ShowTipsByID(301031)
		return
	end

	if _G.PWorldMgr:CurrIsInDungeon() then
		_G.MsgTipsUtil.ShowTipsByID(301024)
		return
	end

	if _G.TeamRecruitMgr:IsRecruiting() then
		_G.TeamRecruitMgr:OpenEditOwingRecruitView()
	else
		UIViewMgr:ShowView(UIViewID.TeamRecruitEdit)
	end
	
	_G.TeamRecruitVM:SetPreSelectTask(nil)
end

function TeamMainPanelView:OnClickedUpdateRecruit()
	if _G.TeamRecruitMgr:IsMajorRecruiting() then
		_G.TeamRecruitMgr:OpenEditOwingRecruitView()
	else
		_G.TeamRecruitMgr:OpenSelfRecruitDetailView({View=self, AnchorView=self.BtnUpdateRecruit})
	end
end

function TeamMainPanelView:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDTeamRecruit then
		self:OnChangeBtnOpenState()
		-- self.CommTabsModule:UpdateItems(self.ModuleVMList, 1)
	end
end

function TeamMainPanelView:OnRecruitCreate(Data)
	if self:GetCurSelectViewType() == ModuleType.Recruit and self:IsVisible() then
		local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
		local Cfg = TeamRecruitCfg:FindCfgByKey(Data.TaskID)
		if Cfg == nil then
			return
		end

		self.CommTabsModule:SelectIndexPredicate(function(Item)
			return Item.TypeID == Cfg.TypeID
		end)
	end
end

function TeamMainPanelView:OnQueryData(Offset)
	if Offset == 0 then
		self.TableAdapterRecruitList:ScrollToTop()
	end
end

function TeamMainPanelView:OnChangeBtnOpenState()
	self.ModuleVMList.Items[2].IsModuleOpen = not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDTeamRecruit)
end

function TeamMainPanelView:OnBtnSwitchClick()
	_G.UIViewMgr:ShowView(_G.UIViewID.ProfessionToggleJobTab)
end

function TeamMainPanelView:OnFilterStateChanged(bChecked)
	TeamRecruitVM:EnableFilter(TeamRecruitVM.CurSelectRecruitType, bChecked)
end

function TeamMainPanelView:OnRecruitListScollToEnd()
	_G.FLOG_INFO("TeamMainPanelView:OnRecruitListScollToEnd")
	TeamRecruitMgr:OnRecruitListScrollToEnd()
end

function TeamMainPanelView:OnRecruitListScrollToFirst()
	_G.FLOG_INFO("TeamMainPanelView:OnRecruitListScrollToFirst")
	TeamRecruitMgr:OnRecruitListScrollToTop()
end

function TeamMainPanelView:OnRecruitListTouchEnd()
	local Entries = self.TableAdapterRecruitList:GetDisplayedEntryWidgets()
	if Entries == nil or Entries:Length() <= 5 and (TeamRecruitVM.ViewingRecruitItemVMList == nil or #(TeamRecruitVM.ViewingRecruitItemVMList.Items) < 5) then
		if TeamRecruitMgr:IsCurOnRecruitLastPage() then
			_G.FLOG_INFO("TeamMainPanelView:OnRecruitListTouchEnd back")
			TeamRecruitMgr:TryScrollUp()
		end
	end
end

function TeamMainPanelView:SetRecruitType(TypeID)
	local bChanged = TypeID ~= TeamRecruitVM.CurSelectRecruitType
	TeamRecruitVM:SetCurSelectRecruitType(TypeID)
	TeamRecruitMgr:UIRefreshCurrentRecruit()
	self.CommSingleBox:SetChecked(TeamRecruitVM:IsEnableFilter(TypeID), true)
	self.TableAdapterRecruitList:SetSelectedIndex(nil)

	local bShowFilter = #(TeamRecruitVM:GetRecruitContentList(TypeID)) > 1
	self.BtnScreener:SetVisibility(bShowFilter and _G.UE.ESlateVisibility.HitTestInvisible or _G.UE.ESlateVisibility.Collapsed)
end

function TeamMainPanelView:GetCurSelectViewType()
	return self.CommTabs:GetSelectedIndex() or 1
end

function TeamMainPanelView:OnShowEmpty(bEmpty)
	UIUtil.SetIsVisible(self.PanelListEmpty, bEmpty)
	if bEmpty then
		self:PlayAnimation(self.AnimEmptyIn)
	end
end

return TeamMainPanelView