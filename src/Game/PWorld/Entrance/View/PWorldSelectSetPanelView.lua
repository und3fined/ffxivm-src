---
--- Author: v_hggzhang
--- DateTime: 2022-11-25 10:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIViewID = require("Define/UIViewID")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")

local MsgTipsID = require("Define/MsgTipsID")
local TeamDefine = require("Game/Team/TeamDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")

local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
local ProfUtil = require("Game/Profession/ProfUtil")

---@type PWorldEntDetailVM
local PWorldEntDetailVM = nil

---@class PWorldSelectSetPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancelMatch CommBtnLView
---@field BtnClose CommBackBtnView
---@field BtnClose02 CommonCloseBtnView
---@field BtnCloseSetUp UFButton
---@field BtnDown UFButton
---@field BtnEquipmentUP UFButton
---@field BtnGoMentor UFButton
---@field BtnHelp CommInforBtnView
---@field BtnInfoTips UFButton
---@field BtnJoin CommBtnLView
---@field BtnLeveUP UFButton
---@field BtnMentorCondition UFButton
---@field BtnMentorTips UFButton
---@field BtnNavEntourage PWorldDetailsBtnItemView
---@field BtnNavExplore PWorldDetailsBtnItemView
---@field BtnNavMuren PWorldDetailsBtnItemView
---@field BtnNavRank PWorldDetailsBtnItemView
---@field BtnNavRecruit PWorldDetailsBtnItemView
---@field BtnNavTeam PWorldDetailsBtnItemView
---@field BtnToggle UFButton
---@field BtnToggle02 UFButton
---@field BtnUp UFButton
---@field ChocoboAvatar ChocoboRaceAvatarItemView
---@field CommCloseMaskBtn UFButton
---@field CommInforBtn CommInforBtnView
---@field CommonTitle CommonTitleView
---@field HorizontalExpected UFHorizontalBox
---@field HorizontalNoMentor UFHorizontalBox
---@field HorizontalTitle UFHorizontalBox
---@field HorizontalUnmet UFHorizontalBox
---@field IconTitle UFImage
---@field ImgBG UFImage
---@field ImgHighlyDifficultJob UFImage
---@field ImgJob UFImage
---@field ImgJob01 UFImage
---@field ImgJob02 UFImage
---@field ImgJob03 UFImage
---@field ImgLock_1 UFImage
---@field ImgLock_2 UFImage
---@field ImgLock_3 UFImage
---@field ImgLock_4 UFImage
---@field ImgLock_5 UFImage
---@field ImgLock_6 UFImage
---@field ImgSetUpBG UFImage
---@field ImgSetUpIcon UFImage
---@field ItemTipLoc UFImage
---@field PaneBan UFCanvasPanel
---@field PanelChocoboRace UFCanvasPanel
---@field PanelDescribeLong UFCanvasPanel
---@field PanelDescribeShort UFCanvasPanel
---@field PanelEquipmentClass UFCanvasPanel
---@field PanelEquipmentClass_2 UFCanvasPanel
---@field PanelExtraDescription UFCanvasPanel
---@field PanelHighlyDifficult UFCanvasPanel
---@field PanelIcon UFCanvasPanel
---@field PanelJoin UFCanvasPanel
---@field PanelLevelRequire UFCanvasPanel
---@field PanelLimitTime UFCanvasPanel
---@field PanelMemberRequire UFCanvasPanel
---@field PanelMentorTips UFCanvasPanel
---@field PanelQuickChocobo UFCanvasPanel
---@field PanelQuickJobToggle UFCanvasPanel
---@field PanelRewards UFCanvasPanel
---@field PanelTaskSet UFCanvasPanel
---@field PanelTaskSetUp UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelTopBtn UFCanvasPanel
---@field RankTips SavageRankTipsView
---@field RichTextEquipmentClass URichTextBox
---@field RichTextEquipmentClass_2 URichTextBox
---@field RichTextExtraDescription URichTextBox
---@field RichTextLevelRequire URichTextBox
---@field RichTextLimitTime URichTextBox
---@field RichTextMemberRequire URichTextBox
---@field RichTextMentorTips01 URichTextBox
---@field RichTextMentorTips02 URichTextBox
---@field RichTextRemainTime URichTextBox
---@field TableViewPWorlds UTableView
---@field TableViewRewards UTableView
---@field TableViewTasksetUp UTableView
---@field TextAmount01 UFTextBlock
---@field TextAmount02 UFTextBlock
---@field TextAmount03 UFTextBlock
---@field TextBan UFTextBlock
---@field TextChocoboLevel UFTextBlock
---@field TextChocoboName UFTextBlock
---@field TextClass UFTextBlock
---@field TextDescribeLong UFTextBlock
---@field TextDescribeShort UFTextBlock
---@field TextEquipmentClass UFTextBlock
---@field TextEquipmentClass_1 UFTextBlock
---@field TextEquipmentClass_2 UFTextBlock
---@field TextExpected UFTextBlock
---@field TextExpectedTime UFTextBlock
---@field TextFeatherNumber UFTextBlock
---@field TextForbid UFTextBlock
---@field TextHighlyDifficult UFTextBlock
---@field TextJobLevel UFTextBlock
---@field TextJobName UFTextBlock
---@field TextLevelRequire UFTextBlock
---@field TextLocalPlace UFTextBlock
---@field TextMemberRequire UFTextBlock
---@field TextMentorTips01 UFTextBlock
---@field TextMentorTips02 UFTextBlock
---@field TextNoMentor UFTextBlock
---@field TextPWorldName UFTextBlock
---@field TextPeopleAmount UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTaskSetUp UFTextBlock
---@field TextTitle UFTextBlock
---@field TipsTaskCondition PWorldInforTipsView
---@field ToggleBtnArrow UToggleButton
---@field VerticalPWorld UFVerticalBox
---@field AnimChangePWorld UWidgetAnimation
---@field AnimEffcetBtnLeveUP1 UWidgetAnimation
---@field AnimEffcetBtnLeveUP2 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimTaskSetChange UWidgetAnimation
---@field AnimTipsIn UWidgetAnimation
---@field AnimToggleBtnArrowChecked UWidgetAnimation
---@field AnimToggleBtnArrowUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldSelectSetPanelView = LuaClass(UIView, true)

function PWorldSelectSetPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancelMatch = nil
	--self.BtnClose = nil
	--self.BtnClose02 = nil
	--self.BtnCloseSetUp = nil
	--self.BtnDown = nil
	--self.BtnEquipmentUP = nil
	--self.BtnGoMentor = nil
	--self.BtnHelp = nil
	--self.BtnInfoTips = nil
	--self.BtnJoin = nil
	--self.BtnLeveUP = nil
	--self.BtnMentorCondition = nil
	--self.BtnMentorTips = nil
	--self.BtnNavEntourage = nil
	--self.BtnNavExplore = nil
	--self.BtnNavMuren = nil
	--self.BtnNavRank = nil
	--self.BtnNavRecruit = nil
	--self.BtnNavTeam = nil
	--self.BtnToggle = nil
	--self.BtnToggle02 = nil
	--self.BtnUp = nil
	--self.ChocoboAvatar = nil
	--self.CommCloseMaskBtn = nil
	--self.CommInforBtn = nil
	--self.CommonTitle = nil
	--self.HorizontalExpected = nil
	--self.HorizontalNoMentor = nil
	--self.HorizontalTitle = nil
	--self.HorizontalUnmet = nil
	--self.IconTitle = nil
	--self.ImgBG = nil
	--self.ImgHighlyDifficultJob = nil
	--self.ImgJob = nil
	--self.ImgJob01 = nil
	--self.ImgJob02 = nil
	--self.ImgJob03 = nil
	--self.ImgLock_1 = nil
	--self.ImgLock_2 = nil
	--self.ImgLock_3 = nil
	--self.ImgLock_4 = nil
	--self.ImgLock_5 = nil
	--self.ImgLock_6 = nil
	--self.ImgSetUpBG = nil
	--self.ImgSetUpIcon = nil
	--self.ItemTipLoc = nil
	--self.PaneBan = nil
	--self.PanelChocoboRace = nil
	--self.PanelDescribeLong = nil
	--self.PanelDescribeShort = nil
	--self.PanelEquipmentClass = nil
	--self.PanelEquipmentClass_2 = nil
	--self.PanelExtraDescription = nil
	--self.PanelHighlyDifficult = nil
	--self.PanelIcon = nil
	--self.PanelJoin = nil
	--self.PanelLevelRequire = nil
	--self.PanelLimitTime = nil
	--self.PanelMemberRequire = nil
	--self.PanelMentorTips = nil
	--self.PanelQuickChocobo = nil
	--self.PanelQuickJobToggle = nil
	--self.PanelRewards = nil
	--self.PanelTaskSet = nil
	--self.PanelTaskSetUp = nil
	--self.PanelTips = nil
	--self.PanelTopBtn = nil
	--self.RankTips = nil
	--self.RichTextEquipmentClass = nil
	--self.RichTextEquipmentClass_2 = nil
	--self.RichTextExtraDescription = nil
	--self.RichTextLevelRequire = nil
	--self.RichTextLimitTime = nil
	--self.RichTextMemberRequire = nil
	--self.RichTextMentorTips01 = nil
	--self.RichTextMentorTips02 = nil
	--self.RichTextRemainTime = nil
	--self.TableViewPWorlds = nil
	--self.TableViewRewards = nil
	--self.TableViewTasksetUp = nil
	--self.TextAmount01 = nil
	--self.TextAmount02 = nil
	--self.TextAmount03 = nil
	--self.TextBan = nil
	--self.TextChocoboLevel = nil
	--self.TextChocoboName = nil
	--self.TextClass = nil
	--self.TextDescribeLong = nil
	--self.TextDescribeShort = nil
	--self.TextEquipmentClass = nil
	--self.TextEquipmentClass_1 = nil
	--self.TextEquipmentClass_2 = nil
	--self.TextExpected = nil
	--self.TextExpectedTime = nil
	--self.TextFeatherNumber = nil
	--self.TextForbid = nil
	--self.TextHighlyDifficult = nil
	--self.TextJobLevel = nil
	--self.TextJobName = nil
	--self.TextLevelRequire = nil
	--self.TextLocalPlace = nil
	--self.TextMemberRequire = nil
	--self.TextMentorTips01 = nil
	--self.TextMentorTips02 = nil
	--self.TextNoMentor = nil
	--self.TextPWorldName = nil
	--self.TextPeopleAmount = nil
	--self.TextSubtitle = nil
	--self.TextTaskSetUp = nil
	--self.TextTitle = nil
	--self.TipsTaskCondition = nil
	--self.ToggleBtnArrow = nil
	--self.VerticalPWorld = nil
	--self.AnimChangePWorld = nil
	--self.AnimEffcetBtnLeveUP1 = nil
	--self.AnimEffcetBtnLeveUP2 = nil
	--self.AnimIn = nil
	--self.AnimTaskSetChange = nil
	--self.AnimTipsIn = nil
	--self.AnimToggleBtnArrowChecked = nil
	--self.AnimToggleBtnArrowUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldSelectSetPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancelMatch)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnClose02)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.BtnJoin)
	self:AddSubView(self.BtnNavEntourage)
	self:AddSubView(self.BtnNavExplore)
	self:AddSubView(self.BtnNavMuren)
	self:AddSubView(self.BtnNavRank)
	self:AddSubView(self.BtnNavRecruit)
	self:AddSubView(self.BtnNavTeam)
	self:AddSubView(self.ChocoboAvatar)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.RankTips)
	self:AddSubView(self.TipsTaskCondition)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldSelectSetPanelView:OnPostInit()
	PWorldEntDetailVM = _G.PWorldEntDetailVM
	self.AdpTableViewPWorlds = UIAdapterTableView.CreateAdapter(self, self.TableViewPWorlds, function(_, Idx, _)
		if Idx ~= PWorldEntDetailVM.CurEntIdx then
			self:PlayAnimation(self.AnimChangePWorld)
		end
		PWorldEntDetailVM:SeletectPWorldByIndex(Idx)
		self:ShowRankTips()
	end, true, false)

	self.AdpTableViewRewards = UIAdapterTableView.CreateAdapter(self, self.TableViewRewards, function(_, Idx, ItemVM, ItemView)
		PWorldEntDetailVM:SetSelectedRewardIdx(Idx)
		self:ShowRewardsDetail(ItemView, ItemVM)
	end, true, false)

	self.AdpTbVDifficulites = UIAdapterTableView.CreateAdapter(self, self.TableViewTasksetUp, function(_, _, VM)
		if VM.Op ~= PWorldEntDetailVM.TaskOp then
			self:PlayAnimation(self.AnimTaskSetChange)
			if VM.Op == 3 then
				MsgTipsUtil.ShowTipsByID(146063)
			end
		end
		PWorldEntDetailVM:SetTaskIdx(VM.Op)
		PWorldEntDetailVM:ToggleDifficultyCheckState()
	end, true, false)

	local UIBinderSetImageBrushByResFunc = require("Binder/UIBinderSetImageBrushByResFunc")

	self.BinderShowNavTeam = UIBinderSetIsVisiblePred.NewByPred(function()
		local TypeID = PWorldEntDetailVM.EntTy or 0
		if TypeID > 0 and TypeID < 5 then
			return _G.TeamRecruitMgr:IsRecruiting() or not _G.TeamMgr:IsInTeam() or _G.TeamMgr:IsCaptain()
		end
	end, self, self.BtnNavTeam)

	self.PWorldPreviewBinders = {
		-- 副本入口类型
		{ "EntTyName", 					UIBinderSetText.New(self, self.TextTitle) },
		{ "bShowSubTitle", UIBinderSetIsVisible.New(self, self.TextSubtitle)},
		{ "SubTitleText", UIBinderSetText.New(self, self.TextSubtitle)},
		{ "EntTyIcon", 					UIBinderSetBrushFromAssetPath.New(self, self.ImgPWorldType) },
		{ "PWorldEntList",    			UIBinderUpdateBindableList.New(self, self.AdpTableViewPWorlds) },
        { "CurEntIdx", 					UIBinderSetSelectedIndex.New(self, self.AdpTableViewPWorlds)},
		{ "EntTy", self.BinderShowNavTeam },

		-- 选中副本
		{ "PWorldName",      UIBinderSetText.New(self, self.TextPWorldName) },
		{ "PWorldSummary",   UIBinderSetText.New(self, self.TextDescribeShort) },
		{ "PWorldSummary",   UIBinderSetText.New(self, self.TextDescribeLong) },
		{ "PWorldExtraDesc",   UIBinderSetText.New(self, self.RichTextExtraDescription) },
		{ "RewardVMs",       UIBinderUpdateBindableList.New(self, self.AdpTableViewRewards) }, --战利品
		{ "bShowRewards",	UIBinderSetIsVisible.New(self, self.PanelRewards)},

		-- 选中副本玩家权限
		{ "BG",                    UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },

		-- 等级、装等、队员要求
		{ "LvReqDesc",  			UIBinderSetText.New(self, self.RichTextLevelRequire) },
		{ "EquipReqDesc",  			UIBinderSetText.New(self, self.RichTextEquipmentClass) },
		{ "bLimitProf", UIBinderSetIsVisible.New(self, self.ImgJob01)},
		{ "bLimitProf", UIBinderSetIsVisible.New(self, self.ImgJob02)},
		{ "bLimitProf", UIBinderSetIsVisible.New(self, self.ImgJob03)},
		{ "bLimitProf", UIBinderSetIsVisible.New(self, self.TextAmount01)},
		{ "bLimitProf", UIBinderSetIsVisible.New(self, self.TextAmount02)},
		{ "bLimitProf", UIBinderSetIsVisible.New(self, self.TextAmount03)},
		{ "MemNumReqDesc", UIBinderSetText.New(self, self.TextPeopleAmount)},
		{ "DefMemDesc", UIBinderSetText.New(self, self.TextAmount01)},
		{ "HelMemDesc", UIBinderSetText.New(self, self.TextAmount02)},
		{ "AtkMemDesc", UIBinderSetText.New(self, self.TextAmount03)},
		{"bPassTeamNum", UIBinderSetIsVisible.New(self, self.ImgLock_4, true, false, true)},
		{"bPassJoinLevel", UIBinderSetIsVisible.New(self, self.ImgLock_3, true, false, true)},
		{"bPassEquipLv", UIBinderSetIsVisible.New(self, self.ImgLock_2, true, false, true)},
		{"bPassJoinLevel", UIBinderSetIsVisible.New(self, self.BtnLeveUP, true, true, true)},
		{"bPassEquipLv", UIBinderSetIsVisible.New(self, self.BtnEquipmentUP, true, true, true)},
		{"bPassJoinLevel", UIBinderValueChangedCallback.New(self, nil, self.PlayAnimEffcetBtnLeveUP1)},
		{"bPassEquipLv", UIBinderValueChangedCallback.New(self, nil, self.PlayAnimEffcetBtnLeveUP2)},

		-- 木人相关
		{"bMuren",		UIBinderSetIsVisible.New(self, self.CommInforBtn)},
		{"bMuren",		UIBinderSetIsVisible.New(self, self.BtnClose02)},
		{"bMuren",		UIBinderSetIsVisible.New(self, self.BtnClose, true)},
		{"bMuren",			UIBinderSetIsVisible.New(self, self.ImgLock_5, true)},

		-- 描述正文文本
		{"bShortDesc", UIBinderSetIsVisible.New(self, self.PanelDescribeShort)},
		{"bShortDesc", UIBinderSetIsVisible.New(self, self.PanelExtraDescription)},
		{"bShortDesc", UIBinderSetIsVisible.New(self, self.PanelDescribeLong, true)},

		-- 选项
		{"DifficultyCheckState", UIBinderValueChangedCallback.New(self, nil, function(_, State)
			self.ToggleBtnArrow:SetCheckedState(State or _G.UE.EToggleButtonState.Checked)
		end)},
		{"bShowDifficultyDetail", UIBinderSetIsVisible.New(self, self.PanelTaskSet)},
		{"bShowDifficultyDetail", UIBinderSetIsVisible.New(self, self.BtnCloseSetUp, false, true)},
		{ "TaskType", UIBinderValueChangedCallback.New(self, nil, function(_, EntType)
			local Icon = PWorldQuestUtil.GetSceneModeIcon(EntType) or ""
			local Name = PWorldQuestUtil.GetSceneModeName(EntType) or ""
			UIUtil.ImageSetBrushFromAssetPath(self.ImgSetUpIcon, Icon, false, false)
			self.TextTaskSetUp:SetText(Name)
		end) },
		{"DifficultyVMs", UIBinderUpdateBindableList.New(self, self.AdpTbVDifficulites)},

		-- 子界面
		{ "bTextRewardsVisible", 		UIBinderSetIsVisible.New(self, self.TextRewards)},
		{ "IsJoinBtnVisible",       	UIBinderSetIsVisible.New(self, self.BtnJoin, nil, true) },
		{
			"IsPreCheckPass",	UIBinderValueChangedCallback.New(self, nil, function(_, Pass, Old)
				if Pass == false and Old ~= nil then
					MsgTipsUtil.ShowTips(_G.LSTR(1320006))
				end
				self:UpdateShowForbidText()
			end)
		},

		{ "JoinBtnText",        		UIBinderSetText.New(self, self.BtnJoin) },
		{ "ForbidText",        			UIBinderSetText.New(self, self.TextForbid) },

		{"IsTaskBtnVisible", UIBinderSetIsVisible.New(self, self.PanelTaskSetUp)},

		-- 通用关闭子界面遮罩
		{ "IsCommCloseMaskVisible",     UIBinderSetIsVisible.New(self, self.CommCloseMaskBtn, false, true) },
		{ "IsCommCloseMaskVisible", UIBinderValueChangedCallback.New(self, nil, function(_, Show)
			if Show then
				self:PlayAnimation(self.AnimTipsIn)
			end
		end)},

		-- 匹配/参加状态
		{ "IsShowCancelMatchBtn", 	UIBinderSetIsVisible.New(self, self.BtnCancelMatch) },
		{ "IsModePanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelSettingStatus) },
		{ "IsMatching", UIBinderSetIsVisible.New(self, self.HorizontalExpected)},
		{ "IsMatching", UIBinderValueChangedCallback.New(self, nil, self.UpdateShowForbidText)},
		{ "CurMatchEstTimeDesc", UIBinderSetText.New(self, self.TextExpectedTime)},
		{ "CancelText", UIBinderSetText.New(self, self.BtnCancelMatch)},

		-- 惩罚
		{ "HasPunished",       UIBinderSetIsVisible.New(self, self.PaneBan) },
		{ "PunishDesc", 		UIBinderSetText.New(self, self.TextBan)},

		-- 指导者
		{ "bShowDirectorUnReg", 		UIBinderSetIsVisible.New(self, self.HorizontalNoMentor) },
		{ "bShowNavDirectorTips", 		UIBinderSetIsVisible.New(self, self.PanelMentorTips) },
		{ "bShowDirectorUnReg",			UIBinderSetIsVisible.New(self, self.BtnInfoTips, false, true)},
		{ "bShowDirectorUnReg",			UIBinderValueChangedCallback.New(self, nil, function (_, V)
			 self:UpdateShowForbidText()
		end)},

		{ "bShowBtnRecruit", 	UIBinderSetIsVisible.New(self, self.BtnNavRecruit, false, true, true) },
		{ "bShowDirectorNavBtn", UIBinderSetIsVisible.New(self, self.BtnMentorCondition, false, true)},
		-- 剧情辅助器
		{ "IsShowBtnEncourage", 		UIBinderSetIsVisible.New(self, self.BtnNavEntourage, false, true, false) },
		-- 导航栏按钮
		{"bBtnStrategy", UIBinderSetIsVisible.New(self, self.BtnNavExplore, false, false)},
		{"bShowMurenButton", UIBinderSetIsVisible.New(self, self.BtnNavMuren, false, true)},
		-- 帮助界面
		{"HelpInfoID", UIBinderValueChangedCallback.New(self, nil, function(_, HelpInfoID)
			self.BtnHelp.HelpInfoID = HelpInfoID
			self.BtnHelp:OnShow()
			if PWorldEntDetailVM.bMuren then
				self.CommInforBtn.HelpInfoID = HelpInfoID
				self.CommInforBtn:OnShow()
			end
		end)},
		{ "bShowBtnHelp", UIBinderSetIsVisible.New(self, self.BtnHelp, false, true)},
		{ "EntTy", UIBinderValueChangedCallback.New(self, nil, function(_, NewValue)
			if NewValue == 1 or PWorldEntUtil.IsCrystalline(NewValue) or NewValue == ProtoCommon.ScenePoolType.ScenePoolChocobo  then
				self.BtnHelp:SetCallback(nil, nil)
			else
				self.BtnHelp:SetCallback(nil, function()
					_G.UIViewMgr:ShowView(_G.UIViewID.PWorldInfoWinPopUp, {HelpInfoID = self.BtnHelp.HelpInfoID, EntID= PWorldEntDetailVM.CurEntID})
				end)
			end
		end)},

		{ "IsShowVerticalPWorld", 					UIBinderSetIsVisible.New(self, self.VerticalPWorld)},
		{ "IsShowChocoboPanel", 					UIBinderSetIsVisible.New(self, self.PanelChocoboRace)},
		{ "ChocoboMatchRequirementDes",  			UIBinderSetText.New(self, self.RichTextEquipmentClass_2) },
		{ "IsShowChocoboMatchRequirementPrompt", 	UIBinderSetIsVisible.New(self, self.ImgLock_6)},


		{ "bShowBtnRank",                           UIBinderSetIsVisible.New(self, self.BtnNavRank, false, true)},
		{ "TitleIconPath", 								UIBinderSetBrushFromAssetPath.New(self, self.IconTitle) },
		

		---稀缺职业
		{ "LackProf", 	UIBinderSetIsVisiblePred.NewByPred(function(Value)
			return Value and Value ~= 0
		end, self, self.PanelHighlyDifficult)},
		{ "LackProf", UIBinderSetImageBrushByResFunc.NewByResFunc(ProfUtil.LackProfFunc2IconForMatch, self, self.ImgHighlyDifficultJob)},

		-- 参加条件
		{ "ExtraCondTitle", 	UIBinderSetText.New(self, self.TextEquipmentClass_1)},
		{ "ExtraCondDetail", 	UIBinderSetText.New(self, self.RichTextLimitTime)},
		{ "ExtraCondTitle",		UIBinderSetIsVisible.New(self, self.PanelLimitTime)},
	}

	self.RoleBinders = {
		{ "EquipScore",                   		UIBinderSetText.New(self, self.TextClass) },
		{ "Prof", 							 	UIBinderSetProfIcon.New(self, self.ImgJob) },
		{ "Prof", 								UIBinderSetProfName.New(self, self.TextJobName) },
		{ "Prof", 								UIBinderValueChangedCallback.New(self, nil, function()
			PWorldEntDetailVM:UpdateVM()
		end) },
		{ "Level", 								UIBinderSetText.New(self, self.TextJobLevel)},
	}

	self.ChocoboInfoBinders = {
		{ "FeatherRankStagesText", 			UIBinderSetText.New(self, self.TextFeatherNumber) },
		{ "Level",                   		UIBinderSetText.New(self, self.TextChocoboLevel) },
		{ "Name",                   		UIBinderSetText.New(self, self.TextChocoboName) },
		{ "Color", 							UIBinderSetColorAndOpacity.New(self, self.ChocoboAvatar.ImgColor) },
	}
	
	self.ChocoboPanelBinders = {
		{ "CurRaceEntryID", UIBinderValueChangedCallback.New(self, nil, self.OnChocoboRaceEntryIDValueChanged) },
	}
	self.RecruitBinders = {
		{ "IsRecruiting",  UIBinderValueChangedCallback.New(self, nil, function(_, Value)
			self.BtnNavTeam:SetIcon(Value and "PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_TeamInvite02_png.UI_PWorld_Btn_Details_TeamInvite02_png'" or
			 "PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_TeamInvite_png.UI_PWorld_Btn_Details_TeamInvite_png'")
			self.BtnNavTeam:SetText(_G.LSTR(Value and 1320240 or 1320239))
		end)},
		{ "IsRecruiting",  self.BinderShowNavTeam},
	}

	self.TeamBinders = {
		{"CaptainID",	self.BinderShowNavTeam},
		{"IsTeam",		self.BinderShowNavTeam},
	}

	self.BtnNavTeam:SetCallback(self.OnNavTeam, self)

	local LSTR = _G.LSTR
	-- Text
	self.TextMemberRequire:SetText(LSTR(1320139))
	self.TextLevelRequire:SetText(LSTR(1320140))
	self.TextEquipmentClass:SetText(LSTR(1320141))
	self.TextExpected:SetText(LSTR(1320145))
	self.RichTextRemainTime:SetText(LSTR(1320144))

	self.TextNoMentor:SetText(LSTR(1320128))
	self.TextMentorTips01:SetText(LSTR(1320131))
	self.RichTextMentorTips01:SetText(LSTR(1320132))
	self.RichTextMentorTips02:SetText(LSTR(1320133))
	self.TextMentorTips02:SetText(LSTR(1320134))
	self.TextLocalPlace:SetText(LSTR(1320201))

	self.TextHighlyDifficult:SetText(LSTR(1320219))

	-- nav button text
	self.BtnNavRank:SetText(LSTR(1320237))
	self.BtnNavExplore:SetText(LSTR(1320238))
	self.BtnNavRecruit:SetText(LSTR(1320241))
	self.BtnNavMuren:SetText(LSTR(1320242))
	self.BtnNavEntourage:SetText(LSTR(1320248))
end

function PWorldSelectSetPanelView:UpdateMatch()
	if _G.PWorldMatchMgr:IsMatching() then
		PWorldEntDetailVM:UpdateMatchTime()
	end
end

function PWorldSelectSetPanelView:UpdateLackProfs(NextUpdateTime)
	PWorldEntDetailVM:UpdateRewards()
	PWorldEntDetailVM:UpdateLackProf()

    if self.TimerIDUpdateLackProf then
       self:UnRegisterTimer(self.TimerIDUpdateLackProf)
    end

	local ServerTime = _G.TimeUtil.GetServerTime()
    local DelayTime = math.max(NextUpdateTime - ServerTime + 1, 5)
    self.TimerIDUpdateLackProf = self:RegisterTimer(function()
		_G.PWorldMatchMgr:BatchQueryLackProf(true)
	end, DelayTime, 300, 0)
end

function PWorldSelectSetPanelView:OnShow()
	self:InitConstInfo()
	PWorldEntDetailVM:OnShowEntranceView(self.Params)

	self.BtnNavRank:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_Rank_png.UI_PWorld_Btn_Details_Rank_png'")
	self.BtnNavExplore:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_Introduction_png.UI_PWorld_Btn_Details_Introduction_png'")
	self.BtnNavRecruit:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_Recurit_png.UI_PWorld_Btn_Details_Recurit_png'")
	self.BtnNavMuren:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_ActivatingSleep_png.UI_PWorld_Btn_Details_ActivatingSleep_png'")
	self.BtnNavEntourage:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_Entourage_png.UI_PWorld_Btn_Details_Entourage_png'")

	_G.PWorldMatchMgr:BatchQueryLackProf()
end

function PWorldSelectSetPanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	-- LSTR string: 要求说明
	self.TextEquipmentClass_2:SetText(_G.LSTR(430007))
end

function PWorldSelectSetPanelView:OnHide()
	PWorldEntDetailVM:OnHideEntranceView()
	if self.RankTimeID then
		self:UnRegisterTimer(self.RankTimeID) 
		self.RankTimeID = nil
		UIUtil.SetIsVisible(self.RankTips, false)
		_G.SavageRankMgr:SetTipsShowTime()
	end
end

function PWorldSelectSetPanelView:UpdateShowForbidText()
	local bShow = not PWorldEntDetailVM.IsPreCheckPass and not PWorldEntDetailVM.bShowDirectorUnReg and not PWorldEntDetailVM.IsMatching
	UIUtil.SetIsVisible(self.TextForbid, bShow)
end

local function GetMatchReqParams()
	local EntType = PWorldEntDetailVM.EntTy
	local EntID = PWorldEntDetailVM.CurEntID
	local Mode = PWorldEntDetailVM.TaskType
	local SubType = PWorldEntDetailVM.SubType
	return EntType, EntID, Mode, SubType
end

function PWorldSelectSetPanelView:OnRegisterUIEvent()
	self.BtnNavRecruit:SetCallback(self.OnClickedBtnRecurit, self)

	UIUtil.AddOnClickedEvent(self, self.BtnJoin, 		self.Join)
	UIUtil.AddOnClickedEvent(self, self.BtnCancelMatch, 	self.OnClickCancelMatch)

	UIUtil.AddOnClickedEvent(self, self.CommCloseMaskBtn, function()
		PWorldEntDetailVM:SetCommCloseMaskVisible(false)
		PWorldEntDetailVM.bShowNavDirectorTips = false
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnToggle, function()
		self:ShowProfSelect()
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnToggle02, function()
		if _G.PWorldMatchMgr:IsMatching() then
			-- LSTR string: 匹配中禁止切换出战陆行鸟
			MsgTipsUtil.ShowTips(_G.LSTR(420080))
			return
		end
		
		_G.UIViewMgr:ShowView(UIViewID.ChocoboExchangeRacerPageView)
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnClose.Button, function()
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.PWorldDirectorListPannel) then
			return
		end
		self:Hide()
	end)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnArrow, function()
		PWorldEntDetailVM:ToggleDifficultyCheckState()
	end)

	self.BtnNavEntourage:SetCallback(self.OnBtnEntourage, self)

	UIUtil.AddOnClickedEvent(self, self.BtnDown, function()
		PWorldEntDetailVM.bShortDesc = false
	end)
	UIUtil.AddOnClickedEvent(self, self.BtnUp, function()
		PWorldEntDetailVM.bShortDesc = true
	end)

	self.BtnNavMuren:SetCallback(function()
		PWorldEntDetailVM:SetSelectType(ProtoCommon.ScenePoolType.ScenePoolMuRen)
		self:PlayAnimIn()
		PWorldEntDetailVM:UpdateVM()
	end)

	self.BtnClose02:SetCallback(self.BtnClose02, function()
		PWorldEntDetailVM:SelecteLastEntType()
		self:PlayAnimIn()
		PWorldEntDetailVM:UpdateVM()
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnMentorCondition, function ()
		_G.UIViewMgr:ShowView(_G.UIViewID.PWorldDirectorListPannel)
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnGoMentor, function ()
		_G.WorldMapMgr:ShowWorldMapNpc(13006, 1017058)
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnInfoTips, function()
		PWorldEntDetailVM.bShowNavDirectorTips = not PWorldEntDetailVM.bShowNavDirectorTips
		if PWorldEntDetailVM.bShowNavDirectorTips then
			PWorldEntDetailVM:SetCommCloseMaskVisible(true)
		end
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnCloseSetUp, function ()
		PWorldEntDetailVM:ToggleDifficultyCheckState()
	end)

	self.BtnNavRank:SetCallback(function ()
		if self.RankTimeID then
			self:UnRegisterTimer(self.RankTimeID) 
			self.RankTimeID = nil
			UIUtil.SetIsVisible(self.RankTips, false)
			_G.SavageRankMgr:SetTipsShowTime()
		end
		_G.SavageRankMgr:OpenSavageRankMainPanel(PWorldEntDetailVM.CurEntID)
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnLeveUP, self.OnClickLeveUP)
	UIUtil.AddOnClickedEvent(self, self.BtnEquipmentUP, self.OnClickEquipmentUP)
