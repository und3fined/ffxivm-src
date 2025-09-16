---
--- Author: Administrator
--- DateTime: 2025-04-14 16:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EModuleID = ProtoCommon.ModuleID
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVM = require("Game/Departure/VM/DepartOfLightVM")

---@class DepartureBigBannerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBanner UFButton
---@field BtnWardrobeL UFButton
---@field BtnWardrobeR UFButton
---@field BubbleCollection DepartureBannerBubbleLItemView
---@field BubbleCraftingLog DepartureBannerBubble2ItemView
---@field BubbleFateR DepartureBannerBubbleRItemView
---@field BubbleFish DepartureBannerBubbleRItemView
---@field BubbleGoldSauserL DepartureBannerBubbleLItemView
---@field BubbleGoldSauserR DepartureBannerBubbleLItemView
---@field BubbleWardrobeL DepartureBannerBubbleLItemView
---@field BubbleWardrobeR DepartureBannerBubbleRItemView
---@field EFFWardrobe UFCanvasPanel
---@field ImgBanner UFImage
---@field ImgFateMonster UFImage
---@field ImgFish UFImage
---@field ImgFishSigh1 UFImage
---@field ImgFishSigh2 UFImage
---@field ImgFishSigh3 UFImage
---@field ImgWardrobeFigure UFImage
---@field PanelBannerText UFCanvasPanel
---@field PanelCollection UFCanvasPanel
---@field PanelCraftingLog UFCanvasPanel
---@field PanelFate UFCanvasPanel
---@field PanelFish UFCanvasPanel
---@field PanelGoldSauser UFCanvasPanel
---@field PanelJobFighting UFCanvasPanel
---@field PanelWardrobe UFCanvasPanel
---@field TextBanner UFTextBlock
---@field AnimaFate UWidgetAnimation
---@field AnimaWardrobe UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field AnimCollection UWidgetAnimation
---@field AnimCraftingLog UWidgetAnimation
---@field AnimFish UWidgetAnimation
---@field AnimGoldSauserL UWidgetAnimation
---@field AnimGoldSauserR UWidgetAnimation
---@field AnimJobFighting UWidgetAnimation
---@field AnimSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBigBannerItemView = LuaClass(UIView, true)

function DepartureBigBannerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBanner = nil
	--self.BtnWardrobeL = nil
	--self.BtnWardrobeR = nil
	--self.BubbleCollection = nil
	--self.BubbleCraftingLog = nil
	--self.BubbleFateR = nil
	--self.BubbleFish = nil
	--self.BubbleGoldSauserL = nil
	--self.BubbleGoldSauserR = nil
	--self.BubbleWardrobeL = nil
	--self.BubbleWardrobeR = nil
	--self.EFFWardrobe = nil
	--self.ImgBanner = nil
	--self.ImgFateMonster = nil
	--self.ImgFish = nil
	--self.ImgFishSigh1 = nil
	--self.ImgFishSigh2 = nil
	--self.ImgFishSigh3 = nil
	--self.ImgWardrobeFigure = nil
	--self.PanelBannerText = nil
	--self.PanelCollection = nil
	--self.PanelCraftingLog = nil
	--self.PanelFate = nil
	--self.PanelFish = nil
	--self.PanelGoldSauser = nil
	--self.PanelJobFighting = nil
	--self.PanelWardrobe = nil
	--self.TextBanner = nil
	--self.AnimaFate = nil
	--self.AnimaWardrobe = nil
	--self.AnimClick = nil
	--self.AnimCollection = nil
	--self.AnimCraftingLog = nil
	--self.AnimFish = nil
	--self.AnimGoldSauserL = nil
	--self.AnimGoldSauserR = nil
	--self.AnimJobFighting = nil
	--self.AnimSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBigBannerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BubbleCollection)
	self:AddSubView(self.BubbleCraftingLog)
	self:AddSubView(self.BubbleFateR)
	self:AddSubView(self.BubbleFish)
	self:AddSubView(self.BubbleGoldSauserL)
	self:AddSubView(self.BubbleGoldSauserR)
	self:AddSubView(self.BubbleWardrobeL)
	self:AddSubView(self.BubbleWardrobeR)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBigBannerItemView:OnInit()
	self.AnimMap = {
		[EModuleID.ModuleIDFATE] = self.AnimaFate,
		[EModuleID.ModuleIDAvatar] = self.AnimaWardrobe,
		--[EModuleID.ModuleIDGoldSauserMain] = self.AnimGoldSauserL, -- 有两个，额外处理
		[EModuleID.ModuleIDMakerNote] = self.AnimCraftingLog,
		[EModuleID.ModuleIDGatherNote] = self.AnimCollection,
		[EModuleID.ModuleIDFisherNote] = self.AnimFish,
		[EModuleID.ModuleIDGamePworld] = self.AnimJobFighting,
	}

	self.PanelMap = {
		[EModuleID.ModuleIDFATE] = {Panel = self.PanelFate, Bubbles = {self.BubbleFateR}},
		[EModuleID.ModuleIDAvatar] = {Panel = self.PanelWardrobe, Bubbles = {self.BubbleWardrobeR, self.BubbleWardrobeL}}, -- 资源左右反了
		[EModuleID.ModuleIDGoldSauserMain] = {Panel = self.PanelGoldSauser, Bubbles = {self.BubbleGoldSauserL, self.BubbleGoldSauserR}},
		[EModuleID.ModuleIDMakerNote] = {Panel = self.PanelCraftingLog, Bubbles = {self.BubbleCraftingLog}},
		[EModuleID.ModuleIDGatherNote] = {Panel = self.PanelCollection, Bubbles = {self.BubbleCollection}},
		[EModuleID.ModuleIDFisherNote] = {Panel = self.PanelFish, Bubbles = {self.BubbleFish}},
		[EModuleID.ModuleIDGamePworld] = {Panel = self.PanelJobFighting, Bubbles = {}},
	}

	self.ClickCallbackMap = {
		[EModuleID.ModuleIDFATE] = self.OnClickedFate,
		--[EModuleID.ModuleIDAvatar] = self.OnClickedCloset,
		[EModuleID.ModuleIDGoldSauserMain] = self.OnClickedGoldSauser,
		[EModuleID.ModuleIDMakerNote] = self.OnClickedMakeNote,
		[EModuleID.ModuleIDGatherNote] = self.OnClickedGatherNote,
		[EModuleID.ModuleIDFisherNote] = self.OnClickedFishNote,
		[EModuleID.ModuleIDGamePworld] = self.OnClickedFight,
	}

	self.GoldSauserAnimMap = {
		[0] = self.AnimGoldSauserL,
		[1] = self.AnimGoldSauserR,
	}

	-- 钓鱼感叹号数量图片
	self.ExclamationNumIconList = {
		[1] = self.ImgFishSigh1,
		[2] = self.ImgFishSigh2,
		[3] = self.ImgFishSigh3,
	}

	self.AppIconMap = {
		[1] = { BigIcon = "Texture2D'/Game/UI/Texture/Departure/Banner/UI_Departure_Img_Wardrobe_Figure1.UI_Departure_Img_Wardrobe_Figure1'",
				SmallIcon = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_Wardrobe3_png.UI_Departure_TipsIcon_Wardrobe3_png'"},
		[2] = { BigIcon = "Texture2D'/Game/UI/Texture/Departure/Banner/UI_Departure_Img_Wardrobe_Figure2.UI_Departure_Img_Wardrobe_Figure2'",
				SmallIcon = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_Wardrobe2_png.UI_Departure_TipsIcon_Wardrobe2_png'"},
		[3] = { BigIcon = "Texture2D'/Game/UI/Texture/Departure/Banner/UI_Departure_Img_Wardrobe_Figure3.UI_Departure_Img_Wardrobe_Figure3'",
				SmallIcon = "PaperSprite'/Game/UI/Atlas/Departure/Frames/UI_Departure_TipsIcon_Wardrobe1_png.UI_Departure_TipsIcon_Wardrobe1_png'"},	
	}

	self:DisableInteractive()
	self.RandInteract = nil
	self.CurGoldSauserAnimOrder = 0
end

function DepartureBigBannerItemView:OnDestroy()

end

function DepartureBigBannerItemView:OnShow()

end

function DepartureBigBannerItemView:OnHide()

end

function DepartureBigBannerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBanner, self.OnBtnBannerClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnWardrobeL, self.OnBtnWardrobeLClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnWardrobeR, self.OnBtnWardrobeRClicked)
end

function DepartureBigBannerItemView:OnRegisterGameEvent()

end

function DepartureBigBannerItemView:OnRegisterBinder()

end

---@type 切换默认背景图
function DepartureBigBannerItemView:OnSwitchActivity(ActivityID)
	UIUtil.SetIsVisible(self.PanelBannerText, false)
	--self:OnActivityClicked(ActivityID)
	self:PlayAnimation(self.AnimSwitch)
	self:ClearCommonTimer()
	self:ClearGoldSauserTimer()
	self:ClearCollectionTimer()
	self:ClearMakeNoteTimer()
	self:ClearEnbaleInteractiveTimer()
	self.RandInteract = nil
	self:DisableInteractive()
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:StopAnimation(CurAnim)
	end

	if ActivityID == nil then
		return
	end

	local InteractInfo = DepartOfLightVMUtils.GetInteractInfoByActivityID(ActivityID)
    local ModuleID = InteractInfo and InteractInfo.ModuleID
	self.ModuleID = ModuleID
	self.InteractiveDelay = InteractInfo.InteractiveDelay
	self.AutoSwitchInterval = InteractInfo.AutoSwitchInterval
	self.InteractList = InteractInfo.InteractList

	-- 玩法相关整体控件显示与隐藏
	if self.PanelMap then
		for Key, PanelInfo in pairs(self.PanelMap) do
			if PanelInfo.Panel then
				UIUtil.SetIsVisible(PanelInfo.Panel, Key == self.ModuleID)
			end

			if PanelInfo.Bubbles and #PanelInfo.Bubbles > 0 then
				for _, Bubble in ipairs(PanelInfo.Bubbles) do
					UIUtil.SetIsVisible(Bubble, false)
					Bubble:UnRegisterAllTimer()
				end
			end
		end
	end

    -- 各模块具体逻辑处理
	if ModuleID == EModuleID.ModuleIDFATE then
		self:OnSwitchFate()
	elseif ModuleID == EModuleID.ModuleIDAvatar then
		self:OnSwitchCloset()
	elseif ModuleID == EModuleID.ModuleIDGoldSauserMain then
		self:OnSwitchGoldSauser()
	elseif ModuleID == EModuleID.ModuleIDMakerNote then
		self:OnSwitchMakeNote()
	elseif ModuleID == EModuleID.ModuleIDGatherNote then
		self:OnSwitchGatherNote()
	elseif ModuleID == EModuleID.ModuleIDFisherNote then
		self:OnSwitchFishNote()
		self:OnClickedFishNote()
	elseif ModuleID == EModuleID.ModuleIDGamePworld then
		self:OnSwitchFight()
	end
end

function DepartureBigBannerItemView:OnActivityClicked(ActivityID)
	self:PlayAnimation(self.AnimSwitch)
	self:ClearCommonTimer()
	self:ClearGoldSauserTimer()
	self:ClearCollectionTimer()
	self:ClearMakeNoteTimer()
	self:ClearEnbaleInteractiveTimer()
	self.RandInteract = nil
	self:DisableInteractive()
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:StopAnimation(CurAnim)
	end

	if ActivityID == nil then
		return
	end

	local InteractInfo = DepartOfLightVMUtils.GetInteractInfoByActivityID(ActivityID)
    local ModuleID = InteractInfo and InteractInfo.ModuleID
	self.ModuleID = ModuleID
	self.InteractiveDelay = InteractInfo.InteractiveDelay
	self.AutoSwitchInterval = InteractInfo.AutoSwitchInterval
	self.InteractList = InteractInfo.InteractList

	-- 玩法相关整体控件显示与隐藏
	if self.PanelMap then
		for Key, PanelInfo in pairs(self.PanelMap) do
			if PanelInfo.Panel then
				UIUtil.SetIsVisible(PanelInfo.Panel, Key == self.ModuleID)
			end

			if PanelInfo.Bubbles and #PanelInfo.Bubbles > 0 then
				for _, Bubble in ipairs(PanelInfo.Bubbles) do
					UIUtil.SetIsVisible(Bubble, false)
					Bubble:UnRegisterAllTimer()
				end
			end
		end
	end

	-- 延迟显示交互框(共同部分处理)
	local function ShowBubbles()
		local PanelInfo = self.PanelMap[ModuleID]
		local BubbleList = PanelInfo and PanelInfo.Bubbles
		if BubbleList and #BubbleList > 0 then
			local ToShowBubble = BubbleList[1]
			if ToShowBubble then
				UIUtil.SetIsVisible(ToShowBubble, true)
			end
			-- 衣橱显示俩个气泡
			if self.ModuleID == EModuleID.ModuleIDAvatar or self.ModuleID == EModuleID.ModuleIDGoldSauserMain then
				local ToShowBubble2 = BubbleList[2]
				if ToShowBubble2 then
					UIUtil.SetIsVisible(ToShowBubble2, true)
				end
			end
		end
		self:EnbaleInteractive()
	end

	if self.InteractiveDelay and self.InteractiveDelay > 0 then
		self.DelayShowBubbleTimer = self:RegisterTimer(ShowBubbles, self.InteractiveDelay)
	else
		ShowBubbles()
		self:EnbaleInteractive()
	end

    -- 各模块具体逻辑处理
	if ModuleID == EModuleID.ModuleIDFATE then
		self:OnSwitchFate()
	elseif ModuleID == EModuleID.ModuleIDAvatar then
		self:OnSwitchCloset()
	elseif ModuleID == EModuleID.ModuleIDGoldSauserMain then
		self:OnSwitchGoldSauser()
	elseif ModuleID == EModuleID.ModuleIDMakerNote then
		self:OnSwitchMakeNote()
	elseif ModuleID == EModuleID.ModuleIDGatherNote then
		self:OnSwitchGatherNote()
	elseif ModuleID == EModuleID.ModuleIDFisherNote then
		self:OnSwitchFishNote()
	elseif ModuleID == EModuleID.ModuleIDGamePworld then
		self:OnSwitchFight()
	end
end

function DepartureBigBannerItemView:ClearCommonTimer()
	if self.DelayShowBubbleTimer then
		self:UnRegisterTimer(self.DelayShowBubbleTimer)
		self.DelayShowBubbleTimer = nil
	end
end

----------------------------- Fate ------------------------------------
---@type 切换到Fate交互
function DepartureBigBannerItemView:OnSwitchFate()
	local PanelInfo = self.PanelMap[self.ModuleID]
	local BubbleList = PanelInfo and PanelInfo.Bubbles
	if BubbleList and #BubbleList > 0 then
		local Bubble = BubbleList[1]
		if Bubble then
			Bubble:SetIcon(DepartOfLightDefine.BubbleIconAttack)
			Bubble:OnIconChanged(self.InteractiveDelay)
		end
	end
	self:RefreshMonsterIcon()
end

-- 设置怪物图片
function DepartureBigBannerItemView:RefreshMonsterIcon()
	self.RandInteract = DepartOfLightVMUtils.GetRandomInteract(self.InteractList, self.RandInteract)
	if self.RandInteract then
		local MonsterIcons = self.RandInteract.IconPaths
		if MonsterIcons and #MonsterIcons > 0 then
			local Icon = MonsterIcons[1] or ""
			UIUtil.ImageSetBrushFromAssetPath(self.ImgFateMonster, Icon)
		end
	end
end

---@type 点击Fate交互
function DepartureBigBannerItemView:OnClickedFate()
	-- 设置怪物图片
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:PlayAnimation(CurAnim)
		AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.FateAnim)
		local AnimLength = CurAnim:GetEndTime()  
		self:RegisterTimer(self.RefreshMonsterIcon, AnimLength * 0.5) -- 播放动效中替换图片
		local function ShowBubble()
			local PanelInfo = self.PanelMap[self.ModuleID]
			local BubbleList = PanelInfo and PanelInfo.Bubbles
			if BubbleList and #BubbleList > 0 then
				local Bubble = BubbleList[1]
				if Bubble then
					Bubble:OnIconChanged(0)
				end
			end
		end
		self:RegisterTimer(ShowBubble, AnimLength) -- 播放动效中替换图片
		self:EnbaleInteractiveDelay(AnimLength)
	end
