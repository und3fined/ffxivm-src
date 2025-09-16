local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID =  require("Define/UIViewID")
local NewbieChannelExaminationQuestionCfg = require("TableCfg/NewbieChannelExaminationQuestionCfg")
local TimerRegister = require("Register/TimerRegister")

local UIViewMgr
local FLOG_ERROR
local LSTR = _G.LSTR
local SeleteItem = nil
local TimerResult = nil

local NormalBGImagePath = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Img_NormalBG.UI_Mentor_Img_NormalBG'"
local CorrectBGImagePath = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Img_CorrectBG.UI_Mentor_Img_CorrectBG'"
local CorrectIconImagePath = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Corner_Correct.UI_Mentor_Corner_Correct'"
local WrongIconImagePath = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Corner_Wrong.UI_Mentor_Corner_Wrong'"

-- 10073("连续答对%s道即可通过")、10074("连续答对x%s")
local ExamineingText = LSTR(50073)
local ExamineFinishText = LSTR(50074)

-- 10075("新人频道发言考核")、10076("考核失败")、10077("恭喜！ 考核通过")
local ExamineingTitle = LSTR(50075)
local ExamineFailTitle = LSTR(50076)
local ExaminePassTitle = LSTR(50077)

-- 10078("新人频道发言考核失败...\n回去练练再来吧！")、10079("恭喜你通过答题考核，可以在新人频道发言了！文明游戏从自己做起。")
local ExamineFailText = LSTR(50078)
local ExaminePassText = LSTR(50079)

---@class ChatNoviceExamPageVM : UIViewModel
local ChatNoviceExamPageVM = LuaClass(UIViewModel)

---Ctor
function ChatNoviceExamPageVM:Ctor()
	self.TagetView = nil
	self.ImgResultA = ""
	self.ImgResultB = ""
	self.ImgSelectBBg = ""
	self.ImgSelectABg = ""
	self.TextQuestion = ""
	self.TextAnswerA = ""
	self.TextAnswerB = ""
	self.TextProgress = 0
	self.HintText = ""
	self.TextTitle = ""
	self.PassText = ""
	self.CorrectText = ""
	self.TextTitleColor = "303030"
	self.PassWarnTextVisible = true
	self.CorrectVisible = false
	self.ImgResultAVisible = false
	self.ImgResultBVisible = false
	self.PanelPassExam = false
	self.PanelQuestionsVisible = true
	self.BtnStartVisible = false
	self.BtnAgainVisible = false
	self.PanelBtnVisible = false

	self.IsPass = false
end

function ChatNoviceExamPageVM:OnInit()

end

function ChatNoviceExamPageVM:OnBegin()
	UIViewMgr = _G.UIViewMgr
	FLOG_ERROR = _G.FLOG_ERROR
	self.TimerRegister = TimerRegister.New()
end

function ChatNoviceExamPageVM:OnEnd()
	self:ClearTimerRegister()
	self.IsPass = false
end

function ChatNoviceExamPageVM:OnShutdown()
	
end

function ChatNoviceExamPageVM:SetTagetView(View)
	self.TagetView = View
end

function ChatNoviceExamPageVM:ClearTimerRegister()
	if self.TimerRegister then
		self.TimerRegister:UnRegisterAll()
	end
end

function ChatNoviceExamPageVM:TimerUpdateFun()
	if TimerResult == nil then
		return
	end

	TimerResult = TimerResult + 0.1
	if math.abs( TimerResult - 1) < 0.01 then
		self:GetNewbieChannelExam( self.TextProgress + 1 )
		TimerResult = nil
	elseif math.abs( TimerResult - 2) < 0.01 then
		self:FailExam()
		TimerResult = nil
	elseif math.abs( TimerResult - 3) < 0.01 then
		self:PassExam()
		TimerResult = nil
	end
end

