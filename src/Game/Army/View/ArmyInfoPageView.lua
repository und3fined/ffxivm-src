---
--- Author: daniel
--- DateTime: 2023-03-18 10:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UTF8Util = require("Utils/UTF8Util")
local FLinearColor = _G.UE.FLinearColor

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local TipsUtil = require("Utils/TipsUtil")

local PersonInfoMgr = require("Game/PersonInfo/PersonInfoMgr")
local ArmyMgr = nil

local ArmyDefine = require("Game/Army/ArmyDefine")
local GloalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyFlagTextColors = ArmyDefine.ArmyFlagTextColors

local ChatDefine = require("Game/Chat/ChatDefine")
local ChatChannel = ChatDefine.ChatChannel

local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local SCORE_TYPE = ProtoRes.SCORE_TYPE

local LSTR
local UIViewMgr
local UIViewID
local ArmyMainVM
local ArmyInfoPageVM

---@class ArmyInfoPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnCopy UFButton
---@field BtnCurrencTips UFButton
---@field BtnEditInfo CommBtnLView
---@field BtnGradeInfo CommInforBtnView
---@field BtnLeader UFButton
---@field BtnReport UFButton
---@field BtnTrends UFButton
---@field FCanvasPanel_18 UFCanvasPanel
---@field ImgCombatGainsIcon UFImage
---@field ImgEditTrends UFImage
---@field ImgIcon UFImage
---@field ImgPeopleIcon UFImage
---@field PanelRuleTips UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProgressBarGrade UProgressBar
---@field RichTextCombatGains URichTextBox
---@field RichTextGrade URichTextBox
---@field RichTextPeople URichTextBox
---@field ShowInfoPage ArmyShowInfoPageView
---@field TableViewPrivilege UTableView
---@field TableViewSE UTableView
---@field TableViewTrends UTableView
---@field Text UFTextBlock
---@field TextArmyName UFTextBlock
---@field TextArmyName02 UFTextBlock
---@field TextGade UFTextBlock
---@field TextGade01 UFTextBlock
---@field TextLeader UFTextBlock
---@field TextNoTrends UFTextBlock
---@field TextNotice UFTextBlock
---@field TextNoticeTitle UFTextBlock
---@field TextPrivilege UFTextBlock
---@field TextSE UFTextBlock
---@field TextTips01 UFTextBlock
---@field TextTips02 UFTextBlock
---@field TextTips03 UFTextBlock
---@field TextTips04 UFTextBlock
---@field TextTrends UFTextBlock
---@field Text_1 UFTextBlock
---@field TextleaderName UFTextBlock
---@field AnimCreate UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInfoPageView = LuaClass(UIView, true)

