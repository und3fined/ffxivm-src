local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local AudioUtil = require("Utils/AudioUtil")
local NpcDialogVM = require("Game/Story/NpcDialogPlayVM")
local InteractiveMainPanelVM = require("Game/Interactive/MainPanel/InteractiveMainPanelVM")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local StoryDefine = require("Game/Story/StoryDefine")
local NpcDialogVM = require("Game/Story/NpcDialogPlayVM")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")
--local KIL = _G.UE.UKismetInputLibrary
--local WBL = _G.UE.UWidgetBlueprintLibrary

---@class NPCDialogueItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field RichText URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCDialogueItemView = LuaClass(UIView, true)

function NPCDialogueItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.RichText = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCDialogueItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCDialogueItemView:OnInit()
	self.EntranceItem = nil
	self.ParentVM = nil
end

function NPCDialogueItemView:OnDestroy()

end

function NPCDialogueItemView:OnShow()
	if nil == self.Params then return end
	local Data = self.Params.Data
	if nil == Data then return end

	local ESlateVisibility = _G.UE.ESlateVisibility
	if self.Object then
		self.Object:SetVisibility(ESlateVisibility.Visible)
	end

	self:FillEntrance(Data)
	self.ItemIndex = self.Params.Index
	self.FuncType = Data.FuncType
	self.ParentViewID = self.ParentView.ViewID
	self:GetParentVM()
	self:InitPanelHandle()
	--self:ClearSelected()
end

function NPCDialogueItemView:OnHide()

end

function NPCDialogueItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function NPCDialogueItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.EntranceItemChanged, self.OnEntranceItemChanged)
	self:RegisterGameEvent(EventID.InputActionTypeChange, self.InitPanelHandle)
	self:RegisterGameEvent(EventID.GamePadUpdateInteractive, self.UpdatePanelHandle)
	self:RegisterGameEvent(EventID.GamePadUpdateDialogue, self.UpdatePanelHandle)
	self:RegisterGameEvent(EventID.GamePadUpdateCombatType, self.UpdatePanelHandle)
	self:RegisterGameEvent(EventID.GamePadEnter, self.OnGamePadEnter)
    self:RegisterGameEvent(EventID.GamePadCancel, self.OnGamePadCancel)
end

function NPCDialogueItemView:OnRegisterBinder()

end

function NPCDialogueItemView:OnEntranceItemChanged(EntranceItem)
	if self.EntranceItem == EntranceItem then
		self:FillEntrance(EntranceItem)
	end
end

function NPCDialogueItemView:FillEntrance(EntranceItem)
	self.EntranceItem = EntranceItem
	self.RichText:SetText(EntranceItem.DisplayName)
	self:SetItemColor(EntranceItem)
	local IconPath = EntranceItem:GetIconPath()
	if string.isnilorempty(IconPath) then
		IconPath = "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Dialog.UI_NPC_Icon_Dialog'"
	end
	UIUtil.ImageSetBrushFromAssetPath(self.Icon, IconPath, true)
end

function NPCDialogueItemView:OnClickBtn()
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")
	if nil ~= self.EntranceItem then
		self.EntranceItem:Click()
	end
end

function NPCDialogueItemView:SetItemColor(Item)
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

