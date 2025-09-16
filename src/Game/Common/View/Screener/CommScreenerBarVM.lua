local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CommScreenerTagVM = require("Game/Common/View/Screener/CommScreenerTagVM")

---@class CommScreenerBarVM : UIViewModel
local CommScreenerBarVM = LuaClass(UIViewModel)

---Ctor
function CommScreenerBarVM:Ctor()
    self.ScreenerTagVMList = UIBindableList.New(CommScreenerTagVM)

end

function CommScreenerBarVM:UpdateByScreenerList(CommScreenerItemList)
	self.ScreenerTagVMList:UpdateByValues(CommScreenerItemList)
end


--要返回当前类
return CommScreenerBarVM