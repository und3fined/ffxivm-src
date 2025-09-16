local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local TimeDefine = require("Define/TimeDefine")
local TimeType = TimeDefine.TimeType

---@class WeatherTimeBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnServer UFButton
---@field ImgServerBg UFImage
---@field ImgSwitch UFImage
---@field Server UFCanvasPanel
---@field TextServer UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WeatherTimeBarItemView = LuaClass(UIView, true)

function WeatherTimeBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnServer = nil
	--self.ImgServerBg = nil
	--self.ImgSwitch = nil
	--self.Server = nil
	--self.TextServer = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WeatherTimeBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WeatherTimeBarItemView:OnInit()
	self.TimerInterval = 0.2
	self.TypeIndex = 1
	self.TypeList = {
		TimeType.Aozy,
		TimeType.Local,
		TimeType.Server,
	}
end

function WeatherTimeBarItemView:OnDestroy()

end

function WeatherTimeBarItemView:OnShow()
	self:RefreshTimeTypeShow()
	--print('andre.WeatherTimeBarItemView:OnShow')
end

function WeatherTimeBarItemView:OnHide()

end

function WeatherTimeBarItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnServer, self.OnBtnServerClicked)
end

function WeatherTimeBarItemView:OnRegisterGameEvent()

end

function WeatherTimeBarItemView:OnRegisterBinder()

end

function WeatherTimeBarItemView:OnRegisterTimer()
	self:RegisterTimer(self.UpdateTime, 0, self.TimerInterval, 0)
end

function WeatherTimeBarItemView:UpdateTime()
	self.TextTime:SetText(TimeUtil.GetTimeFormatByType(self:GetCurrTimeType(), "%H:%M"))
end

function WeatherTimeBarItemView:OnBtnServerClicked()
	self.TypeIndex = self.TypeIndex % #self.TypeList + 1
	self:RefreshTimeTypeShow()
end

function WeatherTimeBarItemView:RefreshTimeTypeShow()
	self.TextServer:SetText(TimeDefine.TimeNameConfig[self:GetCurrTimeType()])
	self:UpdateTime()
end

function WeatherTimeBarItemView:SetTypeList(InTypeList)
	self.TypeList = InTypeList
	self.TypeIndex = 1
end

function WeatherTimeBarItemView:GetCurrTimeType()
	return self.TypeList[self.TypeIndex] or TimeType.Aozy
end

return WeatherTimeBarItemView