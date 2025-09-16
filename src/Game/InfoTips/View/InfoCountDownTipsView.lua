---
--- Author: Administrator
--- DateTime: 2023-10-07 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class InfoCountDownTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNameBG UFImage
---@field ImgProbar URadialImage
---@field RichTextNPCDialog URichTextBox
---@field RichTextNPCName URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoCountDownTipsView = LuaClass(UIView, true)

function InfoCountDownTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNameBG = nil
	--self.ImgProbar = nil
	--self.RichTextNPCDialog = nil
	--self.RichTextNPCName = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoCountDownTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoCountDownTipsView:OnInit()

end

function InfoCountDownTipsView:OnDestroy()

end

function InfoCountDownTipsView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.CurLoopCount = 0
	self.ImgProbar:SetPercent(0)
	local NPCName = Params.NPCName
	if NPCName ~= nil then
		UIUtil.SetIsVisible(self.RichTextNPCName, true)
		self.RichTextNPCName:SetText(Params.NPCName)
	else
		UIUtil.SetIsVisible(self.RichTextNPCName, false)
	end
	local Content = Params.Content
	if Content ~= nil then
		self.RichTextNPCDialog:SetText(Params.Content)
	end
	local ShowTime = Params.ShowTime
	if ShowTime ~= nil then
		local LerpPro = 0.01
		local LoopNum = math.ceil(1 / LerpPro)
		local Interval = ShowTime / LoopNum
		local function SetProPercent(self, LerpPro)
			self.CurLoopCount = self.CurLoopCount + 1
			local CurPro = 1 - LerpPro * self.CurLoopCount
			self.ImgProbar:SetPercent(CurPro)
			if CurPro == 0 then
				self:Hide()
			end
		end

		self:RegisterTimer(SetProPercent, 0, Interval, LoopNum, LerpPro)
	end
	local TextSubTitleVisible = Params.TextSubTitleVisible
	if TextSubTitleVisible ~= nil then
		UIUtil.SetIsVisible(self.TextSubTitle, false)
	end
end

function InfoCountDownTipsView:OnHide()
	self.Params = nil
end

function InfoCountDownTipsView:OnRegisterUIEvent()

end

function InfoCountDownTipsView:OnRegisterGameEvent()

end

function InfoCountDownTipsView:OnRegisterBinder()

end

return InfoCountDownTipsView