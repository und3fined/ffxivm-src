---
--- Author: xingcaicao
--- DateTime: 2025-03-18 14:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")

local LSTR = _G.LSTR
local ImgSaveStrategy = PersonPortraitDefine.ImgSaveStrategy

---@class PersonPortraitSaveSetWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnOk CommBtnLView
---@field CheckBoxAllProf CommCheckBoxView
---@field CheckBoxCurProf CommCheckBoxView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field FTextAllProf UFTextBlock
---@field FTextCurProf UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitSaveSetWinView = LuaClass(UIView, true)

function PersonPortraitSaveSetWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnOk = nil
	--self.CheckBoxAllProf = nil
	--self.CheckBoxCurProf = nil
	--self.Comm2FrameM_UIBP = nil
	--self.FTextAllProf = nil
	--self.FTextCurProf = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitSaveSetWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOk)
	self:AddSubView(self.CheckBoxAllProf)
	self:AddSubView(self.CheckBoxCurProf)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitSaveSetWinView:OnInit()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(60015)) -- 保存设置
	self.FTextCurProf:SetText(LSTR(60035)) -- 保存肖像至当前职业使用 
	self.FTextAllProf:SetText(LSTR(60036)) -- 保存肖像至全部职业使用 
	self.BtnCancel:SetButtonText(LSTR(10003)) -- 取  消
	self.BtnOk:SetButtonText(LSTR(10002)) -- 确  认
end

function PersonPortraitSaveSetWinView:OnDestroy()

end

function PersonPortraitSaveSetWinView:OnShow()
   -- 图片保存策略 0 本职业 1 全部职业
   local IsAll = PersonPortraitVM.SaveImgUrlStrategy == ImgSaveStrategy.AllProf
   self:SetCheckBox(self.CheckBoxAllProf, IsAll)
   self:SetCheckBox(self.CheckBoxCurProf, not IsAll)
end

function PersonPortraitSaveSetWinView:OnHide()

end

function PersonPortraitSaveSetWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxCurProf, self.OnStateChangedCheckBoxCurProf)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxAllProf, self.OnStateChangedCheckBoxAllProf)

	UIUtil.AddOnClickedEvent(self, self.BtnCancel, 	self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnOk, 	self.OnClickButtonOk)
end

function PersonPortraitSaveSetWinView:OnRegisterGameEvent()

end

function PersonPortraitSaveSetWinView:OnRegisterBinder()

end

function PersonPortraitSaveSetWinView:SetCheckBox(CheckBox, IsChecked)
	CheckBox:SetClickable(not IsChecked)
	CheckBox:SetChecked(IsChecked, false)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack 


function PersonPortraitSaveSetWinView:OnStateChangedCheckBoxCurProf(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		self.CheckBoxCurProf:SetClickable(false)

		self:SetCheckBox(self.CheckBoxAllProf, false)
	end
end

function PersonPortraitSaveSetWinView:OnStateChangedCheckBoxAllProf(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		self.CheckBoxAllProf:SetClickable(false)

		self:SetCheckBox(self.CheckBoxCurProf, false)
	end
end

function PersonPortraitSaveSetWinView:OnClickButtonCancel()
	self:Hide()
end

function PersonPortraitSaveSetWinView:OnClickButtonOk()
	local Strategy = self.CheckBoxAllProf:GetChecked() and ImgSaveStrategy.AllProf or ImgSaveStrategy.CurProf
	PersonPortraitVM:SetSaveImgUrlStrategy(Strategy, true)

	self:Hide()
end

return PersonPortraitSaveSetWinView