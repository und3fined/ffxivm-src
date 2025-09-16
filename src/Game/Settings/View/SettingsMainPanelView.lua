---
--- Author: xingcaicao
--- DateTime: 2023-03-20 21:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local SettingsVM = require("Game/Settings/VM/SettingsVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local OperationUtil = require("Utils/OperationUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")

---@class SettingsMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnCustomerService UFButton
---@field CommMenu CommMenuView
---@field CommonBkg01 CommonBkg01View
---@field SettingsSelectionofColorItem SettingsSelectionofColorItmeView
---@field TextCustomerService UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field TreeViewSettings UFTreeView
---@field AnimChangePage UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsMainPanelView = LuaClass(UIView, true)

function SettingsMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnCustomerService = nil
	--self.CommMenu = nil
	--self.CommonBkg01 = nil
	--self.SettingsSelectionofColorItem = nil
	--self.TextCustomerService = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.TreeViewSettings = nil
	--self.AnimChangePage = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommonBkg01)
	self:AddSubView(self.SettingsSelectionofColorItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsMainPanelView:OnInit()
    self.TreeAdapterSettings = UIAdapterTreeView.CreateAdapter(self, self.TreeViewSettings)
end

function SettingsMainPanelView:OnDestroy()

end

function SettingsMainPanelView:OnShow()
	self.MenuDataList = SettingsVM.CategoryList

    local function DelayShowMenu()
		self.TimerID1 = nil
		self.CommMenu:UpdateItems(self.MenuDataList)
    end

    self.TimerID1 = self:RegisterTimer(DelayShowMenu, 0.1, 1, 1)

    local function DelayShowTabContent()
		self.TimerID2 = nil
		self.CommMenu:SetSelectedIndex(1)
    end

    self.TimerID2 = self:RegisterTimer(DelayShowTabContent, 0.2, 1, 1)
	
	self.CommonTitle:SetTextTitleName(_G.LSTR(110041))	--设置
	-- self.TextTitle:SetText(_G.LSTR(110041))	--设置
	self.TextCustomerService:SetText(_G.LSTR(110042))	--联系客服

	if nil ~= OperationUtil.IsEnableCustomService and not OperationUtil.IsEnableCustomService() then
		UIUtil.SetIsVisible(self.BtnCustomerService, false)
	end
end

function SettingsMainPanelView:OnHide()
	if self.TimerID1 then
		self:UnRegisterTimer(self.TimerID1)
		self.TimerID1 = nil
	end

	if self.TimerID2 then
		self:UnRegisterTimer(self.TimerID2)
		self.TimerID2 = nil
	end

	_G.SettingsMgr:ApplyPicSetting()
end

function SettingsMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnClickedEvent(self, self.BtnCustomerService, self.OnClickBtnCustomerService)
end

function SettingsMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.AttackEffectChange, self.OnGameEventAttackEffectChange)

end

function SettingsMainPanelView:OnRegisterBinder()
	local Binders = {
        {"CurSubCategoryVM", 	UIBinderUpdateBindableList.New(self, self.TreeAdapterSettings)},
	}

	self:RegisterBinders(SettingsVM, Binders)
end

function SettingsMainPanelView:OnGameEventAttackEffectChange(Params)
	if nil == Params then
		return
	end

	if ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE == Params.EffectType then
		if MajorUtil.IsMajor(Params.BehitObjID) then
			local CommonMsgBoxView = _G.UIViewMgr:FindView(_G.UIViewID.CommonMsgBox)
			if CommonMsgBoxView and CommonMsgBoxView.bStartTimer then
				_G.MsgBoxUtil.CloseMsgBox()
				MsgTipsUtil.ShowErrorTips(_G.LSTR(110022))
			end
		end
	end
end

function SettingsMainPanelView:OnSelectionChangedCommMenu(Index, _, _, _, _, IsByClick)
	if nil == Index then
		return
	end

	local ItemData = self.MenuDataList[Index]
	if nil == ItemData then
		return
	end

	if IsByClick then
		DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.SettingTab), 0, Index)
	end

	--子标题
	self.CommonTitle:SetTextSubtitle(ItemData.Name or "")
	-- self.TextSubTitle:SetText(ItemData.Name or "")

	SettingsVM:SetCategory(ItemData.Category)
	SettingsVM:UpdateItemList()

	--播放动效
	self:PlayAnimation(self.AnimChangePage)
end

---显示调色盘界面
---@param ColorID number 初始选中的ColorID
---@param Obj table 回调对象
---@param Callback function 回调函数，关闭调色盘时触发，参数为ColorID
function SettingsMainPanelView:ShowColorPalette(ColorID, Obj, Callback)
	self.SettingsSelectionofColorItem:ShowPanel(ColorID, Obj, Callback)
end

function SettingsMainPanelView:OnClickBtnCustomerService()
	OperationUtil.OpenCustomService(OperationUtil.CustomServiceSceneID.Settings)
end

return SettingsMainPanelView