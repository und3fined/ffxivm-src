local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local MiniCactpotMainVM = require("Game/MiniCactpot/MiniCactpotMainVM")

---@class MiniCactpotKeyItemVM : UIViewModel
local MiniCactpotKeyItemVM = LuaClass(UIViewModel)

---Ctor
function MiniCactpotKeyItemVM:Ctor()
    self.NumberIconPath = ""
    self.SetCellState = 1--MiniCactpotMainVM.CellState.Masked
    self.CellIsChecked = false

    --
    self.Index = 0
    self.Number = 0

    -- 不检查是否有变化，必然OnValueChange
    local BindProperty = self:FindBindableProperty("SetCellState")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end
end

return MiniCactpotKeyItemVM
