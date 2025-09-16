---
--- Author: eddardchen
--- DateTime: 2021-03-24 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GMMgr = require("Game/GM/GMMgr")

---@class GMFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonFilter UFButton
---@field ButtonText UFTextBlock
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMFilterItemView = LuaClass(UIView, true)

function GMFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonFilter = nil
	--self.ButtonText = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMFilterItemView:OnClickFilter()
	local EventID = require("Define/EventID")
	GMMgr.ChoseFist = self.Item.TopNameCN
	GMMgr.ChoseSecond = self.Item.SecondNameCN
	_G.EventMgr:SendEvent(EventID.GMSelectFilter, self.Item.TopNameCN, self.Item.SecondNameCN)
end

function GMFilterItemView:OnInit()

end

function GMFilterItemView:OnDestroy()

end

function GMFilterItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.Item = Params.Data
	if nil == self.Item then
		return
	end
	self.ButtonText:SetText(self.Item.Desc)
end

function GMFilterItemView:OnHide()

end

function GMFilterItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonFilter, self.OnClickFilter)
end

function GMFilterItemView:OnRegisterGameEvent()

end

function GMFilterItemView:OnRegisterTimer()

end

function GMFilterItemView:OnRegisterBinder()

end

function GMFilterItemView:OnSelectChanged(NewValue)
	if self.Item.Type == 1 then
		if self.Item.TopNameCN == GMMgr.ChoseFist then
			UIUtil.SetIsVisible(self.ImgSelect, true)
		else
			UIUtil.SetIsVisible(self.ImgSelect, false)
		end
	elseif self.Item.Type == 2 then
		if self.Item.SecondNameCN == GMMgr.ChoseSecond then
			UIUtil.SetIsVisible(self.ImgSelect, true)
		else
			UIUtil.SetIsVisible(self.ImgSelect, false)
		end
	end
end

return GMFilterItemView