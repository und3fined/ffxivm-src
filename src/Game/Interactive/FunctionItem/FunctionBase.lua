
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local NpcDialogHistoryVM = require("Game/Interactive/View/New/NpcDialogueHistoryVM")
local StoryDefine = require("Game/Story/StoryDefine")
local ProtoRes = require("Protocol/ProtoRes")
local DataReportUtil = require("Utils/DataReportUtil")
local FunctionBase = LuaClass()

LuaFuncType = LuaFuncType or {
    NPCQUIT_FUNC = 10000,   --npc专用，触发npc表的EndDialogID对话
    QUIT_FUNC = 10001,      --通用，仅仅是离开
    QUEST_FUNC = 10002,     --任务相关
    OLDNPC_FUNC = 10003,
    INTERACTIVEDESCC_FUNC = 10004,  --通用交互
    DIALOGUE_CHOICE_FUNC = 10005,  --对白分支选项交互
    CUSTOM_TALK_FUNC = 10006,        --自定义对话交互
    HINT_TALK_FUNC = 10007
}

-- 需要子类实现的有，可以参考EntranceNpc
-- OnInit               子类的初始化逻辑
-- OnClick              二级交互项点击的响应逻辑

function FunctionBase:Ctor()
    self.FuncType = 0
	self.DisplayName = ""
    self.FuncParams = nil
    self.IconPath = "PaperSprite'/Game/UI/Atlas/NPCTalk/Frames/UI_Icon_NPC_Dialogue_png.UI_Icon_NPC_Dialogue_png'"
    --默认是收刀/收武器的；   少量的比如接剑不会收刀的
    self.WeaponBackWhenClick = true
    
    --外部创建该FunctionItem的时候自己指定
    --这样不同的tabview，就不用按特定的顺序指定EntryWidgetClass了
    self.EntryWidgetIndex = 0

    -- 1：隐藏二级列表 2：返回一级列表  0：不做任何变化，保持在二级列表
    self.UIOPWhenClick = 1
    -- click时，默认立即转向
    self.DefaultTurn = true

    --二次确认框相关
    self.MessageBoxConfirmText = nil
    self.ClickCoroutine = nil           --外部创建的该Function的Click的协程     这俩协程是因为NpcDialogMgr的特殊逻辑所致
    self.OuterCoroutine = nil           --外部控制Click协程的协程
end

function FunctionBase:Init(DisplayName, FuncParams)
    self.DisplayName = DisplayName
    self.FuncParams = FuncParams
    self.EntityID = FuncParams.EntityID
    self.ResID = FuncParams.ResID
    self.ConditionID = FuncParams.ConditionID
    self.TargetType = ActorUtil.GetActorType(self.EntityID)

    self:OnInit(DisplayName, FuncParams)
end

function FunctionBase:SetEntityID(EntityID)
    self.EntityID = EntityID
end

function FunctionBase:NeedMessageBoxConfirm()
    if self.MessageBoxConfirmText and string.len(self.MessageBoxConfirmText) > 0 then
        return true
    end

    return false
end

function FunctionBase:GetFunctionItemSizeY()
    if self.EntryWidgetIndex == 0 then
        return 100
    -- elseif self.EntryWidgetIndex == 1 then
        -- return 125
    else
        return 125
    end
end

function FunctionBase:Click(NotInsertHistory)
    local rlt

    local ResID = ActorUtil.GetActorResID(self.EntityID)
    if _G.InteractiveMgr:IsMountRideNpc(ResID) then
        --_G.FLOG_INFO("Interactive FunctionBase %s Click", self.DisplayName)
        DataReportUtil.ReportData("MountTestRidingFlow", true, false, true,
            "OpType", "2",
            "Opdetail", self.DisplayName,
            "Arg1", "",
            "Arg2", "",
            "Arg3", "")
    end

    if self:NeedMessageBoxConfirm() then
        --FLOG_INFO("Interactive FunctionBase %s ClickCoroutine and showMessagebox", self.DisplayName)

        MsgBoxUtil.MessageBox(self.MessageBoxConfirmText, LSTR(10002), LSTR(10003),
            function() self:DoClick() end,
            function() self:CancelClick() end, false)

        if self.ClickCoroutine then
            --FLOG_INFO("Interactive FunctionBase ClickCoroutine yield")
            rlt = coroutine.yield()
        end

        --rlt是点击的结果
        --FLOG_INFO("Interactive FunctionBase after ClickCoroutine yield (clickRlt:%s)", tostring(rlt))

        if self.OuterCoroutine then
            coroutine.resume(self.OuterCoroutine, rlt)
            --FLOG_INFO("Interactive FunctionBase resume OuterCoroutine")
            self.OuterCoroutine = nil
        end

        self.ClickCoroutine = nil
        return  rlt
    end
    
    -- FLOG_INFO("Interactive FunctionBase %s Click no corutione", self.DisplayName)

    return self:DoClick(NotInsertHistory)
