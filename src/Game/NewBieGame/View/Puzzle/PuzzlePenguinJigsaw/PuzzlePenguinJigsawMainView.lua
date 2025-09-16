---
--- Author: Administrator
--- DateTime: 2024-08-02 09:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PuzzleGameFirstCfg = require("TableCfg/PuzzleGameFirstCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local MainPanelVM = require("Game/Main/MainPanelVM")
local PuzzleBurritosVM = require("Game/NewBieGame/Puzzle/PuzzleBurritos/PuzzleBurritosVM")
local PuzzleMgr = require("Game/NewBieGame/Puzzle/PuzzleMgr")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local PuzzleDirectoryCfg = require("TableCfg/PuzzleDirectoryCfg")
local FateDefine = require("Game/Fate/FateDefine")

local LSTR = _G.LSTR
local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary
local MaxMoveItemCount = 6 -- 最大的碎片数量 6个
local MaxFragmentCount = 9 -- 碎片最大数量 9个

local MoveStr = "MoveBread%02d"
local DestStr = "ImgYesBread%02d"
local PuzzleFateID = 2003

---@class PuzzlePenguinJigsawMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo CommInforBtnView
---@field CloseBtn CommonCloseBtnView
---@field FateStageInfoPanelNew_UIBP FateStageInfoPanelNewView
---@field HorizontalTime UFHorizontalBox
---@field ImgIcon UFImage
---@field ImgLightWrong UFImage
---@field ImgLightYes UFImage
---@field ImgPuzzleFinishBG UFImage
---@field ImgYesBread01 UFImage
---@field ImgYesBread02 UFImage
---@field ImgYesBread03 UFImage
---@field ImgYesBread04 UFImage
---@field ImgYesBread05 UFImage
---@field ImgYesBread06 UFImage
---@field ImgYesBread07 UFImage
---@field ImgYesBread08 UFImage
---@field ImgYesBread09 UFImage
---@field MoveBread01 PuzzlePenguinJigsawMoveItemView
---@field MoveBread02 PuzzlePenguinJigsawMoveItemView
---@field MoveBread03 PuzzlePenguinJigsawMoveItemView
---@field MoveBread04 PuzzlePenguinJigsawMoveItemView
---@field MoveBread05 PuzzlePenguinJigsawMoveItemView
---@field MoveBread06 PuzzlePenguinJigsawMoveItemView
---@field PanelDestination UFCanvasPanel
---@field PanelMove UFCanvasPanel
---@field PanelMoveBread UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field TextDescribe UFTextBlock
---@field TextGameName UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field TextTipsTimeout UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimCorrect1 UWidgetAnimation
---@field AnimCorrect2 UWidgetAnimation
---@field AnimCorrect3 UWidgetAnimation
---@field AnimCorrect4 UWidgetAnimation
---@field AnimCorrect5 UWidgetAnimation
---@field AnimCorrect6 UWidgetAnimation
---@field AnimCorrect7 UWidgetAnimation
---@field AnimCorrect8 UWidgetAnimation
---@field AnimCorrect9 UWidgetAnimation
---@field AnimFinish UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimNotice01 UWidgetAnimation
---@field AnimNotice02 UWidgetAnimation
---@field AnimNotice03 UWidgetAnimation
---@field AnimNotice04 UWidgetAnimation
---@field AnimNotice05 UWidgetAnimation
---@field AnimNotice06 UWidgetAnimation
---@field AnimNotice07 UWidgetAnimation
---@field AnimNotice08 UWidgetAnimation
---@field AnimNotice09 UWidgetAnimation
---@field AnimTimeOut UWidgetAnimation
---@field AnimWrong UWidgetAnimation
---@field VarAnimPuzzleWidget PuzzleBurritosMoveBreadItem_UIBP_C
---@field VarAnimOffsetX float
---@field VarAnimOffsetY float
---@field VarAnimOffsetRotation float
---@field VarAnimPlayPercent float
---@field VarAnimCurve CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PuzzlePenguinJigsawMainView = LuaClass(UIView, true)

function PuzzlePenguinJigsawMainView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.CloseBtn = nil
	--self.FateStageInfoPanelNew_UIBP = nil
	--self.HorizontalTime = nil
	--self.ImgIcon = nil
	--self.ImgLightWrong = nil
	--self.ImgLightYes = nil
	--self.ImgPuzzleFinishBG = nil
	--self.ImgYesBread01 = nil
	--self.ImgYesBread02 = nil
	--self.ImgYesBread03 = nil
	--self.ImgYesBread04 = nil
	--self.ImgYesBread05 = nil
	--self.ImgYesBread06 = nil
	--self.ImgYesBread07 = nil
	--self.ImgYesBread08 = nil
	--self.ImgYesBread09 = nil
	--self.MoveBread01 = nil
	--self.MoveBread02 = nil
	--self.MoveBread03 = nil
	--self.MoveBread04 = nil
	--self.MoveBread05 = nil
	--self.MoveBread06 = nil
	--self.PanelDestination = nil
	--self.PanelMove = nil
	--self.PanelMoveBread = nil
	--self.PanelTips = nil
	--self.TextDescribe = nil
	--self.TextGameName = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTipsTimeout = nil
	--self.TextTitle = nil
	--self.AnimCorrect1 = nil
	--self.AnimCorrect2 = nil
	--self.AnimCorrect3 = nil
	--self.AnimCorrect4 = nil
	--self.AnimCorrect5 = nil
	--self.AnimCorrect6 = nil
	--self.AnimCorrect7 = nil
	--self.AnimCorrect8 = nil
	--self.AnimCorrect9 = nil
	--self.AnimFinish = nil
	--self.AnimIn = nil
	--self.AnimNotice01 = nil
	--self.AnimNotice02 = nil
	--self.AnimNotice03 = nil
	--self.AnimNotice04 = nil
	--self.AnimNotice05 = nil
	--self.AnimNotice06 = nil
	--self.AnimNotice07 = nil
	--self.AnimNotice08 = nil
	--self.AnimNotice09 = nil
	--self.AnimTimeOut = nil
	--self.AnimWrong = nil
	--self.VarAnimPuzzleWidget = nil
	--self.VarAnimOffsetX = nil
	--self.VarAnimOffsetY = nil
	--self.VarAnimOffsetRotation = nil
	--self.VarAnimPlayPercent = nil
	--self.VarAnimCurve = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PuzzlePenguinJigsawMainView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.FateStageInfoPanelNew_UIBP)
	self:AddSubView(self.MoveBread01)
	self:AddSubView(self.MoveBread02)
	self:AddSubView(self.MoveBread03)
	self:AddSubView(self.MoveBread04)
	self:AddSubView(self.MoveBread05)
	self:AddSubView(self.MoveBread06)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PuzzlePenguinJigsawMainView:OnInit()
    self.Binders = {
        {"PuzzleBurritosTime", UIBinderSetText.New(self, self.FateStageInfoPanelNew_UIBP.TextTime)},
        {"Progress", UIBinderSetPercent.New(self, self.FateStageInfoPanelNew_UIBP.ProBar)},
        {"bMoveBread01Visible", UIBinderSetIsVisible.New(self, self.MoveBread01)},
        {"bMoveBread02Visible", UIBinderSetIsVisible.New(self, self.MoveBread02)},
        {"bMoveBread03Visible", UIBinderSetIsVisible.New(self, self.MoveBread03)},
        {"bMoveBread04Visible", UIBinderSetIsVisible.New(self, self.MoveBread04)},
        {"bMoveBread05Visible", UIBinderSetIsVisible.New(self, self.MoveBread05)},
        {"bMoveBread06Visible", UIBinderSetIsVisible.New(self, self.MoveBread06)},
        {"bYesBread01Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread01)},
        {"bYesBread02Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread02)},
        {"bYesBread03Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread03)},
        {"bYesBread04Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread04)},
        {"bYesBread05Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread05)},
        {"bYesBread06Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread06)},
        {"bYesBread07Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread07)},
        {"bYesBread08Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread08)},
        {"bYesBread09Visible", UIBinderSetIsVisible.New(self, self.ImgYesBread09)}
    }

    self.MoveItemTable = {}
    do
        for Index = 1, MaxMoveItemCount do
            local FinalName = string.format(MoveStr, Index)
            self.MoveItemTable[Index] = self[FinalName]
            if (self.MoveItemTable[Index] == nil) then
                _G.FLOG_ERROR("错误， %s ，无法无法找到节点，请检查")
            end
        end
    end

    self.FinishDestItemTable = {}
    do
        -- body
        for Index = 1, MaxFragmentCount do
            local FinalName = string.format(DestStr, Index)
            self.FinishDestItemTable[Index] = self[FinalName]
            if (self.FinishDestItemTable[Index] == nil) then
                _G.FLOG_ERROR("错误， %s ，无法无法找到节点，请检查")
            end
        end
    end

    self.DragVisualItem = nil -- 拖动的 UMG

    local function CloseBtnCallback()
        MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            LSTR(10004),
            LSTR(280001),
            function()
                self:Hide()
            end,
            nil,
            LSTR(10003),
            LSTR(10002)
        )
        self:CheckHideHelpTip()
    end
    self.CloseBtn:SetCallback(self, CloseBtnCallback)
end

function PuzzlePenguinJigsawMainView:OnCountdownTimeChanged(NewValue, OldValue)
end

function PuzzlePenguinJigsawMainView:GetDragVisualItem()
    if (self.DragVisualItem == nil) then
        self.DragVisualItem = _G.UIViewMgr:CreateView(_G.UIViewID.PuzzlePenguinJigsawMoveItemView, self, true)
    end
    self.DragVisualItem:BeginHighLight()
    return self.DragVisualItem
end

function PuzzlePenguinJigsawMainView:OnDestroy()
end

function PuzzlePenguinJigsawMainView:OnShow()
    self.FateStageInfoPanelNew_UIBP:SetNeedVM(false)
    self.bSuccess = false
    self.InteractNpcEntityID = 0

    self:InitNameAndDesc()
    self.bMainPanelChatInfoVisible = MainPanelVM.ChatInfoVisible
    local GameInst = PuzzleMgr:GetGameInst()
    if GameInst == nil then
        return
    end

    UIUtil.SetIsVisible(self.FateStageInfoPanelNew_UIBP.BtnFold, false)
    UIUtil.SetIsVisible(self.FateStageInfoPanelNew_UIBP.PanelFateArchive, false)
    UIUtil.SetIsVisible(self.FateStageInfoPanelNew_UIBP.TextLevel, false)
    UIUtil.SetIsVisible(self.FateStageInfoPanelNew_UIBP.BtnJoinIn, false)
    UIUtil.SetIsVisible(self.FateStageInfoPanelNew_UIBP.BtnHighrisk, false)
    local IconPath = FateDefine.GetIconByFateID(PuzzleFateID)
    UIUtil.ImageSetBrushFromAssetPath(self.FateStageInfoPanelNew_UIBP.ImgFateType, IconPath)

    local FateCfg = _G.FateMgr:GetFateCfg(PuzzleFateID) -- 拼图的表格数据
    if (FateCfg == nil) then
        self.FateStageInfoPanelNew_UIBP.CommTextSlide:ShowSliderText(LSTR(190122))
    else
        self.FateStageInfoPanelNew_UIBP.CommTextSlide:ShowSliderText(FateCfg.Name)
    end

    self.FateStageInfoPanelNew_UIBP.CommTextSlide:ResetTextScrollSlide()

    self.FateStageInfoPanelNew_UIBP.TextProgress:SetText(LSTR(190127))

    GameInst:SetMainView(self)
    self:ResetSomeToNeedState()
    self:OnReady()
    self:InitData()
    self:InitItems()
    self.InteractNpcEntityID = _G.InteractiveMgr.CurInteractEntityID

    local GameCfg = GameInst.GameCfg
    if (GameCfg ~= nil) then
        -- 替换背景图片
        UIUtil.ImageSetBrushFromAssetPath(self.ImgPuzzleFinishBG, GameCfg.PuzzleBGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgLightWrong, GameCfg.PuzzleWrongBGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgLightYes, GameCfg.PuzzleYesBGPath)

        local OffsetPos = _G.UE.FVector2D(GameCfg.BGOffset[1],GameCfg.BGOffset[2])
        UIUtil.CanvasSlotSetPosition(self.ImgPuzzleFinishBG, OffsetPos)
        UIUtil.CanvasSlotSetPosition(self.ImgLightWrong, OffsetPos)
        UIUtil.CanvasSlotSetPosition(self.ImgLightYes, OffsetPos)
    end
end

function PuzzlePenguinJigsawMainView:InitNameAndDesc()
	local Cfg = PuzzleDirectoryCfg:FindCfgByKey(PuzzleMgr.CurGameID)
	local Name = LSTR(190122) -- 趣味拼图
	local Desc = LSTR(190123) -- 企鹅趣味拼图的描述文字
	if Cfg ~= nil then
		local ItemID = Cfg.RelateItemID
		if ItemID ~= 0 then
			local ICfg = ItemCfg:FindCfgByKey(ItemID)
			if ICfg then
				Name = ICfg.ItemName ~= "" and ICfg.ItemName or Name
				Desc = ICfg.ItemDesc ~= "" and ICfg.ItemDesc or Name
			end
		end
	end
    self.TextTitle:SetText(Name) -- 趣味拼图
    self.TextDescribe:SetText(Desc) -- 企鹅趣味拼图的描述文字
end

function PuzzlePenguinJigsawMainView:OnHide()
    PuzzleMgr:OnEnd()
    PuzzleBurritosVM:OnEnd()

    if (self.bSuccess) then
        local Panel = "PanelPositive"
        MsgTipsUtil.ShowInfoMissionTips(LSTR(190128), nil, Panel, nil)
    else
        local Panel = "PanelFail"
        MsgTipsUtil.ShowInfoMissionTips(LSTR(190129), nil, Panel, nil)
    end
end

function PuzzlePenguinJigsawMainView:OnRegisterUIEvent()
end

function PuzzlePenguinJigsawMainView:OnRegisterGameEvent()
end

function PuzzlePenguinJigsawMainView:OnRegisterBinder()
    self:RegisterBinders(PuzzleBurritosVM, self.Binders)
end

function PuzzlePenguinJigsawMainView:InitData()
    local Params = self.Params
    if Params == nil then
        return
    end

    local MinID = Params.PartIDList[1]
    local MaxID = Params.PartIDList[#Params.PartIDList]
    local AllCfg = PuzzleGameFirstCfg:FindAllCfg(string.format("ID <= %d AND ID >= %d ", MaxID, MinID))
    if AllCfg == nil then
        return
    end

    -- 记录初始化数据
    do
        self.OriginMoveItemDataTable = {}
        local TmpIndex = 0
        for Key, Value in pairs(AllCfg) do
            TmpIndex = TmpIndex + 1

            -- 表格数据
            self.OriginMoveItemDataTable[TmpIndex] = {}
            self.OriginMoveItemDataTable[TmpIndex].Index = TmpIndex
            self.OriginMoveItemDataTable[TmpIndex].TableData = Value
            -- end

            -- 记录结束位置
            local TargetItem = self.FinishDestItemTable[TmpIndex]
            if (TargetItem == nil) then
                _G.FLOG_ERROR("错误，无法获取目标的结束位置,将关闭界面，出错的Index : %s", TmpIndex)
                self:Hide()
                return
            end
            local FinishLocation = UIUtil.CanvasSlotGetPosition(TargetItem)
            self.OriginMoveItemDataTable[TmpIndex].FinishLocation = FinishLocation
            -- end
        end
    end
    -- end

    -- 记录移动物体的初始化位置
    do
        self.OriginInitPosTable = {}

        for Index = 1, MaxMoveItemCount do
            -- body
            local TargetItem = self.MoveItemTable[Index]
            if (TargetItem == nil) then
                _G.FLOG_ERROR("错误，无法获取目标，将关闭界面，出错 index : %s", Index)
                self:Hide()
                return
            end

            local InitLocation = UIUtil.CanvasSlotGetPosition(TargetItem)
            self.OriginInitPosTable[Index] = InitLocation
        end
    end
    -- end
end

--- @type 初始化拼图碎片，随机图片，和已结束图片
function PuzzlePenguinJigsawMainView:InitItems()
    if (self.OriginMoveItemDataTable == nil or #self.OriginMoveItemDataTable < 1) then
        _G.FLOG_ERROR("错误，移动物品的原始表格数据为空，请检查")
        return
    end
    local Params = self.Params
    if Params == nil then
        _G.FLOG_ERROR("初始化出错，没有表格数据，请检查")
        return
    end

    for Index = 1, #self.OriginMoveItemDataTable do
        -- body
        local PuzzleItem = self.FinishDestItemTable[Index]
        local TableData = self.OriginMoveItemDataTable[Index].TableData
        AssetPath = TableData.AssetPath
        UIUtil.ImageSetBrushFromAssetPath(PuzzleItem, AssetPath)
    end

    table.shuffle(self.OriginMoveItemDataTable) -- 这里直接用原始数据随机一下顺序，取后3个作为显示的

    -- 前面6个作为需要移动的拼图
    for Index = 1, MaxMoveItemCount do
        local PuzzleItem = self.MoveItemTable[Index]
        local TableData = self.OriginMoveItemDataTable[Index].TableData
        local TempRandom = math.random(1,2)
        local TargetAngle = 0
        if (TempRandom == 1) then
            TargetAngle = math.random(1, 8) * 20
        else
            TargetAngle = math.random(1, 8) * -20
        end
        local NewParams = {
            bNeedType = 1,
            InitLocation = self.OriginInitPosTable[Index],
            FinishLocation = self.OriginMoveItemDataTable[Index].FinishLocation or -1,
            AssetPath = TableData.AssetPath,
            ConfirmRange = Params.ConfirmRange,
            Angle = TableData.Angle,
            ID = self.OriginMoveItemDataTable[Index].Index,
            Index = Index,
            Angle = TargetAngle
        }
        PuzzleItem:Initlize(NewParams)
        PuzzleItem:EndHighLight()
        PuzzleItem:SetRenderTransformAngle(TargetAngle)
    end

    for Index = 1, MaxFragmentCount do
        UIUtil.SetIsVisible(self.FinishDestItemTable[Index], false)
    end

    for Index = MaxMoveItemCount + 1, MaxFragmentCount do
        local FinishItemIndex = self.OriginMoveItemDataTable[Index].Index
        PuzzleMgr:FinishOnePuzzleItem(FinishItemIndex)
    end
end

--- @type 初始化
function PuzzlePenguinJigsawMainView:ResetSomeToNeedState()
    local Params = self.Params
    if Params == nil then
        return
    end
    self.SelectMoveBread = nil
    self.bOpenClickDetect = false

    UIUtil.SetIsVisible(self.HorizontalTime, (Params.bShowRemainTime == 1 and not PuzzleMgr.bIsDebug))
end

function PuzzlePenguinJigsawMainView:OnMouseButtonDown(InGeo, InMouseEvent)
    local GameInst = PuzzleMgr:GetGameInst()
    if GameInst == nil then
        return false
    end

    if GameInst:GetbAutoPuzzleInEnd() then
        return false
    end
    FLOG_INFO("PuzzlePenguinJigsawMainView OnMouseButtonDown")

    if not self.bOpenClickDetect then
        return false
    end
    if GameInst.bIsDraging then --如果点击到拼图碎片
        return false
    end
    -- if self.SelectMoveBread == nil then
    -- 	return
    -- end

    self.bOpenClickDetect = false
    local TouchPos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent) --UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())

    local LocalPos = UIUtil.AbsoluteToLocal(self.PanelMoveBread, TouchPos)
    local Size = UIUtil.GetLocalSize(self.SelectMoveBread)

    local NeedLocalPos = UE.FVector2D(LocalPos.X - Size.X / 2, LocalPos.Y - Size.Y / 2)

    if PuzzleMgr:bIsPuzzleRange(NeedLocalPos) then
        local bSuccess
        local SelectMoveBread = self.SelectMoveBread

        if self.SelectMoveBread:GetIsNeedType() then
            local DistanceToRightLoc =
                UE.FVector.Dist2D(
                UE.FVector(NeedLocalPos.X, NeedLocalPos.Y, 0),
                UE.FVector(SelectMoveBread.FinishLocation.X, SelectMoveBread.FinishLocation.Y, 0)
            )
            if DistanceToRightLoc <= SelectMoveBread.ConfirmRange then
                bSuccess = true
            else
                bSuccess = false
            end
            SelectMoveBread.bFinish = bSuccess
        else
            bSuccess = false
        end
        GameInst:SetbAutoMove(true)
        local MoveToTargetOp = PuzzleDefine.MoveToTargetOp
        PuzzleMgr:AutoMoveToTargetLoc(SelectMoveBread, NeedLocalPos, bSuccess, MoveToTargetOp.ByMouseClickAutoMove)
    else
        self:ResetSelectBread(true)
    end

    return true
end

function PuzzlePenguinJigsawMainView:OnDrop(MyGeometry, PointerEvent, Operation)
    return false
end

--- @type 更新被选择的碎片
function PuzzlePenguinJigsawMainView:UpdateSelectBread(PuzzleItem)
    self.SelectMoveBread = PuzzleItem
    if self.SelectMoveBread then
        self.SelectMoveBread:BeginHighLight()

        if PuzzleMgr.bIsDebug then
            MsgTipsUtil.ShowTips(string.format("你已经选择了ID = %s的拼图碎片", PuzzleItem.ID))
        end
    end
end

--- @type 重置选择的碎片
function PuzzlePenguinJigsawMainView:ResetSelectBread(bShowDebugTip, bEndHighLight)
    if self.SelectMoveBread ~= nil then
        self.SelectMoveBread:EndHighLight()
        self.SelectMoveBread = nil
    end
    self.bOpenClickDetect = false

    if PuzzleMgr.bIsDebug and bShowDebugTip then
        MsgTipsUtil.ShowTips("你已经取消了选择")
    end
end

--- 动画结束统一回调
function PuzzlePenguinJigsawMainView:OnAnimationFinished(Animation)
end

function PuzzlePenguinJigsawMainView:OnReady()
    UIUtil.SetIsVisible(self.PanelTips, true)
    self.TextTips:SetText(LSTR(250021)) -- 准备

    UIUtil.SetIsVisible(self.ImgLightYes, false)
    UIUtil.SetIsVisible(self.ImgLightWrong, false)

    PuzzleMgr:UpdateShadowVisible(-1)
    self:OnBegin()
end

function PuzzlePenguinJigsawMainView:SequenceEvent_Start()
    self.TextTips:SetText(LSTR(250022)) -- 开始
end

function PuzzlePenguinJigsawMainView:OnBegin()
    local Params = self.Params
    if Params == nil then
        return
    end
    UIUtil.SetIsVisible(self.PanelTips, false)
    PuzzleMgr:BeginCountDown()
end

--- @type 拼完一块图片出现正确or错误表现
function PuzzlePenguinJigsawMainView:OnCheckPuzzleItemFinish(bSuccess)
    local NeedImg, bYesVisible, bWrongVisible
    if bSuccess then
        -- 播放正确动效
        NeedImg = self.ImgLightYes
        bYesVisible = true
        bWrongVisible = false
    else
        -- 播放错误动效
        NeedImg = self.ImgLightWrong
        bWrongVisible = true
        bYesVisible = false
        self:PlayAnimWrong()
    end

    UIUtil.SetIsVisible(self.ImgLightWrong, bWrongVisible)
    UIUtil.SetIsVisible(self.ImgLightYes, bYesVisible)
    self:RegisterTimer(
        function()
            UIUtil.SetIsVisible(NeedImg, false)
        end,
        1.5
    )
end

--- @type 时间结束
function PuzzlePenguinJigsawMainView:OnTimeOut(InbNotForceCancelDrag)
    if (InbNotForceCancelDrag ~= true) then
        -- 取消所有的拖动效果
        _G.UE.UWidgetBlueprintLibrary.CancelDragDrop()
    end
    

    self:OnFinish(true)
end

--- @type 当完成时 包括拼装成功和时间结束自动拼装
function PuzzlePenguinJigsawMainView:OnFinish(bTimeOut)
    -- 这里播放一下，根据是成功还是失败
    self.bSuccess = PuzzleMgr.PuzzleGameInst.bSuccess
    _G.FateMgr:SendFateEndPuzzleReq(self.InteractNpcEntityID, self.bSuccess)
    if bTimeOut then
        -- 超时了
        PuzzleMgr:GameEnd(PuzzleDefine.EndType.TimeOutEnd)
        self.TextTips:SetText(LSTR(280008)) -- 超时失败
        UIUtil.SetIsVisible(self.PanelTips, true)
        self:PlayAnimation(self.AnimTimeOut)
        self:RegisterTimer(
            function()
                UIUtil.SetIsVisible(self.PanelTips, false)
                self:Hide()
            end,
            self.AnimTimeOut:GetEndTime()
        )
    else
        -- 手动成功
        PuzzleMgr:GameEnd(PuzzleDefine.EndType.SuccessEnd)
        local DelayHide = self.AnimFinish:GetEndTime()
        self:SetFinishText()
        UIUtil.SetIsVisible(self.PanelTips, true)
        self.TextTips:SetText(LSTR(270008)) -- 成功

        self:PlayAnimation(self.AnimFinish)
        self:RegisterTimer(
            function()
                UIUtil.SetIsVisible(self.PanelTips, false)
            end,
            1.5
        )

        local function GameEnd()
            self:CheckHideHelpTip()
            self:Hide()
        end

        self:RegisterTimer(GameEnd, DelayHide)
    end
end

--- @type 设置一下结束时的某些相关的Text 0.0
function PuzzlePenguinJigsawMainView:SetFinishText()
    local Params = self.Params
    if nil == Params then
        return
    end
    local RelateItemID = Params.RelateItemID
    local Name = ItemCfg:GetItemName(RelateItemID)
    if nil == Name then
        return
    end
end

--- @type 播放错误动画
function PuzzlePenguinJigsawMainView:PlayAnimWrong()
    self:PlayAnimation(self.AnimWrong)
end

--- @type 出现提示
function PuzzlePenguinJigsawMainView:ShowHelpTip()
    local ID = PuzzleMgr:GetOneNotFinishPuzzleItemID()
    if ID == nil then
        return
    end
    local GameInst = PuzzleMgr:GetGameInst()
    if GameInst == nil then
        return
    end

    local MoveItem = nil
    for Key, Value in pairs(self.MoveItemTable) do
        if (Value.ID == ID) then
            MoveItem = Value
            break
        end
    end
    if MoveItem ~= nil then
        self.HelpShowMoveItem = MoveItem
        MoveItem:BeginHighLight()

        PuzzleBurritosVM:SetYesBreadVisible(ID, true)
        local NeedAnim = self[string.format("AnimNotice%02d", ID)]

        if (NeedAnim ~= nil) then
            self:PlayAnimation(NeedAnim)
            self.EndHelpTipTimer = self:RegisterTimer(self.EndHelpTip, NeedAnim:GetEndTime())
        else
            self.EndHelpTipTimer = self:RegisterTimer(self.EndHelpTip, 1.5)
        end
    else
        _G.FLOG_ERROR("错误，无法获取目标 MoveItem，请检查")
    end

    GameInst:SetShowTipItemID(ID)
end

--- @type 结束提示
function PuzzlePenguinJigsawMainView:EndHelpTip()
    local GameInst = PuzzleMgr:GetGameInst()
    if GameInst == nil then
        return
    end
    if self.EndHelpTipTimer ~= nil then
        self:UnRegisterTimer(self.EndHelpTipTimer)
        self.EndHelpTipTimer = nil
    end

    if (self.HelpShowMoveItem == nil) then
        return
    end
    local ShowTipItemID = self.HelpShowMoveItem.ID
    GameInst:ResetShowTipItemID()
    PuzzleBurritosVM:SetYesBreadVisible(ShowTipItemID, false)
    -- 如果本來就是选中的情况，不要变暗
    if self.SelectMoveBread ~= nil and self.SelectMoveBread:GetID() ~= ShowTipItemID then
        self.HelpShowMoveItem:EndHighLight()
    end

    self.HelpShowMoveItem = nil
end

function PuzzlePenguinJigsawMainView:CheckHideHelpTip()
    if _G.UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTitleTipsView) then
        _G.UIViewMgr:HideView(UIViewID.CommHelpInfoTitleTipsView)
    end
end

function PuzzlePenguinJigsawMainView:GetSelectPuzzleItemData()
    local SelectMoveBread = self.SelectMoveBread
    if SelectMoveBread == nil then
        return
    end
    return UIUtil.CanvasSlotGetPosition(SelectMoveBread), SelectMoveBread.Angle
end

function PuzzlePenguinJigsawMainView:ChangeSelectPuzzleItemPosAndAngle(XOffset, YOffset, InAngle)
    local SelectMoveBread = self.SelectMoveBread
    if SelectMoveBread == nil then
        return
    end
    local CurPos = UIUtil.CanvasSlotGetPosition(SelectMoveBread)
    UIUtil.CanvasSlotSetPosition(SelectMoveBread, UE.FVector2D(CurPos.X + XOffset, CurPos.Y + YOffset))
    local Angle = SelectMoveBread.Angle
    local NewAngle = Angle + InAngle
    SelectMoveBread.Angle = NewAngle
    SelectMoveBread:SetRenderTransformAngle(NewAngle)
end

return PuzzlePenguinJigsawMainView
