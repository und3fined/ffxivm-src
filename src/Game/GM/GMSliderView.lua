---
--- Author: eddardchen
--- DateTime: 2021-03-25 11:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
---@class GMSliderView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CurrentValueText UTextBlock
---@field GMSlider USlider
---@field MaximumText UTextBlock
---@field MinimumText UTextBlock
---@field SliderText UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMSliderView = LuaClass(UIView, true)

function GMSliderView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CurrentValueText = nil
	--self.GMSlider = nil
	--self.MaximumText = nil
	--self.MinimumText = nil
	--self.SliderText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.IsWeatherSlider = false
end

function GMSliderView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMSliderView:OnInit()
end

function GMSliderView:OnDestroy()
end

function GMSliderView:OnShow()
	-- self.SliderText:SetText(self.Params.Desc)
	-- self.MinimumText:SetText(tostring(self.Params.Minimum))
	-- self.MaximumText:SetText(tostring(self.Params.Maximum))
	-- GMMgr:SetCacheValue(self.Params.ID, self.Params.DefaultValue)
	-- self:UpdateView(true)
end

function GMSliderView:OnHide()
end

function GMSliderView:OnRegisterUIEvent()
	-- UIUtil.AddOnEndSliderMovementEvent(self, self.GMSlider, self.OnSliderValueChange)
	UIUtil.AddOnValueChangedEvent(self, self.GMSlider, self.OnSliderValueChange)
end

function GMSliderView:OnRegisterGameEvent()

end

function GMSliderView:OnRegisterTimer()

end

function GMSliderView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	local Binders =
	{
		-- { "Desc", UIBinderSetText.New(self, self.Desc) },
		-- { "Minimum", UIBinderSetText.New(self, self.Minimum) },
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDValueChangedCallback) },

	}

	self:RegisterBinders(ViewModel, Binders)
end

function GMSliderView:OnIDValueChangedCallback()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self.SliderText:SetText(ViewModel.Params.Desc)

	if ViewModel.Params.Minimum ~= nil then
		self.MinimumText:SetText(tostring(ViewModel.Params.Minimum))
	end

	if ViewModel.Params.Maximum ~= nil then
		self.MaximumText:SetText(tostring(ViewModel.Params.Maximum))
	end

	_G.GMMgr:SetCacheValue(ViewModel.Params.ID, ViewModel.Params.DefaultValue)
	self:UpdateView(true)
end

function GMSliderView:ReqGM(CmdList)
	if string.find(CmdList, "|") ~= nil then
        CmdList = string.split(CmdList, "|")
        for i = 1, #(CmdList) do
			self:ReqGM(CmdList[i])
        end
    else
        _G.GMMgr:ReqGM(CmdList)
    end
end

local lastSendTime = 0
function GMSliderView:OnSliderValueChange()
	local sendTime = _G.TimeUtil.GetLocalTimeMS()
    if sendTime - lastSendTime < 50 then
        return
    end
    lastSendTime = sendTime

	local nextValuef = (self.ViewModel.Params.Maximum - self.ViewModel.Params.Minimum) * self.GMSlider:GetValue() + self.ViewModel.Params.Minimum
	local nextValueS = string.format("%.2f",nextValuef)
	_G.GMMgr:SetCacheValue(self.ViewModel.Params.ID, nextValuef)
	self:UpdateView(false)
	local CmdList = ""
	-- replace all {*} with nextValue and save into CmdList 
	local ptr = 1
	while ptr <= #self.ViewModel.Params.CmdList do
		if "{" ~= string.sub(self.ViewModel.Params.CmdList, ptr, ptr) then
			CmdList = CmdList .. string.sub(self.ViewModel.Params.CmdList, ptr, ptr)
			ptr = ptr + 1
		else
			local nptr = ptr
			while nptr + 1 <= #self.ViewModel.Params.CmdList and "}" ~= string.sub(self.ViewModel.Params.CmdList, nptr, nptr) do
				nptr = nptr + 1
			end
			CmdList = CmdList .. tostring(nextValueS)
			ptr = nptr + 1
		end
	end
	self:ReqGM(CmdList)
end

function GMSliderView:UpdateView(bUI)
	local ViewModel = self.ViewModel
	local lastValue = _G.GMMgr:GetCacheValue(ViewModel.Params.ID)
	if nil == lastValue then return end
	self.CurrentValueText:SetText(tostring(lastValue))

	if self.IsWeatherSlider then
		local hour,mins = math.modf(lastValue)
		local secs = math.floor(mins * 3600)
		local secs1,sces2 = math.modf(secs/60)
		self.CurrentValueText:SetText(tostring(hour).."小时"..tostring(secs1).."分")
	end

	if bUI then
		local Params = ViewModel.Params
		local Minimum = Params.Minimum
		local current = (tonumber(lastValue) - Minimum) / (Params.Maximum - Minimum)
		self.GMSlider:SetValue(current)
	end
end

return GMSliderView