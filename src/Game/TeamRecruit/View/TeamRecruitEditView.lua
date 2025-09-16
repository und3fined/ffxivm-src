---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local TeamRecruitTypeCfg = require("TableCfg/TeamRecruitTypeCfg")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitFastMsgCfg = require("TableCfg/TeamRecruitFastMsgCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TipsUtil = require ("Utils/TipsUtil")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")


local LSTR = _G.LSTR
local SceneMode = ProtoCommon.SceneMode
local TeamRecruitModel = ProtoCommon.team_recruit_model

---@class TeamRecruitEditView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChooseContent UFButton
---@field BtnMaskProfDescTips UFButton
---@field BtnQuickInput UFButton
---@field BtnRecruit CommBtnLView
---@field BtnReset CommBtnLView
---@field BtnSetProf UFButton
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field CommInforBtn CommInforBtnView
---@field CommInputBoxCode CommInputBoxView
---@field CommInputBoxLevel CommInputBoxView
---@field ImgBg2 UFImage
---@field ImgBgLight UFImage
---@field ImgChooseContent UFImage
---@field ImgFrame1 UFImage
---@field ImgFrame2 UFImage
---@field ImgLimit UFImage
---@field ImgTypeIcon UFImage
---@field InputBoxComment CommMultilineInputBoxView
---@field InputBoxCommentNew CommInputBoxView
---@field PanelCode UFCanvasPanel
---@field PanelEquipLv UFCanvasPanel
---@field PanelProf UFCanvasPanel
---@field PanelTask UFCanvasPanel
---@field PanelWeekAward UFCanvasPanel
---@field SingleBoxCode CommSingleBoxView
---@field SingleBoxEquipLv CommSingleBoxView
---@field SingleBoxTask CommSingleBoxView
---@field SingleBoxWeek CommSingleBoxView
---@field TableViewLocProf UTableView
---@field TextClear UFTextBlock
---@field TextComment UFTextBlock
---@field TextContent UFTextBlock
---@field TextContentDesc UFTextBlock
---@field TextLimit UFTextBlock
---@field TextLv UFTextBlock
---@field TextProf UFTextBlock
---@field TextRecruitSetting UFTextBlock
---@field TextReward UFTextBlock
---@field TextSetPassword UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimPanelSettingTipsIn UWidgetAnimation
---@field AnimProfDescTipsIn UWidgetAnimation
---@field AnimReset UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitEditView = LuaClass(UIView, true)

