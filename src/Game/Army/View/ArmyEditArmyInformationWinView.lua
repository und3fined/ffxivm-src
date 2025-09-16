---
--- Author: Administrator
--- DateTime: 2025-01-21 20:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ArmyDefine = require("Game/Army/ArmyDefine")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupActivityTimeCfg = require("TableCfg/GroupActivityTimeCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UTF8Util = require("Utils/UTF8Util")

local ArmyMainVM
local ArmyInformationPanelVM
local ArmyEditArmyInformationWinVM

local bNormRecruitSlogan = false
local bLoginNum = false
--- 招募标语最小长度
local Slogin_Min_Limit = nil
--- 招募标语
local Slogin_Max_Limit = nil

local ActivityTimeID = nil
---@class ArmyEditArmyInformationWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSave CommBtnLView
---@field CheckBox01 CommCheckBoxView
---@field CheckBox02 CommCheckBoxView
---@field CheckBox03 CommCheckBoxView
---@field CheckBox04 CommCheckBoxView
---@field CheckBox05 CommCheckBoxView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field Menu CommMenuView
---@field MulitiLineInputBox CommMultilineInputBoxView
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field TableViewMainActiyity UTableView
---@field TableViewRecruitJob UTableView
---@field TextActivityTime UFTextBlock
---@field TextMainActivity UFTextBlock
---@field TextRecruitJob UFTextBlock
---@field TextRecruitState UFTextBlock
---@field TextSlogan UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyEditArmyInformationWinView = LuaClass(UIView, true)

function ArmyEditArmyInformationWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSave = nil
	--self.CheckBox01 = nil
	--self.CheckBox02 = nil
	--self.CheckBox03 = nil
	--self.CheckBox04 = nil
	--self.CheckBox05 = nil
	--self.Comm2FrameL_UIBP = nil
	--self.Menu = nil
	--self.MulitiLineInputBox = nil
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.TableViewMainActiyity = nil
	--self.TableViewRecruitJob = nil
	--self.TextActivityTime = nil
	--self.TextMainActivity = nil
	--self.TextRecruitJob = nil
	--self.TextRecruitState = nil
	--self.TextSlogan = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyEditArmyInformationWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.CheckBox01)
	self:AddSubView(self.CheckBox02)
	self:AddSubView(self.CheckBox03)
	self:AddSubView(self.CheckBox04)
	self:AddSubView(self.CheckBox05)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.Menu)
	self:AddSubView(self.MulitiLineInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyEditArmyInformationWinView:OnInit()
	ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
    ArmyInformationPanelVM = ArmyMainVM:GetArmyInformationPanelVM()
	if ArmyInformationPanelVM then
		ArmyEditArmyInformationWinVM = ArmyInformationPanelVM:GetArmyEditArmyInformationWinVM()
	end
	---活动列表
	self.TableViewActivityAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMainActiyity)
	self.TableViewActivityAdapter:SetOnClickedCallback(self.OnActivityItemClicked)
	---职业列表
	self.TableViewJobAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRecruitJob)
	self.TableViewJobAdapter:SetOnClickedCallback(self.OnJobItemClicked)
	self.Binders = 
	{
		{"ActivityList", UIBinderUpdateBindableList.New(self, self.TableViewActivityAdapter)},
		{"JobList", UIBinderUpdateBindableList.New(self, self.TableViewJobAdapter)},
		{"bRecruitPanel", UIBinderSetIsVisible.New(self, self.Panel02)},
		{"bActivityPanel", UIBinderSetIsVisible.New(self, self.Panel01)},
		{"ActivityTimeType", UIBinderValueChangedCallback.New(self, nil, self.OnActivityTimeTypeChanged)},
		{"IsRecurit", UIBinderValueChangedCallback.New(self, nil, self.OnIsRecuritChanged)},
		{"IsChanged", UIBinderValueChangedCallback.New(self, nil, self.OnIsChangedChanged)},

	}

	ActivityTimeID = {}
	local Cfg = GroupActivityTimeCfg:FindAllCfg()
	for _, ActivityTimeData in ipairs(Cfg) do
		table.insert(ActivityTimeID, ActivityTimeData.ID)
	end
    self.MulitiLineInputBox:SetCallback(self, self.OnSloginTextChanged, self.OnSloginTextComitted)
	---设置招募标语输入框长度限制
	Slogin_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMinLimit)
	Slogin_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMaxLimit)
	self.MulitiLineInputBox.MaxNum = Slogin_Max_Limit
