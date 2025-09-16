--[[
Author: your name
Date: 2021-08-23 12:44:09
LastEditTime: 2021-08-30 09:56:35
LastEditors: your name
Description: In User Settings Edit
FilePath: \Script\Game\NPCTalk\FunctionCommonItemView.lua
--]]
---
--- Author: chunfengluo
--- DateTime: 2021-08-23 12:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
-- local NpcDialogMgr = _G.NpcDialogMgr
local ProtoRes = require("Protocol/ProtoRes")
local AudioUtil = require("Utils/AudioUtil")
-- local BaseFunctionItemView = require("Game/Interactive/FunctionItemView/BaseFunctionItemView")

local KIL = _G.UE.UKismetInputLibrary
local WBL = _G.UE.UWidgetBlueprintLibrary

---@class FunctionCommonItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field FBtn_Function UFButton
---@field FImg_Icon UFImage
---@field FImg_Normal UFImage
---@field FImg_Pic UFImage
---@field FImg_Select UFImage
---@field FText_FunctionName UFTextBlock
---@field ProgressBar_Use UProgressBar
---@field RichTextFunctionName URichTextBox
---@field Use UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FunctionCommonItemView = LuaClass(UIView, true)

function FunctionCommonItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.FBtn_Function = nil
	--self.FImg_Icon = nil
	--self.FImg_Normal = nil
	--self.FImg_Pic = nil
	--self.FImg_Select = nil
	--self.FText_FunctionName = nil
	--self.ProgressBar_Use = nil
	--self.RichTextFunctionName = nil
	--self.Use = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FunctionCommonItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FunctionCommonItemView:OnInit()
	UIUtil.SetIsVisible(self.FImg_Select, false)
	UIUtil.SetIsVisible(self.FImg_Pic, false)
	UIUtil.SetIsVisible(self.Use, false)
	UIUtil.SetIsVisible(self.FText_FunctionName, false)
end

function FunctionCommonItemView:OnDestroy()

end

function FunctionCommonItemView:OnShow()
	if nil == self.Params then return end

	local FunctionItem = self.Params.Data
	if nil == FunctionItem then return end

	local ESlateVisibility = _G.UE.ESlateVisibility
	if self.Object then
		self.Object:SetVisibility(ESlateVisibility.Visible)
	end
	--不能直接OnShow的收获 再设置self的，会死循环
	-- UIUtil.SetIsVisible(self, true, true)
	self:FillFunction(FunctionItem)

	self.LastMousePos = _G.UE.FVector2D(0, 0)
end

function FunctionCommonItemView:OnHide()

end

function FunctionCommonItemView:OnRegisterUIEvent()
	-- UIUtil.AddOnHoveredEvent(self, self.FBtn_Function, self.OnHovered, nil)
	-- UIUtil.AddOnUnhoveredEvent(self, self.FBtn_Function, self.OnUnhovered, nil)
end

function FunctionCommonItemView:OnRegisterGameEvent()

end

function FunctionCommonItemView:OnRegisterTimer()

end

function FunctionCommonItemView:OnRegisterBinder()

end

function FunctionCommonItemView:OnTouchStarted(MyGeometry, MouseEvent)
	print("Function OnTouchStarted")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true
	--UIUtil.SetIsVisible(self.FImg_Select, true)
end

function FunctionCommonItemView:IsMouseMoved(MouseEvent)
	local MousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if math.abs(MousePos.X - self.LastMousePos.X) > 2 or
		math.abs(MousePos.Y - self.LastMousePos.Y) > 2 then
		return true
	end

	return false
end

function FunctionCommonItemView:OnTouchEnded(MyGeometry, MouseEvent)
	print("Function OnTouchEnded")
	if not self:IsMouseMoved(MouseEvent) then
		self.FunctionItem:Click()
	end
	self.IsSelected = false
	--UIUtil.SetIsVisible(self.FImg_Select, false)
end

function FunctionCommonItemView:OnMouseMove(MyGeometry, MouseEvent)
	if not self.IsSelected then
		return
	end

	print("OnMouseMove")
	if self:IsMouseMoved(MouseEvent) then
		self.IsSelected = false
		--UIUtil.SetIsVisible(self.FImg_Select, false)
	end

	local Handled = WBL.Handled()
	return Handled
end

function FunctionCommonItemView:FillFunction(FunctionItem)
	self.RichTextFunctionName:SetText(FunctionItem.DisplayName)
	self.FunctionItem = FunctionItem
	self:SetItemColor(FunctionItem)
	if FunctionItem.FuncType == LuaFuncType.NPCQUIT_FUNC or FunctionItem.FuncType == LuaFuncType.QUIT_FUNC then
		UIUtil.ImageSetBrushFromAssetPath(self.FImg_Icon, "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Leave.UI_NPC_Icon_Leave'")
		--UIUtil.ImageSetBrushFromAssetPath(self.FImg_Normal, "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Img_Leave.UI_NPC_Img_Leave'")
	else
		UIUtil.ImageSetBrushFromAssetPath(self.FImg_Icon, FunctionItem:GetIconPath())
		--UIUtil.ImageSetBrushFromAssetPath(self.FImg_Normal, "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Img_Normal.UI_NPC_Img_Normal'")
	end

	if nil ~= self.UIEventRegister then
		self.UIEventRegister:UnRegisterAll()
	end
	-- UIUtil.AddOnClickedEvent(self, self.FBtn_Function, self.OnClicked)
end

function FunctionCommonItemView:SetItemColor(FunctionItem)
	local _, Options = _G.InteractiveMgr:GetLastCustomTalk()
	if Options and next(Options) then
		if Options[tostring(FunctionItem.DialogLibID)] then
			local Gray = _G.UE.FLinearColor.FromHex("#696969")
			self.RichTextFunctionName:SetColorAndOpacity(Gray)
			self.FImg_Icon:SetColorAndOpacity(Gray)
			return
		end
	end
	--这里处理一下复用UI的颜色
	local White = _G.UE.FLinearColor.FromHex("#FFFFFF")
	self.RichTextFunctionName:SetColorAndOpacity(White)
	self.FImg_Icon:SetColorAndOpacity(White)
end

-- function FunctionCommonItemView:OnClicked()
-- 	self.FunctionItem:Click()
-- end

return FunctionCommonItemView