---
--- Author: moodliu
--- DateTime: 2024-01-23 11:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local PerformanceSongPanelVM = require("Game/Performance/VM/PerformanceSongPanelVM")
local ProtoCS = require("Protocol/ProtoCS")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MajorUtil = require("Utils/MajorUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")

---@class PerformanceProtocolWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameSView
---@field LeftBtnOp CommBtnLView
---@field Panel2Btns UFHorizontalBox
---@field PanelSingleBox UFCanvasPanel
---@field RichTextContent URichTextBox
---@field RightBtnOp CommBtnLView
---@field SingleBox CommSingleBoxView
---@field SpacerMid USpacer
---@field TextSingleBox UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceProtocolWinView = LuaClass(UIView, true)

function PerformanceProtocolWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.LeftBtnOp = nil
	--self.Panel2Btns = nil
	--self.PanelSingleBox = nil
	--self.RichTextContent = nil
	--self.RightBtnOp = nil
	--self.SingleBox = nil
	--self.SpacerMid = nil
	--self.TextSingleBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceProtocolWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.RightBtnOp)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceProtocolWinView:OnInit()
	self:InitStaticText()
	self.VM = PerformanceSongPanelVM.New()
end

function PerformanceProtocolWinView:InitStaticText()
	self.BG:SetTitleText(_G.LSTR(830084))
	self.TextSingleBox:SetText(_G.LSTR(830086))

	self.LeftBtnOp:SetBtnName(_G.LSTR(830085))
	self.RightBtnOp:SetBtnName(_G.LSTR(830060))
end

function PerformanceProtocolWinView:OnDestroy()

end

function PerformanceProtocolWinView:OnShow()
	self.SingleBox:SetChecked(false)
	self.VM.IsAgree = self.SingleBox:GetChecked()
	
	local HelpCfgs = HelpCfg:FindAllHelpIDCfg(10012)
	if HelpCfgs and #HelpCfgs >= 2 then
		local ResList, RetID = HelpInfoUtil.ParseContent(HelpCfgs)
		local TipsContent = HelpInfoUtil.ParseText(ResList)
		if #ResList >= 1 then
			self.BG:SetTitleText(ResList[1].HelpName)
		end

		if #TipsContent >= 1 then
			if #TipsContent[1].Content >= 2 then
				local TextContent  = TipsContent[1].Content[1].."\n"..TipsContent[1].Content[2]
				self.RichTextContent:SetText(TextContent)
			end
		end
	end
end

function PerformanceProtocolWinView:OnHide()

end

function PerformanceProtocolWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxStateChanged)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, self.Hide)
	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, self.SendAgree)
end

function PerformanceProtocolWinView:SendAgree()
	_G.ClientSetupMgr:SendSetReq(ProtoCS.ClientSetupKey.CSKPerformAgreement, MPDefines.AgreeProtocolValue)
end

function PerformanceProtocolWinView:OnSingleBoxStateChanged(_, State)
	self.VM.IsAgree = UIUtil.IsToggleButtonChecked(State)
end

function PerformanceProtocolWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ClientSetupPost, self.OnClientSetupPost)
end

function PerformanceProtocolWinView:OnClientSetupPost(Params)
	local RoleID = Params.ULongParam1
	local Key = Params.IntParam1
	local Value = Params.StringParam1

	if not _G.MusicPerformanceMgr:CheckProf() then
		self:Hide()
		return
	end

	if RoleID == MajorUtil.GetMajorRoleID() and Key == ProtoCS.ClientSetupKey.CSKPerformAgreement and Value == MPDefines.AgreeProtocolValue then
		if not _G.MusicPerformanceMgr:CheckProf() then
			self:Hide()
			return
		end
		self:Hide()
		_G.UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView)
	end
end

function PerformanceProtocolWinView:OnRegisterBinder()
	local Binders = {
		{ "IsAgree", UIBinderSetIsEnabled.New(self, self.LeftBtnOp)},
	}

	self:RegisterBinders(self.VM, Binders)
end

return PerformanceProtocolWinView