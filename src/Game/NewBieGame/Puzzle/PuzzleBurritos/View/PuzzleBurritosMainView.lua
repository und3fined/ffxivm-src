---
--- Author: Administrator
--- DateTime: 2024-08-02 09:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PuzzleGameFirstCfg = require("TableCfg/PuzzleGameFirstCfg")
local PuzzleDirectoryCfg = require("TableCfg/PuzzleDirectoryCfg")
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
local AudioUtil = require("Utils/AudioUtil")
local AudioPath = PuzzleDefine.BurritoAudioPath
local LSTR = _G.LSTR
local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary

---@class PuzzleBurritosMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BottomPanel MainLBottomPanelView
---@field BtnInfo CommInforBtnView
---@field CloseBtn CommonCloseBtnView
---@field HorizontalTime UFHorizontalBox
---@field ImgBreadBG UFImage
---@field ImgIcon UFImage
---@field ImgLightWrong UFImage
---@field ImgLightYes UFImage
---@field ImgYesBread01 UFImage
---@field ImgYesBread02 UFImage
---@field ImgYesBread03 UFImage
---@field ImgYesBread04 UFImage
---@field MainTeamPanel MainTeamPanelView
---@field MoveBread01 PuzzleBurritosMoveBreadItemView
---@field MoveBread02 PuzzleBurritosMoveBreadItemView
---@field MoveBread03 PuzzleBurritosMoveBreadItemView
---@field MoveBread04 PuzzleBurritosMoveBreadItemView
---@field MoveBread05 PuzzleBurritosMoveBreadItemView
---@field MoveBread06 PuzzleBurritosMoveBreadItemView
---@field PanelMoveBread UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelYesBread UFCanvasPanel
---@field PuzzleGM PuzzleGMPanelView
---@field TextAutoMove UFTextBlock
---@field TextDescribe UFTextBlock
---@field TextGameName UFTextBlock
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimAutoFinish UWidgetAnimation
---@field AnimCorrect1 UWidgetAnimation
---@field AnimCorrect2 UWidgetAnimation
---@field AnimCorrect3 UWidgetAnimation
---@field AnimCorrect4 UWidgetAnimation
---@field AnimFinish UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimNotice1 UWidgetAnimation
---@field AnimNotice2 UWidgetAnimation
---@field AnimNotice3 UWidgetAnimation
---@field AnimNotice4 UWidgetAnimation
---@field AnimPaperShadow0 UWidgetAnimation
---@field AnimPaperShadow1 UWidgetAnimation
---@field AnimPaperShadow2 UWidgetAnimation
---@field AnimPaperShadow3 UWidgetAnimation
---@field AnimPaperShadow4 UWidgetAnimation
---@field AnimPuzzleRestore UWidgetAnimation
---@field AnimReady UWidgetAnimation
---@field AnimStart UWidgetAnimation
---@field AnimWrong UWidgetAnimation
---@field VarAnimPuzzleWidget PuzzleBurritosMoveBreadItem_UIBP_C
---@field VarAnimOffsetX float
---@field VarAnimOffsetY float
---@field VarAnimOffsetRotation float
---@field VarAnimPlayPercent float
---@field VarAnimCurve CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PuzzleBurritosMainView = LuaClass(UIView, true)

function PuzzleBurritosMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BottomPanel = nil
	--self.BtnInfo = nil
	--self.CloseBtn = nil
	--self.HorizontalTime = nil
	--self.ImgBreadBG = nil
	--self.ImgIcon = nil
	--self.ImgLightWrong = nil
	--self.ImgLightYes = nil
	--self.ImgYesBread01 = nil
	--self.ImgYesBread02 = nil
	--self.ImgYesBread03 = nil
	--self.ImgYesBread04 = nil
	--self.MainTeamPanel = nil
	--self.MoveBread01 = nil
	--self.MoveBread02 = nil
	--self.MoveBread03 = nil
	--self.MoveBread04 = nil
	--self.MoveBread05 = nil
	--self.MoveBread06 = nil
	--self.PanelMoveBread = nil
	--self.PanelTips = nil
	--self.PanelYesBread = nil
	--self.PuzzleGM = nil
	--self.TextAutoMove = nil
	--self.TextDescribe = nil
	--self.TextGameName = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimAutoFinish = nil
	--self.AnimCorrect1 = nil
	--self.AnimCorrect2 = nil
	--self.AnimCorrect3 = nil
	--self.AnimCorrect4 = nil
	--self.AnimFinish = nil
	--self.AnimIn = nil
	--self.AnimNotice1 = nil
	--self.AnimNotice2 = nil
	--self.AnimNotice3 = nil
	--self.AnimNotice4 = nil
	--self.AnimPaperShadow0 = nil
	--self.AnimPaperShadow1 = nil
	--self.AnimPaperShadow2 = nil
	--self.AnimPaperShadow3 = nil
	--self.AnimPaperShadow4 = nil
	--self.AnimPuzzleRestore = nil
	--self.AnimReady = nil
	--self.AnimStart = nil
	--self.AnimWrong = nil
	--self.VarAnimPuzzleWidget = nil
	--self.VarAnimOffsetX = nil
	--self.VarAnimOffsetY = nil
	--self.VarAnimOffsetRotation = nil
	--self.VarAnimPlayPercent = nil
	--self.VarAnimCurve = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PuzzleBurritosMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BottomPanel)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.MainTeamPanel)
	self:AddSubView(self.MoveBread01)
	self:AddSubView(self.MoveBread02)
	self:AddSubView(self.MoveBread03)
	self:AddSubView(self.MoveBread04)
	self:AddSubView(self.MoveBread05)
	self:AddSubView(self.MoveBread06)
	self:AddSubView(self.PuzzleGM)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PuzzleBurritosMainView:OnInit()
	self.Binders = {
		{"PuzzleBurritosTime", UIBinderSetText.New(self, self.TextTime)},
		-- {"bShadow1Visible", UIBinderSetIsVisible.New(self, self.ImgPaperShadow01)},
		-- {"bShadow2Visible", UIBinderSetIsVisible.New(self, self.ImgPaperShadow02)},
		-- {"bShadow3Visible", UIBinderSetIsVisible.New(self, self.ImgPaperShadow03)},
		-- {"bShadow4Visible", UIBinderSetIsVisible.New(self, self.ImgPaperShadow04)},
		-- {"bShadow5Visible", UIBinderSetIsVisible.New(self, self.ImgPaperShadow05)},

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

	}
	-- UIUtil.SetIsVisible(self.MainTeamPanel.MainQuestPanel.ScrollBox, true, false)
end

function PuzzleBurritosMainView:OnDestroy()

end

function PuzzleBurritosMainView:OnShow()
	UIUtil.SetIsVisible(self.CloseBtn, PuzzleMgr.bIsDebug)
	UIUtil.SetIsVisible(self.MainTeamPanel, false)

	self.bMainPanelChatInfoVisible = MainPanelVM.ChatInfoVisible
	local GameInst = PuzzleMgr:GetGameInst()
	if GameInst == nil then
		return
	end
	GameInst:SetMainView(self)
	self:ResetSomeToNeedState()
	self:OnReady()
	self:InitItems()
	self:InitLSTRText(GameInst)
end

function PuzzleBurritosMainView:InitLSTRText(GameInst)
	self:InitNameAndDesc(GameInst)
	self.TextAutoMove:SetText(LSTR(280006)) -- 自动拼回中...
	self.TextGameName:SetText(LSTR(280007)) -- 拼图游戏
end

function PuzzleBurritosMainView:InitNameAndDesc(GameInst)
	local Cfg = PuzzleDirectoryCfg:FindCfgByKey(GameInst.GameCfg.ID)
	local Name = LSTR(280005) -- 黄昏卷饼
	local Desc = LSTR(280002) -- 沙漠之民的传统盐味面包,\n形状像一个心形结扣
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
	self.TextTitle:SetText(Name)
	self.TextDescribe:SetText(Desc)
end

function PuzzleBurritosMainView:OnHide()
	self:UnRegisterAllTimer()
	
	PuzzleMgr:OnEnd()
	PuzzleBurritosVM:OnEnd()

	-- UIUtil.SetInputMode_GameAndUI()
end

function PuzzleBurritosMainView:OnRegisterUIEvent()

end

function PuzzleBurritosMainView:OnRegisterGameEvent()

end

function PuzzleBurritosMainView:OnRegisterBinder()
    self:RegisterBinders(PuzzleBurritosVM, self.Binders)

	local function CloseBtnCallback()				-- 提示		  --现在退出将无法保存拼装进度, 确认退出吗？				-- 取 消	     确认
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(280001), function() self:Hide() end, nil, LSTR(10003), LSTR(10002))
		self:CheckHideHelpTip()
	end
	self.CloseBtn:SetCallback(self, CloseBtnCallback)
end	

