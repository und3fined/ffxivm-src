---
--- Author: moodliu
--- DateTime: 2024-05-11 15:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local PerformanceAssistNewItemVM = require("Game/Performance/VM/PerformanceAssistNewItemVM")
local PerformanceAssistantNewPanelVM = require("Game/Performance/VM/PerformanceAssistantNewPanelVM")
local MathUtil = require("Utils/MathUtil")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local ObjectGCType = require("Define/ObjectGCType")
local UIBinderSetText = require("Binder/UIBinderSetText")
local DataReportUtil = require("Utils/DataReportUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIViewID = require("Define/UIViewID")

---@class PerformanceAssistantNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlueAreaEffectBtn UFButton
---@field BtnPause UFButton
---@field FinishPage PerformanceFinishPageView
---@field ImgBgBlue UFImage
---@field ImgBgRed UFImage
---@field ImgBlueBg UFImage
---@field ImgHighBlue UFImage
---@field ImgHighBlueBg UFImage
---@field ImgHighRed UFImage
---@field ImgHighRedBg UFImage
---@field ImgRedBg UFImage
---@field ItemB PerformanceAssistNewItemView
---@field ItemB2 PerformanceAssistNewItemView
---@field PanelHighBlue UFCanvasPanel
---@field PanelHighRed UFCanvasPanel
---@field PanelItem UFCanvasPanel
---@field PanelKeyboard UFCanvasPanel
---@field PanelKeyboardBg UFCanvasPanel
---@field PanelKeyboardBg1 UFCanvasPanel
---@field PanelLong UFCanvasPanel
---@field PanelPerformEffect UFCanvasPanel
---@field PanelSToSPlus UFCanvasPanel
---@field PanelShort UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field PanelTrackAll UFCanvasPanel
---@field ProBarSToSPlus UProgressBar
---@field RedAreaEffectBtn UFButton
---@field TextBlue UFTextBlock
---@field TextRed UFTextBlock
---@field TextScore UFTextBlock
---@field TextSongName UFTextBlock
---@field TinyMetronome PerformanceTinyMetronomeItemView
---@field AnimBlueBgShow UWidgetAnimation
---@field AnimRedBgShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceAssistantNewPanelView = LuaClass(UIView, true)

--演奏助手界面相关
function PerformanceAssistantNewPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlueAreaEffectBtn = nil
	--self.BtnPause = nil
	--self.FinishPage = nil
	--self.ImgBgBlue = nil
	--self.ImgBgRed = nil
	--self.ImgBlueBg = nil
	--self.ImgHighBlue = nil
	--self.ImgHighBlueBg = nil
	--self.ImgHighRed = nil
	--self.ImgHighRedBg = nil
	--self.ImgRedBg = nil
	--self.ItemB = nil
	--self.ItemB2 = nil
	--self.PanelHighBlue = nil
	--self.PanelHighRed = nil
	--self.PanelItem = nil
	--self.PanelKeyboard = nil
	--self.PanelKeyboardBg = nil
	--self.PanelKeyboardBg1 = nil
	--self.PanelLong = nil
	--self.PanelPerformEffect = nil
	--self.PanelSToSPlus = nil
	--self.PanelShort = nil
	--self.PanelTrack = nil
	--self.PanelTrackAll = nil
	--self.ProBarSToSPlus = nil
	--self.RedAreaEffectBtn = nil
	--self.TextBlue = nil
	--self.TextRed = nil
	--self.TextScore = nil
	--self.TextSongName = nil
	--self.TinyMetronome = nil
	--self.AnimBlueBgShow = nil
	--self.AnimRedBgShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceAssistantNewPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FinishPage)
	self:AddSubView(self.ItemB)
	self:AddSubView(self.ItemB2)
	self:AddSubView(self.TinyMetronome)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceAssistantNewPanelView:OnInit()
	self:InitStaticText()
	self.VM = PerformanceAssistantNewPanelVM.New()
	self:OnSetRedBlueAreaSize()
end

function PerformanceAssistantNewPanelView:InitStaticText()
	self.FinishPage:SetTextTitle(_G.LSTR(830088))
	self.TextBlue:SetText(_G.LSTR(830138))
	self.TextRed:SetText(_G.LSTR(830137))
