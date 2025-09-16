--
-- Author: anypkvcai
-- Date: 2020-10-27 15:49:02
-- Description:
--

local ProtoRes = require("Protocol/ProtoRes")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local DialogueUtil = require("Utils/DialogueUtil")
local ProtoCS = require("Protocol/ProtoCS")
local CommonDefine = require("Define/CommonDefine")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local TipsQueueDefine = require("Game/TipsQueue/TipsQueueDefine")
local ActorUtil = require("Utils/ActorUtil")

local TipsShowType = ProtoRes.sysnotice_show_type
local DefaultShowTime = 3
local FLOG_ERROR = _G.FLOG_ERROR

local TipsQueue = {}

---@class MsgTipsUtil
local MsgTipsUtil = {

}

---ShowTipsByType
---@param Type number
---@param Cfg table
local function ShowTipsByType(Type, Cfg, Content, ...)
	local Times = 1
	if Cfg.ShowTimes > 0 then
		Times = Cfg.ShowTimes
	end

	local Contents = Cfg.Content or {}
	local ShowTime = Cfg.ShowTime
	local SoundName = Cfg.SoundName

	-- --- 金蝶的某些Tip需要播放声音
	-- GoldSauserDefine.TryPlayGoldTipAudio(Cfg.ID)

	if nil == ShowTime or ShowTime <= 0 then
		ShowTime = DefaultShowTime
	end

	if nil == Content then
		if select("#", ...) > 0 then
			Content = string.sformat(Contents[1], ...)
		else
			Content = Contents[1]
		end
	end

	local SrcContent = Content
	Content = MsgTipsUtil.ParseLabel(Content)
	Content = CommonUtil.GetTextFromStringWithSpecialCharacter(Content)

    if string.isnilorempty(Content) then
		FLOG_ERROR(string.format("MsgTipsUtil.ShowTipsByType, Content is nilorempty, ID = %d, SrcContent = %s", Cfg.ID, SrcContent))
	end 

	for _ = 1, Times do
		if TipsShowType.SYSNOTICE_SHOWTYPE_SYS == Type then
			if not CommonUtil.IsShipping() then
				Content = Content .. "(" .. tostring(Cfg.ID) .. ")"
			end
			MsgTipsUtil.ShowTips(Content, SoundName, ShowTime)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_ROLL == Type then
			MsgTipsUtil.ShowRollTips(Content, SoundName, ShowTime)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_ERROR == Type then
			if not CommonUtil.IsShipping() then
				Content = Content .. "(" .. tostring(Cfg.ID) .. ")"
			end
			MsgTipsUtil.ShowErrorTips(Content, ShowTime, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_AREA == Type then
			MsgTipsUtil.ShowAreaTips(Content, ShowTime, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_TALK == Type then
			local Name = Contents[2] or ""
			MsgTipsUtil.ShowNPCTalkTips(Name, Content, 1, Cfg)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_TALK02 == Type then
			local Name = Contents[2] or ""
			MsgTipsUtil.ShowNPCTalkTips(Name, Content, 2, Cfg)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_TALK03 == Type then
			local Name = Contents[2] or ""
			MsgTipsUtil.ShowNPCTalkTips(Name, Content, 3, Cfg)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_ACTIVE == Type then
			MsgTipsUtil.ShowActiveTips(Content, ShowTime, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_MISSON == Type then
			MsgTipsUtil.ShowMissionTips(Content, ShowTime, SoundName, Cfg.ID)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_INFOMISSON == Type then
			MsgTipsUtil.ShowInfoMissionTips(Content, ShowTime, Cfg.HeadPortrait, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_MSGBOX == Type then
			MsgTipsUtil.ShowMsgBoxTips(Content)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_GOLDSAUSER == Type then
			local NPCName = Contents[2] or ""
			local Params = {NPCName = NPCName, Content = Content, ShowTime = ShowTime}
    		UIViewMgr:ShowView(UIViewID.GoldSauserInfoCountDownTip, Params)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_CHATCHANNEL_SYS == Type then
			MsgTipsUtil.AddSysChatMsg(Content)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_PWORLD_TEACH == Type then
			MsgTipsUtil.ShowPWorldTeachingTips(Content, ShowTime)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_PWORLD_RESULT == Type then
			local Result = false
			if Cfg.Param and Cfg.Param[1] and Cfg.Param[1].Value and Cfg.Param[1].Value > 0 then
				Result = true
			end
			MsgTipsUtil.ShowPWorldResultTips(Content, ShowTime, Result)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_INFOTEXT == Type then
			MsgTipsUtil.ShowInfoTextTips(1, Content, Contents[2], ShowTime, Cfg.HeadPortrait, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_INFOTEXTSMALL == Type then
			MsgTipsUtil.ShowInfoTextTips(2, Content, Contents[2], ShowTime, Cfg.HeadPortrait, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_INFOTEXTBIG == Type then
			MsgTipsUtil.ShowInfoTextTips(3, Content, Contents[2], ShowTime, Cfg.HeadPortrait, SoundName)
		elseif TipsShowType.SYSNOTICE_SHOWTYPE_PVPCOLOSSEUM_NOTICE == Type then
			MsgTipsUtil.ShowPVPColosseumTips(Content, ShowTime, SoundName)
		end
	end
end

---ShowTipsByID
---@param TipsID number
function MsgTipsUtil.ShowTipsByID(TipsID, Content, ...)
	local Cfg = SysnoticeCfg:FindCfgByKey(TipsID)
	if nil == Cfg or nil == next(Cfg) then
		if nil == TipsID then
			FLOG_ERROR(string.format("MsgTipsUtil.ShowTipsByID can't find tips, ID is nil"))
			return
		else
			FLOG_ERROR(string.format("MsgTipsUtil.ShowTipsByID can't find tips, ID=%d", TipsID))
			return
		end
	end
	local bOff = _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_ERROR)
	if bOff and Cfg.ShowControl == 1 then
		return
	end

	local CanContinue = MsgTipsUtil:CheckParamType(Cfg)
	if (not CanContinue) then
		return
	end

	for _, v in ipairs(Cfg.ShowType) do
		ShowTipsByType(v, Cfg, Content, ...)
	end
end

function MsgTipsUtil.ShowTipsByIDAndToSysChat(TipsID, ...)
	MsgTipsUtil.ShowTipsByID(TipsID, nil, ...)
	local Content = require("TableCfg/SysnoticeCfg"):FindCfgByKey(TipsID).Content[1]
	if Content then
		_G.ChatMgr:AddSysChatMsg(string.sformat(Content, ...))
	end
end

function MsgTipsUtil.ShowTipsAndToSysChat(Content)
	if type(Content) ~= 'string' or #Content == 0 then
		return
	end

	MsgTipsUtil.ShowTips(Content, nil, nil)
	_G.ChatMgr:AddSysChatMsg(Content)
end

--- func 返回的true 表示继续， FALSE 表示不显示了
---@param Cfg 表格数据
function MsgTipsUtil:CheckParamType(Cfg)
	if (Cfg == nil or Cfg.Param == nil) then
		return true
	end

	-- 检测金蝶机遇临门相关的
	local Result = self:CheckParamTypeForGoldSauser(Cfg.Param)
	if (not Result) then
		return false
	end

	-- 检测NPC相关
	Result = self:CheckParamTypeForNPC(Cfg.Param)
	if (not Result) then
		return false
	end

	-- 检测坐标点相关
	Result = self:CheckParamTypeForLocation(Cfg.Param)
	if (not Result) then
		return false
	end

	return true
end

function MsgTipsUtil:CheckParamTypeForLocation(InParams)
	if (InParams == nil or InParams[1] == nil) then
		return
	end

	-- 这里处理下类型
	local MsgType = InParams[1].Type
	if (MsgType == nil or MsgType ~= CommonDefine.MESSAGE_PARAM_TYPE.MESSAGE_LOCATION) then
		return true
	end

	local LocationStr = InParams[1].StringValue
	if (LocationStr == nil) then
		return true
	end

	local SplitArray = string.split(LocationStr, ",")
	if (#SplitArray ~= 3) then
		_G.FLOG_ERROR(
			"MsgTipsUtil:CheckParamTypeForLocation 出错，[1].Value : %s 无法解析为坐标",
			LocationStr
		)
		return false
	end

	local TargetPos = _G.UE.FVector(SplitArray[1], SplitArray[2], SplitArray[3])
	local SubMsgType = InParams[2].Type
	if (SubMsgType == CommonDefine.MESSAGE_SUBTYPE.DISTANCE) then
		local ThirdType = InParams[3].Type
		if (ThirdType == CommonDefine.MESSAGE_THIRD_TYPE.VALUE_COMPARE) then
			local Major = MajorUtil.GetMajor()
			if (Major == nil) then
				return true
			end

			local MajorLocation = Major:FGetActorLocation()
			if (MajorLocation == nil) then
				return true
			end

			local CurDis = MajorLocation:Dist2D(TargetPos)
			local DistanceValue = tonumber(InParams[2].Value)
			local CompareType = InParams[3].Value
			
			if (CompareType == CommonDefine.VALUE_OPERATE_TYPE.EQUAL) then
				-- 等于
				return CurDis == DistanceValue
			elseif(CompareType == CommonDefine.VALUE_OPERATE_TYPE.LESS_EQUAL) then
				-- 小于等于
				return CurDis <= DistanceValue
			elseif(CompareType == CommonDefine.VALUE_OPERATE_TYPE.GREAT_EQUAL) then
				-- 大于等于
				return CurDis >= DistanceValue
			end

			_G.FLOG_ERROR("MsgTipsUtil:CheckParamTypeForLocation 出错，未处理的 InParams[3].Value : %s", CompareType)
			return true
		end		
	else
		return true
	end

	return true
end

-- 返回true表示后面的继续执行，false表示停止执行
function MsgTipsUtil:CheckParamTypeForNPC(InParams)
	if (InParams == nil or InParams[1] == nil) then
		return
	end

	-- 这里处理下类型
	local MsgType = InParams[1].Type
	if (MsgType == nil or MsgType ~= CommonDefine.MESSAGE_PARAM_TYPE.MESSAGE_NPC) then
		return true
	end

	local NPCResID = InParams[1].Value
	if (NPCResID == nil) then
		return true
	end

	-- 如果无法获取NPC那么
	local TargetActor = ActorUtil.GetActorByResID(NPCResID)
	if (TargetActor == nil) then
		return false
	end

	local SubMsgType = InParams[2].Type
	if (SubMsgType == CommonDefine.MESSAGE_SUBTYPE.DISTANCE) then
		local ThirdType = InParams[3].Type
		if (ThirdType == CommonDefine.MESSAGE_THIRD_TYPE.VALUE_COMPARE) then
			-- 这里是去判断一下和NPC之间的距离，
			local ActorLocation = TargetActor:FGetActorLocation()
			if (ActorLocation == nil) then
				return true
			end
			
			local Major = MajorUtil.GetMajor()
			if (Major == nil) then
				return true
			end

			local MajorLocation = Major:FGetActorLocation()
			if (MajorLocation == nil) then
				return true
			end

			local CurDis = MajorLocation:Dist2D(ActorLocation)
			local DistanceValue = InParams[2].Value
			local CompareType = InParams[3].Value
			
			if (CompareType == CommonDefine.VALUE_OPERATE_TYPE.EQUAL) then
				-- 等于
				return CurDis == DistanceValue
			elseif(CompareType == CommonDefine.VALUE_OPERATE_TYPE.LESS_EQUAL) then
				-- 小于等于
				return CurDis <= DistanceValue
			elseif(CompareType == CommonDefine.VALUE_OPERATE_TYPE.GREAT_EQUAL) then
				-- 大于等于
				return CurDis >= DistanceValue
			end

			_G.FLOG_ERROR("MsgTipsUtil:CheckParamTypeForNPC 出错，未处理的 InParams[3].Value : %s", CompareType)
			return true
		end

	else
		return true
	end

	return true
end

-- 返回true表示后面的继续执行，false表示停止执行
function MsgTipsUtil:CheckParamTypeForGoldSauser(Param)
	if (Param == nil or Param[1] == nil) then
		return true
	end

	-- 这里处理下类型
	local _type = Param[1].Type
	if (_type == nil or _type ~= CommonDefine.MESSAGE_PARAM_TYPE.MESSAGE_GOLDSAUSER_OPPORTUNITY) then
		return true
	end

	local _value = Param[1].Value
	if (_value == nil) then
		return true
	end

	local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
	if (_value == CommonDefine.MESSAGE_GOLDSAUSER_TYPE.MESSAGE_GOLDSAUSER_TO_ALL) then
		-- 对所有在金蝶里面的人发送
		return true
	elseif(_value == CommonDefine.MESSAGE_GOLDSAUSER_TYPE.MESSAGE_GOLDSAUSER_TO_SIGNUP) then
		-- 对已经报名了的，目前是一个时段只开启一个玩法，因此只需要判断是否报名就行了，不用判断是否报名当前的
		local _hasSignUp = GoldSauserMgr:GetHasSignUp()
		return _hasSignUp
	elseif(_value == CommonDefine.MESSAGE_GOLDSAUSER_TYPE.MESSAGE_GOLDSAUSER_TO_ON_STAGE) then
		-- 在台子上的，目前是快刀斩魔和喷风有
		local _gameState = GoldSauserMgr:GetEntertainState()
		local _hasSignUp = GoldSauserMgr:GetHasSignUp()
		local GoldSauserEntertainState = ProtoCS.GoldSauserEntertainState
		return (_gameState == GoldSauserEntertainState.GoldSauserEntertainState_InProgress and _hasSignUp)
	else
		_G.FLOG_ERROR("错误，未处理的 MESSAGE_GOLDSAUSER_TYPE 类型 : ".._value)
		return true
	end

	return true
end

--播放过场时有时需要弹tips，跟其他tips区分开来
function MsgTipsUtil.ShowStoryTips(Content)
	local Params = {Content = Content, ShowTime = DefaultShowTime}
	local View = UIViewMgr:ShowView(UIViewID.StoryTips)
	if View ~= nil then
		View:AddSystemTip(Params)
	end
end

---ShowActiveSystemErrorTips  
---@return View
function MsgTipsUtil.ShowActiveSystemErrorTipsView()
	local View = UIViewMgr:FindView(UIViewID.ActiveSystemErrorTips)
	if View and not View:CheckNormalOperation() then
		View:Hide()
		_G.UIViewMgr:RecycleView(View)
		View = nil
	end
	if View == nil then
		View = UIViewMgr:ShowView(UIViewID.ActiveSystemErrorTips)
	end
	return View
end

---ShowTips                 @通用提示 向上飘然后消失
---@param Content string    @支持富文本
function MsgTipsUtil.ShowTips(Content, SoundName, ShowTime)
	ShowTime = ShowTime or DefaultShowTime
	local Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime}
	local View = MsgTipsUtil.ShowActiveSystemErrorTipsView()
	if View ~= nil then
		View:AddSystemTip(Params)
	end
end

---ShowErrorTips            @错误提示 显示一段时间后消失
---@param Content string
---@param ShowTime number   @显示时间 单位：秒
function MsgTipsUtil.ShowErrorTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime}
	local View = MsgTipsUtil.ShowActiveSystemErrorTipsView()
	if View ~= nil then
		View:AddErrorTip(Params)
	end
end

---ShowActiveTips
---@param Content string
---@param ShowTime number   @显示时间 单位：秒
function MsgTipsUtil.ShowActiveTips(Content, ShowTime, SoundName, TipParams)
	TipParams = TipParams or {}
	ShowTime = ShowTime or DefaultShowTime
	local Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime, bTargetFinish = TipParams.bTargetFinish,
	Count = TipParams.Count, MaxCount = TipParams.MaxCount,}
	local View = MsgTipsUtil.ShowActiveSystemErrorTipsView()
	if View ~= nil then
		View:AddActiveTip(Params)
	end
end


function MsgTipsUtil.ShowFateErrorTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local function FateErrorTipsCallback(Params)
		_G.TipsMgr:ShowTipsView(UIViewID.FateErrorTips, Params.Content, Params.ShowTime, Params.SoundName)
	end
	local FateErrorConfig = {Type = ProtoRes.tip_class_type.TIP_FATE_NOTICE, Callback = FateErrorTipsCallback,
								Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime}}
	_G.TipsQueueMgr:AddPendingShowTips(FateErrorConfig)
end

function MsgTipsUtil.ShowFateMissionTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local function FateMissionTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.FateMissionTips, Params)
	end
	local FateMissionConfig = {Type = ProtoRes.tip_class_type.TIP_FATE_NOTICE, Callback = FateMissionTipsCallback,
								Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime}}
	_G.TipsQueueMgr:AddPendingShowTips(FateMissionConfig)
