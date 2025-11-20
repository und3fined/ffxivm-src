local LuaClass = require("Core/LuaClass")
local OpsMoggleCollectNodeVM = require("Game/Ops/VM/OpsMoggleCollect/OpsMoggleCollectNodeVM")

---@class OpsMoggleCollectNormalItemVM: OpsMoggleCollectNodeVM
local OpsMoggleCollectNormalItemVM = LuaClass(OpsMoggleCollectNodeVM)

function OpsMoggleCollectNormalItemVM:AdapterOnGetWidgetIndex()
	return 2
end

return OpsMoggleCollectNormalItemVM