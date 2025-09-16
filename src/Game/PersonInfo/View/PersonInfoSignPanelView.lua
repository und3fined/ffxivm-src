---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")

local LSTR = _G.LSTR

---@class PersonInfoSignPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field MulInputBoxContent CommMultilineInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoSignPanelView = LuaClass(UIView, true)

function PersonInfoSignPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.Comm2FrameS_UIBP = nil
	--self.MulInputBoxContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoSignPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.Comm2FrameS_UIBP)
	self:AddSubView(self.MulInputBoxContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoSignPanelView:OnInit()
	self.MulInputBoxContent:SetMaxNum(60)
	self.MulInputBoxContent:SetCallback(self, self.OnTextChanged)

	self.BtnCancel:SetText(_G.LSTR(10003))
	self.BtnSave:SetText(_G.LSTR(10002))
	self.Comm2FrameS_UIBP.FText_Title:SetText(_G.LSTR(620114))
end

function PersonInfoSignPanelView:OnDestroy()

end

function PersonInfoSignPanelView:OnShow()
	self.BtnSave:SetIsEnabled(true)
	self.MulInputBoxContent:SetText(PersonInfoVM.SignContent or "")
end

function PersonInfoSignPanelView:OnHide()
	self.MulInputBoxContent:SetText("")
end

function PersonInfoSignPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
end

function PersonInfoSignPanelView:OnRegisterGameEvent()

end

function PersonInfoSignPanelView:OnRegisterBinder()

end

function PersonInfoSignPanelView:OnTextChanged( Text )
	self.BtnSave:SetIsEnabled(Text ~= PersonInfoVM.SignContent)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoSignPanelView:OnClickButtonSave()
	local Content = self.MulInputBoxContent:GetText()
	if nil == Content then
		return
	end

	self.BtnSave:SetIsEnabled(false)
	PersonInfoVM:SaveSignContent(Content)

	self:OnClickButtonCancel()
end

function PersonInfoSignPanelView:OnClickButtonCancel()
	self:Hide()
end


return PersonInfoSignPanelView