end

function PerformanceAssistantNewPanelView:OnDestroy()

end

function PerformanceAssistantNewPanelView:OnShow()
	_G.MusicPerformanceMgr:ReqNetMsgPerformCmdAssist(true)
	self:Clear()
	self.AssistItems = {}
	self.IsAllKey = MusicPerformanceUtil.GetKeybordMode() ~= 1
	self.IsLargeKey = MusicPerformanceUtil.GetKeySize() ~= 1

	self:UpdateKeyboard()
	_G.MusicPerformanceMgr:OnShowCountDownTips(_G.LSTR(830037))

	self:RegisterTimer(self.OnStartAssistant, MPDefines.AssistantFallingDownConfig.StartDelayTime)
	self.VM.TextSongName = self.Params.Data.Name
	self.VM.TinyMetronomeVisible = self.Params.ToggleMetronome
	self.VM.BtnPauseVisible = false
	self.VM.FinishPageVisible = false

	--取消场景中选中的对象
	_G.SelectTargetMgr:CancelSelectTargetActor()
end

function PerformanceAssistantNewPanelView:UpdateKeyboard()
	local NewKeyboard
	local Size = _G.UE.FVector2D()
	if self.IsAllKey and self.IsLargeKey then
		NewKeyboard = self:CreateKeyboard("Performance/PerformanceFullLargeKey_UIBP")
		Size.X = 1920
		Size.Y = 320
	elseif not self.IsAllKey and self.IsLargeKey then
		NewKeyboard = self:CreateKeyboard("Performance/PerformanceMonoLargeKey_UIBP")
		Size.X = 1920
		Size.Y = 320
	elseif self.IsAllKey and not self.IsLargeKey then
		NewKeyboard = self:CreateKeyboard("Performance/PerformanceFullKey_UIBP")
		Size.X = 1920
		Size.Y = 252
	elseif not self.IsAllKey and not self.IsLargeKey then
		NewKeyboard = self:CreateKeyboard("Performance/PerformanceMonoKey_UIBP")
		Size.X = 1920
		Size.Y = 252
	end

	if NewKeyboard then
		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0.5, 1)
		Anchor.Maximum = _G.UE.FVector2D(0.5, 1)
		local Alignment = _G.UE.FVector2D()
		Alignment.X = 0.5
		Alignment.Y = 1

		UIUtil.CanvasSlotSetAnchors(NewKeyboard, Anchor)
		UIUtil.CanvasSlotSetAutoSize(NewKeyboard, false)
		UIUtil.CanvasSlotSetSize(NewKeyboard, Size)
		UIUtil.CanvasSlotSetAlignment(NewKeyboard, Alignment)
	end

	self.VM.PanelTrackAllVisible = self.IsAllKey
	self.VM.PanelTrackVisible = not self.IsAllKey

	--添加掉落音符的容器
	self.TargetPanel = self.IsLargeKey and self.PanelLong or self.PanelShort

	-- 黄色分界线的高度，区分高低按键
	local BGSize = UIUtil.CanvasSlotGetSize(self.PanelKeyboardBg)
	local BG1Size = UIUtil.CanvasSlotGetSize(self.PanelKeyboardBg1)
	BGSize.Y = self.IsLargeKey and MPDefines.AssistantFallingDownConfig.KeybroadSize.LargeBGY or MPDefines.AssistantFallingDownConfig.KeybroadSize.BGY
	BG1Size.Y = self.IsLargeKey and MPDefines.AssistantFallingDownConfig.KeybroadSize.LargeBGY or MPDefines.AssistantFallingDownConfig.KeybroadSize.BGY
	UIUtil.CanvasSlotSetSize(self.PanelKeyboardBg, BGSize)
	UIUtil.CanvasSlotSetSize(self.PanelKeyboardBg1, BG1Size)

	self.KeyViewMap = MusicPerformanceUtil.GetKeybordKeyViewMap(self.KeyboardView)
end

