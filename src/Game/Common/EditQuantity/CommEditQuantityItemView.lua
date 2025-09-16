---
--- Author: ds_herui
--- DateTime: 2024-06-14 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIViewID = require("Define/UIViewID")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local ItemUtil = require("Utils/ItemUtil")

local UIViewMgr = _G.UIViewMgr

---@class CommEditQuantityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnAddTen UFButton
---@field BtnCurValue UFButton
---@field BtnMax UFButton
---@field BtnSubtract UFButton
---@field BtnSubtractTen UFButton
---@field FCanvasPanel UFCanvasPanel
---@field FCanvasPanel_1 UFCanvasPanel
---@field FCanvasPanel_2 UFCanvasPanel
---@field IconMost UFImage
---@field ImgAdd UFImage
---@field ImgAddDisable UFImage
---@field ImgAddTenNormal UFImage
---@field ImgMaxNormal UFImage
---@field ImgSubtract UFImage
---@field ImgSubtractDisable UFImage
---@field ImgSubtractTenNormal UFImage
---@field TextAddTen UFTextBlock
---@field TextAmount UFTextBlock
---@field TextSubtractTen UFTextBlock
---@field AddSubtract10 bool
---@field Max bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommEditQuantityItemView = LuaClass(UIView, true)

function CommEditQuantityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnAddTen = nil
	--self.BtnCurValue = nil
	--self.BtnMax = nil
	--self.BtnSubtract = nil
	--self.BtnSubtractTen = nil
	--self.FCanvasPanel = nil
	--self.FCanvasPanel_1 = nil
	--self.FCanvasPanel_2 = nil
	--self.IconMost = nil
	--self.ImgAdd = nil
	--self.ImgAddDisable = nil
	--self.ImgAddTenNormal = nil
	--self.ImgMaxNormal = nil
	--self.ImgSubtract = nil
	--self.ImgSubtractDisable = nil
	--self.ImgSubtractTenNormal = nil
	--self.TextAddTen = nil
	--self.TextAmount = nil
	--self.TextSubtractTen = nil
	--self.AddSubtract10 = nil
	--self.Max = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommEditQuantityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommEditQuantityItemView:OnInit()
	self.LowerLimit = 0
	self.UpperLimit = 100
	self.LowerLimitHint = _G.LSTR(10042)	--"已达到最小值，不能再减少"
	self.UpperLimitHint = _G.LSTR(10043)	--"已达到最大值，不能再增加"
	self.MaxHint = _G.LSTR(10044)		--"已达到最大值"
	self.OpenHintState = true
	self.OperationList = { 
		["Add"] = {UnitValue = 1, CallBack = nil },
		["Sub"] = {UnitValue = -1, CallBack = nil },
		["AddTen"] = {UnitValue = 10, CallBack = nil },
		["SubTen"] = {UnitValue = -10, CallBack = nil },
	}
	self.CurValue = 0
	self.ModifyValueCallback = nil
	self.TextAmount:SetText("0")
	self.TextSubtractTen:SetText("-10")
	self.TextAddTen:SetText("+10")

	self.IsSetValueOnShow = true
end

function CommEditQuantityItemView:OnDestroy()

end

function CommEditQuantityItemView:OnShow()
	if self.IsSetValueOnShow then
		self:SetCurValue(self.CurValue)
	end
end

function CommEditQuantityItemView:OnHide()
	UIViewMgr:HideView(UIViewID.CommMiniKeypadWin)
end

function CommEditQuantityItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCurValue, self.OnBtnCurValueClick)
	UIUtil.AddOnClickedEvent(self, self.BtnSubtract, self.OnBtnSubtractClick)
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnBtnAddClick)
	UIUtil.AddOnClickedEvent(self, self.BtnSubtractTen, self.OnBtnSubtractTenClick)
	UIUtil.AddOnClickedEvent(self, self.BtnAddTen, self.OnBtnAddTenClick)
	UIUtil.AddOnClickedEvent(self, self.BtnMax, self.OnBtnMaxClick)
