---
--- Author: muyanli
--- DateTime: 2024-08-08 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class RecordPlayControlPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonExit UButton
---@field PlaySpeedTxt UTextBlock
---@field SliderBar CommSliderHorizontalView
---@field ToggleBtnPlay UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RecordPlayControlPanelView = LuaClass(UIView, true)

function RecordPlayControlPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonExit = nil
	--self.PlaySpeedTxt = nil
	--self.SliderBar = nil
	--self.ToggleBtnPlay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RecordPlayControlPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SliderBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RecordPlayControlPanelView:OnInit()
	self.SliderMinValue = 1
    self.SliderMaxValue = 16
	self.IsPause = false
	self:InitSlider()
    self.SliderBar:SetValueChangedCallback(function(v)
        self:OnValueChangedSlider(v)
    end)
end


function RecordPlayControlPanelView:InitSlider()
	self.SliderBar:SetValue(0)
	self:OnValueChangedSlider(0)
end


function RecordPlayControlPanelView:OnValueChangedSlider(Value)
    local PlaySpeed = self.SliderMinValue + math.ceil(Value * (self.SliderMaxValue - self.SliderMinValue))
    _G.LevelRecordMgr:ChangePlaySpeed(PlaySpeed)
    self.PlaySpeedTxt:SetText("x " .. PlaySpeed)
end

function RecordPlayControlPanelView:OnDestroy()

end

function RecordPlayControlPanelView:OnShow()
	self.SliderBar:SetValue(0)
end

function RecordPlayControlPanelView:OnHide()
	self.SliderBar:SetValue(0)
end

function RecordPlayControlPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnPlay, self.OnClickBtnPause)
end

function RecordPlayControlPanelView:OnRegisterGameEvent()

end

function RecordPlayControlPanelView:OnRegisterBinder()

end

function RecordPlayControlPanelView:OnClickBtnPause()
	_G.LevelRecordMgr:PauseOrResumeRecord()
	self.IsPause=not self.IsPause
	local BtnState = 1
	if self.IsPause then
		BtnState = 0
	end
	self.ToggleBtnPlay:SetCheckedState(BtnState)
end

return RecordPlayControlPanelView