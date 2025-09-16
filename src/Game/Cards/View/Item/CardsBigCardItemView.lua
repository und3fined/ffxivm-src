---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-10-23 17:07
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CardsMainVM = require("Game/Cards/VM/CardsMainPanelViewVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local EventID = require("Define/EventID")
local Log = require("Game/MagicCard/Module/Log")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local RuleDef = ProtoRes.Game.fantasy_card_rule
local EventMgr = _G.EventMgr
local UE = _G.UE
local UEMath = UE.UKismetMathLibrary
local CardTypeEnum = LocalDef.CardItemType
local MouseButtonCfg = LocalDef.CardItemMouseButton
local UKismetInputLibrary = UE.UKismetInputLibrary
local FlipTypeEnum = ProtoCS.FLIP_MOVEMENT
local FLOG_ERROR = _G.FLOG_ERROR
local Handled <const> = _G.UE.UWidgetBlueprintLibrary.Handled()
local Unhandled <const> = _G.UE.UWidgetBlueprintLibrary.Unhandled()

---@class CardsBigCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanvasDeckRoot UFCanvasPanel
---@field CardDisable UFImage
---@field CardsNumber CardsNumberItemView
---@field EFF_Connect_Down UFImage
---@field EFF_Connect_Left UFImage
---@field EFF_Connect_Right UFImage
---@field EFF_Connect_Up UFImage
---@field FImagePlus UFImage
---@field ImageDeckFrame UFImage
---@field ImgBack UFImage
---@field ImgCardBG UFImage
---@field ImgCardBGBlue UFImage
---@field ImgCardBGBlueForGame UFImage
---@field ImgCardBGRed UFImage
---@field ImgCardBGRedForGame UFImage
---@field ImgEmpty UFImage
---@field ImgFrame UFImage
---@field ImgFrameBlue UFImage
---@field ImgFrameYellow UFImage
---@field ImgFrame_Silver UFImage
---@field ImgIcon UFImage
---@field ImgRace UFImage
---@field ImgStar UFImage
---@field PanelCard UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field TextCardName UFTextBlock
---@field TextNameBottom UFTextBlock
---@field TextNameOnTop UFTextBlock
---@field TextPlus UTextBlock
---@field AnimBackLight UWidgetAnimation
---@field AnimCardflopHorizontal UWidgetAnimation
---@field AnimCardflopPortrait UWidgetAnimation
---@field AnimCardIn UWidgetAnimation
---@field AnimChangeofhandGlow UWidgetAnimation
---@field AnimConnectLight UWidgetAnimation
---@field AnimExpandLight UWidgetAnimation
---@field AnimFlipHorizontalToBlue UWidgetAnimation
---@field AnimFlipHorizontalToRed UWidgetAnimation
---@field AnimFlipVerticalToBlue UWidgetAnimation
---@field AnimFlipVerticalToRed UWidgetAnimation
---@field AnimNoticeLightHidden UWidgetAnimation
---@field AnimNoticeLightShow UWidgetAnimation
---@field AnimNumAddLight UWidgetAnimation
---@field AnimNumSubtractLight UWidgetAnimation
---@field AnimOutlineGlow UWidgetAnimation
---@field AnimShake UWidgetAnimation
---@field EnemyExchange UWidgetAnimation
---@field EnemyPlayedAnim UWidgetAnimation
---@field PlayerExchange UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsBigCardItemView = LuaClass(UIView, true)

function CardsBigCardItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClick = nil
    -- self.CardsNumber = nil
    -- self.ImgCardBG = nil
    -- self.ImgEmpty = nil
    -- self.ImgFrame = nil
    -- self.ImgIcon = nil
    -- self.ImgRace = nil
    -- self.ImgStar = nil
    -- self.PanelCard = nil
    -- self.PanelContent = nil
    -- self.TextCardName = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsBigCardItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CardsNumber)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsBigCardItemView:OnInit()
    local Binders = {
        {
            "CardId",
            UIBinderValueChangedCallback.New(self, nil, self.OnCardIDChanged)
        },
        {
            "BGFrameState",
            UIBinderValueChangedCallback.New(self, nil, self.OnBGFramgeStateChange)
        },
        {
            "Disabled",
            UIBinderValueChangedCallback.New(self, nil, self.OnDisabledChange)
        },
        {
            "ShowCardRootPanel",
            UIBinderValueChangedCallback.New(self, nil, self.OnShowCardRootPanelChanged)
        },
        {
            "ShowName",
            UIBinderSetIsVisible.New(self, self.TextCardName, false, false, false)
        },
        {
            "ShowTopName",
            UIBinderSetIsVisible.New(self, self.TextNameOnTop)
        },
        {
            "ShowBottomName",
            UIBinderSetIsVisible.New(self, self.TextNameBottom)
        },
        {
            "ExchangedCardId",
            UIBinderValueChangedCallback.New(self, nil, self.OnExchangedCardIdChange)
        },
        {
            "ChangeNotify",
            UIBinderValueChangedCallback.New(self, nil, self.OnChangeNotifyChange)
        },
        {
            "ChangePoint",
            UIBinderValueChangedCallback.New(self, nil, self.OnChangePointChanged)
        },
        {
            "FlipType",
            UIBinderValueChangedCallback.New(self, nil, self.OnTriggerFlip)
        },
        {
            "ShowImgEmpty",
            UIBinderSetIsVisible.New(self, self.ImgEmpty)
        },
        {
            "TournamentWeaken",
            UIBinderValueChangedCallback.New(self, nil, self.OnTournamentWeaken)
        },
        {
            "Active",
            UIBinderSetIsVisible.New(self, self)
        },
    }
    self.Binders = Binders
    
    UIUtil.SetIsVisible(self.CanvasDeckRoot, false)
    UIUtil.SetIsVisible(self.ImgCardBGRedForGame, false)
    UIUtil.SetIsVisible(self.ImgCardBGBlueForGame, false)