end

function ArmyEditArmyInformationWinView:OnDestroy()

end

function ArmyEditArmyInformationWinView:OnShow()
    self.Menu:CancelSelected()
	self.Menu:UpdateItems(ArmyDefine.EditArmyInformationTabs, false)
	self.Menu:SetSelectedIndex(1)
	---设置默认显示数据
	self.BtnSave:SetText(LSTR(910041))
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(910397))
	---设置招募标语输入框
	UIUtil.SetIsVisible(self.MulitiLineInputBox, true, true)
	self.MulitiLineInputBox:SetHintText(LSTR(910228))
	if ArmyEditArmyInformationWinVM then
		local RecruitSlogan = ArmyEditArmyInformationWinVM:GetRecruitSlogan()
		if RecruitSlogan and RecruitSlogan ~= "" then
			self.MulitiLineInputBox:SetText(RecruitSlogan)
			self.IsInput = false
			self:CheckIsEnabled(RecruitSlogan)
		end
	end
	---设置招募状态item文本
	self.CheckBox01:SetText(LSTR(910393))
	self.CheckBox02:SetText(LSTR(910049))
	---设置活动时间item文本
	local Cfg = GroupActivityTimeCfg:FindAllCfg()
	for _, ActivityTimeData in ipairs(Cfg) do
		local Index = ActivityTimeData.ID + 2
		if self["CheckBox0"..Index] then
			self["CheckBox0"..Index]:SetText(ActivityTimeData.Text)
		end
	end
end

function ArmyEditArmyInformationWinView:OnHide()
	--self.MulitiLineInputBox:SetText("")
	self.IsInput = false
	self.IsWaitCheck = false
end

function ArmyEditArmyInformationWinView:OnRegisterUIEvent()
    UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox01, self.OnOpenRecuritToggleStateChanged)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox02, self.OnCloseRecuritToggleStateChanged)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox03, self.OnActivityTimeToggleStateChanged, ActivityTimeID[1])
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox04, self.OnActivityTimeToggleStateChanged, ActivityTimeID[2])
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox05, self.OnActivityTimeToggleStateChanged, ActivityTimeID[3])

	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedSave)
end

function ArmyEditArmyInformationWinView:OnRegisterGameEvent()

end

function ArmyEditArmyInformationWinView:OnRegisterBinder()
	if nil == ArmyEditArmyInformationWinVM then
        _G.FLOG_ERROR("ArmyEditArmyInformationWinView:OnRegisterBinder ArmyEditArmyInformationWinVM is nil")
        return
    end
    self:RegisterBinders(ArmyEditArmyInformationWinVM, self.Binders)
end

function ArmyEditArmyInformationWinView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)
	local Key = ItemData.Key
    if Key == nil then
        return
    end
	ArmyEditArmyInformationWinVM:OnMenuSelectedChanged(Key)
end

---活动item点击
function ArmyEditArmyInformationWinView:OnActivityItemClicked(Index, ItemData, ItemView)
	local ID = ItemData.ID
	local IsChecked = ItemData:GetIsChecked()
	if ArmyEditArmyInformationWinVM then
		ArmyEditArmyInformationWinVM:UpdaActivitysStateByItemCilcked(ID, IsChecked)
		ArmyEditArmyInformationWinVM:CheckActivitysChanged()
	end
end