end

function PWorldSelectSetPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PWorldEntourageViewClosed, self.OnEveEntourageClosed)
	self:RegisterGameEvent(_G.EventID.PWorldMatchTimeUpdate, self.UpdateMatch)
	self:RegisterGameEvent(_G.EventID.PWorldMatchLackProfUpd, self.UpdateLackProfs)
	self:RegisterGameEvent(_G.EventID.PWorldMapEnter,self.OnPWorldMapEnter)
	self:RegisterGameEvent(_G.EventID.PWorldUpdatePreCheck,self.OnPWorldUpdatePreCheck)
	self:RegisterGameEvent(_G.EventID.TeamUpdateMember, self.OnTeamMemberUpdate)
end

function PWorldSelectSetPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0, nil)

	self.TimerIDUpdateLackProf = self:RegisterTimer(function()
		_G.PWorldMatchMgr:BatchQueryLackProf(true)
	end, 2, 300, 0)
end

function PWorldSelectSetPanelView:OnTimer()
	PWorldEntDetailVM:RefreshRewards()
end

function PWorldSelectSetPanelView:OnEveEntourageClosed()
	self:PlayAnimIn()
end

function PWorldSelectSetPanelView:OnPWorldMapEnter()
	if _G.PWorldMgr:CurrIsInDungeon() then
        self:Hide()
    end
