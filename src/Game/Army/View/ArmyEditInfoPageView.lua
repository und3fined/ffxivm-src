---
--- Author: daniel
--- DateTime: 2023-03-07 17:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UTF8Util = require("Utils/UTF8Util")

local MsgTipsUtil = _G.MsgTipsUtil
local LSTR = _G.LSTR
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local ArmyEditTextType = ArmyDefine.ArmyEditTextType
local GlobalCfgType = ArmyDefine.GlobalCfgType

local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local ArmyEditInfoHeadSlotVM = require("Game/Army/ItemVM/ArmyEditInfoHeadSlotVM")
local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")

local ArmyMgr = nil


---@class ArmyEditInfoPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgain CommBtnSView
---@field BtnCancel UFButton
---@field BtnCreate CommBtnLView
---@field BtnEditBadge CommBtnSView
---@field BtnInvite CommBtnLView
---@field CommInforBtn CommInforBtnView
---@field CommMoneySlot CommMoneySlotView
---@field CommonRedDot_UIBP CommonRedDotView
---@field HorizontalCurrency UFHorizontalBox
---@field ImgArmy UFImage
---@field ImgArmyIcon UFImage
---@field ImgBadge ArmyBadgeItemView
---@field ImgCurrency UFImage
---@field InputName CommInputBoxView
---@field InputShortName CommInputBoxView
---@field TableView_97 UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field TextArmyNM UFTextBlock
---@field TextArmyName UFTextBlock
---@field TextCount UFTextBlock
---@field TextCreateDate UFTextBlock
---@field TextFinishSign UFTextBlock
---@field TextSign UFTextBlock
---@field TextSignPeopleTips UFTextBlock
---@field TextSubtitle UFTextBlock
---@field TextTime UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimCreate UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyEditInfoPageView = LuaClass(UIView, true)

--- 部队名字最小长度
local Name_Min_Limit = nil
--- 部队名字最大长度
local Name_Max_Limit = nil
--- 简称最小长度
local ShortName_Min_Limit = nil
--- 简称最大长度
local ShortName_Max_Limit = nil
--- 招募标语最小长度
local Slogin_Min_Limit = nil
--- 招募标语
local Slogin_Max_Limit = nil
--- 是否选中了徽章
local bSelectedBadge = false
--- 是否名称合规
local bNormArmyName = false
--- 是否简称合规
local bNormShortName = false
--- 是否招募标语合规
local bNormSlogin = true

local IsOutArmyTimeEnough = false

local CurGrandID = nil

local OldRecruitSlogan = nil

--- 检测是否是纯符号
---@param Text string
function ArmyEditInfoPageView:CheckIsAllSign(Text)
    if Text == nil then
        return false
    end
    local Pattern = "^[%p%s]+$"
    if string.match(Text, Pattern) then
        return true
    else
        return false
    end
end

--- 检测是否含有数字
---@param Text string
function ArmyEditInfoPageView:CheckIsNumStr(Text)
    if Text == nil then
        return false
    end
    local Pattern = "%d+"
    if string.match(Text, Pattern) then
        return true
    else
        return false
    end
end

function ArmyEditInfoPageView:SetErrorTip(TextType)
    -- LSTR string:您输入的内容不可使用，请重新输入。
    --MsgTipsUtil.ShowTips(LSTR(910126))
    if TextType == ArmyDefine.ArmyEditTextType.ArmyName then
        bNormArmyName = false
    elseif TextType == ArmyDefine.ArmyEditTextType.ShortName then
        bNormShortName = false
    elseif TextType == ArmyDefine.ArmyEditTextType.RecruitSlogan then
        --招募标语校验关闭
        --bNormSlogin = false
    end
    --self:CheckedCreateBtnState()
end