--创建键盘
function PerformanceAssistantNewPanelView:CreateKeyboard(BPName)
	if self.KeyboardView and self.KeyboardView.BPName == BPName then
		return
	end

	if self.KeyboardView then
		_G.UIViewMgr:HideSubView(self.KeyboardView)
		self.PanelKeyboard:RemoveChild(self.KeyboardView)
		self.KeyboardView:RemoveFromParentView()
		_G.UIViewMgr:RecycleView(self.KeyboardView)
	end
	self.KeyboardView = _G.UIViewMgr:CreateViewByName(BPName, ObjectGCType.NoCache, self, true, true, nil)
	
	self.PanelKeyboard:AddChild(self.KeyboardView)
	
	_G.UIViewMgr:ShowSubView(self.KeyboardView)
	return self.KeyboardView
end

function PerformanceAssistantNewPanelView:GetKeyOffset(Key)
	local KeyView = self.KeyViewMap and self.KeyViewMap[Key] or nil
	if KeyView == nil or self.KeyboardView == nil or self.TargetPanel == nil then
		return nil
	end

	local AbsPos = UIUtil.LocalToAbsolute(self.KeyboardView, UIUtil.CanvasSlotGetPosition(KeyView))
	local TargetPos = UIUtil.AbsoluteToLocal(self.TargetPanel, AbsPos)
	return TargetPos.X
end

function PerformanceAssistantNewPanelView:OnAssistantPause()
	if self:GetToggleMetronome() then
		self.TinyMetronome:Pause()
	end
end

function PerformanceAssistantNewPanelView:OnAssistantResume()
	if self:GetToggleMetronome() then
		local LogicTimeMS = _G.MusicPerformanceMgr:GetAssistantInst():GetLogicTimeMS()
		--传给节拍器算动画播放起始位置的时间必须为音符此刻真实时间，否则'第一个音符'暂停后再播放的位置算的就会不对
		LogicTimeMS = LogicTimeMS + MPDefines.AssistantFallingDownConfig.EarlyAppearOffsetMS
		self.TinyMetronome:Play(LogicTimeMS / 1000)
	end
end

function PerformanceAssistantNewPanelView:OnAssistantDone()
	self.VM.FinishPageVisible = true
	self.VM.BtnPauseVisible = false
	local DelayTime = self.FinishPage:GetAnimationTime()
	self:RegisterTimer(function()
		self.VM.FinishPageVisible = false
		_G.UIViewMgr:HideView(_G.UIViewID.PerformanceAssistantPanelView, true)
	end, DelayTime, 0, 1)
	self.TinyMetronome:ResetMetronome()

	--播放演奏完成的音效
	AudioUtil.LoadAndPlay2DSound(MPDefines.CommonSettings.PerformanceAssistantDoneSoundPath)

    --演奏埋点(完成演奏)
	DataReportUtil.ReportSystemFlowData("PerformanceAssistant", tostring(2), tostring(MusicPerformanceUtil.GetKeybordMode()), tostring(self.Params.Data.Name))
end

function PerformanceAssistantNewPanelView:OnBtnPauseClicked()
	_G.UIViewMgr:ShowView(_G.UIViewID.PerformanceAssistantPauseWinView, 
		{Data = self.Params.Data, ToggleMetronome = self:GetToggleMetronome()})
end

function PerformanceAssistantNewPanelView:OnHide()
	self:Clear()
	_G.MusicPerformanceMgr:ReqNetMsgPerformCmdAssist(false)
end

function PerformanceAssistantNewPanelView:Clear()
	if self.CurFocusIndex then
		self:DoFocus(self.CurFocusIndex, false)
		self.CurFocusIndex = nil
	end
	if self.AssistItems then
		for _, Item in pairs(self.AssistItems) do
			self:DestoryItemView(Item.View)
		end
	end
	self.AssistItems = nil
	self.LastNoteIndex = -1 --记录上一个音符索引
	self:UpdatePercent(0)
end

function PerformanceAssistantNewPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPause, self.OnBtnPauseClicked)

	--高低八度20%侧边按键
	UIUtil.AddOnLongClickedEvent(self, self.RedAreaEffectBtn, self.OnPressedRedAreaEffectBtn)
    UIUtil.AddOnLongClickReleasedEvent(self, self.RedAreaEffectBtn, self.OnReleasedRedAreaEffectBtn)
	UIUtil.AddOnLongClickedEvent(self, self.BlueAreaEffectBtn, self.OnPressedBlueAreaEffectBtn)
    UIUtil.AddOnLongClickReleasedEvent(self, self.BlueAreaEffectBtn, self.OnReleasedBlueAreaEffectBtn)
