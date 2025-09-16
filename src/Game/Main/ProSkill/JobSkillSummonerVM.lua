local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local JobSkillSummonerVM = LuaClass(UIViewModel)

function JobSkillSummonerVM:Ctor()
    --self.GemLock = false

    self.AnimState1 = 1
    self:SetBindPropertyNoCheckValueChange("AnimState1")

    self.AnimState2 = nil
    self:SetBindPropertyNoCheckValueChange("AnimState2")

    self.AnimState3 = nil
    self:SetBindPropertyNoCheckValueChange("AnimState3")

    for i = 1, 3 do
        self[string.format("GemPile%d", i)] = 0

        local LightAnim = string.format("LightAnim%d", i)
        self[LightAnim] = nil
        local DarkAnim = string.format("DarkAnim%d", i)
        self[DarkAnim] = nil
        local BigShowAnim = string.format("BigShowAnim%d", i)
        self[BigShowAnim] = nil
        local BigHiddenAnim = string.format("BigHiddenAnim%d", i)
        self[BigHiddenAnim] = nil

        local GemstoneCanvas = string.format("GemstoneCanvas%d", i)
        self[GemstoneCanvas] = false

        --self:SetBindPropertyNoCheckValueChange(GemRenderOpacity)
        --self:SetBindPropertyNoCheckValueChange(GemShineRenderOpacity)
        self:SetBindPropertyNoCheckValueChange(LightAnim)
        self:SetBindPropertyNoCheckValueChange(DarkAnim)
        self:SetBindPropertyNoCheckValueChange(BigShowAnim)
        self:SetBindPropertyNoCheckValueChange(BigHiddenAnim)
        self:SetBindPropertyNoCheckValueChange(GemstoneCanvas)
    end
    self.BuffCDVisible = false
    self:SetBindPropertyNoCheckValueChange("BuffCDVisible")
    self.BuffCDTime = -1

    self.AnimalIndex = 1

    self.DragonInitLoopAnim = false

    rawset(self, "GemPile", {})
end

function JobSkillSummonerVM:SetBindPropertyNoCheckValueChange(BindName)
    local BindProperty = self:FindBindableProperty(BindName)
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end
end

--仅修改了透明度，没有显示闪烁材质
function JobSkillSummonerVM:SetGemRenderOpacity(RenderOpacity, ShineRenderOpacity)
    for i = 1, 3 do
        self[string.format("DarkAnim%d", i)] = -1
        self[string.format("GemRenderOpacity%d", i)] = RenderOpacity
        self[string.format("GemShineRenderOpacity%d", i)] = ShineRenderOpacity
    end
    self.BuffCDTime = -1
end

function JobSkillSummonerVM:SetGemData(Index, Time, Pile)
    if Index < 1 or Index > 3 then return end
    self[string.format("GemPile%d", Index)] = Pile
    self.BuffCDVisible = Time > 0
    local GemPile = rawget(self, "GemPile")
    local CurPile = GemPile[Index]
    GemPile[Index] = Pile
    if Pile <= 0 then
        self[string.format("BigHiddenAnim%d", Index)] = 1
        self[string.format("BigShowAnim%d", Index)] = -1
        self[string.format("DarkAnim%d", Index)] = 1
        return
    end
    self.BuffCDTime = Time
    if Pile > 0 and CurPile == nil then
        self[string.format("BigShowAnim%d", Index)] = 1
        self[string.format("BigHiddenAnim%d", Index)] = -1
    end
end

function JobSkillSummonerVM:ResetGemPileList()
    rawset(self, "GemPile", {})
end

function JobSkillSummonerVM:SetGemStatus(Index, Status)
    if Index < 1 or Index > 3 then return end
    if Status then
        self[string.format("DarkAnim%d", Index)] = -1
        self[string.format("LightAnim%d", Index)] = 1
    end
end

--断线重连、重新显示量谱等情况会导致表现异常，这里reset一下
function JobSkillSummonerVM:Reset()
    rawset(self, "GemPile", {})
    self:SwitchState(1, -1, -1)
    self.BuffCDVisible = false

    for i = 1, 3 do
        local LightAnim = string.format("LightAnim%d", i)
        self[LightAnim] = nil
        local DarkAnim = string.format("DarkAnim%d", i)
        self[DarkAnim] = nil
        local BigShowAnim = string.format("BigShowAnim%d", i)
        self[BigShowAnim] = nil
        local BigHiddenAnim = string.format("BigHiddenAnim%d", i)
        self[BigHiddenAnim] = nil
    end
    self.BuffCDVisible = false
    self.BuffCDTime = -1
end

function JobSkillSummonerVM:SwitchState(State1, State2, State3)
    --State1 + State2 + State3 == -1
    self.AnimState1 = State1
    self.AnimState2 = State2
    self.AnimState3 = State3
end

return JobSkillSummonerVM