--- 简称字符是否符合规则
function ArmyEditInfoPageView:CheckNameRule(TextType, Min, Max, Text, CallBack, IsShowTips)
    local Length = UTF8Util.Len(Text)
    local bRecruitSloganType = TextType ~= ArmyDefine.ArmyEditTextType.RecruitSlogan
    if Length == nil then
        Length = 0
    end
    if nil == Min or nil == Max then
        self.IsWaitCheck = false
        return
    end
    --- Max文本交给输入框处理，min文本额外提示
    if Length < Min or Length > Max or (Length == ArmyDefine.Zero and bRecruitSloganType) then
        self.IsWaitCheck = false
        return
    end
    if string.match(Text, "^%s+") or string.match(Text, "%s+$") then
        ---开头结尾使用空格
        self:SetErrorTip(TextType)
        self:CheckedCreateInfoError(not IsShowTips)
        self.IsWaitCheck = false
        return
    end
    if string.match(Text, "%s%s") then
        ---连续使用空格与下划线
        self:SetErrorTip(TextType)
        self:CheckedCreateInfoError(not IsShowTips)
        self.IsWaitCheck = false
        return
    end
    if string.match(Text, "_%_") then
        ---连续使用空格与下划线
        self:SetErrorTip(TextType)
        self:CheckedCreateInfoError(not IsShowTips)
        self.IsWaitCheck = false
        return
    end
    if TextType == ArmyEditTextType.ArmyName or TextType == ArmyEditTextType.ShortName then
        if not string.match(Text, "^[%w%s\228-\233\128-\191_:;!?&%-]+$") then
            --名称、简称可以使用中文、字母、空格、下划线,:;!?&-
            self:SetErrorTip(TextType)
            self:CheckedCreateInfoError(not IsShowTips)
            self.IsWaitCheck = false
            return
        end
        local bAllSign = self:CheckIsAllSign(Text)
        local bNumStr = self:CheckIsNumStr(Text)
        if bAllSign then
            --使用纯符号作为名称或简称
            self:SetErrorTip(TextType)
            self:CheckedCreateInfoError(not IsShowTips)
            self.IsWaitCheck = false
            return
        end
        if bNumStr then
            --使用数字作为名称或简称
            self:SetErrorTip(TextType)
            self:CheckedCreateInfoError(not IsShowTips)
            self.IsWaitCheck = false
            return
        end
    end
    -- 查询文本是否合法（敏感词）
    -- if TextType == ArmyEditTextType.RecruitSlogan then
    --     --if OldRecruitSlogan ~= Text then
    --         OldRecruitSlogan = Text
    --         ArmyMgr:SendCheckSloganMsg(Text)
    --     --end
    -- else
        ArmyMgr:CheckSensitiveText(Text, function( IsLegal )
            self.IsWaitCheck = false
            if IsLegal then
                if TextType == ArmyDefine.ArmyEditTextType.ArmyName then
                    bNormArmyName = true
                elseif TextType == ArmyDefine.ArmyEditTextType.ShortName then
                    bNormShortName = true
                elseif TextType == ArmyEditTextType.RecruitSlogan then
                    bNormSlogin = true
                end
                self:CheckedCreateBtnState()
                CallBack()
            else
                --输入的内容包含敏感词汇
                self:SetErrorTip(TextType)
                self:CheckedCreateInfoError(not IsShowTips)
            end
        end)
    --end
end

function ArmyEditInfoPageView:SetRecruitSlogan(Text)
    if OldRecruitSlogan == nil or Text == nil then
        return
    end
    local IsLegal = Text == OldRecruitSlogan
    OldRecruitSlogan = Text
    if IsLegal then
        bNormSlogin = true
        self:CheckedCreateBtnState()
    else
        --self.InputRecruitSlogan:SetText(Text)
        --输入的内容包含敏感词汇
        -- LSTR string:您输入的内容不可使用，请重新输入。
        MsgTipsUtil.ShowTips(LSTR(910126))
        return
    end
end

function ArmyEditInfoPageView:CheckedCreateInfoError(IsNoTips)
    local TipsStr = ""
    local NameStr
    local StrList = {}
    if not bNormArmyName then
        -- LSTR string:部队名字
        NameStr = LSTR(910251)
        table.insert(StrList, NameStr)
    end
    local ShortNameStr
    if not bNormShortName then
        -- LSTR string:部队简称
        ShortNameStr = LSTR(910262)
        table.insert(StrList, ShortNameStr)
    end
    ---招募标语判断屏蔽
    -- local RecruitSloganStr
    -- if not bNormSlogin then
    --     -- LSTR string:招募标语
    --     RecruitSloganStr = LSTR(910136)
    --     table.insert(StrList, RecruitSloganStr)
    -- end
    
    if #StrList == 0 then
        return false
    else
        if #StrList == 1 then
            -- LSTR string:%s不可使用，请重新输入。
            TipsStr = string.format(LSTR(910014), StrList[1])
        elseif #StrList == 2 then
            -- LSTR string:%s、%s不可使用，请重新输入。
            TipsStr = string.format(LSTR(910009), StrList[1], StrList[2])
        elseif #StrList == 3 then
            -- LSTR string:%s、%s、%s不可使用，请重新输入。
            TipsStr = string.format(LSTR(910007),StrList[1], StrList[2],StrList[3])
        end
        if not IsNoTips then
            MsgTipsUtil.ShowErrorTips(TipsStr)
        end
        return true
    end

end