function TeamRecruitEditView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChooseContent = nil
	--self.BtnMaskProfDescTips = nil
	--self.BtnQuickInput = nil
	--self.BtnRecruit = nil
	--self.BtnReset = nil
	--self.BtnSetProf = nil
	--self.Comm2FrameL_UIBP = nil
	--self.CommInforBtn = nil
	--self.CommInputBoxCode = nil
	--self.CommInputBoxLevel = nil
	--self.ImgBg2 = nil
	--self.ImgBgLight = nil
	--self.ImgChooseContent = nil
	--self.ImgFrame1 = nil
	--self.ImgFrame2 = nil
	--self.ImgLimit = nil
	--self.ImgTypeIcon = nil
	--self.InputBoxComment = nil
	--self.InputBoxCommentNew = nil
	--self.PanelCode = nil
	--self.PanelEquipLv = nil
	--self.PanelProf = nil
	--self.PanelTask = nil
	--self.PanelWeekAward = nil
	--self.SingleBoxCode = nil
	--self.SingleBoxEquipLv = nil
	--self.SingleBoxTask = nil
	--self.SingleBoxWeek = nil
	--self.TableViewLocProf = nil
	--self.TextClear = nil
	--self.TextComment = nil
	--self.TextContent = nil
	--self.TextContentDesc = nil
	--self.TextLimit = nil
	--self.TextLv = nil
	--self.TextProf = nil
	--self.TextRecruitSetting = nil
	--self.TextReward = nil
	--self.TextSetPassword = nil
	--self.AnimIn = nil
	--self.AnimPanelSettingTipsIn = nil
	--self.AnimProfDescTipsIn = nil
	--self.AnimReset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitEditView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRecruit)
	self:AddSubView(self.BtnReset)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommInputBoxCode)
	self:AddSubView(self.CommInputBoxLevel)
	self:AddSubView(self.InputBoxComment)
	self:AddSubView(self.InputBoxCommentNew)
	self:AddSubView(self.SingleBoxCode)
	self:AddSubView(self.SingleBoxEquipLv)
	self:AddSubView(self.SingleBoxTask)
	self:AddSubView(self.SingleBoxWeek)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitEditView:OnInit()
	self.InputBoxComment:SetMaxNum(100)
	self.InputBoxComment:SetCallback(self, self.OnInputBoxFreeMsgTextChanged)
	self.TableAdapterLocProf = UIAdapterTableView.CreateAdapter(self, self.TableViewLocProf, self.OnSelectProfChanged)

	self.EditProfBinder = UIBinderSetIsVisiblePred.NewByPred(function()
		return not TeamRecruitVM.IsCalcingMembersProf and _G.TeamMgr:GetTeamMemberCount() < TeamRecruitVM.EditProfVMList:Length()
	end, self, self.BtnSetProf, false, true)
	self.Binders = {
        { "IsCalcingMembersProf", self.EditProfBinder},
		{ "EditProfTotalNum", self.EditProfBinder},
		{ "EditProfVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterLocProf) },
		{ "EditContentID", UIBinderValueChangedCallback.New(self, nil, self.OnRecruitIDChanged) },
		{ "EditQuickTextIDs", UIBinderValueChangedCallback.New(self, nil, self.OnQuickIDsChanged) },
		{ "EditSceneMode",	UIBinderValueChangedCallback.New(self, nil, self.OnUpdateDifficulty)},
		{ "bShowEditWeeklyReward", UIBinderSetIsVisible.New(self, self.PanelWeekAward)},
		{ "EditWeeklyAward", UIBinderValueChangedCallback.New(self, nil, self.OnEditWeeklyRewardChanged)},
		{ "EditCompleteTask", UIBinderValueChangedCallback.New(self, nil, self.OnEditCompleteTaskChanged)},
	}

	self.TeamBinders = {
		{"MemberNumber", self.EditProfBinder},
	}
end

function TeamRecruitEditView:OnShow()
	self:ResetSet(false, self.Params)

	local bReset = not _G.TeamRecruitMgr:IsMajorRecruiting()
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(self.Params and 1310047 or 1310113))
	self.BtnReset:SetText(LSTR(bReset and 1310048 or 1310042))
	self.BtnRecruit:SetText(LSTR(bReset and 1310049 or 1310043))
	self.InputBoxComment:SetHintText(_G.LSTR(1310108))

	--初始化职能设置数据
	self:InitFuncSetData()

	self.CommInputBoxCode:SetHintText(_G.LSTR(1310097))
	if self.TextSetPassword then
		self.TextSetPassword:SetText(_G.LSTR(1310098))
		UIUtil.SetIsVisible(self.TextSetPassword, true)
	end
	if self.TextLv then
		self.TextLv:SetText(_G.LSTR(1310099))
		UIUtil.SetIsVisible(self.TextLv, true)
	end
	if self.TextClear then
		self.TextClear:SetText(_G.LSTR(1310094))
		UIUtil.SetIsVisible(self.TextClear, true)
	end
	if self.TextReward then
		self.TextReward:SetText(_G.LSTR(1310111))
		UIUtil.SetIsVisible(self.TextReward, true)
	end

	self.TextContent:SetText(_G.LSTR(1310055))
	self.TextProf:SetText(_G.LSTR(1310059))
	self.TextRecruitSetting:SetText(_G.LSTR(1310062))
	self.TextComment:SetText(_G.LSTR(1310057))
end

function TeamRecruitEditView:OnHide()
	if self:NeedRecover() then
		TeamRecruitMgr:TryRecoverEditRecruit()
	else
		TeamRecruitMgr.LastRecruitCloseReason = nil
	end

	TeamRecruitVM:ClearEditData()
	self.bCloseToHide = nil
end

function TeamRecruitEditView:OnDestroy()
	self.bCloseToHide = nil
end

