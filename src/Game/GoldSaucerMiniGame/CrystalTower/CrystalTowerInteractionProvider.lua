
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType

local UE = _G.UE
local TimerMgr = _G.TimerMgr
---@class CrystalTowerInteractionProvider
local CrystalTowerInteractionProvider = LuaClass()

---Ctor
function CrystalTowerInteractionProvider:Ctor(InitPos, TrackIndex)
	self.InitPos = InitPos
    self.TrackIndex = TrackIndex
    -- self.RemainCount = 0
    self.InteractionCfgs = {}
    self.AllTimer = {}
end

--- @type 准备让交互物开始下落
function CrystalTowerInteractionProvider:OnBeginFalling()
    local InteractionCfgs = self.InteractionCfgs
    local AllTimer = self.AllTimer
    local InitPos = self.InitPos
    local DelayShowTime = 0
    for i = 1, #InteractionCfgs do
        local Cfg = InteractionCfgs[i]
        if Cfg ~= nil then
            DelayShowTime = DelayShowTime + Cfg.DelayShowTime
            local Timer = TimerMgr:AddTimer(self, function()
                local Interaction = self:GetInteraction()
                if Interaction ~= nil then
                    Interaction:SetbShow(true)
                    UIUtil.CanvasSlotSetPosition(Interaction, InitPos)
                    local VM = Interaction:GetViewModel()
                    VM:UpdateVM(Cfg)
                    Interaction:UpdateTrackIndex(self.TrackIndex) -- 在哪个赛道
                    Interaction:SetShootProvider(self)
                    Interaction:Falling(Cfg.Category) 
                else
                    FLOG_ERROR("CrystalTowerInteractionProvider Interaction = nil ")
                end
            end, DelayShowTime / 1000) -- 毫秒变秒
            table.insert(AllTimer, Timer)
        end
    end
end

function CrystalTowerInteractionProvider:GetInteraction()
    local Callback = self.InteractionFactory
    if Callback then
        return Callback()
    end
end

function CrystalTowerInteractionProvider:RegisterInteractionFactory(Callback)
    self.InteractionFactory = Callback
end

--- @type 缓存交互物池
function CrystalTowerInteractionProvider:CachInteraction(Elem)
    local HidePos = GoldSaucerMiniGameDefine.MiniGameClientConfig[MiniGameType.CrystalTower].HidePos
    Elem:Reset()
    UIUtil.CanvasSlotSetPosition(Elem, HidePos)
end

--- @type 设置交互物的配置
function CrystalTowerInteractionProvider:SetInteractionCfgs(InteractionCfgs)
    self.InteractionCfgs = InteractionCfgs
end

--- @type 
function CrystalTowerInteractionProvider:Reset()
    self.InteractionCfgs = {}

    local AllTimer = self.AllTimer
    for i, v in pairs(AllTimer) do
        local Timer = v
        if Timer ~= nil then
            TimerMgr:CancelTimer(Timer)
        end
    end
    self.AllTimer = {}
    
end

--------ItemView------


----------------点击交互

return CrystalTowerInteractionProvider