---
--- Author: ds_herui
--- DateTime: 2024-06-14 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR

---@class CommMiniKeypadWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn0 UFButton
---@field Btn1 UFButton
---@field Btn2 UFButton
---@field Btn3 UFButton
---@field Btn4 UFButton
---@field Btn5 UFButton
---@field Btn6 UFButton
---@field Btn7 UFButton
---@field Btn8 UFButton
---@field Btn9 UFButton
---@field BtnConfirm UFButton
---@field BtnDelete UFButton
---@field FCanvasPanel_3 UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Text0 UFTextBlock
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field Text4 UFTextBlock
---@field Text5 UFTextBlock
---@field Text6 UFTextBlock
---@field Text7 UFTextBlock
---@field Text8 UFTextBlock
---@field Text9 UFTextBlock
---@field TextConfirm UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMiniKeypadWinView = LuaClass(UIView, true)

function CommMiniKeypadWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn0 = nil
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.Btn3 = nil
	--self.Btn4 = nil
	--self.Btn5 = nil
	--self.Btn6 = nil
	--self.Btn7 = nil
	--self.Btn8 = nil
	--self.Btn9 = nil
	--self.BtnConfirm = nil
	--self.BtnDelete = nil
	--self.FCanvasPanel_3 = nil
	--self.PopUpBG = nil
	--self.Text0 = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.Text4 = nil
	--self.Text5 = nil
	--self.Text6 = nil
	--self.Text7 = nil
	--self.Text8 = nil
	--self.Text9 = nil
	--self.TextConfirm = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMiniKeypadWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMiniKeypadWinView:OnInit()
	self.LowerLimit = 0
	self.UpperLimit = 100
	self.UpperLimitHint = LSTR(10040)   -- 已达到最大数量
	self.LowerLimitHint = LSTR(10041)   -- 已达到最小数量
	self.ConfirmCallback = nil
	self.ShowCallback = nil
	self.InitValue = 0
	self.CurrentValue = 0
	self.FirstInput = true
	self.PopUpBG:SetCallback(self, self.InitiativeClose)
	self.Text0:SetText("0")
	self.Text1:SetText("1")
	self.Text2:SetText("2")
	self.Text3:SetText("3")
	self.Text4:SetText("4")
	self.Text5:SetText("5")
	self.Text6:SetText("6")
	self.Text7:SetText("7")
	self.Text8:SetText("8")
	self.Text9:SetText("9")
end

function CommMiniKeypadWinView:OnDestroy()

end

function CommMiniKeypadWinView:OnShow()
	self.TextConfirm:SetText(LSTR(10033))        --确认
	local Params = self.Params
	if Params == nil then
		return
	end 
	self.ShowCallback = Params.ShowCallback
	self.ConfirmCallback = Params.ConfirmCallback
	self.CurrentValue = Params.CutValue or 0
	self.InitValue = self.CurrentValue
	self:SetInputLowerLimit(Params.LowerLimit, Params.LowerLimitHintText)
	self:SetInputUpperLimit(Params.UpperLimit, Params.UpperLimitHintText)
	self.FirstInput = true
end

function CommMiniKeypadWinView:OnHide()
	if self.ShowCallback ~= nil then
		self.ShowCallback(self.InitValue)
	end
	if self.ConfirmCallback ~= nil then
		self.ConfirmCallback(self.InitValue)
	end
end

function CommMiniKeypadWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickBtnDelete)
	UIUtil.AddOnClickedEvent(self, self.Btn0, self.OnClickBtnInput, {0})
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnClickBtnInput, {1})
	UIUtil.AddOnClickedEvent(self, self.Btn2, self.OnClickBtnInput, {2})
	UIUtil.AddOnClickedEvent(self, self.Btn3, self.OnClickBtnInput, {3})
	UIUtil.AddOnClickedEvent(self, self.Btn4, self.OnClickBtnInput, {4})
	UIUtil.AddOnClickedEvent(self, self.Btn5, self.OnClickBtnInput, {5})
	UIUtil.AddOnClickedEvent(self, self.Btn6, self.OnClickBtnInput, {6})
	UIUtil.AddOnClickedEvent(self, self.Btn7, self.OnClickBtnInput, {7})
	UIUtil.AddOnClickedEvent(self, self.Btn8, self.OnClickBtnInput, {8})
	UIUtil.AddOnClickedEvent(self, self.Btn9, self.OnClickBtnInput, {9})