end

---ShowGatherChainTips            @采集连锁的提示 显示一段时间后消失
---@param Content string
---@param ShowTime number   @显示时间 单位：秒
function MsgTipsUtil.ShowGatherChainTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	_G.TipsMgr:ShowTipsView(UIViewID.GatherChainTips, Content, ShowTime, SoundName)
end


---记录地图相关提示哪些正在显示，同时显示时按优先级显示，避免重叠
local MapTipsShowing =
{
	[TipsShowType.SYSNOTICE_SHOWTYPE_AREA] = false,
	[TipsShowType.SYSNOTICE_SHOWTYPE_MAP] = false,
}

---ShowAreaTips             @进入某个区域的提示
---@param Content string
---@param ShowTime number   @显示时间 单位：秒
function MsgTipsUtil.ShowAreaTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local function AreaTipsCallback(Params)
		if MapTipsShowing[TipsShowType.SYSNOTICE_SHOWTYPE_MAP] then
			-- 地图提示显示优先级高于区域提示
			return false
		end
		UIViewMgr:HideView(UIViewID.InfoAreaTips)
		UIViewMgr:ShowView(UIViewID.InfoAreaTips, Params)
		return true
	end
	local function StopAreaTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.InfoAreaTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.InfoAreaTips)
			return true
		end
	end
	local AreaConfig = {
		Type = ProtoRes.tip_class_type.TIP_AREA_NOTICE,
		Key = Content,
		Callback = AreaTipsCallback,
		StopCallback = StopAreaTipsCallback,
		Params = {
			ShowType = TipsShowType.SYSNOTICE_SHOWTYPE_AREA,
			Content = Content,
			SoundName = SoundName,
			ShowTime = ShowTime
		}
	}
	_G.TipsQueueMgr:AddPendingShowTips(AreaConfig)