function ArmyEditInfoPageView:CheckedCreateInfoEmpty(IsNoTips)
    local TipsStr = ""
    local NameStr = self.InputName:GetText()
    local StrList = {}
    if string.isnilorempty(NameStr) then
        -- LSTR string:部队名字
        NameStr = LSTR(910251)
        table.insert(StrList, NameStr)
    end
    local ShortNameStr = self.InputShortName:GetText()
    if string.isnilorempty(ShortNameStr) then
        -- LSTR string:部队简称
        ShortNameStr = LSTR(910262)
        table.insert(StrList, ShortNameStr)
    end
    ---招募标语屏蔽
    -- local RecruitSloganStr = self.InputRecruitSlogan:GetText()
    -- if string.isnilorempty(RecruitSloganStr) then
    --     -- LSTR string:招募标语
    --     RecruitSloganStr = LSTR(910136)
    --     table.insert(StrList, RecruitSloganStr)
    -- end
    
    if #StrList == 0 then
        return false
    else
        if #StrList == 1 then
            -- LSTR string:%s未填写！
            TipsStr = string.format(LSTR(910018), StrList[1])
        elseif #StrList == 2 then
            -- LSTR string:%s、%s未填写！
            TipsStr = string.format(LSTR(910010), StrList[1], StrList[2])
        elseif #StrList == 3 then
            -- LSTR string:%s、%s、%s未填写！
            TipsStr = string.format(LSTR(910008),StrList[1], StrList[2],StrList[3])
        end
        if not IsNoTips then
            MsgTipsUtil.ShowTips(TipsStr)
        end
        return true
    end

end


--- todo判断逻辑重构
-- function ArmyEditInfoPageView:CheckedCreateBtnState()
--     if IsOutArmyTimeEnough and self.bEnoughScore then
--         self.BtnCreate:UpdateImage(CommBtnColorType.Recommend)
--     else
--         self.BtnCreate:UpdateImage(CommBtnColorType.Disable)
--     end
-- end

function ArmyEditInfoPageView:CheckedCreateBtnState()
    ---会在回包的时候调用,做一次Object判断拦截
    if self.Object ~= nil and self.Object:IsValid() then
        ---特殊处理，输入框输入的时候，置灰
        if self.IsInput then
            self.BtnCreate:SetIsDisabledState(true, true)
            return
        end
        if self.IsGivePeition then
            ---领取组建书状态 水晶点/署名人数/名称、简称未填写
            if  self.bEnoughScore and self.bEnouoghSignNum and not self:CheckedCreateInfoEmpty(true) then
                self.BtnCreate:SetIsRecommendState(true)
            else
                self.BtnCreate:SetIsDisabledState(true, true)
            end
        else
            ---未领取组建书状态 退出时间/署名其他组建书/名称、简称未填写
            if IsOutArmyTimeEnough and not self:CheckedCreateInfoEmpty(true)  then
                self.BtnCreate:SetIsRecommendState(true)
            else
                self.BtnCreate:SetIsDisabledState(true, true)
            end
        end
    end
end

function ArmyEditInfoPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgain = nil
	--self.BtnCancel = nil
	--self.BtnCreate = nil
	--self.BtnEditBadge = nil
	--self.BtnInvite = nil
	--self.CommInforBtn = nil
	--self.CommMoneySlot = nil
	--self.CommonRedDot_UIBP = nil
	--self.HorizontalCurrency = nil
	--self.ImgArmy = nil
	--self.ImgArmyIcon = nil
	--self.ImgBadge = nil
	--self.ImgCurrency = nil
	--self.InputName = nil
	--self.InputShortName = nil
	--self.TableView_97 = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.TextArmyNM = nil
	--self.TextArmyName = nil
	--self.TextCount = nil
	--self.TextCreateDate = nil
	--self.TextFinishSign = nil
	--self.TextSign = nil
	--self.TextSignPeopleTips = nil
	--self.TextSubtitle = nil
	--self.TextTime = nil
	--self.AnimCheck = nil
	--self.AnimCreate = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.Callback = nil
    self.CommittedCallback = nil
    self.IsWaitCheck = nil
    self.IsInput = nil
end

function ArmyEditInfoPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAgain)
	self:AddSubView(self.BtnCreate)
	self:AddSubView(self.BtnEditBadge)
	self:AddSubView(self.BtnInvite)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommMoneySlot)
	self:AddSubView(self.CommonRedDot_UIBP)
	self:AddSubView(self.ImgBadge)
	self:AddSubView(self.InputName)
	self:AddSubView(self.InputShortName)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyEditInfoPageView:OnInit()
    ArmyMgr = require("Game/Army/ArmyMgr")
    self.BadgeData = {
        TotemID = 0,
        IconID = 0,
        BackgroundID = 0,
    }
    self.DefaultBadgeData = {
        TotemID = 0,
        IconID = 0,
        BackgroundID = 0,
    }
    self.bEnoughScore = false
    Name_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMinLimit)
    Name_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMaxLimit)
    ShortName_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMinLimit)
    ShortName_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMaxLimit)
    Slogin_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMinLimit)
    Slogin_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMaxLimit)
    bNormArmyName = false
    bNormShortName = false
	self.InputName:SetText("")
	self.InputName:SetMaxNum(Name_Max_Limit)
	self.InputShortName:SetText("")
	self.InputShortName:SetMaxNum(ShortName_Max_Limit)
	-- self.InputRecruitSlogan:SetText("")
	-- self.InputRecruitSlogan:SetMaxNum(Slogin_Max_Limit)
    -- LSTR string:请输入部队名字
    self.InputName:SetHintText(LSTR(910232))
    -- LSTR string:请输入部队简称
    self.InputShortName:SetHintText(LSTR(910234))
    self.ImgBadge:SetBadgeData(self.BadgeData)
    --bNormSlogin = Slogin_Min_Limit == 0
    bSelectedBadge = false
    --UIUtil.SetIsVisible(self.BtnTipsNew, true)
    self.InputName:SetCallback(self, nil, self.OnTextArmyNameCommitted)
    self.InputShortName:SetCallback(self, nil, self.OnTextArmyShortNameCommitted)
	self.TableViewSignAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_97, nil, nil, nil, nil, true, true)
	self.SignList = UIBindableList.New( ArmyEditInfoHeadSlotVM )
end

---重置数据
function ArmyEditInfoPageView:ResetInfo()
    self.BadgeData = {
        TotemID = 0,
        IconID = 0,
        BackgroundID = 0,
    }
    self.DefaultBadgeData = {
        TotemID = 0,
        IconID = 0,
        BackgroundID = 0,
    }
    self.bEnoughScore = false
    Name_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMinLimit)
    Name_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMaxLimit)
    ShortName_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMinLimit)
    ShortName_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMaxLimit)
    Slogin_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMinLimit)
    Slogin_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMaxLimit)
    bNormArmyName = false
    bNormShortName = false
	self.InputName:SetText("")
	self.InputName:SetMaxNum(Name_Max_Limit)
	self.InputShortName:SetText("")
	self.InputShortName:SetMaxNum(ShortName_Max_Limit)
	-- self.InputRecruitSlogan:SetText("")
	-- self.InputRecruitSlogan:SetMaxNum(Slogin_Max_Limit)
    -- LSTR string:请输入部队名字
    self.InputName:SetHintText(LSTR(910232))
    -- LSTR string:请输入部队简称
    self.InputShortName:SetHintText(LSTR(910234))
    self.ImgBadge:SetBadgeData(self.BadgeData)
    --bNormSlogin = Slogin_Min_Limit == 0
    bSelectedBadge = false
    --UIUtil.SetIsVisible(self.BtnTipsNew, true)
    self.InputName:SetCallback(self, nil, self.OnTextArmyNameCommitted)
    self.InputShortName:SetCallback(self, nil, self.OnTextArmyShortNameCommitted)
end

function ArmyEditInfoPageView:OnDestroy()
end

function ArmyEditInfoPageView:OnShow()
    ---文本设置
    -- LSTR string:编辑部队信息
    self.TextSubtitle:SetText(LSTR(910283))
	-- LSTR string:部队简称
	self.TextArmyNM:SetText(LSTR(910285))
	-- LSTR string:部队名字
	self.TextArmyName:SetText(LSTR(910284))
	-- LSTR string:招募标语
	--self.TextArmyRecruit:SetText(LSTR(910286))
    -- LSTR string:退出部队未满24小时
    self.TextTime:SetText(LSTR(910287))
	-- LSTR string:写下对部队成员的期待吧！
	--self.InputRecruitSlogan:SetHintText(LSTR(910288))
    -- LSTR string:大国防联军
    self.Text01:SetText(LSTR(910289))
    -- LSTR string:已完成署名
    self.TextFinishSign:SetText(LSTR(910404))
	--self.TableViewSignAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_97, nil, nil, nil, nil, true, true)
    ---蓝图配置第一次不生效，断点看获取的style是nil，代码设置一下
    self.CommInforBtn:SetButtonStyle(4)
    self.BtnAgain:UpdateImage(CommBtnColorType.Normal)
    local Cost = GroupGlobalCfg:GetValueByType(GlobalCfgType.CreateArmyNeedGold) or 0
    local ScoreType = GroupGlobalCfg:GetValueByType(GlobalCfgType.CreateArmyScoreType)
    local MyScore = ScoreMgr:GetScoreValueByID(ScoreType) or 0

    -- local MoneyIcon = ScoreMgr:GetScoreIconName(ScoreType)

    IsOutArmyTimeEnough = false
    local LastQuitTime = ArmyMainVM:GetLastQuitTime()
    local QuitTime = _G.TimeUtil.GetServerTime() - LastQuitTime - ArmyDefine.Day
    if LastQuitTime == ArmyDefine.Zero then
        IsOutArmyTimeEnough = true
    else
        IsOutArmyTimeEnough = QuitTime >= 0
    end
    if not IsOutArmyTimeEnough then
        UIUtil.SetIsVisible(self.TextTime, true)
        UIUtil.SetIsVisible(self.HorizontalCurrency, false)
    else
        UIUtil.SetIsVisible(self.TextTime, false)
        UIUtil.SetIsVisible(self.HorizontalCurrency, true)
    end 
    self.bEnoughScore = MyScore >= Cost
    self.CommMoneySlot:UpdateView(ScoreType, false, nil, true)
    self.CommMoneySlot.TextMoneyAmount:SetText(self:FormatNumber(MyScore))
    self:SetCreateMoney(ScoreType, Cost)
    self:CheckedCreateBtnState()

    -- LSTR string:编辑队徽
    self.BtnEditBadge:SetText(LSTR(910207))
    -- LSTR string:重选
    self.BtnAgain:SetText(LSTR(910266))
    -- LSTR string:创建部队
    --self.BtnCreate:SetText(LSTR(910071))
    local PetitionData = ArmyMgr:GetArmyCreatePeitionData()
    local IsGivePeition = PetitionData and PetitionData.GroupPetition
    self:SetIsGivePeition(IsGivePeition, PetitionData)
