---
--- Author: lipengzha
--- DateTime: 2021-08-16 10:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local USelectEffectMgr = nil
local Handled <const> = _G.UE.UWidgetBlueprintLibrary.Handled()
local Unhandled <const> = _G.UE.UWidgetBlueprintLibrary.Unhandled()

---@class UMGWWiseEventViewerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseButton UFButton
---@field MainPanel UCanvasPanel
---@field Scroll_Items UScrollBox
---@field Items int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local UMGWWiseEventViewerView = LuaClass(UIView, true)

function UMGWWiseEventViewerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseButton = nil
	--self.MainPanel = nil
	--self.Scroll_Items = nil
	--self.Items = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function UMGWWiseEventViewerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function UMGWWiseEventViewerView:OnInit()

end

function UMGWWiseEventViewerView:OnDestroy()

end

function UMGWWiseEventViewerView:AddNewEventItemListener(EventInfo)
    if self.bShowActorEventOnly then
        local AttachedActor = EventInfo.AttachedActor:Get()
        if AttachedActor == nil or USelectEffectMgr:GetCurrSelectedTarget() ~= AttachedActor then
            return
        end
    end

     local UMG_WWiseEventItem_C = _G.UE.UClass.Load("/Game/UI/BP/GM/Audio/UMG_WWiseEventItem.UMG_WWiseEventItem_C")
     local UMG_WWiseEventItem_Ins = _G.UE.UWidgetBlueprintLibrary.Create(self,UMG_WWiseEventItem_C)
     UMG_WWiseEventItem_Ins:SetEventInfo(EventInfo.EventName, EventInfo.PlayingID)
     self.Items:Add(EventInfo.PlayingID, UMG_WWiseEventItem_Ins)
     self.Scroll_Items:AddChild(UMG_WWiseEventItem_Ins)
    --self:AddNewEventItem(EventInfo.EventName,EventInfo.PlayingID)
    ----self.Overridden.AddNewEventItemListener(self,NAME,id)
end

function UMGWWiseEventViewerView:RemoveEventItemListener(EventInfo)
    local UMG_WWiseEventItem_Ins = self.Items:Find(EventInfo.PlayingID)
    if UMG_WWiseEventItem_Ins then
        UMG_WWiseEventItem_Ins:Remove()
        self.Items:Remove(EventInfo.PlayingID)
    end
    --self:RemovePlayingEventItem(EventInfo.EventName,EventInfo.PlayingID)

end

local ViewerOpenedCnt = 0

local function OnViewerOpenedCntChanged()
    local UAudioMgr = _G.UE.UAudioMgr.Get()
    if ViewerOpenedCnt > 0 then
        UAudioMgr:SetDrawDebugPos(true)
    elseif ViewerOpenedCnt == 0 then
        UAudioMgr:SetDrawDebugPos(false)
    end
end

function UMGWWiseEventViewerView:OnShow()
    local UAudioMgr = _G.UE.UAudioMgr.Get()
    if USelectEffectMgr == nil then
        USelectEffectMgr = _G.UE.USelectEffectMgr.Get()
    end

    local Title = self.Title
    if Title then
        Title:SetText(self.TitleText or "")
    end

    local Items = UAudioMgr:GetPlayingEventItems()
    local keys = Items:Keys()
    for i = 1, keys:Length() do
        local key = keys:Get(i)
        local value = Items:Find(key)
        self:AddNewEventItemListener(value)
    end

    UAudioMgr:AddOnAudioPlayed({ self, UMGWWiseEventViewerView.AddNewEventItemListener })
    UAudioMgr:AddOnAudioRemoved({ self, UMGWWiseEventViewerView.RemoveEventItemListener })
    UIUtil.AddOnClickedEvent(self, self.CloseButton, self.OnClickCloseButton)

    ViewerOpenedCnt = ViewerOpenedCnt + 1
    OnViewerOpenedCntChanged()
end

function UMGWWiseEventViewerView:OnHide()
    local UAudioMgr = _G.UE.UAudioMgr.Get()
    UAudioMgr:RemoveOnAudioPlayed({ self, UMGWWiseEventViewerView.AddNewEventItemListener })
    UAudioMgr:RemoveOnAudioRemoved({ self, UMGWWiseEventViewerView.RemoveEventItemListener })
    self:UnRegisterAllUIEvent()
    print("........on hide wwise event viewer")
    self.Scroll_Items:ClearChildren()
    self.Items:Clear()

    ViewerOpenedCnt = ViewerOpenedCnt - 1
    OnViewerOpenedCntChanged()
end

function UMGWWiseEventViewerView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.CloseButton, self.OnClickCloseButton)
end

function UMGWWiseEventViewerView:OnRegisterGameEvent()

end

function UMGWWiseEventViewerView:OnRegisterTimer()

end

function UMGWWiseEventViewerView:OnRegisterBinder()

end

function UMGWWiseEventViewerView:OnClickCloseButton()
    self:OnHide()
    UIUtil.SetIsVisible(self, false)
end

local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local USlateBlueprintLibrary = _G.UE.USlateBlueprintLibrary

function UMGWWiseEventViewerView:OnMouseButtonDown(InGeo, InMouseEvent)
	local DragStartMousePos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
	DragStartMousePos = USlateBlueprintLibrary.AbsoluteToLocal(InGeo, DragStartMousePos)
	self:EnterDragState(DragStartMousePos)
    return Handled
end

function UMGWWiseEventViewerView:OnMouseMove(InGeo, InMouseEvent)
	if not self.bIsDrag then
		return Unhandled
	end

	local DragStartMousePos = self.DragStartMousePos
    local AbsMousePos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    local LocalMousePos = USlateBlueprintLibrary.AbsoluteToLocal(InGeo, AbsMousePos)
	UIUtil.CanvasSlotSetPosition(self.MainPanel, self.DragStartCanvasPos + LocalMousePos - DragStartMousePos)
    return Handled
end

function UMGWWiseEventViewerView:OnMouseButtonUp(InGeo, InMouseEvent)
	self:ClearDragState()
    return Handled
end

function UMGWWiseEventViewerView:OnMouseLeave(MouseEvent)
	self:ClearDragState()
end

function UMGWWiseEventViewerView:OnMouseCaptureLost()
	self:ClearDragState()
end

function UMGWWiseEventViewerView:EnterDragState(DragStartMousePos)
	UIUtil.SetInputMode_UIOnly()
	self.bIsDrag = true
	self.DragStartMousePos = DragStartMousePos
	self.DragStartCanvasPos = UIUtil.CanvasSlotGetPosition(self.MainPanel)
end

function UMGWWiseEventViewerView:ClearDragState()
    UIUtil.SetInputMode_GameAndUI()
	self.bIsDrag = false
	self.DragStartMousePos = nil
	self.DragStartCanvasPos = nil
end

return UMGWWiseEventViewerView