end

function CommEditQuantityItemView:OnRegisterGameEvent()

end

function CommEditQuantityItemView:OnRegisterBinder()

end

function CommEditQuantityItemView:SetTextAmountText(ConfirmValue)
	if CommonUtil.IsObjectValid(self.TextAmount) then
		self.TextAmount:SetText(ItemUtil.GetItemNumText(tonumber(ConfirmValue)))
	end
end

function CommEditQuantityItemView:OnBtnCurValueClick()
	local ConfirmCallback = function (ConfirmValue)
		if not CommonUtil.IsObjectValid(self) then
			return
		end
		self:SetTextAmountText(ConfirmValue)
		self:SetCurValue(ConfirmValue)
	end
	local ShowCallback = function (CutValue)
		if not CommonUtil.IsObjectValid(self) then
			return
		end
		self:SetTextAmountText(CutValue)
	end
	local CutValue = tonumber(self.TextAmount:GetText())
	local Params = { CutValue = CutValue, ConfirmCallback = ConfirmCallback , 
					ShowCallback = ShowCallback, LowerLimit = self.LowerLimit, UpperLimit = self.UpperLimit, UpperLimitHintText = self.UpperLimitHint, LowerLimitHintText = self.LowerLimitHint}
	local View = UIViewMgr:ShowView(UIViewID.CommMiniKeypadWin, Params)
	self.CommMiniKeyView = View
	-- 计算展示位置
	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	local KetpadSize = UIUtil.GetWidgetSize(View.FCanvasPanel_3)
	local BtnSize = UIUtil.GetWidgetSize(self.FCanvasPanel_2)
	local XScale = ViewportSize.X / ScreenSize.X 
	local YScale = ViewportSize.Y / ScreenSize.Y 
	KetpadSize.X = KetpadSize.X * XScale
	KetpadSize.Y = KetpadSize.Y * YScale
	BtnSize.X = BtnSize.X * XScale
	BtnSize.Y = BtnSize.Y * YScale
	local BtnAbsolute = UIUtil.GetWidgetAbsolutePosition(self.FCanvasPanel_2)
	local BtnPosition = UIUtil.AbsoluteToViewport(BtnAbsolute)
	if BtnPosition.X > KetpadSize.X then
		KetpadSize = UIUtil.GetWidgetSize(View.FCanvasPanel_3)
		BtnSize = UIUtil.GetWidgetSize(self.FCanvasPanel_2)
		local InRightOffset = _G.UE.FVector2D( -BtnSize.X - KetpadSize.X - 20, -KetpadSize.Y + 100)
		TipsUtil.AdjustTipsPosition(View.FCanvasPanel_3, self.FCanvasPanel_2, InRightOffset, _G.UE.FVector2D(0, 0))
	else
		KetpadSize = UIUtil.GetWidgetSize(View.FCanvasPanel_3)
		BtnSize = UIUtil.GetWidgetSize(self.FCanvasPanel_2)
		local InLeftOffset = _G.UE.FVector2D( BtnSize.X - 20, - KetpadSize.Y + 100)
		TipsUtil.AdjustTipsPosition(View.FCanvasPanel_3, self.FCanvasPanel_2, InLeftOffset, _G.UE.FVector2D(0, 0))
	end
end

function CommEditQuantityItemView:Operation(Type)
	local AOperation = self.OperationList[Type]
	if AOperation.CallBack ~= nil then 
		return AOperation.CallBack(self.CurValue)
	end
	return self.CurValue + AOperation.UnitValue 
end

function CommEditQuantityItemView:OnBtnSubtractClick()
	if not UIUtil.IsVisible(self.ImgSubtract) then
		if self.OpenHintState then
			MsgTipsUtil.ShowTips(self.LowerLimitHint, nil , 1)
		end
		return
	end
	local RetVal = self:Operation("Sub")
	self:SetCurValue(RetVal)
end

