---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class NewWeatherBallISlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field IconWeather UFImage
---@field ImgWeatherBar2 UFImage
---@field ImgWeatherBar3 UFImage
---@field Spacer_35 USpacer
---@field TextWeather UFTextBlock
---@field WeatherBallSlot UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherBallISlotItemView = LuaClass(UIView, true)

function NewWeatherBallISlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.IconWeather = nil
	--self.ImgWeatherBar2 = nil
	--self.ImgWeatherBar3 = nil
	--self.Spacer_35 = nil
	--self.TextWeather = nil
	--self.WeatherBallSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherBallISlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherBallISlotItemView:OnInit()
	self.Binder = 
	{
		{ "Icon", 					UIBinderSetBrushFromAssetPath.New(self, self.IconWeather) },
		{ "Name", 					UIBinderSetText.New(self, self.TextWeather) },
		{ "IsShowBorder", 			UIBinderSetIsVisible.New(self, self.ImgWeatherBar2) },
		{ "IsShowName", 			UIBinderSetIsVisible.New(self, self.TextWeather) },
		{ "IsGlow", 				UIBinderSetIsVisible.New(self, self.ImgWeatherBar3) },
		{ "NameColor", 				UIBinderSetColorAndOpacityHex.New(self, self.TextWeather) },
		{ "Alpha", 					UIBinderSetRenderOpacity.New(self, self.WeatherBallSlot) },
	}
end

function NewWeatherBallISlotItemView:OnDestroy()

end

function NewWeatherBallISlotItemView:OnShow()
	self:UpdateItem()
end

function NewWeatherBallISlotItemView:OnHide()
	self.VM = nil
end

function NewWeatherBallISlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, 				self.BtnSlot, 			self.OnBtnSelt)
end

function NewWeatherBallISlotItemView:OnRegisterGameEvent()

end

function NewWeatherBallISlotItemView:OnRegisterBinder()
	if self.VM == nil and self.Params ~= nil and self.Params.Data ~= nil then
		self.VM = self.Params.Data
	end

	self:UpdWeather(self.VM)
end

function NewWeatherBallISlotItemView:UpdWeather(VM)
	if not VM then
		return
	end

	if self.VM then
		self:UnRegisterBinders(self.VM, self.Binder)
	end

	self.VM = VM

	if self:GetIsShowView() then
		self:RegisterBinders(self.VM, 				self.Binder)
	end
end

function NewWeatherBallISlotItemView:OnBtnSelt()
	local WeatherVM = _G.WeatherVM
	local IsDetailExpand = false
	if self.VM then
		local VM = self.VM
		local BtnCallBack = self.BtnCallBack or self.VM.BtnCallBack
		if BtnCallBack ~= nil then
			BtnCallBack(VM, self.BtnSlot)
		elseif VM.MapID ~= nil then
			WeatherVM:SetDetailInfo(VM.MapID, VM.TimeOff, self.BtnSlot, VM.IsUnExpBall)
			_G.UIViewMgr:ShowView(_G.UIViewID.WeatherForecastTips)
		end
	end
end

function NewWeatherBallISlotItemView:SetBtnSeltCallBack(BtnCallBack)
	if BtnCallBack ~= nil then
		self.BtnCallBack = BtnCallBack
	end
end

function NewWeatherBallISlotItemView:UpdateItem()
	if self.VM then --self.Params and self.Params.Data then
		-- self.VM = self.Params.Data
		self.TextWeather:SetText(self.VM.Name)
		UIUtil.ImageSetBrushFromAssetPath(self.IconWeather, self.VM.Icon)
	end
end


return NewWeatherBallISlotItemView