end

local function AddValueWithTournamentWeaken(CurrentValue, TournamentWeaken)
    local _finalValue = CurrentValue + TournamentWeaken
    if (_finalValue < 1) then
        _finalValue = 1
        return _finalValue
    end

    if (_finalValue > 10) then
        _finalValue = 10
        return _finalValue
    end

    return _finalValue
end

function CardsBigCardItemView:OnTournamentWeaken()
    if (self.ViewModel.CardId == nil or self.ViewModel.CardId <= 0) then
        return
    end

    local ItemCfg = CardCfg:FindCfgByKey(self.ViewModel.CardId)
    if (ItemCfg ~= nil) then
        -- 这里要处理一下大赛，会直接削弱数值,仅针对本地玩家幻卡
        -- 上限是A，下限是1，直接改
        local _tournamentWeaken = self.ViewModel.TournamentWeaken or 0
        if (_tournamentWeaken ~= nil and _tournamentWeaken ~= 0) then
            local _upValue = AddValueWithTournamentWeaken(ItemCfg.Up, _tournamentWeaken)
            local _downValue = AddValueWithTournamentWeaken(ItemCfg.Down, _tournamentWeaken)
            local _leftValue = AddValueWithTournamentWeaken(ItemCfg.Left, _tournamentWeaken)
            local _rightValue = AddValueWithTournamentWeaken(ItemCfg.Right, _tournamentWeaken)
            --self.CardsNumber:SetNumbes(_upValue, _downValue, _leftValue, _rightValue)

            UIUtil.SetIsVisible(self.TextPlus, true)
            UIUtil.SetIsVisible(self.FImagePlus, true)
            local ColorCfg = LocalDef.RuleEffectWeakenStrenthenColor
            UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPlus, ColorCfg.WeakenText)
            UIUtil.ImageSetColorAndOpacityHex(self.FImagePlus, ColorCfg.WeakenImg)
            self.TextPlus:SetText(_tournamentWeaken)
        end
        self.CardsNumber:SetNumbes(ItemCfg.Up, ItemCfg.Down, ItemCfg.Left, ItemCfg.Right)
    else
        FLOG_ERROR("获取幻卡数据失败，ID是："..tostring(self.ViewModel.CardId))
    end