function ArmyInfoPageView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnCopy = nil
	--self.BtnCurrencTips = nil
	--self.BtnEditInfo = nil
	--self.BtnGradeInfo = nil
	--self.BtnLeader = nil
	--self.BtnReport = nil
	--self.BtnTrends = nil
	--self.FCanvasPanel_18 = nil
	--self.ImgCombatGainsIcon = nil
	--self.ImgEditTrends = nil
	--self.ImgIcon = nil
	--self.ImgPeopleIcon = nil
	--self.PanelRuleTips = nil
	--self.PanelTips = nil
	--self.PlayerHeadSlot = nil
	--self.ProgressBarGrade = nil
	--self.RichTextCombatGains = nil
	--self.RichTextGrade = nil
	--self.RichTextPeople = nil
	--self.ShowInfoPage = nil
	--self.TableViewPrivilege = nil
	--self.TableViewSE = nil
	--self.TableViewTrends = nil
	--self.Text = nil
	--self.TextArmyName = nil
	--self.TextArmyName02 = nil
	--self.TextGade = nil
	--self.TextGade01 = nil
	--self.TextLeader = nil
	--self.TextNoTrends = nil
	--self.TextNotice = nil
	--self.TextNoticeTitle = nil
	--self.TextPrivilege = nil
	--self.TextSE = nil
	--self.TextTips01 = nil
	--self.TextTips02 = nil
	--self.TextTips03 = nil
	--self.TextTips04 = nil
	--self.TextTrends = nil
	--self.Text_1 = nil
	--self.TextleaderName = nil
	--self.AnimCreate = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInfoPageView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnEditInfo)
	self:AddSubView(self.BtnGradeInfo)
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ShowInfoPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInfoPageView:OnInit()
    LSTR = _G.LSTR
    UIViewMgr = _G.UIViewMgr
    UIViewID = _G.UIViewID
    ArmyMgr = require("Game/Army/ArmyMgr")
    ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
    ArmyInfoPageVM = ArmyMainVM:GetArmyInfoPageVM()
    if ArmyInfoPageVM and ArmyInfoPageVM.ArmyShowInfoVM then
        local ShowInfoVM = ArmyInfoPageVM.ArmyShowInfoVM
        self.ShowInfoPage:RefreshVM(ShowInfoVM)
    end
    --self.TableViewAdapterPrivilege = UIAdapterTableView.CreateAdapter(self, self.TableViewPrivilege)
	--self.TableViewAdapterPrivilege:SetOnClickedCallback(self.OnClickedSelectPrivilegeItem)
    self.TableViewAdapterSE = UIAdapterTableView.CreateAdapter(self, self.TableViewSE)
    self.TableViewAdapterTrends = UIAdapterTableView.CreateAdapter(self, self.TableViewTrends)
	--self.TableViewAdapterSE:SetOnClickedCallback(self.OnClickedSelectSEItem)
    self.Binders = {
        {"ArmyLevel", UIBinderSetText.New(self, self.TextGade01)},
        {"CaptainName", UIBinderSetText.New(self, self.TextleaderName)},
        {"MemberNum", UIBinderSetText.New(self, self.RichTextPeople)},
        {"GainExpWay", UIBinderSetText.New(self, self.TextTips04)},
        {"ExpText", UIBinderSetText.New(self, self.RichTextGrade)},
        {"MaxExpText", UIBinderSetText.New(self, self.TextTips02)},
        {"bEditNameEnable", UIBinderSetIsVisible.New(self, self.BtnEditInfo, false, true)},
        {"LogIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTrendsIcon)},
        {"BadgeData", UIBinderValueChangedCallback.New(self, nil, self.OnBadgeDataChange)},
        --{"NewsContent", UIBinderSetText.New(self, self.RichTextTrends)},
        {"bTopLogShow", UIBinderSetIsVisible.New(self, self.TextNoTrends, true)},
        --{"PrivilegeList", UIBinderUpdateBindableList.New(self, self.TableViewAdapterPrivilege)},
        {"SEList", UIBinderUpdateBindableList.New(self, self.TableViewAdapterSE)},
		{"ExpProgressValue", UIBinderSetPercent.New(self, self.ProgressBarGrade) },
        {"LeaderRoleID", UIBinderValueChangedCallback.New(self, nil, self.SetPlayerHeadSlot)},
        {"Notice", UIBinderSetText.New(self, self.TextNotice)},
        {"TrendList", UIBinderUpdateBindableList.New(self, self.TableViewAdapterTrends)},
        {"ArmyName", UIBinderSetText.New(self, self.TextArmyName)},
        {"ArmyShortName", UIBinderSetText.New(self, self.TextArmyName02)},
        {"GainNum", UIBinderSetText.New(self, self.RichTextCombatGains)},
        {"GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.OnGrandCompanyTypeChanged)},
    }
    self.BtnGradeInfo:SetCallback(self, self.ShowLevelTips)
    -- LSTR string:招募信息
    --self.BtnInfo:SetText(LSTR(910135))
end

function ArmyInfoPageView:OnBadgeDataChange(Value)
   
end

function ArmyInfoPageView:OnDestroy()
end

function ArmyInfoPageView:OnShow()
    ---固定文本设置
    -- LSTR string:部队长
    self.TextLeader:SetText(LSTR(910264))
    -- LSTR string:成员
    self.Text:SetText(LSTR(910128))
    -- LSTR string:等级
    self.TextGade:SetText(LSTR(910296))
    -- LSTR string:动态
    self.TextTrends:SetText(LSTR(910297))
    -- LSTR string:特效
    self.TextSE:SetText(LSTR(910173))
    -- LSTR string:权限
    self.TextPrivilege:SetText(LSTR(910165))
    -- LSTR string:招募信息
    --self.BtnInfo:SetText(LSTR(910135))
    -- LSTR string:部队经验获取规则
    self.TextTips01:SetText(LSTR(910364))
    -- LSTR string:经验获取途径
    self.TextTips03:SetText(LSTR(910365))
    -- LSTR string:暂无动态
    self.TextNoTrends:SetText(LSTR(910303))
    -- LSTR string:公告
    self.TextNoticeTitle:SetText(LSTR(910055))
    -- LSTR string:战绩
    self.Text_1:SetText(LSTR(910387))
    ---屏蔽掉不需要显示的UI
	UIUtil.SetIsVisible(self.PanelTips, false)
    if self.ArmyBadgeItem then
        UIUtil.SetIsVisible(self.ArmyBadgeItem, false)
    end
    if self.ImgFlag then
	    UIUtil.SetIsVisible(self.ImgFlag, false)
    end
    ArmyMgr:SendGroupStoreReqStoreBaseInfo()
    if ArmyInfoPageVM then
        local LeaderRoleID = ArmyInfoPageVM:GetLeaderID()
        -- local PlayerHeadSlot = self.PlayerHeadSlot
        -- _G.RoleInfoMgr:QueryRoleSimple(LeaderRoleID, function(_, RoleVM)
		-- 	if LeaderRoleID == RoleVM.RoleID then
		-- 		if PlayerHeadSlot and CommonUtil.IsObjectValid(PlayerHeadSlot) then
        --             PlayerHeadSlot:SetInfo(LeaderRoleID)
        --         end
		-- 	end
        -- end, nil, true)
        self.PlayerHeadSlot:SetInfo(LeaderRoleID)
        if ArmyInfoPageVM:GetIsOpenEditWin() then
            self:OnClickedEdit()
            ArmyInfoPageVM:SetIsOpenEditWin(false)
        end
    end

    --ArmyInfoPageVM:UpdataUsedBonusStates()

    -- LSTR string:编辑部队信息
    self.BtnEditInfo:SetText(LSTR(910206))
end

function ArmyInfoPageView:SetPlayerHeadSlot(LeaderRoleID)
    self.PlayerHeadSlot:SetInfo(LeaderRoleID)
end

function ArmyInfoPageView:OnHide()
end

function ArmyInfoPageView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnEditInfo, self.OnClickedEdit)
    UIUtil.AddOnClickedEvent(self, self.BtnTrends, self.OnClickedLookTrends)
    UIUtil.AddOnClickedEvent(self, self.BtnLeader, self.OnClickedLeader)
    UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickedClose)
    UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickedCopy)
    UIUtil.AddOnClickedEvent(self, self.BtnCurrencTips, self.OnClickedScoreIcon)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickedReport)
    --UIUtil.AddOnClickedEvent(self, self.BtnInfo, self.OnClickedUpdateRecruit)
