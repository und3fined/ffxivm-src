






local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetIsVisibleByBit : UIBinderSetIsVisible
local UIBinderSetIsVisibleByBit = LuaClass(UIBinder)

---Ctor
---@param Data table    外部传入一个用于共享的table，用于记录最大位数及Mask值，参考MainControlPanelView
function UIBinderSetIsVisibleByBit:Ctor(View, Widget, Data, IsInverted, IsHitTestVisible, IsHidden)
    self.IsInverted = IsInverted
	self.IsHitTestVisible = IsHitTestVisible
	self.IsHidden = IsHidden
    self.Data = Data
    self.BitIndex = (Data.MaxIndex or 0) + 1
    Data.MaxIndex = self.BitIndex
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetIsVisibleByBit:OnValueChanged(NewValue, OldValue)
    if nil == self.Widget or nil == self.View then
		return
	end

	if type(NewValue) == "number" then
		NewValue = NewValue ~= 0
	end

	local IsVisible = NewValue
	if self.IsInverted then
		IsVisible = not IsVisible
	end

    local Data = self.Data
    local BitIndex = self.BitIndex
    local Mask = Data.Mask
    local NewMask = Mask or 2 ^ BitIndex - 1
    if IsVisible then
        NewMask = NewMask | (1 << (BitIndex - 1))
    else
        NewMask = NewMask & ~(1 << (BitIndex - 1))
    end

    if not Data.IsForceUpdate and NewMask == Mask then
       return
    end
    local MaxBitIndex = Data.MaxIndex
    Data.Mask = NewMask
    local bVisible = NewMask == (2 ^ MaxBitIndex - 1)
    if not Data.IsForceUpdate and Data.bVisible == bVisible then
        return
    end
    Data.bVisible = bVisible

    UIUtil.SetIsVisible(self.Widget, bVisible, self.IsHitTestVisible, self.IsHidden)
end

return UIBinderSetIsVisibleByBit