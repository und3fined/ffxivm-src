---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local FriendVM = require("Game/Social/Friend/FriendVM")

---@class FriendScreenStyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field PanelSelect UFCanvasPanel
---@field TextDesc UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendScreenStyleItemView = LuaClass(UIView, true)

function FriendScreenStyleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.PanelSelect = nil
	--self.TextDesc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendScreenStyleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendScreenStyleItemView:OnInit()

end

function FriendScreenStyleItemView:OnDestroy()

end

function FriendScreenStyleItemView:OnShow()

end

function FriendScreenStyleItemView:OnHide()

end

function FriendScreenStyleItemView:OnRegisterUIEvent()

end

function FriendScreenStyleItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FriendScreenPlayStyleUpdate, self.UpdateSelectedState)
end

function FriendScreenStyleItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local Data = Params.Data
	self.ID = Data.ID

	-- 描述 
	self.TextDesc:SetText(Data.Desc or "")

	-- 图标
	local IconPath = Data.Icon
	if not string.isnilorempty(IconPath) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	-- 是否选中
	self:UpdateSelectedState()
end

function FriendScreenStyleItemView:UpdateSelectedState()
	local ID = self.ID
	UIUtil.SetIsVisible(self.PanelSelect, ID and table.contain(FriendVM.PlayStyleScreenList or{}, ID))
end

return FriendScreenStyleItemView