end

function ArmyEditInfoPageView:OnHide()
    self.SignList:Clear()
    self.IsWaitCheck = false
    self.IsInput = false
    --self.TableViewSignAdapter:DestroyView()
    --self.TableViewSignAdapter = nil
    --self.SignList = nil
end

function ArmyEditInfoPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEditBadge, self.OnClickedEditBadge)
	UIUtil.AddOnClickedEvent(self, self.BtnCreate, self.OnClickedCreate)
    UIUtil.AddOnClickedEvent(self, self.BtnAgain, self.OnClickedBack)
    UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedCancelCreate)
    UIUtil.AddOnClickedEvent(self, self.BtnInvite, self.OnClickedInvite)
    ---快速处理，P5转服务器验证
    UIUtil.AddOnFocusReceivedEvent(self, self.InputName.InputText, self.OnTextFocusReceived)
    UIUtil.AddOnFocusReceivedEvent(self, self.InputShortName.InputText, self.OnTextFocusReceived)
end

function ArmyEditInfoPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ArmySignNumToc, self.OnSignNumToc)
end

function ArmyEditInfoPageView:OnRegisterBinder()
end

---署名人数变化时，请求一下数据来刷新
function ArmyEditInfoPageView:OnSignNumToc()
    ArmyMgr:SendGroupPeitionQuery()
end

--- 部队名称submit时触发
function ArmyEditInfoPageView:OnTextArmyNameCommitted(Text)
    local ArmyCreatePanelVM = ArmyMainVM:GetCreatePanelVM()
    local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
    self.IsInput = false
    self.IsWaitCheck = true
	self:CheckNameRule(ArmyEditTextType.ArmyName, Name_Min_Limit, Name_Max_Limit, Text, function()
        if IsGivePeition and ArmyCreatePanelVM then
            ArmyCreatePanelVM:SendGroupPeitionEdit(Text)
        end
    end, IsGivePeition)
    self:CheckedCreateBtnState()
end

function ArmyEditInfoPageView:OnTextFocusReceived()
    self.IsInput = true
    self:CheckedCreateBtnState()
end

--- 部队简称submit时触发
function ArmyEditInfoPageView:OnTextArmyShortNameCommitted(Text)
    self.IsInput = false
    self.IsWaitCheck = true
    local ArmyCreatePanelVM = ArmyMainVM:GetCreatePanelVM()
    local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
	self:CheckNameRule(ArmyEditTextType.ShortName, ShortName_Min_Limit, ShortName_Max_Limit, Text, function()
        if IsGivePeition and ArmyCreatePanelVM then
            ArmyCreatePanelVM:SendGroupPeitionEdit(nil,Text)
        end
    end, IsGivePeition)
    self:CheckedCreateBtnState()
end

--- 部队标语submit时触发
function ArmyEditInfoPageView:OnTextArmyRecruitSloganCommitted(Text)
	self:CheckNameRule(ArmyEditTextType.RecruitSlogan, Slogin_Min_Limit, Slogin_Max_Limit, Text)
end

--- 编辑徽章
function ArmyEditInfoPageView:OnClickedEditBadge()
    local function CommitedCallback(Data)
        self:OnSelectedBadgeCommited(Data)
    end
    local Cfg =  GrandCompanyCfg:FindCfgByKey(CurGrandID)
    if Cfg and Cfg.BgIcon then
        UIViewMgr:ShowView(UIViewID.ArmyEmblemEditPanel, {UnitedIcon = Cfg.BgIcon, BadgeData = self.BadgeData, CommitedCallback = CommitedCallback, GrandCompanyType = CurGrandID})
    end
