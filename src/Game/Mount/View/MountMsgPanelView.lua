---
--- Author: jamiyang
--- DateTime: 2023-03-16 14:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")

---@class MountMsgPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInput CommSearchBarView
---@field CloseBtn CommonCloseBtnView
---@field TableViewMsgList UTableView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountMsgPanelView = LuaClass(UIView, true)

function MountMsgPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInput = nil
	--self.CloseBtn = nil
	--self.TableViewMsgList = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountMsgPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInput)
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountMsgPanelView:OnInit()

end

function MountMsgPanelView:OnDestroy()

end

function MountMsgPanelView:OnShow()

end

function MountMsgPanelView:OnHide()

end

function MountMsgPanelView:OnRegisterUIEvent()

end

function MountMsgPanelView:OnRegisterGameEvent()

end

function MountMsgPanelView:OnRegisterBinder()

end

return MountMsgPanelView