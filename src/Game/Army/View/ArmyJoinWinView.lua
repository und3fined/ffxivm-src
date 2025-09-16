---
--- Author: daniel
--- DateTime: 2023-03-20 17:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyMgr = nil

---@class ArmyJoinWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg CommMsgTipsView
---@field BtnApply CommBtnLView
---@field BtnCancel CommBtnLView
---@field InputBox CommMultilineInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyJoinWinView = LuaClass(UIView, true)

function ArmyJoinWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnApply = nil
	--self.BtnCancel = nil
	--self.InputBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.Callback = nil
end

function ArmyJoinWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnApply)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.InputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJoinWinView:OnInit()
    ArmyMgr = require("Game/Army/ArmyMgr")
end

function ArmyJoinWinView:OnDestroy()

end

function ArmyJoinWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.InputBox.MaxNum = Params.MaxTextLength
	self.InputBox:UpdateDescText()
	self.InputBox:SetHintText(Params.HintText)
	self.Callback = Params.Callback

	-- LSTR string:申请加入部队
	self.BG:SetTitleText(LSTR(910307))
	-- LSTR string:申请加入
	self.BtnApply:SetText(LSTR(910179))
	-- LSTR string:取  消
	self.BtnCancel:SetText(LSTR(910081))
end

function ArmyJoinWinView:OnHide()
	self.InputBox:SetText("")
	self.Callback = nil
end

function ArmyJoinWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnApply, self.OnClickedCommit)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
end

function ArmyJoinWinView:OnRegisterGameEvent()

end

function ArmyJoinWinView:OnRegisterBinder()

end

function ArmyJoinWinView:OnClickedCommit()
	local Msg = self.InputBox:GetText()
	---查询文本是否合法（敏感词）
	ArmyMgr:CheckSensitiveText(Msg, function( IsLegal )
		if IsLegal then
            if self.Callback then
				self.Callback(Msg)
				self.InputBox:SetText("")
			end
			self:Hide()
		else
			-- LSTR string:当前文本不可使用，请重新输入
			MsgTipsUtil.ShowErrorTips(LSTR(10057))
        end
    end)
end

return ArmyJoinWinView