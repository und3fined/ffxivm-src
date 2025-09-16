---
--- Author: Administrator
--- DateTime: 2023-05-08 15:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local ChatNoviceExamPageVM = require("Game/Chat/VM/ChatNoviceExamPageVM")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetTextFormat =  require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")

local LSTR = _G.LSTR


---@class ChatNoviceExamPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgain CommBtnLView
---@field BtnAnswerA UFButton
---@field BtnAnswerB UFButton
---@field BtnStart CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field ImgResultA UFImage
---@field ImgResultB UFImage
---@field ImgSelectABg UFImage
---@field ImgSelectBBg UFImage
---@field PanelBtn UFCanvasPanel
---@field PanelContinuous UFCanvasPanel
---@field PanelPassExam UFCanvasPanel
---@field PanelQuestions UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextAnswerA UFTextBlock
---@field TextAnswerB UFTextBlock
---@field TextCongratulation UFTextBlock
---@field TextContinuous UFTextBlock
---@field TextProgress URichTextBox
---@field TextQuestion URichTextBox
---@field TextQuestion02 UFTextBlock
---@field TextTitle UFTextBlock
---@field TextWarning UFTextBlock
---@field AnimAFalse UWidgetAnimation
---@field AnimASelect UWidgetAnimation
---@field AnimATrue UWidgetAnimation
---@field AnimBFalse UWidgetAnimation
---@field AnimBSelect UWidgetAnimation
---@field AnimBTrue UWidgetAnimation
---@field AnimHideResult UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimNext UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimPanelContinuous UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatNoviceExamPageView = LuaClass(UIView, true)

function ChatNoviceExamPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgain = nil
	--self.BtnAnswerA = nil
	--self.BtnAnswerB = nil
	--self.BtnStart = nil
	--self.CloseBtn = nil
	--self.ImgResultA = nil
	--self.ImgResultB = nil
	--self.ImgSelectABg = nil
	--self.ImgSelectBBg = nil
	--self.PanelBtn = nil
	--self.PanelContinuous = nil
	--self.PanelPassExam = nil
	--self.PanelQuestions = nil
	--self.PopUpBG = nil
	--self.TextAnswerA = nil
	--self.TextAnswerB = nil
	--self.TextCongratulation = nil
	--self.TextContinuous = nil
	--self.TextProgress = nil
	--self.TextQuestion = nil
	--self.TextQuestion02 = nil
	--self.TextTitle = nil
	--self.TextWarning = nil
	--self.AnimAFalse = nil
	--self.AnimASelect = nil
	--self.AnimATrue = nil
	--self.AnimBFalse = nil
	--self.AnimBSelect = nil
	--self.AnimBTrue = nil
	--self.AnimHideResult = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimNext = nil
	--self.AnimOut = nil
	--self.AnimPanelContinuous = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatNoviceExamPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAgain)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatNoviceExamPageView:OnInit()
	self.Binders = {		
		{ "PanelQuestionsVisible", UIBinderSetIsVisible.New(self, self.PanelQuestions) },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle ) },
		{ "TextTitleColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTitle ) },
		{ "HintText", UIBinderSetText.New(self, self.TextProgress ) },
		{ "TextProgress", UIBinderSetTextFormat.New(self, self.TextQuestion02, LSTR(50061)) }, -- "问题%d:"
		{ "TextQuestion", UIBinderSetText.New(self, self.TextQuestion) },
		{ "CorrectVisible", UIBinderSetIsVisible.New(self, self.PanelContinuous) },
		{ "CorrectText", UIBinderSetText.New(self, self.TextContinuous) },
		
		{ "ImgSelectABg", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelectABg) },
		{ "ImgSelectBBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelectBBg) },
		{ "TextAnswerA", UIBinderSetTextFormat.New(self, self.TextAnswerA, "A.%s") },
		{ "TextAnswerB", UIBinderSetTextFormat.New(self, self.TextAnswerB, "B.%s") },
		{ "ImgResultA", UIBinderSetBrushFromAssetPath.New(self, self.ImgResultA) },
		{ "ImgResultAVisible", UIBinderSetIsVisible.New(self, self.ImgResultA) },
		{ "ImgResultB", UIBinderSetBrushFromAssetPath.New(self, self.ImgResultB) },
		{ "ImgResultBVisible", UIBinderSetIsVisible.New(self, self.ImgResultB) },

		{ "PanelBtnVisible", UIBinderSetIsVisible.New(self, self.PanelBtn) },
		{ "BtnStartVisible", UIBinderSetIsVisible.New(self, self.BtnStart) },
		{ "BtnAgainVisible", UIBinderSetIsVisible.New(self, self.BtnAgain) },

		{ "PanelPassExam", UIBinderSetIsVisible.New(self, self.PanelPassExam) },
		{ "PassWarnTextVisible", UIBinderSetIsVisible.New(self, self.TextWarning) },
		{ "PassText", UIBinderSetText.New(self, self.TextCongratulation) },
	}

	self.BtnStart:SetText(LSTR(50102)) -- 10102("开始发言")
	self.BtnAgain:SetText(LSTR(50103)) -- 10102("再来一次")
	self.TextWarning:SetText(LSTR(50149)) -- 50149("不当的指导行为存在遭到举报的风险。")
end

function ChatNoviceExamPageView:OnRegisterBinder()
	self:RegisterBinders(ChatNoviceExamPageVM, self.Binders)
end

function ChatNoviceExamPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnConfirm)
	UIUtil.AddOnClickedEvent(self, self.BtnAgain, self.OnClickBtnAgain)
	UIUtil.AddOnClickedEvent(self, self.BtnAnswerB, self.OnClickBtnAnswerB)
	UIUtil.AddOnClickedEvent(self, self.BtnAnswerA, self.OnClickBtnAnswerA)
end

function ChatNoviceExamPageView:OnRegisterGameEvent()

end

function ChatNoviceExamPageView:OnDestroy()

end

function ChatNoviceExamPageView:OnShow()
	ChatNoviceExamPageVM:SetTagetView(self)
end

function ChatNoviceExamPageView:OnHide()
	ChatNoviceExamPageVM:ClearTimerRegister()
	ChatNoviceExamPageVM:SetTagetView(nil)
	if ChatNoviceExamPageVM.IsPass then
		local NewbieMgr = _G.NewbieMgr
		if NewbieMgr:IsInNewbieChannel() then
			NewbieMgr:RecordNewbieChannelEvaluatTime(TimeUtil.GetServerLogicTime())
		end
		ChatNoviceExamPageVM.IsPass = false
	end
end

function ChatNoviceExamPageView:OnClickBtnAgain()
	ChatNoviceExamPageVM:StartNewbieSpeakEvaluation()
end

function ChatNoviceExamPageView:OnClickBtnConfirm()
	self:Hide()
end

function ChatNoviceExamPageView:OnClickBtnAnswerA()
	ChatNoviceExamPageVM:AnswerA()
end

function ChatNoviceExamPageView:OnClickBtnAnswerB()
	ChatNoviceExamPageVM:AnswerB()
end

function ChatNoviceExamPageView:PlayAnimationFromVM(AnimName)
	local Anim = self[AnimName] 
	if Anim ~= nil then 
		self:PlayAnimation(Anim)
	end
end

return ChatNoviceExamPageView