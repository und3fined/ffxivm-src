---
--- Author: xingcaicao
--- DateTime: 2023-07-03 22:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local EventID = require("Define/EventID")

local LSTR = _G.LSTR

---@class SidebarCommonWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnLeft CommBtnSView
---@field BtnRight CommBtnSView
---@field ProBarCD UProgressBar
---@field RichTextDesc URichTextBox
---@field RichTextDesc2 URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

---@field Params table @通过外部参数传入
---@field Params.Title string @标题
---@field Params.Desc1 string @描述文本1，不传或空字符串时，会隐藏对应的文本组件
---@field Params.Desc2 string @描述文本2，不传或空字符串时，会隐藏对应的文本组件
---@field Params.StartTime number @倒计时开始时间（时间搓，单位秒）
---@field Params.CountDown number @倒计时长
---@field Params.CBFuncObj table @回调函数调用者对象
---@field Params.CBFuncLeft function @左边按钮点击回调函数
---@field Params.CBFuncRight function @右边按钮点击回调函数
---@field Params.BtnTextLeft string @左边按钮文字，默认“拒绝”
---@field Params.BtnTextRight string @右边按钮文字，默认“接受”
---@field Params.Type SidebarDefine.SidebarType @侧边栏类型
---@field Params.TransData customdefine @透传数据
local SidebarCommonWinView = LuaClass(UIView, true)

function SidebarCommonWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.ProBarCD = nil
	--self.RichTextDesc = nil
	--self.RichTextDesc2 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarCommonWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnLeft)
	self:AddSubView(self.BtnRight)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarCommonWinView:OnInit()

end

function SidebarCommonWinView:OnDestroy()

end

function SidebarCommonWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	--标题
	self.TextTitle:SetText(Params.Title or "")

	--描述文本1
	self:SetDesc(self.RichTextDesc, Params.Desc1)

	--描述文本2
	self:SetDesc(self.RichTextDesc2, Params.Desc2)

	self.CBFuncObj = Params.CBFuncObj
	self.CBFuncLeft = Params.CBFuncLeft
	self.CBFuncRight = Params.CBFuncRight
	self.Type = Params.Type

	--按钮文本
	local BtnTextLeft = self.Params.BtnTextLeft
	self.BtnLeft:SetText(string.isnilorempty(BtnTextLeft) and LSTR(460011) or BtnTextLeft) -- "拒 绝"

	local BtnTextRight = self.Params.BtnTextRight
	self.BtnRight:SetText(string.isnilorempty(BtnTextRight) and LSTR(460013) or BtnTextRight) -- "接 受"

	--透传数据
	self.TransData = Params.TransData

	--倒计时
	self.CountDown = Params.CountDown or 0

	local StartTime = Params.StartTime or 0
	self.LossTime = TimeUtil.GetServerTime() - StartTime
	if self.LossTime >= self.CountDown then
		self.ProBarCD:SetPercent(0)
		self:CloseUI()
		return
	end

	self:SetProBarCD(self.LossTime)
	self:RegisterTimer(self.OnTimer, 0, 0.01, 0)
end

function SidebarCommonWinView:OnHide()

end

function SidebarCommonWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, 	self.OnClickButtonLeft)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, 	self.OnClickButtonRight)
	UIUtil.AddOnClickedEvent(self, self.BtnClose,	self.OnClickButtonClose)
end

function SidebarCommonWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SidebarRemoveItem, self.OnEventSidebarRemoveItem)
	self:RegisterGameEvent(EventID.SidebarRemoveItemByParam, self.OnEventSidebarRemoveItemByParam)
end

function SidebarCommonWinView:OnRegisterBinder()

end

function SidebarCommonWinView:SetDesc( RichText, Text)
	if string.isnilorempty(Text) then
		UIUtil.SetIsVisible(RichText, false)

	else
		RichText:SetText(Text)
		UIUtil.SetIsVisible(RichText, true)
	end
end

function SidebarCommonWinView:SetProBarCD( ElapsedTime )
	local Percent  = math.clamp(1 - ElapsedTime / self.CountDown, 0, 1)
	self.ProBarCD:SetPercent(Percent)

	self:PlayAnimationTimeRange(self.AnimProBarLight, Percent, Percent, 1, nil, 0, false)
end

function SidebarCommonWinView:OnTimer( _, ElapsedTime )
	local CountDown = self.CountDown
	if nil == CountDown or CountDown <= 0 then
		return
	end

	ElapsedTime = (self.LossTime or 0) + ElapsedTime
	if ElapsedTime >= CountDown then
		self:CloseUI()
		return
	end

	self:SetProBarCD(ElapsedTime)
end

function SidebarCommonWinView:CloseUI()
	SidebarMgr:TryOpenSidebarMainWin()
	self:Hide()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 


function SidebarCommonWinView:OnEventSidebarRemoveItem(Type)
	if nil ~= Type and Type == self.Type then 
		self:CloseUI()
	end
end

function SidebarCommonWinView:OnEventSidebarRemoveItemByParam(Param, ParamName)
	if nil ~= Param and nil ~= self.TransData and type(self.TransData) == "table" and Param == self.TransData[ParamName] then 
		self:CloseUI()
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function SidebarCommonWinView:OnClickButtonLeft()
	if self.CBFuncLeft then
		self.CBFuncLeft(self.CBFuncObj, self.TransData)
	end

	self:CloseUI()
end

function SidebarCommonWinView:OnClickButtonRight()
	if self.CBFuncRight then
		self.CBFuncRight(self.CBFuncObj, self.TransData)
	end

	self:CloseUI()
end

function SidebarCommonWinView:OnClickButtonClose()
	self:CloseUI()
end

return SidebarCommonWinView