function TeamRecruitEditView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxTask, self.OnToggleStateChangedTask)
	-- UIUtil.AddOnStateChangedEvent(self,	self.ToggleGroupSceneMode, self.OnGroupStateChangedSceneMode)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxCode, self.OnToggleStateChangedCode)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxEquipLv, self.OnToggleStateChangedEquipLv)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxWeek, self.OnToggleStateChangedEditWeeklyReward)

	self.CommInputBoxCode:SetCallback(self, self.OnCodeTextChanged, self.OnCodeTextChanged)
	self.CommInputBoxLevel:SetCallback(self, self.OnTextChangedEquipLv, nil)
	self.CommInputBoxCode:SetMaxNum(TeamRecruitDefine.MaxCodeLength)
	self.CommInputBoxLevel:SetMaxNum(4)
	self.CommInputBoxLevel:SetIsHideNumber(true)
	self.CommInputBoxCode:SetIsHideNumber(true)

	--UIUtil.AddOnClickedEvent(self, self.BtnSceneModeSetTips.BtnInfor, self.OnClickedSceneModeSetTips)

	UIUtil.AddOnClickedEvent(self, self.BtnMaskProfDescTips, self.OnClickedMaskProfDescTips)
	-- UIUtil.AddOnClickedEvent(self, self.BtnMaskSetTips, self.OnClickedMaskSetTips)
	UIUtil.AddOnClickedEvent(self, self.BtnChooseContent, self.OnClickedChooseContent)
	UIUtil.AddOnClickedEvent(self, self.BtnQuickInput, self.OnClickedQuickInput)
	UIUtil.AddOnClickedEvent(self, self.BtnSetProf, self.OnClickedSetProf)
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickedReset)
	UIUtil.AddOnClickedEvent(self, self.BtnRecruit, self.OnClickedRecruit)
end

function TeamRecruitEditView:OnRegisterBinder()
	self:RegisterBinders(TeamRecruitVM, self.Binders)
	self:RegisterBinders(_G.TeamVM, self.TeamBinders)
end

---@param RecruitData csteamrecruitdd.TeamRecruit @招募的完整服务器信息
function TeamRecruitEditView:ResetSet( IsClearEditData, RecruitData)
	if IsClearEditData then
		TeamRecruitVM:ClearEditData()
		self:PlayAnimation(self.AnimReset)
	end

	self.SingleBoxCode:SetChecked(false, false)
	self.CommInputBoxCode:SetIsEnabled(false)
	self.SingleBoxTask:SetChecked(false, false)
	self.SingleBoxEquipLv:SetChecked(false, false)
	self.CommInputBoxLevel:SetIsEnabled(false)

	-- UIUtil.SetIsVisible(self.PanelSettingTips, false)
	-- UIUtil.SetIsVisible(self.ProfDescTips, false)
	UIUtil.SetIsVisible(self.BtnMaskProfDescTips, false)

	self.CommInputBoxLevel:SetText("0")
	self.InputBoxComment:SetText("")
	self.CommInputBoxCode:SetText("")

	if nil == RecruitData then
		--默认选择默认招募类型的第一个内容 或者 是 已经选择的招募内容
		TeamRecruitVM:SetEditRecruitType(TeamRecruitVM.CurSelectRecruitType or TeamRecruitDefine.DefaultRecruitType)
		local ContentList = TeamRecruitVM:GetRecruitContentList(TeamRecruitVM.EditRecruitType)
		if #ContentList > 0 then
			local ContentID = ContentList[1].ID
			local PreSelectTask = TeamRecruitVM.PreSelectTask
			-- #TODO USE A CONSTRUTED RECRUIT DATA INSTEAD
			if PreSelectTask then
				for _, v in ipairs(ContentList) do
					if v.Task == PreSelectTask or PreSelectTask == v.DailyRandomID then
						ContentID = v.ID
						break
					end
				end
			end
			TeamRecruitVM:SetEditContentID(ContentID)
		end

		self:OnUpdateDifficulty()
		return
	end

	TeamRecruitVM:SetEditSceneMode(RecruitData.TaskLimit)
	TeamRecruitVM:SetEditContentID(RecruitData.ID)
	TeamRecruitVM:SetEditRecruitTypeByContentID(RecruitData.ID)
	self:OnUpdateDifficulty()

	self.SingleBoxTask:SetChecked(RecruitData.ComplateTask, true)

	--密码
	local Password = tonumber(RecruitData.Password)
	Password = Password ~= nil and tostring(Password) or ""
	self.CommInputBoxCode:SetText(Password)
	self.SingleBoxCode:SetChecked(string.len(Password) > 0, true)

	--装备平均品级
	self:SetEquipLv(RecruitData.EquipLv)

	--计算招募职能填充信息
	TeamRecruitVM:CalcMembersProf(RecruitData.Prof or {})

	local Message = RecruitData.Message or ""
	TeamRecruitVM:SetEditQuickTextIDs(TeamRecruitUtil.GetQuickTextIDs(Message))

	self.InputBoxComment:SetText(Message)

	-- 周奖励
	TeamRecruitVM:SetEditWeeklyReward(RecruitData.WeeklyAward)