end

----------------------------- Fate End------------------------------------


----------------------------- 衣橱交互 ------------------------------------
---@type 切换到衣橱交互
function DepartureBigBannerItemView:OnSwitchCloset()
	self:RefreshAppIcon()
end

-- 设置外观图片
function DepartureBigBannerItemView:RefreshAppIcon()
	self.RandInteract = DepartOfLightVMUtils.GetRandomInteract(self.InteractList, self.RandInteract)
	if self.RandInteract then
		local AppIcons = self.RandInteract.IconPaths
		if AppIcons and #AppIcons >= 3 then
			local MainIcon = AppIcons[1] or ""
			local LAppIcon = AppIcons[2] or ""
			local RAppIcon = AppIcons[3] or ""
			local CurAnim = self.AnimMap[self.ModuleID]
			local AnimLength = 0
			if CurAnim then
				AnimLength = CurAnim:GetEndTime()
			end
			self:SetAppIconInner(MainIcon, LAppIcon, RAppIcon, AnimLength * 0.5)
			self.MainAppIndex = self:GetCloetIndexByIcon(MainIcon)
			self.LAppIconIndex = self:GetCloetIndexByIcon(LAppIcon)
			self.RAppIconIndex = self:GetCloetIndexByIcon(RAppIcon)
		end
	end
