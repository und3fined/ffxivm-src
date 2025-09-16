---
--- Author: stellahxhu
--- DateTime: 2022-08-12 12:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = _G.UIViewMgr
local UIViewID = require("Define/UIViewID")

---@class CommPlayerBGJobSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Item UFButton
---@field FImg_Invite UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommPlayerBGJobSlotView = LuaClass(UIView, true)

function CommPlayerBGJobSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_Item = nil
	--self.FImg_Invite = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPlayerBGJobSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPlayerBGJobSlotView:OnInit()
	UIUtil.SetIsVisible(self.FImg_Invite, false)
	self.FBtn_Item:SetIsEnabled(false)
end

function CommPlayerBGJobSlotView:OnDestroy()

end

function CommPlayerBGJobSlotView:OnShow()
end

function CommPlayerBGJobSlotView:OnHide()

end

function CommPlayerBGJobSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Item, self.OnClickedButtonItem)
end

function CommPlayerBGJobSlotView:OnRegisterGameEvent()

end

function CommPlayerBGJobSlotView:OnRegisterBinder()

end

function CommPlayerBGJobSlotView:OnClickedButtonItem()
	UIViewMgr:ShowView(UIViewID.TeamInvite)
end

return CommPlayerBGJobSlotView