end

function PWorldSelectSetPanelView:OnRegisterBinder()
	self:RegisterBinders(PWorldEntDetailVM, self.PWorldPreviewBinders)

	local MajorVM = MajorUtil.GetMajorRoleVM(true)
	if MajorVM then
		self:RegisterBinders(MajorVM, self.RoleBinders)
	end

	self:RegisterBinders(_G.ChocoboMainVM, self.ChocoboPanelBinders)

	self:RegisterBinders(_G.TeamRecruitVM, self.RecruitBinders)
	self:RegisterBinders(_G.TeamVM, self.TeamBinders)
end

function PWorldSelectSetPanelView:OnChocoboRaceEntryIDValueChanged(NewValue, OldValue)
	if nil ~= OldValue and 0 ~= OldValue then
		local ViewModel = _G.ChocoboMainVM:FindChocoboVM(OldValue)
		if nil ~= ViewModel then
			self:UnRegisterBinders(ViewModel, self.ChocoboInfoBinders)
		end
	end

	if nil ~= NewValue and 0 ~= NewValue then
		local ViewModel = _G.ChocoboMainVM:FindChocoboVM(NewValue)
		if nil ~= ViewModel then
			self.ViewModel = ViewModel
			self:RegisterBinders(self.ViewModel, self.ChocoboInfoBinders)
		end
	end
