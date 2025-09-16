---
--- Author: daniel
--- DateTime: 2023-03-28 09:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyMgr = nil

---@class ArmyRankNameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameSView
---@field BtnCancel CommBtnLView
---@field BtnConfirm CommBtnLView
---@field InputBox CommInputBoxView
---@field TextError UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRankNameWinView = LuaClass(UIView, true)

function ArmyRankNameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnConfirm = nil
	--self.InputBox = nil
	--self.TextError = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.SureCallback = nil
end

function ArmyRankNameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.InputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRankNameWinView:OnInit()
    ArmyMgr = require("Game/Army/ArmyMgr")
end

function ArmyRankNameWinView:OnDestroy()

end

function ArmyRankNameWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.BG.FText_Title:SetText(Params.Title)
	self.InputBox:SetHintText(Params.HintText)
	self.InputBox.MaxNum = Params.MaxTextLength
	self.InputBox:SetText(Params.Content or "")
	self.SureCallback = Params.SureCallback
end

function ArmyRankNameWinView:OnHide()

end

function ArmyRankNameWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickedConfirm)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
end

function ArmyRankNameWinView:OnRegisterGameEvent()

end

function ArmyRankNameWinView:OnRegisterBinder()

end

function ArmyRankNameWinView:OnClickedConfirm()
	local Text = self.InputBox:GetText()
	ArmyMgr:CheckSensitiveText(Text, function( IsLegal )
		if IsLegal then
            if self.SureCallback then
				self.SureCallback(Text)
			end
			self:Hide()
        end
    end, true)
end

return ArmyRankNameWinView