---
--- Author: Administrator
--- DateTime: 2024-08-06 20:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
---@class PuzzleGMPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn01 UFButton
---@field Btn01_1 UFButton
---@field Btn01_2 UFButton
---@field Btn02 UFButton
---@field Btn02_1 UFButton
---@field Btn02_2 UFButton
---@field Btn02_3 UFButton
---@field Btn02_4 UFButton
---@field Btn04 UFButton
---@field Btn05 UFButton
---@field InputBox01 CommInputBoxView
---@field InputBox02 CommInputBoxView
---@field InputBox03 CommInputBoxView
---@field InputBox04 CommInputBoxView
---@field InputBox05 CommInputBoxView
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field Text4 UFTextBlock
---@field Text5 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PuzzleGMPanelView = LuaClass(UIView, true)

function PuzzleGMPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn01 = nil
	--self.Btn01_1 = nil
	--self.Btn01_2 = nil
	--self.Btn02 = nil
	--self.Btn02_1 = nil
	--self.Btn02_2 = nil
	--self.Btn02_3 = nil
	--self.Btn02_4 = nil
	--self.Btn04 = nil
	--self.Btn05 = nil
	--self.InputBox01 = nil
	--self.InputBox02 = nil
	--self.InputBox03 = nil
	--self.InputBox04 = nil
	--self.InputBox05 = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.Text4 = nil
	--self.Text5 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PuzzleGMPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InputBox01)
	self:AddSubView(self.InputBox02)
	self:AddSubView(self.InputBox03)
	self:AddSubView(self.InputBox04)
	self:AddSubView(self.InputBox05)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PuzzleGMPanelView:OnInit()
	self.InputBox01:SetMaxNum(2000)
	self.InputBox02:SetMaxNum(2000)
	self.InputBox03:SetMaxNum(360)
	self.InputBox04:SetMaxNum(2000)
	self.InputBox05:SetMaxNum(2000)
	-- UIUtil.SetIsVisible(self.InputBox01.RichTextNumber, false)
	-- UIUtil.SetIsVisible(self.InputBox02.RichTextNumber, false)
	-- UIUtil.SetIsVisible(self.InputBox03.RichTextNumber, false)
	
	self.InputBox01:SetIsHideNumber(true)
	self.InputBox02:SetIsHideNumber(true)
	self.InputBox03:SetIsHideNumber(true)
	self.InputBox04:SetIsHideNumber(true)
	self.InputBox05:SetIsHideNumber(true)
	self.InputBox01:SetCallback(self, nil, self.OnPosXValueChange)
	self.InputBox02:SetCallback(self, nil, self.OnPosYValueChange)
	self.InputBox03:SetCallback(self, nil, self.OnAngleValueChange)
	self.InputBox04:SetCallback(self, nil, self.OnBtnSetBgPos)
	self.InputBox05:SetCallback(self, nil, self.OnBtnSetBgPos)

	self.Text1:SetText("X")
	self.Text2:SetText("Y")
	self.Text3:SetText("Angle")
	self.Text4:SetText("BgX")
	self.Text5:SetText("BgY")
end

function PuzzleGMPanelView:OnDestroy()

end

function PuzzleGMPanelView:OnShow()
end

function PuzzleGMPanelView:OnHide()

end

function PuzzleGMPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn01, self.OnBtnSubX)
    UIUtil.AddOnClickedEvent(self, self.Btn02, self.OnBtnAddX)

	UIUtil.AddOnClickedEvent(self, self.Btn01_1, self.OnBtnSubY)
    UIUtil.AddOnClickedEvent(self, self.Btn02_1, self.OnBtnAddY)
	UIUtil.AddOnClickedEvent(self, self.Btn01_2, self.OnBtnSubAngle)
    UIUtil.AddOnClickedEvent(self, self.Btn02_2, self.OnBtnAddAngle)


	self.InputBox01:SetMaxNum(2000)
	self.InputBox02:SetMaxNum(2000)
	self.InputBox03:SetMaxNum(360)
	self.InputBox04:SetMaxNum(2000)
	self.InputBox05:SetMaxNum(2000)
