---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-12 19:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SignsMainVM = require("Game/Signs/VM/SignsMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class SignsMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field TableViewSigns UTableView
---@field TextDefaultTips UFTextBlock
---@field TextRecommend UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SignsMainPanelView = LuaClass(UIView, true)

function SignsMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrameS_UIBP = nil
	--self.TableViewSigns = nil
	--self.TextDefaultTips = nil
	--self.TextRecommend = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SignsMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SignsMainPanelView:OnInit()
	self.TableAdapterSigns = UIAdapterTableView.CreateAdapter(self, self.TableViewSigns)
	
	self.Binders = {
		{"SinsItems", UIBinderUpdateBindableList.New(self, self.TableAdapterSigns)},
	}
	
end

function SignsMainPanelView:OnDestroy()

end

function SignsMainPanelView:OnShow()
	self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(1240019))		--- "场景标记"
	self.TextDefaultTips:SetText(LSTR(1240042))	--- "选择要标记的目标"
	self.TextRecommend:SetText(LSTR(1240020))	--- "选择标记"
	SignsMainVM:OnInitViewData()

	--- 打开时获取是否已经选择目标
	local TargetID = _G.SignsMgr.TargetID
	local IsSelectedTarget = TargetID ~= 0
	if IsSelectedTarget then
		_G.FLOG_INFO("SignsMainPanelView:OnShow, To InteractiveMgr, Hide InteractiveMainPanel")
		_G.UIViewMgr:HideView(_G.UIViewID.InteractiveMainPanel)
	end
	self:OnChangedSelectState(IsSelectedTarget)
	self:CheckItemUsedState()
end

function SignsMainPanelView:OnHide()
	_G.SignsMgr.TargetSignsMainPanelIsShowing = false
	_G.FLOG_INFO("SignsMainPanelView:OnHide, To InteractiveMgr, Show InteractiveMainPanel")
    _G.UIViewMgr:ShowView(_G.UIViewID.InteractiveMainPanel)
end

function SignsMainPanelView:OnRegisterUIEvent()
	
end

function SignsMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamSignsSelectedCancle, self.OnCancleSelected)
	self:RegisterGameEvent(_G.EventID.TeamSignsSelected, self.OnSelectedChanged)
	self:RegisterGameEvent(_G.EventID.TargetChangeMajor, function(self, TatgetID) self:OnChangedSelectState(TatgetID ~= 0) end)
end

function SignsMainPanelView:OnRegisterBinder()
	self:RegisterBinders(SignsMainVM, self.Binders)
end

function SignsMainPanelView:CheckItemUsedState()
	local GetTargetList = _G.SignsMgr:GetTargetList()
    if nil == GetTargetList then return end
	for index, _ in pairs(GetTargetList) do
		SignsMainVM:OnSetItemUsedState(index, true)
	end
end

function SignsMainPanelView:OnChangedSelectState(IsSelected)
	UIUtil.SetIsVisible(self.TextDefaultTips, not IsSelected)
	UIUtil.SetIsVisible(self.TextRecommend, IsSelected)
end

function SignsMainPanelView:OnCancleSelected()
	self.TextRecommend:SetText(LSTR(1240020))	--- "选择标记"
end

function SignsMainPanelView:OnSelectedChanged(Text)
	self.TextRecommend:SetText(Text)
end

return SignsMainPanelView