end

function MsgTipsUtil.MarkAreaTips(bShow)
	MapTipsShowing[TipsShowType.SYSNOTICE_SHOWTYPE_AREA] = bShow
end

---进入地图提示
function MsgTipsUtil.ShowEnterMapTips(ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = { ShowType = TipsShowType.SYSNOTICE_SHOWTYPE_MAP, ShowTime = ShowTime, SoundName = SoundName }
	UIViewMgr:ShowView(UIViewID.InfoAreaTips, Params)
end

function MsgTipsUtil.MarkEnterMapTips(bShow)
	MapTipsShowing[TipsShowType.SYSNOTICE_SHOWTYPE_MAP] = bShow
	if not bShow then
		MsgTipsUtil.ShowQueue()
	end
end


---ShowNPCTalkTips          @显示NPC对话
---@param NPCName string    @NPC Name
---@param Content string    @Talk Content
---@param ShowType int      @显示样式
---@param Cfg table   @表格中预置信息
function MsgTipsUtil.ShowNPCTalkTips(Name, Content, ShowType, Cfg)
	local Params = Cfg.Param or {}
	local ShowLocation
	for i = 1, #Params do
		if Params[i].Type == CommonDefine.MESSAGE_PARAM_TYPE.MESSAGE_TALKTIP_DISPLAYPOSITION then
			ShowLocation = Params[i].Value
		end
	end

	local ShowTime = Cfg.ShowTime or DefaultShowTime
	local function TalkTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.NewNPCTalkTips, Params)
		local Text = Params.NPCName .. ':' .. Params.Content
		Text = string.gsub(Text, "%b<>", "")
		MsgTipsUtil.AddSysChatMsg(RichTextUtil.GetText(Text, "89bd88" ), true)
	end
	local TalkConfig = {Type = ProtoRes.tip_class_type.TIP_NPC_DIALOGUE, Callback = TalkTipsCallback}
	TalkConfig.Params = {NPCName = Name, Content = Content, ShowTime = ShowTime, SoundName = Cfg.SoundName, IconPath = Cfg.HeadPortrait, ShowType = ShowType, ShowLocation = ShowLocation}
	_G.TipsQueueMgr:AddPendingShowTips(TalkConfig)