end

function DepartureBigBannerItemView:SetAppIconInner(MainIcon, LAppIcon, RAppIcon, Delay)
	if not string.isnilorempty(MainIcon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgWardrobeFigure, MainIcon)
	end

	local PanelInfo = self.PanelMap[self.ModuleID]
	local BubbleList = PanelInfo and PanelInfo.Bubbles
	if BubbleList and #BubbleList > 0 then
		local ToShowBubbleL = BubbleList[1]
		local ToShowBubbleR = BubbleList[2]
		if ToShowBubbleL and not string.isnilorempty(LAppIcon) then
			ToShowBubbleL:SetIcon(LAppIcon)
			local function PlayBubbleAnim()
				local AnimLength = ToShowBubbleL:OnIconChanged()
				self:EnbaleInteractiveDelay(AnimLength)
			end

			if Delay and Delay > 0 then
				self:RegisterTimer(PlayBubbleAnim, Delay)
			end
		end

		if ToShowBubbleR and not string.isnilorempty(RAppIcon) then
			ToShowBubbleR:SetIcon(RAppIcon)
			local function PlayBubbleAnim()
				local AnimLength = ToShowBubbleR:OnIconChanged()
				self:EnbaleInteractiveDelay(AnimLength)
			end

			if Delay and Delay > 0 then
				self:RegisterTimer(PlayBubbleAnim, Delay)
			end
		end
	end
