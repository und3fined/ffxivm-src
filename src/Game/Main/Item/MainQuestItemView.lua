---
--- Author: lydianwang
--- DateTime: 2023-02-22 15:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestDefine = require("Game/Quest/QuestDefine")
local RichTextUtil = require("Utils/RichTextUtil")
local ChapterVM = require("Game/Quest/VM/DataItemVM/ChapterVM")
local MapCfg = require("TableCfg/MapCfg")
local AutoMoveTargetType = require("Define/AutoMoveTargetType")
local TimeUtil = require("Utils/TimeUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

local QuestTrackVM = nil

local LSTR = _G.LSTR
local TextFinishQuest = LSTR(593005) --593005("任务完成!")
local TextSwitchProf = LSTR(593004) --593004("切换至战斗职业以进入迷宫")
local TextAcceptable = LSTR(593003) --593003("%s可接取")
local TextHourLimitTimeAccept = LSTR(593010) --593010("%s小时后可接取")
local TextMinuteLimitTimeAccept = LSTR(593011) --593011("%s分钟后可接取")

---@class MainQuestItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnQuest UFButton
---@field ImgStateBg UFImage
---@field QuestState UFCanvasPanel
---@field QuestTime UFCanvasPanel
---@field QuestTitle MainQuestTitleItemView
---@field RichTextState URichTextBox
---@field TargetList UTableView
---@field TextTime UFTextBlock
---@field AnimSelect UWidgetAnimation
---@field AnimSelectHidden UWidgetAnimation
---@field PanelIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainQuestItemView = LuaClass(UIView, true)

function MainQuestItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnQuest = nil
	--self.ImgStateBg = nil
	--self.QuestState = nil
	--self.QuestTime = nil
	--self.QuestTitle = nil
	--self.RichTextState = nil
	--self.TargetList = nil
	--self.TextTime = nil
	--self.AnimSelect = nil
	--self.AnimSelectHidden = nil
	--self.PanelIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainQuestItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.QuestTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainQuestItemView:OnInit()
	QuestTrackVM = QuestMainVM.QuestTrackVM
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TargetList)
	self.bPlayedTrackAnim = false

	self.DisplayVMQueue = {}
	self.DisplayTimerID = nil
end

function MainQuestItemView:OnDestroy()

end

function MainQuestItemView:OnShow()
	UIUtil.SetIsVisible(self.QuestTime, false)
	if self.Params == nil then return end

	local TrackingChapterID = nil
	if _G.AutoPathMoveMgr:IsAutoPathMovingState() and _G.AutoPathMoveMgr.TargetType == AutoMoveTargetType.Task then
		TrackingChapterID = _G.QuestTrackMgr.AutoPathTrackChapterID
	end

	local MainlineVM = self.Params.MainlineVM
	if MainlineVM ~= nil then
		if MainlineVM.bActivatedMainline then
			self:SetStateAcceptable(MainlineVM)
		elseif MainlineVM.bMainlineEndedTempVM then
			self:SetStateFinishAll()
		else
			UIUtil.SetIsVisible(self.QuestState, false)
		end
		if TrackingChapterID and MainlineVM.ChapterID == TrackingChapterID then
			self.QuestTitle:SwitchAutoFindStatus(true)
		else
			self.QuestTitle:SwitchAutoFindStatus(false)
		end
	end

	local OtherVM = self.Params.OtherVM
	if OtherVM ~= nil then
		UIUtil.SetIsVisible(self.QuestState, false)
		self:SetQuestTitleContent(OtherVM)
		if TrackingChapterID and OtherVM.ChapterID == TrackingChapterID then
			self.QuestTitle:SwitchAutoFindStatus(true)
		else
			self.QuestTitle:SwitchAutoFindStatus(false)
		end
	end
end

function MainQuestItemView:OnHide()
	self.bPlayedTrackAnim = false
	if self.DisplayTimerID then
		self:UnRegisterAllTimer()
		self.DisplayTimerID = nil
		self.DisplayVMQueue = {}
	end
end

function MainQuestItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnQuest, self.OnClickedBtnQuest)
end

function MainQuestItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.TempChangeTargetVMList)
	self:RegisterGameEvent(EventID.StartAutoPathMove, self.OnGameEventStartAutoPathMove)
	self:RegisterGameEvent(EventID.StopAutoPathMove, self.OnGameEventStopAutoPathMove)
end