end

--从暂停界面关闭后，继续演奏助手过程
function PerformanceAssistantNewPanelView:ResumeAssistant()
	self:OnResumeAssistantTimer()
end

function PerformanceAssistantNewPanelView:GetToggleMetronome()
	return self.VM.TinyMetronomeVisible
end

function PerformanceAssistantNewPanelView:SetToggleMetronome(ToggleMetronome)
	self.VM.TinyMetronomeVisible = ToggleMetronome
end

function PerformanceAssistantNewPanelView:OnStartAssistant()
	local PerformData = _G.MusicPerformanceMgr:GetSelectedPerformData()
	local IsLongClick = PerformData and PerformData.Loop == 1 or false
	local Rate = self.Params.Rate or 1.0
	_G.MusicPerformanceMgr:GetAssistantInst():StartMusicAssistant(self.Params.Data, IsLongClick, Rate)
	if self:GetToggleMetronome() then
		self.TinyMetronome:SetBPM(self.Params.Data.Bpm)
		self.TinyMetronome:SetBeatPerBar(self.Params.Data.Beat2)
		self.TinyMetronome:SetSpeedValue(Rate)
		self.TinyMetronome:Play(0)
	end
	self.VM.BtnPauseVisible = true
end

function PerformanceAssistantNewPanelView:OnResumeAssistantTimer()
	-- Resume 不一定成功，所以接下来的逻辑走事件通知
	_G.MusicPerformanceMgr:GetAssistantInst():Resume(true)
	self.VM.BtnPauseVisible = true
end

function PerformanceAssistantNewPanelView:RestartAssistant(Rate, ToggleMetronome)
	self:Clear()
	self.AssistItems = {}
	self.VM.BtnPauseVisible = false
	self:SetToggleMetronome(ToggleMetronome)
	self.TinyMetronome:ResetMetronome()
	self.Params.Rate = Rate
	self:RegisterTimer(self.OnStartAssistant, MPDefines.AssistantFallingDownConfig.StartDelayTime)

	_G.MusicPerformanceMgr:OnShowCountDownTips(_G.LSTR(830037))
end

--创建掉落的音符Item
function PerformanceAssistantNewPanelView:CreateItemView(UINote, VM)
	local ItemView = _G.UIViewMgr:CreateView(_G.UIViewID.PerformanceAssistantItemView, self, true, true, {Data = VM})
	self.TargetPanel:AddChildToCanvas(ItemView)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 1)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 1)
	UIUtil.CanvasSlotSetAnchors(ItemView, Anchor)
	UIUtil.CanvasSlotSetAlignment(ItemView, _G.UE.FVector2D(0.5, 1))
	UIUtil.CanvasSlotSetAutoSize(ItemView, true)
	local OffsetX = self:GetKeyOffset(UINote)
	UIUtil.CanvasSlotSetPosition(ItemView, _G.UE.FVector2D(OffsetX, 0))

	return ItemView
end