end

---@type 点击衣橱交互动效
function DepartureBigBannerItemView:OnClickedCloset(ChangeAppCallback)
	if not self.CanInteractive then
		return
	end

	self:DisableInteractive()
	self:PlayAnimation(self.AnimClick)
	AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.CloseAnim)
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:PlayAnimation(CurAnim)
		local AnimLength = CurAnim:GetEndTime()
		return AnimLength
	end
end

---@type 播放动效衣橱左气泡
function DepartureBigBannerItemView:OnBtnWardrobeLClicked()
	if not self.CanInteractive then
		return
	end

	local AnimLength = self:OnClickedCloset()
	if self.MainAppIndex == nil or self.LAppIconIndex == nil then
		return
	end
	if self.LAppIconIndex <= 0 or self.MainAppIndex <= 0 then
		return
	end
	local NewLAppIconIndex = self.MainAppIndex
	self.MainAppIndex = self.LAppIconIndex
	self.LAppIconIndex = NewLAppIconIndex

	local NewMainApp = self.AppIconMap and self.AppIconMap[self.MainAppIndex]
	local NewLAppIcon = self.AppIconMap and self.AppIconMap[self.LAppIconIndex]
	if NewMainApp and NewLAppIcon then
		self:SetAppIconInner(NewMainApp.BigIcon, NewLAppIcon.SmallIcon, nil, AnimLength * 0.6)
	end
end