end

function ArmyEditInfoPageView:OnSelectedBadgeCommited(BadgeData)
    self.BadgeData = BadgeData
    bSelectedBadge = true
    self.ImgBadge:SetBadgeData(BadgeData)
    self:CheckedCreateBtnState()
    local ArmyCreatePanelVM = ArmyMainVM:GetCreatePanelVM()
    local IsGivePeition = ArmyCreatePanelVM:GetIsGivePeition()
    if IsGivePeition and ArmyCreatePanelVM then
        ArmyCreatePanelVM:SendGroupPeitionEdit(nil,nil, BadgeData)
    end
end


--- 创建
function ArmyEditInfoPageView:OnClickedCreate()
    if not self.bCreate then
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyErrorCode.CodeCreateAuthFailed)
        return
    end
    ---文本校验还没回包，进行拦截提示，后续改为服务器提示
    if self.IsWaitCheck or self.IsInput then
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InputCheck)
        return
    end
    local CreateVM = ArmyMainVM:GetCreatePanelVM()
    local IsGivePeition = CreateVM:GetIsGivePeition()
    --- 判断费用是否足够/是否为空/是否输入有格式或敏感词问题
    if not self:CheckedCreateInfoEmpty() and not self:CheckedCreateInfoError() then
        if not self.bEnoughScore and IsGivePeition then
            -- LSTR string:您的货币不足
            MsgTipsUtil.ShowTips(LSTR(910125))
            return
        end
    else
        return
    end
    --- 如果是创建部队，检查是否人数已满
    if IsGivePeition and not self.bEnouoghSignNum then
        -- LSTR string:无法创建，署名人数不足%s人
        local TextStr = string.format(LSTR(910341), ArmyMgr:GetArmySignFullNum())
        MsgTipsUtil.ShowErrorTips(TextStr)
        return
    end
    local function Callback()
        if self.CommittedCallback ~= nil then
            --self:PlayAnimation(self.AnimCreate)
            if self.Object ~= nil and self.Object:IsValid() then
                self.CommittedCallback(self.InputName:GetText(), self.InputShortName:GetText(), self.BadgeData)
            else
                _G.FLOG_WARNING("ArmyEditInfoPageView.Object is nil or not valid")
            end
        end
	end
    local RichArmyName = RichTextUtil.GetText(self.InputName:GetText(), ArmyTextColor.YellowHex)
    local ContentStr = ""
    if IsGivePeition then
        ---LSTR: 是否与当前署名成员共同创建部队？署名成员将会以初始成员身份加入部队
        ContentStr = string.format(LSTR(910339))
    else
        ---LSTR: 在部队创建之前，部队名字可能会被其他部队占用，是否领取部队创建书
        ContentStr = string.format(LSTR(910344))
    end
	-- LSTR string:提示
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(910338), ContentStr, Callback, nil, LSTR(910083), LSTR(910185))
end

--- 返回
function ArmyEditInfoPageView:OnClickedBack()
    if self.Callback ~= nil then
        self.Callback()
    end
end

---随机队徽配置
function ArmyEditInfoPageView:BadgeDataRandomly(GrandID)
    if GrandID == nil then
        return
    end
    local Cfg =  GrandCompanyCfg:FindCfgByKey(GrandID)
    local Length = #Cfg.ArmyBadge
    local BadgeIndex = math.random(1, Length)
    ---做一下隔离，重进要恢复默认
    self.DefaultBadgeData.TotemID = Cfg.ArmyBadge[BadgeIndex].IDs.ImpliedID or 0
    self.DefaultBadgeData.IconID = Cfg.ArmyBadge[BadgeIndex].IDs.ShieldID or 0
    self.DefaultBadgeData.BackgroundID = Cfg.ArmyBadge[BadgeIndex].IDs.BgID or 0
end

