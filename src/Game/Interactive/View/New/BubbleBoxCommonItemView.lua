---
--- Author: saintzhao
--- DateTime: 2024-04-10 14:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local AudioUtil = require("Utils/AudioUtil")
local InteractiveMainPanelVM = require("Game/Interactive/MainPanel/InteractiveMainPanelVM")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
--local KIL = _G.UE.UKismetInputLibrary
--local WBL = _G.UE.UWidgetBlueprintLibrary

---@class BubbleBoxCommonItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field RichText URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BubbleBoxCommonItemView = LuaClass(UIView, true)

function BubbleBoxCommonItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.RichText = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BubbleBoxCommonItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BubbleBoxCommonItemView:OnInit()
	self.EntranceItem = nil
	self.ItemIndex = 1
end

function BubbleBoxCommonItemView:OnDestroy()

end

function BubbleBoxCommonItemView:OnShow()
	if nil == self.Params then return end
	local Data = self.Params.Data
	if nil == Data then return end

	local ESlateVisibility = _G.UE.ESlateVisibility
	if self.Object then
		self.Object:SetVisibility(ESlateVisibility.Visible)
	end

	self:FillEntrance(Data)
	self.ItemIndex = self.Params.Index
	self.ParentViewID = self.ParentView.ViewID
	self:GetParentVM()
	self:InitPanelHandle()
	--self:ClearSelected()
end

function BubbleBoxCommonItemView:OnHide()

end

function BubbleBoxCommonItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function BubbleBoxCommonItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.EntranceItemChanged, self.OnEntranceItemChanged)
	self:RegisterGameEvent(EventID.InputActionTypeChange, self.InitPanelHandle)
	self:RegisterGameEvent(EventID.GamePadUpdateInteractive, self.UpdatePanelHandle)
	self:RegisterGameEvent(EventID.GamePadUpdateDialogue, self.UpdatePanelHandle)
	self:RegisterGameEvent(EventID.GamePadUpdateCombatType, self.UpdatePanelHandle)
	self:RegisterGameEvent(EventID.GamePadEnter, self.OnGamePadEnter)
    self:RegisterGameEvent(EventID.GamePadCancel, self.OnGamePadCancel)
end

function BubbleBoxCommonItemView:OnRegisterBinder()

end

function BubbleBoxCommonItemView:OnEntranceItemChanged(EntranceItem)
	if self.EntranceItem == EntranceItem then
		self:FillEntrance(EntranceItem)
	end
end

function BubbleBoxCommonItemView:FillEntrance(EntranceItem)
	self.EntranceItem = EntranceItem
	self.RichText:SetText(EntranceItem.DisplayName)
	self:SetItemColor(EntranceItem)
	local IconPath = EntranceItem:GetIconPath()
	if string.isnilorempty(IconPath) then
		IconPath = "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Dialog.UI_NPC_Icon_Dialog'"
	end
	UIUtil.ImageSetBrushFromAssetPath(self.Icon, IconPath, true)
end

function BubbleBoxCommonItemView:OnClickBtn()
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")
	if nil ~= self.EntranceItem then
		self.EntranceItem:Click()
	end
end

function BubbleBoxCommonItemView:SetItemColor(Item)
	if nil ~= Item.DialogLibID then
		local _, Options = _G.InteractiveMgr:GetLastCustomTalk()
		if Options and next(Options) then
			if Options[tostring(Item.DialogLibID)] then
				local Gray = _G.UE.FLinearColor.FromHex("#696969")
				self.RichText:SetColorAndOpacity(Gray)
				self.Icon:SetColorAndOpacity(Gray)
				return
			end
		end
	end
	--这里处理一下复用UI的颜色
	local White = _G.UE.FLinearColor.FromHex("#FFFFFF")
	self.RichText:SetColorAndOpacity(White)
	self.Icon:SetColorAndOpacity(White)
end