end

function PWorldSelectSetPanelView:ShowRewardsDetail(ItemView, ItemVM)
	if ItemView then
		ItemTipsUtil.ShowTipsByResID(ItemVM.ID, ItemView)
	end
end

function PWorldSelectSetPanelView:ShowProfSelect()
	_G.UIViewMgr:ShowView(_G.UIViewID.ProfessionToggleJobTab)
end

function PWorldSelectSetPanelView:Join()
	if not PWorldEntDetailVM.IsJoinBtnEnable then
		if nil == PWorldEntDetailVM.PreCheckFailedReasons then
			print("attempt to index a nil value (field 'PreCheckFailedReasons')")
			return
		end
		local Params = {}
		Params.Prof = nil
		if false == PWorldEntDetailVM.PreCheckFailedReasons.IsPassMem then
			--生产职业提升途径暂不使用 5.2版本才考虑
			_G.MsgTipsUtil.ShowErrorTips(PWorldEntDetailVM.ForbidText)	--"职业不符，请切换战斗职业参加"
		elseif false == PWorldEntDetailVM.PreCheckFailedReasons.IsPassLv then
			--若战职等级不够 则打开职业等级提升途径界面
			Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_COMBAT
			EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params)
		elseif false == PWorldEntDetailVM.PreCheckFailedReasons.IsPassEquipLv then
			--若装备品级不够 则打开装备品级提升途径界面
			Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_EQUIP
			EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params)
		end
		return
	end

	if PWorldEntDetailVM.IsMatching then
		return
	end

	local IsInTeam = _G.TeamMgr:IsInTeam()
	if IsInTeam and not _G.TeamMgr:IsCaptain() and not PWorldEntDetailVM.bMuren then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchJoinOrCancelNoCaptain, nil)
		return
	end

	if PWorldEntDetailVM.bMuren and IsInTeam then
		_G.MsgTipsUtil.ShowErrorTips(_G.LSTR(1320001))
		return
	end

	if PWorldEntDetailVM.TaskType == PWorldQuestDefine.ClientSceneMode.SceneModeChocboRank then
		if IsInTeam then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchChocoboCannotInTeam)
			return
		end
	end

	if PWorldEntDetailVM.TaskType == PWorldQuestDefine.ClientSceneMode.SceneModeChocoboRoom then
		if not IsInTeam then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchChocoboMustInTeam)
			return
		end
	end

	if PWorldEntUtil.IsCrystalline(PWorldEntDetailVM.SubType) then
		local Policy = PWorldEntUtil.GetPol(nil, ProtoCommon.ScenePoolType.ScenePoolPVPCrystal)
		if Policy then
			if not Policy:CheckIsInEventTime() then
				MsgTipsUtil.ShowTipsByID(338045) -- 不在活动时间内无法匹配
				return
			end
		end
		if PWorldEntUtil.IsCrystallineExercise(PWorldEntDetailVM.SubType) or PWorldEntUtil.IsCrystallineRank(PWorldEntDetailVM.SubType) then
			if IsInTeam then
				MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldCrystallineInTeamBan)
				return
			end
		end
	end

	if PWorldEntDetailVM.EntTy ~= ProtoCommon.ScenePoolType.ScenePoolChocobo
			and PWorldEntDetailVM.EntTy ~= ProtoCommon.ScenePoolType.ScenePoolChocoboRandomTrack and _G.TeamRecruitMgr:IsRecruiting() then
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self ,_G.LSTR(1320230), _G.LSTR(1320002), self.JoinInner)
		return
	end

	self:JoinInner()