--- @type 初始化零散的拼图Item
function PuzzleBurritosMainView:InitItems()
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

	for i, v in ipairs(AllCfg) do
		local Cfg = v
		if Cfg == nil then
			FLOG_ERROR("PuzzleGameFirstCfg = NIL")
			return
		end
		local FinishLocation
		local YesItemNameIndex = string.format("ImgYesBread0%d", i)
		if i <= 4 and #Cfg.FinishLocation <= 1 then
			FinishLocation = UIUtil.CanvasSlotGetPosition(self[string.format(YesItemNameIndex, i)])
		else
			FinishLocation = UE.FVector2D(Cfg.FinishLocation[1], Cfg.FinishLocation[2])
		end

		if self[YesItemNameIndex] ~= nil and Cfg.bNeedType then
			UIUtil.ImageSetMaterialTextureFromAssetPathSync(self[YesItemNameIndex], Cfg.AssetPath, "Texture")
			UIUtil.CanvasSlotSetPosition(self[YesItemNameIndex], FinishLocation)
		end

		local NameIndex = "MoveBread0"..tostring(i)
		local PuzzleItem = self[NameIndex]
		if PuzzleItem then
			PuzzleItem:OnInit()
			PuzzleItem:SetRenderTranslation(_G.UE.FVector2D(0, 0))
			PuzzleItem:EndHighLight()
			-- if Cfg.bNeedType then

			-- local StrFinishLoc = Cfg.FinishLocation
			-- local TmpData2 = string.split(StrFinishLoc, ";")

			local InitLocation = PuzzleMgr:SetPuzzleItemPosAngleAndSize(PuzzleItem, Cfg, self)
			local NewParams = {
				bNeedType = Cfg.bNeedType,
				InitLocation = InitLocation,
				FinishLocation = FinishLocation or -1,
				AssetPath = Cfg.AssetPath,
				ConfirmRange = Params.ConfirmRange,--PuzzleMgr.GameCfg.ConfirmRange,
				Angle = Cfg.Angle,
				ID = i,
			}
			PuzzleItem:Initlize(NewParams)
		end
		
	end
end


--- @type 初始化
function PuzzleBurritosMainView:ResetSomeToNeedState()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.SelectMoveBread = nil
	self.bOpenClickDetect = false

	-- self.BottomPanel:SetButtonEmotionVisible(false)
	-- self.BottomPanel:SetButtonPhotoVisible(false)
	-- self.BottomPanel:OnClickButtonHide()
	UIUtil.SetIsVisible(self.BottomPanel, false)
	-- self.MainTeamPanel:SwitchTab(1)

	UIUtil.SetIsVisible(self.HorizontalTime, (Params.bShowRemainTime == 1 and not PuzzleMgr.bIsDebug))
	-- UIUtil.SetIsVisible(self.CloseBtn, true)

	UIUtil.SetIsVisible(self.PuzzleGM, PuzzleMgr.bIsDebug)
	UIUtil.SetIsVisible(self.TextAutoMove, false)

	local GameCfg = Params
    if (GameCfg ~= nil) then
        -- 替换背景图片
        UIUtil.ImageSetBrushFromAssetPath(self.ImgBreadBG, GameCfg.PuzzleBGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgLightWrong, GameCfg.PuzzleWrongBGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgLightYes, GameCfg.PuzzleYesBGPath)

        local OffsetPos = _G.UE.FVector2D(GameCfg.BGOffset[1],GameCfg.BGOffset[2])
        self:SetBgPosition(OffsetPos)
    end
end

