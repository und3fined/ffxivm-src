---
--- Author: Administrator
--- DateTime: 2025-02-26 16:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsHalloweenGameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field Panelpaper UFCanvasPanel
---@field RichTextBoxHint URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenGameWinView = LuaClass(UIView, true)

function OpsHalloweenGameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.Panelpaper = nil
	--self.RichTextBoxHint = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenGameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenGameWinView:OnInit()

end

function OpsHalloweenGameWinView:OnDestroy()

end

function OpsHalloweenGameWinView:OnShow()
	if self.Params == nil then
		return
	end

	self.TextTitle:SetText(self.Params.Title)
	self.RichTextBoxHint:SetText(self.Params.Content)
end

function OpsHalloweenGameWinView:OnHide()

end

function OpsHalloweenGameWinView:OnRegisterUIEvent()

end

function OpsHalloweenGameWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function OpsHalloweenGameWinView:OnRegisterBinder()

end

function OpsHalloweenGameWinView:OnPreprocessedMouseButtonUp(MouseEvent)
	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.Panelpaper, MousePosition) == false then
		self:Hide()
	end
end

return OpsHalloweenGameWinView