end

function ArmyInfoPageView:OnRegisterGameEvent()
end

function ArmyInfoPageView:OnRegisterBinder()
    if nil == ArmyInfoPageVM then
        _G.FLOG_ERROR("ArmyInfoPageView:OnRegisterBinder ArmyInfoPageVM is nil")
        return
    end
    ----部队信息界面不显示权限了，先屏蔽
    --- 有报错，绑定的时候控件为空
    -- if nil == self.TableViewAdapterPrivilege.Widget or nil == self.TableViewAdapterSE.Widget then
    --     _G.FLOG_ERROR("ArmyInfoPageView:OnRegisterBinder TableViewAdapterPrivilege.Widget or TableViewAdapterSE.Widget is nil")
    --     return
    -- end
    self:RegisterBinders(ArmyInfoPageVM, self.Binders)
    -- local ShowInfoVM = ArmyInfoPageVM.ArmyShowInfoVM
	-- if nil == ShowInfoVM then
	-- 	return
	-- end
    --self.ShowInfoPage:RefreshVM(ShowInfoVM)
end

--- 修改部队信息
function ArmyInfoPageView:OnClickedEdit()
    local Callback = function(NewName, NewShortName, NewNotice)
        local Name = nil
        local ShortName = nil
        local Notice = nil
        --- 部队名称和简称检查放在编辑界面处理
        if NewName ~= ArmyInfoPageVM.ArmyName then
            Name = NewName
        end
        if NewShortName ~= ArmyInfoPageVM.ArmyShortName then
            ShortName = NewShortName
        end
        if NewNotice ~= ArmyInfoPageVM.Notice then
            Notice = NewNotice
        end
        ArmyMgr:SendArmyEditInfoMsg(Name, ShortName, Notice)
        --UIViewMgr:HideView(UIViewID.ArmyEditInfoPanel)
    end
    UIViewMgr:ShowView(UIViewID.ArmyEditInfoPanel,
    {
        ArmyName = ArmyInfoPageVM.ArmyName,
        ShortName = ArmyInfoPageVM.ArmyShortName,
        NameEditedTime = ArmyInfoPageVM.NameEditedTime, --- 时间需要判断
        AliasEditedTime = ArmyInfoPageVM.AliasEditedTime,
        EmblemEditedTime = ArmyInfoPageVM.EmblemEditedTime,
        BadgeData = ArmyInfoPageVM.BadgeData,
        Notice = ArmyInfoPageVM.Notice,
        GrandCompanyType = ArmyInfoPageVM.GrandCompanyType,
        Callback = Callback
    })
