---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-11-01 19:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")

local CactusType = ProtoRes.Game.LeapOfFaithCactusType

---@class GateLeapOfFaithTopInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextBronze UFTextBlock
---@field TextGold UFTextBlock
---@field TextSilver UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateLeapOfFaithTopInfoView = LuaClass(UIView, true)

function GateLeapOfFaithTopInfoView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextBronze = nil
	--self.TextGold = nil
	--self.TextSilver = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateLeapOfFaithTopInfoView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateLeapOfFaithTopInfoView:OnInit()
end

function GateLeapOfFaithTopInfoView:OnDestroy()
end

function GateLeapOfFaithTopInfoView:OnShow()
	self:InternalUpdateScore()
end

function GateLeapOfFaithTopInfoView:OnHide()
end

function GateLeapOfFaithTopInfoView:OnRegisterUIEvent()
end

function GateLeapOfFaithTopInfoView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.LeapOfFaithUpdateScore, self.OnLeapOfFaithUpdateCore)
end

function GateLeapOfFaithTopInfoView:OnLeapOfFaithUpdateCore(Params)
	self:InternalUpdateScore()

    if (Params ~= nil) then
        if (Params == CactusType.LeapOfFaithCactusTypeGold) then
            self:PlayAnimation(self.AnimGold)
        elseif (Params == CactusType.LeapOfFaithCactusTypeSilver) then
            self:PlayAnimation(self.AnimSilver)
        else
            self:PlayAnimation(self.AnimBronze)
        end
    end
end

function GateLeapOfFaithTopInfoView:InternalUpdateScore()
    -- 更新分数
    local GoldSauserLeapOfFaithMgr = _G.GoldSauserLeapOfFaithMgr
    local CurGoldCount = GoldSauserLeapOfFaithMgr.GoldCount
    local CurSilverCount = GoldSauserLeapOfFaithMgr.SilverCount
    local CurBronzeCount = GoldSauserLeapOfFaithMgr.BronzeCount
    local GoldMaxNum = GoldSauserLeapOfFaithMgr.GoldMaxNum
    local SilverMaxNum = GoldSauserLeapOfFaithMgr.SilverMaxNum
    local BronzeMaxNum = GoldSauserLeapOfFaithMgr.BronzeMaxNum

    self.TextGold:SetText(string.format("%d/%d", CurGoldCount, GoldMaxNum))
	self.TextSilver:SetText(string.format("%d/%d", CurSilverCount, SilverMaxNum))
	self.TextBronze:SetText(string.format("%d/%d", CurBronzeCount, BronzeMaxNum))
end

function GateLeapOfFaithTopInfoView:OnRegisterBinder()
end

return GateLeapOfFaithTopInfoView
