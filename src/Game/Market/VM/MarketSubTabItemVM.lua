local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



---@class MarketSubTabItemVM : UIViewModel
local MarketSubTabItemVM = LuaClass(UIViewModel)

---Ctor
function MarketSubTabItemVM:Ctor()
    self.SubTabName = nil
	self.SelectedVisible = nil
	self.SubTabData = nil
	self.NameColor = "#d5d5d5"
end

function MarketSubTabItemVM:UpdateVM(Value)
	self.SubTabData = Value
	self.SubTabName = Value.SubTypeName
end

function MarketSubTabItemVM:UpdateSelectedState(ShowID)
	self.SelectedVisible = ShowID  == self.SubTabData.ShowID
	self.NameColor = ShowID  == self.SubTabData.ShowID and "#594123" or "#d5d5d5"
end

function MarketSubTabItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.SubTabData.ID
end

--要返回当前类
return MarketSubTabItemVM