function PuzzleBurritosMainView:OnMouseButtonDown(InGeo, InMouseEvent)
	local GameInst = PuzzleMgr:GetGameInst()
	if GameInst == nil then
		return false
	end

	if GameInst:GetbAutoPuzzleInEnd() then
		return false
	end
	FLOG_INFO("PuzzleBurritosMainView OnMouseButtonDown")

	if not self.bOpenClickDetect then
		return false
	end

	if GameInst.bIsDraging then --如果点击到拼图碎片
		return false
	end	

	if self.SelectMoveBread == nil or self.SelectMoveBread.bFinish then
		FLOG_INFO("PuzzleBurritosMainView_OnMouseButtonDown selectMoveBread is nil or finish!")
	 	return false
	end

	self.bOpenClickDetect = false
	local TouchPos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent) --UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())

	-- local TouchPos = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())
	local LocalPos =  UIUtil.AbsoluteToLocal(self.PanelMoveBread, TouchPos)
	local Size = UIUtil.GetLocalSize(self.SelectMoveBread)
	
	local NeedLocalPos = UE.FVector2D(LocalPos.X - Size.X / 2, LocalPos.Y - Size.Y / 2)

	if PuzzleMgr:bIsPuzzleRange(NeedLocalPos) then
		local bSuccess
		local SelectMoveBread = self.SelectMoveBread

		if self.SelectMoveBread:GetIsNeedType() then
			local DistanceToRightLoc = UE.FVector.Dist2D(UE.FVector(NeedLocalPos.X, NeedLocalPos.Y, 0), UE.FVector(SelectMoveBread.FinishLocation.X, SelectMoveBread.FinishLocation.Y, 0))
			if DistanceToRightLoc <= SelectMoveBread.ConfirmRange then
				bSuccess = true
			else
				bSuccess = false
			end
			SelectMoveBread.bFinish = bSuccess
		else
			bSuccess = false
		end
		local GameInst = PuzzleMgr:GetGameInst()
		if GameInst == nil then
			return
		end
		GameInst:SetbAutoMove(true)
		local MoveToTargetOp = PuzzleDefine.MoveToTargetOp
		PuzzleMgr:AutoMoveToTargetLoc(SelectMoveBread, NeedLocalPos, bSuccess, MoveToTargetOp.ByMouseClickAutoMove)
	else	
		self:ResetSelectBread(true)
	end

	return true
end


function PuzzleBurritosMainView:OnDrop(MyGeometry, PointerEvent, Operation)
    return false
end

--- @type 更新被选择的碎片
function PuzzleBurritosMainView:UpdateSelectBread(PuzzleItemID, bHighLight)
	self.SelectMoveBread = self[string.format("MoveBread0%s", PuzzleItemID)]
	if self.SelectMoveBread then
		_G.FLOG_INFO("Select Bread ID = %s, Begin Detect Next Click", self.SelectMoveBread.ID)

		-- if bHighLight then
		self.SelectMoveBread:BeginHighLight()
		-- end

		if PuzzleMgr.bIsDebug then
			self.PuzzleGM:UpdateSelectPuzzleItemData()
			MsgTipsUtil.ShowTips(string.format("你已经选择了ID = %s的拼图碎片", PuzzleItemID))
		end
	end
end

--- @type 重置选择的碎片
function PuzzleBurritosMainView:ResetSelectBread(bShowDebugTip, bEndHighLight)
	if self.SelectMoveBread ~= nil then
		-- TODO 取消发光
		_G.FLOG_INFO("ResetSelectBread Close Next Click")
		-- if bEndHighLight then
		self.SelectMoveBread:EndHighLight()
		-- end

		self.SelectMoveBread = nil
	end
	self.bOpenClickDetect = false

	if PuzzleMgr.bIsDebug and bShowDebugTip then
		self.PuzzleGM:ResetData()
		MsgTipsUtil.ShowTips("你已经取消了选择")
	end
end


--- 动画结束统一回调
function PuzzleBurritosMainView:OnAnimationFinished(Animation)
	
end

function PuzzleBurritosMainView:OnReady()
	local ReadyTime = 1
	local ReadyToBegin = 1
	UIUtil.SetIsVisible(self.PanelTips, true)
	self.TextTips:SetText(LSTR(250021)) -- 准备
	AudioUtil.LoadAndPlayUISound(AudioPath.Perpare)

	-- UIUtil.SetIsVisible(self.ImgClockTime, true)
	-- UIUtil.SetIsVisible(self.ImgClockArrow, true)
	UIUtil.SetIsVisible(self.ImgLightYes, false)
	UIUtil.SetIsVisible(self.ImgLightWrong, false)
	-- 隐藏摆放区碎片
	for i = 1, 6 do
		PuzzleMgr:SetMoveBreadVisible(i, false)
		if i <= 4 then
			PuzzleMgr:SetYesBreadVisible(i, false)
		end
	end
	PuzzleMgr:UpdateShadowVisible(-1)

	self:RegisterTimer(function() self:OnBegin() end, ReadyTime + ReadyToBegin)
end

function PuzzleBurritosMainView:SequenceEvent_Start()
	self.TextTips:SetText(LSTR(250022)) -- 开始
end

