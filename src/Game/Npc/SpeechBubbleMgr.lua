local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local YellGroupCfg = require("TableCfg/YellGroupCfg")
local YellCfg = require("TableCfg/YellCfg")
local BalloonCfg = require("TableCfg/BalloonCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local MonsterCfg = require("TableCfg/MonsterCfg")
local SpeechBubbleGroup = require("Game/Npc/SpeechBubbleGroup")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EActorType = _G.UE.EActorType
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventMgr = _G.EventMgr
local BubbleShowDelay = 1
local BubbleRepeatDelay = 3.0

---@class SpeechBubbleMgr : MgrBase
local SpeechBubbleMgr = LuaClass(MgrBase)

function SpeechBubbleMgr:OnInit()
    self.BubbleGroupList = {}
    self.InRangeNPC = {}
    self.InVisionCharacter = {}
    self.AllowShowBubbleActorList = {}
    self.BubbleInfoList = {}
end

function SpeechBubbleMgr:OnBegin()
end

function SpeechBubbleMgr:OnEnd()
end

function SpeechBubbleMgr:OnShutdown()
end

function SpeechBubbleMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.VisionEnter, self.OnVisionEnter)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnVisionLeave)
    self:RegisterGameEvent(EventID.ActorDestroyed, self.OnEventNPCDestroy)
    self:RegisterGameEvent(EventID.EnterBubbleRange, self.OnEventEnterBubbleRange)
    --self:RegisterGameEvent(EventID.LeaveBubbleRange, self.OnEventLeaveBubbleRange)
    self:RegisterGameEvent(EventID.LeaveMaxBubbleRange, self.OnEventLeaveMaxBubbleRange)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnGameEventStartFadeIn)
    -- 选中目标用于GM测试
    self:RegisterGameEvent(EventID.SelectTarget, self.OnGameEventSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)
end

---@param Params table
function SpeechBubbleMgr:OnVisionEnter(Params)
    local EntityID = Params.ULongParam1
    self:SetBubbleRange(EntityID)
    if EntityID and EntityID ~= 0 then
        self.InVisionCharacter[EntityID] = EntityID
    end
end

---@param Params FEventParams
function SpeechBubbleMgr:OnVisionLeave(Params)
	local EntityID = Params.ULongParam1
    if self.InVisionCharacter[EntityID] then
        self.InVisionCharacter[EntityID] = nil
    end
    self:HideBubbleViews(EntityID)
	if table.length(self.InVisionCharacter) == 0 then
		self:CloseBubblePanel()
		return
	end
end

function SpeechBubbleMgr:OnEventNPCDestroy(Params)
    if (Params.IntParam1 ~= EActorType.Npc and Params.IntParam1 ~= EActorType.Monster) then
        return
    end
    local EntityID = Params.ULongParam1
    self.InVisionCharacter[EntityID] = nil
    self:HideBubbleViews(EntityID)
	if table.length(self.InVisionCharacter) == 0 then
		self:CloseBubblePanel()
		return
	end
end

function SpeechBubbleMgr:OnEventEnterBubbleRange(Params)
    local EntityID = Params.ULongParam1
    self.InRangeNPC[EntityID] = 1
    self:ShowBubbleGroupByEntityID(EntityID,0)
end

-- function SpeechBubbleMgr:OnEventLeaveBubbleRange(Params)
--     local EntityID = Params.ULongParam1
--     self.InRangeNPC[EntityID] = nil
--     self:HideBubbleGroupByEntityID(EntityID)
-- end

function SpeechBubbleMgr:OnEventLeaveMaxBubbleRange(Params)
    local EntityID = Params.ULongParam1
    self.InRangeNPC[EntityID] = nil
    self:HideBubbleGroupByEntityID(EntityID)
end