---@type 播放动效衣橱右气泡
function DepartureBigBannerItemView:OnBtnWardrobeRClicked()
	if not self.CanInteractive then
		return
	end
	local AnimLength = self:OnClickedCloset()
	if self.MainAppIndex == nil or self.LAppIconIndex == nil then
		return
	end
	if self.RAppIconIndex <= 0 or self.MainAppIndex <= 0 then
		return
	end
	local NewRAppIconIndex = self.MainAppIndex
	self.MainAppIndex = self.RAppIconIndex
	self.RAppIconIndex = NewRAppIconIndex

	local NewMainApp = self.AppIconMap and self.AppIconMap[self.MainAppIndex]
	local NewRAppIcon = self.AppIconMap and self.AppIconMap[self.RAppIconIndex]
	if NewMainApp and NewRAppIcon then
		self:SetAppIconInner(NewMainApp.BigIcon, nil, NewRAppIcon.SmallIcon, AnimLength * 0.6)
	end
end

---@type 获取外观索引
function DepartureBigBannerItemView:GetCloetIndexByIcon(IconPath)
	if self.AppIconMap == nil then
		return 0
	end

	if string.isnilorempty(IconPath) then
		return 0
	end

	for Index, WardrobelIcon in ipairs(self.AppIconMap) do
		if IconPath == WardrobelIcon.BigIcon or IconPath == WardrobelIcon.SmallIcon then
			return Index
		end
	end
	return 0
end
----------------------------- 衣橱交互 End------------------------------------


----------------------------- 金蝶游乐场交互 ------------------------------------
---@type 切换到金蝶游乐场交互
function DepartureBigBannerItemView:OnSwitchGoldSauser()
	self.CurGoldSauserAnimOrder = 0
	if self.AutoSwitchInterval and self.AutoSwitchInterval > 0 then
		self.AutoSwitchGoldSauserBubbleTimer = self:RegisterTimer(self.SwitchGoldSauserBubble, 0, self.AutoSwitchInterval, -1)
	else
		self:SwitchGoldSauserBubble(self.InteractiveDelay)
	end
end

function DepartureBigBannerItemView:SwitchGoldSauserBubble(InteractDelay)
	-- 左右轮流切换气泡，不点击时，自动切换
	self.CurGoldSauserAnimOrder = self.CurGoldSauserAnimOrder + 1
	local TurnIndex = math.fmod(self.CurGoldSauserAnimOrder, 2)
	--FLOG_ERROR("气泡ID"..TurnIndex)
	local Anim = self.GoldSauserAnimMap[TurnIndex]
	if Anim then
		self:PlayAnimation(Anim)
	end

	-- 设置气泡图片
	self:RefreshGoldSauserIcon(TurnIndex + 1, InteractDelay) -- 从1开始
end

-- 设置金蝶玩法图片
function DepartureBigBannerItemView:RefreshGoldSauserIcon(Index, Delay)
	self.RandInteract = DepartOfLightVMUtils.GetRandomInteract(self.InteractList, self.RandInteract)
	if self.RandInteract then
		local GoldSausers = self.RandInteract.IconPaths
		if GoldSausers and #GoldSausers >= 1 then
			local GoldSauserIcon = GoldSausers[1] or ""
			local PanelInfo = self.PanelMap[self.ModuleID]
			local BubbleList = PanelInfo and PanelInfo.Bubbles
			if BubbleList and #BubbleList > 0 then
				local Bubble = BubbleList[Index]
				if Bubble then
					Bubble:SetIcon(GoldSauserIcon)
					local AnimLength = Bubble:OnIconChanged(Delay)
					self:EnbaleInteractiveDelay(AnimLength)
				end
			end
		end
	end
end

---@type 点击金蝶游乐场交互
function DepartureBigBannerItemView:OnClickedGoldSauser()
	self:ClearGoldSauserTimer()
	self:SwitchGoldSauserBubble(0)
end

-- 清除金蝶气泡计时器
function DepartureBigBannerItemView:ClearGoldSauserTimer()
	if self.AutoSwitchGoldSauserBubbleTimer then
		self:UnRegisterTimer(self.AutoSwitchGoldSauserBubbleTimer)
		self.AutoSwitchGoldSauserBubbleTimer = nil
	end
end
----------------------------- 金蝶游乐场交互 End------------------------------------