end

--- 复制部队ID
function ArmyInfoPageView:OnClickedCopy()
    if nil == ArmyInfoPageVM then
        _G.FLOG_ERROR("ArmyInfoPageView:OnRegisterBinder ArmyInfoPageVM is nil")
        return
    end
    if ArmyInfoPageVM.ArmyID then
        _G.CommonUtil.ClipboardCopy(ArmyInfoPageVM.ArmyID)
        -- LSTR string:拷贝成功
        _G.MsgTipsUtil.ShowTips(LSTR(910142))
    else
        _G.FLOG_ERROR(" ArmyInfoPageView:OnClickedCopy() ArmyInfoPageVM.ArmyID is nil")
        local ArmyID = ArmyMgr:GetArmyID()
        if ArmyID then
            _G.CommonUtil.ClipboardCopy(ArmyID)
            -- LSTR string:拷贝成功
            _G.MsgTipsUtil.ShowTips(LSTR(910142))
        else
            _G.FLOG_ERROR("ArmyMgr:GetArmyID() is nil")
        end
    end
end

-- --- 修改公告
-- function ArmyInfoPageView:OnClickedUpdateNotice()
--     local MaxLimit = GroupGlobalCfg:GetValueByType(GloalCfgType.EditNoticeMaxLimit)
--     local Callback = function(NewNotice)
--         if NewNotice ~= ArmyInfoPageVM.Notice then
--             local MinLimit = GroupGlobalCfg:GetValueByType(GloalCfgType.EditNoticeMinLimit)
--             local Len = UTF8Util.Len(NewNotice)
--             if Len < MinLimit then
-- LSTR string:公告内容不能少于%d个字
--                 local Tips = string.format(LSTR(910056), MinLimit)
--                 MsgTipsUtil.ShowTips(Tips)
--             else
--                 ArmyMgr:SendArmyEditNoticeMsg(NewNotice)
--             end
--         end
--     end
--     UIViewMgr:ShowView(
--         UIViewID.ArmyEditNoticPanel,
--         {
-- LSTR string:请输入公告
--             HintText = LSTR(910227),
--             Text = ArmyInfoPageVM.Notice,
--             MaxNum = MaxLimit,
--             Callback = Callback
--         }
--     )
-- end

--- 修改招募信息
function ArmyInfoPageView:OnClickedUpdateRecruit()
    local IsAllowEditor = ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.GROUP_PERMISSION_TYPE_EditNotice)
    local IsDelRecruitRedDot = not ArmyMgr:GetIsRecruitPanelHaveOpened()
    if IsDelRecruitRedDot then
        RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyRecruit)
        ArmyMgr:SetIsRecruitPanelHaveOpened(true)
    end
    UIViewMgr:ShowView(
        UIViewID.ArmyEditRecruitPanel,
        {
            -- LSTR string:请输入招募标语
            HintText = LSTR(910228),
            Callback = function(RecruitSlogan, RecruitStatus)
                ArmyMgr:SendArmyEditRecruitInfoMsg(RecruitSlogan, RecruitStatus)
            end,
            IsHavePermission = IsAllowEditor,
        }
    )
end

--- 查看部队动态信息
function ArmyInfoPageView:OnClickedLookTrends()
    UIViewMgr:ShowView(UIViewID.ArmyInfoTrendsPanel)
end

--- 进入部队频道
function ArmyInfoPageView:OnClickedChannel()
    UIViewMgr:HideView(UIViewID.ArmyPanel)
    UIViewMgr:HideView(UIViewID.Main2ndPanel)
    _G.ChatMgr:ShowChatView(ChatChannel.Army)
end

--- 复制部队ID
function ArmyInfoPageView:OnClickedCopyArmyNumber()
    CommonUtil.ClipboardCopy(ArmyInfoPageVM.ArmyID)
    -- 弹出拷贝成功的Tips
    -- LSTR string:拷贝成功
    MsgTipsUtil.ShowTips(LSTR(910142))