function PuzzleBurritosMainView:OnBegin()
	local Params = self.Params
	if Params == nil then
		return
	end
	UIUtil.SetIsVisible(self.PanelTips, false)

	-- UIUtil.SetIsVisible(self.ImgClockArrow, false)
	-- UIUtil.SetIsVisible(self.ImgClockTime, false)

	-- 显示可移动的碎片
	for i = 1, 6 do
		PuzzleMgr:SetMoveBreadVisible(i, true)
	end

	local function BeginGameCountDown()
		if not PuzzleMgr.bIsDebug then
			PuzzleMgr:BeginCountDown()
		else
			self.PuzzleGM:LookBgPos()
		end
	end

	self:RegisterTimer(BeginGameCountDown, self.AnimStart:GetEndTime())

	self:RegisterTimer(function() AudioUtil.LoadAndPlayUISound(AudioPath.Begin) end, 0.5)

end

--- @type 拼完一块图片出现正确or错误表现
function PuzzleBurritosMainView:OnCheckPuzzleItemFinish(bSuccess)
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
		AudioUtil.LoadAndPlayUISound(AudioPath.Error)
	end
	
	UIUtil.SetIsVisible(self.ImgLightWrong, bWrongVisible)
	UIUtil.SetIsVisible(self.ImgLightYes, bYesVisible)
	self:RegisterTimer(function() UIUtil.SetIsVisible(NeedImg, false) end, 1.5)
end

--- @type 时间结束
function PuzzleBurritosMainView:OnTimeOut()
	--- 时间结束自动拼完
	self:AutoPuzzleAllItem()

	self:RegisterTimer(self.OnFinish, 3, 0, 1, true)
end

--- @type 自动拼装所有碎片
function PuzzleBurritosMainView:AutoPuzzleAllItem()
	local Params = self.Params
	if Params == nil then
		return
	end
	local GameInst = PuzzleMgr:GetGameInst()
	if GameInst == nil then
		return
	end

	if Params.bNeedAutoPuzzle == 1 then
		self:EndHelpTip()
		GameInst:SetbAutoPuzzleInEnd(true)
		UIUtil.SetIsVisible(self.TextAutoMove, Params.bNeedAutoPuzzle)
		for i = 1, 6 do
			local NameIndex = "MoveBread0"..tostring(i)
			local PuzzleItem = self[NameIndex]
			if PuzzleItem.bNeedType == 1 then
				local MoveToTargetOp = PuzzleDefine.MoveToTargetOp				
				PuzzleMgr:AutoMoveToTargetLoc(PuzzleItem, PuzzleItem.FinishLocation, true, MoveToTargetOp.ByTimeOutAutoMove)
			end
		end
	else
		-- TODO 不自动拼图应该做什么
	end
end

--- @type 当完成时 包括拼装成功和时间结束自动拼装
function PuzzleBurritosMainView:OnFinish(bTimeOut)
	local TipStr
	local DelayHide
	
	if bTimeOut then
		-- 自动完成
		TipStr = LSTR(280003) -- 拼图结束
		DelayHide = 2
		MsgTipsUtil.ShowTips(TipStr, nil, 1)

		UIUtil.SetIsVisible(self.TextAutoMove, false)
		UIUtil.SetIsVisible(self.CloseBtn, PuzzleMgr.bIsDebug)
		-- MsgTipsUtil.ShowTips(TipStr)
	
		local function GameEnd()
			local Params = {
				PuzzleGameID = PuzzleMgr.CurGameID,
				bTimeOut = bTimeOut
			}
			_G.EventMgr:SendEvent(EventID.PuzzleFinishNotify, Params)
			FLOG_INFO("_G.EventMgr:SendEvent(EventID.PuzzleFinishNotify) ID = %d", EventID.PuzzleFinishNotify)
			PuzzleMgr:GameEnd(PuzzleDefine.EndType.TimeOutEnd)
			self:PlayAnimation(self.AnimAutoFinish)
			self:CheckHideHelpTip()

			self:RegisterTimer(function() self:Hide() end, self.AnimAutoFinish:GetEndTime())
		end
	
		self:RegisterTimer(GameEnd, DelayHide)
	else
		-- 手动成功
		DelayHide = self.AnimFinish:GetEndTime()
		self:SetFinishText()
		UIUtil.SetIsVisible(self.PanelTips, true)
		self.TextTips:SetText(LSTR(270008)) -- 成功

		--- 完成后隐藏错误碎片
		for i = 1, 6 do
			PuzzleMgr:SetMoveBreadVisible(i, false)
		end
		PuzzleMgr:StopCountDown()
		self:PlayAnimation(self.AnimFinish)
		self:RegisterTimer(function() UIUtil.SetIsVisible(self.PanelTips, false) end, 1.5)

		UIUtil.SetIsVisible(self.TextAutoMove, false)
		UIUtil.SetIsVisible(self.CloseBtn, PuzzleMgr.bIsDebug)
	
		local function GameEnd()
			local Params = {
				PuzzleGameID = PuzzleMgr.CurGameID,
				bTimeOut = bTimeOut
			}
			_G.EventMgr:SendEvent(EventID.PuzzleFinishNotify, Params)
			FLOG_INFO("_G.EventMgr:SendEvent(EventID.PuzzleFinishNotify) ID = %d", EventID.PuzzleFinishNotify)
			PuzzleMgr:GameEnd(PuzzleDefine.EndType.SuccessEnd)
			self:CheckHideHelpTip()
			self:Hide()
		end
		AudioUtil.LoadAndPlayUISound(AudioPath.Success)

		self:RegisterTimer(GameEnd, DelayHide)
	end