--[[ function NPCDialogueItemView:OnTouchStarted(MyGeometry, MouseEvent)
	if not self.Params or not self.Params.Data then return end -- 确保entrance在列表里

	print("Entrance OnTouchStarted")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	self.LastViewportPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(FWORLD())
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true
	self.CheckTimerID = _G.TimerMgr:AddTimer(self, self.CheckMousePos, 0, 0.02, 0)
end

function NPCDialogueItemView:CheckMousePos()
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

function NPCDialogueItemView:ClearTimer()
	if self.CheckTimerID then
		_G.TimerMgr:CancelTimer(self.CheckTimerID)
		self.CheckTimerID = nil
	end
end

function NPCDialogueItemView:IsMouseMoved(MouseEvent)
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

function NPCDialogueItemView:OnTouchEnded(MyGeometry, MouseEvent)
	if not self.Params or not self.Params.Data then return end -- 确保entrance在列表里

	self:ClearSelected()
	self:ClearTimer()
	print("Entrance OnTouchEnded")
	if not self:IsMouseMoved(MouseEvent) then
		self.EntranceItem:Click()
	end
end

function NPCDialogueItemView:ClearSelected()
	self.IsSelected = false

	self:ClearTimer()
end

-- 下面的回调是为了应对entrance单独拎出来，不放在列表里的情况
function NPCDialogueItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
	if self.Params and self.Params.Data then return end
	if self.Params and self.Params.bNeedSecondJoyStick then return end

	print("Entrance OnMouseButtonDown")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true

	local Handled = WBL.Handled()
	return WBL.CaptureMouse(Handled, self)
end

function NPCDialogueItemView:OnMouseButtonUp(MyGeometry, MouseEvent)
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
function NPCDialogueItemView:SetHandleDirectionVisible(Value)
	if Value then
		self.HandleDirection:SetHandleDirectionType("UpAndDown")
	else
		self.HandleDirection:SetHandleDirectionType("Hide")
	end
end

function NPCDialogueItemView:SetHandleButtonText(Value)
	self.HandleState.TextNum:SetText(Value)
end

function NPCDialogueItemView:SetHandleFingerVisible(Value)
	UIUtil.SetIsVisible(self.ImgFinger, Value)
end

function NPCDialogueItemView:UpdatePanelHandle(IsUpdateButtonText)
	if self.FuncType == LuaFuncType.QUIT_FUNC or self.FuncType == LuaFuncType.NPCQUIT_FUNC then
		if IsUpdateButtonText then
			local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
			if HandleButtonText then
				self:SetHandleButtonText(HandleButtonText)
			end
		end
		if self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
			self:SetHandleFingerVisible(true)
			self:SetHandleDirectionVisible(true)
		else
			self:SetHandleFingerVisible(false)
			self:SetHandleDirectionVisible(false)
		end
	else
		if IsUpdateButtonText then
			local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
			if HandleButtonText then
				self:SetHandleButtonText(HandleButtonText)
			end
		end
		if self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
			UIUtil.SetIsVisible(self.PanelHandle, true)
			self:SetHandleFingerVisible(true)
			self:SetHandleDirectionVisible(true)
		else
			UIUtil.SetIsVisible(self.PanelHandle, false)
		end
	end
end

function NPCDialogueItemView:InitPanelHandle(IsHandleAttached)
	if nil == IsHandleAttached then
		IsHandleAttached = _G.SettingsHandleMgr:GetIsHandleAttached()
	end
	self.ItemList = self:GetItemList()
	if IsHandleAttached and #self.ItemList > 0 then
		local IsSingle = #self.ItemList > 1
		if IsSingle then
			self:SetHandleDirectionVisible(true)
		else
			self:SetHandleDirectionVisible(false)
		end
		if self.FuncType == LuaFuncType.QUIT_FUNC or self.FuncType == LuaFuncType.NPCQUIT_FUNC then
			local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
			if HandleButtonText then
				self:SetHandleButtonText(HandleButtonText)
			end
			UIUtil.SetIsVisible(self.PanelHandle, true)
			if self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
				self:SetHandleFingerVisible(true)
				self:SetHandleDirectionVisible(true)
			else
				self:SetHandleFingerVisible(false)
				self:SetHandleDirectionVisible(false)
			end
		else
			local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
			if HandleButtonText then
				self:SetHandleButtonText(HandleButtonText)
			end
			if self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
				UIUtil.SetIsVisible(self.PanelHandle, true)
			else
				UIUtil.SetIsVisible(self.PanelHandle, false)
			end
		end
	else
		UIUtil.SetIsVisible(self.PanelHandle, false)
	end
end

local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
function NPCDialogueItemView:OnGamePadEnter(Params)
	local Priority = Params.IntParam1
    if self:IsClickBtnValid(Priority) then
		self:OnClickBtn()
	end
end

function NPCDialogueItemView:IsClickBtnValid(Priority)
	if self.ParentViewID == UIViewID.InteractiveMainPanel
		and Priority == SettingsHandleDefine.HandleActionPriority.InteractiveCustom then
		if InteractiveMainPanelVM:GetFunctionVisible() and InteractiveMainPanelVM.ItemListNum > 0 
			and InteractiveMainPanelVM.CurHandleSelectItemIndex == self.ItemIndex then
			return true
		end
	elseif self.ParentViewID == UIViewID.NpcDialogueMainPanel
		and Priority == SettingsHandleDefine.HandleActionPriority.NpcDialogCustom then
		if self.ParentVM.bChoicePanelVisible and #self.ItemList > 0 and self.ParentVM.CurHandleSelectItemIndex == self.ItemIndex then
			return true
		end
	end
	return false
end

function NPCDialogueItemView:OnGamePadCancel(Params)
    if (self.FuncType == LuaFuncType.QUIT_FUNC or self.FuncType == LuaFuncType.NPCQUIT_FUNC) then
		self:OnClickBtn()
	end
end

function NPCDialogueItemView:GetParentVM()
	if self.ParentViewID == UIViewID.InteractiveMainPanel then
		self.ParentVM = InteractiveMainPanelVM
	else
		self.ParentVM = self.ParentView.View.ViewModel
	end
end

function NPCDialogueItemView:GetItemList()
	if self.ParentViewID == UIViewID.InteractiveMainPanel then
		return InteractiveMainPanelVM.FunctionItemList
	else
		if self.ParentView.View.ViewType == StoryDefine.UIType.SequenceDialog then
			return SequencePlayerVM.ChoiceUnitList
		end
		return NpcDialogVM.DialogBranchList
	end
end

return NPCDialogueItemView