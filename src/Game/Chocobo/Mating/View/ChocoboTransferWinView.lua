---
--- Author: Administrator
--- DateTime: 2024-01-15 20:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local MapContentType = MapDefine.MapContentType

---@class ChocoboTransferWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose1 UFButton
---@field ImgFrame UImage
---@field TextContent UFTextBlock
---@field mapContent AetherCurrentMapPanelView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransferWinView = LuaClass(UIView, true)

function ChocoboTransferWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose1 = nil
	--self.ImgFrame = nil
	--self.TextContent = nil
	--self.mapContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransferWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.mapContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransferWinView:OnInit()

end

function ChocoboTransferWinView:OnDestroy()

end

function ChocoboTransferWinView:OnShow()
	local Teleport = MapContentType.Teleport
	self.mapContent:SetContentType(Teleport)
	_G.MapMarkerMgr:CreateProviders(Teleport)

	local CrystalID = self.Params.CrystalID
	local cfg = TeleportCrystalCfg:FindCfgByKey(CrystalID)
	if cfg ~= nil then  
		self.mapContent:ShowMapContent(cfg.MapID)
		local X, Y = MapUtil.ConvertMapPos2UI(cfg.X, cfg.Y, 0, 0, 200, false)
		self.mapContent:SetPosition(X,Y)
	end
end

function ChocoboTransferWinView:OnHide()

end

function ChocoboTransferWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose1, self.OnClickBtnClose)
end

function ChocoboTransferWinView:OnRegisterGameEvent()

end

function ChocoboTransferWinView:OnRegisterBinder()

end

function ChocoboTransferWinView:OnClickBtnClose()
	self:Hide()
end

return ChocoboTransferWinView