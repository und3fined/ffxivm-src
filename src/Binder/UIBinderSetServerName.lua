---
--- Author: anypkvcai
--- DateTime: 2021-01-19 21:44
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local LoginMgr = require("Game/Login/LoginMgr")

---@class UIBinderSetServerName : UIBinder
local UIBinderSetServerName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetServerName:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetServerName:OnValueChanged(NewValue, OldValue)
	local WorldID = NewValue

	--- 区服数据（本地）
	--local Name = ServerDirCfg:FindValue(WorldID, "Name")
	--- 区服数据（服务器）
	local Name = LoginMgr:GetMapleNodeName(WorldID)

	self.Widget:SetText(Name)
end

return UIBinderSetServerName