---
--- Author: v_zanchang
--- DateTime: 2022-08-25 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
-- local EventID = _G.EventID

---@class Main2ndMenuItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field FImg_Icon UFImage
---@field FTextBlock_BtnName UFTextBlock
---@field MaskBox_50 UMaskBox
---@field MenuItem UFButton
---@field PanelLock UFCanvasPanel
---@field TextNews UFTextBlock
---@field AnimIn1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndMenuItemView = LuaClass(UIView, true)

function Main2ndMenuItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.FImg_Icon = nil
	--self.FTextBlock_BtnName = nil
	--self.MaskBox_50 = nil
	--self.MenuItem = nil
	--self.PanelLock = nil
	--self.TextNews = nil
	--self.AnimIn1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndMenuItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndMenuItemView:OnInit()
	self.ModuleID = nil
	self.RedDotID = nil
end

function Main2ndMenuItemView:OnDestroy()

end

function Main2ndMenuItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	if nil == Item then
		return
	end
	if nil == self.ModuleID then
		self.ModuleID = _G.ModuleOpenMgr:CheckOpenStateByName(Item.BtnEntranceID)
	end
	if nil == self.RedDotID and self.ModuleID ~= nil then
		self.RedDotID = _G.ModuleOpenMgr.RedDotList[self.ModuleID]
	end
	self:OnCheckLockState(self.ModuleID)
	UIUtil.ImageSetBrushFromAssetPath(self.FImg_Icon, Item.Icon)
	self.FTextBlock_BtnName:SetText(Item.BtnName)
	self.StartTime = TimeUtil.GetLocalTimeMS()
	self.MenuItem:SetRenderOpacity(0)
	self.DelayTime = Item.AnimInDelayTime
	self.BtnEntranceID = Item.BtnEntranceID
	if Item.RedDotID then
		self.CommonRedDot_UIBP:SetRedDotIDByID(Item.RedDotID)
	end
	if self.RedDotID and _G.ModuleOpenMgr:CheckRedDotIsNeedShow(self.ModuleID) then
		self.CommonRedDot_UIBP:SetRedDotIDByID(self.RedDotID)
	end
	self:PlayAnimation(self.AnimIn1)
end

-- 检查系统解锁状态
function Main2ndMenuItemView:OnCheckLockState(ModuleID)
	if self.RedDotID and _G.ModuleOpenMgr:CheckRedDotIsNeedShow(self.ModuleID) then
		self.CommonRedDot_UIBP:SetRedDotIDByID(self.RedDotID)
	end
	if ModuleID == self.ModuleID then
		local LockState = not _G.ModuleOpenMgr:CheckOpenState(self.ModuleID)	--- 锁的显示状态
		UIUtil.SetIsVisible(self.PanelLock, LockState)
	end
end

function Main2ndMenuItemView:OnHide()
	self.ModuleID = nil
end

function Main2ndMenuItemView:OnRegisterUIEvent()

end

function Main2ndMenuItemView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.Main2ndPanelMenuAnimNotify, self.PlayAnimDelayTime)
	self:RegisterGameEvent(_G.EventID.ModuleOpenNotify, self.OnCheckLockState)
end

function Main2ndMenuItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

end

function Main2ndMenuItemView:PlayAnimDelayTime()
	local CurrentTime = TimeUtil.GetLocalTimeMS()
	if (CurrentTime - self.StartTime) / 1000 >= self.DelayTime and not self.IsPlay then
		self:PlayAnimation(self.AnimIn1)
		self.IsPlay = true
	end

end

return Main2ndMenuItemView