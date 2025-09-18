---
--- Author: anypkvcai
--- DateTime: 2021-04-10 10:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ProtoRes = require("Protocol/ProtoRes")
local LoginMgr = require("Game/Login/LoginMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ChatMgr = require("Game/Chat/ChatMgr")
local ChatVM = require("Game/Chat/ChatVM")
local MajorUtil = require ("Utils/MajorUtil")
local MsgTipsID = require("Define/MsgTipsID")
local ChatDefine = require("Game/Chat/ChatDefine")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ChatSetting = require("Game/Chat/ChatSetting")
local AudioUtil = require("Utils/AudioUtil")

local ModuleType = ProtoRes.module_type
local ChatHeadTipsTime = 3

local PersonChatTipsSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/system/SE_UI/Play_SE_UI_SE_UI_tell_01.Play_SE_UI_SE_UI_tell_01'"

---@class MainLBottomPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonEmotion UFButton
---@field ButtonHide UFButton
---@field ButtonPhoto UFButton
---@field ButtonShow UFButton
---@field ComRedDotChat1 CommonRedDotView
---@field ComRedDotChat2 CommonRedDotView
---@field CommPlayerHeadSlot CommPlayerHeadSlotView
---@field CommPlayerHeadSlot2 CommPlayerHeadSlotView
---@field FBtnChat UFButton
---@field FBtnHead UFButton
---@field FBtnHead2 UFButton
---@field IconEmotion UFImage
---@field IconHide UFImage
---@field IconPhoto UFImage
---@field ImgArrowDown UFImage
---@field ImgProbar URadialImage
---@field PanelChatMsg UFCanvasPanel
---@field PanelHide2 UFCanvasPanel
---@field PanelMentorTips UFCanvasPanel
---@field PanelRedDotChat1 UFCanvasPanel
---@field PanelRedDotChat2 UFCanvasPanel
---@field PanelShow UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TableViewChatMsg UTableView
---@field AnimHeadNews2Show UWidgetAnimation
---@field AnimHeadNewsShow UWidgetAnimation
---@field AnimMentorTipsIn UWidgetAnimation
---@field AnimMentorTipsOut UWidgetAnimation
---@field AnimPanelShowFold UWidgetAnimation
---@field AnimPanelShowUnFold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainLBottomPanelView = LuaClass(UIView, true)

function MainLBottomPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonEmotion = nil
	--self.ButtonHide = nil
	--self.ButtonPhoto = nil
	--self.ButtonShow = nil
	--self.ComRedDotChat1 = nil
	--self.ComRedDotChat2 = nil
	--self.CommPlayerHeadSlot = nil
	--self.CommPlayerHeadSlot2 = nil
	--self.FBtnChat = nil
	--self.FBtnHead = nil
	--self.FBtnHead2 = nil
	--self.IconEmotion = nil
	--self.IconHide = nil
	--self.IconPhoto = nil
	--self.ImgArrowDown = nil
	--self.ImgProbar = nil
	--self.PanelChatMsg = nil
	--self.PanelHide2 = nil
	--self.PanelMentorTips = nil
	--self.PanelRedDotChat1 = nil
	--self.PanelRedDotChat2 = nil
	--self.PanelShow = nil
	--self.RichTextTips = nil
	--self.TableViewChatMsg = nil
	--self.AnimHeadNews2Show = nil
	--self.AnimHeadNewsShow = nil
	--self.AnimMentorTipsIn = nil
	--self.AnimMentorTipsOut = nil
	--self.AnimPanelShowFold = nil
	--self.AnimPanelShowUnFold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainLBottomPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComRedDotChat1)
	self:AddSubView(self.ComRedDotChat2)
	self:AddSubView(self.CommPlayerHeadSlot)
	self:AddSubView(self.CommPlayerHeadSlot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainLBottomPanelView:OnInit()
    -- self.ShowButtonEmotion = true
	-- self.ShowButtonPhoto = LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_PHOTO) and false
	-- self.PhotoEnable = false
	self.ChatHeadTipsTime = 0

	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewChatMsg)
	self.TableViewAdapter:SetItemChangedCallback(self.OnChatMsgItemChanged)

	self.Binders = {
		-- { "IsTestVersion", UIBinderValueChangedCallback.New(self, nil, self.OnTestVersionChanged) },
		{ "EmotionVisible",  UIBinderSetIsVisible.New(self, self.ButtonEmotion, false, true)},
		{ "PhotoVisible",  UIBinderSetIsVisible.New(self, self.ButtonPhoto, false, true)},

		{ "PersonChatHeadTipsPlayer", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPersonChatHeadTipsPlayer) },
	}

	self.BindersChat = {
		{ "ChatInfoVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedChatInfoVisible) },
		{ "BindableListMsg", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	}

	-- 清除头像提示
	MainPanelVM:SetPersonChatHeadTipsPlayer()
end

function MainLBottomPanelView:OnDestroy()

end

function MainLBottomPanelView:OnShow()
    -- fixed 后台偶现不会发送CS_CHAT_CMD_PRIVATE_CHAT_MSG_NTF消息给前台，导致本地私聊未加载
    ChatMgr:LoadPrivateSessions()
    ChatMgr:LoadPrivateChatLogs()
    -- local _show = self.ShowButtonEmotion and LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_MOTION)
    -- UIUtil.SetIsVisible(self.ButtonEmotion, _show, _show)

	-- local bShowBtnPhoto = self.ShowButtonPhoto 
	-- bShowBtnPhoto = true --临时开放
	-- UIUtil.SetIsVisible(self.ButtonPhoto, bShowBtnPhoto, bShowBtnPhoto)

	self:SetMainLBottomPanelVisible(MainPanelVM.IsShowMainLBottomPanel)
	self:OnChatMsgItemChanged()

	-- 私聊小红点
	local IsOpen = ChatSetting.IsOpenPrivateRedDotTip()
	self:UpdateChatRedDotPanelsVisible(IsOpen)
end

function MainLBottomPanelView:OnHide()
	self:ClosePersonChatTipsTimer()

	-- 清除头像提示
	MainPanelVM:SetPersonChatHeadTipsPlayer()
end

function MainLBottomPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtnChat, self.OnClickedButtonChat)

	UIUtil.AddOnClickedEvent(self, self.FBtnHead, self.OnClickedButtonHead)
	UIUtil.AddOnClickedEvent(self, self.FBtnHead2, self.OnClickedButtonHead)

	UIUtil.AddOnClickedEvent(self, self.ButtonEmotion, self.OnClickButtonEmotion)
	UIUtil.AddOnClickedEvent(self, self.ButtonHide, self.OnClickButtonHide)
	UIUtil.AddOnClickedEvent(self, self.ButtonShow, self.OnClickButtonShow)
	UIUtil.AddOnClickedEvent(self, self.ButtonPhoto, self.OnClickedButtonPhoto)
