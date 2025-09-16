local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@field MarketBuyVisible boolean  @购买是否显示
---@field MarketSellVisible boolean @出售是否显示
---@class MarketMainVM : UIViewModel
local MarketMainVM = LuaClass(UIViewModel)

---Ctor
function MarketMainVM:Ctor()
	self.MarketBuyVisible = false
	self.MarketSellVisible = false
	self.ImgBgLineVisible = nil
	self.SubTitleText = nil
	self.SubTitleTextVisible = nil
	self.JumpToBuyItemID = nil
end

function MarketMainVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
end

function MarketMainVM:OnBegin()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnBegin函数
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）
end

function MarketMainVM:OnEnd()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnEnd函数
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function MarketMainVM:OnShutdown()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnShutdown函数
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function MarketMainVM:SetPageTabIndex(Index)
	self.MarketBuyVisible = Index == 1
	self.MarketSellVisible = Index == 2

end


--要返回当前类
return MarketMainVM