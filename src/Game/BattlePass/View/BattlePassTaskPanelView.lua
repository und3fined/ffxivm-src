---
--- Author: Administrator
--- DateTime: 2025-05-22 15:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local BattlePassMainVM = require("Game/BattlePass/VM/BattlePassMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ProtoCS = require("Protocol/ProtoCS")

---@class BattlePassTaskPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGetAll02 CommBtnMView
---@field BtnReward UFButton
---@field CanvasPanel_0 UCanvasPanel
---@field CommDropDownList4 CommDropDownListView
---@field EFF1 UFCanvasPanel
---@field EffectSelectDown UFCanvasPanel
---@field EffectSelectUp UFCanvasPanel
---@field ImgGot UFImage
---@field ImgReward UFImage
---@field PanelDropDownList UFCanvasPanel
---@field PanelTask UFCanvasPanel
---@field RedDotChallenge CommonRedDotView
---@field RedDotWeek CommonRedDotView
---@field RedDot_2 CommonRedDotView
---@field TableViewTask UTableView
---@field TextChallenge UFTextBlock
---@field TextCountDownDate UFTextBlock
---@field TextWeek UFTextBlock
---@field Textcheckin UFTextBlock
---@field ToggleBtnChallenge UToggleButton
---@field ToggleBtnWeek UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassTaskPanelView = LuaClass(UIView, true)

function BattlePassTaskPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGetAll02 = nil
	--self.BtnReward = nil
	--self.CanvasPanel_0 = nil
	--self.CommDropDownList4 = nil
	--self.EFF1 = nil
	--self.EffectSelectDown = nil
	--self.EffectSelectUp = nil
	--self.ImgGot = nil
	--self.ImgReward = nil
	--self.PanelDropDownList = nil
	--self.PanelTask = nil
	--self.RedDotChallenge = nil
	--self.RedDotWeek = nil
	--self.RedDot_2 = nil
	--self.TableViewTask = nil
	--self.TextChallenge = nil
	--self.TextCountDownDate = nil
	--self.TextWeek = nil
	--self.Textcheckin = nil
	--self.ToggleBtnChallenge = nil
	--self.ToggleBtnWeek = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassTaskPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGetAll02)
	self:AddSubView(self.CommDropDownList4)
	self:AddSubView(self.RedDotChallenge)
	self:AddSubView(self.RedDotWeek)
	self:AddSubView(self.RedDot_2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassTaskPanelView:OnInit()
	self.CurTaskToggleIndex = BattlePassDefine.TaskType.Weekly
	-- 周任务/挑战任务List
	self.TableViewTaskAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask)
	self.ViewModel = BattlePassMainVM
end

function BattlePassTaskPanelView:OnDestroy()

end

function BattlePassTaskPanelView:OnShow()
	self.RedDotWeek:SetRedDotIDByID(BattlePassDefine.RedDotID.Week)
	self.RedDotChallenge:SetRedDotIDByID(BattlePassDefine.RedDotID.Challenge)
	self.CurWeekIndex = 0
	self:InitText()

	self:InitWeekDropdownList()
	self.ViewModel:UpdateTaskList(self.CurTaskToggleIndex, self.CurWeekIndex)
	self:StartBattlePassWeekCountdown()
end

function BattlePassTaskPanelView:OnHide()

end

function BattlePassTaskPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGetAll02.Button, self.OnClickedGetAllBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnReward, self.OnClickedBtnWeeklySignIn)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnWeek, self.OnClickedToggleBtnWeek)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnChallenge, self.OnClickedToggleBtnChallenge)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList4, self.OnFilterTaskWeekIndexChanged)
end

function BattlePassTaskPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BattlePassTaskUpdate, self.OnBattlePassTaskUpdate)
end

function BattlePassTaskPanelView:OnRegisterBinder()
	local Binders = {
		{"WeekSignEff", UIBinderSetIsVisible.New(self, self.EFF1, true)},
		{"WeekSignEff", UIBinderSetIsVisible.New(self, self.ImgGot)},
		{"GetTaskAllVisible",UIBinderSetIsVisible.New(self, self.BtnGetAll02)},
		{"TaskList", UIBinderUpdateBindableList.New(self, self.TableViewTaskAdapter)},
		{"PanelDropDownVisible", UIBinderSetIsVisible.New(self, self.PanelDropDownList)},
		{"TaskWeekToggleChecked", UIBinderSetIsChecked.New(self, self.ToggleBtnWeek, true)},
		{"TaskWeekToggleChecked", UIBinderSetIsChecked.New(self, self.ToggleBtnChallenge, true, true)},
		{"NextWeekCountDown", UIBinderSetText.New(self, self.TextCountDownDate)},
	}

	self:RegisterBinders(self.ViewModel, Binders)

