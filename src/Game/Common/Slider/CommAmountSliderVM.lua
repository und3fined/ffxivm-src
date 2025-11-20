local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local TextColor = {
	"d1ba8e",--黄
	"dc5868",--红
	"#828282",--灰
	"d5d5d5", -- 白
}

local YellowText = _G.UE.FLinearColor(0.6, 0.5, 0.3, 1)
local GeryText = _G.UE.FLinearColor(0.2, 0.2, 0.2, 1)

---@class CommAmountSliderVM : UIViewModel
local CommAmountSliderVM = LuaClass(UIViewModel)

---Ctor
function CommAmountSliderVM:Ctor()
    self:SetSliderValueMaxMin(1,0)
end

function CommAmountSliderVM:SetSliderValueMaxMin(MaxValue, MinValue, BatchValue)
    self.MaxValue = MaxValue or 0
    self.MinValue = MinValue or 0
    self.BatchValue = BatchValue or 0
    if MaxValue <= 0 then
        self.MinValue = self.MaxValue
        self.Value = self.MinValue
        self.Percent = 0
        self.SilderEnabled = false
    elseif MaxValue == MinValue then
        self.MinValue = self.MaxValue
        self.Value = self.MinValue
        self.Percent = 1
        if self.MinValue == 1 then
            self.SilderEnabled = true
        else
            self.SilderEnabled = false
        end
	else
        self.Value = self.MinValue
        self.Percent = (self.Value - self.MinValue) / (self.MaxValue - self.MinValue)
        self.SilderEnabled = true
    end

    self.ValueText = self.Value
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

    self.ValueText = self.Value
    self:SetAddSubEnabled()

    if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(self.Value)
	end
end

--处理滑块滑动事件
function CommAmountSliderVM:SetSliderPercent(Percent)
    self.Percent = Percent
    
    local Range = self.MaxValue - self.MinValue
    local StepCount = Range  -- 例如 1~3 → 3个值
    
    local RawStep = Percent * StepCount
    local Step = math.floor(RawStep + 0.5)
    
    Step = math.max(0, math.min(Step, StepCount))
    
    -- 更新实际值和百分比
    self.Value = self.MinValue + Step
    self.Percent = Step / StepCount  -- 更新百分比以对齐到离散位置
    self.ValueText = self.Value

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

function CommAmountSliderVM:AddBatchValue()
    if self:IsSliderMax() then
        return
    end

    local Value = self.Value + self.BatchValue
    if Value > self.MaxValue then
        Value = self.MaxValue
    end

    self:SetSliderValue(Value)
end

function CommAmountSliderVM:SubSliderValue(Value)
    if self:IsSliderMin() then
        return
    end
    self:SetSliderValue(self.Value - Value)
end

function CommAmountSliderVM:SubBatchValue()
    if self:IsSliderMin() then
        return
    end

    local Value = self.Value - self.BatchValue
    if Value < self.MinValue then
        Value = self.MinValue
    end

    self:SetSliderValue(Value)
end

function CommAmountSliderVM:SetMaxValue()
    if self:IsSliderMax() then
        return
    end

    self:SetSliderValue(self.MaxValue)
end

function CommAmountSliderVM:SetInputNum(Num)
    if self:IsSliderMax() then
        return
    end

    if self:IsSliderMin() then
        return
    end

    self:SetSliderValue(Num)
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
        self.AddTenBtnEnabled = false
        self.AddTenColor = GeryText
        self.ImgAddTenDisab = true
        self.ImgAddTenNormal = false
    else
        self.AddBtnEnabled = true
        self.AddTenBtnEnabled = true
        self.AddTenColor = YellowText
        self.ImgAddTenDisab = false
        self.ImgAddTenNormal = true
    end

    if self:IsSliderMin() then
        self.SubBtnEnabled  = false
        self.SubTenBtnEnabled = false
        self.SubtractTenColor = GeryText
        self.ImgSubTenDisab = true
        self.ImgSubTenNormal = false
    else
        self.SubBtnEnabled  = true
        self.SubTenBtnEnabled = true
        self.SubtractTenColor = YellowText
        self.ImgSubTenDisab = false
        self.ImgSubTenNormal = true
    end
end

function CommAmountSliderVM:SetMultipleBtnState(Value)
    self.MultipleBtnState = Value
end

function CommAmountSliderVM:SetValueChangedCallback( func )
	self.ValueChangedCallback = func
end

function CommAmountSliderVM:SetCanChangedCallback( func )
	self.CanChangedCallback = func
end

return CommAmountSliderVM