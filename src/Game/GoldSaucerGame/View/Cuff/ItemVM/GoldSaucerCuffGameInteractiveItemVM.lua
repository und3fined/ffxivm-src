---
--- Author: Leo
--- DateTime: 2023-10-11 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local GoldSaucerCuffBlowResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffBlowResultItemVM")

local ProtoRes = require("Protocol/ProtoRes")
local InteractionCategory = ProtoRes.InteractionCategory
local CuffDefine = GoldSaucerMiniGameDefine.CuffDefine
local InteractionType = {
    Low = 0,
    Middle = 1,
    High = 3,
    Red = 2,
    StarLight = 4,
    Empty = 5,
}

---@class GoldSaucerCuffGameInteractiveItemVM : UIViewModel

local GoldSaucerCuffGameInteractiveItemVM = LuaClass(UIViewModel)

---Ctor
function GoldSaucerCuffGameInteractiveItemVM:Ctor(bNeedCallBack)
    -- Main Part
    self.Type = 0
    self.Pos = 0
    self.DelayShowTime = 0
    self.DelayShrinkTime = 0
    self.ShrinkSp = 0
    self.Scale = CuffDefine.BlowDefaultSize
    self.bBtnVisible = false
    self.bBlowResultVisible = false
    self.CallBackIndex = 0
    self.CuffBlowResultItemVM = GoldSaucerCuffBlowResultItemVM.New()
end

function GoldSaucerCuffGameInteractiveItemVM:IsEqualVM(Value)
    return true
end

function GoldSaucerCuffGameInteractiveItemVM:UpdateVM(Data)
    if Data.Pos == nil then
        return
    end
    self.Type = Data.Type
    self.Pos = Data.Pos
    self.DelayShowTime = Data.DelayShowTime
    self.DelayShrinkTime = Data.DelayShrinkTime
    self.ShrinkSp = Data.ShrinkSp
    self.Scale = CuffDefine.BlowDefaultSize * (1 - (Data.Scale - 1))
    self.bBlowResultVisible = Data.bBlowResultVisible
    self.bBtnVisible = Data.bBtnVisible
    if Data.ResultData ~= nil then
        self.CuffBlowResultItemVM:UpdateVM(Data.ResultData)
    else
        self.CuffBlowResultItemVM:ResetVM()
    end

    local GameInst = _G.GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
    if GameInst == nil then
        return
    end
    if GameInst.IsBegin then
        self.CallBackIndex = self.CallBackIndex + 1
    end
end

function GoldSaucerCuffGameInteractiveItemVM:UpdateResultTip(Data)
    self.CuffBlowResultItemVM:UpdateVM(Data)
end

function GoldSaucerCuffGameInteractiveItemVM:ResetVM()
    -- Main Part
    self.Type = 0
    self.Pos = 0
    self.bRedBlowVisible = false
    self.bBlueBlowVisible = false
    self.bYellowBlowVisible = false
    self.bPurpleBlowVisible = false
    self.DelayShowTime = 0
    self.DelayShrinkTime = 0
    self.ShrinkSp = 0
    self.Scale = CuffDefine.BlowDefaultSize
    self.bBtnVisible = false
    self.bBlowResultVisible = false
    self.CallBackIndex = 0
    self.CuffBlowResultItemVM:ResetVM()
end

function GoldSaucerCuffGameInteractiveItemVM:AdapterOnGetWidgetIndex()
    local Type = self.Type
    -- print("AdapterOnGetWidgetIndex"..tostring(Type))
    if Type == InteractionCategory.CATEGORY_LOW then
        return InteractionType.Low
    elseif Type == InteractionCategory.CATEGORY_MIDDLE then
        return InteractionType.Middle
    elseif Type == InteractionCategory.CATEGORY_HIGH then
        return InteractionType.High
    elseif Type == InteractionCategory.CATEGORY_STARLIGHT then
        return InteractionType.StarLight
    elseif Type == InteractionCategory.CATEGORY_ERROR then
        return InteractionType.StarLight
    elseif Type == InteractionCategory.CATEGORY_NONE then
        return InteractionType.Empty
    else
        return InteractionType.Red
    end
end

function GoldSaucerCuffGameInteractiveItemVM:GetBlowResultItemVM()
    return self.CuffBlowResultItemVM
end

function GoldSaucerCuffGameInteractiveItemVM:UpdateBlowResultVisible(bVisible)
    self.bBlowResultVisible = bVisible
end

return GoldSaucerCuffGameInteractiveItemVM