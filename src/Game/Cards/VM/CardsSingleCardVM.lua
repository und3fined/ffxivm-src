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
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local CardTypeEnum = LocalDef.CardItemType

---@class CardsSingleCardVM : UIViewModel
local CardsSingleCardVM = LuaClass(UIViewModel)

---Ctor ParentVM需要自行注意，目前可能是 CardsGroupCardVM 或者 CardsEditDecksPanelVM
function CardsSingleCardVM:Ctor(ParentVM, Index, CardType)
    -- self.LocalString = nil
    -- self.TextColor = nil
    -- self.ProfID = nil
    -- self.GenderID = nil
    -- self.IsVisible = nil
    self.__Index = Index
    self.__ParentVM = ParentVM
    self.CardItemType = CardType
    self.IsSelected = false
    self.CardId = 0 -- 卡片的ID
    self:SetFrameState(LocalDef.BGFrameState.NormalState)
    self.Disabled = false -- 显示灰色遮罩，后续优化一下，取纯色?
    self.ShowCardRootPanel = true -- 这里是否显示卡面，拖动的时候就不显示卡面了
    self.CardFrame = 0 -- 边框的类型 0是普通类型，1是银色边框
    self.ExchangedCardId = 0 -- 交换ID，要做效果的
    self.ShouldExpose = true -- 是否暴露，即是否隐藏卡背，默认是隐藏的，但是对手的牌，有些时候是会显示出来的
    self.IsExposed = true   -- 是否已经显露，在游戏内，开场的时候都是不显露的，在播放了效果之后才显露
    self.ShowName = true -- 是否显示名字
    self.FlipType = 0
    self.ShowTopName = false
    self.IsPlayed = false
    self.IsDeckShow = false -- 是否用于显示先后手更新用的
    self.ChangeNotify = false -- 更新通知用的
    self.CardName = nil -- 外面可能要用到，不做通知，因为一般不会更新
    self.ChangePoint = 0
    self.ShowBottomName = false
    self.ShowImgEmpty = true
    self.IsInGameMode = false
    self.TournamentWeaken = 0
    self:SetIsPlayerCard(false) -- 是否为玩家打出的牌，如果是，那么会修改底色
    self.Active = true -- 是否显示整个卡牌，已打出去的隐藏
end

function CardsSingleCardVM:SetTournamentWeaken(TargetValue)
    self.TournamentWeaken = TargetValue
end

function CardsSingleCardVM:SetShowImgEmpty(TargetValue)
    self.ShowImgEmpty = TargetValue
end

function CardsSingleCardVM:IsInGamePlayingCard()
    return self.__ParentVM and self.__ParentVM:IsPlayingCard()
end

function CardsSingleCardVM:SetActive(Value)
    self.Active = Value
end

-- 目前只是拖动，编辑的时候用到
function CardsSingleCardVM:CopyFromOther(OtherVM)
    if (OtherVM == nil) then
        _G.FLOG_ERROR("传入的 OtherVM 为空，请检查")
        return
    end

    self.CardId = OtherVM.CardId
    self.ChangePoint = OtherVM.ChangePoint
    self.TournamentWeaken = OtherVM.TournamentWeaken
end

function CardsSingleCardVM:TryChangeNotify()
    self.ChangeNotify = not self.ChangeNotify
end

-- 显示先手或者后手用的，其实就是显示一张图片
function CardsSingleCardVM:SetShowFirstOrSecond(IsPlayerCard)
    self.IsPlayerCard = IsPlayerCard
    self.IsDeckShow = true
    self:SetIsDisabled(false)
    self.ShowTopName = false
    self:TryChangeNotify()
end

function CardsSingleCardVM:SetIsPlayed(TargetBoolValue)
    self.IsPlayed = TargetBoolValue
    self:TryChangeNotify()
end

function CardsSingleCardVM:SetIsPlayerCard(TargeBoolValue)
    self.IsPlayerCard = TargeBoolValue
    self:TryChangeNotify()
end

function CardsSingleCardVM:SetIsShowCardRootPanel(TargetValue)
    self.ShowCardRootPanel = TargetValue
end

function CardsSingleCardVM:SetShowName(TargetValue)
    self.ShowName = TargetValue
end

function CardsSingleCardVM:SetShowTopName(TargetValue)
    self.ShowTopName = TargetValue
end

function CardsSingleCardVM:SetShowBottomName(TargetValue)
    self.ShowBottomName = TargetValue
end

function CardsSingleCardVM:GetShouldExpose()
    return self.ShouldExpose
end

function CardsSingleCardVM:SetChangePoint(TargetValue)
    self.ChangePoint = TargetValue
end

function CardsSingleCardVM:SetExpose(TargetValue)
    self.ShouldExpose = TargetValue
end

function CardsSingleCardVM:SetIsExposed(TargetValue)
    self.IsExposed = TargetValue
    self:TryChangeNotify()
end

function CardsSingleCardVM:GetIsExposed()
    return self.IsExposed
end

function CardsSingleCardVM:ResetData(TargetCardID)
    if (TargetCardID == nil) then
        self:SetCardId(0)
    else
        self:SetCardId(TargetCardID)
    end

    self:SetChangePoint(0)
    self.IsPlayed = false
    self:SetExpose(true)
    self:SetIsPlayerCard(false)
    self:SetIsDisabled(false)
    self.IsExposed = true
    self:TryChangeNotify()
end

function CardsSingleCardVM:GetIsClickTwice()
    return self.IsClickTwice
