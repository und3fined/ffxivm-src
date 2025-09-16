---
--- Author: xingcaicao
--- DateTime: 2023-05-18 21:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")

---@class TeamRecruitCodeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameSView
---@field BtnCancel CommBtnLView
---@field BtnEnter CommBtnLView
---@field TextInput UFTextBlock
---@field TextPassword UEditableText
---@field AnimErrorPassword UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitCodeView = LuaClass(UIView, true)

function TeamRecruitCodeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnCancel = nil
	--self.BtnEnter = nil
	--self.TextInput = nil
	--self.TextPassword = nil
	--self.AnimErrorPassword = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitCodeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnEnter)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitCodeView:OnShow()
	self.TextPassword:SetText("")

	self.Bg:SetTitleText(_G.LSTR(1310088))
	self.TextInput:SetText(_G.LSTR(1310090))
	self.BtnCancel:SetText(_G.LSTR(1310091))
	self.BtnEnter:SetText(_G.LSTR(1310092))
end

function TeamRecruitCodeView:OnRegisterUIEvent()
	UIUtil.AddOnTextChangedEvent(self, self.TextPassword, self.OnTextChangedCode)

	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnEnter, self.OnClickedEnter)
end

function TeamRecruitCodeView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ErrorCode, self.OnGameEventErrorCode)
end

function TeamRecruitCodeView:OnRegisterBinder()

end

function TeamRecruitCodeView:OnTextChangedCode(_, Text)
	local NewText = Text
    -- lengh cut
	if string.len(Text) > TeamRecruitDefine.MaxCodeLength and TeamRecruitDefine.MaxCodeLength > 0 then
		NewText = string.sub(Text, 1, TeamRecruitDefine.MaxCodeLength)
	end
	-- number refine
	local Ix = string.find(NewText, "%D")
	if Ix ~= nil then
		NewText = string.sub(NewText, 1, Ix-1)
	end
	-- avoid recursive lua bug
	local DelaySetText = function(w, NText)
		if w and w.TextPassword then
			w.TextPassword:SetText(NText)
		end
	end
	if NewText ~= Text then
		self:RegisterTimer(DelaySetText, 0, 0.001, 1, NewText)
	end
end

function TeamRecruitCodeView:OnGameEventErrorCode( ErrorCode )
	if ErrorCode == TeamRecruitDefine.PasswordErrorCode then
		self:PlayAnimation(self.AnimErrorPassword)
	end
end

-------------------------------------------------------------------------------------------------------
--- Component CallBack

function TeamRecruitCodeView:OnClickedCancel()
	self:Hide()
end

function TeamRecruitCodeView:OnClickedEnter()
	local RoleID = self.Params and self.Params.RoleID
	if nil == RoleID then
		return
	end

	local Password = self.TextPassword:GetText()
	if #(Password or "") == 0 then
		_G.MsgTipsUtil.ShowErrorTips(LSTR(1310032))
		return
	end
	
	self:Hide()
	_G.TeamRecruitMgr:TryJoinRecruit(self.Params.FromView, RoleID, Password, self.Params.ContentID)
end

return TeamRecruitCodeView