---职业item点击
function ArmyEditArmyInformationWinView:OnJobItemClicked(Index, ItemData, ItemView)
	local ID = ItemData.ID
	local IsChecked = ItemData:GetIsChecked()
	if ArmyEditArmyInformationWinVM then
		ArmyEditArmyInformationWinVM:UpdaJobsStateByItemCilcked(ID, IsChecked)
		ArmyEditArmyInformationWinVM:CheckJobsChanged()
	end
end

function ArmyEditArmyInformationWinView:OnActivityTimeTypeChanged(ActivityTimeType)
	if ActivityTimeType then
		local CurIndex = ActivityTimeType + 2
		for i = 3, 5 do
			if self["CheckBox0"..i] then
				self["CheckBox0"..i]:SetChecked(i == CurIndex, false)
			end
		end
	end
end

function ArmyEditArmyInformationWinView:OnIsRecuritChanged(IsRecurit)
	self.CheckBox01:SetChecked(IsRecurit, false)
	self.CheckBox02:SetChecked(not IsRecurit, false)
	self.MulitiLineInputBox:SetIsEnabled(IsRecurit)
	---策划要求关闭招募时活动这边也不能设置
	for i = 3, 5 do
		if self["CheckBox0"..i] then
			self["CheckBox0"..i]:SetIsEnabled(IsRecurit)
		end
	end
end

function ArmyEditArmyInformationWinView:OnIsChangedChanged(IsChanged)
	local IsChanged = ArmyEditArmyInformationWinVM:CheckChanged()
	if IsChanged and bNormRecruitSlogan and bLoginNum then
		self.BtnSave:SetIsRecommendState(true)
	else
		self.BtnSave:SetIsDisabledState(true, true)
	end
end

---开放招募点击
function ArmyEditArmyInformationWinView:OnOpenRecuritToggleStateChanged(ToggleButton, State)
	if ArmyEditArmyInformationWinVM then
		local CurIsRecurit =  ArmyEditArmyInformationWinVM:GetIsRecurit()
		local Checked = State == 1
		if CurIsRecurit ~= Checked then
			if Checked then
				ArmyEditArmyInformationWinVM:SetIsRecurit(Checked)
				self:CheckIsEnabled() --- 注意顺序，此函数必须在招募状态设置完成后（招募文本有效条件依赖招募状态，防止有效检查出错），变化响应之前调用（需要招募文本有效值做判断，防止按钮状态出错）
				ArmyEditArmyInformationWinVM:CheckRecuritChanged()
			else
				---只能通过点击另一个checkbox来关闭招募
				self.CheckBox01:SetChecked(true, false)
			end
		end
	end
end

---关闭招募点击
function ArmyEditArmyInformationWinView:OnCloseRecuritToggleStateChanged(ToggleButton, State)
	if ArmyEditArmyInformationWinVM then
		local CurIsCloseRecurit =  not ArmyEditArmyInformationWinVM:GetIsRecurit()
		local Checked = State == 1
		if CurIsCloseRecurit ~= Checked then
			if Checked then
				ArmyEditArmyInformationWinVM:SetIsRecurit(not Checked)
				self:CheckIsEnabled() --- 注意顺序，此函数必须在招募状态设置完成后（招募文本有效条件依赖招募状态，防止有效检查出错），变化响应之前调用（需要招募文本有效值做判断，防止按钮状态出错）
				ArmyEditArmyInformationWinVM:CheckRecuritChanged()
			else
				---只能通过点击另一个checkbox来开启招募
				self.CheckBox02:SetChecked(true, false)
			end
		end
	end
end

