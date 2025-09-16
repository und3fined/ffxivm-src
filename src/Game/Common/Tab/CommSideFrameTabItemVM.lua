---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CommTabsDefine = require("Game/Common/Tab/CommTabsDefine")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
---@class CommSideFrameTabItemVM : UIViewModel
local CommSideFrameTabItemVM = LuaClass(UIViewModel)

---Ctor
function CommSideFrameTabItemVM:Ctor()
	self.NormalIcon = ""
	self.SelectedIcon = ""
	self.bEnable = false
	self.CurrentType = 0
	self.IconIMG = ""
	self.bSelect = false
	self.bRedDotsVisible = false
	self.UpdateRedDot = 0
	self.RedDotsStyle = RedDotDefine.RedDotStyle.TextStyle
	
end
function CommSideFrameTabItemVM:OnUpdateToSelect(NewValue,OldValue)
	if NewValue then
		self.IconIMG = self.SelectedIcon
	else
		self.IconIMG = self.NormalIcon
	end
end
function CommSideFrameTabItemVM:OnVMSelect()
	self.ParentVM:SetCurrentSelect(self.CurrentType)
end
function CommSideFrameTabItemVM:InitBindProperty()
	--self:SetNoCheckValueChange("bRedDotsVisible", true)
end
--要返回当前类
return CommSideFrameTabItemVM