---
--- Author: Administrator
--- DateTime: 2024-03-05 10:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local AtlasEntranceCfg = require("TableCfg/AtlasEntranceCfg")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local MagicCardCollectionDefine = require("Game/MagicCardCollection/MagicCardCollectionDefine")
local UIViewID = require("Define/UIViewID")
local ModuleOpenMgr = require("Game/ModuleOpen/ModuleOpenMgr")
local AudioUtil = require("Utils/AudioUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")

local LSTR = _G.LSTR
local MusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_book_popup.Play_UI_book_popup'"
local ModuleType = ProtoRes.module_type

---@class GuideMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn1 UFButton
---@field Btn10 UFButton
---@field Btn2 UFButton
---@field Btn3 UFButton
---@field Btn4 UFButton
---@field Btn5 UFButton
---@field Btn6 UFButton
---@field Btn7 UFButton
---@field Btn8 UFButton
---@field Btn9 UFButton
---@field BtnClose CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field ImgLock1 UFImage
---@field ImgLock10 UFImage
---@field ImgLock2 UFImage
---@field ImgLock3 UFImage
---@field ImgLock4 UFImage
---@field ImgLock5 UFImage
---@field ImgLock6 UFImage
---@field ImgLock7 UFImage
---@field ImgLock8 UFImage
---@field ImgLock9 UFImage
---@field Panel5 UFCanvasPanel
---@field Panel6 UFCanvasPanel
---@field RedDot10 CommonRedDotView
---@field RedDot2 CommonRedDotView
---@field RedDot3 CommonRedDotView
---@field RedDot4 CommonRedDotView
---@field RedDot9 CommonRedDotView
---@field RedDotMount CommonRedDotView
---@field SpineGuidePageturn USpineWidget
---@field Text1 UFTextBlock
---@field Text10 UFTextBlock
---@field Text2 UFTextBlock
---@field Text3 UFTextBlock
---@field Text4 UFTextBlock
---@field Text5 UFTextBlock
---@field Text6 UFTextBlock
---@field Text7 UFTextBlock
---@field Text8 UFTextBlock
---@field Text9 UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimMainLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GuideMainPanelView = LuaClass(UIView, true)

function GuideMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn1 = nil
	--self.Btn10 = nil
	--self.Btn2 = nil
	--self.Btn3 = nil
	--self.Btn4 = nil
	--self.Btn5 = nil
	--self.Btn6 = nil
	--self.Btn7 = nil
	--self.Btn8 = nil
	--self.Btn9 = nil
	--self.BtnClose = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.ImgLock1 = nil
	--self.ImgLock10 = nil
	--self.ImgLock2 = nil
	--self.ImgLock3 = nil
	--self.ImgLock4 = nil
	--self.ImgLock5 = nil
	--self.ImgLock6 = nil
	--self.ImgLock7 = nil
	--self.ImgLock8 = nil
	--self.ImgLock9 = nil
	--self.Panel5 = nil
	--self.Panel6 = nil
	--self.RedDot10 = nil
	--self.RedDot2 = nil
	--self.RedDot3 = nil
	--self.RedDot4 = nil
	--self.RedDot9 = nil
	--self.RedDotMount = nil
	--self.SpineGuidePageturn = nil
	--self.Text1 = nil
	--self.Text10 = nil
	--self.Text2 = nil
	--self.Text3 = nil
	--self.Text4 = nil
	--self.Text5 = nil
	--self.Text6 = nil
	--self.Text7 = nil
	--self.Text8 = nil
	--self.Text9 = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimMainLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GuideMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.RedDot10)
	self:AddSubView(self.RedDot2)
	self:AddSubView(self.RedDot3)
	self:AddSubView(self.RedDot4)
	self:AddSubView(self.RedDot9)
	self:AddSubView(self.RedDotMount)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GuideMainPanelView:OnInit()
	self.BtnList = {}
	self.BtnName = {}
	self.LockList = {}
	local AtlasInfo = self:GetAtlasInfo()
	for i = 1, #AtlasInfo do
		local Btn = "Btn" .. tostring(i)
		local Text = "Text" .. tostring(i)
		local Lock = "ImgLock" .. tostring(i)
		table.insert(self.BtnList, self[Btn])
		table.insert(self.BtnName, self[Text])
		table.insert(self.LockList, self[Lock])
	end
	self.AtlasInfo = AtlasInfo

	self.RedDot4:SetRedDotIDByID(MagicCardCollectionDefine.CardRedDotID)
