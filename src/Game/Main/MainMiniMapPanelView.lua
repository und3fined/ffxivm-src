--
-- Author: anypkvcai
-- Date: 2020-09-12 15:59:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class MainMiniMapPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MiniMap MiniMapPanelView
---@field ToggleBtnSwitch UToggleButton
---@field Anim1 UWidgetAnimation
---@field Anim2 UWidgetAnimation
---@field Anim3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainMiniMapPanelView = LuaClass(UIView, true)

function MainMiniMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MiniMap = nil
	--self.ToggleBtnSwitch = nil
	--self.Anim1 = nil
	--self.Anim2 = nil
	--self.Anim3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainMiniMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MiniMap)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainMiniMapPanelView:OnInit()
	self.MultiBinders = {
		{
			ViewModel = MainPanelVM,
			Binders = {
				{ "MiniMapPanelVisible", UIBinderSetIsVisible.New(self, self.MiniMap) },
				{ "MiniMapPanelVisible", UIBinderSetIsChecked.New(self, self.ToggleBtnSwitch, false, true) },
			}
		},
	}
end

function MainMiniMapPanelView:OnDestroy()

end

function MainMiniMapPanelView:OnShow()
	MainPanelVM:SetMiniMapPanelVisible(true)
	
end

function MainMiniMapPanelView:OnHide()
	self:StopAllAnimations()
end

function MainMiniMapPanelView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.Btn_MiniMap, self.AddOnClickedMiniMap)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnSwitch, self.OnStateChangedSwitch)
	
end

function MainMiniMapPanelView:OnRegisterGameEvent()

end

function MainMiniMapPanelView:OnRegisterTimer()

end

function MainMiniMapPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
	--self:RegisterBinders(MainPanelVM, self.Binders)
end

function MainMiniMapPanelView:OnStateChangedSwitch(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)

	MainPanelVM:SetMiniMapPanelVisible(not IsChecked)
end

-- 动画结束统一回调
function MainMiniMapPanelView:OnAnimationFinished(Animation)
	
end

return MainMiniMapPanelView