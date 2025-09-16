--ViewModel是用来存储UI需要显示的数据，尽量不要处理和UI显示无关的逻辑。
--ViewModel中数据变化时，会调用绑定Binder的OnValueChanged函数来更新UI。
--UIViewModel所有成员变量都会创建为UIBindableProperty，所以UIViewModel不应该包含非UI要显示的属性。
--UIViewModel包含一个BindableProperties列表，Key值是PropertyName，Value值是UIBindableProperty
--使用类变量时和普通变量一样使用，UIViewModel会自动创建UIBindableProperty
--更多UIViewModel介绍请参考下面wiki
--https://iwiki.woa.com/pages/viewpage.action?pageId=858296043

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



---@class CommCountSliderVM : UIViewModel
local CommCountSliderVM = LuaClass(UIViewModel)

---Ctor
function CommCountSliderVM:Ctor()
    self:SetSliderValueMaxMin(1,0)
end

function CommCountSliderVM:SetSliderValueMaxMin(MaxValue, MinValue)
    self.MaxValue = MaxValue
    self.MinValue = MinValue
    if MaxValue <= 0  or MaxValue == MinValue then
        self.MinValue = self.MaxValue
        self.Value = self.MinValue
        self.Percent = 1
        self.SilderEnabled = false
	else
        self.Value = self.MinValue
        self.Percent = (self.Value - self.MinValue) / (self.MaxValue - self.MinValue)
        self.SilderEnabled = true
    end

    self:SetAddSubEnabled()
end


--处理滑块旁边加减号点击事件
function CommCountSliderVM:SetSliderValue(Vaule)
    if self.SilderEnabled == false then
        return
    end
    
    self.Value = Vaule
    
    if self.CanChangedCallback ~= nil then
        self.Value =  self.CanChangedCallback(Vaule)
    end

    self.Percent  = (self.Value - self.MinValue) / (self.MaxValue - self.MinValue)

    self:SetAddSubEnabled()

    if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(self.Value)
	end
end

--处理滑块滑动事件
function CommCountSliderVM:SetSliderPercent(Percent)
    self.Percent = Percent
    self.Value = math.floor(Percent * (self.MaxValue - self.MinValue)) + self.MinValue
    
    self:SetAddSubEnabled()
    
    if self.ValueChangedCallback ~= nil then
		self.ValueChangedCallback(self.Value)
	end
end

function CommCountSliderVM:AddSliderValue()
    if self:IsSliderMax() then
        return
    end
    self:SetSliderValue(self.Value + 1)
end

function CommCountSliderVM:SubSliderValue()
    if self:IsSliderMin() then
        return
    end
    self:SetSliderValue(self.Value - 1)
end

function CommCountSliderVM:IsSliderMax()
    return self.Value >= self.MaxValue
end

function CommCountSliderVM:IsSliderMin()
    return self.Value <= self.MinValue
end

function CommCountSliderVM:GetSliderValue()
    return self.Value
end

function CommCountSliderVM:SetAddSubEnabled()
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


function CommCountSliderVM:SetValueChangedCallback( func )
	self.ValueChangedCallback = func
end

function CommCountSliderVM:SetCanChangedCallback( func )
	self.CanChangedCallback = func
end

--要返回当前类
return CommCountSliderVM