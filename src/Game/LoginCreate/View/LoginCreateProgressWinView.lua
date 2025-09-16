---
--- Author: chriswang
--- DateTime: 2023-10-18 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateProgressWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAppearance UFButton
---@field BtnBrithday UFButton
---@field BtnCustomize UFButton
---@field BtnGod UFButton
---@field BtnName UFButton
---@field BtnRaceGender UFButton
---@field BtnRole UFButton
---@field BtnTribe UFButton
---@field ImgStep1Done UFImage
---@field ImgStep1Now UFImage
---@field ImgStep2Done UFImage
---@field ImgStep2Now UFImage
---@field ImgStep2Undone UFImage
---@field ImgStep3Done UFImage
---@field ImgStep3Now UFImage
---@field ImgStep3Undone UFImage
---@field ImgStep4Done UFImage
---@field ImgStep4Now UFImage
---@field ImgStep4Undone UFImage
---@field ImgStep5Done UFImage
---@field ImgStep5Now UFImage
---@field ImgStep5Undone UFImage
---@field ImgStep6Done UFImage
---@field ImgStep6Now UFImage
---@field ImgStep6Undone UFImage
---@field ImgStep7Done UFImage
---@field ImgStep7Now UFImage
---@field ImgStep7Undone UFImage
---@field ImgStep8Done UFImage
---@field ImgStep8Now UFImage
---@field ImgStep8Undone UFImage
---@field PanelStep1 UFCanvasPanel
---@field PanelStep2 UFCanvasPanel
---@field PanelStep3 UFCanvasPanel
---@field PanelStep4 UFCanvasPanel
---@field PanelStep5_1 UFCanvasPanel
---@field PanelStep6 UFCanvasPanel
---@field PanelStep7 UFCanvasPanel
---@field PanelStep8 UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field Text4 UFTextBlock
---@field Text5 UFTextBlock
---@field Text6 UFTextBlock
---@field Text7 UFTextBlock
---@field Text8 UFTextBlock
---@field TextClickTips UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimStep1 UWidgetAnimation
---@field AnimStep2 UWidgetAnimation
---@field AnimStep3 UWidgetAnimation
---@field AnimStep4 UWidgetAnimation
---@field AnimStep5 UWidgetAnimation
---@field AnimStep6 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateProgressWinView = LuaClass(UIView, true)

function LoginCreateProgressWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAppearance = nil
	--self.BtnBrithday = nil
	--self.BtnCustomize = nil
	--self.BtnGod = nil
	--self.BtnName = nil
	--self.BtnRaceGender = nil
	--self.BtnRole = nil
	--self.BtnTribe = nil
	--self.ImgStep1Done = nil
	--self.ImgStep1Now = nil
	--self.ImgStep2Done = nil
	--self.ImgStep2Now = nil
	--self.ImgStep2Undone = nil
	--self.ImgStep3Done = nil
	--self.ImgStep3Now = nil
	--self.ImgStep3Undone = nil
	--self.ImgStep4Done = nil
	--self.ImgStep4Now = nil
	--self.ImgStep4Undone = nil
	--self.ImgStep5Done = nil
	--self.ImgStep5Now = nil
	--self.ImgStep5Undone = nil
	--self.ImgStep6Done = nil
	--self.ImgStep6Now = nil
	--self.ImgStep6Undone = nil
	--self.ImgStep7Done = nil
	--self.ImgStep7Now = nil
	--self.ImgStep7Undone = nil
	--self.ImgStep8Done = nil
	--self.ImgStep8Now = nil
	--self.ImgStep8Undone = nil
	--self.PanelStep1 = nil
	--self.PanelStep2 = nil
	--self.PanelStep3 = nil
	--self.PanelStep4 = nil
	--self.PanelStep5_1 = nil
	--self.PanelStep6 = nil
	--self.PanelStep7 = nil
	--self.PanelStep8 = nil
	--self.PopUpBG = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.Text4 = nil
	--self.Text5 = nil
	--self.Text6 = nil
	--self.Text7 = nil
	--self.Text8 = nil
	--self.TextClickTips = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimStep1 = nil
	--self.AnimStep2 = nil
	--self.AnimStep3 = nil
	--self.AnimStep4 = nil
	--self.AnimStep5 = nil
	--self.AnimStep6 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateProgressWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateProgressWinView:OnInit()

end

function LoginCreateProgressWinView:OnDestroy()

end

function LoginCreateProgressWinView:OnShow()
	_G.LoginUIMgr:SetCurPhaseOpacity(0.4)
	self:UpdateUI()
	--幻想药模式第7阶段的标题是确认信息，默认是职业
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		UIUtil.SetIsVisible(self.PanelStep8, false, false, false)
		self.Text7:SetText(LSTR(980036))
	else
		UIUtil.SetIsVisible(self.PanelStep8, true, false, false)
		self.Text7:SetText(LSTR(980038))
	end
	
	self.Text1:SetText(_G.LSTR(980059))	--种族性别
	self.Text2:SetText(_G.LSTR(980050))	--部族
	self.Text3:SetText(_G.LSTR(980060))--外貌
	self.Text4:SetText(_G.LSTR(980061))--外貌细节
	self.Text5:SetText(_G.LSTR(980051))--创建日
	self.Text6:SetText(_G.LSTR(980052))--守护神
	self.Text7:SetText(_G.LSTR(980053))--职业
	self.Text8:SetText(_G.LSTR(980062))--设置昵称
	self.TextClickTips:SetText(_G.LSTR(980063))--点击空白处关闭