end

function FunctionBase:DoClick(NotInsertHistory)
    --FLOG_INFO("Interactive FunctionBase %s DoClick", self.DisplayName)
	--给上层一个点击处理的机会，比如NpcDialogMgr会不同情况下，修正NpcDialogState
    --隐藏二级显示列表，显示一级列表
    if self.DisplayName ~= "" then
        local HistoryItem = StoryDefine.DialogHistoryClass.New(StoryDefine.ContentType.Choice, StoryDefine.DialogType.Dialog, "", self.DisplayName)
        if not NotInsertHistory then
            if self.FuncParams and next(self.FuncParams) then
                if self.FuncParams.NeedInsertHistory then
                    NpcDialogHistoryVM:InsertHistoryItem(HistoryItem)
                end
            end
        end        
    end
	_G.EventMgr:SendEvent(EventID.PreClickFunctionItems, self)

    local rlt = self:OnClick()
	_G.EventMgr:SendEvent(EventID.PostClickFunctionItems, self, rlt)

    if self.EntityID and self.DefaultTurn then
        self:LookAtActor()
    end

    if self.ClickCoroutine then
        --FLOG_INFO("Interactive FunctionBase resume ClickCoroutine")
        coroutine.resume(self.ClickCoroutine, rlt)
    end

    
    --FLOG_INFO("Interactive FunctionBase DoClick rlt: %s", tostring(rlt))
    return rlt
end

function FunctionBase:LookAtActor()
    if nil ~= self.InteractivedescCfg and nil ~= self.InteractivedescCfg.FuncType and
        (self.InteractivedescCfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_PERSONAL_INFO or
        (self.InteractivedescCfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_UI and 
         nil ~= self.FuncCfg and nil ~= self.FuncCfg.Func and self.FuncCfg.Func[1].Type == ProtoRes.FuncType.OpenUI and
         self.FuncCfg.Func[1].Value[1] == _G.UIViewID.EmotionMainPanel)) then
         -- 1.主角与宠物交互，点情感动作交互按钮。 2.主角与其他人交互，点冒险者名牌或情感动作交互按钮。
        --_G.InteractiveMgr:LookAtTarget(self.EntityID)
    else
        MajorUtil.LookAtActor(self.EntityID)
    end
end

--兜底函数，不处理逻辑
function FunctionBase:UpdateData()

end

function FunctionBase:CancelClick()
    if self.ClickCoroutine then
        --FLOG_INFO("Interactive FunctionBase %s CancelClick", self.DisplayName)
        
        --给上层一个点击处理的机会，比如NpcDialogMgr会不同情况下，修正NpcDialogState
        --隐藏二级显示列表，显示一级列表
        _G.EventMgr:SendEvent(EventID.PreClickFunctionItems, self)

        --FLOG_INFO("Interactive FunctionBase resume ClickCoroutine")
        coroutine.resume(self.ClickCoroutine, false)
    end
end

function FunctionBase:AdapterOnGetWidgetIndex()
	return self.EntryWidgetIndex
end

---@return string
function FunctionBase:GetIconPath()
    return self.IconPath
end

---@param InPath string
function FunctionBase:SetIconPath(InPath)
    self.IconPath = InPath
end

---@param Name string
function FunctionBase:SetDisplayName(Name)
    self.DisplayName = Name
end

return FunctionBase
