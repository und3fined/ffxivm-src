---
--- Author: anypkvcai
--- DateTime: 2021-01-06 9:44
--- Description: 倒计时 UI适配器
--- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=696176173

local LuaClass = require("Core/LuaClass")
local UIAdapterBase = require("UI/Adapter/UIAdapterBase")
local TimeUtil = require("Utils/TimeUtil")
local DateTimeTools = require("Common/DateTimeTools")

---@class UIAdapterCountDown : UIAdapterBase
local UIAdapterCountDown = LuaClass(UIAdapterBase, true)

---CreateAdapter
---@param View UIView
---@param Widget UUserWidget
---@field TimeFormat string
---@field StrFormat string
---@field TimeOutCallback function
---@field TimeUpdateCallback function
---@field TimeFormatChinese boolean
---@return UIView
function UIAdapterCountDown.CreateAdapter(View, Widget, TimeFormat, StrFormat, TimeOutCallback, TimeUpdateCallback, TimeFormatChinese)
	local Adapter = UIAdapterCountDown.New()
	Adapter:InitAdapter(View, Widget, TimeFormat, StrFormat, TimeOutCallback, TimeUpdateCallback, TimeFormatChinese)
	return Adapter
end

---Ctor
---@field TimeFormat string
---@field StrFormat string
---@field Callback function
---@field EndTime number
function UIAdapterCountDown:Ctor()
	self.TimeFormat = nil
	self.StrFormat = nil
	self.TimeFormatChinese = false
	self.TimeOutCallback = nil
	self.TimeUpdateCallback = nil
	self.EndTime = 0
end

---InitAdapter
---@param View UIView
---@param Widget UUserWidget
---@field TimeFormat string
---@field StrFormat string
---@field TimeOutCallback function
---@field TimeUpdateCallback function
---@field TimeFormatChinese boolean
function UIAdapterCountDown:InitAdapter(View, Widget, TimeFormat, StrFormat, TimeOutCallback, TimeUpdateCallback, TimeFormatChinese)
	self.Super:InitAdapter(View, Widget)

	self.TimeFormat = TimeFormat
	self.TimeFormatChinese = TimeFormatChinese
	self.StrFormat = StrFormat
	self.TimeOutCallback = TimeOutCallback
	self.TimeUpdateCallback = TimeUpdateCallback

	if nil ~= self.Widget then
		self.Widget:SetText("")
	end
end

---OnTimer
function UIAdapterCountDown:OnTimer()
	local Widget = self.Widget
	if nil == Widget then
		return
	end

	local TimeStamp = TimeUtil.GetServerLogicTimeMS()
	local LeftTime = (self.EndTime > TimeStamp and self.EndTime - TimeStamp or 0) / 1000
	
	local TimeStr

	if nil ~= self.TimeUpdateCallback then
		TimeStr = self.TimeUpdateCallback(self.View, LeftTime)
	else
		if nil ~= self.TimeFormat then
			TimeStr = DateTimeTools.TimeFormat(LeftTime, self.TimeFormat, self.TimeFormatChinese)
		end

		if nil == TimeStr or "" == TimeStr then
			TimeStr = tostring(LeftTime)
		end
	end

	if nil ~= self.StrFormat then
		Widget:SetText(string.format(self.StrFormat, TimeStr))
	else
		Widget:SetText(TimeStr)
	end

	if LeftTime <= 0 then
		self:UnRegisterAllTimer()

		if nil ~= self.TimeOutCallback then
			self.TimeOutCallback(self.View)
		end
	end
end

---Start
---@param Time number        @倒计时的时间
---@param Interval number    @计时器间隔
---@param IsTimeStamp boolean @是否时间戳
---@param  IsMilliSecond boolean @时间单位是否毫秒
function UIAdapterCountDown:Start(Time, Interval, IsTimeStamp, IsMilliSecond)
	self:UnRegisterAllTimer()

	--小于0相当于中断已有倒计时
	if Time < 0 then
		return
	end

	local TimeMS = IsMilliSecond and Time or Time * 1000
	if IsTimeStamp then
		self.EndTime = TimeMS
	else
		self.EndTime = TimeUtil.GetServerLogicTimeMS() + TimeMS
	end

	self.CountDownTimerID = self:RegisterTimer(self.OnTimer, 0, Interval or 1, 0)
end

-- 手动停止
function UIAdapterCountDown:ManuallyStop()
	if (self.CountDownTimerID ~= nil and self.CountDownTimerID > 0) then
		self:UnRegisterTimer(self.CountDownTimerID)
		self.CountDownTimerID = nil
	end
end

return UIAdapterCountDown