---
--- Author: Administrator
--- DateTime: 2024-11-18 10:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local LevelExpCfg = require("TableCfg/LevelExpCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local TipsUtil = require("Utils/TipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")

local LeveQuestMainPanelVM = require("Game/LeveQuest/VM/LeveQuestMainPanelVM")
local LeveQuestDefine = require("Game/LeveQuest/LeveQuestDefine")
local LeveQuestMgr = require("Game/LeveQuest/LeveQuestMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class LeveQuestMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field BtnClose CommonCloseBtnView
---@field CommonBkg CommonBkg01View
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field ConsignAdd UFTextBlock
---@field ConsignReduce UFTextBlock
---@field DropDownList CommDropDownListView
---@field EffProBar UFCanvasPanel
---@field EffProBarGrop UFCanvasPanel
---@field FButton_147 UFButton
---@field IconJob UFImage
---@field ImgFigure UFImage
---@field PanelContent UFCanvasPanel
---@field PanelTaskQuantity UFCanvasPanel
---@field Panelaccepted UHorizontalBox
---@field ProBar UFProgressBar
---@field SingleBox CommSingleBoxView
---@field TaskInfo1 LeveQuestTaskInfoItemView
---@field TaskInfo2 LeveQuestTaskInfoItemView
---@field TextAccepted UFTextBlock
---@field TextExperience UFTextBlock
---@field TextLevel UFTextBlock
---@field TextPlace UFTextBlock
---@field TextPlaceofIssue UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field AnimConsignAdd UWidgetAnimation
---@field AnimConsignReduce UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---@field AnimProBarControl UWidgetAnimation
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimProbarStart float
---@field ValueAnimProbarEnd float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LeveQuestMainPanelView = LuaClass(UIView, true)

function LeveQuestMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.BtnClose = nil
	--self.CommonBkg = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.ConsignAdd = nil
	--self.ConsignReduce = nil
	--self.DropDownList = nil
	--self.EffProBar = nil
	--self.EffProBarGrop = nil
	--self.FButton_147 = nil
	--self.IconJob = nil
	--self.ImgFigure = nil
	--self.PanelContent = nil
	--self.PanelTaskQuantity = nil
	--self.Panelaccepted = nil
	--self.ProBar = nil
	--self.SingleBox = nil
	--self.TaskInfo1 = nil
	--self.TaskInfo2 = nil
	--self.TextAccepted = nil
	--self.TextExperience = nil
	--self.TextLevel = nil
	--self.TextPlace = nil
	--self.TextPlaceofIssue = nil
	--self.TextQuantity2 = nil
	--self.VerIconTabs = nil
	--self.AnimConsignAdd = nil
	--self.AnimConsignReduce = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBar = nil
	--self.AnimProBarControl = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimProbarStart = nil
	--self.ValueAnimProbarEnd = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LeveQuestMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.SingleBox)
	self:AddSubView(self.TaskInfo1)
	self:AddSubView(self.TaskInfo2)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LeveQuestMainPanelView:OnInit()
	self.LeveQuestVM = LeveQuestMainPanelVM.New()

	self.Binders = {
		{ "ProfIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconJob)},
		{ "ProfLv", UIBinderSetText.New(self, self.TextLevel)},
		{ "ProfExpPercent", UIBinderSetPercent.New(self, self.ProBar)},
		{ "ProfExp", UIBinderSetText.New(self, self.TextExperience)},
		{ "SingleChecked", UIBinderSetIsChecked.New(self,self.SingleBox)},
		{ "QuestPlace", UIBinderSetText.New(self, self.TextPlace)},
		{ "QuestNpcImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgFigure)},
		{ "QuestLimitNum", UIBinderSetText.New(self, self.TextQuantity2)},
		{ "IsEmpty", UIBinderSetIsVisible.New(self, self.BackpackEmpty)},
		-- { "EffProBarVisible", UIBinderSetIsVisible.New(self, self.EffProBar)},
	}

	self.TabRecordList = {}
	self.RefreshTimer = nil
	self.CurLevel  = 1
	self.JumpCfg = nil
end

function LeveQuestMainPanelView:OnDestroy()

end

function LeveQuestMainPanelView:OnShow()
	self.LastChoiceCareer = 0
	if LeveQuestMgr:CheckProfLockedStatus() then
		local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
		if bIsProductProf then
			self.PropID = MajorUtil.GetMajorProfID()
		else
			self.PropID = LeveQuestMgr:GetMaxLevelProfID()   -- 选中的Tab
		end
	end
	
	self:InitText()
	self:InitLevelList()
	self.SingleBox:SetText(_G.LSTR(880005))
	self.LeveQuestVM.SingleChecked = LeveQuestMgr:GetPaySingleOrMost() == LeveQuestDefine.PayType.Single

	if self.Params ~= nil then
		-- 查找奖励物品
		local ItemID = self.Params.JumpItemID
		self.JumpCfg = LeveQuestMgr:GetCfgbyJumpItemID(ItemID)
		if self.JumpCfg == nil then
			_G.FLOG_ERROR("JumpCfg Is nil")
		end

		if self.JumpCfg ~= nil then
			self.ProfID = self.JumpCfg.ProfType
		end
	end
	self.VerIconTabs:UpdateItems(LeveQuestMgr:GetAllCareerData(), LeveQuestMgr:GetCareerIndex(self.PropID))
	self.VerIconTabs:ScrollIndexIntoView(LeveQuestMgr:GetCareerIndex(self.PropID))

	LeveQuestMgr:SendGetLeveQuestData()

end

function LeveQuestMainPanelView:InitText()
	self.TextAccepted:SetText(_G.LSTR(880012))
	self.TextPlaceofIssue:SetText(_G.LSTR(880013))
	self.CommonTitle:SetTextTitleName((_G.LSTR(880019)))
end

function LeveQuestMainPanelView:OnHide()
	self.TabRecordList = {}
	self.JumpCfg = nil
	if self.RefreshTimer ~= nil then
		self:UnRegisterTimer(self.RefreshTimer)
		self.RefreshTimer = nil
	end
end

function LeveQuestMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnCommVerIconTabsChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnFilterQuestLevelChanged)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnPaySettingMoreChanged)
	UIUtil.AddOnClickedEvent(self, self.FButton_147, self.OnClickedBtnLimitInfo)
end

function LeveQuestMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LeveQuestInfoUpdate, self.OnLeveQuestInfoUpdate)
	self:RegisterGameEvent(EventID.LeveQuestListUpdate, self.OnLeveQuestListUpdate)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate) -- 升级
	self:RegisterGameEvent(EventID.MajorExpUpdate, self.OnMajorExpUpdate) -- 经验变动
	self:RegisterGameEvent(EventID.LeveQuestExpUpdate, self.OnMajorExpUpdate) -- 经验变动
	self:RegisterGameEvent(EventID.BagUpdate, self.OnBagItemsUpdate)
	self:RegisterGameEvent(EventID.LeveQuestReduceAnim, self.OnLeveQuestReduceAnim)