end

function CardsBigCardItemView:OnTriggerFlip(FlipType)
    if FlipType == 0 then
        return
    end

    local ItemData = self.ViewModel
    if not ItemData then
        return
    end

    local AnimToPlay
    if ItemData:IsInGamePlayingCard() then
        -- 这里IsPlayerCard是翻牌前的状态
        if ItemData.IsPlayerCard then
            AnimToPlay = FlipType == FlipTypeEnum.FLIP_MOVEMENT_LEVEL and self.AnimFlipHorizontalToRed or
                             self.AnimFlipVerticalToRed
        else
            AnimToPlay = FlipType == FlipTypeEnum.FLIP_MOVEMENT_LEVEL and self.AnimFlipHorizontalToBlue or
                             self.AnimFlipVerticalToBlue
        end
    else
        AnimToPlay = FlipType == FlipTypeEnum.FLIP_MOVEMENT_LEVEL and self.FlipAnimLeftRight or
                         self.FlipAnimUpDown
    end
    Log.I("MagicCardCardItemView trigger flip [%s]", Log.EnumValueToKey(FlipTypeEnum, FlipType))
    self:PlayAnimation(AnimToPlay)
    -- 没有trigger，所以需要手动重置
    ItemData.FlipType = 0
end

-- 界面单独设置，就不通过VM了，因为VM是多个界面通用的
function CardsBigCardItemView:SetTextCardNameVisible(TargetValue)
    UIUtil.SetIsVisible(self.TextCardName, TargetValue)
end

function CardsBigCardItemView:OnChangeNotifyChange(NewValue, OldValue)
    local _selfVM = self.ViewModel
    UIUtil.SetIsVisible(self.CardDisable, _selfVM.Disabled)

    if (self.ViewModel.IsDeckShow) then
        UIUtil.SetIsVisible(self.CanvasDeckRoot, true)
        UIUtil.SetIsVisible(self.TextNameOnTop, false)
        UIUtil.SetIsVisible(self.TextCardName, false)
        UIUtil.SetIsVisible(self.ImgBack, false)
        UIUtil.SetIsVisible(self.PanelContent, false)

        if (self.ViewModel.IsPlayerCard) then
            UIUtil.SetIsVisible(self.ImgCardBGBlue, true)
            UIUtil.SetIsVisible(self.ImgCardBGRed, false)
        else
            UIUtil.SetIsVisible(self.ImgCardBGBlue, false)
            UIUtil.SetIsVisible(self.ImgCardBGRed, true)
        end
    else
        UIUtil.SetIsVisible(self.CanvasDeckRoot, false)

        if (self.ViewModel.IsExposed) then
            UIUtil.SetIsVisible(self.ImgBack, false)
            UIUtil.SetIsVisible(self.PanelContent, _selfVM:GetCardId() > 0)
        else
            UIUtil.SetIsVisible(self.ImgBack, true)
            UIUtil.SetIsVisible(self.PanelContent, false)
        end

        if (self.ViewModel.IsPlayed or self.ViewModel.IsInGameMode) then
            if (self.ViewModel.IsPlayerCard) then
                UIUtil.SetIsVisible(self.ImgCardBGRedForGame, false)
                UIUtil.SetIsVisible(self.ImgCardBGBlueForGame, true)
            else
                UIUtil.SetIsVisible(self.ImgCardBGRedForGame, true)
                UIUtil.SetIsVisible(self.ImgCardBGBlueForGame, false)
            end
        end
    end
end

