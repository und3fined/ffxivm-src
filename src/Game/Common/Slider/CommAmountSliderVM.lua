local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommAmountSliderVM : UIViewModel
local CommAmountSliderVM = LuaClass(UIViewModel)

---Ctor
function CommAmountSliderVM:Ctor()
    self:SetSliderValueMaxMin(1,0)
end

function CommAmountSliderVM:SetSliderValueMaxMin(MaxValue, MinValue)
    self.MaxValue = MaxValue
    self.MinValue = MinValue
    if MaxValue <= 0 then
        self.MinValue = self.MaxValue
        self.Value = self.MinValue
        self.Percent = 0
        self.SilderEnabled = false
    elseif MaxValue == MinValue then
        self.MinValue = self.MaxValue
        self.Value = self.MinValue
        self.Percent = 1
        --self.SilderEnabled = false
	else
        self.Value = self.MinValue
        self.Percent = (self.Value - self.MinValue) / (self.MaxValue - self.MinValue)
        self.SilderEnabled = true
    end

    self:SetAddSubEnabled()
end


--处理滑块旁边加减号点击事件
function CommAmountSliderVM:SetSliderValue(Vaule)
    if self.SilderEnabled == false then
        return
    end
    
    self.Value = Vaule
    
    if self.CanChangedCallback ~= nil then
        self.Value =  self.CanChangedCallback(Vaule)
    end

    if self.MinValue == self.MaxValue then
        self.Percent = 1
    else
        self.Percent = (self.Value - self.MinValue) / (self.MaxValue - self.MinValue)
    end

    self:SetAddSubEnabled()

    if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(self.Value)
	end
end

--处理滑块滑动事件
function CommAmountSliderVM:SetSliderPercent(Percent)
    self.Percent = Percent
    self.Value = math.floor(Percent * (self.MaxValue - self.MinValue)) + self.MinValue
    
    self:SetAddSubEnabled()
    
    if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(self.Value)
	end
end

function CommAmountSliderVM:AddSliderValue(Value)
    if self:IsSliderMax() then
        return
    end
    self:SetSliderValue(self.Value + Value)
end

function CommAmountSliderVM:SubSliderValue(Value)
    if self:IsSliderMin() then
        return
    end
    self:SetSliderValue(self.Value - Value)
end

function CommAmountSliderVM:IsSliderMax()
    return self.Value >= self.MaxValue
end

function CommAmountSliderVM:IsSliderMin()
    return self.Value <= self.MinValue
end

function CommAmountSliderVM:GetSliderValue()
    return self.Value
end

function CommAmountSliderVM:SetAddSubEnabled()
    if self:IsSliderMax() then
        self.AddBtnEnabled = false
    else
        self.AddBtnEnabled = true
    end

    if self:IsSliderMin() then
        self.SubBtnEnabled  = false
    else
        self.SubBtnEnabled  = true
    end

end

function CommAmountSliderVM:SetValueChangedCallback( func )
	self.ValueChangedCallback = func
end

function CommAmountSliderVM:SetCanChangedCallback( func )
	self.CanChangedCallback = func
end

return CommAmountSliderVM