function PerformanceAssistantNewPanelView:OnAssistantUIItemRefresh(Assistant, ShowItemIndex, LogicTimeMS, IsLongClick)
	for _, EventIndex in pairs(ShowItemIndex) do
		self:AddItem(Assistant, EventIndex, IsLongClick)
	end

	local EarlyAppearOffsetMS = MPDefines.AssistantFallingDownConfig.EarlyAppearOffsetMS
	local RemoveKeys = _G.ObjectPoolMgr:AllocCommonTable()
	for Key, Item in pairs(self.AssistItems) do
		local VM = Item.VM
		if LogicTimeMS > Item.EndTimeMS and VM.UIState ~= MPDefines.AssistantFallingDownConfig.UIStates.WaitDestory then
			-- 长按键隐藏，短按键播放动画
			VM.UIState = MPDefines.AssistantFallingDownConfig.UIStates.WaitDestory
		elseif LogicTimeMS > (Item.EndTimeMS + MPDefines.AssistantFallingDownConfig.AssistantItemDestoryTimeOffsetMS) then
			-- 移除下落项
			table.insert(RemoveKeys, Key)
		else
			if Item.ClickTimeMS then
				-- 点击后停止位置更新，改为调整缩放
				VM.CostTime = Item.ClickTimeMS - Item.StartTimeMS + EarlyAppearOffsetMS
				VM.Duration = math.max(0, Item.Duration - (LogicTimeMS - Item.ClickTimeMS))
				if MathUtil.IsNearlyEqual(VM.Duration, 0) then
					VM.UIState = MPDefines.AssistantFallingDownConfig.UIStates.WaitDestory
				end
			else
				VM.CostTime = LogicTimeMS - Item.StartTimeMS + EarlyAppearOffsetMS
			end
		end
	end

	-- 销毁超时项
	for _, Key in ipairs(RemoveKeys) do
		local Item = self.AssistItems[Key]
		self.AssistItems[Key] = nil
		_G.ObjectPoolMgr:FreeObject(PerformanceAssistNewItemVM, Item.VM)
		self:DestoryItemView(Item.View)
	end

	_G.ObjectPoolMgr:FreeCommonTable(RemoveKeys)

	local Assistant = _G.MusicPerformanceMgr:GetAssistantInst()
	local Percent = ((LogicTimeMS + EarlyAppearOffsetMS) / ((Assistant and Assistant:GetMusicLength() or 0) + EarlyAppearOffsetMS))
	self:UpdatePercent(Percent)
end

function PerformanceAssistantNewPanelView:UpdatePercent(Percent)
	--Percent = math.clamp(Percent, 0, 1)
	Percent = math.min(1, Percent)
	self.VM.Percent = Percent
	self.VM.TextScore = string.format("%.0f%%", Percent * 100)
end

function PerformanceAssistantNewPanelView:DestoryItemView(ItemView)
	self.TargetPanel:RemoveChild(ItemView)
	_G.UIViewMgr:RecycleView(ItemView)
end

function PerformanceAssistantNewPanelView:AddItem(Assistant, Index, IsLongClick)
	local NoteEvent = Assistant:GetNoteEvent(Index)
	local Item = self.AssistItems[Index]
	if Item == nil then
		Item = {}
		self.AssistItems[Index] = Item
		Item.VM = _G.ObjectPoolMgr:AllocObject(PerformanceAssistNewItemVM)
		Item.StartTimeMS = NoteEvent.Time
		Item.EndTimeMS = NoteEvent.Time + NoteEvent.Duration + MPDefines.AssistantFallingDownConfig.RecycleTimeOffsetMS
		Item.ClickTimeMS = nil	-- 响应按键的时间，响应后Item的位置就不该移动了
		Item.Tone = NoteEvent.Tone
		Item.VM.Duration = NoteEvent.Duration
		Item.Duration = NoteEvent.Duration

		-- 计算键盘上的按键
		local UINote
		local IsBlackKey
		if self.IsAllKey then
			UINote = NoteEvent.Tone
			IsBlackKey = not MPDefines.AssistantFallingDownConfig.IsWhiteKey[UINote % MPDefines.KeyDefines.KEY_MAX]
		else
			-- i要单独处理
			local IsKeyI = (NoteEvent.Tone == MPDefines.KeyStart + MPDefines.KeyDefines.KEY_MAX * 2)
				or (NoteEvent.Tone == MPDefines.KeyStart + MPDefines.KeyDefines.KEY_MAX * 3)
			UINote = MPDefines.KeyCenterStart + (IsKeyI and MPDefines.KeyDefines.KEY_MAX or (NoteEvent.Tone % MPDefines.KeyDefines.KEY_MAX))
			IsBlackKey = not MPDefines.AssistantFallingDownConfig.IsWhiteKey[IsKeyI and MPDefines.KeyDefines.KEY_MAX or UINote % MPDefines.KeyDefines.KEY_MAX]
		end

		local KeyOffset = 0
		-- 全音阶的情况下不进行颜色提示
		if not self.IsAllKey and NoteEvent.Tone < MPDefines.KeyStart + MPDefines.KeyDefines.KEY_MAX then
			KeyOffset = -1
		elseif not self.IsAllKey and NoteEvent.Tone > MPDefines.KeyStart + MPDefines.KeyDefines.KEY_MAX * 2 then
			KeyOffset = 1
		end

		-- UI样式调整
		Item.VM.IsLongClick = IsLongClick
		Item.VM.IsBlackKey = IsBlackKey
		Item.VM.IsAllKey = self.IsAllKey
		Item.VM.KeyOffset = KeyOffset
		Item.VM.UIState = MPDefines.AssistantFallingDownConfig.UIStates.Falling
		--FLOG_INFO("TEST.r=[KeyOffset=%d, Tone=%d, KeyStart=%d,  KEY_MAX=%d]", KeyOffset, NoteEvent.Tone, MPDefines.KeyStart, MPDefines.KeyDefines.KEY_MAX)
		
		local startTime = os.clock()
		Item.View = self:CreateItemView(UINote, Item.VM)
		Item.UINote = UINote
		local endTime = os.clock()
		local elapsedTime = endTime - startTime
		--print("CreateItemView Elapsed time: " .. elapsedTime .. " seconds")
	end