end

function MainLBottomPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ShowUI, self.OnShowView)
    self:RegisterGameEvent(EventID.ChatOpenPrivateRedDotTipChanged, self.OnEvenOpenPrivateRedDotTipChanged)
end

function MainLBottomPanelView:OnRegisterTimer()

end

function MainLBottomPanelView:OnRegisterBinder()
	self:RegisterBinders(MainPanelVM, self.Binders)

	local VM = ChatVM.ComprehensiveChannelVM
	if VM then
		self:RegisterBinders(VM, self.BindersChat)
	end
end

function MainLBottomPanelView:SetMainLBottomPanelVisible(bVisible, IsPlayAnimation)
	if bVisible and not LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_CHAT, true) then
		return
	end

	MainPanelVM.IsShowMainLBottomPanel = bVisible 
	MainPanelVM:SetChatInfoVisible(bVisible)

	local Anim = bVisible and self.AnimPanelShowUnFold or self.AnimPanelShowFold
	local StartAtTime = IsPlayAnimation and 0 or Anim:GetEndTime()
	self:PlayAnimation(Anim, StartAtTime)
end

function MainLBottomPanelView:OnClickButtonShow()
	self:SetMainLBottomPanelVisible(true, true)
end

function MainLBottomPanelView:OnClickButtonHide()
	self:SetMainLBottomPanelVisible(false, true)
end

function MainLBottomPanelView:OnClickButtonEmotion()
	if not LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_MOTION, true) then
		return
	end

	-- 死亡状态下不支持操作
    if MajorUtil.IsMajorDead() == true then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.DeadStateCantControls)
        return
    end

	if MajorUtil.IsGatherProf() and _G.GatherMgr:IsGatherState() then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherStateCantControls)
		return
	end
	
	_G.EmotionMgr:ShowEasyMainPanel()
end

function MainLBottomPanelView:OnClickedButtonPhoto()
	_G.U2pmMgr:ToggleAutoFight()
end

--function MainLBottomPanelView:OnTestVersionChanged(Value)
--	if not Value then
--		self:PlayAnimation(self.AnimPanelShowFold)
--	end
--end

--业务系统使用的时候，换这个接口MainPanelVM:SetEmotionVisible
-- function MainLBottomPanelView:SetButtonEmotionVisible(IsVisible)
--     -- if (IsVisible) then
--     --     self.ShowButtonEmotion = true
--     --     UIUtil.SetIsVisible(self.ButtonEmotion, true, true)
--     -- else
--     --     self.ShowButtonEmotion = false
--     --     UIUtil.SetIsVisible(self.ButtonEmotion, false, false)
--     -- end
-- end

--业务系统使用的时候，换这个接口MainPanelVM:SetPhotoVisible
-- function MainLBottomPanelView:SetButtonPhotoVisible(IsVisible)
-- 	-- if not self.PhotoEnable then 
-- 	-- 	return 
-- 	-- end

-- 	-- self.ShowButtonPhoto = IsVisible
	
