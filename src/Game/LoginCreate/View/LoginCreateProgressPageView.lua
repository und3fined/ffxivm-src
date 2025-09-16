---
--- Author: chriswang
--- DateTime: 2023-10-18 10:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIViewID = require("Define/UIViewID")
---@class LoginCreateProgressPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnProgress UFButton
---@field Img1Now UFImage
---@field Img2Now UFImage
---@field Img3Now UFImage
---@field Img4Now UFImage
---@field Img5Now UFImage
---@field Img6Now UFImage
---@field Img7Now UFImage
---@field Img8Now UFImage
---@field Panel7th UFCanvasPanel
---@field Panel8th UFCanvasPanel
---@field PanelFifth UFCanvasPanel
---@field PanelFirst UFCanvasPanel
---@field PanelFourth UFCanvasPanel
---@field PanelSecond UFCanvasPanel
---@field PanelSixth UFCanvasPanel
---@field PanelThird UCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateProgressPageView = LuaClass(UIView, true)

function LoginCreateProgressPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnProgress = nil
	--self.Img1Now = nil
	--self.Img2Now = nil
	--self.Img3Now = nil
	--self.Img4Now = nil
	--self.Img5Now = nil
	--self.Img6Now = nil
	--self.Img7Now = nil
	--self.Img8Now = nil
	--self.Panel7th = nil
	--self.Panel8th = nil
	--self.PanelFifth = nil
	--self.PanelFirst = nil
	--self.PanelFourth = nil
	--self.PanelSecond = nil
	--self.PanelSixth = nil
	--self.PanelThird = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateProgressPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateProgressPageView:OnInit()

end

function LoginCreateProgressPageView:OnDestroy()

end

function LoginCreateProgressPageView:OnShow()
	_G.LoginUIMgr.ProgressPage = self
	--幻想药模式只有7个阶段，第8个阶段要隐藏
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		UIUtil.SetIsVisible(self.Panel8th, false, false, false)
	else
		UIUtil.SetIsVisible(self.Panel8th, true, false, false)
	end
end

function LoginCreateProgressPageView:OnHide()
	_G.LoginUIMgr.ProgressPage = nil
end

function LoginCreateProgressPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnProgress, self.OnBtnProgressClick)
end

function LoginCreateProgressPageView:OnRegisterGameEvent()

end

function LoginCreateProgressPageView:OnRegisterBinder()

end

function LoginCreateProgressPageView:OnBtnProgressClick()
	_G.UIViewMgr:ShowView(UIViewID.LoginProgressWin)
end

function LoginCreateProgressPageView:OnPhaseChage(CurPhase)
	--由于增加了幻想药的流程，PhaseType的值不等于PhaseIndex，因此需要转换一下
	local MaxDonePhase = _G.LoginUIMgr:PhaseTypeToIndex(_G.LoginUIMgr.MaxDonePhase)
	local RealPhaseIndex = _G.LoginUIMgr:PhaseTypeToIndex(CurPhase)
	FLOG_INFO("LoginRoleProgressPageView:OnPhaseChage phase:%d", RealPhaseIndex)
	for index = 1, 8 do
		local ImageNow = self["Img" .. index .. "Now"]
		-- local ImageDone = self["Img" .. index .. "Done"]
		-- local ImageUndone = self["Img" .. index .. "Undone"]
		
		if index <= MaxDonePhase then
			if index == RealPhaseIndex then
				UIUtil.SetIsVisible(ImageNow, true)
	
				-- if ImageDone then
				-- 	UIUtil.SetIsVisible(ImageDone, false)
				-- end
	
				-- if ImageUndone then
				-- 	UIUtil.SetIsVisible(ImageUndone, false)
				-- end
			else							--已做的
				UIUtil.SetIsVisible(ImageNow, false)
	
				-- if ImageDone then
				-- 	UIUtil.SetIsVisible(ImageDone, true)
				-- end
	
				-- if ImageUndone then
				-- 	UIUtil.SetIsVisible(ImageUndone, false)
				-- end
			end
		else								--未做的
			UIUtil.SetIsVisible(ImageNow, false)
			-- if ImageDone then
			-- 	UIUtil.SetIsVisible(ImageDone, false)
			-- end

			-- if ImageUndone then
			-- 	UIUtil.SetIsVisible(ImageUndone, true)
			-- end
		end
	end
end

return LoginCreateProgressPageView