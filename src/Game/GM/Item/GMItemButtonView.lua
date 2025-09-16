---
--- Author: v_zanchang
--- DateTime: 2022-05-07 14:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GMItemButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ClickItem UFButton
---@field ShowText UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMItemButtonView = LuaClass(UIView, true)

function GMItemButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ClickItem = nil
	--self.ShowText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMItemButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMItemButtonView:OnInit()

end

function GMItemButtonView:OnDestroy()

end

function GMItemButtonView:OnShow()
	if self.Params == nil then
		return
	end
	self.ShowText:SetText(self.Params.CmdList)
end

function GMItemButtonView:OnHide()
	--_G.EventMgr:SendEvent(_G.EventID.ItemSelected, self.ShowText:GetText(), true)
end

function GMItemButtonView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ClickItem, self.ClickItemHandle)
	UIUtil.AddOnHoveredEvent(self, self.ClickItem, self.HoveredItemHandle)
	UIUtil.AddOnUnhoveredEvent(self, self.ClickItem, self.UnHoveredItemHandle)
end

function GMItemButtonView:ClickItemHandle()
	_G.EventMgr:SendEvent(_G.EventID.ItemSelected, self.ShowText:GetText(), true)
end

function GMItemButtonView:HoveredItemHandle()
	_G.EventMgr:SendEvent(_G.EventID.ItemIsHoverd, true, true)
end

function GMItemButtonView:UnHoveredItemHandle()
	_G.EventMgr:SendEvent(_G.EventID.ItemIsHoverd, false, true)
end

function GMItemButtonView:OnRegisterGameEvent()

end

function GMItemButtonView:OnRegisterBinder()

end

return GMItemButtonView