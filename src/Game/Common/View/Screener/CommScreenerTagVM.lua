local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



---@class CommScreenerTagVM : UIViewModel
local CommScreenerTagVM = LuaClass(UIViewModel)

---Ctor
function CommScreenerTagVM:Ctor()
    self.ID = nil
	self.TagNameText = nil
end

function CommScreenerTagVM:UpdateVM(Value)
	self.ID = Value.ID
	self.TagNameText = Value.ScreenerName
end

function CommScreenerTagVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

--要返回当前类
return CommScreenerTagVM