end

function PWorldSelectSetPanelView:OnClickCancelMatch()
	if _G.TeamMgr:IsInTeam() and not _G.TeamMgr:IsCaptain() then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchJoinOrCancelNoCaptain, nil)
		return
	end

	if PWorldEntDetailVM.IsMatching then
		local EntID = PWorldEntDetailVM.CurEntID
		local EntType = PWorldEntDetailVM.EntTy
		_G.PWorldMatchMgr:ReqCancelMatch(EntType, EntID)
	end
end

function PWorldSelectSetPanelView:JoinInner()
	if not PWorldEntDetailVM.IsPreCheckPass then
		_G.FLOG_ERROR("PWorldSelectSetPanelView:JoinInner IsPreCheckPass failed!")
		return
	end

	if _G.SidebarMgr:GetSidebarItemVM(SidebarDefine.SidebarType.PWorldEnterConfirm) or _G.UIViewMgr:FindVisibleView(_G.UIViewID.PWorldConfirm) ~= nil then
		_G.MsgTipsUtil.ShowTipsByID(146061)
		return
	end

	local Result = {select(1, PWorldEntUtil.JoinCheck())}
	if  Result[1] ~= true and Result[1] ~= nil then
		if type(Result[1]) == 'number' then
			MsgTipsUtil.ShowTipsByID(Result[1], table.unpack(Result, 2))
		else
			MsgTipsUtil.ShowTips(table.unpack(Result, 2))
		end
		return
	elseif type(Result[1]) == 'string' then
		MsgTipsUtil.ShowTips(table.unpack(Result))
		return
	end

	local EntType, EntID, Mode, SubType = GetMatchReqParams()
	if PWorldEntUtil.IsPrettyHardPWorld(EntID) and _G.TeamMgr:IsInTeam() then
		local CounterID = PWorldEntUtil.GetWeeklyRewardCounterID(EntID)
		if CounterID == nil then
			_G.FLOG_ERROR("can not find counter id for ent id %s", EntID)
			return
		end

		_G.TeamMgr:QueryTeamMemberCounters(CounterID, function(Data)
			if not _G.UIViewMgr:IsViewVisible(_G.UIViewID.PWorldEntranceSelectPanel) then
				return
			end

			if not _G.TeamMgr:IsInTeam() then
				return
			end

			if  PWorldEntUtil.IsWeeklyRewardNotMatch(Data)then
				_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(1320230), _G.LSTR(1320226), function()
					self:FinalJoin(EntID, EntType, Mode, SubType)
				end, nil, _G.LSTR(1320227), _G.LSTR(1320228))
				return
			end

			self:FinalJoin(EntID, EntType, Mode, SubType)
		end)
		return
	end

	self:FinalJoin(EntID, EntType, Mode, SubType)
