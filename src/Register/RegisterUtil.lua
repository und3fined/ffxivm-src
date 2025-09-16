--
-- Author: anypkvcai
-- Date: 2024-06-08 15:37
-- Description:
--

local DefaultListenerName = "UnKnown"

---@class RegisterUtil
local RegisterUtil = {

}

function RegisterUtil.GetListenerName(Listener)
	if nil == Listener then
		return DefaultListenerName
	end

	local GetName = Listener.GetName
	if nil == GetName then
		return DefaultListenerName
	end

	local Name = GetName(Listener)
	if nil == Name or string.len(Name) <= 0 then
		return DefaultListenerName
	end

	return Name
end

return RegisterUtil