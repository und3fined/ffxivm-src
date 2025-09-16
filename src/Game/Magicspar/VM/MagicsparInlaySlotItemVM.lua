local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MagicsparInlaySlotItemVM : UIViewModel
local MagicsparInlaySlotItemVM = LuaClass(UIViewModel)

function MagicsparInlaySlotItemVM:Ctor()
    self.ResID = nil
    self.bInlay = false
    self.bNomal = true
    self.MagicsparIndex = 0
    self.bSelect = false
    self.DefaultIconPath = nil
end

function MagicsparInlaySlotItemVM:InitMagicsparSlot(InResID, Index, bNomal)
    self.bNomal = bNomal
    if self.bNomal == true then
		self.DefaultIconPath = "Texture2D'/Game/Assets/Icon/WP/InlaySolt/UI_Msg_Inlay_Slot_Empty.UI_Msg_Inlay_Slot_Empty'"
	else
		self.DefaultIconPath = "Texture2D'/Game/Assets/Icon/WP/InlaySolt/UI_Msg_BanInlay_Slot_Empty.UI_Msg_BanInlay_Slot_Empty'"
	end

    self.ResID = InResID
    self.bInlay = InResID ~= nil and InResID > 0
    self.MagicsparIndex = Index
end

return MagicsparInlaySlotItemVM