function CardsBigCardItemView:OnExchangedCardIdChange(NewValue, OldValue)
    if NewValue <= 0 then
        return
    end

    local ItemData = self.ViewModel
    if not ItemData then
        return
    end

    -- 这里还没有动效果，先直接改变好了
    self.ViewModel:SetCardId(NewValue)
    -- self.ViewModel:SetExpose(true) -- 交换牌后不会直接看到是那张牌
    if ItemData.IsPlayerCard then
        self:PlayAnimationForward(self.PlayerExchange, 1, false)
    else
        self:PlayAnimationForward(self.EnemyExchange, 1, false)
    end
    --self.ViewModel.ExchangedCardId = 0
end

function CardsBigCardItemView:OnDisabledChange(NewValue, OldValue)
    UIUtil.SetIsVisible(self.CardDisable, NewValue)
end

function CardsBigCardItemView:OnShowCardRootPanelChanged(NewValue, OldValue)
    local NewCardId = self.ViewModel:GetCardId()
    if NewCardId == nil or NewCardId == 0 or not self.ViewModel.ShowCardRootPanel then
        UIUtil.SetIsVisible(self.PanelContent, false)
    else
        UIUtil.SetIsVisible(self.PanelContent, true)
    end
end

function CardsBigCardItemView:OnChangePointChanged(NewChangePoint)
    if NewChangePoint == nil or NewChangePoint == 0 then
        UIUtil.SetIsVisible(self.FImagePlus, false)
        UIUtil.SetIsVisible(self.TextPlus, false)
        return
    end
    if self.ViewModel == nil then
        return
    end
    Log.I(
        "MagicCardCardItemView:OnChangePointChanged CardIdx [%d] NewChangePoint: %d", self.ViewModel:GetIndex(),
        NewChangePoint
    )
    UIUtil.SetIsVisible(self.TextPlus, true)
    UIUtil.SetIsVisible(self.FImagePlus, true)
    local ColorCfg = LocalDef.RuleEffectWeakenStrenthenColor
    if NewChangePoint > 0 then
        -- 强化弱化在一局中保持不变，所以实际上>0即代表是强化规则，反之则是弱化
        UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPlus, ColorCfg.StrenthenText)
        UIUtil.ImageSetColorAndOpacityHex(self.FImagePlus, ColorCfg.StrenthenImg)
        -- self:PlayAnimation(self.AnimNumAddLight)
    else
        UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPlus, ColorCfg.WeakenText)
        UIUtil.ImageSetColorAndOpacityHex(self.FImagePlus, ColorCfg.WeakenImg)
        -- self:PlayAnimation(self.AnimNumSubtractLight)
    end
    local PlusSymbol = NewChangePoint > 0 and  "+" or ""
    self.TextPlus:SetText(string.format("%s%d", PlusSymbol, NewChangePoint))
end

function CardsBigCardItemView:OnBGFramgeStateChange(NewValue, OldValue)
    UIUtil.SetIsVisible(self.ImgFrameBlue, NewValue == LocalDef.BGFrameState.BlueState)
    local _showYellow = LocalDef.BGFrameState.YellowState or self.IsSelected
    UIUtil.SetIsVisible(self.ImgFrameYellow, NewValue == _showYellow)
end

function CardsBigCardItemView:OnMouseButtonDown(InGeo, InMouseEvent)
    local _selfModel = self.ViewModel
    if (_selfModel == nil) then
        return Unhandled
    end

    if (not _selfModel:CanClick()) then
        FLOG_INFO("[CardsBigCardItemView] CanClick Failed")
        return Unhandled
    end

    if (not _selfModel:HandleCardClicked()) then
        -- 如果没有点击成功，那么取消一切拖拽相关的
        self.IsCheckingDrag = false
        self.IsDragDetected = false
        FLOG_INFO("[CardsBigCardItemView] HandleCardClicked Failed")
        return Unhandled
    end

    if _selfModel:CanDrag() then
        self.IsCheckingDrag = true
        self.IsDragDetected = false
        self.DragStartPos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    else
        FLOG_INFO("[CardsBigCardItemView] CanDrag Failed")
        self.IsCheckingDrag = false
        self.IsDragDetected = false
        return Unhandled
    end

    return Handled
end

