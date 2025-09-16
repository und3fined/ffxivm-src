---
--- Author: chriswang
--- DateTime: 2024-09-24 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local LSTR = _G.LSTR
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle

---@class SettingsItemSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelSlider UFCanvasPanel
---@field SliderBar CommSliderHorizontalView
---@field TextItemContent UFTextBlock
---@field TextSliderValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsItemSliderView = LuaClass(UIView, true)

function SettingsItemSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelSlider = nil
	--self.SliderBar = nil
	--self.TextItemContent = nil
	--self.TextSliderValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsItemSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SliderBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsItemSliderView:OnInit()

end

function SettingsItemSliderView:OnDestroy()

end

function SettingsItemSliderView:OnShow()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.ItemVM = self.Params.Data

	self:SetSlider()
end

function SettingsItemSliderView:OnHide()

end

function SettingsItemSliderView:OnRegisterUIEvent()

end

function SettingsItemSliderView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.QualityLevelChg, self.OnQualityLevelChg)
end

function SettingsItemSliderView:OnRegisterBinder()

end

--画质等级切换，QualityLevel:0-4
function SettingsItemSliderView:OnQualityLevelChg(QualityLevel, Index)
	local SettingCfg = self.ItemVM.SettingCfg
	-- local MaxNum = 0
	if QualityLevel >= 0 and QualityLevel <= 4 then
		-- MaxNum = SettingsUtils.CurSetingCfg.Num[QualityLevel + 1]

		if string.find(SettingCfg.SaveKey, "VisionPlayerNum") then
			self:SetSlider()
			-- self:UpdateMaxNum(SettingCfg, MaxNum, "VisionPlayerNum")
		elseif string.find(SettingCfg.SaveKey, "VisionPetNum") then
			self:SetSlider()
			-- self:UpdateMaxNum(SettingCfg, MaxNum, "VisionPetNum")
		elseif string.find(SettingCfg.SaveKey, "VisionNpcNum") then
			self:SetSlider()
			-- self:UpdateMaxNum(SettingCfg, MaxNum, "VisionNpcNum")
		end
	else
		FLOG_ERROR("setting SetVisionPlayerNum Value(%d) Error", QualityLevel)
	end
end

-- function SettingsItemSliderView:UpdateMaxNum(SettingCfg, MaxNum, SaveKeyStr)
-- 	local ID = SettingCfg.ID
-- 	_G.SettingsMgr.SliderMaxNum[ID] = MaxNum
-- 	FLOG_INFO("setting OnQualityLevelChg %s MaxNum(%d)", SaveKeyStr, MaxNum)
-- 	self.SliderMaxValue = _G.SettingsMgr.SliderMaxNum[ID]

-- 	self:SetSlider()
-- end

---进度条。Value[最大值、默认值]
function SettingsItemSliderView:SetSlider()
	-- 设置描述
	self.TextItemContent:SetText(self.ItemVM.Desc or "")
	
	self.SliderMinValue = tonumber(self.ItemVM.Value[3]) or 0
	-- if self.SliderMinValue <= 0 then
	-- 	self.SliderMinValue = 0
	-- end

	local ID = self.ItemVM.SettingCfg.ID
	if not _G.SettingsMgr.SliderMaxNum[ID] then
		self.SliderMaxValue = tonumber(self.ItemVM.Value[1]) or 1
		if self.SliderMaxValue <= 0 then
			self.SliderMaxValue = 1
		end

		_G.SettingsMgr.SliderMaxNum[ID] = self.SliderMaxValue
	else
		self.SliderMaxValue = _G.SettingsMgr.SliderMaxNum[ID]
	end

	-- 设置值
	local CurValue = SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg)
	if nil == CurValue or CurValue < self.SliderMinValue then
		CurValue = tonumber(self.ItemVM.Value[2]) or self.SliderMinValue
	end

	self:SetSliderValue(CurValue)
	self.TextSliderValue:SetText(CurValue)

	self.SliderBar:SetValueChangedCallback(function (v)
		self:OnValueChangedSlider(v)
	end)

	self.SliderBar:SetCaptureBeginCallBack(function ()
		local CurValue = self.SliderBar:GetValue()
		self:SetCaptureBeginCallBack(CurValue)
	end)
	
	self.SliderBar:SetCaptureEndCallBack(function ()
		local CurValue = self.SliderBar:GetValue()
		local bConfigHotMsgBox = self.ItemVM.SettingCfg.IsConfigHotMsgBox == 1
		if bConfigHotMsgBox then
			local DefaultValue = _G.SettingsMgr:GetDefaultValue(self.ItemVM.SettingCfg)
			local CurIntValue = self:GetValueBySliderValue(CurValue)
			if CurIntValue > DefaultValue then
				-- local function DoCaptureEnd()
				-- 	self:SetCaptureEndCallBack(CurValue)
				-- end

				local function DoCaptureCancel()
					local Percent = (self.ValueBeginCapture - self.SliderMinValue) / (self.SliderMaxValue - self.SliderMinValue) 
					if Percent < 0 then
						Percent = 0
					end
					self.SliderBar:SetValue(Percent)
					self:SetCaptureEndCallBack(Percent)
				end

				MsgBoxUtil.ShowMsgBoxTwoOp(
					self,
					LSTR(110025),
					LSTR(110049),
					nil, --DoCaptureEnd,
					DoCaptureCancel, LSTR(110021), LSTR(110032), {CloseClickCB = DoCaptureCancel})
			end
		end
	end)
end

function SettingsItemSliderView:SetSliderValue( WholeNumber )
	local Percent = (WholeNumber - self.SliderMinValue) / (self.SliderMaxValue - self.SliderMinValue) 
	if Percent < 0 then
		Percent = 0
	end

	self.SliderBar:SetValue(Percent)
end

function SettingsItemSliderView:GetValueBySliderValue(Value)
	return self.SliderMinValue + math.ceil(Value * (self.SliderMaxValue - self.SliderMinValue))
end

function SettingsItemSliderView:OnValueChangedSlider( Value )
	local WholeNumber = self:GetValueBySliderValue(Value)
	self.TextSliderValue:SetText(WholeNumber)
	-- FLOG_INFO("Setting OnValueChanged:%.3f  -- %d", Value, WholeNumber)

	SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, WholeNumber, true, false, true)
end

function SettingsItemSliderView:SetCaptureBeginCallBack(Value)
	local CurNum = tonumber(self.TextSliderValue:GetText())
	self.ValueBeginCapture = CurNum
	-- local WholeNumber = self:GetValueBySliderValue(Value)
	-- FLOG_INFO("Setting ValueBeginCapture:%.3f  -- %d", self.ValueBeginCapture, WholeNumber)
end

function SettingsItemSliderView:SetCaptureEndCallBack(Value)
	self:OnValueChangedSlider(Value)
end

return SettingsItemSliderView