---
--- Author: Administrator
--- DateTime: 2024-07-08 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoDarkEdgeVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

---@class PhotoFilterPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewFilter UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoFilterPanelView = LuaClass(UIView, true)

function PhotoFilterPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewFilter = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoFilterPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoFilterPanelView:OnInit()
	PhotoFilterVM = _G.PhotoFilterVM
	self.AdpFilter 				= UIAdapterTableView.CreateAdapter(self, self.TableViewFilter, self.OnAdpItemFilter)

	self.BinderFilter = 
	{
		{ "FilterList", 		UIBinderUpdateBindableList.New(self, self.AdpFilter) },
		{ "CurFilterIdx",     	UIBinderSetSelectedIndex.New(self, self.AdpFilter, true)},
		{ "FilterAlpha",     	UIBinderSetSlider.New(self, self.Slider)},
		{ "FilterAlpha",     	UIBinderSetPercent.New(self, self.ProbarTransparency)},

		{ "FilterAlphaText",    UIBinderSetText.New(self, self.TextAngleNumber)},
		{ "IsShowAngPanel", 	UIBinderSetIsVisible.New(self, self.PanelAngle) },
	}
end

function PhotoFilterPanelView:OnDestroy()

end

function PhotoFilterPanelView:OnShow()
end

function PhotoFilterPanelView:OnHide()

end

function PhotoFilterPanelView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedScale)
end

function PhotoFilterPanelView:OnRegisterGameEvent()

end

function PhotoFilterPanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoFilterVM, 		self.BinderFilter)
end

function PhotoFilterPanelView:OnAdpItemFilter(Idx, ItemVM)
	PhotoFilterVM:SetFilterIdx(Idx)
end

function PhotoFilterPanelView:OnValueChangedScale(_, Value)
	PhotoFilterVM:SetFilterAlpha(Value)
end



return PhotoFilterPanelView