end

--- 部队战绩说明
function ArmyInfoPageView:OnClickedGain()
    local Position = _G.UE.FVector2D(0, 0)
    ItemTipsUtil.CurrencyTips(ArmyDefine.GroupScroeID, nil, self.BtnGain, Position)
end

--- 部队长个人信息
function ArmyInfoPageView:OnClickedLeader()
    if nil == ArmyInfoPageVM then
        _G.FLOG_ERROR("ArmyInfoPageView:OnRegisterBinder ArmyInfoPageVM is nil")
        return
    end
    PersonInfoMgr:ShowPersonalSimpleInfoView(ArmyInfoPageVM:GetLeaderID())
end

function ArmyInfoPageView:OnClickedClose()
    self:HideLevelTips()
end

function ArmyInfoPageView:OnClickedScoreIcon()
    local ScoreID = SCORE_TYPE.SCORE_TYPE_GROUP_PERFORMANCE
    ItemTipsUtil.CurrencyTips(ScoreID, nil, self.ImgCombatGainsIcon, nil, nil, true)
end


--- 部队等级经验说明
function ArmyInfoPageView:ShowLevelTips()
	UIUtil.SetIsVisible(self.PanelTips, true)

end

function ArmyInfoPageView:HideLevelTips()
	UIUtil.SetIsVisible(self.PanelTips, false) 
end

----部队信息界面不显示权限了，先屏蔽
---点击公会权限Item
-- function ArmyInfoPageView:OnClickedSelectPrivilegeItem(Index, ItemData, ItemView)
--     local Params = {
--         Title = ItemData.Permission,
--         Content = ItemData.Describe,
--     }
--     local IconView = ItemView.ImgIcon or ItemView
-- 	TipsUtil.ShowSimpleTipsView(Params, IconView, _G.UE.FVector2D(0, -5), _G.UE.FVector2D(0, 0), false)
-- end

-- 点击特效Item,Item有按钮遮挡点击，在item处理逻辑
-- function ArmyInfoPageView:OnClickedSelectSEItem(Index, ItemData, ItemView)
--     local Params = {
-- 		Title = ItemData.Name,
-- LSTR string:效果:
-- 		Content = string.format("%s %s \n %s %s",LSTR(910146), ItemData.Desc, LSTR(910075), ItemData.TiemStr)
--     }
-- 	TipsUtil.ShowSimpleTipsView(Params, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(1, 0), false)
-- end

function ArmyInfoPageView:PlayAnimShow()
    self:PlayAnimation(self.AnimShow)
end

function ArmyInfoPageView:PlayAnimCreate()
    self:PlayAnimation(self.AnimCreate)
end

function ArmyInfoPageView:StopAnimShow()
    if self:IsAnimationPlaying(self.AnimShow) then
        self:StopAnimation(self.AnimShow)
    end
end

function ArmyInfoPageView:OnClickedReport()
    local Params = {
        ReporteeRoleID = ArmyInfoPageVM:GetLeaderID(),
        GroupID = ArmyInfoPageVM:GetArmyID(),
        GroupName = ArmyInfoPageVM:GetName(),
        ReportContentList = {
            Abbreviation = ArmyInfoPageVM:GetShortName(),
            Announcement = ArmyInfoPageVM:GetNotice(), 
        },
    }
    --- Params.ReportContentList  = { "Abbreviation" = "部队简称文本", "Announcement" = "部队公告文本" }
	_G.ReportMgr:OpenViewByArmyInfo(Params)
end

function ArmyInfoPageView:OnGrandCompanyTypeChanged(GrandCompanyType)
    if GrandCompanyType then
        ---设置文本颜色		
        local Colors
        if GrandCompanyType == ArmyDefine.GrandCompanyType.ShuangShe then
            Colors = ArmyFlagTextColors.Dark
        else
            Colors = ArmyFlagTextColors.Nomal
        end
        local LeaderNameColor =Colors.LeaderNameColor
        local ContentColor = Colors.ContentColor
        UIUtil.SetColorAndOpacityHex(self.TextArmyName, LeaderNameColor)-- 部队名字文本颜色
        UIUtil.SetColorAndOpacityHex(self.TextArmyName02, ContentColor)-- 部队简称文本颜色
    end
end


function ArmyInfoPageView:IsForceGC()
	return true
end

return ArmyInfoPageView