end

---ShowMissionTips
---@param Content string
---@param ShowTime number   @显示时间 单位：秒
function MsgTipsUtil.ShowMissionTips(Content, ShowTime, SoundName, ID, Callback, bSymbolInvisible)
	ShowTime = ShowTime or DefaultShowTime
	local function MissonTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.MissionTips, Params)
	end
	local function StopMissonTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.MissionTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.MissionTips)
			return true
		end
	end
	local MissonConfig = {
		Type = ProtoRes.tip_class_type.TIP_MISSION_TEAM,
		Callback = MissonTipsCallback,
		StopCallback = StopMissonTipsCallback,
		Params = {
			Content = Content,
			SoundName = SoundName,
			ShowTime = ShowTime,
			ID = ID,
			Callback = Callback,
			bSymbolInvisible = bSymbolInvisible
		}
	}
	_G.TipsQueueMgr:AddPendingShowTips(MissonConfig)
end

---ShowQuestTips
---@param Content string
---@param MainGenre string  @任务分类
---@param ShowTime number   @显示时间 单位：秒
---@param ChapterID number  @章节ID
function MsgTipsUtil.ShowQuestTips(Content, MainGenre, ShowTime, SoundName, ChapterID, Callback, bSymbolInvisible)
	local function ShowTipsCallback(Params)
	    if _G.PuzzleMgr:CheckIsInPuzzle() then -- 拼图时候不希望任务Tip遮挡事业
			return false
		end
		UIViewMgr:ShowView(UIViewID.QuestInfoTips, Params)
		return true
    end
    local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.QuestInfoTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.QuestInfoTips)
			return true
		end
    end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_COMPLETE_TASK,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
		Params = {
			Content = Content,
			MainGenre = MainGenre,
			ShowTime = ShowTime,
			SoundName = SoundName,
			ChapterID = ChapterID,
			Callback = Callback,
			bSymbolInvisible = bSymbolInvisible
		}
	}
    _G.TipsQueueMgr:AddPendingShowTips(Config)