function CommEditQuantityItemView:OnBtnAddClick()
	if not UIUtil.IsVisible(self.ImgAdd) then
		if self.OpenHintState then
			MsgTipsUtil.ShowTips(self.UpperLimitHint, nil , 1)
		end		
		return
	end
	local RetValue = self:Operation("Add")
	self:SetCurValue(RetValue)
end

function CommEditQuantityItemView:OnBtnSubtractTenClick()
	if not UIUtil.IsVisible(self.ImgSubtractTenNormal) then
		if self.OpenHintState then
			MsgTipsUtil.ShowTips(self.LowerLimitHint, nil , 1)
		end
		return
	end
	local RetValue = self:Operation("SubTen")
	self:SetCurValue(RetValue)
end

function CommEditQuantityItemView:OnBtnAddTenClick()
	if not UIUtil.IsVisible(self.ImgAddTenNormal) then
		if self.OpenHintState then
			MsgTipsUtil.ShowTips(self.UpperLimitHint, nil , 1)
		end
		return
	end
	local RetValue = self:Operation("AddTen")
	self:SetCurValue(RetValue)
end

function CommEditQuantityItemView:OnBtnMaxClick()
	if not UIUtil.IsVisible(self.ImgMaxNormal) then
		if self.OpenHintState then
			MsgTipsUtil.ShowTips(self.MaxHint, nil , 1)
		end
		return
	end
	self:SetCurValue(self.UpperLimit)
end

function CommEditQuantityItemView:SetCurValue(Value)
	Value = math.floor(Value)
	if Value < self.LowerLimit then
		Value = self.LowerLimit
		MsgTipsUtil.ShowTips(self.LowerLimitHint, nil , 1)
	elseif Value > self.UpperLimit then
		Value = self.UpperLimit
		MsgTipsUtil.ShowTips(self.UpperLimitHint, nil , 1)
	end
	self:SetTextAmountText(tostring(Value))
	self.CurValue = Value
	self:NextForecast()
	if self.ModifyValueCallback ~= nil then
		self.ModifyValueCallback(Value)
	end
end

function CommEditQuantityItemView:NextForecast()
	if not self.IsSetValueOnShow then
		return
	end
	local ReVal = self:Operation("Add")
	local IsEnabled = not (ReVal > self.UpperLimit or self.UpperLimit <= self.CurValue)
	self:SetBtnAddIsEnabled(IsEnabled)

	ReVal = self:Operation("Sub")
	IsEnabled = not (ReVal < self.LowerLimit or self.LowerLimit >= self.CurValue)
	self:SetBtnSubtractIsEnabled(IsEnabled)

	ReVal =  self:Operation("AddTen")
	IsEnabled = not (ReVal > self.UpperLimit or self.UpperLimit <= self.CurValue)
	self:SetBtnAddTenIsEnabled(IsEnabled)

	ReVal = self:Operation("SubTen")
	IsEnabled = not (ReVal < self.LowerLimit or self.LowerLimit >= self.CurValue)
	self:SetBtnSubtractTenIsEnabled(IsEnabled)

	self:SetBtnMaxIsEnabled(not (self.UpperLimit <= self.CurValue))
end

-------------------------------------------------------------------------------------------------------
---Public Interface 

-- 设置可输入下限 和超下限提示文本
function CommEditQuantityItemView:SetInputLowerLimit(LowerLimit, HintText)
	if LowerLimit ~= nil and LowerLimit > 0 then
		self.LowerLimit = math.floor(LowerLimit)
	end
	if HintText ~= nil then
		self.LowerLimitHint = HintText
	end
end

-- 设置可输入上限 和超上限提示文本
function CommEditQuantityItemView:SetInputUpperLimit(UpperLimit, HintText)
	if UpperLimit ~= nil then
		self.UpperLimit = math.floor(UpperLimit)
	end
	if HintText ~= nil then
		self.UpperLimitHint = HintText
	end
end

-- 设置 范围减 算法
function CommEditQuantityItemView:SetRangeSubCall(RangeSubCall)
	self.OperationList["SubTen"].CallBack = RangeSubCall
end

