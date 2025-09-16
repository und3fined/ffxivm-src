---
--- Author: xingcaicao
--- DateTime: 2024-07-20 17:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")

---@class LinkShellScreenerActItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field PanelSelect UFCanvasPanel
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellScreenerActItemView = LuaClass(UIView, true)

function LinkShellScreenerActItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.PanelSelect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellScreenerActItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellScreenerActItemView:OnInit()

end

function LinkShellScreenerActItemView:OnDestroy()

end

function LinkShellScreenerActItemView:OnShow()

end

function LinkShellScreenerActItemView:OnHide()

end

function LinkShellScreenerActItemView:OnRegisterUIEvent()

end

function LinkShellScreenerActItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellScreenActUpdate, self.UpdateSelectedState)
end

function LinkShellScreenerActItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local Data = Params.Data
	self.ID = Data.ID

	-- 描述 
	self.TextName:SetText(Data.Name or "")

	-- 图标
	local IconPath = Data.Icon
	if not string.isnilorempty(IconPath) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	-- 是否选中
	self:UpdateSelectedState()
end

function LinkShellScreenerActItemView:UpdateSelectedState()
	local b = LinkShellVM:IsInScreenSelectedAct(self.ID)
	UIUtil.SetIsVisible(self.PanelSelect, b)
end

return LinkShellScreenerActItemView