--- Author: Administrator
--- DateTime: 2025-06-27 17:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

local PhotoEditMainVM


---@class PhotoEditMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnRefresh UFButton
---@field BtnSave CommBtnLView
---@field CommBackBtn CommBackBtnView
---@field CommSingle CommSingleBoxView
---@field CommonTitle CommonTitleView
---@field PhotoEditPanel PhotoRightEditPanelView
---@field TableViewLeftList UTableView
---@field TextTitle1 UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoEditMainView = LuaClass(UIView, true)

function PhotoEditMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnRefresh = nil
	--self.BtnSave = nil
	--self.CommBackBtn = nil
	--self.CommSingle = nil
	--self.CommonTitle = nil
	--self.PhotoEditPanel = nil
	--self.TableViewLeftList = nil
	--self.TextTitle1 = nil
	--self.VerIconTabs = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoEditMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.CommBackBtn)
	self:AddSubView(self.CommSingle)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.PhotoEditPanel)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoEditMainView:OnInit()
	PhotoEditMainVM = _G.PhotoEditMainVM
	self.AdpSubTab = UIAdapterTableView.CreateAdapter(self, self.TableViewLeftList, self.OnSelectItemSubTab)
	self:InitBinder()
	self:InitViewData()
end

function PhotoEditMainView:OnDestroy()

end

function PhotoEditMainView:OnShow()
	PhotoEditMainVM:UpdateVM()
	self:UpdateMainTab()
end

function PhotoEditMainView:OnHide()

end

function PhotoEditMainView:OnRegisterUIEvent()
	self.CommBackBtn:AddBackClick(self, self.OnBtnClose)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnMainTabChange)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingle, self.OnStateChangedToggle)
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickButtonRefresh)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
end

function PhotoEditMainView:OnRegisterGameEvent()

end

function PhotoEditMainView:OnRegisterBinder()
	self:RegisterBinders(PhotoEditMainVM, self.Binder)
end

function PhotoEditMainView:InitBinder()
	self.Binder = {
		{ "SubTabList", UIBinderUpdateBindableList.New(self, self.AdpSubTab) },
		{ "SubTabIdx", UIBinderSetSelectedIndex.New(self, self.AdpSubTab) },
	}
end

function PhotoEditMainView:InitViewData()
	self.CommonTitle:SetTextTitleName(_G.LSTR(630069))
	self.CommonTitle:SetTextSubtitle(_G.LSTR(630070))
	self.CommSingle:SetChecked(true, true)
end

function PhotoEditMainView:OnMainTabChange(MainIndex)
	PhotoEditMainVM:SetMainTabIdx(MainIndex)
end

function PhotoEditMainView:UpdateMainTab()
	self.VerIconTabs:UpdateItems(PhotoDefine.UITabEditCfg, 1)
end

function PhotoEditMainView:OnSelectItemSubTab(SubIndex, ItemVM)
	PhotoEditMainVM:SetSubTabIdx(SubIndex)
end

function PhotoEditMainView:OnBtnClose()
	self:Hide()
end

function PhotoEditMainView:OnStateChangedToggle(ToggleButton, State)
	local IsShow = UIUtil.IsToggleButtonChecked(State)
	self.PhotoEditPanel:SetLinesVisiable(IsShow)
end

function PhotoEditMainView:OnClickButtonRefresh()
	self.PhotoEditPanel:InitFrameSize()
end

function PhotoEditMainView:OnClickButtonSave()
	self.PhotoEditPanel:CalculateCropRange()
	self:Hide()
end

return PhotoEditMainView