---保存点击
function ArmyEditArmyInformationWinView:OnClickedSave()
	if self.IsWaitCheck or self.IsInput then
		MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InputCheck)
		return
	end
	if bLoginNum == false then
		-- LSTR string:招募标语长度限制%d-%d个字符
		local Message = string.format(LSTR(910139), Slogin_Min_Limit, Slogin_Max_Limit)
		MsgTipsUtil.ShowTips(Message)
		return
	end
	if bNormRecruitSlogan == false then
		-- LSTR string:招募标语的文本不可使用！
		MsgTipsUtil.ShowErrorTips(LSTR(910138))
		return
	end
	if ArmyEditArmyInformationWinVM then
		local IsChanged = ArmyEditArmyInformationWinVM:CheckChanged()
		if IsChanged then
			---todo 等待服务器新协议
			---_G.MsgTipsUtil.ShowTips(LSTR(910399))
			ArmyEditArmyInformationWinVM:Save()
		else
			_G.MsgTipsUtil.ShowTips(LSTR(910398))
		end
	end
end

---招募文本输入响应
function ArmyEditArmyInformationWinView:OnSloginTextComitted(Text)
	self.IsInput = false
	self.IsWaitCheck = true
	bLoginNum = false
	bNormRecruitSlogan = false
	self:CheckIsEnabled(Text)
	if ArmyEditArmyInformationWinVM then
		ArmyEditArmyInformationWinVM:SetRecruitSlogan(Text)
		ArmyEditArmyInformationWinVM:CheckRecuritChanged()
	end
end

---招募文本输入变更响应
function ArmyEditArmyInformationWinView:OnSloginTextChanged()
	self.IsInput = true
	self.BtnSave:SetIsDisabledState(true, true)
end

---活动时间修改响应
function ArmyEditArmyInformationWinView:OnActivityTimeToggleStateChanged(ActivityTimeID, ToggleButton, State)
	if ArmyEditArmyInformationWinVM then
		local CurID = ArmyEditArmyInformationWinVM:GetActivityTimeType()
		local IsChecked = State == 1
		if CurID ~= ActivityTimeID and IsChecked then
			ArmyEditArmyInformationWinVM:SetActivityTimeType(ActivityTimeID)
			ArmyEditArmyInformationWinVM:CheckActivityTimeChanged()
		elseif not IsChecked and CurID == ActivityTimeID then
			---只能通过点击另一个checkbox来切换，不能点击当前的取消
			local Index = ActivityTimeID + 2
			if self["CheckBox0"..Index] then
				self["CheckBox0"..Index]:SetChecked(true, false)
			end
		end
	end
end

---更新按钮状态
function ArmyEditArmyInformationWinView:UpdateBtnState()
	if ArmyEditArmyInformationWinVM then
		local IsChanged = ArmyEditArmyInformationWinVM:CheckChanged()
		if IsChanged and bNormRecruitSlogan and bLoginNum then
			self.BtnSave:SetIsRecommendState(true)
		else
			self.BtnSave:SetIsDisabledState(true, true)
		end
	end
end

---招募敏感词排查/长度排查
function ArmyEditArmyInformationWinView:CheckIsEnabled(Text)
	local RecruitSloganText = Text or self.MulitiLineInputBox:GetText()
	---长度检查
	local Length = UTF8Util.Len(RecruitSloganText)
	local IsRecurit = ArmyEditArmyInformationWinVM:GetIsRecurit()
	if IsRecurit then
		if Length < Slogin_Min_Limit or Length > Slogin_Max_Limit then
			bLoginNum = false
			self.IsWaitCheck = false
			self:UpdateBtnState()
			return
		end
	else
		---关闭不做最小判断
		if Length > Slogin_Max_Limit then
			bLoginNum = false
			self.IsWaitCheck = false
			self:UpdateBtnState()
			return
		end
	end
	bLoginNum = true
	---查询文本是否合法（敏感词）
	_G.ArmyMgr:CheckSensitiveText(RecruitSloganText, function( IsLegal )
		if IsLegal then
			bNormRecruitSlogan = true
		else
			bNormRecruitSlogan = false
			-- LSTR string:招募标语的文本不可使用！
			MsgTipsUtil.ShowErrorTips(LSTR(910138))
		end
		self.IsWaitCheck = false
		self:UpdateBtnState() --- 敏感词回包后刷新一次按钮状态
	end)
end

return ArmyEditArmyInformationWinView