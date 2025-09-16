---
--- Author: xingcaicao
--- DateTime: 2024-07-10 10:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local FriendVM = require("Game/Social/Friend/FriendVM")

---@class FriendScreenProfItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconProf UFImage
---@field PanelSelect UFCanvasPanel
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendScreenProfItemView = LuaClass(UIView, true)

function FriendScreenProfItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconProf = nil
	--self.PanelSelect = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendScreenProfItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendScreenProfItemView:OnInit()

end

function FriendScreenProfItemView:OnDestroy()

end

function FriendScreenProfItemView:OnShow()

end

function FriendScreenProfItemView:OnHide()
end

function FriendScreenProfItemView:OnRegisterUIEvent()

end

function FriendScreenProfItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FriendScreenProfUpdate, self.UpdateSelectedState)
end

function FriendScreenProfItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local Data = Params.Data
	local ProfID = Data.ProfID
	if nil == ProfID then
		return
	end

	self.ProfID = ProfID

	-- 职业图标
	local ProfIcon = Data.Icon
    if not string.isnilorempty(ProfIcon) then
		UIUtil.ImageSetBrushFromAssetPath(self.IconProf, ProfIcon)
    end

	-- 是否选中
	self:UpdateSelectedState()
end

function FriendScreenProfItemView:UpdateSelectedState()
	local ProfID = self.ProfID
	UIUtil.SetIsVisible(self.PanelSelect, ProfID and table.contain(FriendVM.ProfScreenList or{}, ProfID))
end

return FriendScreenProfItemView