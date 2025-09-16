local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



---@class CommScreenerClassItemVM : UIViewModel
local CommScreenerClassItemVM = LuaClass(UIViewModel)

local Outward_Type = {SingleText = 0, SingleIcon = 1, Multiple = 2, Number = 3}

---Ctor
function CommScreenerClassItemVM:Ctor()
    self.SelectedNodeVisible = false
	self.SelectedTagVisible = nil
	self.SingleText = nil
	self.SingleIcon = nil
	self.MultipleText = nil
	self.MultipleIcon = nil
	self.NumberText = nil

    self.SingleTextVisible = nil
    self.SingleIconVisible = nil
    self.MultipleItemVisible = nil
    self.NumberTextVisible = nil

    self.Value = nil
    self.OutwardType = nil
end

function CommScreenerClassItemVM:UpdateVM(Value, Param)
	self.Value = Value
    self.SelectedTagVisible = (Param and Param.ShowTag) or false
    local OutwardType = self:GetOutwardType(Value)
    if OutwardType == Outward_Type.SingleText then
        self.SingleTextVisible = true
        self.SingleIconVisible = false
        self.MultipleItemVisible = false
        self.NumberTextVisible = false
        self.SingleText = Value.ScreenerName
    elseif OutwardType == Outward_Type.SingleIcon then
        self.SingleIconVisible = true
        self.SingleTextVisible = false
        self.MultipleItemVisible = false
        self.NumberTextVisible = false
        self.SingleIcon = Value.ScreenerIcon
	elseif OutwardType == Outward_Type.Multiple then
        self.MultipleItemVisible = true
        self.SingleTextVisible = false
        self.SingleIconVisible = false
        self.NumberTextVisible = false
        self.MultipleText = Value.ScreenerName
        self.MultipleIcon = Value.ScreenerIcon
    elseif OutwardType == Outward_Type.Number then
        self.NumberTextVisible = true
        self.SingleTextVisible = false
        self.SingleIconVisible = false
        self.MultipleItemVisible = false
        self.NumberText = Value.ScreenerName
    end
end

function CommScreenerClassItemVM:GetOutwardType(Value)
    if string.isnilorempty(Value.ScreenerName) then
        return Outward_Type.SingleIcon
    else
        if string.isnilorempty(Value.ScreenerIcon) then
            local n = tonumber(Value.ScreenerName);
            if n then
                return Outward_Type.Number
            else
                return Outward_Type.SingleText
            end
        else
            return Outward_Type.Multiple
        end
    end
end

function CommScreenerClassItemVM:SetSelected()
    if self.SelectedNodeVisible == false then
        self.SelectedNodeVisible = true
    else
        self.SelectedNodeVisible = false
    end
    
end

function CommScreenerClassItemVM:SetItemSelected(IsSelected)
    self.SelectedNodeVisible = IsSelected
end

function CommScreenerClassItemVM:ResetSelected()
    self:SetItemSelected(false)
end

function CommScreenerClassItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.Value.ID
end
--要返回当前类
return CommScreenerClassItemVM