end

---ShowMsgBoxTips
---@param Content string
function MsgTipsUtil.ShowMsgBoxTips(Content)
	--MsgBoxUtil.MessageBox(Content, nil, nil, nil, nil, false)
	-- 10002(确  认)
	-- 10004(提  示)
	MsgBoxUtil.ShowMsgBoxOneOpRight(nil, _G.LSTR(10004), Content, nil, _G.LSTR(10002))
end

---ShowLevelUpTips
---@param NewProf number
---@param NewLevel number
function MsgTipsUtil.ShowLevelUpTips(NewProf, NewLevel, ShowCallback)
	local function ShowTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.LevelUpTips, Params)
		if nil ~= ShowCallback then
			ShowCallback()
		end
		return true
	end
	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.LevelUpTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.LevelUpTips)
			return true
		end
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_LEVEL_UP,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
		Params = {Prof = NewProf, Level = NewLevel}
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)

end

---ShowBottomTips
---@param Content string
---@param ShowTime number     @显示时间 单位：秒
function MsgTipsUtil.ShowBottomTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = { Content = Content, ShowTime = ShowTime, SoundName = SoundName }
	UIViewMgr:ShowView(UIViewID.BottomTips, Params)
end

---ShowAetherCurrentPanelTips
---@param Content string
---@param ShowTime number     @显示时间 单位：秒
---@param bShowProcess boolean @是否显示副标题
---@param Callback function @提示显示结束后回调
function MsgTipsUtil.ShowAetherCurrentPanelTips(Content, ShowTime, SubContent, bShowBigTitle, bShowSubTitle, Callback, SoundName)
	local Params = { Content = Content, ShowTime = ShowTime, SubContent = SubContent, bShowBigTitle = bShowBigTitle, bShowSubTitle = bShowSubTitle, Callback = Callback, SoundName = SoundName }
	UIViewMgr:ShowView(UIViewID.AetherCurrentTipsPanelView, Params)