end

function BattlePassTaskPanelView:InitText()
	self.Textcheckin:SetText(_G.LSTR(850026)) --每周签到
	self.TextWeek:SetText(_G.LSTR(850023))	-- 本周
	self.TextChallenge:SetText(_G.LSTR(850024)) --挑战
	self.BtnGetAll02:SetText(_G.LSTR(850041)) --一键领取
end

local function numberToChinese(num)
	local LSTRList = {
	}
	for i = 850054, 850105, 1 do
		table.insert(LSTRList, _G.LSTR(i))
	end
    return LSTRList[num]
end

function BattlePassTaskPanelView:InitWeekDropdownList()
	if BattlePassMgr:GetSeasonID() == 0 then
		return
	end
	local StartTime = BattlePassMgr:GetBattlePassStartTime()

	local CurTime =TimeUtil.GetServerLogicTime()
	local Len = (CurTime - TimeUtil.GetTimeFromString(StartTime)) / (60 * 60 * 24 * 7)
	local ItemList = {}
	for index = 0, math.ceil(Len) do
		local Item = {}
		Item.ID = index
		Item.Name = index == 0 and _G.LSTR(850047) or numberToChinese(index)
		table.insert(ItemList, Item)
	end

	self.CommDropDownList4:UpdateItems(ItemList, 1) 
end

-- 每日签到
function BattlePassTaskPanelView:OnClickedBtnWeeklySignIn()
	if not BattlePassMgr:GetBattlePassWeekSign() then
		BattlePassMgr:SendBattlePassWeekSignReq()
	end
end

function BattlePassTaskPanelView:OnClickedGetAllBtn()
	local NodeIDs = {}

	local List1 = BattlePassMgr:GetTaskList(BattlePassDefine.TaskType.Weekly)
	local List2 = BattlePassMgr:GetTaskList(BattlePassDefine.TaskType.Challenge)
	for _, v in ipairs(List1) do
		if v.Nodes.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			table.insert(NodeIDs, v.Nodes.Head.NodeID)
		end
	end
	for _, v in ipairs(List2) do
		if v.Nodes.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			table.insert(NodeIDs, v.Nodes.Head.NodeID)
		end
	end
	BattlePassMgr:SendGetAllTaskReward(NodeIDs)
end

function BattlePassTaskPanelView:OnClickedToggleBtnWeek(ToggleButton, State)
	if self.CurTaskToggleIndex ==  BattlePassDefine.TaskType.Weekly then
		return
	end
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self.ViewModel.TaskWeekToggleChecked = IsChecked
	self.ViewModel.PanelDropDownVisible = IsChecked
	self.CurTaskToggleIndex =  BattlePassDefine.TaskType.Weekly
	self.TableViewTaskAdapter:ClearChildren()
	self.ViewModel:UpdateTaskList(self.CurTaskToggleIndex, self.CurWeekIndex)

	-- 更新时间
	local EndTime = BattlePassMgr:GetBattlePassEndTime()
	local Timestamp1 = self:Get_seconds_until_next_update_time(EndTime)
	local Timestamp = TimeUtil.GetTimeFromString(EndTime)
	local Servertime = TimeUtil.GetServerLogicTime()
	local TempTime =  Timestamp - Servertime
	if TempTime > 0 then
		local Str = string.format("%s%s", _G.LSTR(850048), LocalizationUtil.GetCountdownTimeForSimpleTime(Timestamp1, self:GetTimeFormat(Timestamp1)))
		self.ViewModel.NextWeekCountDown = Str
	end
end

function BattlePassTaskPanelView:OnClickedToggleBtnChallenge(ToggleButton, State)
	if self.CurTaskToggleIndex ==  BattlePassDefine.TaskType.Challenge then
		return
	end
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self.ViewModel.TaskWeekToggleChecked = not IsChecked
	self.ViewModel.PanelDropDownVisible = not IsChecked
	self.CurTaskToggleIndex =  BattlePassDefine.TaskType.Challenge
	self.TableViewTaskAdapter:ClearChildren()
	self.ViewModel:UpdateTaskList(self.CurTaskToggleIndex, 0)
	self.ViewModel.NextWeekCountDown = _G.LSTR(850109)