end

function GuideMainPanelView:OnDestroy()

end

function GuideMainPanelView:OnShow()
	_G.TouringBandMgr:QueryCollectionReq()
	self.TextTitle:SetText(LSTR(1180001))
	for i = 1, #self.AtlasInfo do
		local IsUnLock = self:AtlasIsUnLock(self.AtlasInfo[i].OpenID)
		if self.AtlasInfo[i].ID == 6  then
			local bShow = _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_MOUNT_PREVIEW)
			UIUtil.SetIsVisible(self.LockList[i], bShow and (not IsUnLock))		--Module锁优先
		elseif self.AtlasInfo[i].ID == 5 then
			local bShow = _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_COMPANION_PREVIEW)
			UIUtil.SetIsVisible(self.LockList[i], not bShow or not IsUnLock)
		else
			UIUtil.SetIsVisible(self.LockList[i], not IsUnLock)
		end
		self.BtnName[i]:SetText(self.AtlasInfo[i].Name)
	end

	local function PlayLoopAni()
		self:PlayAnimation(self.AnimMainLoop, 0, 0)	
	end

	self.DelayTimerID = self:RegisterTimer(PlayLoopAni, 2.3, 0, 1)

	AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), MusicPath, true)
end

function GuideMainPanelView:OnHide()

end

function GuideMainPanelView:OnRegisterUIEvent()
	for i = 1, #self.AtlasInfo do
		local Data = {}
		Data.AtlasID = self.AtlasInfo[i].ID
		Data.ModuleID = ModuleOpenMgr:CheckIDType(self.AtlasInfo[i].OpenID)
		UIUtil.AddOnClickedEvent(self, self.BtnList[i], self.AtlasClick, Data)
	end
end

function GuideMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ExitRevertState, self.OnCloseView)
end

function GuideMainPanelView:OnRegisterBinder()

end

function GuideMainPanelView:AtlasClick(Data)
	local IsUnLock = true
	if Data and Data.ModuleID then
		IsUnLock = ModuleOpenMgr:CheckOpenState(Data.ModuleID)
	end

	--首测屏蔽逻辑
	if Data and Data.AtlasID then
		if Data.AtlasID == 6 then
			--坐骑图鉴
			local bShow = _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_MOUNT_PREVIEW)
			IsUnLock = bShow and IsUnLock
		elseif Data.AtlasID == 5 then
			--宠物图鉴
			local bShow = _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_COMPANION_PREVIEW)
			IsUnLock = bShow and IsUnLock
		end
	end

	if not IsUnLock then
		local Tips = LSTR(1180003)
		_G.MsgTipsUtil.ShowTips(Tips)
		return
	end
	
	if Data and Data.AtlasID then
		local AtlasID = Data.AtlasID
		--根据图鉴入口表ID
		if AtlasID == 1 then
			-- Fate机遇临门图鉴
			_G.FateMgr:ShowFateArchive()
		elseif AtlasID == 2 then
			_G.ChocoboCodexArmorMgr:OpenChocoboCodexArmorPanel()
		elseif AtlasID == 3 then
			MusicPlayerMgr:OpenMusicAtlas()
		elseif AtlasID == 4 then
			MagicCardCollectionMgr:ShowMagicCardCollectionMainPanel()
		elseif AtlasID == 5 then
			_G.CompanionMgr:OpenCompanionArchive()
		elseif AtlasID == 6 then
			_G.MountMgr:OpenMountArchive()
		elseif AtlasID == 7 then
			_G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, {OpenSource = 7})  --传奇武器
		elseif AtlasID == 8 then
			_G.UIViewMgr:ShowView(UIViewID.FishGuide)
		elseif AtlasID == 9 then		
			_G.DiscoverNoteMgr:OpenDiscoverNoteMainPanel() --探索笔记
		elseif AtlasID == 10 then
			_G.TouringBandMgr:OpenTouringBandView(self.ViewID) -- 巡回乐团
		end
	end
end

function GuideMainPanelView:GetAtlasInfo()
	local Cfg = AtlasEntranceCfg:FindAllCfg()
	return Cfg
end

function GuideMainPanelView:AtlasIsUnLock(OpenID)
	local ModuleID = ModuleOpenMgr:CheckIDType(OpenID)
	local IsUnLock = ModuleOpenMgr:CheckOpenState(ModuleID)
	return IsUnLock
end

function GuideMainPanelView:OnCloseView()
	self:OnHide()
end

return GuideMainPanelView