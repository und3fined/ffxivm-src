---
--- Author: ccppeng
--- DateTime: 2024-10-30 14:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
---@class CommSelectSettingsTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSingleBox CommSingleBoxView
---@field PopUpBG CommonPopUpBGView
---@field TableViewSetting UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSelectSettingsTipsView = LuaClass(UIView, true)

function CommSelectSettingsTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSingleBox = nil
	--self.PopUpBG = nil
	--self.TableViewSetting = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

end

function CommSelectSettingsTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSingleBox)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSelectSettingsTipsView:OnInit()
	self.TableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSetting)
end


function CommSelectSettingsTipsView:OnDestroy()

end

function CommSelectSettingsTipsView:OnShow()

end

function CommSelectSettingsTipsView:OnHide()
    if self.ViewModel ~= nil then
	    self.ViewModel:ClearListData()
    end
end

function CommSelectSettingsTipsView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox, self.OnAutoUseStateChange )
	self.PopUpBG.HideOnClick = false
	self.PopUpBG:SetCallback(self, self.OnHideSettingTips)
end
function CommSelectSettingsTipsView:OnHideSettingTips()
	if self.ViewModel ~= nil then
	    self.ViewModel:HideSelf()
    end
end
function CommSelectSettingsTipsView:OnAutoUseStateChange(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		if self.ViewModel:GetCurrentChooseType() == 0  then
			self.CommSingleBox:UpdateColor(IsChecked)
			self.ViewModel:SelectDefaultElem()
		end
	else
		self.CommSingleBox:UpdateColor(IsChecked)
		self.ViewModel:CancelAllSelected()
		self.ViewModel:CallSettingFunction(self.ViewModel:GetEmptyIndexDefaultElem())
	end
end

function CommSelectSettingsTipsView:OnRegisterGameEvent()

end
function CommSelectSettingsTipsView:UpdateViewModel(InViewModel)
	self.ViewModel = InViewModel
end
function CommSelectSettingsTipsView:OnRegisterBinder()

	self.CustomBinders = {
		{ "ListSettingTipsItemVM", UIBinderUpdateBindableList.New(self, self.TableView) },
		{ "bAutoUseSelect", UIBinderSetCheckedState.New(self, self.CommSingleBox, true) },

	}
	self.CommSingleBox:SetText(self.ViewModel.AutoUseInRainTitle)

	self:RegisterBinders(self.ViewModel, self.CustomBinders)

end

return CommSelectSettingsTipsView