end

function TeamRecruitEditView:OnUpdateDifficulty()
	local bShowEditDifficulty =  TeamRecruitUtil.HasDifficultyConfig(TeamRecruitVM.EditContentID)
	UIUtil.SetIsVisible(self.TextLimit, bShowEditDifficulty)
	UIUtil.SetIsVisible(self.ImgLimit, bShowEditDifficulty)
	if bShowEditDifficulty then
		local Mode = TeamRecruitVM.EditSceneMode or SceneMode.SceneModeNormal
		local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
		local Icon = PWorldQuestUtil.GetSceneModeIcon(Mode) or ""
		local Text = PWorldQuestUtil.GetSceneModeName(Mode) or ""
		UIUtil.ImageSetBrushFromAssetPath(self.ImgLimit, Icon)
		self.TextLimit:SetText(Text)
	end
end

function TeamRecruitEditView:OnEditWeeklyRewardChanged(Value)
	self.SingleBoxWeek:SetChecked(Value, false)
end

function TeamRecruitEditView:OnEditCompleteTaskChanged(Value)
	self.SingleBoxTask:SetChecked(Value, false)
end

function TeamRecruitEditView:InitFuncSetData()
	local FuncEditVMList = TeamRecruitVM.FuncEditVMList
	if FuncEditVMList:Length() > 0 then
		return
	end

	FuncEditVMList:UpdateByValues(TeamRecruitDefine.RecruitFunctionEditConfig)
end

function TeamRecruitEditView:SetEquipLv( EquipLv )
	EquipLv = tonumber(EquipLv) or 0
	self.CommInputBoxLevel:SetText(tostring(EquipLv))
	self.SingleBoxEquipLv:SetChecked(EquipLv > 0, true)
end

function TeamRecruitEditView:OnSelectProfChanged(Index, ItemData, ItemView)
	if nil == ItemData or nil == ItemView then
		return
	end

	--职业描述
	--self.TextProfDetail:SetText(TeamRecruitUtil.GetRecruitProfDesc(ItemData) or "")

	--位置计算
	-- local ViewportPos = ItemView:GetViewportPosition() 
	-- local LocalPos = UIUtil.ViewportToLocal(self.PanelProf, ViewportPos) 
    -- LocalPos.Y = LocalPos.Y - 5

	-- UIUtil.CanvasSlotSetPosition(self.ProfDescTips, LocalPos)

	-- UIUtil.SetIsVisible(self.ProfDescTips, true)
	-- UIUtil.SetIsVisible(self.BtnMaskProfDescTips, true, true)
	-- self:PlayAnimation(self.AnimProfDescTipsIn)

	-- self.TextProfDetail:SetText(TeamRecruitUtil.GetRecruitProfDesc(ItemData) or "")

	--位置计算
	local Width = self.TableViewLocProf.EntryWidth
	local Height = self.TableViewLocProf.EntryHeight

	if UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTipsView) then
		UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
	end

	TipsUtil.ShowInfoTips(TeamRecruitUtil.GetRecruitProfDesc(ItemData) or "", ItemView, _G.UE.FVector2D( 7 - Width, 0), _G.UE.FVector2D(0, 1), true)

	UIUtil.SetIsVisible(self.BtnMaskProfDescTips, true, true)
end