end

function CommMiniKeypadWinView:OnClickBtnConfirm()
	if self.CurrentValue < self.LowerLimit then
		self.CurrentValue = self.LowerLimit
		MsgTipsUtil.ShowTips(self.LowerLimitHint, nil , 1)
		if self.ShowCallback ~= nil then
			self.ShowCallback(self.CurrentValue)
		end
		return 
	end
	if self.CurrentValue > self.UpperLimit then
		self.CurrentValue = self.UpperLimit
		MsgTipsUtil.ShowTips(self.UpperLimitHint, nil , 1)
		if self.ShowCallback ~= nil then
			self.ShowCallback(self.CurrentValue)
		end
		return 
	end

	self.InitValue = self.CurrentValue
	self:Hide()
end

function CommMiniKeypadWinView:OnClickBtnDelete()
	self.FirstInput = false

	local Expect = math.floor(self.CurrentValue / 10 )
	if self.ShowCallback ~= nil then
		self.ShowCallback(Expect)
	end
	self.CurrentValue = Expect
end

function CommMiniKeypadWinView:OnClickBtnInput(Params)
	if self.FirstInput then
		self.CurrentValue = 0
		self.FirstInput = false
	end

	local Input = Params[1] or 0
	local Expect = math.floor(self.CurrentValue * 10 + Input)
	
	if Expect > self.UpperLimit then
		MsgTipsUtil.ShowTips(self.UpperLimitHint, nil , 1)
		Expect = self.UpperLimit
	end
	if self.ShowCallback ~= nil then
		self.ShowCallback(Expect)
	end
	self.CurrentValue = Expect
end

function CommMiniKeypadWinView:InitiativeClose()
	if self.CurrentValue < self.LowerLimit then
		self.CurrentValue = self.InitValue
		MsgTipsUtil.ShowTips(self.LowerLimitHint, nil , 1)
	end
	if self.CurrentValue > self.UpperLimit then
		self.CurrentValue = self.InitValue
		MsgTipsUtil.ShowTips(self.UpperLimitHint, nil , 1)
	end

	self.InitValue = self.CurrentValue
	self:Hide()
end

function CommMiniKeypadWinView:OnRegisterGameEvent()

end

function CommMiniKeypadWinView:OnRegisterBinder()

end

-------------------------------------------------------------------------------------------------------
---Public Interface 

-- 设置可输入下限 和超下限提示文本
function CommMiniKeypadWinView:SetInputLowerLimit(LowerLimit, HintText)
	if LowerLimit ~= nil and LowerLimit >= 0 then
		self.LowerLimit = math.floor(LowerLimit)
	else
		_G.FLOG_WARNING("Error CommMiniKeypadWinView SetInputLowerLimit out of range!  LowerLimit: " .. tostring(LowerLimit))
		self:Hide()
		MsgTipsUtil.ShowTipsByID(158107)
		return 
	end
	if HintText ~= nil then
		self.LowerLimitHint = HintText
	end
end

-- 设置可输入上限 和超上限提示文本 
function CommMiniKeypadWinView:SetInputUpperLimit(UpperLimit, HintText)
	if UpperLimit ~= nil then
		self.UpperLimit = math.floor(UpperLimit)
	else
		_G.FLOG_WARNING("Error CommMiniKeypadWinView SetInputUpperLimit out of range!  UpperLimit: " .. tostring(UpperLimit))
		self:Hide()
		MsgTipsUtil.ShowTipsByID(158107)
		return
	end
	if HintText ~= nil then
		self.UpperLimitHint = HintText
	end
end

return CommMiniKeypadWinView