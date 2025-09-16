local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HistoryVM = require("Game/Interactive/View/New/NpcDialogueHistoryVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AudioUtil = require("Utils/AudioUtil")
local NpcDialogVM = require("Game/Story/NpcDialogPlayVM")
local SequencePlayerVM = require("Game/Story/SequencePlayerVM")

---@class NPCPlotReviewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BackpackEmpty CommBackpackEmptyView
---@field TableViewDialogue UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCPlotReviewItemView = LuaClass(UIView, true)

function NPCPlotReviewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BackpackEmpty = nil
	--self.TableViewDialogue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCPlotReviewItemView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDialogue)
end

function NPCPlotReviewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BackpackEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY BackBtn

end

function NPCPlotReviewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self.BackBtn, self.BackBtn.Button, self.OnClickClose)
end

function NPCPlotReviewItemView:OnShow()
	self:CheckListIsEmpty()
	self.TextTitle:SetText(LSTR(1280008))
	self.BackpackEmpty:SetTipsContent(LSTR(90030))
	self.TableViewAdapter:ScrollToBottom()

	self.SoundItemIndex = 0
	self.PlayingSoundID = 0
	self.bHoldChoicePanel = false
	local bIsSeq = self.Params.bIsSeq
	if bIsSeq  then
		--先存一下回顾之前的状态
		self.HoldChoicePanelVisible = SequencePlayerVM.bChoicePanelVisible
		SequencePlayerVM.bChoicePanelVisible = false

		self.HoldTopButtonGroupVisible = SequencePlayerVM.bHideAllTopButton
		SequencePlayerVM.bHideAllTopButton = true

		SequencePlayerVM.bTalkPanelVisible = false
	else
		self.HoldChoicePanelVisible = NpcDialogVM.bChoicePanelVisible
		NpcDialogVM.bChoicePanelVisible = false

		self.HoldTopButtonGroupVisible = NpcDialogVM.bTopButtonGroupVisible
		NpcDialogVM.bTopButtonGroupVisible = false

		self.HoldTalkPanelVisible = NpcDialogVM.bTalkPanelVisible
		NpcDialogVM.bTalkPanelVisible = false
		local InteractiveMainView = _G.UIViewMgr:FindView(_G.UIViewID.InteractiveMainPanel)
		if not InteractiveMainView then return end
		_G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, false)
	end
end

function NPCPlotReviewItemView:OnHide()
	local bIsSeq = self.Params.bIsSeq
	if bIsSeq then
		SequencePlayerVM.bChoicePanelVisible = self.HoldChoicePanelVisible
		SequencePlayerVM.bHideAllTopButton = self.HoldTopButtonGroupVisible
		SequencePlayerVM.bTalkPanelVisible = SequencePlayerVM.bDialogUpdated
		SequencePlayerVM:ResumeAutoPlay()
	else
		NpcDialogVM:ResumeAutoPlay()
		NpcDialogVM.bChoicePanelVisible = self.HoldChoicePanelVisible
		NpcDialogVM.bTopButtonGroupVisible = self.HoldTopButtonGroupVisible
		NpcDialogVM.bTalkPanelVisible = self.HoldTalkPanelVisible
		local InteractiveMainView = _G.UIViewMgr:FindView(_G.UIViewID.InteractiveMainPanel)
		if not InteractiveMainView then return end
		_G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, true)
	end
	UIUtil.SetInputMode_UIOnly()
	_G.CommonUtil.HideJoyStick()
	self:StopPrevAudio(true)
end

function NPCPlotReviewItemView:OnRegisterBinder()
	local Binders = {
		{ "HistoryDialogList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
	}
	self:RegisterBinders(HistoryVM, Binders)
end

function NPCPlotReviewItemView:CheckListIsEmpty()
	if not HistoryVM.HistoryDialogList or not next(HistoryVM.HistoryDialogList) then
		UIUtil.SetIsVisible(self.BackpackEmpty, true)
	else
		UIUtil.SetIsVisible(self.BackpackEmpty, false)
	end
end

function NPCPlotReviewItemView:OnClickClose()
	if self.Params.bIsSeq then
		SequencePlayerVM.bInDialogHistory = false
	else
		self:Hide()
	end
end

function NPCPlotReviewItemView:PlayItemAudio(ItemData)
	if (ItemData.Index == 0) or (ItemData.VoiceName == nil) then return end

	self.SoundItemIndex = ItemData.Index
	self.PlayingSoundID = AudioUtil.Play2DVoice(ItemData.VoiceName)
end

---@return number
function NPCPlotReviewItemView:StopPrevAudio(bIgnoreItemAnim)
	if self.PlayingSoundID ~= 0 then
		AudioUtil.StopSound(self.PlayingSoundID)
		self.PlayingSoundID = 0
	end

	if bIgnoreItemAnim then return self.SoundItemIndex end

	local StoppedItemIndex = self.SoundItemIndex
	if self.SoundItemIndex ~= 0 then
		local Widget = self.TableViewAdapter:GetChildWidget(self.SoundItemIndex)
		if Widget then
			Widget:PlayAudioAnimStop()
		end
		self.SoundItemIndex = 0
	end

	return StoppedItemIndex
end

return NPCPlotReviewItemView