end

---ShowAetherCurrentDetectTips
---@param Content string
---@param ShowTime number     @显示时间 单位：秒
function MsgTipsUtil.ShowAetherCurrentDetectTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = { Content = Content, ShowTime = ShowTime, SoundName = SoundName}
	UIViewMgr:ShowView(UIViewID.AetherCurrentTips02PanelView, Params)
end

---ShowPWorldTeachingTips
---@param Content string
---@param ShowTime number     @显示时间 单位：秒
function MsgTipsUtil.ShowPWorldTeachingTips(Content, ShowTime)
	ShowTime = ShowTime or DefaultShowTime
	local Params = { Content = Content, ShowTime = ShowTime}
	UIViewMgr:ShowView(UIViewID.TutorialGestureTips1Item, Params)
end

---ShowPWorldResultTips
---@param Content string
---@param ShowTime number     @显示时间 单位：秒
---@param Result boolean      @是否胜利
function MsgTipsUtil.ShowPWorldResultTips(Content, ShowTime, Result)
	ShowTime = ShowTime or DefaultShowTime
	local Params = { Content = Content, ShowTime = ShowTime, Result = Result}
	UIViewMgr:ShowView(UIViewID.CommTextTipsBigStrongItem, Params)
end

---AddSysChatMsg
---@param Content string
function MsgTipsUtil.AddSysChatMsg(Content, IsStory)
	if _G.LifeMgrModule.GetCurLifeType() <= _G.UE.EGameLifeType.Role then
		if IsStory then
			_G.ChatMgr:AddSysChatMsgStory(Content)
		else
			_G.ChatMgr:AddSysChatMsg(Content)
		end
    end
end

---ShowRunningTips 运营全服通告需求
---@param Content string
function MsgTipsUtil.ShowRunningTips(Content)
	FLOG_INFO("MsgTipsUtil.ShowRunningTips(): %s", tostring(Content))

	if not string.isnilorempty(Content) then
		local View = UIViewMgr:ShowView(UIViewID.CommonRunningTips)
		View:AddToQueue(Content)
	end