--     -- if (IsVisible) then
--     --     UIUtil.SetIsVisible(self.ButtonPhoto, true, true)
--     -- else
--     --     UIUtil.SetIsVisible(self.ButtonPhoto, false, false)
--     -- end
-- end

function MainLBottomPanelView:OnShowView(ViewID)
	if ViewID == UIViewID.ChatMainPanel then
		-- 清除头像提示
		MainPanelVM:SetPersonChatHeadTipsPlayer()
	end
end

function MainLBottomPanelView:UpdateChatRedDotPanelsVisible(IsOpen)
	UIUtil.SetIsVisible(self.PanelRedDotChat1, IsOpen)
	UIUtil.SetIsVisible(self.PanelRedDotChat2, IsOpen)
end

function MainLBottomPanelView:OnEvenOpenPrivateRedDotTipChanged()
	local IsOpen = ChatSetting.IsOpenPrivateRedDotTip()
	self:UpdateChatRedDotPanelsVisible(IsOpen)
end

-------------------------------------------------------------------------------------------------------
--- 聊天

function MainLBottomPanelView:OnChatMsgItemChanged()
	self.TableViewAdapter:ScrollToBottom()
end

function MainLBottomPanelView:ShowChatInfoTips(TipsText, ShowTime)
	self:PlayAnimation(self.AnimMentorTipsIn)
	self.RichTextTips:SetText(TipsText)
	self.TipsCutTime = 0
	self.TipsShowTime = ShowTime
	local CountdownFun = function()
		self.TipsCutTime = self.TipsCutTime + 0.05
		if self.TipsCutTime <= self.TipsShowTime then
			self.ImgProbar:SetPercent(self.TipsCutTime / self.TipsShowTime)
		else
			self:PlayAnimation(self.AnimMentorTipsOut)
			self:UnRegisterTimer(self.TipsTimer)
			self.TipsTimer = nil
		end
	end
	self.TipsTimer = self:RegisterTimer(CountdownFun , 0, 0.05, 0)
end

function MainLBottomPanelView:OnValueChangedPersonChatHeadTipsPlayer( RoleID )
	if nil == RoleID or RoleID <= 0 then
		UIUtil.SetIsVisible(self.ButtonShow, true, true)
		UIUtil.SetIsVisible(self.ComRedDotChat2, true)
		UIUtil.SetIsVisible(self.FBtnHead, false)
		UIUtil.SetIsVisible(self.FBtnHead2, false)
		return
	end

    --聊天主界面打开状态，无需做头像提示
    if UIViewMgr:IsViewVisible(UIViewID.ChatMainPanel) then
		MainPanelVM:SetPersonChatHeadTipsPlayer()
        return
    end

	local CurTime = os.time() 
	local LastTime = self.ChatHeadTipsTime or 0
	if CurTime - LastTime < ChatHeadTipsTime then
		return
    end

	self.ChatHeadTipsTime = CurTime

	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
		if nil == RoleVM then
			MainPanelVM:SetPersonChatHeadTipsPlayer()
			return
		end

		-- 私聊提示音
		AudioUtil.LoadAndPlay2DSound(PersonChatTipsSoundPath)

		UIUtil.SetIsVisible(self.FBtnHead, true, true)
		UIUtil.SetIsVisible(self.FBtnHead2, true, true)
		UIUtil.SetIsVisible(self.ComRedDotChat2, false)
		UIUtil.SetIsVisible(self.ButtonShow, false)

		self.CommPlayerHeadSlot:SetInfo(RoleID)
		self.CommPlayerHeadSlot2:SetInfo(RoleID)

		self:ClosePersonChatTipsTimer()
		self.PersonChatTipsTimer = _G.TimerMgr:AddTimer(self, self.OnPersonChatTipsTimerCallback, ChatHeadTipsTime)
	end)
end

function MainLBottomPanelView:ClosePersonChatTipsTimer()
	if self.PersonChatTipsTimer ~= nil then
		_G.TimerMgr:CancelTimer(self.PersonChatTipsTimer)
		self.PersonChatTipsTimer = nil
	end
end

function MainLBottomPanelView:OnPersonChatTipsTimerCallback()
	-- 清除头像提示
	MainPanelVM:SetPersonChatHeadTipsPlayer()
end

function MainLBottomPanelView:OnValueChangedChatInfoVisible(Visible)
	UIUtil.SetIsVisible(self.PanelShow, Visible)
	UIUtil.SetIsVisible(self.PanelChatMsg, Visible)
end

function MainLBottomPanelView:OnClickedButtonChat()
	if _G.UIViewMgr:IsViewVisible(UIViewID.ChatMainPanel) then
		return
	end

	ChatMgr:ShowChatView(nil, nil, nil, nil, true)
end

function MainLBottomPanelView:OnClickedButtonHead()
	local Channel = ChatDefine.ChatChannel.Person
	local ChannelID = MainPanelVM.PersonChatHeadTipsPlayer
	ChatMgr:ShowChatView(Channel, ChannelID, nil, nil, true)
end

-------------------------------------------------------------------------------------------------------

return MainLBottomPanelView