end

-- 查找Index <= CurIndex 且Tone相同的Item
function PerformanceAssistantNewPanelView:FindItems(Items, CurCheckIndex, Tone)
	for Index, Item in pairs(self.AssistItems) do
		if Index < CurCheckIndex and Item.Tone == Tone then
			table.insert(Items, Item)
		end
	end
end

function PerformanceAssistantNewPanelView:OnAssistantItemUpdate(LogicTimeMS, CurCheckIndex, Tone, IsClick)
	local Items = _G.ObjectPoolMgr:AllocCommonTable()
	self:FindItems(Items, CurCheckIndex, Tone)
	if Items then
		for _, Item in ipairs(Items) do
			if IsClick then
				if Item.ClickTimeMS == nil then
					Item.ClickTimeMS = Item.ClickTimeMS or LogicTimeMS
					Item.VM.UIState = MPDefines.AssistantFallingDownConfig.UIStates.Press
				end
			else
				Item.VM.UIState = MPDefines.AssistantFallingDownConfig.UIStates.WaitDestory
			end
		end
	end
	_G.ObjectPoolMgr:FreeCommonTable(Items)
	if self.CurFocusIndex ~= CurCheckIndex then
		-- 取消之前的点击提示
		self:DoFocus(self.CurFocusIndex, false)
	end
end

function PerformanceAssistantNewPanelView:OnAssistantItemFocus(CurCheckIndex)
	if self.CurCheckIndex ~= CurCheckIndex then
		-- 提示点击在响应范围的按键
		self:DoFocus(CurCheckIndex, true)
		self.CurFocusIndex = CurCheckIndex
	end
end

function PerformanceAssistantNewPanelView:DoFocus(Index, IsFocus)
	local Item = self.AssistItems and self.AssistItems[Index]
	if Item == nil then
		return
	end
	
	local UINote = Item.UINote 			--所按的键值
	local KeyOffset = Item.VM.KeyOffset --键类型(0普通白音符、-1为蓝色低音、1为红色高音)
	local KeyState = self:GetKeyState(IsFocus, KeyOffset)
	
	-- 提示音符按键
	local KeyView = self.KeyViewMap[UINote]
	if KeyView and KeyView.KeyState then
			UIUtil.SetIsVisible(KeyView.KeyState, IsFocus, false)
			KeyView.KeyState:SetKeyState(KeyState)

			if IsFocus then
				KeyView:StartPromptKeyState()
			else
				KeyView:StopPromptKeyState()
			end
	end
	self:CheckShowNoteKeyPromptTips(Index, IsFocus, KeyOffset)

	-- 提示变阶按键
	local OffsetKeyView = nil
	if KeyOffset > 0 then
		OffsetKeyView = self.KeyViewMap.Up
	elseif KeyOffset < 0 then
		OffsetKeyView = self.KeyViewMap.Down
	end

	if OffsetKeyView  then
		if IsFocus then
			OffsetKeyView:StartPromptKeyState()
		else
			OffsetKeyView:StopPromptKeyState()
		end
	end

	-- if OffsetKeyView and OffsetKeyView.KeyState then
	-- 	UIUtil.SetIsVisible(OffsetKeyView.KeyState, IsFocus, false)
	-- 	OffsetKeyView.KeyState:SetKeyState(KeyState)
	-- end