function CardsBigCardItemView:OnMouseLeave(MouseEvent)
    local _selfVM = self.ViewModel
    if (_selfVM == nil) then
        return
    end
    _selfVM:HandleOnMouseLeave()
end

function CardsBigCardItemView:OnMouseButtonUp(InGeo, InMouseEvent)
    local _selfModel = self.ViewModel
    if (_selfModel == nil) then
        return
    end

    _selfModel:HandelMouseUp()

    if self.IsDragDetected then
        return false
    else
        -- 松开鼠标，这里取消选择
        self.IsCheckingDrag = false
        return true
    end
end

function CardsBigCardItemView:OnMouseMove(InGeo, InMouseEvent)
    if not self.IsCheckingDrag then
        return false
    end

    if not self.ViewModel then
        return false
    end

    local AbsMousePos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    if UEMath.Distance2D(self.DragStartPos, AbsMousePos) >= MouseButtonCfg.DistanceToTriggerDrag then
        self.IsCheckingDrag = false
        if UKismetInputLibrary.Key_IsValid(UKismetInputLibrary.PointerEvent_GetEffectingButton(InMouseEvent)) then
            self.DragOffset = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeo, AbsMousePos)
            return UE.UWidgetBlueprintLibrary.DetectDragIfPressed(InMouseEvent, self, UE.FKey("LeftMouseButton"))
        else
            self.IsCheckingDrag = true
            self.IsDragDetected = false
        end
    end
    return false
end

---@param Operation MagicCardItemDragDropOperation @[out]
function CardsBigCardItemView:OnDragDetected(MyGeometry, PointerEvent, Operation)
    local DragVm = self.ViewModel:GetDragVisualCardVM()
    if (DragVm == nil) then
        return
    end

    self.IsDragDetected = true

    Operation = _G.NewObject(UE.UDragDropOperation, self, nil, "Game/MagicCard/Module/MagicCardItemDragDropOperation")
    Operation.DragOffset = self.DragOffset
    Operation.WidgetReference = self
    Operation.Pivot = UE.EDragPivot.CenterCenter
    local DragItemView = self.ViewModel:GetDragVisualCardItemView()
    DragItemView:HideView()
    local _scale = self.ViewModel:GetDragVisualCardScale()
    local _cardType = DragVm.CardItemType
    if (_cardType == CardTypeEnum.DragVisualEdit or _cardType == CardTypeEnum.DragVisual) then
        DragItemView:SetRenderScale(UE.FVector2D(_scale, _scale))
    end
    DragVm:CopyFromOther(self.ViewModel)
    DragItemView:ShowView(
        {
            Data = DragVm
        }
    )

    Operation.DefaultDragVisual = DragItemView

    self.ViewModel:OnDragDetected()

    return Operation
end

---@param Operation MagicCardItemDragDropOperation
function CardsBigCardItemView:OnDragCancelled(PointerEvent, Operation)
    if (Operation == nil) then
        _G.FLOG_ERROR("CardsBigCardItemView:OnDragCancelled 错误，传入的 Operation 为空，请检查")
        return
    end
    local DraggedCardVm = Operation.WidgetReference.ViewModel
    DraggedCardVm:OnDragCancelled()
    if (Operation.SetDragEnterCard ~= nil) then
        Operation:SetDragEnterCard()
    else
        _G.FLOG_ERROR("CardsBigCardItemView:OnDragCancelled 错误， Operation.SetDragEnterCard 为空，请检查")
    end
end

---@param Operation MagicCardItemDragDropOperation
---@return boolean
function CardsBigCardItemView:OnDrop(MyGeometry, PointerEvent, Operation)
    local selfVM = self.ViewModel
    if selfVM then
        return selfVM:OnDrop(Operation.WidgetReference.ViewModel)
    end
    return false
end

---@param Operation MagicCardItemDragDropOperation
function CardsBigCardItemView:OnDragEnter(MyGeometry, PointerEvent, Operation)
    local selfVM = self.ViewModel
    if selfVM and selfVM:CanDragEnter(Operation.WidgetReference.ViewModel) then
        selfVM:OnDragEnter()
    end