--- 设置回传
---@param GrandID number @联盟Type
function ArmyEditInfoPageView:SetCallback(GrandID, Callback, CommittedCallback)
    --- 切换国防联军时,判断有无专属寓意物
    local Cfg =  GrandCompanyCfg:FindCfgByKey(GrandID)
    local IsNeedReset = true
    if self.DefaultBadgeData.TotemID == 0 then
        ---onshow会触发一次组建书数据处理，这个时间点IsGivePeition可以使用
        ---有组建书使用组建书数据，初始不随机
        if not self.IsGivePeition then
            self:BadgeDataRandomly(GrandID)
        end
    elseif CurGrandID and CurGrandID ~= GrandID then
        local TotemID = self.DefaultBadgeData.TotemID
        local CurTotemID = self.BadgeData.TotemID
        local TotemCfg = GroupEmblemTotemCfg:FindCfgByKey(TotemID)
        local CurTotemCfg = GroupEmblemTotemCfg:FindCfgByKey(CurTotemID)
        local IsNeedRandomly = true
        if TotemCfg and TotemCfg.CompanyIDs then
            for _, CompanyID in ipairs(TotemCfg.CompanyIDs) do
                if GrandID == CompanyID then
                    IsNeedRandomly = false
                end
            end
        end
        if CurTotemCfg and CurTotemCfg.CompanyIDs then
            for _, CompanyID in ipairs(CurTotemCfg.CompanyIDs) do
                if GrandID == CompanyID then
                    IsNeedReset = false
                end
            end
        end
        if IsNeedRandomly then
            self:BadgeDataRandomly(GrandID)
        end
    elseif CurGrandID and CurGrandID == GrandID then
        IsNeedReset = false
    end
    CurGrandID = GrandID
    if IsNeedReset then
        self.BadgeData.TotemID = self.DefaultBadgeData.TotemID
        self.BadgeData.IconID = self.DefaultBadgeData.IconID
        self.BadgeData.BackgroundID = self.DefaultBadgeData.BackgroundID
        self.ImgBadge:SetBadgeData(self.DefaultBadgeData)
        ---如果重置队徽，更新一下vm里的数据
        local ArmyCreatePanelVM = ArmyMainVM:GetCreatePanelVM()
        ArmyCreatePanelVM:SetBadgeData(self.BadgeData)
    end
    if Cfg then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgArmy, Cfg.BgIcon)
        self.Text02:SetText(Cfg.Name)
        ---设置小图标
        UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyIcon, Cfg.EditIcon)
    end
	self.Callback = Callback
	self.CommittedCallback = CommittedCallback

    local TextColor 
    if CurGrandID == ArmyDefine.GrandCompanyType.ShuangShe then
        TextColor = "313131FF"
    else
        TextColor = "D5D5D5FF"
    end
    UIUtil.SetColorAndOpacityHex(self.Text01, TextColor)
    UIUtil.SetColorAndOpacityHex(self.Text02, TextColor)
end

function ArmyEditInfoPageView:SetCreateData(IsAllowsCreate)
    self.bCreate = IsAllowsCreate
end

function ArmyEditInfoPageView:ClearCurGrandID()
    CurGrandID = nil
end

function ArmyEditInfoPageView:FormatNumber(Number)
    
    local resultNum = Number
    if type(Number) == "number" then
        local inter, point = math.modf(Number)

        local StrNum = tostring(inter)
        local NewStr = ""
        local NumLen = string.len( StrNum )
        local Count = 0
        for i = NumLen, 1, -1 do
            if Count % 3 == 0 and Count ~= 0  then
                NewStr = string.format("%s,%s",string.sub( StrNum,i,i),NewStr) 
            else
                NewStr = string.format("%s%s",string.sub( StrNum,i,i),NewStr) 
            end
            Count = Count + 1
        end

        if point > 0 then
            --@desc 存在小数点，
            local strPoint = string.format( "%.2f", point )
            resultNum = string.format("%s%s",NewStr,string.sub( strPoint,2, string.len( strPoint ))) 
        else
            resultNum = NewStr
        end
    end
    
    return resultNum
end

function ArmyEditInfoPageView:PlayAnimCheck()
    self:PlayAnimation(self.AnimCheck)
end

function ArmyEditInfoPageView:OnAnimationFinished(Anim)
    if Anim == self.AnimCreate then
        if self.CreateCallback ~= nil then
            self.CreateCallback()
        end
    end
end

function ArmyEditInfoPageView:PlayAnimShow()
    self:PlayAnimation(self.AnimShow)
end

function ArmyEditInfoPageView:PlayAnimCreate()
    self:PlayAnimation(self.AnimCreate)
end

function ArmyEditInfoPageView:SetCreateMoney(ScoreType, Cost)
    local ScoreIcon = ScoreMgr:GetScoreIconName(ScoreType)
    if ScoreIcon then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgCurrency, ScoreIcon)
    end
    self.TextCount:SetText(self:FormatNumber(Cost))
    local LinearColor
    if self.bEnoughScore then
        LinearColor = _G.UE.FLinearColor.FromHex(ArmyTextColor.YellowHex)
    else
		LinearColor = _G.UE.FLinearColor.FromHex("DC5868FF")
    end
    self.TextCount:SetColorAndOpacity(LinearColor)
end