end

--- @type 设置一下结束时的某些相关的Text 0.0
function PuzzleBurritosMainView:SetFinishText()
	local Params = self.Params
	if nil == Params then
		return
	end
	local RelateItemID = Params.RelateItemID
	local Name = ItemCfg:GetItemName(RelateItemID)
	if nil == Name then
		return
	end
	self.TextDescribe:SetText(string.format(LSTR(280004), Name)) -- "脑海中浮现了%s的样子！"
end

--- @type 播放错误动画
function PuzzleBurritosMainView:PlayAnimWrong()
	self:PlayAnimation(self.AnimWrong)
end

--- @type 出现提示
function PuzzleBurritosMainView:ShowHelpTip()
	local ID = PuzzleMgr:GetOneNotFinishPuzzleItemID()
	if ID == nil then
		return
	end
	local GameInst = PuzzleMgr:GetGameInst()
	if GameInst == nil then
		return
	end
	PuzzleBurritosVM:SetYesBreadVisible(ID, true)
	local NeedAnim = self[string.format("AnimNotice%s", ID)]
	self:PlayAnimation(NeedAnim)

	local NameIndex = "MoveBread0"..tostring(ID)
	self[NameIndex]:BeginHighLight()
	GameInst:SetShowTipItemID(ID)
	self.EndHelpTipTimer = self:RegisterTimer(self.EndHelpTip, NeedAnim:GetEndTime())
end

--- @type 结束提示
function PuzzleBurritosMainView:EndHelpTip()
	local GameInst = PuzzleMgr:GetGameInst()
	if GameInst == nil then
		return
	end
	if self.EndHelpTipTimer ~= nil then
		self:UnRegisterTimer(self.EndHelpTipTimer)
		self.EndHelpTipTimer = nil
	end
	local ShowTipItemID = GameInst:GetShowTipItemID()
	if ShowTipItemID == nil or ShowTipItemID < 0 then
		return
	end
	GameInst:ResetShowTipItemID()

	PuzzleBurritosVM:SetYesBreadVisible(ShowTipItemID, false)

	-- 如果本來就是选中的情况，不要变暗
	if self.SelectMoveBread ~= nil and self.SelectMoveBread:GetID() ~= ShowTipItemID then
		local NameIndex = "MoveBread0"..tostring(ShowTipItemID)
		self[NameIndex]:EndHighLight()
	end

end

-- function PuzzleBurritosMainView:OnAnimationFinished(Animation)
-- 	if Animation == self.AnimIn then
-- 		-- self:InitItems()
-- 	end
-- end

function PuzzleBurritosMainView:CheckHideHelpTip()
	if _G.UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTitleTipsView) then
		_G.UIViewMgr:HideView(UIViewID.CommHelpInfoTitleTipsView)
	end
end

-------------------------------------------debug---------------------------------------------------
function PuzzleBurritosMainView:GetSelectPuzzleItemData()
	local SelectMoveBread = self.SelectMoveBread
	if SelectMoveBread == nil then
		return
	end
	return UIUtil.CanvasSlotGetPosition(SelectMoveBread), SelectMoveBread.Angle
end

function PuzzleBurritosMainView:ChangeSelectPuzzleItemPosAndAngle(XOffset, YOffset, InAngle)
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

function PuzzleBurritosMainView:SetBgPosition(OffsetPos)
	UIUtil.CanvasSlotSetPosition(self.ImgBreadBG, OffsetPos)
    UIUtil.CanvasSlotSetPosition(self.ImgLightWrong, OffsetPos)
    UIUtil.CanvasSlotSetPosition(self.ImgLightYes, OffsetPos)
end

return PuzzleBurritosMainView