end

function PWorldSelectSetPanelView:FinalJoin(EntID, EntTy, Mode, SubType)
	if	PWorldEntUtil.EnterTest() then
		if EntTy ~= ProtoCommon.ScenePoolType.ScenePoolMuRen then
			_G.PWorldVoteMgr:ReqStartVoteEnterPWorld(EntID, EntTy, Mode)
		else
			-- 单人本进入木人
			 local Cfg = require("TableCfg/SceneEnterCfg"):FindCfgByKey(EntID)
			_G.PWorldMgr:EnterSinglePWorld(Cfg and Cfg.SPID)
		end
	else
		local IsMatchOK, ErrCode = PWorldEntUtil.MatchCheck()
		if IsMatchOK then
			local IsChocoboRoom = Mode == PWorldQuestDefine.ClientSceneMode.SceneModeChocoboRoom
			if IsChocoboRoom then
				_G.PWorldVoteMgr:ReqStartVoteEnterChocoboRoom(EntID)
			else
				_G.PWorldMatchMgr:ReqStartMatch(EntTy, EntID, Mode, SubType)
			end
		else
			MsgTipsUtil.ShowTipsByID(ErrCode)
		end
	end
end

function PWorldSelectSetPanelView:OnClickedBtnRecurit()
	self:JumpToRecruite()
end

function PWorldSelectSetPanelView:JumpToRecruite() 
	local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
	local Cfg = TeamRecruitCfg:FindCfgByKey(PWorldEntDetailVM.RecruitID)
	local TypeID = Cfg and Cfg.TypeID or nil
	if TypeID and TypeID > 0 then
		local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	    TeamRecruitUtil.TryOpenTeamRecruitView(TypeID, PWorldEntDetailVM.CurEntID)
	end
end

function PWorldSelectSetPanelView:OnBtnEntourage()
	_G.UIViewMgr:ShowView(_G.UIViewID.PWorldEntouragePanel, nil)
end

function PWorldSelectSetPanelView:ShowRankTips()
	if not PWorldEntDetailVM.bShowBtnRank then
		return
	end

	local IsCanShow = _G.SavageRankMgr:IsShowTips()
	if not IsCanShow then
		UIUtil.SetIsVisible(self.RankTips, false)
		FLOG_ERROR("IsShowTips = False")
		return
	end

	local TipsList = _G.SavageRankMgr:GetSavageRankOverTime()
	local TipsNum = #TipsList
	local EndPosX, EndPosY = self:GetAdvtureGuideTipsPos()
	self.RankTips:SetTipsPosition(_G.UE.FVector2D(EndPosX, EndPosY))
	if TipsNum > 0 then
		local Index = 1
		local function ShowTips()
			if Index > TipsNum then
				self:UnRegisterTimer(self.RankTimeID)
				self.RankTimeID = nil
				UIUtil.SetIsVisible(self.RankTips, false)
				_G.SavageRankMgr:SetTipsShowTime()
				print("stop showtips")
				return
			end

			local DiffTime = TipsList[Index].RemainSeconds
			local RankName = TipsList[Index].Name
			local TimeString = LocalizationUtil.GetCountdownTimeForSimpleTime(DiffTime, "s")
			local Text = string.format(_G.LSTR(1450020), RankName, TimeString)--%s排行榜将在%s后关闭
			self.RankTips:SetType(2, nil, Text)
			UIUtil.SetIsVisible(self.RankTips, true)
			print(string.format("IsShowTips = true Text = %s", Text))
			Index = Index + 1
		end

		if not self.RankTimeID then
			self.RankTimeID = self:RegisterTimer(ShowTips, 0, _G.SavageRankMgr.SustainTime, 0)
		end
	end