end

function BattlePassTaskPanelView:OnFilterTaskWeekIndexChanged(Index, ItemData, ItemView)
	self.CurWeekIndex = ItemData.ID
	self.ViewModel:UpdateTaskList(self.CurTaskToggleIndex,  self.CurTaskToggleIndex == BattlePassDefine.TaskType.Weekly and self.CurWeekIndex or 0)
end

function BattlePassTaskPanelView:StartBattlePassWeekCountdown()
	local Servertime = TimeUtil.GetServerLogicTime()
	if TimeUtil.GetIsCurWeekCycleTime(Servertime) then
		local Timestamp = TimeUtil.GetWeeklyUpdateTimeTotalSecs()
		if Timestamp > 0 then
			if self.BattleRemainWeekTimer ~= nil then
				self:UnRegisterTimer(self.BattleRemainWeekTimer)
				self.BattleRemainWeekTimer = nil
			end
			self.BattleRemainWeekTimer = self:RegisterTimer(self.OnBattlePassRemainWeekCountDown, 0, 1, 1)
		end
	end
end

function BattlePassTaskPanelView:OnBattlePassRemainWeekCountDown()
	local EndTime = BattlePassMgr:GetBattlePassEndTime()
	local Timestamp1 = self:Get_seconds_until_next_update_time(EndTime)
	local Timestamp = TimeUtil.GetTimeFromString(EndTime)
	local Servertime =TimeUtil.GetServerLogicTime()
	local TempTime =  Timestamp - Servertime
	if TempTime > 0 then
		local Str = "" 
		if self.CurTaskToggleIndex == BattlePassDefine.TaskType.Challenge then
			Str = _G.LSTR(850109)
		else
			Str = string.format("%s%s", _G.LSTR(850048), LocalizationUtil.GetCountdownTimeForSimpleTime(Timestamp1, self:GetTimeFormat(Timestamp1)))
		end
		self.ViewModel.NextWeekCountDown = Str
	else
		if self.BattleRemainWeekTimer ~= nil then
			self:UnRegisterTimer(self.BattleRemainWeekTimer)
			self.BattleRemainWeekTimer = nil
		end
	end
end

function BattlePassTaskPanelView:Get_seconds_until_next_update_time(SeasonEndTime)
    local function get_day_of_week(y, m, d)
        if m < 3 then
            m = m + 12
            y = y - 1
        end
        local c = math.floor(y / 100)
        y = y % 100
        local h = d + math.floor((13 * (m + 1)) / 5) + y + math.floor(y / 4) + math.floor(c / 4) + 5 * c
        h = h % 7
        return h
    end

    local timestampe = TimeUtil.GetServerLogicTime()
	local now = os.date("*t", timestampe)
    local y, m, d = now.year, now.month, now.day
    local current_wday = get_day_of_week(y, m, d)

    local days_to_add
	local week_day_index = 5
    if current_wday == week_day_index then -- 周一
        local total_seconds = now.hour * 3600 + now.min * 60 + now.sec
        if total_seconds < 5 * 3600 then
            days_to_add = 0
        else
            days_to_add = 7
        end
    else
        days_to_add = (week_day_index - current_wday) % 7
    end

    local today_0am = os.time{ year = y, month = m, day = d, hour = 0, min = 0, sec = 0 }
    local target_timestamp = today_0am + days_to_add * 86400 + 5 * 3600
    local current_timestamp = os.time(now)

	if SeasonEndTime ~= "" then
		local season_end_time = TimeUtil.GetTimeFromString(SeasonEndTime)
		if season_end_time and season_end_time < target_timestamp then
		    target_timestamp = season_end_time
		end
	end

    return target_timestamp - current_timestamp
end

function BattlePassTaskPanelView:GetTimeFormat(SecondsTime)
	local days = SecondsTime / (24 * 3600)
    if days >= 1 then
        return "d"
    end
    
    local hours = SecondsTime / 3600
    if hours >= 1 then
        return "h"
    end
    
    local minutes = SecondsTime / 60
    if minutes >= 1 then
        return "m"
    end

    return "s"
end

function BattlePassTaskPanelView:OnBattlePassTaskUpdate(IsUpdate)
	self.ViewModel:UpdateTaskList(self.CurTaskToggleIndex, self.CurWeekIndex)
end

return BattlePassTaskPanelView