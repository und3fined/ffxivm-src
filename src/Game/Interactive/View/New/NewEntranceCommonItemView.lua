---
--- Author: saintzhao
--- DateTime: 2024-04-10 14:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")

---@class NewEntranceCommonItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewEntranceCommonItemView = LuaClass(UIView, true)

function NewEntranceCommonItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewEntranceCommonItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewEntranceCommonItemView:OnInit()

end

function NewEntranceCommonItemView:OnDestroy()

end

function NewEntranceCommonItemView:OnShow()
	if nil == self.Params then return end

	local FunctionItem = self.Params.Data
	if nil == FunctionItem then return end

	local ESlateVisibility = _G.UE.ESlateVisibility
	if self.Object then
		self.Object:SetVisibility(ESlateVisibility.Visible)
	end

	self:FillFunction(FunctionItem)
end

function NewEntranceCommonItemView:OnHide()

end

function NewEntranceCommonItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function NewEntranceCommonItemView:OnRegisterGameEvent()

end

function NewEntranceCommonItemView:OnRegisterBinder()

end

function NewEntranceCommonItemView:OnClickBtn()
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")
	if nil ~= self.FunctionItem then
		self.FunctionItem:Click()
	end
end

function NewEntranceCommonItemView:FillFunction(FunctionItem)
	self.Text:SetText(FunctionItem.DisplayName)
	self.FunctionItem = FunctionItem

	if FunctionItem.FuncType == LuaFuncType.NPCQUIT_FUNC or FunctionItem.FuncType == LuaFuncType.QUIT_FUNC then
		UIUtil.ImageSetBrushFromAssetPath(self.Icon, "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Leave.UI_NPC_Icon_Leave'")
	else
		local IconPath = self:GetIconPath(FunctionItem.FuncParams.FuncValue)
		if not string.isnilorempty(IconPath) then
			UIUtil.ImageSetBrushFromAssetPath(self.Icon, FunctionItem:GetIconPath())
		end
	end
end

function NewEntranceCommonItemView:GetIconPath(InteractiveID)
	local Cfg = InteractivedescCfg:FindCfgByKey(InteractiveID)
	if nil ~= Cfg then
		return Cfg.IconPath
	end
	return nil
end

return NewEntranceCommonItemView