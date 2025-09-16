local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local BuddyMainPageItemVM = require("Game/Buddy/VM/BuddyMainPageItemVM")
local BuddyAbilityPageVM = require("Game/Buddy/VM/BuddyAbilityPageVM")
local BuddyStatusPageVM = require("Game/Buddy/VM/BuddyStatusPageVM")

---@class BuddyMainVM : UIViewModel
local BuddyMainVM = LuaClass(UIViewModel)

BuddyMainVM.MenuType = {Status = 1, Ability = 2}
---Ctor
function BuddyMainVM:Ctor()
	self.AbilityPageVisible = nil
	self.StatusPageVisible = nil
	self.CurrentPageVMList = UIBindableList.New(BuddyMainPageItemVM)
	self.AbilityPageVM = BuddyAbilityPageVM.New()
	self.StatusPageVM = BuddyStatusPageVM.New()
end

function BuddyMainVM:ShowStatusPage()
	self.AbilityPageVisible = false
	self.StatusPageVisible = true
	self:SetCurrentPageState(BuddyMainVM.MenuType.Status)
	self.StatusPageVM:UpdateVM()
end

function BuddyMainVM:ShowAbilityPage()
	self.AbilityPageVisible = true
	self.StatusPageVisible = false
	self:SetCurrentPageState(BuddyMainVM.MenuType.Ability)
	self.AbilityPageVM:UpdateVM()
end

function BuddyMainVM:SetCurrentPageState(Index)
	for i = 1, self.CurrentPageVMList:Length() do
		local ItemVM = self.CurrentPageVMList:Get(i)
		ItemVM:UpdateIconState(Index)	
	end
end

function BuddyMainVM:InitPageMenu()
	local ItemList = {}
	table.insert(ItemList, {Index = BuddyMainVM.MenuType.Status, OffIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_BuddyStatus_Normal.UI_Icon_SideTab_BuddyStatus_Normal'", OnIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_BuddyStatus_Select.UI_Icon_SideTab_BuddyStatus_Select'"})
	table.insert(ItemList, {Index = BuddyMainVM.MenuType.Ability, OffIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_BuddyAbility_Normal.UI_Icon_SideTab_BuddyAbility_Normal'", OnIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_BuddyAbility_Select.UI_Icon_SideTab_BuddyAbility_Select'"})

	self.CurrentPageVMList:UpdateByValues(ItemList)
end



--要返回当前类
return BuddyMainVM