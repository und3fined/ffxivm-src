---
--- Author: v_zanchang
--- DateTime: 2022-05-11 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")

---@class HomePageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CMDEdittext UFGMEditableText
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HomePageItemView = LuaClass(UIView, true)

function HomePageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CMDEdittext = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HomePageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HomePageItemView:OnInit()

end

function HomePageItemView:OnDestroy()

end

function HomePageItemView:OnShow()
	self.CMDEdittext:SetText(self.Params.CmdList)
	self.Desc:SetText(self.Params.Desc)
end

function HomePageItemView:OnHide()

end

function HomePageItemView:OnRegisterUIEvent()

end

function HomePageItemView:OnRegisterGameEvent()

end

function HomePageItemView:OnRegisterBinder()

end

return HomePageItemView