function MainQuestItemView:OnRegisterBinder()
	if self.Params == nil then return end

	local TrackVMBinders = {
		{ "CurrTrackChapterID", UIBinderValueChangedCallback.New(self, nil, self.OnCurrTrackIDChanged) },
	}
	self:RegisterBinders(QuestTrackVM, TrackVMBinders)

	local MainlineVM = self.Params.MainlineVM
	if MainlineVM ~= nil then
		local Binders = {
			{ "Icon", UIBinderValueChangedCallback.New(self, nil, self.OnChapterContentChanged) },
			{ "ChapterID", UIBinderValueChangedCallback.New(self, nil, self.OnChapterContentChanged) },
			{ "TargetVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
			--临时
			{ "TempOneTargetName", UIBinderValueChangedCallback.New(self, nil, self.TempChangeTargetVMList) },
			{ "TempCountdownStr", UIBinderSetIsVisible.New(self, self.QuestTime) },
			{ "TempCountdownStr", UIBinderSetText.New(self, self.TextTime) },
		}
		self:RegisterBinders(MainlineVM, Binders)
	end

	local OtherVM = self.Params.OtherVM
	if OtherVM ~= nil then
		local Binders = {
			{ "Icon", UIBinderValueChangedCallback.New(self, nil, self.OnChapterContentChanged) },
			{ "TargetVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
			--临时
			{ "TempOneTargetName", UIBinderValueChangedCallback.New(self, nil, self.TempChangeTargetVMList) },
			{ "TempCountdownStr", UIBinderSetIsVisible.New(self, self.QuestTime) },
			{ "TempCountdownStr", UIBinderSetText.New(self, self.TextTime) },
		}
		self:RegisterBinders(OtherVM, Binders)
	end
end

---@return boolean
function MainQuestItemView:IsChapter(ChapterID)
	if self.Params == nil then return false end
	local VM = self.Params.MainlineVM or self.Params.OtherVM
	if VM == nil then return false end

	return VM.ChapterID == ChapterID
end

function MainQuestItemView:PushDisplayFinished(VM)
	local FinishVM = ChapterVM.New()
	FinishVM.Name = TextFinishQuest
	FinishVM.Icon = VM.Icon
	FinishVM.bFinishedTipTempVM = true

	table.insert(self.DisplayVMQueue, {
		VM = FinishVM, Duration = QuestDefine.NEW_ACCCEPT_DURATION,
	})

	self:PopDisplay()
end

function MainQuestItemView:PushDisplayNormal(VM)
	table.insert(self.DisplayVMQueue, {
		VM = VM, Duration = 0,
	})

	self:PopDisplay()
end

function MainQuestItemView:PopDisplay()
	if self.DisplayTimerID then return end

	local VMParams
	repeat
		VMParams = table.remove(self.DisplayVMQueue, 1)
	until (self.DisplayVMQueue[1] == nil) or ((VMParams ~= nil) and (VMParams.Duration > 0))

	if (VMParams == nil) or (VMParams.VM == nil) then
		UIUtil.SetIsVisible(self, false)
		return
	end

	-- 刷新
	UIUtil.SetIsVisible(self, true)
	if self.PanelIndex == 1 then
		self:UpdateView({ MainlineVM = VMParams.VM })
	elseif self.PanelIndex == 2 then
		self:UpdateView({ OtherVM = VMParams.VM })
	end

	if VMParams.Duration == 0 then return end

	self.DisplayTimerID = self:RegisterTimer(function()
		self.DisplayTimerID = nil
		self:PopDisplay()
	end, VMParams.Duration, 0, 1)
end

function MainQuestItemView:OnCurrTrackIDChanged(NewValue)
	if self:IsChapter(NewValue) then
		--self:PlayAnimation(self.AnimSelect) --去掉流光动效
		--self.TitleAnimTimerID = self:RegisterTimer(function(_)
		--	self.QuestTitle:PlayAnimTrack()
		--end, QuestDefine.NEW_ACCCEPT_DURATION, 0, 1)
		self.QuestTitle:PlayAnimTrack()
		self.bPlayedTrackAnim = true

	elseif self.bPlayedTrackAnim then -- 简单优化，避免重复播放Hidden动画
		self:PlayAnimation(self.AnimSelectHidden)
		if self.TitleAnimTimerID ~= nil then
			self:UnRegisterTimer(self.TitleAnimTimerID)
			self.TitleAnimTimerID = nil
		end
		self.QuestTitle:PlayAnimTrack(false)
		self.bPlayedTrackAnim = false
	end
end

function MainQuestItemView:OnChapterContentChanged()
	if self.Params == nil then return end
	local VM = self.Params.MainlineVM or self.Params.OtherVM
	self:SetQuestTitleContent(VM)
end

function MainQuestItemView:SetQuestTitleContent(VM)
	if VM == nil then return end

	local Title = VM:GetTitleName()

	local QuestID = VM.QuestID
	if not UE.UCommonUtil.IsShipping() then
		if UIViewMgr:IsViewVisible(UIViewID.NarrativeTestPanel) then
			Title = Title .. "(" .. tostring(QuestID) .. ")"
		end
	end

	local bNormalColor = VM:IsNormalColorTitle()

	if not bNormalColor then -- 蓝图未提供红色轮廓字接口，先硬编码处理
		Title = RichTextUtil.GetText(Title,
		"FF9999FF", "AA0808AA", 2)
	end

	
	self.QuestTitle:SetContent(VM.Icon, Title)
end

function MainQuestItemView:OnClickedBtnQuest()
	if self.Params == nil then return end

	_G.NaviDecalMgr:SetNaviType(_G.NaviDecalMgr.EGuideType.Task)

	local MainlineVM = self.Params.MainlineVM
	if MainlineVM ~= nil then
		local ChapterID = MainlineVM.ChapterID
		if MainlineVM.bActivatedMainline then
			-- 点击激活但未接取的主线，尝试追踪
			if QuestTrackVM.CurrTrackQuestVM and QuestTrackVM.CurrTrackQuestVM.ChapterID == ChapterID then
				if not _G.AutoPathMoveMgr:IsAutoPathMoveEnable() then --如果没有开启自动寻路,打开任务点地图
					QuestTrackVM:ShowMapTrackQuest(ChapterID)
				else
					QuestTrackVM:StartCanAcceptQuestAutoPathMove(ChapterID) --开始自动寻路
				end
			else
				QuestTrackVM:TrackCanAcceptQuest(ChapterID)
				if not _G.AutoPathMoveMgr:IsAutoPathMoveEnable() then --如果没有开启自动寻路,打开任务点地图
					QuestTrackVM:ShowMapTrackQuest(ChapterID)
				end
			end
		else
			self:TrackQuest(ChapterID)
		end
	end

	local OtherVM = self.Params.OtherVM
	if OtherVM ~= nil then
		self:TrackQuest(OtherVM.ChapterID)
	end
end

function MainQuestItemView:TrackQuest(ChapterID)
	if not ChapterID then
		return
	end
	if QuestTrackVM.CurrTrackChapterID == ChapterID then
		QuestTrackVM:PushTrackQuest()
	else
		QuestTrackVM:TrackQuest(ChapterID)
		_G.QuestMgr.QuestReport:ReportChangeTaskTracking(ChapterID)
	end
end

-----------------------------------

---主线可接取
function MainQuestItemView:SetStateAcceptable(VM)
	if not VM then
		self.RichTextState:SetText("")
		UIUtil.SetIsVisible(self.ImgStateBg, false)
		UIUtil.SetIsVisible(self.QuestState, false)
		return
	end
	local LimitTime = VM.LimitTime
	if LimitTime ~= 0 then
		if LimitTime and LimitTime > TimeUtil.GetServerLogicTime() then
			--显示剩余时间可接取
			local RawText = ""
			local Second = LimitTime - TimeUtil.GetServerLogicTime()
			local Number = 0
			if Second >= 3600 then
				Number = math.ceil(Second / 3600)
				RawText = string.format(LSTR(TextHourLimitTimeAccept), Number)
			else
				Number = math.ceil(Second / 60)
				RawText = string.format(LSTR(TextMinuteLimitTimeAccept), Number)
			end
			local RichText = RichTextUtil.GetText(RawText, nil, "187EB9FF", 2)
			self.RichTextState:SetText(RichText)
			UIUtil.SetIsVisible(self.ImgStateBg, false)
			UIUtil.SetIsVisible(self.QuestState, true)

			self.LastNumber = Number

			self:RegisterTimer(self.OnSecond, 1, 1, -1)
			return
        end
	end

	local MapID = VM.MapID
	--显示接取的地名
	local MapName = ""
	if (MapID or 0) > 0 then
		MapName = MapCfg:FindValue(MapID, "DisplayName")
	end
	local RawText = string.format(TextAcceptable, MapName)
	local RichText = RichTextUtil.GetText(RawText, nil, "449342FF", 2)
	self.RichTextState:SetText(RichText)
	UIUtil.SetIsVisible(self.ImgStateBg, false)
	UIUtil.SetIsVisible(self.QuestState, true)
end

function MainQuestItemView:OnSecond()
	local _ <close> = CommonUtil.MakeProfileTag("sammrli_MainQuestItemView_OnSecond")
	if self.Params then
		local MainlineVM = self.Params.MainlineVM
		if MainlineVM then
			local ServerTime = TimeUtil.GetServerLogicTime() - 1 --减1秒前后台误差
			local LimitTime =  MainlineVM.LimitTime
			if LimitTime > ServerTime then
				local Second = LimitTime - ServerTime
				local Number = 0
				local IsHour = false
				if Second >= 3600 then
					Number = math.ceil(Second / 3600)
					IsHour = true
				else
					Number = math.ceil(Second / 60)
				end
				if Number ~= self.LastNumber then
					local RawText = nil
					if IsHour then
						RawText = string.format(LSTR(TextHourLimitTimeAccept), Number)
					else
						RawText = string.format(LSTR(TextMinuteLimitTimeAccept), Number)
					end
					local RichText = RichTextUtil.GetText(RawText, nil, "187EB9FF", 2)
					self.RichTextState:SetText(RichText)
				end
				self.LastNumber = Number
			else
				self:UnRegisterAllTimer()
				local co = coroutine.create(_G.QuestMgr.OnQuestConditionUpdate)
        		_G.SlicingMgr:EnqueueCoroutineAndExecOnce(co, _G.QuestMgr, false, true)
				self:SetStateAcceptable(MainlineVM)
				self.QuestTitle:PlayAnimTrack()
			end
		end
	else
		self:UnRegisterAllTimer()
	end
end

---已完成所有主线
function MainQuestItemView:SetStateFinishAll()
	self.RichTextState:SetText(RichTextUtil.GetText(QuestDefine.MainlineOverText2, nil, nil, 0))
	UIUtil.SetIsVisible(self.ImgStateBg, true)
	UIUtil.SetIsVisible(self.QuestState, true)
end

function MainQuestItemView:OnGameEventStartAutoPathMove(EventParam)
	if not EventParam or EventParam.TargetType ~= AutoMoveTargetType.Task then
		return
	end
	if self.Params == nil then return end

	local TrackingChapterID = _G.QuestTrackMgr.AutoPathTrackChapterID
	local MainlineVM = self.Params.MainlineVM
	if MainlineVM then
		if TrackingChapterID and MainlineVM.ChapterID == TrackingChapterID then
			self.QuestTitle:SwitchAutoFindStatus(true)
		else
			self.QuestTitle:SwitchAutoFindStatus(false)
		end
	end
	local OtherVM = self.Params.OtherVM
	if OtherVM then
		if TrackingChapterID and OtherVM.ChapterID == TrackingChapterID then
			self.QuestTitle:SwitchAutoFindStatus(true)
		else
			self.QuestTitle:SwitchAutoFindStatus(false)
		end
	end
end

function MainQuestItemView:OnGameEventStopAutoPathMove()
	self.QuestTitle:SwitchAutoFindStatus(false)
end

-----------------------------------

local UIBindableList = require("UI/UIBindableList")
local QuestTargetVM = require("Game/Quest/VM/DataItemVM/QuestTargetVM")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local TARGET_TYPE = ProtoRes.QUEST_TARGET_TYPE
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS

---临时功能，职业不满足且需要进入副本时切换目标描述
function MainQuestItemView:TempChangeTargetVMList()
	if self.Params == nil then return end
	local VM = self.Params.MainlineVM or self.Params.OtherVM
	if VM == nil then return end
	local Quest = _G.QuestMgr.QuestMap[VM.QuestID]
	if Quest == nil then return end

	self.TargetVMListCache = self.TargetVMListCache or nil

	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if RoleSimple == nil then return end
	local CurrProf = RoleSimple.Prof
	local bCombatProf = _G.ProfMgr.CheckProfClass(CurrProf, 8)

	local bTargetFinishPWorld = false
	local MapIDList = nil
	local TargetID = nil
	for _, Target in pairs(Quest.Targets) do
		local TargetType = Target.Cfg.m_iTargetType
		if TargetType == TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_SPACE
		and Target.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS then
			bTargetFinishPWorld = true
			MapIDList = Target:GetMapIDList()
			TargetID = Target.TargetID
			break
		end
	end

	if bTargetFinishPWorld and (not bCombatProf) then
		if not self.TargetVMListCache then
			self.TargetVMListCache = VM.TargetVMList
			self.ChapterIDCache = VM.ChapterID

			local NewVM = QuestTargetVM.New()
			NewVM.TargetID = TargetID
			NewVM.OverDesc = TextSwitchProf
			NewVM.OwnerChapterVM = VM
			NewVM.MapIDList = MapIDList
			local NewVMList = UIBindableList.New(QuestTargetVM)
			NewVMList:UpdateByValues({ NewVM })

			VM.TargetVMList = NewVMList
		end

	elseif self.TargetVMListCache then
		if VM.ChapterID == self.ChapterIDCache then
			VM.TargetVMList = self.TargetVMListCache
			self.TargetVMListCache = nil
			self.ChapterIDCache = nil
		end
	end
end

return MainQuestItemView