end

-------------------------------------------音符按键消除提示------------------------------------------------------------------------
-- 检测音符按键消除提示(当所要按的音符掉落时)
function PerformanceAssistantNewPanelView:CheckShowNoteKeyPromptTips(Index, IsFocus, KeyOffset)
	if self.LastNoteIndex == Index then
		if not IsFocus then
			self:HideNoteKeyTips()
			self:ClearNoteKeyPromptTipsTimer()
		end
		return
	end
	self:ClearNoteKeyPromptTipsTimer() --防止出现未清timer的情况
	self.NoteKeyPromptTimer = self:RegisterTimer(self.ShowNoteKeyTips, MPDefines.AssistantFallingDownConfig.AssistanNoteKeyTipsDelayTime)
	self.LastNoteIndex = Index
end

function PerformanceAssistantNewPanelView:ClearNoteKeyPromptTipsTimer()
	if self.NoteKeyPromptTimer ~= nil then
		self:UnRegisterTimer(self.NoteKeyPromptTimer)
		self.NoteKeyPromptTimer = nil
	end
end

function PerformanceAssistantNewPanelView:ShowNoteKeyTips()
	local Item = self.AssistItems and self.AssistItems[self.LastNoteIndex]
	if Item == nil then
		return
	end
	local KeyOffset = Item.VM.KeyOffset --键类型(0普通白音符、-1为蓝色低音、1为红色高音)
	if KeyOffset == 0 then
		_G.UIViewMgr:ShowView(_G.UIViewID.PerformanceYellowTipsView)
	elseif KeyOffset > 0 then
		_G.UIViewMgr:ShowView(_G.UIViewID.PerformanceRedTipsView)
	elseif KeyOffset < 0 then
		_G.UIViewMgr:ShowView(_G.UIViewID.PerformanceBlueTipsView)
	end
end

function PerformanceAssistantNewPanelView:HideNoteKeyTips()
	local Item = self.AssistItems and self.AssistItems[self.LastNoteIndex]
	if Item == nil then
		return
	end
	local KeyOffset = Item.VM.KeyOffset
	if KeyOffset == 0 then
		_G.UIViewMgr:HideView(_G.UIViewID.PerformanceYellowTipsView)
	elseif KeyOffset > 0 then
		_G.UIViewMgr:HideView(_G.UIViewID.PerformanceRedTipsView)
	elseif KeyOffset < 0 then
		_G.UIViewMgr:HideView(_G.UIViewID.PerformanceBlueTipsView)
	end
end
-------------------------------------------音符按键消除提示------------------------------------------------------------------------

function PerformanceAssistantNewPanelView:GetKeyState(IsFocus, KeyOffset)
	local KeyStates = MPDefines.AssistantFallingDownConfig.KeyStates
	if not IsFocus or KeyOffset == nil then
		return KeyStates.None
	end

	if  KeyOffset < 0 then
		return KeyStates.Blue
	elseif KeyOffset > 0 then
		return KeyStates.Red
	else
		return KeyStates.Grey
	end
end

function PerformanceAssistantNewPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(_G.EventID.MusicPerformanceAssistantUIItemRefresh, self.OnAssistantUIItemRefresh)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceAssistantItemUpdate, self.OnAssistantItemUpdate)
	--self:RegisterGameEvent(_G.EventID.MusicPerformanceAssistantItemFocus, self.OnAssistantItemFocus)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceAssistantDone, self.OnAssistantDone)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceAssistantPause, self.OnAssistantPause)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceAssistantResume, self.OnAssistantResume)
	self:RegisterGameEvent(_G.EventID.MusicPerformanceToneOffset, self.OnMusicPerformanceToneOffsetUpdate)
end

