---
--- Author: xingcaicao
--- DateTime: 2023-10-07 16:42
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ChatGifCfg = require("TableCfg/ChatGifCfg")

---@class ChatGifItemVM : UIViewModel
local ChatGifItemVM = LuaClass(UIViewModel)

---Ctor
function ChatGifItemVM:Ctor()
	self.ID = nil
	self.Icon = nil
end

function ChatGifItemVM:IsEqualVM(Value)
	if nil == Value then
		return false
	end

	local ID = self.ID
	return ID and ID == Value.ID
end

function ChatGifItemVM:UpdateVM(Value)
	local ID = Value.ID
	self.ID = Value.ID 
	self.Icon = ChatGifCfg:GetIcon(ID)
end

return ChatGifItemVM