end

function PuzzleGMPanelView:OnRegisterGameEvent()

end

function PuzzleGMPanelView:OnRegisterBinder()

end

function PuzzleGMPanelView:UpdateSelectPuzzleItemData()
	local SelectMoveBread = self.ParentView.SelectMoveBread
	if SelectMoveBread == nil then
		return
	end

	local Pos, Angle = self.ParentView:GetSelectPuzzleItemData()
	self.InputBox01:SetText(Pos.X)
	self.InputBox02:SetText(Pos.Y)
	self.InputBox03:SetText(Angle)
end


function PuzzleGMPanelView:ResetData()
	self.InputBox01:SetText("")
	self.InputBox02:SetText("")
	self.InputBox03:SetText("")
end

function PuzzleGMPanelView:LookBgPos()
	local Pos = UIUtil.CanvasSlotGetPosition(self.ParentView.ImgLightYes)
	self.InputBox04:SetText(Pos.X)
	self.InputBox05:SetText(Pos.Y)
end

function PuzzleGMPanelView:OnBtnSetBgPos()
	local X = tonumber(self.InputBox04:GetText())
	local Y = tonumber(self.InputBox05:GetText())
	if X == nil or Y== nil then
		return
	end
	local Pos = _G.UE.FVector2D(X, Y)
	self.ParentView:SetBgPosition(Pos)
end

function PuzzleGMPanelView:OnBtnSubX()
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(-1, 0, 0)
	self:UpdateSelectPuzzleItemData()
end

function PuzzleGMPanelView:OnBtnAddX()
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(1, 0, 0)
	self:UpdateSelectPuzzleItemData()

end

function PuzzleGMPanelView:OnBtnSubY()
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(0, -1, 0)
	self:UpdateSelectPuzzleItemData()
end

function PuzzleGMPanelView:OnBtnAddY()
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(0, 1, 0)
	self:UpdateSelectPuzzleItemData()
end

function PuzzleGMPanelView:OnBtnSubAngle()
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(0, 0, -1)
	self:UpdateSelectPuzzleItemData()
end

function PuzzleGMPanelView:OnBtnAddAngle()
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(0, 0, 1)
	self:UpdateSelectPuzzleItemData()
end

function PuzzleGMPanelView:OnPosXValueChange(Text)
	if Text == "" then
		return
	end

	if not tonumber(Text) then
		MsgTipsUtil.ShowTips("请输入数字")
		return
	end
	local SelectMoveBread = self.ParentView.SelectMoveBread
	if SelectMoveBread == nil then
		return
	end

	local Pos, Angle = self.ParentView:GetSelectPuzzleItemData()
	local XOffset = tonumber(Text) - Pos.X
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(XOffset, 0, 0)
end

function PuzzleGMPanelView:OnPosYValueChange(Text)
	if Text == "" then
		return
	end
	if not tonumber(Text) then
		MsgTipsUtil.ShowTips("请输入数字")
		return
	end
	local SelectMoveBread = self.ParentView.SelectMoveBread
	if SelectMoveBread == nil then
		return
	end
	local Pos, Angle = self.ParentView:GetSelectPuzzleItemData()
	local YOffset = tonumber(Text) - Pos.Y
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(0, YOffset, 0)
end

function PuzzleGMPanelView:OnAngleValueChange(Text)
	if Text == "" then
		return
	end
	if not tonumber(Text) then
		MsgTipsUtil.ShowTips("请输入数字")
		return
	end
	local SelectMoveBread = self.ParentView.SelectMoveBread
	if SelectMoveBread == nil then
		return
	end
	local Pos, Angle = self.ParentView:GetSelectPuzzleItemData()
	local AngleOffset = tonumber(Text) - Angle
	self.ParentView:ChangeSelectPuzzleItemPosAndAngle(0, 0, AngleOffset)
end


return PuzzleGMPanelView