---设置创建状态
function ArmyEditInfoPageView:SetIsGivePeition(IsGivePeition, PetitionData)
    self.IsGivePeition = IsGivePeition
    local CurSignNum = 0
    local MaxSignNum = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgGroupSignNum) or 0
    local Signs = {}
    if IsGivePeition then
        ---已领取组建书
        if PetitionData then
            ---创建消耗显示
            UIUtil.SetIsVisible(self.HorizontalCurrency, true)

            ---时间设置
            local GainTime = PetitionData.GainTime
            if GainTime then
                UIUtil.SetIsVisible(self.TextCreateDate, true)
                local GainTimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d", GainTime)
                local LocalGainTimeStr =  LocalizationUtil.GetTimeForFixedFormat(GainTimeStr)
                -- LSTR string:创建时间
                self.TextCreateDate:SetText(string.format(LSTR(910342),LocalGainTimeStr))
            end
            ---署名列表显示，提示文本隐藏
            --UIUtil.SetIsVisible(self.TableView_97, true)
            UIUtil.SetIsVisible(self.TextSignPeopleTips, false)
            ---署名人数设置
            if PetitionData.Signs then
                CurSignNum = #PetitionData.Signs
                for Index, RoleID in ipairs(PetitionData.Signs) do
                   local Item = {RoleID = RoleID, ID = Index}
                   table.insert(Signs, Item)
                end
            end
            local EmptyNum =  MaxSignNum - CurSignNum
            for i = 1, EmptyNum do
                local Item = {IsEmpty = true, ID = i}
                table.insert(Signs, Item)
            end
            self.bEnouoghSignNum = MaxSignNum == CurSignNum
            UIUtil.SetIsVisible(self.TextFinishSign, self.bEnouoghSignNum)
            ---按钮设置
            -- LSTR string:创建部队
            self.BtnCreate:SetText(LSTR(910071))
            UIUtil.SetIsVisible(self.BtnCancel, true, true)
            UIUtil.SetIsVisible(self.BtnInvite, not self.bEnouoghSignNum)
            -- LSTR string:邀请署名
            self.BtnInvite:SetText(LSTR(910336))
            local GroupPetition = PetitionData.GroupPetition
            if GroupPetition then
                local GrandCompanyType = GroupPetition.GrandCompanyType
                local Name = GroupPetition.Name
                local Alias = GroupPetition.Alias
                local Emblem = GroupPetition.Emblem
                self.InputName:SetText(Name)
                self.InputShortName:SetText(Alias)
                ---关闭敏感词拦截
                bNormArmyName = true
                bNormShortName = true
                self.ImgBadge:SetBadgeData(Emblem)
                self.BadgeData = table.clone(Emblem)
                self.DefaultBadgeData = table.clone(self.BadgeData)
                CurGrandID = GrandCompanyType
                local Cfg =  GrandCompanyCfg:FindCfgByKey(CurGrandID)
                if Cfg then
                    UIUtil.ImageSetBrushFromAssetPath(self.ImgArmy, Cfg.BgIcon)
                end
            end
        end
    else
        ---未领取组建书
        ---创建消耗隐藏
        UIUtil.SetIsVisible(self.HorizontalCurrency, false)
        ---日期隐藏
        UIUtil.SetIsVisible(self.TextCreateDate, false)
        ---署名列表隐藏，提示文本显示
        --UIUtil.SetIsVisible(self.TableView_97, false)
        UIUtil.SetIsVisible(self.TextSignPeopleTips, true)
        -- LSTR string:署名人
        self.TextSign:SetText(LSTR(910335))
        -- LSTR string:领取部队组建书后，需要邀请三名志同道合的成员进去部队署名以完成部队创建
        self.TextSignPeopleTips:SetText(LSTR(910348))
        ---按钮设置
        -- LSTR string:领取部队组建书
        self.BtnCreate:SetText(LSTR(910343))
        UIUtil.SetIsVisible(self.BtnCancel, false)
        UIUtil.SetIsVisible(self.BtnInvite, false)
        UIUtil.SetIsVisible(self.TextFinishSign, false)
    end
    ---排序交由服务器 or todo 待定
    self.SignList:UpdateByValues(Signs)
    self.TableViewSignAdapter:UpdateAll(self.SignList)
    self:CheckedCreateBtnState()
    -- LSTR string:署名人
    self.TextSign:SetText(string.format("%s %s/%s", LSTR(910335), CurSignNum, MaxSignNum))
end

function ArmyEditInfoPageView:OnClickedCancelCreate()
    local function Callback()
        ArmyMgr:SendCancelCreate()
	end

	-- LSTR string:部队组建
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(910338), LSTR(910345), Callback, nil, LSTR(910083), LSTR(910185))
end

---署名人数变化时，请求一下数据来刷新
function ArmyEditInfoPageView:OnClickedInvite()
    ArmyMgr:OpenInviteWinByItemType(InviteSignSideDefine.InviteItemType.ArmySignInvite)
end

return ArmyEditInfoPageView