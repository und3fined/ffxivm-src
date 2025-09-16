local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")

local COMPANION_AUTO = ProtoCS.CompanionAuto
local LSTR = _G.LSTR

local CompanionCallingSettingItemVM = require("Game/Companion/VM/CompanionCallingSettingItemVM")

---@class CompanionCallingSettingVM : UIViewModel
local CompanionCallingSettingVM = LuaClass(UIViewModel)

local SettingItemTitleMap = {
    [COMPANION_AUTO.CompanionAutoLast] = LSTR(120017),
    [COMPANION_AUTO.CompanionAutoAll] = LSTR(120018),
    [COMPANION_AUTO.CompanionAutoLike] = LSTR(120019),
}

---Ctor
function CompanionCallingSettingVM:Ctor()
	self.SettingItemVM = self:GetSettingVMList()    -- 自动召唤选项列表
end

function CompanionCallingSettingVM:GetSettingVMList()
    local VMList = {}
    local IndexList = {
        COMPANION_AUTO.CompanionAutoLast,
        COMPANION_AUTO.CompanionAutoAll,
        COMPANION_AUTO.CompanionAutoLike,
    }

    for _, AutoType in ipairs(IndexList) do
        local ItemVM = self:GetItemVM(AutoType)
        table.insert(VMList, ItemVM)
    end

    return VMList
end

function CompanionCallingSettingVM:SelectCallingType(SelectedIndex)
	if self.SettingItemVM == nil then 
        self.SettingItemVM = self:GetSettingVMList()
    end

    for _, value in ipairs(self.SettingItemVM) do
        local IsSelect = value.Index == SelectedIndex
        value:SetSelect(IsSelect)
    end
end

function CompanionCallingSettingVM:GetItemVM(Index)
    local ItemVM = CompanionCallingSettingItemVM.New()
    ItemVM.Index = Index
    ItemVM.Title = SettingItemTitleMap[Index]
    ItemVM:SetSelect(false)
    
    return ItemVM
end

function CompanionCallingSettingVM:SetItemsClickable(Clickable)
	for _, value in ipairs(self.SettingItemVM) do
        value:SetClickable(Clickable)
    end
end

--要返回当前类
return CompanionCallingSettingVM