end

function CardsSingleCardVM:GetIndex()
    return self.__Index
end

function CardsSingleCardVM:GetCardType()
    return self.CardItemType
end

function CardsSingleCardVM:SetInGameEnemyMode()
    self.IsPlayerCard = false
    self.IsPlayed = false
    self:SetExpose(false)
    self.IsExposed = false
    self.IsInGameMode = true
    self:TryChangeNotify()
end

function CardsSingleCardVM:SetInGamePlayerMode(IsExposed)
    self.IsPlayerCard = true
    self.IsPlayed = false
    self:SetExpose(false)
    self.IsExposed = IsExposed
    self.IsInGameMode = true
    self:TryChangeNotify()
end

function CardsSingleCardVM:SetIsDisabled(IsDisabled)
    self.Disabled = IsDisabled
end

function CardsSingleCardVM:GetIsDisable()
    return self.Disabled
end

function CardsSingleCardVM:GetIsSelected()
    return self.IsSelected
end

function CardsSingleCardVM:SetIsSelected(TargetValue)
    self.IsSelected = TargetValue
end

function CardsSingleCardVM:SetParentVM(ParentVM)
    self.__ParentVM = ParentVM
end

function CardsSingleCardVM:HandleCardClicked()
    return self.__ParentVM:HandleCardClicked(self)
end

function CardsSingleCardVM:HandelMouseUp()
    if (self.__ParentVM.HandelCardMouseUp ~= nil) then
        self.__ParentVM:HandelCardMouseUp(self)
    end
end

function CardsSingleCardVM:HandleOnMouseLeave()
    if (self.__ParentVM ~= nil and self.__ParentVM.HandleOnMouseLeave ~= nil) then
        self.__ParentVM:HandleOnMouseLeave(self)
    end
end

function CardsSingleCardVM:SetCardId(TargetValue)
    self.CardId = TargetValue
    self:TryChangeNotify()
end

function CardsSingleCardVM:GetCardId()
    return self.CardId
end

function CardsSingleCardVM:GetIsPlayed()
    return self.IsPlayed
end

function CardsSingleCardVM:OnDragEnter()
    if (self.CardItemType == LocalDef.CardItemType.InfoShow) then
        self:SetFrameState(LocalDef.BGFrameState.YellowState)
    end

    self.__ParentVM:OnDragEnter(self)
end

function CardsSingleCardVM:GetDragVisualCardScale()
    return self.__ParentVM:GetDragVisualCardScale()
end

function CardsSingleCardVM:OnDragLeave()
    -- 如果是在显示槽里面的，则显示蓝色
    if (self.CardItemType == LocalDef.CardItemType.InfoShow) then
        -- 看一下是否为空，为空，就显示蓝色
        if (self.CardId <= 0) then
            self:SetFrameState(LocalDef.BGFrameState.BlueState)
        else
            self:SetFrameState(LocalDef.BGFrameState.NormalState)
        end
    else
        self:SetFrameState(LocalDef.BGFrameState.NormalState)
    end

    self.__ParentVM:OnDragLeave(self)
end

function CardsSingleCardVM:SetFrameState(TargetState)
    if (TargetState == LocalDef.BGFrameState.BlueState) then
        -- 要设置蓝色的话，判断一下，自己的ID是 空的，才可以
        if (self.CardId <= 0) then
            self.BGFrameState = TargetState
        end
    else
        self.BGFrameState = TargetState
    end
end

---@type 卡牌是否为空
function CardsSingleCardVM:IsCardEmpty()
    return self.CardId <= 0
end

function CardsSingleCardVM:OnDragDetected()
    self.__ParentVM:OnDragDetected(self)
end

function CardsSingleCardVM:OnDragCancelled()
    self.__ParentVM:OnDragCancelled(self)
end

function CardsSingleCardVM:CanInteractInEdit()
    return true
end

--- 返回拖拽卡片的VM
function CardsSingleCardVM:GetDragVisualCardVM()
    return self.__ParentVM:GetDragVisualCardVM()
end

--- 返回拖拽卡片的View
function CardsSingleCardVM:GetDragVisualCardItemView()
    return self.__ParentVM:GetDragVisualCardItemView()
end

function CardsSingleCardVM:CanClick()
    if (not self.IsExposed) then
        return false
    end

    if (self.__ParentVM ~= nil and not self.__ParentVM:CanCardClick(self)) then
        return false
    end

    return not self:GetIsDisable()
end

function CardsSingleCardVM:CanDrag()
    return self.__ParentVM:CanDrag(self)
end

---@param SrcItemVm CardsSingleCardVM
function CardsSingleCardVM:CanDragEnter(SrcItemVm)
    return true
end

---@param SrcItemVm CardsSingleCardVM
function CardsSingleCardVM:CanDrop(SrcItemVm)
    if self:CanInteractInEdit() then
        if self.CardItemType == CardTypeEnum.OwnedCard then
            if SrcItemVm.CardItemType == CardTypeEnum.OwnedCard then
                -- 不允许从右侧卡牌drop到同样是右侧的卡牌上
                return false
            end
        elseif self.CardItemType == CardTypeEnum.RewardCard then
            if SrcItemVm == self then
                -- 把卡组中一张卡拖到同一位置，视为cancel
                return false
            end
        end
        return true
    end

    return false
end

function CardsSingleCardVM:OnDrop(SrcItemVm)
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

-- 要返回当前类
return CardsSingleCardVM