end

function LeveQuestMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.LeveQuestVM, self.Binders)
	self.TaskInfo1:SetParams({Data = self.LeveQuestVM.LeveQuestVM1} )
	self.TaskInfo2:SetParams({Data = self.LeveQuestVM.LeveQuestVM2} )
end

function LeveQuestMainPanelView:OnLeveQuestReduceAnim(Num)
	if type(Num) == "number" then
		self.ConsignReduce:SetText(string.format("-%d", Num))
		self:PlayAnimation(self.AnimConsignReduce, 0, 1)
	end
end

function LeveQuestMainPanelView:OnMajorLevelUpdate(Params)

	local OldLevel = Params.OldLevel
	local ProfID = Params.ProfID
    if not ProfUtil.IsProductionProf(ProfID)then
        return
    end

	if ProfID ~= self.ProfID then
		return
	end

	--更新职业变动, 播放动画
	if OldLevel ~= nil then
		self:PlayAnimation(self.AnimProBar, self.AnimProBar:GetEndTime(), 1, nil, 0.0, false)
		self:RegisterTimer(function ()
			self.LeveQuestVM:UpdateProfIcon(ProfID)
			self.LeveQuestVM:UpdateProfLv(ProfID)

			-- 更新当前等级
			local PropLevelInterval = self:GetPropLevelInterval(ProfID)
			if LeveQuestMgr:GetProfUnlockLevel(ProfID) < PropLevelInterval then
				self.DropDownList:CancelSelected()
				self.DropDownList:UpdateItems(self:GetLevelList(ProfID), PropLevelInterval)
				self.DropDownList:SetSelectedIndex(PropLevelInterval)
				LeveQuestMgr:SetProfUnlockLevel(ProfID, PropLevelInterval)
			end

		end, self.AnimProBar:GetEndTime())
	end
end

