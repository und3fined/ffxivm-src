---
--- Author: v_vvxinchen
--- DateTime: 2025-02-17 18:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local EventID = require("Define/EventID")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local LSTR = _G.LSTR

---@class SidebarFishWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnLeft CommBtnSView
---@field BtnRight CommBtnSView
---@field CommBackpack74Slot CommBackpack74SlotView
---@field ProBarCD UProgressBar
---@field RichTextDesc URichTextBox
---@field RichTextDesc2 URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarFishWinView = LuaClass(UIView, true)

function SidebarFishWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.CommBackpack74Slot = nil
	--self.ProBarCD = nil
	--self.RichTextDesc = nil
	--self.RichTextDesc2 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarFishWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnLeft)
	self:AddSubView(self.BtnRight)
	self:AddSubView(self.CommBackpack74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarFishWinView:OnInit()

end

function SidebarFishWinView:OnDestroy()

end

function SidebarFishWinView:OnShow()
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

	--Icon
    if Params.TransData then
		self:SetItemIcon(Params.TransData.ResID)
	end

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
	self:RegisterTimer(self.OnTimer, 0, 0.3, 0)
end

function SidebarFishWinView:OnHide()

end

function SidebarFishWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, 	self.OnClickButtonLeft)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, 	self.OnClickButtonRight)
	UIUtil.AddOnClickedEvent(self, self.BtnClose,	self.OnClickButtonClose)
end

function SidebarFishWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SidebarRemoveItem, self.OnEventSidebarRemoveItem)
	self:RegisterGameEvent(EventID.SidebarRemoveItemByParam, self.OnEventSidebarRemoveItemByParam)
end

function SidebarFishWinView:OnRegisterBinder()

end

function SidebarFishWinView:SetDesc( RichText, Text)
	if string.isnilorempty(Text) then
		UIUtil.SetIsVisible(RichText, false)

	else
		RichText:SetText(Text)
		UIUtil.SetIsVisible(RichText, true)
	end
end

function SidebarFishWinView:SetProBarCD( ElapsedTime )
	local Percent  = math.clamp(1 - ElapsedTime / self.CountDown, 0, 1)
	self.ProBarCD:SetPercent(Percent)

	self:PlayAnimationTimeRange(self.AnimProBarLight, Percent, Percent, 1, nil, 0, false)
end

function SidebarFishWinView:OnTimer( _, ElapsedTime )
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

function SidebarFishWinView:CloseUI()
	SidebarMgr:TryOpenSidebarMainWin()
	self:Hide()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 


function SidebarFishWinView:OnEventSidebarRemoveItem(Type)
	if nil ~= Type and Type == self.Type then 
		self:CloseUI()
	end
end

function SidebarFishWinView:OnEventSidebarRemoveItemByParam(Param, ParamName)
	if nil ~= Param and nil ~= self.TransData and type(self.TransData) == "table" and Param == self.TransData[ParamName] then 
		self:CloseUI()
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function SidebarFishWinView:OnClickButtonLeft()
	if self.CBFuncLeft then
		self.CBFuncLeft(self.CBFuncObj, self.TransData)
	end

	self:CloseUI()
end

function SidebarFishWinView:OnClickButtonRight()
	if self.CBFuncRight then
		self.CBFuncRight(self.CBFuncObj, self.TransData)
	end

	self:CloseUI()
end

function SidebarFishWinView:OnClickButtonClose()
	self:CloseUI()
end

function SidebarFishWinView:SetItemIcon(ResID)
	self.CommBackpack74Slot:SetNumVisible(false)
	UIUtil.SetIsVisible(self.CommBackpack74Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.CommBackpack74Slot.RichTextLevel, false)

	if ResID == nil then
		_G.FLOG_ERROR("SidebarFishWinView:SetItemIcon ResID is nil")
		return
	end
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		_G.FLOG_ERROR(string.format("SidebarFishWinView:SetItemIcon Cfg is nil, ResID = %d", ResID))
		return
	end
	local ImgPath = ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
	self.CommBackpack74Slot:SetIconImg(ImgPath)
	self.CommBackpack74Slot:SetQualityImg(ItemUtil.GetItemColorIcon(ResID))
end

return SidebarFishWinView