--[[ function BubbleBoxCommonItemView:OnTouchStarted(MyGeometry, MouseEvent)
	if not self.Params or not self.Params.Data then return end -- 确保entrance在列表里

	print("Entrance OnTouchStarted")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	self.LastViewportPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(FWORLD())
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true
	self.CheckTimerID = _G.TimerMgr:AddTimer(self, self.CheckMousePos, 0, 0.02, 0)
end

function BubbleBoxCommonItemView:CheckMousePos()
	local CurMousePos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())
	if not self.LastViewportPos then
		self:ClearSelected()
	else
		local DeltaPos = CurMousePos - self.LastViewportPos
		if math.abs(DeltaPos.X) > 2 or
			math.abs(DeltaPos.Y) > 2 then
				self:ClearSelected()
		end
	end
end

function BubbleBoxCommonItemView:ClearTimer()
	if self.CheckTimerID then
		_G.TimerMgr:CancelTimer(self.CheckTimerID)
		self.CheckTimerID = nil
	end
end

function BubbleBoxCommonItemView:IsMouseMoved(MouseEvent)
	if not self.LastMousePos then
		return false
	end

	local MousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if math.abs(MousePos.X - self.LastMousePos.X) > 2 or
		math.abs(MousePos.Y - self.LastMousePos.Y) > 2 then
		return true
	end

	return false
end

function BubbleBoxCommonItemView:OnTouchEnded(MyGeometry, MouseEvent)
	if not self.Params or not self.Params.Data then return end -- 确保entrance在列表里

	self:ClearSelected()
	self:ClearTimer()
	print("Entrance OnTouchEnded")
	if not self:IsMouseMoved(MouseEvent) then
		self.EntranceItem:Click()
	end
end

function BubbleBoxCommonItemView:ClearSelected()
	self.IsSelected = false

	self:ClearTimer()
end

-- 下面的回调是为了应对entrance单独拎出来，不放在列表里的情况
function BubbleBoxCommonItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
	if self.Params and self.Params.Data then return end
	if self.Params and self.Params.bNeedSecondJoyStick then return end

	print("Entrance OnMouseButtonDown")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true

	local Handled = WBL.Handled()
	return WBL.CaptureMouse(Handled, self)
end

function BubbleBoxCommonItemView:OnMouseButtonUp(MyGeometry, MouseEvent)
	if self.Params and self.Params.Data then return end
	if self.Params and self.Params.bNeedSecondJoyStick then return end

	print("Entrance OnMouseButtonUp")
	if not self:IsMouseMoved(MouseEvent) then
		self.EntranceItem:Click()
	end
	self:ClearSelected()

	local Handled = WBL.Handled()
	return WBL.ReleaseMouseCapture(Handled)
end ]]

---手柄交互相关---
function BubbleBoxCommonItemView:SetHandleDirectionVisible(Value)
	if Value then
		self.HandleDirection:SetHandleDirectionType("UpAndDown")
	else
		self.HandleDirection:SetHandleDirectionType("Hide")
	end
end

function BubbleBoxCommonItemView:SetHandleButtonText(Value)
	self.HandleState.TextNum:SetText(Value)
end

function BubbleBoxCommonItemView:UpdatePanelHandle(IsUpdateButtonText)
	if IsUpdateButtonText then
		local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
		if HandleButtonText then
			self:SetHandleButtonText(HandleButtonText)
		end
	end
	if self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
		UIUtil.SetIsVisible(self.PanelHandle, true)
	else
		UIUtil.SetIsVisible(self.PanelHandle, false)
	end
end

function BubbleBoxCommonItemView:InitPanelHandle(IsHandleAttached)
	if nil == IsHandleAttached then
		IsHandleAttached = _G.SettingsHandleMgr:GetIsHandleAttached()
	end
	local ItemList = self:GetItemList()
	if IsHandleAttached and #ItemList > 0 then
		local IsSingle = #ItemList > 1
		if IsSingle then
			self:SetHandleDirectionVisible(true)
		else
			self:SetHandleDirectionVisible(false)
		end
		local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
		if HandleButtonText then
			self:SetHandleButtonText(HandleButtonText)
		end
		if self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
			UIUtil.SetIsVisible(self.PanelHandle, true)
		else
			UIUtil.SetIsVisible(self.PanelHandle, false)
		end
	else
		UIUtil.SetIsVisible(self.PanelHandle, false)
	end
end

function BubbleBoxCommonItemView:OnGamePadEnter(Params)
	local Priority = Params.IntParam1
    if self:IsClickBtnValid(Priority) then
		self:OnClickBtn()
	end
end

function BubbleBoxCommonItemView:IsClickBtnValid(Priority)
	if self.ParentViewID == UIViewID.InteractiveMainPanel
		and Priority == SettingsHandleDefine.HandleActionPriority.InteractiveCustom then
		if InteractiveMainPanelVM:GetEntrancesVisible() and InteractiveMainPanelVM.ItemListNum > 0 
			and InteractiveMainPanelVM.CurHandleSelectItemIndex == self.ItemIndex then
			return true
		end
	elseif self.ParentViewID == UIViewID.DialogueMainPanel
		and Priority == SettingsHandleDefine.HandleActionPriority.NpcDialogCustom then
		if SequencePlayerVM.bChoicePanelVisible and #SequencePlayerVM.ChoiceUnitList > 0 and SequencePlayerVM.CurHandleSelectItemIndex == self.ItemIndex then
			return true
		end
	end
	return false
end

function BubbleBoxCommonItemView:OnGamePadCancel(Params)
    
end

function BubbleBoxCommonItemView:GetParentVM()
	if self.ParentViewID == UIViewID.InteractiveMainPanel then
		self.ParentVM = InteractiveMainPanelVM
	else
		self.ParentVM = self.ParentView.View.ViewModel
	end
end

function BubbleBoxCommonItemView:GetItemList()
	if self.ParentViewID == UIViewID.InteractiveMainPanel then
		return InteractiveMainPanelVM.EntranceItemList
	else
		return SequencePlayerVM.ChoiceUnitList
	end
end

return BubbleBoxCommonItemView