-- 设置 范围增 算法
function CommEditQuantityItemView:SetRangeAddCall(RangeAddCall)
	self.OperationList["AddTen"].CallBack = RangeAddCall
end

-- 设置 单位减 算法
function CommEditQuantityItemView:SetUnitSubCall(UnitSubCall)
	self.OperationList["Sub"].CallBack = UnitSubCall
end

-- 设置 单位增 算法
function CommEditQuantityItemView:SetUnitAddCall(UnitAddCall)
	self.OperationList["Add"].CallBack = UnitAddCall
end

-- 设置 是否打开按钮文本提示
---@param IsEnabled bool @开启/关闭 按钮提示
function CommEditQuantityItemView:SetOpenHintState(HintState)
	self.OpenHintState = HintState == true
end

-- 设置 值变动  回调
function CommEditQuantityItemView:SetModifyValueCallback(ModifyValueCallback)
	self.ModifyValueCallback = ModifyValueCallback
end

-- 设置 置灰最大值按钮
---@param IsEnabled bool @fasle 置灰  true 点亮
function CommEditQuantityItemView:SetBtnMaxIsEnabled(IsEnabled)
	UIUtil.SetIsVisible(self.ImgMaxNormal, IsEnabled == true)
	UIUtil.SetIsVisible(self.IconMost, IsEnabled == true)
end

-- 设置 置灰 当前值按钮
---@param IsEnabled bool @fasle 置灰  true 点亮
function CommEditQuantityItemView:SetBtnCurValueIsEnabled(IsEnabled)
	self.BtnCurValue:SetIsEnabled(IsEnabled == true)
end

-- 设置 置灰减少按钮
---@param IsEnabled bool @fasle 置灰  true 点亮
function CommEditQuantityItemView:SetBtnSubtractIsEnabled(IsEnabled)
	UIUtil.SetIsVisible(self.ImgSubtract, IsEnabled == true)
end

-- 设置 置灰范围减少按钮
---@param IsEnabled bool @fasle 置灰  true 点亮
function CommEditQuantityItemView:SetBtnSubtractTenIsEnabled(IsEnabled)
	UIUtil.SetIsVisible(self.ImgSubtractTenNormal, IsEnabled == true)
end

-- 设置 置灰增加按钮
---@param IsEnabled bool @fasle 置灰  true 点亮
function CommEditQuantityItemView:SetBtnAddIsEnabled(IsEnabled)
	UIUtil.SetIsVisible(self.ImgAdd, IsEnabled == true)
end

-- 设置 置灰范围增加按钮
---@param IsEnabled bool @fasle 置灰  true 点亮
function CommEditQuantityItemView:SetBtnAddTenIsEnabled(IsEnabled)
	UIUtil.SetIsVisible(self.ImgAddTenNormal, IsEnabled == true)
end

-- 设置是否置灰所有按钮并且关闭 点击提示
---@param IsEnabled bool @显示/置灰 所有按钮
function CommEditQuantityItemView:SetAllBtnIsEnabled(IsEnabled)
	self:SetBtnCurValueIsEnabled(IsEnabled)
	self:SetBtnMaxIsEnabled(IsEnabled)
	self:SetBtnSubtractIsEnabled(IsEnabled)
	self:SetBtnSubtractTenIsEnabled(IsEnabled)
	self:SetBtnAddIsEnabled(IsEnabled)
	self:SetBtnAddTenIsEnabled(IsEnabled)
	self:SetOpenHintState(IsEnabled)
end

-- 设置显示模式
---@param NewState bool @显示/隐藏 范围增减按钮
function CommEditQuantityItemView:ShowRangeMode(NewState)
	local IsShow = NewState == true
	UIUtil.SetIsVisible(self.FCanvasPanel, IsShow)  
	UIUtil.SetIsVisible(self.FCanvasPanel_1, IsShow)
	UIUtil.SetIsVisible(self.BtnSubtractTen, IsShow, IsShow)  
	UIUtil.SetIsVisible(self.BtnAddTen, IsShow, IsShow)
end

return CommEditQuantityItemView