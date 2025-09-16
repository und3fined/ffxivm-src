---
--- Author: Administrator
--- DateTime: 2024-09-13 11:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
local MenuType = Main2ndPanelDefine.MenuType

---@class Main2ndMenuItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field FImg_Icon UFImage
---@field FTextBlock_BtnName UFTextBlock
---@field ImgLockIcon UFImage
---@field MenuItem UFButton
---@field PanelLock UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndMenuItemNewView = LuaClass(UIView, true)

function Main2ndMenuItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.FImg_Icon = nil
	--self.FTextBlock_BtnName = nil
	--self.ImgLockIcon = nil
	--self.MenuItem = nil
	--self.PanelLock = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndMenuItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndMenuItemNewView:OnInit()
	self.ModuleID = nil
	self.RedDotID = nil
end

function Main2ndMenuItemNewView:OnDestroy()

end

function Main2ndMenuItemNewView:OnShow()
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
	--self.StartTime = TimeUtil.GetLocalTimeMS()
	self.MenuItem:SetRenderOpacity(0)
	--self.DelayTime = Item.AnimInDelayTime
	self.BtnEntranceID = Item.BtnEntranceID
	self:OnCheckMarketLockState()
	if self.RedDotID and _G.ModuleOpenMgr:CheckRedDotIsNeedShow(self.ModuleID) then
		---添加解锁子红点不需要修改配置的红点id,除非没有定义功能红点
		self.CommonRedDot_UIBP:SetRedDotIDByID(self.RedDotID)
	elseif Item.BtnRedDotID and Item.BtnRedDotID ~= 0 then
		self.CommonRedDot_UIBP:SetRedDotIDByID(Item.BtnRedDotID)
	end
	--self:PlayAnimation(self.AnimIn1)
end

-- 检查系统解锁状态
function Main2ndMenuItemNewView:OnCheckLockState(ModuleID)
	if ModuleID == self.ModuleID then
		local LockState = not _G.ModuleOpenMgr:CheckOpenState(self.ModuleID)	--- 锁的显示状态
		UIUtil.SetIsVisible(self.PanelLock, LockState)
		local UIRenderOpacity =  LockState and 0.5 or 1
		self.FImg_Icon:SetRenderOpacity(UIRenderOpacity)
		self.FTextBlock_BtnName:SetRenderOpacity(UIRenderOpacity)
	end
end

function Main2ndMenuItemNewView:OnCheckMarketLockState()
	if self.BtnEntranceID == MenuType.Transaction then
		local LockState = _G.MarketMgr:CanUnLockMarket() == false
		UIUtil.SetIsVisible(self.PanelLock, LockState)
		local UIRenderOpacity =  LockState and 0.5 or 1
		self.FImg_Icon:SetRenderOpacity(UIRenderOpacity)
		self.FTextBlock_BtnName:SetRenderOpacity(UIRenderOpacity)
	end
end

function Main2ndMenuItemNewView:OnHide()
	self.ModuleID = nil
	---红点清理
	self.RedDotID = nil
	self.CommonRedDot_UIBP:SetRedDotIDByID(self.RedDotID)
end

function Main2ndMenuItemNewView:OnRegisterUIEvent()

end

function Main2ndMenuItemNewView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ModuleOpenNotify, self.OnCheckLockState)
	self:RegisterGameEvent(_G.EventID.UpdateScore, self.OnCheckMarketLockState)
end

function Main2ndMenuItemNewView:OnRegisterBinder()

end

-- function Main2ndMenuItemNewView:PlayAnimDelayTime()
-- 	local CurrentTime = TimeUtil.GetLocalTimeMS()
-- 	if (CurrentTime - self.StartTime) / 1000 >= self.DelayTime and not self.IsPlay then
-- 		self:PlayAnimation(self.AnimIn1)
-- 		self.IsPlay = true
-- 	end
-- end

return Main2ndMenuItemNewView