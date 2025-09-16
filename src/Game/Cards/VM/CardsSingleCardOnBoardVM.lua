--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local Log = require("Game/MagicCard/Module/Log")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local EventID = require("Define/EventID")
local CardsSingleCardVM = require("Game/Cards/VM/CardsSingleCardVM")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local CardTypeEnum = LocalDef.CardItemType

---@class CardsSingleCardOnBoardVM : UIViewModel
local CardsSingleCardOnBoardVM = LuaClass(UIViewModel)

---Ctor ParentVM需要自行注意，目前可能是 CardsGroupCardVM 或者 CardsEditDecksPanelVM
function CardsSingleCardOnBoardVM:Ctor(ParentVM, Index, CardType)
    self.Index = Index
    self.__ParentVM = ParentVM
    self.SingleCardVM = CardsSingleCardVM.New(ParentVM, Index, CardType)
    self.SingleCardVM:SetShowName(false)
    self.ShowHover = false
    self:SetIsPlayerCard(false)
    self.IsPlayed = false
    self.UpdateNotify = false -- 简单的更新用
end

function CardsSingleCardOnBoardVM:SetFlipType(TargetValue)
    self.SingleCardVM.FlipType = TargetValue
end

function CardsSingleCardOnBoardVM:SetChangePoint(TargetValue)
    self.SingleCardVM:SetChangePoint(TargetValue)
end

function CardsSingleCardOnBoardVM:SetTournamentWeaken(TargetValue)
    self.SingleCardVM:SetTournamentWeaken(TargetValue)
end

function CardsSingleCardOnBoardVM:GetIndex()
    return self.Index
end

function CardsSingleCardOnBoardVM:ChangeNotify()
    self.UpdateNotify = not self.UpdateNotify
end

function CardsSingleCardOnBoardVM:GetCardType()
    return self.SingleCardVM:GetCardType()
end

function CardsSingleCardOnBoardVM:SetIsPlayerCard(TargetBoolValue)
    self.IsPlayerCard = TargetBoolValue
    self.SingleCardVM:SetIsPlayerCard(TargetBoolValue)
    self:ChangeNotify()
end

function CardsSingleCardOnBoardVM:SetIsPlayed(TargetValue)
    self.IsPlayed = TargetValue
    self.SingleCardVM:SetIsPlayed(TargetValue)
    self:ChangeNotify()
end

function CardsSingleCardOnBoardVM:SetCardId(TargetValue)
    self.SingleCardVM:SetCardId(TargetValue)
    self.SingleCardVM:SetExpose(true)
    self:ChangeNotify()
end

function CardsSingleCardOnBoardVM:GetCardId()
    return self.SingleCardVM:GetCardId()
end

function CardsSingleCardOnBoardVM:ResetData()
    self.SingleCardVM:ResetData(0)
    self.IsPlayed = false
    self.SingleCardVM:SetShowImgEmpty(false)
    self:SetIsPlayerCard(false)
    self:ChangeNotify()
end

function CardsSingleCardOnBoardVM:OnDragEnter()
    -- 这里看下， 是否已经放下卡牌了
    if (self.SingleCardVM:GetCardId() > 0) then
        return
    end
    self:SetFrameState(LocalDef.BGFrameState.YellowState)
    self.__ParentVM:OnDragEnter(self)
end

function CardsSingleCardOnBoardVM:OnDragCancelled()
    self.__ParentVM:OnDragCancelled(self)
end

function CardsSingleCardOnBoardVM:SetFrameState(TargetValue)
    if (TargetValue == LocalDef.BGFrameState.NormalState) then
        self.ShowHover = false
    else
        self.ShowHover = true
    end
end

function CardsSingleCardOnBoardVM:GetIsPlayed()
    return self.IsPlayed
end

function CardsSingleCardOnBoardVM:CanDrop(SrcItemVm)
    return SrcItemVm:GetCardId() > 0
end

function CardsSingleCardOnBoardVM:OnDrop(SrcItemVm)
    if (SrcItemVm == nil) then
        return false
    end

    self:SetFrameState(LocalDef.BGFrameState.NormalState)
    if self:CanDrop(SrcItemVm) then
        self.__ParentVM:OnDrop(self)
        return true
    end
    return false
end

function CardsSingleCardOnBoardVM:OnDragLeave()
    self:SetFrameState(LocalDef.BGFrameState.NormalState)
    self.__ParentVM:OnDragLeave(self)
end

-- 要返回当前类
return CardsSingleCardOnBoardVM