end

---ShowInfoTextTipsView 显示文本信息
---@param Type number    @ 1：文本信息正常  2：文本信息小  3：文本信息大
---@param Content string
---@param HintText string
---@param ShowTime number
---@param ImagePanel string @使用底图中的哪个Panel
---@param SoundName string
function MsgTipsUtil.ShowInfoTextTips(Type, Content, HintText, ShowTime, ImagePanel, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	if (ImagePanel or "") == "" then
		ImagePanel = nil
	end

	local function ShowTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.InfoTextTips, Params)
	end
	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.InfoTextTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.InfoTextTips)
			return true
		end
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_INFOTEXT_TIP,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
		Params = { Content = Content, HintText = HintText, ShowTime = ShowTime, Type = Type, ImagePanel = ImagePanel, SoundName = SoundName }
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

---ShowInfoMissionTips 显示节点信息    新的节点提示
---@param Content string
---@param ShowTime number
---@param ImagePanel string   @样式补充参数
---@param SoundName string
function MsgTipsUtil.ShowInfoMissionTips(Content, ShowTime, ImagePanel, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local function ShowTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.InfoMissionTips, Params)
	end
	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.InfoMissionTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.InfoMissionTips)
			return true
		end
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_INFOMISSION_TIP,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
		Params = { Content = Content, ShowTime = ShowTime, ImagePanel = ImagePanel, SoundName = SoundName }
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

---ShowFogUnlockTips 显示迷雾解锁提示
---@param IsAllUnlock boolean@是否全地图解锁
---@param ShowTime number@显示时间
function MsgTipsUtil.ShowFogUnlockTips(IsAllUnlock, ShowTime)
	ShowTime = ShowTime or DefaultShowTime
	local Params = { IsAllUnlock = IsAllUnlock, ShowTime = ShowTime}
	if MapTipsShowing[TipsShowType.SYSNOTICE_SHOWTYPE_MAP] then
		MsgTipsUtil.AddQueue(UIViewID.InfoMistTips, Params)
		return
	end
	UIViewMgr:ShowView(UIViewID.InfoMistTips, Params)
end

---ShowCrystalTips 显示水晶提示
---@param Title string
---@param SubTitle string
---@param ShowTime number
function MsgTipsUtil.ShowCrystalTips(Title, SubTitle, ShowTime)
	ShowTime = ShowTime or DefaultShowTime
	local function ShowTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.InfoCrystalTips, Params)
	end
	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.InfoCrystalTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.InfoCrystalTips)
			return true
		end
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_CRYSTAL_NOTICE,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
		Params = { Title = Title, SubTitle = SubTitle, ShowTime = ShowTime}
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

---ParseLabel 处理系统通知文本中的特殊文本，如"<player>"
---@param Text string
---@return string
function MsgTipsUtil.ParseLabel(Text)
	if not string.isnilorempty(Text) then
		if string.find(Text, "<player>") then
			local Attr = MajorUtil.GetMajorAttributeComponent()
			if Attr ~= nil then
				return string.gsub(Text, "<player>", Attr.ActorName)
			end
		end

	end

	return DialogueUtil.ParseLabel(Text)
end

---简易队列,同viewid会覆盖,消息没有优先级,需手动调用 MsgTipsUtil.ShowQueue()
function MsgTipsUtil.AddQueue(ViewID, Params)
	TipsQueue[ViewID] = Params
end

function MsgTipsUtil.ShowQueue()
	local ViewID, Params = next(TipsQueue)
	if ViewID then
		TipsQueue[ViewID] = nil
		UIViewMgr:ShowView(ViewID, Params)
	end
end

---ShowMentorTips
---@param Params table
function MsgTipsUtil.ShowMentorTips(Params)
	local function ShowTipsCallback()
		_G.UIViewMgr:ShowView(UIViewID.InfoContentUnlockTips, Params)
		return true
	end
	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.InfoContentUnlockTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.InfoContentUnlockTips)
			return true
		end
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_MENTOR_NOTICE,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

---ShowAchievementTips
---@param NewCompeltedID table
function MsgTipsUtil.ShowAchievementTips(NewCompeltedID)
	for i = 1, #NewCompeltedID do
		_G.LeftSidebarMgr:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, {
			AchievementID = NewCompeltedID[i],
			ClickCallback = function() _G.AchievementMgr:OpenAchieveMainViewByAchieveID(NewCompeltedID[i]) end,
		})
	end