function LeveQuestMainPanelView:OnMajorExpUpdate(Params)
	if Params == nil then
		return
	end
	local ProfID = self.ProfID
	local CurLevel = LeveQuestMgr:GetProfCurLevel(ProfID)
	local NewExp = Params.ULongParam3

	LeveQuestMgr:SetProfCurExp(ProfID, NewExp)

	local LevelCfg = LevelExpCfg:FindCfgByKey(CurLevel)
	local EndPercent = LevelCfg ~= nil and NewExp/LevelCfg.NextExp  or 1
	if EndPercent > self.ProBar.Percent then
		self:PlayAnimProBar(self.ProBar.Percent, EndPercent)
		self.LeveQuestVM:UpdateExpValue(ProfID, Params)
	else
		self:PlayAnimProBar(self.ProBar.Percent, 1)
		self:RegisterTimer(function ()
			-- 从0到最新
			self.LeveQuestVM:UpdateProfLv(ProfID)
			self:PlayAnimProBar(0, EndPercent)
			self.LeveQuestVM:UpdateExpValue(ProfID, Params)
		end, self.AnimProBar:GetEndTime())
	end
end

function LeveQuestMainPanelView:OnLeveQuestListUpdate()
	-- 更新当前界面数据
	local ProfID = self.ProfID
	self.LeveQuestVM:UpdateProfIcon(ProfID)
	self.LeveQuestVM:UpdateProfLv(ProfID)
	self.LeveQuestVM:UpdateLeveQuestItems(self.ProfID, self.CurLevel)
	self.LeveQuestVM:UpdateLeveQuestInfo()
	self:UpdatePayListSelectIMG()
end

function LeveQuestMainPanelView:OnBagItemsUpdate()
	self:OnLeveQuestListUpdate()
end

function LeveQuestMainPanelView:OnGameEventOnNormalMakeStart()
	self:Hide()
end

function LeveQuestMainPanelView:OnCommVerIconTabsChanged(Index, ItemData, ItemView)
	_G.ObjectMgr:CollectGarbage(false, true, false)
	local ProfID = ItemData.ID
	local ProfName = _G.EquipmentMgr:GetProfName(ProfID)

	if ProfName == nil then
		return
	end

	if self.LeveQuestVM == nil then
		return
	end

	if LeveQuestMgr:GetCareerLocked(ProfID) then
		MsgTipsUtil.ShowTips((string.format(_G.LSTR(880006), ProfName)))
		self.VerIconTabs:SetSelectedIndex(0)
        self.VerIconTabs:SetSelectedIndex(self.LastChoiceCareer)
		self.VerIconTabs:ScrollIndexIntoView(self.LastChoiceCareer)
        return
    end

	self.LastChoiceCareer = LeveQuestMgr:GetCareerIndex(ProfID)

	-- 移除理符红点
	LeveQuestMgr:DelCareerRedDot(ProfID)

	local PropLevelInterval = self.TabRecordList[tostring(self.PropID)] and self.TabRecordList[tostring(ProfID)] or self:GetPropLevelInterval(ProfID)

	if self.JumpCfg ~= nil then
		PropLevelInterval  = self:GetMaxLevelIndex(self.JumpCfg.Level)
		self.JumpCfg = nil
	end

	_G.FLOG_INFO("LeveQuestMainPanelView:OnCommVerIconTabsChanged .. " .. ProfName)
	self.ProfID = ProfID
	self.CommonTitle:SetTextSubtitle(_G.EquipmentMgr:GetProfName(ProfID))

	self.LeveQuestVM:UpdateProfIcon(ProfID)
	self.LeveQuestVM:UpdateProfLv(ProfID)
	self.LeveQuestVM:UpdateExpValue(ProfID)

	-- 更新数据
	self.DropDownList:CancelSelected()
	self.DropDownList:UpdateItems(self:GetLevelList(ProfID), PropLevelInterval)
	self.DropDownList:SetSelectedIndex(PropLevelInterval)

end

-- 筛选等级
function LeveQuestMainPanelView:OnFilterQuestLevelChanged(Index, ItemData, ItemView)
	local ListItemData  = self:GetLevelListItem(Index)
	_G.FLOG_INFO("LeveQuestMainPanelView:OnFilterQuestLevelChanged "..ListItemData.Max)
	-- Todo 更新任务栏
	local Level = ListItemData.Max
	self.CurLevel = Level
	self.TabRecordList[tostring(self.ProfID)] = Index
	self.LeveQuestVM:UpdateLeveQuestItems(self.ProfID, Level)
	self:UpdatePayListSelectIMG()
	-- Todo 更新背景图
	self.LeveQuestVM:UpdateBackground(self.ProfID, Level)
end

function LeveQuestMainPanelView:UpdatePayListSelectIMG()
	self.TaskInfo1:UpdateSelectedImge()
	self.TaskInfo2:UpdateSelectedImge()
end



function LeveQuestMainPanelView:GetPropLevelInterval(PropID)
	local MajorLevel = LeveQuestMgr:GetProfCurLevel(PropID) or 0
	return self:GetMaxLevelIndex(MajorLevel)
end