end

function CardsBigCardItemView:OnDragLeave(PointerEvent, Operation)
    local selfVM = self.ViewModel
    if selfVM then
        selfVM:OnDragLeave()
    end
end

function CardsBigCardItemView:OnDestroy()

end

function CardsBigCardItemView:OnShow()
    -- UIUtil.SetIsVisible(self.ImgBack, false) 这里不要，因为在register里面已经设置过了
    -- UIUtil.SetIsVisible(self.CardDisable, false) 这里不要，因为在register里面已经设置过了
    UIUtil.SetIsVisible(self.TextNameOnTop, false)
    UIUtil.SetIsVisible(self.TextNameBottom, false)
    self:SetVisible(true, true)
    --UIUtil.SetIsVisible(self, true, true)
    -- UIUtil.SetIsVisible(self.ImgCardBGRedForGame, not self.ViewModel.IsPlayerCard)
    -- UIUtil.SetIsVisible(self.ImgCardBGBlueForGame, self.ViewModel.IsPlayerCard)
end

function CardsBigCardItemView:OnHide()

end

function CardsBigCardItemView:OnRegisterUIEvent()

end

function CardsBigCardItemView:OnRegisterGameEvent()
    
end

function CardsBigCardItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end
    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self.ViewModel = ViewModel
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function CardsBigCardItemView:OnCardIDChanged(NewCardId, OldCardId)
    if NewCardId == nil or NewCardId == 0 or not self.ViewModel.ShowCardRootPanel then
        UIUtil.SetIsVisible(self.PanelContent, false)
    else
        UIUtil.SetIsVisible(self.PanelContent, true)
        local ItemCfg = CardCfg:FindCfgByKey(NewCardId)
        if nil == ItemCfg then
            _G.FLOG_WARNING("CardDecksSlotItemView:OnCardIdChanged CardId error: [%d]", NewCardId)
            return
        end

        self.ViewModel.CardName = ItemCfg.Name

        if (self.TextCardName ~= nil) then
            self.TextCardName:SetText(ItemCfg.Name)
        end

        if (self.TextNameOnTop ~= nil) then
            self.TextNameOnTop:SetText(ItemCfg.Name)
        end
        if (self.TextNameBottom ~= nil) then
            self.TextNameBottom:SetText(ItemCfg.Name)
        end

        -- 这里要处理一下大赛，会直接削弱数值,仅针对本地玩家幻卡
        -- 上限是A，下限是1，直接改
        local _tournamentWeaken = self.ViewModel.IsPlayerCard and self.ViewModel.TournamentWeaken or 0
        if (_tournamentWeaken ~= nil and _tournamentWeaken ~= 0) then
            local _upValue = AddValueWithTournamentWeaken(ItemCfg.Up, _tournamentWeaken)
            local _downValue = AddValueWithTournamentWeaken(ItemCfg.Down, _tournamentWeaken)
            local _leftValue = AddValueWithTournamentWeaken(ItemCfg.Left, _tournamentWeaken)
            local _rightValue = AddValueWithTournamentWeaken(ItemCfg.Right, _tournamentWeaken)

            --self.CardsNumber:SetNumbes(_upValue, _downValue, _leftValue, _rightValue)
        end
        self.CardsNumber:SetNumbes(ItemCfg.Up, ItemCfg.Down, ItemCfg.Left, ItemCfg.Right)

        if (ItemCfg.ShowImage == nil or ItemCfg.ShowImage == "") then
            UIUtil.SetIsVisible(self.ImgIcon, false)
        else
            UIUtil.SetIsVisible(self.ImgIcon, true)
            UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemCfg.ShowImage)
        end

        local StarCfg = CardStarCfg:FindCfgByKey(ItemCfg.Star)
        if StarCfg ~= nil then
            UIUtil.ImageSetBrushFromAssetPath(self.ImgStar, StarCfg.StarImage)
        end

        if ItemCfg.Race == 0 then
            UIUtil.SetIsVisible(self.ImgRace, false)
        else
            local RaceCfg = CardRaceCfg:FindCfgByKey(ItemCfg.Race)
            if RaceCfg ~= nil then
                UIUtil.SetIsVisible(self.ImgRace, true)
                UIUtil.ImageSetBrushFromAssetPath(self.ImgRace, RaceCfg.RaceImage)
            end
        end

        if (ItemCfg.FrameType == 0) then
            UIUtil.SetIsVisible(self.ImgFrame, true)
            UIUtil.SetIsVisible(self.ImgFrame_Silver, false)
        elseif (ItemCfg.FrameType == 1) then
            UIUtil.SetIsVisible(self.ImgFrame, false)
            UIUtil.SetIsVisible(self.ImgFrame_Silver, true)
        else
            UIUtil.SetIsVisible(self.ImgFrame, true)
            UIUtil.SetIsVisible(self.ImgFrame_Silver, false)
            FLOG_ERROR("未确认的边框类型：" .. ItemCfg.FrameType)
        end
    end
