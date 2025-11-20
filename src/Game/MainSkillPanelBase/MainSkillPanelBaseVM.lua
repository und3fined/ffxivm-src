

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MainSkillPanelBaseVM : UIViewModel
local MainSkillPanelBaseVM = LuaClass(UIViewModel)

local SkillLimitState = {
	NoLimit = 0,		--不显示极限技
	LimitVisible = 1,	--显示极限技入口
	LimitCast = 2,		--显示极限技释放界面
}

function MainSkillPanelBaseVM:Ctor()
    rawset(self, "LimitState", SkillLimitState.NoLimit)
    self.IsLimitEntranceVisible = false
    self.IsLimitCastVisible = false
end

function MainSkillPanelBaseVM:OnInit()
end

function MainSkillPanelBaseVM:OnBegin()
end

function MainSkillPanelBaseVM:OnEnd()
end

function MainSkillPanelBaseVM:OnShutdown()
end

function MainSkillPanelBaseVM:SetLimitState(State)
    if rawget(self, "LimitState") == State then
        return
    end

    rawset(self, "LimitState", State)
    if State == SkillLimitState.NoLimit then
        self.IsLimitCastVisible = false
        self.IsLimitEntranceVisible = false
    elseif State == SkillLimitState.LimitVisible then
        self.IsLimitCastVisible = false
        self.IsLimitEntranceVisible = true
    else
        self.IsLimitCastVisible = true
        self.IsLimitEntranceVisible = false
    end
end

function MainSkillPanelBaseVM:GetLimitState()
    return rawget(self, "LimitState")
end

return MainSkillPanelBaseVM