end

function LoginCreateProgressWinView:OnHide()
	_G.LoginUIMgr:SetCurPhaseOpacity(1)
end

function LoginCreateProgressWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRaceGender, self.OnPhaseBtnClick, 1)
	UIUtil.AddOnClickedEvent(self, self.BtnTribe, self.OnPhaseBtnClick, 2)
	UIUtil.AddOnClickedEvent(self, self.BtnAppearance, self.OnPhaseBtnClick, 3)
	UIUtil.AddOnClickedEvent(self, self.BtnCustomize, self.OnPhaseBtnClick, 4)
	UIUtil.AddOnClickedEvent(self, self.BtnBrithday, self.OnPhaseBtnClick, 5)
	UIUtil.AddOnClickedEvent(self, self.BtnGod, self.OnPhaseBtnClick, 6)
	UIUtil.AddOnClickedEvent(self, self.BtnRole, self.OnPhaseBtnClick, 7)
	UIUtil.AddOnClickedEvent(self, self.BtnName, self.OnPhaseBtnClick, 8)
end

function LoginCreateProgressWinView:OnRegisterGameEvent()

end

function LoginCreateProgressWinView:OnRegisterBinder()

end

function LoginCreateProgressWinView:OnPhaseBtnClick(ToPhase)
	--由于增加了幻想药的流程，PhaseIndex的值不等于PhaseType，因此需要转换一下
	local RealPhaseType = _G.LoginUIMgr:PhaseIndexToType(ToPhase)
	if self.CurPhaseIndex and self.CurPhaseIndex == ToPhase then
		print("======")
		return
	end

	if _G.LoginUIMgr:PhaseTypeToIndex(_G.LoginUIMgr.MaxDonePhase) < ToPhase then
		print(">>>>>>>>>>>")
		return
	end
	
	self.CurPhaseIndex = ToPhase

	_G.LoginUIMgr:SetCurPhaseOpacity(1)
	_G.LoginUIMgr:SwitchToPhase(RealPhaseType)
    local function DelaySetPhaseOpacity()
		_G.LoginUIMgr:SetCurPhaseOpacity(0.4)
    end
    --临时功能，就写死1.4s了
    self.FastMakeTimerID = _G.TimerMgr:AddTimer(nil, DelaySetPhaseOpacity, 0.01, 1, 1)
	self:UpdateUI()
end

--蓝图做的特殊，1和8少image
function LoginCreateProgressWinView:UpdateUI()
	--由于增加了幻想药的流程，PhaseType的值不等于PhaseIndex，因此需要转换一下
	local CurPhase = _G.LoginUIMgr:PhaseTypeToIndex(_G.LoginUIMgr.CurLoginRolePhase)
	self.CurPhaseIndex = CurPhase
	local MaxDonePhase = _G.LoginUIMgr:PhaseTypeToIndex(_G.LoginUIMgr.MaxDonePhase)
	FLOG_INFO("LoginCreateProgressWinView Cur phase:%d MaxDonePhase:%d", CurPhase, MaxDonePhase)
	for index = 1, 8 do
		local ImageNow = self["ImgStep" .. index .. "Now"]
		local ImageDone = self["ImgStep" .. index .. "Done"]
		local ImageUndone = self["ImgStep" .. index .. "Undone"]
		local Text = self["Text" .. index]
		if index <= MaxDonePhase then
			if index == CurPhase then
				UIUtil.SetIsVisible(ImageNow, true)
				UIUtil.TextBlockSetColorAndOpacityHex(Text, "183f7bFF")
	
				if ImageDone then
					UIUtil.SetIsVisible(ImageDone, false)
				end
	
				if ImageUndone then
					UIUtil.SetIsVisible(ImageUndone, false)
				end
			else							--已做的
				UIUtil.SetIsVisible(ImageNow, false)
				UIUtil.TextBlockSetColorAndOpacityHex(Text, "FFFFFFFF")
	
				if ImageDone then
					UIUtil.SetIsVisible(ImageDone, true)
				end
	
				if ImageUndone then
					UIUtil.SetIsVisible(ImageUndone, false)
				end
			end
		else								--未做的
			UIUtil.SetIsVisible(ImageNow, false)
			UIUtil.TextBlockSetColorAndOpacityHex(Text, "688fb6FF")

			if ImageDone then
				UIUtil.SetIsVisible(ImageDone, false)
			end

			if ImageUndone then
				UIUtil.SetIsVisible(ImageUndone, true)
			end
		end
	end
end

return LoginCreateProgressWinView