function TeamRecruitEditView:OnRecruitIDChanged(ContentID)
	if nil == ContentID then
		return
	end

	local Cfg = TeamRecruitCfg:FindCfgByKey(ContentID)
	if nil == Cfg then
		return
	end

	TeamRecruitVM:SetEditRecruitType(Cfg.TypeID)

	--类型图标
	local TypeInfo = TeamRecruitTypeCfg:GetRecruitTypeInfo(Cfg.TypeID) or {}
	if not string.isnilorempty(TypeInfo.Icon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgTypeIcon, TypeInfo.Icon)
	end

	--招募内容描述
	self.TextContentDesc:SetText(string.format("%s - %s", TypeInfo.Name or "", Cfg.TaskName or ""))

	--任务设置（场景类型）
	local RecruitModel = Cfg.RecruitModel or {}
	local IsVisible = table.contain(RecruitModel, TeamRecruitModel.TEAM_RECRUIT_MODEL_DAMAGE) 
	-- UIUtil.SetIsVisible(self.CheckBoxChallenge, IsVisible)
	-- if not IsVisible and TeamRecruitVM.EditSceneMode == SceneMode.SceneModeChallenge then -- 切换回常规
	-- 	-- self.ToggleGroupSceneMode:SetCheckedIndex(0)
	-- end

	-- IsVisible = table.contain(RecruitModel, TeamRecruitModel.TEAM_RECRUIT_MODEL_UNLIMITED) 
	-- UIUtil.SetIsVisible(self.CheckBoxUnlimit, IsVisible)
	-- if not IsVisible and TeamRecruitVM.EditSceneMode == SceneMode.SceneModeUnlimited then -- 切换回常规
	-- 	-- self.ToggleGroupSceneMode:SetCheckedIndex(0)
	-- end

	--已完成过任务
	local ShowCompleteTask = Cfg.CompleteTask == 1
	UIUtil.SetIsVisible(self.PanelTask, ShowCompleteTask)
	if not ShowCompleteTask then
		self:OnToggleStateChangedTask(self.SingleBoxTask, false)
	end

	--默认装备等级
	self:SetEquipLv(Cfg.EquipLv)

	--默认职业列表
	TeamRecruitVM:ResetEditProfVMList(self.Params)

	self:OnUpdateDifficulty()

	if self.Params == nil and TeamRecruitUtil.HasWeeklyRewardConfig(ContentID) then
		local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
		TeamRecruitVM:SetEditWeeklyReward(not PWorldEntUtil.IsWeeklyRewardGet(Cfg.Task))
	end
end

function TeamRecruitEditView:OnQuickIDsChanged()
	local NewText = ""
	local Text = self.InputBoxComment:GetText()

	--被取消的选项
	local AllQuickText = TeamRecruitFastMsgCfg:GetAllText()
	local ReduceIDs = table.clone(TeamRecruitVM.EditReduceQuickTextIDs or {})

	local function WipeText(v)
		local QuickText = AllQuickText[v]
        if not string.isnilorempty(QuickText) then 
			Text = string.gsub(Text, string.revisePattern(string.format("[%s]", QuickText)), "")
		end
	end

	for _, v in ipairs(ReduceIDs) do
		WipeText(v)
	end

	--便捷输入
	local IDList = table.clone(TeamRecruitVM.EditQuickTextIDs)
	table.sort(IDList, function (a, b)
		return a < b
	end)

	for _, v in ipairs(IDList)  do
		local QuickText = AllQuickText[v]
        if not string.isnilorempty(QuickText) then 
			local Str = string.format("[%s]", QuickText)  
			Text = string.gsub(Text, string.revisePattern(Str), "")

			NewText = NewText .. Str
		end
	end

	NewText =  NewText .. Text
	self.InputBoxComment:SetText(NewText)
end

function TeamRecruitEditView:OnInputBoxFreeMsgTextChanged( Text )
	TeamRecruitVM:UpdateEditText(Text)
end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

function TeamRecruitEditView:OnToggleStateChangedTask(ToggleButton, State)
	local Text = self.InputBoxComment:GetText()
	local Word = TeamRecruitDefine.CompleteTaskWord

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		-- if not string.startsWith(Text, Word) then
		-- 	Text = Word .. Text 
		-- end
		if string.find(Text, string.revisePattern(Word)) == nil then
			Text = Word .. Text
		end
	else
		Text = string.gsub(Text, "^" .. string.revisePattern(Word), "")
	end

	TeamRecruitVM:SetEditCompleteTask(IsChecked)