-- 开始答题考核
function ChatNoviceExamPageVM:StartNewbieSpeakEvaluation()
	self:ClearTimerRegister()
	TimerResult = nil
	self.IsPass = false
	self.TimerRegister:Register(self, self.TimerUpdateFun, 0 , 0.1, 0)

	self.NewbieChannelExamList = {}
	local ExamList = NewbieChannelExaminationQuestionCfg:FindAllCfg()
	if #ExamList < 10 then
		FLOG_ERROR(" NewbieChannelExam database quantity not sufficient!")
		return
	end

	for i = 1, 10 do
		local RandomValue = math.random(1, #ExamList)
		table.insert(self.NewbieChannelExamList, i, ExamList[RandomValue])
		table.remove(ExamList, RandomValue)
	end

	UIViewMgr:ShowView(UIViewID.ChatNoviceExamPagePanel)
	self:GetNewbieChannelExam(1)
end

-- 发布题目
---@param Progress int
---@param TextQuestion string
---@param AText string
---@param BText string
function ChatNoviceExamPageVM:ExhibitionTitle(Progress, TextQuestion, AText, BText)
	self.ImgResultA = ""
	self.ImgResultB = ""
	self.ImgSelectBBg = NormalBGImagePath
	self.ImgSelectABg = NormalBGImagePath
	self.TextQuestion = TextQuestion
	self.TextAnswerA = AText
	self.TextAnswerB = BText
	self.TextProgress = Progress
	self.HintText = string.format(ExamineingText, RichTextUtil.GetText("10", "449342"))
	self.TextTitle = ExamineingTitle
	self.TextTitleColor = "303030FF"
	self.CorrectVisible = false
	self.ImgResultAVisible = false
	self.ImgResultBVisible = false
	self.PanelQuestionsVisible = true
	self.PanelPassExam = false
	self.PassText = ""
	self.PassWarnTextVisible = true
	self.BtnStartVisible = false
	self.BtnAgainVisible = false
	self.PanelBtnVisible = false

	SeleteItem = 99  --待答题
end

function ChatNoviceExamPageVM:AnswerA()
	if SeleteItem ~= 99 or self.TagetView == nil then
		return
	end
	
	SeleteItem = 1
	self:NewbieSpeakEvaluationAnswer(self.TextProgress, "A")
end

function ChatNoviceExamPageVM:AnswerB()
	if SeleteItem ~= 99 or self.TagetView == nil then
		return 
	end

	SeleteItem = 2
	self:NewbieSpeakEvaluationAnswer(self.TextProgress, "B")
end

function ChatNoviceExamPageVM:AnswerError(CorrectAnswer)
	if self.TagetView == nil then
		return
	end

	local IsA = CorrectAnswer == "A"
	self.ImgResultA = IsA and CorrectIconImagePath or WrongIconImagePath
	self.ImgSelectABg = IsA and CorrectBGImagePath or NormalBGImagePath 
	self.ImgResultB = (not IsA) and CorrectIconImagePath or WrongIconImagePath
	self.ImgSelectBBg = (not IsA) and CorrectBGImagePath or NormalBGImagePath 
	self.ImgResultAVisible = true
	self.ImgResultBVisible = true
	if IsA then
		self.TagetView:PlayAnimationFromVM("AnimBFalse")
	else
		self.TagetView:PlayAnimationFromVM("AnimAFalse")
	end

	TimerResult = 1
end

function ChatNoviceExamPageVM:AnswerCorrectly(CorrectAnswer)
	if self.TagetView == nil then 
		return 
	end
	local IsA = CorrectAnswer == "A"
	if IsA then 
		self.ImgResultA =  CorrectIconImagePath
		self.ImgSelectABg = CorrectBGImagePath
		self.ImgResultAVisible = true
		self.TagetView:PlayAnimationFromVM("AnimATrue")
	else
		self.ImgResultB = CorrectIconImagePath
		self.ImgSelectBBg = CorrectBGImagePath
		self.ImgResultBVisible = true
		self.TagetView:PlayAnimationFromVM("AnimBTrue")
	end
	self.CorrectVisible = true
	self.CorrectText = string.format(ExamineFinishText, tostring(self.TextProgress))

	if ( self.TextProgress == #self.NewbieChannelExamList ) then
		TimerResult = 2
	else
		TimerResult = 0
		self.TagetView:PlayAnimationFromVM("AnimPanelContinuous")
	end
end

function ChatNoviceExamPageVM:FailExam()
	if self.TagetView == nil then
		return
	end
	self.HintText = RichTextUtil.GetText(string.format(ExamineFinishText, tostring(self.TextProgress - 1)), "af4c58")
	self.TextTitle = ExamineFailTitle
	self.TextTitleColor = "af4c58FF"

	self.PassText = ExamineFailText
	self.PassWarnTextVisible = false
	self.PanelQuestionsVisible = false
	self.PanelPassExam = true
	self.BtnAgainVisible = true
	self.PanelBtnVisible = true
	self.TagetView:PlayAnimationFromVM("AnimNext")
end

function ChatNoviceExamPageVM:PassExam()
	if self.TagetView == nil then 
		return 
	end

	self.HintText = RichTextUtil.GetText(string.format(ExamineFinishText, "10"), "449342")
	self.TextTitle = ExaminePassTitle
	self.TextTitleColor = "449342FF"
	self.PassText = ExaminePassText
	self.PassWarnTextVisible = true
	self.PanelPassExam = true
	self.PanelQuestionsVisible = false
	self.BtnStartVisible = true
	self.PanelBtnVisible = true
	self.TagetView:PlayAnimationFromVM("AnimNext")
	self.TagetView:PlayAnimationFromVM("AnimSuccess")
	self.IsPass = true
end

-- 获取新人频道考核目标题目
---@param Progress int
function ChatNoviceExamPageVM:GetNewbieChannelExam(Progress)
	if Progress > #self.NewbieChannelExamList or Progress < 1 then
		UIViewMgr:HideView(UIViewID.ChatNoviceExamPagePanel)
		return
	end
	local NewbieChannelExam = self.NewbieChannelExamList[Progress]
	self.TagetView:PlayAnimationFromVM("AnimHideResult")
	self:ExhibitionTitle(Progress, NewbieChannelExam.ExamQuestion, NewbieChannelExam.AnswerA, NewbieChannelExam.AnswerB)
end

-- 发送考核答题回答
---@param Progress int
---@param Answer string
function ChatNoviceExamPageVM:NewbieSpeakEvaluationAnswer(Progress, Answer)
	if not _G.NewbieMgr:IsInNewbieChannel() then
		self.TagetView:Hide()
		self.TagetView = nil
		MsgTipsUtil.ShowTipsByID(115041)
		return
	end
	local CorrectAnswer = self.NewbieChannelExamList[Progress].CorrectAnswer
	if CorrectAnswer == Answer then
		self:AnswerCorrectly(CorrectAnswer)
	else
		self:AnswerError(CorrectAnswer)
	end
end

--要返回当前类
return ChatNoviceExamPageVM