end

function PWorldSelectSetPanelView:GetAdvtureGuideTipsPos()
	local ButtonRanks = self.BtnNavRank
	local PanelBtnBar =  self.PanelTopBtn
	local ParentPanelPos = UIUtil.CanvasSlotGetPosition(PanelBtnBar)
	local ParentPanelSize = UIUtil.CanvasSlotGetSize(PanelBtnBar)

	local EndPosX = ParentPanelPos.X - ParentPanelSize.X - 200
	local EndPosY = ParentPanelSize.Y / 2 - ParentPanelPos.Y

	return EndPosX, EndPosY
end

--打开提升聚合界面
function PWorldSelectSetPanelView:OnClickLeveUP()
	if self.AnimEffcetBtnLeveUP1 then
		self:PlayAnimation(self.AnimEffcetBtnLeveUP1)
	end

	if false == PWorldEntDetailVM.PreCheckFailedReasons.IsPassMem then
		--"职业不符，请切换战斗职业参加"
		_G.MsgTipsUtil.ShowErrorTips(PWorldEntDetailVM.ForbidText)
		return
	end

	local Params = {}
	Params.Prof = nil
	Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_COMBAT
    EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params)
end

--打开提升聚合界面
function PWorldSelectSetPanelView:OnClickEquipmentUP()
	if self.AnimEffcetBtnLeveUP2 then
		self:PlayAnimation(self.AnimEffcetBtnLeveUP2)
	end

	local Params = {
        TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_EQUIP,
		Prof = nil
    }
    EventMgr:SendEvent(EventID.ShowPromoteMainPanel, Params)
end

--播放动效
function PWorldSelectSetPanelView:OnPWorldUpdatePreCheck(Params)
	if not Params then return end
	if Params.IsJoinBtnEnable then
		if self.BtnJoin then
			self.BtnJoin:SetIsRecommendState(true)
			self.BtnJoin:SetIsEnabled(true, true)
		end
	else
		if self.BtnJoin then
			self.BtnJoin:SetIsNormalState(true)
			self.BtnJoin:SetIsEnabled(false, true)
		end

		if nil == PWorldEntDetailVM.PreCheckFailedReasons then
			print("attempt to index a nil value (field 'PreCheckFailedReasons')")
			return
		end
		if false == Params.PreCheckFailedReasons.IsPassLv then
			if self.AnimEffcetBtnLeveUP1 then
				-- self:PlayAnimation(self.AnimEffcetBtnLeveUP1)
				self:PlayAnimEffcetBtnLeveUP1(PWorldEntDetailVM.bPassJoinLevel)
			end
		end

		if false == Params.PreCheckFailedReasons.IsPassEquipLv then
			if self.AnimEffcetBtnLeveUP2 then
				-- self:PlayAnimation(self.AnimEffcetBtnLeveUP2)
				self:PlayAnimEffcetBtnLeveUP2(PWorldEntDetailVM.bPassEquipLv)
			end
		end
	end
end

--播放动效-职业等级
function PWorldSelectSetPanelView:PlayAnimEffcetBtnLeveUP1(bPassJoinLevel)
	local PlayL = function()
		if bPassJoinLevel then return end
		if not PWorldEntDetailVM then return end
		local Lv = PWorldEntDetailVM.PWorldRequireLv
		if Lv == nil then return end

		local RoleVM = MajorUtil.GetMajorRoleVM(true)
		local MajorLv = RoleVM.Level
		local IsPassLv = MajorLv >= Lv
		if IsPassLv then
			return
		end

		if self.AnimEffcetBtnLeveUP1 then
			self:PlayAnimation(self.AnimEffcetBtnLeveUP1)
		end
	end
	
	if self.TimerLeveUP ~= 0 then
		--VM存在先更新4次旧数据 然后再更新有效数据的情况 动效不能在这之前就触发
		_G.TimerMgr:CancelTimer(self.TimerLeveUP)
	end
	self.TimerLeveUP = _G.TimerMgr:AddTimer(self, PlayL, 0.05, 0, 1)
end

--播放动效-装备等级
function PWorldSelectSetPanelView:PlayAnimEffcetBtnLeveUP2(bPassEquipLv)
	local PlayE = function()
		if bPassEquipLv then return end
		if not PWorldEntDetailVM then return end
		local EquipLv = PWorldEntDetailVM.PWorldRequireEquipLv
		if EquipLv == nil then return end

		local MajorEquipLv = _G.EquipmentMgr:CalculateEquipScore()
		local IsPassEquipLv = MajorEquipLv >= EquipLv
		if IsPassEquipLv then
			return	--不播放动效
		end

		if self.AnimEffcetBtnLeveUP2 then
			self:PlayAnimation(self.AnimEffcetBtnLeveUP2)
		end
	end

	if self.TimerEquipUP ~= 0 then
		_G.TimerMgr:CancelTimer(self.TimerEquipUP)
	end
	self.TimerEquipUP = _G.TimerMgr:AddTimer(self, PlayE, 0.05, 0, 1)
end

---@param VM ATeamVM
function PWorldSelectSetPanelView:OnTeamMemberUpdate(VM)
	if VM:GetOwnerMgr() == _G.TeamMgr then
		_G.PWorldEntDetailVM:UpdateJoinRelatedInfo()
	end
end

--- navigation
function PWorldSelectSetPanelView:OnNavTeam()
	if _G.TeamRecruitMgr:IsRecruiting() then
		_G.UIViewMgr:ShowView(UIViewID.TeamInvite, {RecruitShare=true})
	else
		if not _G.TeamMgr:CheckCanOpTeam(true) then
			return
		end
	
		local TeamHelper = require("Game/Team/TeamHelper")
		local TeamVM = TeamHelper.GetTeamMgr().TeamVM
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
	
		_G.UIViewMgr:ShowView(UIViewID.TeamInvite)
	end
end

return PWorldSelectSetPanelView