end

function TeamRecruitEditView:OnToggleStateChangedCode(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self.CommInputBoxCode:SetText(IsChecked and "0000" or "")
	self.CommInputBoxCode:SetIsEnabled(IsChecked)
end

function TeamRecruitEditView:OnCodeTextChanged()
	local Text = self.CommInputBoxCode:GetText()
	local OldText = Text
	-- lengh cut
	if string.len(Text) > TeamRecruitDefine.MaxCodeLength and TeamRecruitDefine.MaxCodeLength > 0 then
		Text = string.sub(Text, 1, TeamRecruitDefine.MaxCodeLength)
	end
	-- number refine
	local Ix = string.find(Text, "%D")
	if Ix ~= nil then
		Text = string.sub(Text, 1, Ix-1)
	end
	if Text == nil then
		Text = ""
	end
	if Text ~= TeamRecruitVM.EditPassword or OldText ~= Text then
		-- avoid recursive call lua bug
		self:RegisterTimer(function(w, NText)
			TeamRecruitVM.EditPassword = NText
			if w then
				w.CommInputBoxCode:SetText(TeamRecruitVM.EditPassword)
			end
		end
		, 0, 0.001, 1, Text)
	end
end

function TeamRecruitEditView:OnToggleStateChangedEquipLv(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if not IsChecked then
		self.CommInputBoxLevel:SetText("0")
	end

	self.CommInputBoxLevel:SetIsEnabled(IsChecked)
end

function TeamRecruitEditView:OnToggleStateChangedEditWeeklyReward(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	TeamRecruitVM:SetEditWeeklyReward(IsChecked)
end

function TeamRecruitEditView:OnTextChangedEquipLv(Text, _)
	local Ix = string.find(Text, "%D")
	local EquipLv = tonumber(Ix and string.sub(Text, 1, Ix-1) or Text)
    if EquipLv == nil then
		EquipLv = 0
	end
	if  EquipLv > TeamRecruitDefine.MaxEquipLv then
		EquipLv = TeamRecruitDefine.MaxEquipLv
	end
	TeamRecruitVM.EditEquipLv = EquipLv
	if Text ~= tostring(EquipLv) then
		self:RegisterTimer(
		function(w, NText)
			if w and w.CommInputBoxLevel then
				w.CommInputBoxLevel:SetText(NText)
			end
		end,
		0, 0.001, 1, tostring(EquipLv))
	end
end

function TeamRecruitEditView:OnClickedMaskProfDescTips()
	-- UIUtil.SetIsVisible(self.ProfDescTips, false)
	-- UIUtil.SetIsVisible(self.BtnMaskProfDescTips, false)

	-- self.TableAdapterLocProf:CancelSelected()

	-- UIUtil.SetIsVisible(self.ProfDescTips, false)

	if UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTipsView) then
		UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
	end
	UIUtil.SetIsVisible(self.BtnMaskProfDescTips, false)

	self.TableAdapterLocProf:CancelSelected()
end

function TeamRecruitEditView:OnClickedSceneModeSetTips()
	UIUtil.SetIsVisible(self.PanelSettingTips, true)
	self:PlayAnimation(self.AnimPanelSettingTipsIn)
end

function TeamRecruitEditView:OnClickedMaskSetTips()
	UIUtil.SetIsVisible(self.PanelSettingTips, false)
end

function TeamRecruitEditView:OnClickedChooseContent()
	UIViewMgr:ShowView(UIViewID.TeamRecruitContentSelect)
end

function TeamRecruitEditView:OnClickedQuickInput()
	UIViewMgr:ShowView(UIViewID.TeamRecruitQuickInput)
end

function TeamRecruitEditView:OnClickedSetProf()
	UIViewMgr:ShowView(UIViewID.TeamRecruitEditFunc)
end

function TeamRecruitEditView:OnClickedReset()
	if self:IsEditUpdate() then
		self.bCloseToHide = true
		_G.TeamRecruitMgr:SendCloseRecruitReq()
		self:Hide()
	else
		MsgBoxUtil.ShowMsgBoxTwoOp(
		self, 
		LSTR(1310035), 
		LSTR(1310036), 
		function()
			self:ResetSet(true)
		end, 
		nil, 
		LSTR(1310004), 
		LSTR(1310005))
	end
end

function TeamRecruitEditView:IsEditUpdate()
	return self.Params and self.Params.bEditUpdate
end


local LastClickRecruitTime = 0
function TeamRecruitEditView:OnClickedRecruit()
	if os.time() - LastClickRecruitTime <= 2 then
		MsgTipsUtil.ShowTipsByID(301023)
		return
	end
	LastClickRecruitTime = os.time()

	if _G.TeamMgr:GetTeamMemberCount() >= TeamRecruitVM.EditProfVMList:Length() then
		MsgTipsUtil.ShowTipsByID(301031)
		return
	end

	local PWorldEntID = nil
	if TeamRecruitVM.EditContentID then
		local Cfg = TeamRecruitCfg:FindCfgByKey(TeamRecruitVM.EditContentID)
		if Cfg then
			PWorldEntID = Cfg.Task
		end
	end

	if PWorldEntID then
		_G.EventMgr:SendEvent(EventID.TeamRecruitTaskSetConfirm, {PWorldEntID = PWorldEntID, 
													Task = TeamRecruitVM.EditSceneMode})
	end
	
	local bShowHint
	local ProfUtil = require("Game/Profession/ProfUtil")
	for _, RoleID in _G.TeamMgr:IterTeamMembers() do
		if RoleID then
			local RVM = _G.TeamMgr.FindRoleVM(RoleID, true)
			if ProfUtil.IsProductionProf(RVM.Prof) then
				bShowHint = true
				break
			end
		end
	end

	local function CreateRecruitAndHide()
		if not self:NeedRecover() then
			TeamRecruitMgr:SendCreateRecruitReq()
			return
		end
		self:Hide()
	end

	local function TryCreateRecruit()
		CreateRecruitAndHide()
	end

	if bShowHint then
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self, 
			PWorldHelper.GetPWorldText("POPUP_INVALID_NEW_RECRUIT_TITLE"), 
			PWorldHelper.GetPWorldText("POPUP_INVALID_NEW_RECRUIT_CONTENT"), 
			function()
				TryCreateRecruit()
			end, 
			nil, 
			PWorldHelper.GetPWorldText("BTN_INVALID_NEW_RECRUIT_NO"), 
			PWorldHelper.GetPWorldText("BTN_INVALID_NEW_RECRUIT_YES"), nil)
		return
	end
	
	TryCreateRecruit()
end

function TeamRecruitEditView:NeedRecover()
	local bEdit = self:IsEditUpdate() and not self.bCloseToHide
	if bEdit  then
		local ParamsA = {
			ID			= TeamRecruitVM.EditContentID,
			Message     = TeamRecruitVM.EditMessage or "",
			Prof        = TeamRecruitVM:GetEditProfs(),
			TaskLimit   = TeamRecruitVM.EditSceneMode,
			Password    = TeamRecruitVM:GetEditPassword(),
			EquipLv     = TeamRecruitVM.EditEquipLv or 0,
			CompleteTask = TeamRecruitVM.EditCompleteTask == true,
			QuickMessageIDs = TeamRecruitVM.EditQuickTextIDs,
			WeeklyAward = TeamRecruitVM.EditWeeklyAward == true
		}
		local ParamsB = {
			ID			= self.Params.ID,
			Message     = self.Params.Message or "",
			Prof        = self.Params.Prof,
			TaskLimit   = self.Params.TaskLimit or 0,
			Password    = self.Params.Password or "",
			EquipLv     = self.Params.EquipLv or 0,
			CompleteTask = self.Params.ComplateTask == true,
			QuickMessageIDs = self.Params.QuickMessageIDs,
			WeeklyAward = self.Params.WeeklyAward == true
		}

		local Json = require("Core/Json")
		if Json.encode(ParamsA) ~= Json.encode(ParamsB) then
			return false
		end
	end

	return bEdit
end

return TeamRecruitEditView