end

---ShowRollTips             @队伍分配提示
function MsgTipsUtil.ShowRollTips(Content, SoundName, ShowTime)
	MsgTipsUtil.ShowTips(Content, SoundName, ShowTime)
end


---PVP水晶冲突提示
function MsgTipsUtil.ShowPVPColosseumTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local function ShowTipsCallback(Params)
		UIViewMgr:ShowView(UIViewID.InfoPVPColosseumTips, Params)
		return true
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_PVPCOLOSSEUM_NOTICE,
		Callback = ShowTipsCallback,
		Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime}
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

---PVP水晶冲突队伍提示
---@param Content string 提示内容
---@param IsBlueTeam boolean 红蓝方
function MsgTipsUtil.ShowPVPColosseumTeamTips(Content, IsBlueTeam, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = {Content = Content, IsBlueTeam = IsBlueTeam, SoundName = SoundName, ShowTime = ShowTime}
	--UIViewMgr:ShowView(UIViewID.InfoPVPColosseumTeamTips, Params)

	local View = MsgTipsUtil.ShowActiveSystemErrorTipsView()
	if View ~= nil then
		View:AddPVPColosseumTeamTip(Params)
	end
end

---PVP水晶冲突击杀提示
---@param KillParams talbe 击杀参数信息
function MsgTipsUtil.ShowPVPColosseumKillTips(KillParams, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = {KillParams = KillParams, ShowTime = ShowTime, SoundName = SoundName}
	--UIViewMgr:ShowView(UIViewID.InfoPVPColosseumKillTips, Params)

	local View = MsgTipsUtil.ShowActiveSystemErrorTipsView()
	if View ~= nil then
		View:AddPVPColosseumKillTipsView(Params)
	end
end

---PVP水晶冲突战斗指挥
function MsgTipsUtil.ShowPVPColosseumCommand(Params)
	UIViewMgr:ShowView(UIViewID.InfoPVPColosseumCommand, Params)
end


---ShowGrandCompanyTips
---@param Params table
function MsgTipsUtil.ShowGrandCompanyTips(Params)
	local function ShowTipsCallback()
		_G.UIViewMgr:ShowView(UIViewID.InfoContentUnlockTips, Params)
		return true
	end
	local function HideTipsCallback(_, StopReason)
		if StopReason == TipsQueueDefine.STOP_REASON.COMPLETE then
			return not UIViewMgr:IsViewVisible(UIViewID.InfoContentUnlockTips)
		else
			-- 被强制关闭的话强制关闭UI
			UIViewMgr:HideView(UIViewID.InfoContentUnlockTips)
			return true
		end
	end
	local Config = {
		Type = ProtoRes.tip_class_type.TIP_GRANDCOMPANY_NOTICE,
		Callback = ShowTipsCallback,
		StopCallback = HideTipsCallback,
	}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

---显示足迹完成提示
---@param Params table
function MsgTipsUtil.ShowFootPrintTips(Content, ShowTime, SoundName)
	ShowTime = ShowTime or DefaultShowTime
	local Params = {Content = Content, SoundName = SoundName, ShowTime = ShowTime}

	local View = MsgTipsUtil.ShowActiveSystemErrorTipsView()
	if View ~= nil then
		View:AddFootPrintTipsView(Params)
	end
end

----------------------------- 轮播相关

---@field int32 DisplayNum  @最多可同时显示个数
---@field int32 MoveSpacing @每个tip单位移动长度
---@field bool Useing @正在使用中
local SliderMode = {
	Normal = { DisplayNum = 5, MoveSpacing = 82, Useing = true },
	PVP = { DisplayNum = 2, MoveSpacing = 100, Useing = false }
}

function MsgTipsUtil.SetSliderMode(Mode)
	local SelectionMode = SliderMode[Mode]
	if SelectionMode ~= nil then 
		for _, Mode in pairs(SliderMode) do
			Mode.Useing = false
		end
		SelectionMode.Useing = true

		local SliderView = UIViewMgr:FindView(UIViewID.ActiveSystemErrorTips)
		if SliderView ~= nil then
			SliderView:RefreshDisplayNumOrMoveSpacing(SelectionMode.DisplayNum, SelectionMode.MoveSpacing)
		end
	end
end

function MsgTipsUtil.GetSliderMode()
	for _, Mode in pairs(SliderMode) do
		if Mode.Useing then 
			return Mode
		end
	end
	return SliderMode.Normal
end

-------------------------------
return MsgTipsUtil