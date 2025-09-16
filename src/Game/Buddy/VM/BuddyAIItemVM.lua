local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BuddyMgr = require("Game/Buddy/BuddyMgr")

---@class BuddyAIItemVM : UIViewModel
local BuddyAIItemVM = LuaClass(UIViewModel)

---Ctor
function BuddyAIItemVM:Ctor()
	self.UseImgVisible = nil
	self.MaskImgVisible = nil
	self.EFFVisible = nil
	self.IconImg = nil
	self.ID = nil
	self.Value = nil

	self.SelectImgVisible = nil
end

function BuddyAIItemVM:UpdateVM(Value)
	self.MaskImgVisible = false
	self.EFFVisible = false
	if  Value == nil then
		return
	end
	self.ID = Value.ID
	self.Value = Value
	self.IconImg = Value.Icon
	self:UpdateAIItemUse(BuddyMgr:GetBuddyUseAI())
end

function BuddyAIItemVM:UpdateIconState(ID)
	self.SelectImgVisible = ID  == self.ID 
end

function BuddyAIItemVM:UpdateAIItemUse(Strategy)
	self.UseImgVisible = Strategy == self.Value.Strategy
end


function BuddyAIItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end


--要返回当前类
return BuddyAIItemVM