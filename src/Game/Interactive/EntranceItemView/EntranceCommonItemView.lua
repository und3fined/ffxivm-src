

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local UTF8Util = require("Utils/UTF8Util")
local EventID = require("Define/EventID")
local AudioUtil = require("Utils/AudioUtil")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local KIL = _G.UE.UKismetInputLibrary
local WBL = _G.UE.UWidgetBlueprintLibrary

---@class EntranceCommonItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Loop_T_Inst_7 UFImage
---@field FBtn_EntranceBtn UFButton
---@field FImg_Icon UFImage
---@field FImg_Normal UFImage
---@field FImg_Pic UFImage
---@field FImg_Select UFImage
---@field FText_EntranceName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EntranceCommonItemView = LuaClass(UIView, true)

function EntranceCommonItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Loop_T_Inst_7 = nil
	--self.FBtn_EntranceBtn = nil
	--self.FImg_Icon = nil
	--self.FImg_Normal = nil
	--self.FImg_Pic = nil
	--self.FImg_Select = nil
	--self.FText_EntranceName = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EntranceCommonItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EntranceCommonItemView:OnInit()
	-- UIUtil.SetIsVisible(self.FImg_Normal, false)
	UIUtil.SetIsVisible(self.FImg_Select, false)
	UIUtil.SetIsVisible(self.FImg_Pic, false)
	UIUtil.SetIsVisible(self.EFF_Loop_T_Inst_7, false)

	self.EntranceItem = nil
end

function EntranceCommonItemView:OnDestroy()

end

function EntranceCommonItemView:OnShow()
	if nil == self.Params then return end
	local Data = self.Params.Data
	if nil == Data then return end

	local ESlateVisibility = _G.UE.ESlateVisibility
	if self.Object then
		self.Object:SetVisibility(ESlateVisibility.Visible)
	end
	--不能直接OnShow的收获 再设置self的，会死循环
	-- UIUtil.SetIsVisible(self, true, true)
	self:FillEntrance(Data)

	self:ClearSelected()
end

function EntranceCommonItemView:OnHide()

end

function EntranceCommonItemView:OnRegisterUIEvent()
	-- UIUtil.AddOnHoveredEvent(self, self.FBtn_EntranceBtn, self.OnHovered, Params)
	-- UIUtil.AddOnUnhoveredEvent(self, self.FBtn_EntranceBtn, self.OnUnhovered, Params)
	-- UIUtil.AddOnClickedEvent(self, self.FBtn_EntranceBtn, self.OnClicked)
end

function EntranceCommonItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.EntranceItemChanged, self.OnEntranceItemChanged)
end

function EntranceCommonItemView:OnRegisterTimer()

end

function EntranceCommonItemView:OnRegisterBinder()

end

-- function EntranceCommonItemView:OnHovered()
-- 	if self.FImg_Normal ~= nil then
-- 		UIUtil.SetIsVisible(self.FImg_Normal, false)
-- 	end
-- 	if self.FImg_Select ~= nil then
-- 		UIUtil.SetIsVisible(self.FImg_Select, true)
-- 	end
-- end

-- function EntranceCommonItemView:OnUnhovered()
-- 	if self.FImg_Normal ~= nil then
-- 		UIUtil.SetIsVisible(self.FImg_Normal, true)
-- 	end
-- 	if self.FImg_Select ~= nil then
-- 		UIUtil.SetIsVisible(self.FImg_Select, false)
-- 	end
-- end

function EntranceCommonItemView:OnEntranceItemChanged(EntranceItem)
	if self.EntranceItem == EntranceItem then
		self:FillEntrance(EntranceItem)
	end
end

function EntranceCommonItemView:FillEntrance(EntranceItem)
	self.EntranceItem = EntranceItem

	local Name = EntranceItem.DisplayName
	self.FText_EntranceName:SetText(Name)

	UIUtil.SetIsVisible(self.FImg_Normal, true)

	local IconPath = EntranceItem:GetIconPath()
	if IconPath ~= nil and IconPath ~= "" then
		UIUtil.ImageSetBrushFromAssetPath(self.FImg_Icon, IconPath, true)
	end

	-- local Margin = _G.UE.FMargin()
	-- Margin.Bottom = -15
	-- Margin.Top = -15
	-- self:SetPadding(Margin)
end

-- function EntranceCommonItemView:OnClicked()
-- 	print("Entrance OnClicked")
-- 	self.EntranceItem:Click()
-- end

function EntranceCommonItemView:OnTouchStarted(MyGeometry, MouseEvent)
	if not self.Params or not self.Params.Data then return end -- 确保entrance在列表里

	print("Entrance OnTouchStarted")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	self.LastViewportPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(FWORLD())
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true
	--UIUtil.SetIsVisible(self.FImg_Select, true)
	self.CheckTimerID = _G.TimerMgr:AddTimer(self, self.CheckMousePos, 0, 0.02, 0)
end

function EntranceCommonItemView:CheckMousePos()
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

function EntranceCommonItemView:ClearTimer()
	if self.CheckTimerID then
		_G.TimerMgr:CancelTimer(self.CheckTimerID)
		self.CheckTimerID = nil
	end
end

function EntranceCommonItemView:IsMouseMoved(MouseEvent)
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

function EntranceCommonItemView:OnTouchEnded(MyGeometry, MouseEvent)
	if not self.Params or not self.Params.Data then return end -- 确保entrance在列表里

	self:ClearSelected()
	self:ClearTimer()
	print("Entrance OnTouchEnded")
	if not self:IsMouseMoved(MouseEvent) then
		self.EntranceItem:Click()
	end
end

function EntranceCommonItemView:ClearSelected()
	self.IsSelected = false
	--UIUtil.SetIsVisible(self.FImg_Select, false)

	self:ClearTimer()
end

-- 下面的回调是为了应对entrance单独拎出来，不放在列表里的情况

function EntranceCommonItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
	if self.Params and self.Params.Data then return end
	if self.Params and self.Params.bNeedSecondJoyStick then return end

	print("Entrance OnMouseButtonDown")
	self.LastMousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_normal.Play_UI_click_normal")

	self.IsSelected = true
	--UIUtil.SetIsVisible(self.FImg_Select, true)

	local Handled = WBL.Handled()
	return WBL.CaptureMouse(Handled, self)
end

function EntranceCommonItemView:OnMouseButtonUp(MyGeometry, MouseEvent)
	if self.Params and self.Params.Data then return end
	if self.Params and self.Params.bNeedSecondJoyStick then return end

	print("Entrance OnMouseButtonUp")
	if not self:IsMouseMoved(MouseEvent) then
		self.EntranceItem:Click()
	end
	self:ClearSelected()

	local Handled = WBL.Handled()
	return WBL.ReleaseMouseCapture(Handled)
end

return EntranceCommonItemView