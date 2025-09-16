local ProtoRes = require("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local FunctionNpcQuit = require("Game/Interactive/FunctionItem/FunctionNpcQuit")
local DialogUtil = require("Utils/DialogueUtil")
local CustomDialogOptionCfg = require("TableCfg/CustomDialogOptionCfg")
local CustomDialogAnswerCfg = require("TableCfg/CustomDialogAnswerCfg")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local NpcDialogVM = require("Game/Story/NpcDialogPlayVM")

local AnswerContentIDList = JumboCactpotDefine.AnswerContentIDList

local FunctionCustomTalk = LuaClass(FunctionBase)

local ContentType = {
    CUSTOM_TALK = 1,
    NPC_DIALOG = 2,
    SEQUENCE_DIALOG = 3,
}

local SaveValueType = {
    NONE = 0,
    CUSTOMTalk = 1,
    FUNCTION = 2
}

function FunctionCustomTalk:Ctor()
    self.FuncType = LuaFuncType.CUSTOM_TALK_FUNC
    self.Cfg = nil
    self.ContentType = nil
    self.DialogLibID = 0
    self.TempFuncID = nil
    self.SaveValueType = SaveValueType.NONE
    self.OptionFunctionList = nil
end

function FunctionCustomTalk:OnInit(_, FuncParams)
    self:UpdateData()
end

function FunctionCustomTalk.CreateCustomTalkFunc(DisplayName, FuncParams)
    local IFuncUnit = FunctionCustomTalk.New()
    IFuncUnit:Init(DisplayName, FuncParams)

    return IFuncUnit
end

function FunctionCustomTalk:UpdateData()
    if self.FuncParams.IsCustomTalk == true then
        self.ContentType = ContentType.CUSTOM_TALK
    -- if self.FuncParams.FuncValue >= 700000 and self.FuncParams.FuncValue <= 799999 then
    --     self.ContentType = ContentType.CUSTOM_TALK
    -- elseif self.FuncParams.FuncValue < 700000 then
    --     self.ContentType = ContentType.NPC_DIALOG
    elseif self.FuncParams.FuncValue >= 10000000 and self.FuncParams.FuncValue <= 29999999 then
        self.ContentType = ContentType.SEQUENCE_DIALOG
    elseif self.FuncParams.FuncValue >= 2000000 and self.FuncParams.FuncValue <= 2999999 then
        self.ContentType = ContentType.NPC_DIALOG
    end

    if self.ContentType == ContentType.CUSTOM_TALK then
        -- CustomTalk
        if self.Cfg == nil then
            self.Cfg = CustomDialogOptionCfg:FindCfgByKey(self.FuncParams.FuncValue)
            if self.Cfg == nil then return end
            self.TempFuncID = self.FuncParams.FuncValue
        end

        if self.DisplayName == nil then
            self.DisplayName = self.Cfg.Title
        end
        if self.FuncParams.IgnorePreDialog then
            self.DialogLibID = 0
        else
            self.DialogLibID = _G.NpcDialogMgr:GetDialogIDByCondition(self.Cfg.PreDialogID, self.Cfg.PreConditionID)
        end
        if self.FuncParams.TrueCustomTalkID and self.FuncParams.TrueCustomTalkID ~= 0 then
            self.DialogLibID = self.FuncParams.TrueCustomTalkID
        end
    else
        self.DialogLibID = self.FuncParams.FuncValue
    end
end

function FunctionCustomTalk:OnClick()
    local NpcDialogMgr = require("Game/NPC/NpcDialogMgr")
    if self.ContentType == ContentType.CUSTOM_TALK or self.ContentType == ContentType.NPC_DIALOG then
        self:CheckAnswerIsCustom()
        self.OptionFunctionList = self:GenCustomTalkOptions(self.FuncParams.FuncValue)
        local bNoOptions = self.OptionFunctionList == nil or #self.OptionFunctionList == 0
        local DialogLib =  _G.NpcDialogMgr:ReadDialogLib(self.DialogLibID or 0, self.FuncParams.EntityID)
        if not next(DialogLib) and bNoOptions then
            self.DialogLibID = 0
        end
        local function OpenInteraction()
            local InteractiveMainView = _G.UIViewMgr:FindView(UIViewID.InteractiveMainPanel)
            if _G.InteractiveMgr.bMainPanelClosedByOtherUI == true then
                return
            end
            if _G.GatherMgr:IsGatherState() then
                return
            end
            --Sequenc播放的时候不展示交互列表了
            if InteractiveMainView and InteractiveMainView.CanShowInteractive == false then return end
            NpcDialogVM:SetContorllerButtonVisible(false)
            _G.InteractiveMgr:SetMainPanelIsVisible(InteractiveMainView, true)
        end
        local function PlayDialogCallback()
            if self.OptionFunctionList ~= nil and #self.OptionFunctionList > 0 then
                _G.InteractiveMgr:SaveLastTalk(self.TempFuncID)
                NpcDialogVM:SetArrowHide(true)
                _G.InteractiveMgr:SetFunctionList(self.OptionFunctionList)
                OpenInteraction()
            end
            if bNoOptions then
                if self.SaveValueType == SaveValueType.FUNCTION then
                    --这里播完对话直接触发功能
                    self.OptionFunctionList = self:GenFuncListByFuncID(self.FuncParams.FuncValue)
                    if not next(self.OptionFunctionList) then
                        _G.NpcDialogMgr:PlayDialogLib(0 -1)
                        _G.FLOG_ERROR("OptionFunctionList Is Empty")
                        return
                    end
                    self.OptionFunctionList[1]:Click()
                    _G.InteractiveMgr:ClearCustomData()
                    --_G.InteractiveMgr:OnGameEventClickNextDialog()
                    --副本传送和对话类型特殊屏蔽一下，后续考虑配置
                    if self.OptionFunctionList[1].InteractivedescCfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_DIALOGG or
                    self.OptionFunctionList[1].InteractivedescCfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_SCENE_S or
                    self.OptionFunctionList[1].InteractivedescCfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_ARMY_UI
                    then return end 
                    _G.NpcDialogMgr:PlayDialogLib(0 -1)
                    return 
                end
                 --这里重新导向上一级CustomTalk，主要为了不与外面其他对话和交互耦合，逻辑放在这里
                 _G.InteractiveMgr:SaveLastTalk(nil, self.DialogLibID)
                 local LastCustomTalkID =  _G.InteractiveMgr:GetLastCustomTalk()
                 if LastCustomTalkID and LastCustomTalkID ~= 0 then
                     self.Cfg = CustomDialogOptionCfg:FindCfgByKey(LastCustomTalkID)
                     self.OptionFunctionList = self:GenCustomTalkOptions(LastCustomTalkID)
                     NpcDialogVM:SetArrowHide(true)
                     _G.InteractiveMgr:SetFunctionList(self.OptionFunctionList, true)
                     OpenInteraction()
                 else
                     _G.NpcDialogMgr:EndInteraction()
                 end
            end
        end
        --这里需要提前检查有没有对话，没有对话说明是功能ID，对话ID置0
        --如果对话组ID为0，不再调用对话了，隐藏对话展示交互
        _G.NpcDialogMgr:PlayDialogLib(self.DialogLibID, self.FuncParams.EntityID, nil, PlayDialogCallback, bNoOptions)
        return true
    elseif self.ContentType == ContentType.SEQUENCE_DIALOG then
        _G.NpcDialogMgr:EndInteraction()
        _G.StoryMgr:PlayDialogueSequence(self.FuncParams.FuncValue)
    end
end

function FunctionCustomTalk:CheckAnswerIsCustom()
    if self.Cfg and next(self.Cfg) then return end
    --没有找到说明是回答ID，先在回答表找一下有没有嵌套的CustomID
    local AnswerCfg = CustomDialogAnswerCfg:FindCfgByKey(self.FuncParams.FuncValue)
    if AnswerCfg and next (AnswerCfg) then
        if AnswerCfg.CustomTalkID ~= 0 then
            self.SaveValueType = SaveValueType.CUSTOMTalk
            local CustomTalkID = AnswerCfg.CustomTalkID
            self.TempFuncID = CustomTalkID
            self.Cfg = CustomDialogOptionCfg:FindCfgByKey(CustomTalkID)
            self.FuncParams.FuncValue = CustomTalkID  
        elseif AnswerCfg.FuncID ~= 0 then
            self.SaveValueType = SaveValueType.FUNCTION
            local FuncID = AnswerCfg.FuncID
            self.TempFuncID = FuncID
            self.FuncParams.FuncValue = FuncID  
        end
    end
end

function FunctionCustomTalk:GenCustomTalkOptions(CustomTalkID)
    if self.Cfg == nil then
        return 
    end

    local FunctionList = {}
    local OptionVisibilityConditionID = self.Cfg.OptionVisibilityConditionID
    local Conditions = string.split(OptionVisibilityConditionID, ';')
    local Options = self.Cfg.Options
    for i = 1, #Options do
        if (Conditions[i] == nil or Conditions[i] == 0 or ConditionMgr:CheckConditionByID(Conditions[i]))
        and Options[i] ~= nil and Options[i].Title ~= "" then
            local Option = Options[i]
            local Answers = string.split(Option.AnswerID, ';')
            local AnswerContentID = 0
            local TrueCustomTalkID = 0
            for AnswerIdx = 1, #Answers do
                local AnswerCfg = CustomDialogAnswerCfg:FindCfgByKey(Answers[AnswerIdx])
                if AnswerCfg ~= nil and 
                (AnswerCfg.ConditionID == 0 or ConditionMgr:CheckConditionByID(AnswerCfg.ConditionID)) and 
                AnswerCfg.ContentID ~= 0 then
                    AnswerContentID = tonumber(AnswerCfg.ContentID)
                    break
                elseif AnswerCfg ~= nil and 
                (AnswerCfg.ConditionID == 0 or ConditionMgr:CheckConditionByID(AnswerCfg.ConditionID)) then
                    if AnswerCfg.FuncID ~= 0 then
                        AnswerContentID = tonumber(AnswerCfg.AnswerID)
                        break
                    elseif AnswerCfg.CustomTalkID ~= 0 then
                        AnswerContentID = tonumber(AnswerCfg.AnswerID)
                        TrueCustomTalkID = AnswerCfg.CustomTalkID
                    end
                end
            end
            if AnswerContentID > 0 then
                --嵌套CustomTalk且无ContentID在这里处理一下
                local IFuncUnit = FunctionCustomTalk.New()
                IFuncUnit:Init(Option.Title,
                {FuncValue = AnswerContentID, EntityID = self.FuncParams.EntityID, ResID = self.FuncParams.NpcResID,
                IsCustomTalk = TrueCustomTalkID ~= 0, TrueCustomTalkID = TrueCustomTalkID, NeedInsertHistory = true})
                local IconPath = Option.IconPath or ""
                if _G.JumboCactpotMgr:IsJumboAnswer(Answers) and tonumber(Answers[1]) == AnswerContentIDList.Buy then
                    IFuncUnit:SetIconPath(_G.JumboCactpotMgr:GetDialogJumboIconPath())                
                end
                if IconPath and IconPath ~= "" then
                    IFuncUnit:SetIconPath(IconPath)    
                end
                if IFuncUnit then
                    table.insert(FunctionList, IFuncUnit)
                end
            elseif AnswerContentID == 0 and _G.JumboCactpotMgr:IsJumboAnswer(Answers) then
            else
                local IFuncUnit = FunctionNpcQuit.New()
                IFuncUnit:Init(Option.Title,
                {FuncValue = AnswerContentID, EntityID = self.FuncParams.EntityID, ResID = self.FuncParams.NpcResID})

                if IFuncUnit then
                    table.insert(FunctionList, IFuncUnit)
                end
            end
        end
    end

    if #FunctionList == 1 and FunctionList[1].FuncType == LuaFuncType.NPCQUIT_FUNC then
        FunctionList = {}
    end

    return FunctionList
end

function FunctionCustomTalk:GenFuncListByFuncID(FuncID)
    local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
    local FunctionList = {}
    if FuncID then
        local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(
            {FuncValue = FuncID, EntityID = self.FuncParams.EntityID, ResID = self.FuncParams.NpcResID, NeedStopDialog = true}, false, true)
        if InteractFunctionUnit then
            table.insert(FunctionList, InteractFunctionUnit)
        end    
    end
    return FunctionList
end

return FunctionCustomTalk