function LeveQuestMainPanelView:GetMaxLevelIndex(Level)
	local Len = #self.LevelList
	if Level >= self.LevelList[Len].Max then
		return Len
	end

	for index, value in ipairs(self.LevelList) do
		if index ~= Len then
			if Level >= self.LevelList[index].Max and Level <  self.LevelList[index + 1 ].Max then
				return index
			end
		end
	end

	return 1
end

function LeveQuestMainPanelView:OnPaySettingMoreChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	_G.LeveQuestMgr:SetPaySingleOrMost(IsChecked)

	self.TaskInfo1:UpdatePayNum()
	self.TaskInfo2:UpdatePayNum()
end

-- 理符限额
function LeveQuestMainPanelView:OnClickedBtnLimitInfo()
	local Size = UIUtil.GetWidgetSize(self.FButton_147)
	local Content = self:GetTips()
	TipsUtil.ShowInfoTips(Content, self.FButton_147, _G.UE.FVector2D(-Size.X + 10, Size.Y + 10), _G.UE.FVector2D(0, 0), false , {View = self, HidePopUpBGCallback= function ()
		self:ClearRefreshTimer()
		_G.UIViewMgr:HideView(_G.UIViewID.CommHelpInfoTipsView)
		self.RefreshTimer = self:RegisterTimer(self.OnRefreshTime, 0, 1, 0)
	end})

	self:ClearRefreshTimer()
	self.RefreshTimer = self:RegisterTimer(self.OnRefreshTime, 0, 1, 0)
end

function LeveQuestMainPanelView:ClearRefreshTimer()
	if self.RefreshTimer ~= nil then
		self:UnRegisterTimer(self.RefreshTimer)
		self.RefreshTimer = nil
	end
end

function LeveQuestMainPanelView:GetTips()
	local LocalTimeStamp = TimeUtil.GetServerLogicTimeMS()
	local RefreshTime = LeveQuestMgr:GetRefreshTime()
	local RemainTime =  LocalizationUtil.GetCountdownTimeForLongTime( (RefreshTime - LocalTimeStamp)/ 1000)
	local Content = string.format(_G.LSTR(880007), RemainTime)
	return Content
end

function LeveQuestMainPanelView:OnRefreshTime()
	local Time = TimeUtil.GetServerLogicTimeMS()
	local RefreshTime = LeveQuestMgr:GetRefreshTime()
	if Time > RefreshTime then
		-- _G.FLOG_INFO("理符刷新事件到，发送消息")
		LeveQuestMgr:SendGetLeveQuestData()
		self:UnRegisterTimer(self.RefreshTimer)
		self.RefreshTimer = nil
		return
	end

	-- _G.FLOG_INFO("理符刷新时间")

	-- 更新数据
	local View = _G.UIViewMgr:FindView(_G.UIViewID.CommHelpInfoTipsView)
	if View ~= nil then
		View:UpdateData({{Title = "", Content = {self:GetTips()}}} )
	end
end

-- 更新理符基础信息
function LeveQuestMainPanelView:OnLeveQuestInfoUpdate()
	if self.LeveQuestVM == nil then
		return
	end
	
	self.LeveQuestVM:UpdateLeveQuestInfo()
	local View = _G.UIViewMgr:FindView(_G.UIViewID.CommHelpInfoTipsView)
	if View ~= nil then
		View:UpdateData({{Title = "", Content = {self:GetTips()}}} )
	end
	-- 刷新时间
	_G.FLOG_INFO("理符数据收到，开始倒计时")
	self:ClearRefreshTimer()
	self.RefreshTimer = self:RegisterTimer(self.OnRefreshTime, 0, 1, 0)
end

function LeveQuestMainPanelView:InitLevelList()
	local GroupLevel = LeveQuestDefine.LevelGroupLevel
	local LevelList = {}
	local MaxLevel = LevelExpCfg:GetMaxLevel() - 5
	local MinLevel = 0
	for StartLevel = MinLevel, MaxLevel, GroupLevel do
		local Max =  StartLevel == 0 and 1 or StartLevel
		local Item = {
			ID = Max,
			Max = Max,
			Name = string.format(_G.LSTR(880001), Max),
		}
		table.insert(LevelList, Item)
	end

	self.LevelList = LevelList
end

function LeveQuestMainPanelView:GetLevelList()
	return self.LevelList
end

function LeveQuestMainPanelView:GetLevelListItem(Index)
	for index, value in ipairs(self.LevelList) do
		if Index == index then
			return value
		end
	end
end

function LeveQuestMainPanelView:SetDefaultProfID()
	if LeveQuestMgr:CheckProfLockedStatus() then
		local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
		if bIsProductProf then
			self.PropID = MajorUtil.GetMajorProfID()
		else
			self.PropID = LeveQuestMgr:GetMaxLevelProfID()   -- 选中的Tab
		end
	end
end


return LeveQuestMainPanelView