----------------------------- 制作笔记交互 ------------------------------------
---@type 切换到制作笔记交互
function DepartureBigBannerItemView:OnSwitchMakeNote()
	if self.AutoSwitchInterval and self.AutoSwitchInterval > 0 then
		self.AutoRefreshMakeNoteIconTimer = self:RegisterTimer(self.RefreshMakeNoteIcon, 0, self.AutoSwitchInterval, -1)
	else
		self:RefreshMakeNoteIcon(self.InteractiveDelay)
	end
end

-- 设置制作玩法图片
function DepartureBigBannerItemView:RefreshMakeNoteIcon(Delay)
	self.RandInteract = DepartOfLightVMUtils.GetRandomInteract(self.InteractList, self.RandInteract)
	if self.RandInteract then
		local MakeNoteIcons = self.RandInteract.IconPaths
		local PanelInfo = self.PanelMap[self.ModuleID]
		local BubbleList = PanelInfo and PanelInfo.Bubbles
		if BubbleList and #BubbleList > 0 then
			local ToShowBubble = BubbleList[1]
			if ToShowBubble then
				local MakeNoteIconL = MakeNoteIcons and MakeNoteIcons[1] or ""
				local MakeNoteIconR = MakeNoteIcons and MakeNoteIcons[2] or ""
				ToShowBubble:SetIcon(MakeNoteIconL, MakeNoteIconR)
				local AnimLength = ToShowBubble:OnIconChanged(Delay)
				self:EnbaleInteractiveDelay(AnimLength)
			end
		end
	end
end

---@type 点击制作笔记交互
function DepartureBigBannerItemView:OnClickedMakeNote()
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:PlayAnimation(CurAnim)
	end
	
	self:ClearMakeNoteTimer()
	self:RefreshMakeNoteIcon()
end

-- 清除制作气泡计时器
function DepartureBigBannerItemView:ClearMakeNoteTimer()
	if self.AutoRefreshMakeNoteIconTimer then
		self:UnRegisterTimer(self.AutoRefreshMakeNoteIconTimer)
		self.AutoRefreshMakeNoteIconTimer = nil
	end
end
----------------------------- 制作笔记交互 End------------------------------------

----------------------------- 采集笔记交互 ------------------------------------
---@type 切换到采集笔记交互
function DepartureBigBannerItemView:OnSwitchGatherNote()
	if self.AutoSwitchInterval and self.AutoSwitchInterval > 0 then
		self.AutoRefreshCollectionIconTimer = self:RegisterTimer(self.RefreshCollectionIcon, 0, self.AutoSwitchInterval, -1)
	else
		self:RefreshCollectionIcon(self.InteractiveDelay)
	end
end

---@type 点击采集笔记交互
function DepartureBigBannerItemView:OnClickedGatherNote()
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:PlayAnimation(CurAnim)
	end
	-- 切换随机采集物图片
	self:RefreshCollectionIcon()
	self:ClearCollectionTimer() -- 停止自动切换
end

-- 设置采集玩法图片
function DepartureBigBannerItemView:RefreshCollectionIcon(Delay)
	self.RandInteract = DepartOfLightVMUtils.GetRandomInteract(self.InteractList, self.RandInteract)
	if self.RandInteract then
		local CollectionIcons = self.RandInteract.IconPaths
		local PanelInfo = self.PanelMap[self.ModuleID]
		local BubbleList = PanelInfo and PanelInfo.Bubbles
		if BubbleList and #BubbleList > 0 then
			local ToShowBubble = BubbleList[1]
			if ToShowBubble then
				local CollectionIcon = CollectionIcons and CollectionIcons[1] or ""
				ToShowBubble:SetIcon(CollectionIcon)
				local AnimLength = ToShowBubble:OnIconChanged(Delay)
				self:EnbaleInteractiveDelay(AnimLength)
			end
		end
	end
end

-- 清除采集气泡计时器
function DepartureBigBannerItemView:ClearCollectionTimer()
	if self.AutoRefreshCollectionIconTimer then
		self:UnRegisterTimer(self.AutoRefreshCollectionIconTimer)
		self.AutoRefreshCollectionIconTimer = nil
	end
end
----------------------------- 采集笔记交互 End------------------------------------


----------------------------- 钓鱼笔记 ------------------------------------
---@type 切换到钓鱼笔记交互
function DepartureBigBannerItemView:OnSwitchFishNote()
	self:RefreshFishAndExclamationIcon(false)
