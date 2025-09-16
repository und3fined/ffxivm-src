---
--- Author: frankjfwang
--- DateTime: 2022-05-24 21:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UTF8Util = require("Utils/UTF8Util")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")

---@class MagicCardEditGroupNameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFHorizontalBox
---@field CancelBtn CommBtnLView
---@field EditableTextRename CommInputBoxView
---@field FImg_Box UFImage
---@field FImg_Check_1 UFImage
---@field FText_Money UFTextBlock
---@field Icon_Money UFImage
---@field InputBox UFCanvasPanel
---@field OKBtn CommBtnLView
---@field ToggleButtonCheck UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardEditGroupNameView = LuaClass(UIView, true)

function MagicCardEditGroupNameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.CancelBtn = nil
	--self.EditableTextRename = nil
	--self.FImg_Box = nil
	--self.FImg_Check_1 = nil
	--self.FText_Money = nil
	--self.Icon_Money = nil
	--self.InputBox = nil
	--self.OKBtn = nil
	--self.ToggleButtonCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardEditGroupNameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CancelBtn)
	self:AddSubView(self.EditableTextRename)
	self:AddSubView(self.OKBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardEditGroupNameView:OnInit()

end

function MagicCardEditGroupNameView:OnDestroy()

end

function MagicCardEditGroupNameView:OnShow()
	self.CancelBtn:SetButtonText(_G.LSTR(MagicCardLocalDef.UKeyConfig.CommonCancel))
	self.OKBtn:SetButtonText(_G.LSTR(MagicCardLocalDef.UKeyConfig.CommonConfirm))
	self.EditableTextRename:SetMaxNum(MagicCardLocalDef.MaxCharNumForGroupName)
	if self.Params and self.Params.OrigName then
		local OrigGroupName = self.Params.OrigName
		self.EditableTextRename:SetText(OrigGroupName)
	end
end

function MagicCardEditGroupNameView:OnHide()

end

function MagicCardEditGroupNameView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.OKBtn.Button, self.OnOkBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.CancelBtn.Button, self.OnCancelBtnClicked)
end

function MagicCardEditGroupNameView:OnRegisterGameEvent()

end

function MagicCardEditGroupNameView:OnRegisterBinder()

end

function MagicCardEditGroupNameView:OnOkBtnClicked()
	local GroupNameInput = self.EditableTextRename:GetText()
	local function TextIsLegalCallback(bCan)
		if bCan == true then
			if self.Params and self.Params.OnOkCallback then
				self.Params.OnOkCallback(GroupNameInput)
			end
			_G.UIViewMgr:HideView(_G.UIViewID.MagicCardEditGroupNameView)
		else
			local OrigGroupName = self.Params.OrigName
			self.EditableTextRename:SetText(OrigGroupName)
		end
	end
	_G.JudgeSearchMgr:QueryTextIsLegal(GroupNameInput, TextIsLegalCallback, true, LSTR(10057))
end

function MagicCardEditGroupNameView:OnCancelBtnClicked()
	_G.UIViewMgr:HideView(_G.UIViewID.MagicCardEditGroupNameView)
end

return MagicCardEditGroupNameView