end

function CardsBigCardItemView:PlayAnimHandGlow()
    self:PlayAnimation(self.AnimChangeofhandGlow, 0, 1,nil, 1.0, false) --轮到当前方出牌时的手牌动效
end

---@param RuleId
function CardsBigCardItemView:SetAsTriggerCard(ConnectEffects, RuleId)
    UIUtil.SetIsVisible(self.EFF_Connect_Up, ConnectEffects.UP)
    UIUtil.SetIsVisible(self.EFF_Connect_Down, ConnectEffects.DOWN)
    UIUtil.SetIsVisible(self.EFF_Connect_Right, ConnectEffects.RIGHT)
    UIUtil.SetIsVisible(self.EFF_Connect_Left, ConnectEffects.LEFT)

    self:PlayAnimation(self.AnimBackLight)
    self:PlayAnimation(self.AnimDarkGrid)
    self:PlayAnimation(self.AnimConnectLight)
    if RuleId == RuleDef.FANTASY_CARD_RULE_ADD_CALC then
        -- 加算：“下的牌”放AnimOutlineGlow
        self:PlayAnimation(self.AnimOutlineGlow)
    end
end

---@param Card OneFlippedCard
function CardsBigCardItemView:SetAsSpecialFlippedCard(Card)
    self:PlayAnimation(self.AnimBackLight)
    self:PlayAnimation(self.AnimDarkGrid)
    if Card.FlipType > 0 then
        -- “异色牌”放AnimShake
        self:PlayAnimation(self.AnimShake)
    end

    if Card.RuleId == RuleDef.FANTASY_CARD_RULE_ADD_CALC and Card.FlipType == 0 then
        -- 加算：“同色牌”放AnimOutlineGlow
        self:PlayAnimation(self.AnimOutlineGlow)
    end

    if Card.RuleId == RuleDef.FANTASY_CARD_RULE_FOLLOW_UP and Card.FlipType > 0 then
        -- 连携：“异色牌”放AnimOutlineGlow
        self:PlayAnimation(self.AnimOutlineGlow)
    end
end

function CardsBigCardItemView:OnAnimationFinished(Anim)
    local ItemData = self.ViewModel
    if not ItemData then
        return
    end

    if Anim == self.PlayerExchange or Anim == self.EnemyExchange then
        if ItemData.ExchangedCardId ~= 0 then
            ItemData.CardId = ItemData.ExchangedCardId
            self:PlayAnimation(Anim, 0, 1, UE.EUMGSequencePlayMode.Reverse)
            ItemData.ExchangedCardId = 0
        end
    elseif Anim == self.FlipAnimLeftRight or Anim == self.FlipAnimUpDown then
        if ItemData then
            ItemData:OnFlipAnimEnd()
        end
    end
end

function CardsBigCardItemView:PlayEffectForSpecialRule()
    self:PlayAnimation(self.AnimExpandLight)
end

return CardsBigCardItemView
