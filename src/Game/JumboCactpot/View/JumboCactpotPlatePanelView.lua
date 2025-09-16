---
--- Author: Administrator
--- DateTime: 2023-09-18 09:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class JumboCactpotPlatePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field JumboCactpotPlateItem JumboCactpotPlateItemView
---@field JumboCactpotPlateItem_1 JumboCactpotPlateItemView
---@field JumboCactpotPlateItem_2 JumboCactpotPlateItemView
---@field JumboCactpotPlateItem_3 JumboCactpotPlateItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotPlatePanelView = LuaClass(UIView, true)

function JumboCactpotPlatePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.JumboCactpotPlateItem = nil
	--self.JumboCactpotPlateItem_1 = nil
	--self.JumboCactpotPlateItem_2 = nil
	--self.JumboCactpotPlateItem_3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotPlatePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.JumboCactpotPlateItem)
	self:AddSubView(self.JumboCactpotPlateItem_1)
	self:AddSubView(self.JumboCactpotPlateItem_2)
	self:AddSubView(self.JumboCactpotPlateItem_3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotPlatePanelView:OnInit()

end

function JumboCactpotPlatePanelView:OnDestroy()

end

function JumboCactpotPlatePanelView:OnShow()

end

function JumboCactpotPlatePanelView:OnHide()

end

function JumboCactpotPlatePanelView:OnRegisterUIEvent()

end

function JumboCactpotPlatePanelView:OnRegisterGameEvent()

end

function JumboCactpotPlatePanelView:OnRegisterBinder()

end

return JumboCactpotPlatePanelView