function SpeechBubbleMgr:SetBubbleRange(EntityID)
    local BubbleGroupID = self:GetBubbleBroupIDByEntityID(EntityID)
    if BubbleGroupID == nil then
        return
    end

    self.BubbleGroupIDList = self.BubbleGroupIDList or {}
    self.BubbleGroupIDList[EntityID] = BubbleGroupID

    local YellGroupCfg = YellGroupCfg:FindCfgByKey(BubbleGroupID)
    if YellGroupCfg == nil then 
        return
    end
    ---取气泡组的第一个气泡ID的触发距离作为 气泡组的触发距离
    local FirstYellID = YellGroupCfg["YellID"]
    local YellCfg = YellCfg:FindCfgByKey(FirstYellID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if YellCfg and Actor then
        local TriggerDistance = tonumber(YellCfg["SendDistance"])
        if TriggerDistance then
            Actor:SetBubbleRange(TriggerDistance)
        end

        local MaxShowDistance = tonumber(YellCfg["MaxDistance"])
        if MaxShowDistance then
            Actor:SetMaxBubbleRange(MaxShowDistance)
        end
    end
end

function SpeechBubbleMgr:GetBubbleBroupIDByEntityID(EntityID)
    if self.BubbleGroupIDList and self.BubbleGroupIDList[EntityID] then
        return self.BubbleGroupIDList[EntityID]
    end
    local ActorID = ActorUtil.GetActorResID(EntityID)
    local ActorType = ActorUtil.GetActorType(EntityID)
    local BubbleGroupID = nil
    if ActorType == EActorType.Npc then
        local NpcCfg = NpcCfg:FindCfgByKey(ActorID)
        if NpcCfg then
            BubbleGroupID = NpcCfg["BubbleID"]
        end
    elseif ActorType == EActorType.Monster then
        local MosterCfg = MonsterCfg:FindCfgByKey(ActorID)
        if MosterCfg then
            BubbleGroupID = MosterCfg["BubbleID"]
        end
    end
    return BubbleGroupID
end

function SpeechBubbleMgr:GetActorEntityIDByActor(Actor)
    if Actor then
		local AttrComp = Actor:GetAttributeComponent()
        if AttrComp then 
            return AttrComp.EntityID 
        end
	end
    return nil
end

---@type 根据GroupID构造BubbleGroup
function SpeechBubbleMgr:GenBubbleGroup(EntityID,BubbleGroupID)
    local GroupID = 0

    if BubbleGroupID > 0 then
        GroupID = BubbleGroupID
    else
        GroupID = self:GetBubbleGroupIDByEntityID(EntityID)
    end

    local YellIDlist = YellGroupCfg:FindAllIDsByGroupID(GroupID)
    local BubbleGroup = SpeechBubbleGroup.New()
    local GroupCfg = YellGroupCfg:FindCfgByKey(GroupID)
    if GroupCfg == nil then
        return
    end
    BubbleGroup:SetGroupLoopNum(GroupCfg["Cycles"])
    BubbleGroup:SetGroupDisplayMode(GroupCfg["DisplayMode"])
    BubbleGroup.GroupID = GroupID
    for Index = 1, #YellIDlist do
        local YellID = YellIDlist[Index]["YellID"]
        BubbleGroup:InsertID(Index, YellID, EntityID)
    end
    return BubbleGroup
end

function SpeechBubbleMgr:GetOrCreateBubbleGroup(EntityID,BubbleGroupID)
    self.BubbleGroupList = self.BubbleGroupList or {}

    if self.BubbleGroupList[EntityID] == nil then
        self.BubbleGroupList[EntityID] = self:GenBubbleGroup(EntityID,BubbleGroupID)
    end

    return self.BubbleGroupList[EntityID]
end

function SpeechBubbleMgr:GetBubbleGroupIDByEntityID(EntityID)
    if self.BubbleGroupIDList == nil then
        return nil
    end
    return self.BubbleGroupIDList[EntityID]
end

function SpeechBubbleMgr:CloseBubblePanel()
    -- FLOG_ERROR("[SpeechBubbleMgr] HideView(UIViewID.SpeechBubblePanel)")
    UIViewMgr:HideView(UIViewID.SpeechBubblePanel)
end

---@type 通过气泡ID显示气泡内容
function SpeechBubbleMgr:ShowBubbleViews(EntityID, BubbleID)
    if BubbleID == nil then
        return
    end
    local BubbleInfo = self:GetBubbleInfoByBubbleID(BubbleID)
    if BubbleInfo == nil then
        return
    end

    UIViewMgr:ShowView(UIViewID.SpeechBubblePanel)
    local Params = {
        EntityID = EntityID,
        Content = BubbleInfo.Content,
        BubbleType = BubbleInfo.BubbleType,
        BubbleStyle = BubbleInfo.BubbleStyle,
        BubbleID = BubbleID,
    }
    EventMgr:SendEvent(EventID.ShowSpeechBubble, Params)
end

function SpeechBubbleMgr:HideBubbleViews(EntityID, Callback)
    local Params = {
        EntityID = EntityID,
        CallBack = Callback,
    }
    EventMgr:SendEvent(EventID.HideSpeechBubble, Params)
end

function SpeechBubbleMgr:BubbleGroupCanPlay(BubbleGroup, bTask)
    if (BubbleGroup == nil or 
        BubbleGroup:ValidateIDList() == false or 
        BubbleGroup.IsPlaying == true or
        BubbleGroup:ValidateType(bTask) == false) then
        return false
    end

    --判断触发NPC是否在触发范围
    -- local FirstEntityIDs = BubbleGroup.FirstEntityIDs
    -- for _,EntityID in ipairs(FirstEntityIDs) do
    --     if self.InRangeNPC[EntityID] == nil then
    --          FLOG_ERROR("[SpeechBubbleMgr]EntityID = %d not InRange", EntityID)
    --         return false
    --     end
    -- end

    --判断BubbleGroup里面的NPC是否都在视野
    local ContantNPCMap = BubbleGroup.ContantsNPC
    for EntityID,_ in pairs(ContantNPCMap) do
        if self.InVisionCharacter[EntityID] == nil then
            -- FLOG_ERROR("[SpeechBubbleMgr]NpcID = %d not InVision", NpcID)
            return false
        end
    end

    return true
end

function SpeechBubbleMgr:BubbleCanPlay(EntityID, BubbleID)
    if EntityID == nil or type(EntityID) ~= "number" or EntityID <= 0 then
        return false
    end

    if self.InVisionCharacter[EntityID] == nil then
        FLOG_WARNING("气泡无法显示，因为气泡主体不在视野范围内")
        return false
    end
    
    -- 如果传入气泡ID，则受到气泡配置的范围影响
    if BubbleID and type(BubbleID) == "number" and BubbleID > 0 then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor == nil then
            return false
        end
        
        local DistanceToMajor = Actor:GetDistanceToMajor()
        local BubbleInfo = self:GetBubbleInfoByBubbleID(BubbleID)
        if BubbleInfo == nil then
            return false
        end
    
        if BubbleInfo.MaxDistance < DistanceToMajor then
            FLOG_WARNING("气泡无法显示，因为超出了气泡显示范围，请检查气泡配置:"..BubbleID)
            return false
        end        
    end

    return true
end

function SpeechBubbleMgr:OnBubbleGroupPlayEnd(bCheckClosePanel)
    -- FLOG_ERROR("[SpeechBubbleMgr]GroupID = %d End Play", GroupID)
    if (bCheckClosePanel) then
        self:CheckClosePanel()
    end
end

function SpeechBubbleMgr:CheckClosePanel()
    local bHasPlaying = false
    for _, BubbleGroup in pairs(self.BubbleGroupList) do
        if BubbleGroup.IsPlaying == true then
            bHasPlaying = true
            break
        end
    end
    if bHasPlaying == false then
        self:CloseBubblePanel()
    end
end

function SpeechBubbleMgr:RepeatPlayBubbleGroup(EntityID)
    local BubbleGroup = self.BubbleGroupList[EntityID]
    if BubbleGroup == nil then 
        self:OnBubbleGroupPlayEnd(true)
        return
    end

    if BubbleGroup:CanGroupLoop() == false then
        self:OnBubbleGroupPlayEnd(true)
        -- 播放完成，再次进入距离范围不再触发
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor then
            Actor:SetBubbleRange(-1)
        end
        return
    end

    if self:BubbleGroupCanPlay(BubbleGroup) == false then
        self:OnBubbleGroupPlayEnd(true)
        return
    end

    local function RepeatPlay()
        BubbleGroup:OnGroupLoop()
        if self:ShowBubbleGroup(EntityID,0) == false then
            BubbleGroup:PlayReset()
            self:OnBubbleGroupPlayEnd(true)
        end
    end

    BubbleGroup:AddTimer(self:RegisterTimer(RepeatPlay, BubbleRepeatDelay))
end

---@type 显示气泡组
---@param EntityID 实体对象唯一ID
function SpeechBubbleMgr:ShowBubbleGroupByEntityID(EntityID,BubbleGroupID)
    self:ShowBubbleGroup(EntityID,BubbleGroupID)
end

---@type 隐藏气泡组
---@param EntityID 实体对象唯一ID
function SpeechBubbleMgr:HideBubbleGroupByEntityID(EntityID)
    self:HideBubbleGroup(EntityID, false)
    self:CheckClosePanel()
end

---@type 独立显示单个气泡
---@param EntityID int32
---@param Text string 气泡内容
---@param TextType int32 气泡类型
---@param BubbleStyle int32 气泡UI样式,nil or 0：为默认样式, 1：为特殊样式
function SpeechBubbleMgr:ShowBubbleSingle(EntityID, Text, TextType, BubbleStyle, BubbleID)
    if self:BubbleCanPlay(EntityID) == false then
        FLOG_WARNING("[SpeechBubbleMgr] 播放气泡对象不在视野内")
        return
    end

    UIViewMgr:ShowView(UIViewID.SpeechBubblePanel)
    local Params = {
        EntityID = EntityID,
        Content = Text,
        BubbleType = TextType,
        BubbleStyle = BubbleStyle,
        BubbleID = BubbleID,
    }
    EventMgr:SendEvent(EventID.ShowSpeechBubble, Params)
end

---@type 隐藏对象的气泡
---@param EntityID int32
function SpeechBubbleMgr:HideBubbleSingle(EntityID, CallBack)
    local Params = {
        EntityID = EntityID,
        CallBack = CallBack,
    }
    EventMgr:SendEvent(EventID.HideSpeechBubble, Params)
end

---缓存一下behavior气泡的持续时间,可能会因为停掉NPC的tick导致没能正确触发隐藏气泡的逻辑,保底处理一下
function SpeechBubbleMgr:RecordBallonTimer(EntityID, BalloonID, Duration)
    if Duration == nil or Duration <= 0 then
        return
    end
    if self.BallonCache == nil then
        self.BallonCache = {}
    end
    ---先清掉之前没触发的Timer
    if self.BallonCache[EntityID] then
        local TimerID = self.BallonCache[EntityID]
        self:UnRegisterTimer(TimerID)
    end
    local function HideBalloon()
        self:HideBalloonByID(EntityID)
    end
    local TimerID = self:RegisterTimer(HideBalloon,Duration)
    self.BallonCache[EntityID] = TimerID
end

---behavior中用到的气泡
---@param EntityID int32
---@param BalloonID int32
---@param Duration float @如果传的无效参数就不做保底,由cpp完全控制气泡的显示和隐藏
function SpeechBubbleMgr:ShowBalloonByID(EntityID, BalloonID, Duration)
    if not self:BubbleCanPlay(EntityID) then
        return
    end

    local CurrBalloon = BalloonCfg:FindCfgByKey(BalloonID)
    if CurrBalloon == nil then
        return
    end
    local Text = CurrBalloon.Text
    local TextType = CurrBalloon.IsSlowly
    local Style = CurrBalloon.Style
    self:ShowBubbleSingle(EntityID, Text, TextType, Style)
    self:RecordBallonTimer(EntityID, BalloonID, Duration)
end

---behavior清除当前冒泡
---@param EntityID int32
function SpeechBubbleMgr:HideBalloonByID(EntityID)
    if self.BallonCache and self.BallonCache[EntityID] then
        local TimerID = self.BallonCache[EntityID]
        self:UnRegisterTimer(TimerID)
        self.BallonCache[EntityID] = nil
    end
    self:HideBubbleSingle(EntityID)
end

function SpeechBubbleMgr:ShowBubbleByID(EntityID,BubbleID)
    if not self:BubbleCanPlay(EntityID, BubbleID) then
        return
    end

    local function ShowIndeed()
        local CurBubble = self:GetBubbleInfoByBubbleID(BubbleID)
        if CurBubble == nil then
            return
        end
        self:ShowBubbleSingle(EntityID, CurBubble.Content, CurBubble.BubbleType, CurBubble.BubbleStyle, BubbleID)

        local CurBubbleDuration = CurBubble.Duration

        if not CurBubble.IsAwaysShow then
            self:RegisterTimer(
                    function()
                        self:HideBubbleSingle(EntityID)
                    end,
                    CurBubbleDuration)
        end
    end

    local FirstBubbleInfo = self:GetBubbleInfoByBubbleID(BubbleID)
    if FirstBubbleInfo == nil then
        FLOG_ERROR(string.format("BubbleID %s不存在，请检查！！！", BubbleID))
        return
    end
    local FirstBubbleDelay = FirstBubbleInfo and FirstBubbleInfo.DelayTime or BubbleShowDelay
    self:RegisterTimer(ShowIndeed, FirstBubbleDelay)
end

function SpeechBubbleMgr:ShowBubbleGroup(EntityID,BubbleGroupID)
    local BubbleGroup = self:GetOrCreateBubbleGroup(EntityID,BubbleGroupID)
    if self:BubbleGroupCanPlay(BubbleGroup, false) == false then
        return false
    end
    -- FLOG_ERROR("[SpeechBubbleMgr]GroupID = %d Start Play", GroupID)
    BubbleGroup.IsPlaying = true
    -- Show indeed after a delay, required by designer
    local function ShowIndeed()
        if (self.BubbleGroupList == nil or self.BubbleGroupList[EntityID] == nil) then
            return
        end
        self:ShowBubbleSuccessively(EntityID, 1)
    end

    local FirstBubbleID = BubbleGroup:GetIDAt(1)
    local FirstBubbleInfo = self:GetBubbleInfoByBubbleID(FirstBubbleID)
    local FirstBubbleDelay = FirstBubbleInfo and FirstBubbleInfo.DelayTime or BubbleShowDelay
    BubbleGroup:AddTimer(self:RegisterTimer(ShowIndeed, FirstBubbleDelay))
    return true
end

function SpeechBubbleMgr:HideBubbleGroup(EntityID, bCheckClosePanel)
    local BubbleGroup = self.BubbleGroupList[EntityID]
    if BubbleGroup == nil then 
        return
    end

    for _, Value in ipairs(BubbleGroup.TimerList) do
        self:UnRegisterTimer(Value)
    end

    self:HideBubbleViews(EntityID)
    
    BubbleGroup:PlayReset()
    self.BubbleGroupList[EntityID] = nil
    self:OnBubbleGroupPlayEnd(bCheckClosePanel)
end

function SpeechBubbleMgr:ShowBubbleSuccessively(EntityID, Index)
    -- Show new bubble
    local BubbleGroup = self.BubbleGroupList[EntityID]
    if BubbleGroup == nil then 
        return
    end

    
    if (Index > BubbleGroup:GetSize()) then
        BubbleGroup:PlayReset()
        return
    end


    local CurBubbleID = BubbleGroup:GetIDAt(Index)
    self:ShowBubbleViews(EntityID, CurBubbleID)
    
    local CurBubble = self:GetBubbleInfoByBubbleID(CurBubbleID)
    local CurBubbleDuration = CurBubble.Duration
    -- Set timer for bubble hide and next bubble show
    local function HideCallback()
        if (self.BubbleGroupList == nil or self.BubbleGroupList[EntityID] == nil) then
            return
        end
        local LocalBubbleGroup = self.BubbleGroupList[EntityID]
        local NextBubbleIndex = Index + 1
        if (NextBubbleIndex > LocalBubbleGroup:GetSize()) then
            LocalBubbleGroup:PlayReset()
            self:RepeatPlayBubbleGroup(EntityID)
            return
        end

        local NextBubbleID = LocalBubbleGroup:GetIDAt(NextBubbleIndex)
        local NextBubble = self:GetBubbleInfoByBubbleID(NextBubbleID)
        local NextBubbleShowDelay = NextBubble and NextBubble.DelayTime or 0
        LocalBubbleGroup:AddTimer(self:RegisterTimer(
            function()
                self:ShowBubbleSuccessively(EntityID, Index + 1)
            end,
            NextBubbleShowDelay
        ))
    end

    if not CurBubble.IsAwaysShow then
        BubbleGroup:AddTimer(self:RegisterTimer(
        function()
            if (self.BubbleGroupList == nil or self.BubbleGroupList[EntityID] == nil) then
                return
            end
            self:HideBubbleViews(EntityID, HideCallback)
        end,
        CurBubbleDuration
    ))
    end
end

function SpeechBubbleMgr:GetBubbleInfoByBubbleID(BubbleID)
    if BubbleID == nil or type(BubbleID) ~= "number" then
        FLOG_ERROR("[SpeechBubbleMgr]BubbleID is nil or not a number!!!,Please check")
        return
    end

    if self.BubbleInfoList and self.BubbleInfoList[BubbleID] then
        return self.BubbleInfoList[BubbleID]
    end
    local Yell = YellCfg:FindCfgByKey(BubbleID)
    if Yell == nil then
        FLOG_ERROR("[SpeechBubbleMgr]气泡不存在："..BubbleID)
        return
    end
    
    local NPCName = ""
    local Content = Yell["Text"]
    local CharacterID = tonumber(Yell["NameId"])
    local IsAwaysShow = tonumber(Yell["IsBalloonTimelyDisable"]) > 0
    --按原作给的表的字段意思，应该是作为内容前面是否加名字的开关（先按策划的来吧，作为名字后面要加的内容）
    local TextBehindName = Yell["IsNameAddonText"]
    if CharacterID and CharacterID ~= 0 then
        local NPCCfg = NpcCfg:FindCfgByKey(CharacterID)
        NPCName = NPCCfg["Name"]
        if TextBehindName and TextBehindName ~= "0" then
            NPCName = NPCName..TextBehindName
        end
        Content = NPCName..Content
    end
    
    local BubbleInfo = {
        BubbleID = BubbleID,
        Content = MsgTipsUtil.ParseLabel(Content), -- 遇到标签要替换
        Duration = Yell["BalloonTime"],
        IsAwaysShow = IsAwaysShow,
        NPCID = Yell["NameId"],
        BubbleType = Yell["OutputType"],
        DelayTime = Yell["IsBalloonImmediately"],
        BubbleStyle = Yell["BubbleStyle"],
        TriggerDistance = Yell["SendDistance"],
        MaxDistance = Yell["MaxDistance"]
    }
    
    if self.BubbleInfoList == nil then
        self.BubbleInfoList = {}
    end
    self.BubbleInfoList[BubbleID] = BubbleInfo
    return BubbleInfo
end

---@type 是否显示所有气泡
function SpeechBubbleMgr:ShowSpeechBubbleAll(IsShow)
    EventMgr:SendEvent(EventID.ShowSpeechBubbleAll, IsShow)
end

---@type 模型显现时才展示气泡及更新位置
function SpeechBubbleMgr:OnGameEventStartFadeIn(Params)
    local EntityID = Params.ULongParam1
    self.CanShowActorList = EntityID
    if self.AllowShowBubbleActorList == nil then
        self.AllowShowBubbleActorList = {}
    end
    self.AllowShowBubbleActorList[EntityID] = EntityID
end

function SpeechBubbleMgr:ShowCondition(EntityID)
    return self.AllowShowBubbleActorList and self.AllowShowBubbleActorList[EntityID] ~= nil
end


--region GM测试
-- GM使用 播放气泡
function SpeechBubbleMgr:ShowBubbleTest(InBubbleID)
    local MajorUtil = require("Utils/MajorUtil")
    local EntityID = self.SelectedEntityID or MajorUtil.GetMajorEntityID()
    if EntityID then
        self.InVisionCharacter[EntityID] = EntityID
        local BubbleID = InBubbleID and tonumber(InBubbleID) or 0
        if BubbleID then
            self:ShowBubbleByID(EntityID, BubbleID)
        else
            self:HideBubbleSingle(EntityID)
        end
    end
end

-- GM使用 播放Ballon（behavior 冒泡）
function SpeechBubbleMgr:ShowBalloonTest(InBalloonID)
    local MajorUtil = require("Utils/MajorUtil")
    local EntityID = self.SelectedEntityID or MajorUtil.GetMajorEntityID()
    if EntityID then
        self.InVisionCharacter[EntityID] = EntityID
        local BalloonID = InBalloonID and tonumber(InBalloonID) or 0
        if BalloonID > 0 then
            self:ShowBalloonByID(EntityID, BalloonID)
        else
            self:HideBubbleSingle(EntityID)
        end
    end
end

function SpeechBubbleMgr:OnGameEventSelectTarget(Params)
	self.SelectedEntityID = Params.ULongParam1
end

function SpeechBubbleMgr:OnGameEventUnSelectTarget(Params)
	self.SelectedEntityID = nil
end
--endregion GM测试

return SpeechBubbleMgr