end

---@type 设置鱼类和感叹号图片
function DepartureBigBannerItemView:RefreshFishAndExclamationIcon(IsPlayBubbleAnim)
	if self.ExclamationNumIconList == nil or next(self.ExclamationNumIconList) == nil then
		return
	end

	for _, NumIcon in ipairs(self.ExclamationNumIconList) do
		UIUtil.SetIsVisible(NumIcon, false)
	end

	-- 随机感叹号数量（对应鱼类级别）
	local RandomLevel = math.random(#self.ExclamationNumIconList)
	for Index = 1, RandomLevel do
		local NumIcon = self.ExclamationNumIconList[Index]
		if NumIcon then
			UIUtil.SetIsVisible(NumIcon, true)
		end
	end

	if RandomLevel < 3 then
		AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.FishNote1)
	else
		AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.FishNote3)
	end

	self.RandInteract = DepartOfLightVMUtils.GetRandomInteract(self.InteractList, self.RandInteract)
	if self.RandInteract then
		local FishIcons = self.RandInteract.IconPaths
		local PanelInfo = self.PanelMap[self.ModuleID]
		local BubbleList = PanelInfo and PanelInfo.Bubbles
		if BubbleList and #BubbleList > 0 then
			-- 设置鱼类图片
			local FishIcon = FishIcons and FishIcons[RandomLevel] or ""
			UIUtil.ImageSetBrushFromAssetPath(self.ImgFish, FishIcon)

			local ToShowBubble = BubbleList[1]
			if ToShowBubble then
				-- 设置表情
				local EmotionIcon = DepartOfLightDefine.InteractFishNoteEmotionPath[RandomLevel]
				if EmotionIcon then
					ToShowBubble:SetIcon(EmotionIcon)
					if IsPlayBubbleAnim then
						local CurAnim = self.AnimMap[self.ModuleID]
						if CurAnim then
							local AnimLength = CurAnim:GetEndTime()
							ToShowBubble:OnIconChanged(AnimLength * 0.9)
						end
					end
				end
			end
		end
	end
end

---@type 点击钓鱼笔记交互
function DepartureBigBannerItemView:OnClickedFishNote()
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:PlayAnimation(CurAnim)
		local AnimLength = CurAnim:GetEndTime()
		self:EnbaleInteractiveDelay(AnimLength)
	end
	self:RefreshFishAndExclamationIcon(true)
end
----------------------------- 钓鱼笔记 End------------------------------------


----------------------------- 战斗职业 ------------------------------------
---@type 切换到战斗职业交互
function DepartureBigBannerItemView:OnSwitchFight()
	-- body
end

---@type 点击战斗职业交互
function DepartureBigBannerItemView:OnClickedFight()
	local CurAnim = self.AnimMap[self.ModuleID]
	if CurAnim then
		self:PlayAnimation(CurAnim)
		AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.Battle)
		local AnimLength = CurAnim:GetEndTime()
		self:EnbaleInteractiveDelay(AnimLength)
	end
end
----------------------------- 战斗职业 End------------------------------------


---@type 播放当前玩法动效
function DepartureBigBannerItemView:OnBtnBannerClicked()
	if not self.CanInteractive then
		return
	end
	self:PlayAnimation(self.AnimClick)
	local ClickCallback = self.ClickCallbackMap[self.ModuleID]
	if ClickCallback then
		self:DisableInteractive()
		ClickCallback(self)
	end
end

function DepartureBigBannerItemView:EnbaleInteractiveDelay(AnimLength)
	self:ClearEnbaleInteractiveTimer()
	self.EnbaleInteractiveTimer = self:RegisterTimer(self.EnbaleInteractive, AnimLength) -- 播放动效完后开启交互功能
end

function DepartureBigBannerItemView:ClearEnbaleInteractiveTimer()
	if self.EnbaleInteractiveTimer then
		self:UnRegisterTimer(self.EnbaleInteractiveTimer)
		self.EnbaleInteractiveTimer = nil
	end
end

function DepartureBigBannerItemView:EnbaleInteractive()
	self.CanInteractive = true
end

function DepartureBigBannerItemView:DisableInteractive()
	self.CanInteractive = false
end






return DepartureBigBannerItemView