--设置二侧20%高底八底按键区域
function PerformanceAssistantNewPanelView:OnSetRedBlueAreaSize()
	local ViewportSize = UIUtil.GetViewportSize()

	local BlueSize = UIUtil.CanvasSlotGetSize(self.BlueAreaEffectBtn)
	local BlueViewportX = ViewportSize.X * 0.2
	UIUtil.CanvasSlotSetSize(self.BlueAreaBtnEffect, _G.UE.FVector2D(BlueViewportX, BlueSize.Y))

	local RedSize = UIUtil.CanvasSlotGetSize(self.RedAreaEffectBtn)
	local RedViewportX = ViewportSize.X * 0.2
	UIUtil.CanvasSlotSetSize(self.BlueAreaBtnEffect, _G.UE.FVector2D(RedViewportX, RedSize.Y))
end

function PerformanceAssistantNewPanelView:OnMusicPerformanceToneOffsetUpdate(Offset)
	local IsSingleMode = MusicPerformanceUtil.GetKeybordMode() == 1	-- 是否是单音阶
	if not IsSingleMode then
		return
	end
	
	if Offset > 0 then
		self:OnShowRedEffect()
		self:OnHideBlueEffect()
		self.RedAreaEffectBtn:SetIsEnabled(false)
		self.BlueAreaEffectBtn:SetIsEnabled(false)
	elseif Offset < 0 then
		self:OnShowBlueEffect()
		self:OnHideRedEffect()
		self.RedAreaEffectBtn:SetIsEnabled(false)
		self.BlueAreaEffectBtn:SetIsEnabled(false)
	else
		self:OnHideBlueEffect()
		self:OnHideRedEffect()
		self.RedAreaEffectBtn:SetIsEnabled(true)
		self.BlueAreaEffectBtn:SetIsEnabled(true)
	end
end

function PerformanceAssistantNewPanelView:OnPressedRedAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, MPDefines.KeyDefines.KEY_MAX)
end
function PerformanceAssistantNewPanelView:OnReleasedRedAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, 0)
end

function PerformanceAssistantNewPanelView:OnPressedBlueAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, -MPDefines.KeyDefines.KEY_MAX)
end
function PerformanceAssistantNewPanelView:OnReleasedBlueAreaEffectBtn()
	_G.EventMgr:SendEvent(_G.EventID.MusicPerformanceToneOffset, 0)
end

--显示高八度效果
function PerformanceAssistantNewPanelView:OnShowRedEffect()
	self:PlayAnimation(self.AnimRedBgShow)
	self.VM.ImgRedBgVisible = true
end
--隐藏高八度效果
function PerformanceAssistantNewPanelView:OnHideRedEffect()
	self:StopAnimLoop(self.AnimRedBgShow)
	self.VM.ImgRedBgVisible = false
end

--显示低八度效果
function PerformanceAssistantNewPanelView:OnShowBlueEffect()
	self:PlayAnimation(self.AnimBlueBgShow)
	self.VM.ImgBlueBgVisible = true
end
--隐藏低八度效果
function PerformanceAssistantNewPanelView:OnHideBlueEffect()
	self:StopAnimLoop(self.AnimBlueBgShow)
	self.VM.ImgBlueBgVisible = false
end

function PerformanceAssistantNewPanelView:OnRegisterBinder()
	local Binders = {
		{ "TextSongName", UIBinderSetText.New(self, self.TextSongName )},
		{ "TextScore", UIBinderSetText.New(self, self.TextScore)},
		{ "TinyMetronomeVisible", UIBinderSetIsVisible.New(self, self.TinyMetronome)},
		{ "BtnPauseVisible", UIBinderSetIsVisible.New(self, self.BtnPause, false, true)},
		{ "FinishPageVisible", UIBinderSetIsVisible.New(self, self.FinishPage)},
		{ "Percent", UIBinderSetPercent.New(self, self.ProBarSToSPlus)},
		{ "PanelTrackVisible", UIBinderSetIsVisible.New(self, self.PanelTrack)},
		{ "PanelTrackAllVisible", UIBinderSetIsVisible.New(self, self.PanelTrackAll)},

		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.ImgRedBg) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.ImgBlueBg) },
		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.ImgBgRed) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.ImgBgBlue) },
		{ "ImgRedBgVisible", UIBinderSetIsVisible.New(self, self.PanelHighRed) },
		{ "ImgBlueBgVisible", UIBinderSetIsVisible.New(self, self.PanelHighBlue) },
	}

	self:RegisterBinders(self.VM, Binders)
end

return PerformanceAssistantNewPanelView