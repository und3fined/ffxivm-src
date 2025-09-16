---
--- Author: daniel
--- DateTime: 2023-03-18 16:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UTF8Util = require("Utils/UTF8Util")
local LSTR = _G.LSTR
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyEditTextType = ArmyDefine.ArmyEditTextType
local UnitedArmyTabs = ArmyDefine.UnitedArmyTabs
local DayToSeconds = ArmyDefine.Day
local MinToSeconds = ArmyDefine.Minutes
local HuorToSeconds = ArmyDefine.Hour
local MonthToSeconds = ArmyDefine.Month
local ArmyBadgeType = ArmyDefine.ArmyBadgeType

local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyMgr = require("Game/Army/ArmyMgr")
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local GroupEmblemIconCfg = require("TableCfg/GroupEmblemIconCfg")
local GroupEmblemBackgroundCfg = require("TableCfg/GroupEmblemBackgroundCfg")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local EventID = require("Define/EventID")
local LocalizationUtil = require("Utils/LocalizationUtil")

local MsgBoxUtil = _G.MsgBoxUtil

---@class ArmyInfoEditorWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadgeItem ArmyBadgeItemView
---@field BG Comm2FrameLView
---@field BtnRandom UFButton
---@field BtnReset UFButton
---@field BtnSave CommBtnLView
---@field BtnSave02 CommBtnLView
---@field ImgArmyBg UFImage
---@field InputBoxName CommInputBoxView
---@field InputBoxTime CommInputBoxView
---@field MulitiLineInputBox CommMultilineInputBoxView
---@field PanelEditBadge UFCanvasPanel
---@field PanelEditName UFCanvasPanel
---@field TableViewSlot UTableView
---@field TableViewTabs CommMenuView
---@field TexTmodify UFTextBlock
---@field TextName UFTextBlock
---@field TextName02 UFTextBlock
---@field TextNoName UFTextBlock
---@field TextNotice UFTextBlock
---@field TextNoticeTips UFTextBlock
---@field TextTime UFTextBlock
---@field TextTipsName3 UFTextBlock
---@field ToggleGroupTabs CommHorTabsView
---@field AnimChangeBadgeTab UWidgetAnimation
---@field AnimChangeTab UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInfoEditorWinView = LuaClass(UIView, true)

--- 部队名字最小长度
local Name_Min_Limit = nil
--- 部队名字最大长度
local Name_Max_Limit = nil
--- 简称最小长度
local ShortName_Min_Limit = nil
--- 简称最大长度
local ShortName_Max_Limit = nil
---公告最小长度
local Notice_Min_Limit = nil
---公告最大长度
local Notice_Max_Limit = nil

local bSelectedBadge = true --- 是否选中了徽章
local bNormArmyName = true --- 是否名称合规
local bNormShortName = true --- 是否简称合规
local bNormNotice = true --- 是否公告合规

local UnitedIcon = nil

local TabKey = 
{
    InfoEdit = 1,
    Badge = 2,
}

local function GetTimeFormatStr(Time)
    local TimeStr = LocalizationUtil.GetCountdownTimeForLongTime(Time)
    -- LSTR string:后可编辑
    local Str = LSTR(910088)
    return string.format("%s%s", TimeStr, Str)
    -- if Time >= ArmyDefine.Day and Time < MonthToSeconds then -- >1天<30天
    --     local Day = math.floor(Time / DayToSeconds)
    -- LSTR string:天后可编辑
    --     local Str = LSTR(910094)
    --     return string.format("%d%s", Day, Str)
    -- else
    --     local Hour = math.floor(Time / ArmyDefine.Hour)
    -- LSTR string:分后可编辑
    --     local Str = LSTR(910058)
    --     if Hour >= ArmyDefine.One then
    -- LSTR string:时
    --         local HourStr = LSTR(910152)
    --         local Minute = math.floor(Time % HuorToSeconds / MinToSeconds)
    --         return string.format("%d%s%d%s", Hour, HourStr, Minute, Str)
    --     else
    --         local Minute = math.floor(Time / MinToSeconds)
    --         return string.format("%d%s", Minute, Str)
    --     end
    -- end
end




function ArmyInfoEditorWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadgeItem = nil
	--self.BG = nil
	--self.BtnRandom = nil
	--self.BtnReset = nil
	--self.BtnSave = nil
	--self.BtnSave02 = nil
	--self.ImgArmyBg = nil
	--self.InputBoxName = nil
	--self.InputBoxTime = nil
	--self.MulitiLineInputBox = nil
	--self.PanelEditBadge = nil
	--self.PanelEditName = nil
	--self.TableViewSlot = nil
	--self.TableViewTabs = nil
	--self.TexTmodify = nil
	--self.TextName = nil
	--self.TextName02 = nil
	--self.TextNoName = nil
	--self.TextNotice = nil
	--self.TextNoticeTips = nil
	--self.TextTime = nil
	--self.TextTipsName3 = nil
	--self.ToggleGroupTabs = nil
	--self.AnimChangeBadgeTab = nil
	--self.AnimChangeTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInfoEditorWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadgeItem)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.BtnSave02)
	self:AddSubView(self.InputBoxName)
	self:AddSubView(self.InputBoxTime)
	self:AddSubView(self.MulitiLineInputBox)
	self:AddSubView(self.TableViewTabs)
	self:AddSubView(self.ToggleGroupTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end



--- 选中
---@param Index number @下标 从1开始
function ArmyInfoEditorWinView:OnClickedSelectItem(Index, ItemData, ItemView)
	if self.CurArmyBadgeType == ArmyBadgeType.Implied then
		--寓意物有筛选，不能直接用下标
		self.CurSelectedImpliedID = ItemData.ID
        self.CurSelectedImpliedIndex = Index
		self.ArmyBadgeItem:SetSymbol(self.CurSelectedImpliedID)
	elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
		self.CurSelectedShieldIndex = Index
		self.ArmyBadgeItem:SetShield(self.CurSelectedShieldIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
		self.CurSelectedBgIndex = Index
		self.ArmyBadgeItem:SetBackground(self.CurSelectedBgIndex)
	end
	self:CheckedEdit()
end

--- 选中变更事件，用于随机队徽时滑动处理
---@param Index number @下标 从1开始
function ArmyInfoEditorWinView:OnSelectChangedCallback(Index, ItemData, ItemView, IsByClick)
	if not IsByClick then
		self.TabsViewAdapter:ScrollIndexIntoView(Index)
	end
end

function ArmyInfoEditorWinView:CheckedEdit()
    local EmblemNameEditCD =  self.EmblemEditSpace * ArmyDefine.Day
	local Params = self.Params
    if nil == Params then
		return
	end
    local CurrentTime = _G.TimeUtil.GetServerTime() --当前时间
    self.EditEmblemTime = CurrentTime - Params.EmblemEditedTime - EmblemNameEditCD
    self.IsEditEmblem = self.EditEmblemTime >= 0
    if not self.IsEditEmblem then
        UIUtil.SetIsVisible(self.TexTmodify, true)
        self.TexTmodify:SetText(GetTimeFormatStr(math.abs(self.EditEmblemTime)))
        self.BtnSave02:SetIsEnabled(false, true)
        return
    else
        UIUtil.SetIsVisible(self.TexTmodify, false)
    end
    if Params.BadgeData.TotemID ~= self.CurSelectedImpliedID or
		Params.BadgeData.IconID ~= self.CurSelectedShieldIndex or
		Params.BadgeData.BackgroundID ~= self.CurSelectedBgIndex
	then
		if self.CurSelectedImpliedID and self.CurSelectedImpliedID > 0 and self.CurSelectedShieldIndex > 0 and self.CurSelectedBgIndex > 0 then
			self.BtnSave02:SetIsEnabled(true, true)
		else
			self.BtnSave02:SetIsEnabled(false, true)
		end
		self.BtnReset:SetIsEnabled(true)
	else
		self.BtnSave02:SetIsEnabled(false, true)
		self.BtnReset:SetIsEnabled(false)
	end
end

function ArmyInfoEditorWinView:OnSetBadgeCD(BadgeData, EmblemEditedTime)
    local EmblemNameEditCD =  self.EmblemEditSpace * ArmyDefine.Day
    local CurrentTime = _G.TimeUtil.GetServerTime() --当前时间
    self.Params.BadgeData = BadgeData
    self.OldSelectedImpliedID = BadgeData.TotemID
    self.OldSelectedShieldIndex = BadgeData.IconID
    self.OldSelectedBgIndex = BadgeData.BackgroundID
    self.BtnReset:SetIsEnabled(false)
    if EmblemEditedTime then
        self.Params.EmblemEditedTime = EmblemEditedTime
        self.EditEmblemTime = CurrentTime - EmblemEditedTime - EmblemNameEditCD
        self.IsEditEmblem = self.EditEmblemTime >= 0
        if not self.IsEditEmblem then
            UIUtil.SetIsVisible(self.TexTmodify, true)
            self.TexTmodify:SetText(GetTimeFormatStr(math.abs(self.EditEmblemTime)))
            self.BtnSave02:SetIsEnabled(false, true)
        else
            UIUtil.SetIsVisible(self.TexTmodify, false)
        end
    else
        ArmyMgr:SendGroupQueryCategory()
    end
    self:CheckedEdit()
end

function ArmyInfoEditorWinView:OnSetArmyNameCD(Name, NameEditedTime)
    local NameEditCD = self.NameEditSpace * ArmyDefine.Day
    self.Params.ArmyName = Name
    self.InputBoxName:SetText(Name)
    if NameEditedTime then
        self.Params.NameEditedTime = NameEditedTime
        local CurrentTime = _G.TimeUtil.GetServerTime() --当前时间
        local EditNameTime = CurrentTime - NameEditedTime - NameEditCD
        local IsEditName = EditNameTime >= 0
        local Color = "B71823FF"
        if not IsEditName then
            UIUtil.TextBlockSetColorAndOpacityHex( self.TextTime, Color)
            self.TextTime:SetText(GetTimeFormatStr(math.abs(EditNameTime)))
            self.BtnSave02:SetIsEnabled(false, true)
            self.InputBoxName:SetIsEnabled(false)
        end
    else
        ArmyMgr:SendGroupQueryCategory()
    end
    self:CheckedSaveBtnState()
    --self.InputBoxName:SetIsEnabled(false)
    self.InputBoxName:SetIsHideNumber(true)
end

function ArmyInfoEditorWinView:OnSetAliasNameCD(Alias, AliasEditedTime)
    ---按策划要求，简称不实时更新，保持和其他UI一致
    if AliasEditedTime == nil then
        return
    end
    local ShortNameEditCD = self.ShortNameEditSpace* ArmyDefine.Day
    self.Params.ShortName = Alias
    self.InputBoxTime:SetText(Alias)
    if AliasEditedTime then 
        self.Params.AliasEditedTime = AliasEditedTime
        local CurrentTime = _G.TimeUtil.GetServerTime() --当前时间
        local EditAliasTime = CurrentTime - AliasEditedTime - ShortNameEditCD
        local IsEditAlias = EditAliasTime >= 0
        local Color = "B71823FF"
        if not IsEditAlias then
            UIUtil.TextBlockSetColorAndOpacityHex( self.TextTipsName3, Color)
            self.TextTipsName3:SetText(GetTimeFormatStr(math.abs(EditAliasTime)))
            self.BtnSave02:SetIsEnabled(false, true)
            self.InputBoxTime:SetIsEnabled(false)
        end
    else
        ArmyMgr:SendGroupQueryCategory()
    end
    self:CheckedSaveBtnState()
    --self.InputBoxTime:SetIsEnabled(false)
    self.InputBoxTime:SetIsHideNumber(true)
end

function ArmyInfoEditorWinView:OnAllCDChange(EditedTimes)
    self:SetAllInfoCD(EditedTimes)
end

--- 设置所有信息编辑CD
function ArmyInfoEditorWinView:SetAllInfoCD(EditedTimes)
    if not self.NameEditSpace or not self.ShortNameEditSpace or not self.EmblemEditSpace then
        return
    end
    local NameEditCD = self.NameEditSpace * ArmyDefine.Day
    local ShortNameEditCD = self.ShortNameEditSpace* ArmyDefine.Day
    local EmblemNameEditCD =  self.EmblemEditSpace * ArmyDefine.Day
    local CurrentTime = _G.TimeUtil.GetServerTime() --当前时间
    local Color = "B71823FF"
    --- 设置名字CD
    local EditNameTime = CurrentTime - EditedTimes.NameTime - NameEditCD
    local IsEditName = EditNameTime >= 0
    if not IsEditName then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextTime, Color)
        self.TextTime:SetText(GetTimeFormatStr(math.abs(EditNameTime)))
        self.BtnSave:SetIsEnabled(false, true)
    end
    ---设置简称CD
    local EditAliasTime = CurrentTime - EditedTimes.AliasTime - ShortNameEditCD
    local IsEditAlias = EditAliasTime >= 0
    if not IsEditAlias then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextTipsName3, Color)
        self.TextTipsName3:SetText(GetTimeFormatStr(math.abs(EditAliasTime)))
        self.BtnSave:SetIsEnabled(false,true)
    end
    --- 设置队徽CD
    self.EditEmblemTime = CurrentTime - EditedTimes.EmblemTime - EmblemNameEditCD
    self.IsEditEmblem = self.EditEmblemTime >= 0
    if not self.IsEditEmblem then
        UIUtil.SetIsVisible(self.TexTmodify, true)
        self.TexTmodify:SetText(GetTimeFormatStr(math.abs(self.EditEmblemTime)))
        self.BtnSave02:SetIsEnabled(false, true)
    else
        UIUtil.SetIsVisible(self.TexTmodify, false)
    end
    self:CheckedSaveBtnState()
    self:CheckedEdit()
end

function ArmyInfoEditorWinView:OnSetNoticeChange(Notice)
    self.Params.Notice = Notice
    self.MulitiLineInputBox:SetText(Notice)
    self.IsInput = false
    self:CheckedSaveBtnState()
end

--- 显示队徽界面
function ArmyInfoEditorWinView:OnBadgeShow()
	local Params = self.Params
	if nil == Params then
		return
	end
    ---保证第一次选中
    self.CurArmyBadgeType = -1
	self.CurGrandCompanyType = self.Params.GrandCompanyType
	self.CurSelectedImpliedIndex = ArmyDefine.Zero
	self.CurSelectedShieldIndex = ArmyDefine.Zero
	self.CurSelectedBgIndex = ArmyDefine.Zero
	self.CurSelectedImpliedID = ArmyDefine.Zero
	if Params.BadgeData then
		self.CurSelectedImpliedID = Params.BadgeData.TotemID
		self.CurSelectedShieldIndex = Params.BadgeData.IconID
		self.CurSelectedBgIndex = Params.BadgeData.BackgroundID
		self.OldSelectedImpliedID = Params.BadgeData.TotemID
		self.OldSelectedShieldIndex = Params.BadgeData.IconID
		self.OldSelectedBgIndex = Params.BadgeData.BackgroundID
	end
	self.ArmyBadgeItem:SetBadgeData(Params.BadgeData)
	--self.CommitedCallback = Params.CommitedCallback
	self.BtnSave02:SetIsEnabled(false, true)
	self.BtnReset:SetIsEnabled(false)
    self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
	self.ToggleGroupTabs:SetSelectedIndex(1)
    self:OnGroupTabsSelectionChanged(1)
    local Cfg = GrandCompanyCfg:FindCfgByKey(self.CurGrandCompanyType)
    local UnitedIcon = Cfg.BgIcon
	UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyBg, UnitedIcon)
	-- if self.CurSelectedImpliedID > 0 then
	-- 	self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
	-- 	if self.CurSelectedImpliedIndex then
	-- 		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedImpliedIndex)
	-- 		self.TabsViewAdapter:ScrollToIndex(self.CurSelectedImpliedIndex)
	-- 	else
	-- 		self.TabsViewAdapter:CancelSelected()
	-- 	end
	-- else
	-- 	self.TabsViewAdapter:CancelSelected()
	-- end
end


--- Tab切换
---@param Index number @下标 从0开始
function ArmyInfoEditorWinView:OnGroupTabsSelectionChanged(Index, ItemData, ItemView)
	local CurIndex = Index - 1
    self:PlayAnimation(self.AnimChangeBadgeTab)
	--self:PlayAnimation(self.AnimUpdateSlot)
	if CurIndex ~= self.CurArmyBadgeType then
		self.CurArmyBadgeType = CurIndex
		local SelectedIndex
		local Values
		if self.CurArmyBadgeType == ArmyBadgeType.Implied then
			local TotemCfg = GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
			Values = {}
			for _, Totem in ipairs(TotemCfg) do
				if Totem.CompanyIDs then
					for _, CompanyID in ipairs(Totem.CompanyIDs) do
						if self.CurGrandCompanyType and CompanyID == self.CurGrandCompanyType then
							table.insert(Values, Totem)
							break
						end
					end
				end
			end
			SelectedIndex = self.CurSelectedImpliedIndex
		elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
			Values = GroupEmblemIconCfg:GetAllEmblemIconCfg()
			SelectedIndex = self.CurSelectedShieldIndex
		elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
			Values = GroupEmblemBackgroundCfg:GetAllEmblemBgCfg()
			SelectedIndex = self.CurSelectedBgIndex
		end
		self.TabsViewAdapter:UpdateAll(Values)
		if SelectedIndex and SelectedIndex > ArmyDefine.Zero then
			self.TabsViewAdapter:SetSelectedIndex(SelectedIndex)
			self.TabsViewAdapter:ScrollIndexIntoView(SelectedIndex)
		else
			self.TabsViewAdapter:ClearSelectedItem()
		end
	end
end

function ArmyInfoEditorWinView:SetNameText(ErrorTip, NumberTip, EditableText, Max, Text)
    local Length = UTF8Util.Len(Text)
    if Length > Max then
        -- EditableText:SetText(UTF8Util.Sub(Text, 0, Max))
        Length = Max
    end
    NumberTip:SetText(string.format("%d/%d", Length, Max))
end

--- 检测是否是纯符号
---@param Text string
function ArmyInfoEditorWinView:CheckIsAllSign(Text)
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
function ArmyInfoEditorWinView:CheckIsNumStr(Text)
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

function ArmyInfoEditorWinView:SetErrorTip(TextType)
    if TextType == ArmyDefine.ArmyEditTextType.ArmyName then
        bNormArmyName = false
    elseif TextType == ArmyDefine.ArmyEditTextType.ShortName then
        bNormShortName = false
    elseif TextType == ArmyDefine.ArmyEditTextType.RecruitSlogan then
        bNormNotice = false
    end
    self:CheckedSaveBtnState()
end

--- 简称字符是否符合规则
function ArmyInfoEditorWinView:CheckNameRules(TextType, Min, Max, Text)
    local Length = UTF8Util.Len(Text)
    ---最大由输入框拦截，最小点击保存时拦截
    if Length < Min then
        self:CheckedSaveBtnState()
        self.IsWaitCheck = false
        return
    end
    if string.match(Text, "^%s+") or string.match(Text, "%s+$") then
        ---开头结尾使用空格
        self:SetErrorTip(TextType)
        self.IsWaitCheck = false
        return
    end
    if string.match(Text, "%s%s") then
        ---连续使用空格与下划线
        self:SetErrorTip(TextType)
        self.IsWaitCheck = false
        return
    end
    if string.match(Text, "_%_") then
        ---连续使用空格与下划线
        self:SetErrorTip(TextType)
        self.IsWaitCheck = false
        return
    end
    if TextType == ArmyEditTextType.ArmyName or TextType == ArmyEditTextType.ShortName then
        if not string.match(Text, "^[%w%s\228-\233\128-\191_:;!?&%-]+$") then
            --名称、简称可以使用中文、字母、空格、下划线,:;!?&-
            self:SetErrorTip(TextType)
            -- if TextType == ArmyEditTextType.ArmyName then
            -- LSTR string:名称可以使用中文、字母、空格、下划线,:;!?&-
            --     self:SetErrorTip(TextType, LSTR(910087))
            -- elseif TextType == ArmyEditTextType.ShortName then
            -- LSTR string:简称可以使用中文、字母、空格、下划线,:;!?&-
            --     self:SetErrorTip(TextType, LSTR(910198))
            -- end
            self.IsWaitCheck = false
            return
        end
        local bAllSign = self:CheckIsAllSign(Text)
        local bNumStr = self:CheckIsNumStr(Text)
        if bAllSign then
            --使用纯符号作为名称或简称
            self:SetErrorTip(TextType)
            self.IsWaitCheck = false
            return
        end
        if bNumStr then
            --使用数字作为名称或简称
            self:SetErrorTip(TextType)
            self.IsWaitCheck = false
            return
        end
    end
    ---查询文本是否合法（敏感词）
	ArmyMgr:CheckSensitiveText(Text, function( IsLegal )
        self.IsWaitCheck = false
		if IsLegal then
            if TextType == ArmyDefine.ArmyEditTextType.ArmyName then
                --UIUtil.SetIsVisible(self.TextTipsName1, false)
                bNormArmyName = true
            elseif TextType == ArmyDefine.ArmyEditTextType.ShortName then
                --UIUtil.SetIsVisible(self.TextTipsTime1, false)
                bNormShortName = true
            elseif TextType == ArmyDefine.ArmyEditTextType.Notice then
                bNormNotice = true
            end
            self:CheckedSaveBtnState()
        else
            --输入的内容包含敏感词汇
            self:SetErrorTip(TextType)
            return
        end
    end)
end

function ArmyInfoEditorWinView:CheckedCreateInfoError(IsShowTips)
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
    local RecruitSloganStr
    if not bNormNotice then
        -- LSTR string:部队公告
        RecruitSloganStr = LSTR(910250)
        table.insert(StrList, RecruitSloganStr)
    end
    
    if #StrList == 0 then
        return false
    else
        if #StrList == 1 then
            -- LSTR string:%s不可使用，请重新输入
            TipsStr = string.format(LSTR(910014), StrList[1])
        elseif #StrList == 2 then
            -- LSTR string:%s、%s不可使用，请重新输入
            TipsStr = string.format(LSTR(910009), StrList[1], StrList[2])
        elseif #StrList == 3 then
            -- LSTR string:%s、%s、%s不可使用，请重新输入
            TipsStr = string.format(LSTR(910007),StrList[1], StrList[2],StrList[3])
        end
        MsgTipsUtil.ShowErrorTips(TipsStr)
        return true
    end

end

function ArmyInfoEditorWinView:CheckedCreateInfoEmpty()
    local TipsStr = ""
    local NameStr = self.InputBoxName:GetText()
    local StrList = {}
    if string.isnilorempty(NameStr) then
        -- LSTR string:部队名字
        NameStr = LSTR(910251)
        table.insert(StrList, NameStr)
    end
    local ShortNameStr = self.InputBoxTime:GetText()
    if string.isnilorempty(ShortNameStr) then
        -- LSTR string:部队简称
        ShortNameStr = LSTR(910262)
        table.insert(StrList, ShortNameStr)
    end
    
    if #StrList == 0 then
        UIUtil.SetIsVisible(self.TextNoName, false)
        return false
    else
        if #StrList == 1 then
            -- LSTR string:%s未填写！
            TipsStr = string.format(LSTR(910018), StrList[1])
        elseif #StrList == 2 then
            -- LSTR string:%s、%s未填写！
            TipsStr = string.format(LSTR(910010), StrList[1], StrList[2])
        end
        --MsgTipsUtil.ShowTips(TipsStr)
        UIUtil.SetIsVisible(self.TextNoName, true)
        self.TextNoName:SetText(TipsStr)
        return true
    end

end

function ArmyInfoEditorWinView:CheckedSaveBtnState()
    if self.IsInput then
        self.BtnSave:SetIsEnabled(false, true)
        return
    end
    if  not self:CheckedCreateInfoEmpty() and not self:CheckedCreateInfoError() then
        --local bBadgeChanged = self:IsBadgeChanged()
        if self.Params.ArmyName ~= self.InputBoxName:GetText() or
            self.Params.ShortName ~= self.InputBoxTime:GetText() or
            self.Params.Notice ~= self.MulitiLineInputBox:GetText()
        then
            self.BtnSave:SetIsEnabled(true, true)
        else
            self.BtnSave:SetIsEnabled(false, true)
        end
    else
        self.BtnSave:SetIsEnabled(false, true)
    end
end

function ArmyInfoEditorWinView:CheckedBadgeSaveBtnState()
    local bBadgeChanged = self:IsBadgeChanged()
    if bBadgeChanged then
        self.BtnSave02:SetIsEnabled(true,true)
    else
        self.BtnSave02:SetIsEnabled(false, true)
    end
end

function ArmyInfoEditorWinView:OnInit()
    Name_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMinLimit)
    Name_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.NameMaxLimit)
    ShortName_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMinLimit)
    ShortName_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.ShortNameMaxLimit)
    Notice_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.EditNoticeMinLimit)
    Notice_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.EditNoticeMaxLimit)
    ---名字修改CD
    self.NameEditSpace = GroupGlobalCfg:GetValueByType(GlobalCfgType.EditNameTimeInterval)
    --- 简称修改CD
    self.ShortNameEditSpace = GroupGlobalCfg:GetValueByType(GlobalCfgType.EditShortNameTimeInterval)
    --- 队徽修改CD
    self.EmblemEditSpace = GroupGlobalCfg:GetValueByType(GlobalCfgType.EditEmblemTimeInterval) 
    local NameEditSpaceStr = self.NameEditSpace > 1 and self.NameEditSpace or ""
    -- LSTR string:每%s天(地球时间)可修改一次
    self.TextTime:SetText(string.format(LSTR(910169), NameEditSpaceStr))
    local ShortNameEditSpaceStr = self.ShortNameEditSpace > 1 and self.ShortNameEditSpace or ""
    -- LSTR string:每%s天(地球时间)可修改一次
    self.TextTipsName3:SetText(string.format(LSTR(910169), ShortNameEditSpaceStr))
    local Color = "828282FF"
    UIUtil.TextBlockSetColorAndOpacityHex( self.TextTime, Color)
    UIUtil.TextBlockSetColorAndOpacityHex( self.TextTipsName3, Color)
    ---公告无CD
    self.InputBoxName:SetCallback(self, nil, self.OnTextArmyNameCommitted)
    self.InputBoxTime:SetCallback(self, nil, self.OnTextArmyShortNameCommitted)
    self.MulitiLineInputBox:SetCallback(self, self.OnTextFocusReceived, self.OnTextArmyNoticeNameCommitted)
    ---队徽相关
    self.CurArmyBadgeType = -1
	self.CurSelectedImpliedIndex = 0
	self.CurSelectedShieldIndex = 0
    self.CurSelectedImpliedID = 0
	self.CurSelectedBgIndex = nil
	self.OldSelectedImpliedID = nil
	self.OldSelectedShieldIndex = nil
	self.OldSelectedBgIndex = nil
	self.CommitedCallback = nil
	self.CurGrandCompanyType = nil
    self.IsEditEmblem = true
    self.EditEmblemTime = 0
	-- LSTR string:撤销修改
	---self.BtnReset:SetText(LSTR(910145))
	self.TabsViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.TabsViewAdapter:SetOnClickedCallback(self.OnClickedSelectItem)
	self.TabsViewAdapter:SetOnSelectChangedCallback(self.OnSelectChangedCallback)
end

function ArmyInfoEditorWinView:OnDestroy()
end

function ArmyInfoEditorWinView:OnShow()
    ---固定文本处理
    -- LSTR string:编辑部队信息
    self.BG:SetTitleText(LSTR(910292))
    -- LSTR string:部队名字
    self.TextName:SetText(LSTR(910284))
    -- LSTR string:部队简称
    self.TextName02:SetText(LSTR(910285))
    -- LSTR string:部队公告
    self.TextNotice:SetText(LSTR(910290))
    -- LSTR string:未填写部队名字
    self.TextNoName:SetText(LSTR(910291))
    local Tab = {
         -- LSTR string:寓意物
         { Name = LSTR(910293) }, 
         -- LSTR string:盾纹
         { Name = LSTR(910294) },
         -- LSTR string:背景
         { Name = LSTR(910295) },
    }
    self.ToggleGroupTabs:UpdateItems(Tab)
    local Params = self.Params
    if nil == Params then
        return
    end
    bNormArmyName = true
    bNormShortName = true
    bNormNotice = true
    --- 公告无CD
    UIUtil.SetIsVisible(self.TextNoticeTips, false)
    self.InputBoxName:SetMaxNum(Name_Max_Limit)
    self.InputBoxName:SetText(Params.ArmyName)
    -- LSTR string:请输入部队名称
    self.InputBoxName:SetHintText(LSTR(910233))
    self.InputBoxTime:SetMaxNum(ShortName_Max_Limit)
    self.InputBoxTime:SetText(Params.ShortName)
    -- LSTR string:请输入部队简称
    self.InputBoxTime:SetHintText(LSTR(910234))
    -- LSTR string:请输入部队公告
    self.MulitiLineInputBox:SetHintText(LSTR(910231))
    self.MulitiLineInputBox:SetMaxNum(Notice_Max_Limit)
    self.MulitiLineInputBox:SetText(Params.Notice)
    self.IsInput = false
    local CurrentTime = _G.TimeUtil.GetServerTime() --当前时间
    local NameEditCD = self.NameEditSpace * ArmyDefine.Day
    local ShortNameEditCD = self.ShortNameEditSpace* ArmyDefine.Day
    local EmblemEditCD =  self.EmblemEditSpace * ArmyDefine.Day
    local EditNameTime = CurrentTime - Params.NameEditedTime - NameEditCD
    local IsEditName = EditNameTime >= 0
    local EditShortNameTime = CurrentTime - Params.AliasEditedTime - ShortNameEditCD
    local IsEditShortName = EditShortNameTime >= 0
    self.EditEmblemTime = CurrentTime - Params.EmblemEditedTime - EmblemEditCD
    self.IsEditEmblem =  self.EditEmblemTime >= 0
    local Type = _G.ArmyMgr:GetArmyUnionType()
    UnitedIcon = UnitedArmyTabs[Type].BGIcon
    UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyBg, UnitedIcon)
    UIUtil.SetIsVisible(self.ImgArmyBg, true, false)
    --UIUtil.SetIsVisible(self.TextTipsName1, false)
    --UIUtil.SetIsVisible(self.TextTipsName3, false)
    self.InputBoxName:SetIsEnabled(IsEditName)
    self.InputBoxName:SetIsHideNumber(not IsEditName)
    local Color = "B71823FF"
    --- 公会名CD
    if not IsEditName then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextTime, Color)
        self.TextTime:SetText(GetTimeFormatStr(math.abs(EditNameTime)))
        --self.InputBoxName:SetIsEnabled(false)
    end
   -- UIUtil.SetIsVisible(self.TextTipsTime1, false)
   -- UIUtil.SetIsVisible(self.TextTipsTime3, not IsEditShortName)
    self.InputBoxTime:SetIsEnabled(IsEditShortName)
    self.InputBoxTime:SetIsHideNumber(not IsEditShortName)
    --- 简称CD
    if not IsEditShortName then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextTipsName3, Color)
        self.TextTipsName3:SetText(GetTimeFormatStr(math.abs(EditShortNameTime)))
    end
    if not self.IsEditEmblem then
        UIUtil.SetIsVisible(self.TexTmodify, true)
        self.TexTmodify:SetText(GetTimeFormatStr(math.abs( self.EditEmblemTime)))
        self.BtnSave02:SetIsEnabled(false, true)
    else
        UIUtil.SetIsVisible(self.TexTmodify, false)
    end
    self:SetBadge(Params.BadgeData)
    self.BtnSave:SetIsEnabled(false, true)
    self.Callback = Params.Callback

    local Tabs = ArmyDefine.ArmyInfoEditTabs
    self.TableViewTabs:UpdateItems(Tabs)
    self.TableViewTabs:SetSelectedIndex(ArmyDefine.One)
    UIUtil.SetIsVisible(self.TextNoName, false)

    -- LSTR string:保  存
    self.BtnSave:SetText(LSTR(910041))
    -- LSTR string:保  存
    self.BtnSave02:SetText(LSTR(910041))
end

function ArmyInfoEditorWinView:OnHide()
    self.Callback = nil
    self.CurArmyBadgeType = -1
    self.IsInput = false
    self.IsWaitCheck = false
end

function ArmyInfoEditorWinView:OnRegisterUIEvent()
    --UIUtil.AddOnClickedEvent(self, self.BtnEditBadge, self.OnClickedEditBadge)
    UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedSave)
    UIUtil.AddOnClickedEvent(self, self.BtnSave02, self.OnClickedSaveBadge)
    --UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
    UIUtil.AddOnSelectionChangedEvent(self, self.TableViewTabs, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnSelectionChangedEvent(self, self.ToggleGroupTabs, self.OnGroupTabsSelectionChanged)
    UIUtil.AddOnClickedEvent(self, self.BtnRandom, self.OnClickedRandomBadge)
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickedBadgeReset)
    ---快速处理，P5转服务器验证
    UIUtil.AddOnFocusReceivedEvent(self, self.InputBoxName.InputText, self.OnTextFocusReceived)
    UIUtil.AddOnFocusReceivedEvent(self, self.InputBoxTime.InputText, self.OnTextFocusReceived)
end

function ArmyInfoEditorWinView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ArmySelfArmyEmblemUpdate, self.OnSetBadgeCD)
    self:RegisterGameEvent(EventID.ArmySelfArmyNameUpdate, self.OnSetArmyNameCD)
    self:RegisterGameEvent(EventID.ArmySelfArmyAliasUpdateBySelf, self.OnSetAliasNameCD)
    self:RegisterGameEvent(EventID.ArmySelfArmyNoticeUpdate, self.OnSetNoticeChange)
    self:RegisterGameEvent(EventID.ArmyInfoEditTimeUpdate, self.OnAllCDChange)
end

function ArmyInfoEditorWinView:OnTextFocusReceived()
    self.IsInput = true
    self:CheckedSaveBtnState()
end

function ArmyInfoEditorWinView:OnRegisterBinder()
end

function ArmyInfoEditorWinView:SetBadge(BadgeData)
    self.BadgeData = BadgeData
    self.ArmyBadgeItem:SetBadgeData(BadgeData)
end

--- 部队名称submit时触发
function ArmyInfoEditorWinView:OnTextArmyNameCommitted(Text)
    self.IsInput = false
    self.IsWaitCheck = true
    bNormArmyName = false
    self:CheckNameRules(ArmyDefine.ArmyEditTextType.ArmyName, Name_Min_Limit, Name_Max_Limit, Text)
end

--- 部队简称submit时触发
function ArmyInfoEditorWinView:OnTextArmyShortNameCommitted(Text)
    self.IsInput = false
    self.IsWaitCheck = true
    bNormShortName = false
    self:CheckNameRules(ArmyDefine.ArmyEditTextType.ShortName, ShortName_Min_Limit, ShortName_Max_Limit, Text)
end

--- 部队公告submit时触发
function ArmyInfoEditorWinView:OnTextArmyNoticeNameCommitted(Text)
    self.IsInput = false
    self.IsWaitCheck = true
    bNormNotice = false
    self:CheckNameRules(ArmyDefine.ArmyEditTextType.Notice, Notice_Min_Limit, Notice_Max_Limit, Text)
end


function ArmyInfoEditorWinView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)
    local Key = ItemData.Key
    if Key == nil then
        return
    end
    self:PlayAnimation(self.AnimChangeTab)
    if Key == TabKey.InfoEdit then
        UIUtil.SetIsVisible(self.PanelEditName, true)
        UIUtil.SetIsVisible(self.PanelEditBadge, false)
        self.TabsViewAdapter:CancelSelected()
    elseif Key == TabKey.Badge then
        UIUtil.SetIsVisible(self.PanelEditName, false)
        UIUtil.SetIsVisible(self.PanelEditBadge, true)
        self:OnBadgeShow()
    end
   
end

--- 编辑徽章
function ArmyInfoEditorWinView:OnClickedEditBadge()
    local function CommitedCallback(Data)
        self:OnSelectedBadgeCommited(Data)
    end
    UIViewMgr:ShowView(UIViewID.ArmyEmblemEditPanel, {
        UnitedIcon = UnitedIcon,
        BadgeData = self.Params.BadgeData,
        CommitedCallback = CommitedCallback
    })
end

function ArmyInfoEditorWinView:OnSelectedBadgeCommited(BadgeData)
    bSelectedBadge = true
    self:SetBadge(BadgeData)
    self:CheckedBadgeSaveBtnState()
end

function ArmyInfoEditorWinView:IsBadgeChanged()
    if self.BadgeData ~= nil then
        if self.Params.BadgeData.TotemID ~= self.CurSelectedImpliedID or
		self.Params.BadgeData.IconID ~= self.CurSelectedShieldIndex or
		self.Params.BadgeData.BackgroundID ~= self.CurSelectedBgIndex
	    then
            return true
        end
    end
    return false
end

--- 保存
function ArmyInfoEditorWinView:OnClickedSave()
    ---文本校验还没回包，进行拦截提示，后续改为服务器提示
    if self.IsWaitCheck or self.IsInput then
        MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InputCheck)
        return
    end
    local IsEmpty = self:CheckedCreateInfoEmpty()
    local IsError = self:CheckedCreateInfoError()
    if  not IsEmpty and not IsError then
        if self.Params.ArmyName ~= self.InputBoxName:GetText() or
            self.Params.ShortName ~= self.InputBoxTime:GetText() or
            self.Params.Notice ~= self.MulitiLineInputBox:GetText()
        then
            if self.Callback then
                self.Callback(self.InputBoxName:GetText(), self.InputBoxTime:GetText(), self.MulitiLineInputBox:GetText())
            end
        else
            -- LSTR string:未检测到内容变动，无法保存
            MsgTipsUtil.ShowTips(LSTR(910160))
        end
    end
end

--- 队徽保存
function ArmyInfoEditorWinView:OnClickedSaveBadge()
    if not self.IsEditEmblem then
        if self.EditEmblemTime then
            MsgTipsUtil.ShowTips(LSTR(GetTimeFormatStr(math.abs(self.EditEmblemTime))))
        end
        return
    end
    local bBadgeChanged = self:IsBadgeChanged()
    if not bBadgeChanged then
        -- LSTR string:未检测到内容变动，无法保存
        MsgTipsUtil.ShowTips(LSTR(910160))
        return
    end
    local BadgeData = {}
     BadgeData.TotemID = self.CurSelectedImpliedID
     BadgeData.IconID = self.CurSelectedShieldIndex
     BadgeData.BackgroundID = self.CurSelectedBgIndex
    --- 队徽修改
    ArmyMgr:SendArmyEditEmblemMsg(BadgeData)
end

--- 随机徽章
function ArmyInfoEditorWinView:OnClickedRandomBadge()
	local TotemAllCfg = GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
	local ShieldCfg = GroupEmblemIconCfg:GetAllEmblemIconCfg()
	local BgCfg = GroupEmblemBackgroundCfg:GetAllEmblemBgCfg()
	local ImpliedCount = #TotemAllCfg
	local ImpliedIndex = self.CurSelectedImpliedID
	while ImpliedIndex == self.CurSelectedImpliedID do
		ImpliedIndex = math.floor(math.random(1, ImpliedCount))
        local TotemCfg = GroupEmblemTotemCfg:FindCfgByKey(ImpliedIndex)
		if TotemCfg.CompanyIDs then
			local IsFind = table.find_by_predicate(TotemCfg.CompanyIDs,function(A)
				return A == self.CurGrandCompanyType
			end)
			if not IsFind then
				ImpliedIndex = self.CurSelectedImpliedID
			end
		else
			ImpliedIndex = self.CurSelectedImpliedID
		end
	end
	self.CurSelectedImpliedID = ImpliedIndex
	self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
	local ShieldNum = #ShieldCfg
	local ShieldIndex = math.floor(math.random(1, ShieldNum))
	while ShieldIndex == self.CurSelectedShieldIndex do
		ShieldIndex = math.floor(math.random(1, ShieldNum))
	end
	self.CurSelectedShieldIndex = ShieldIndex
	local BgNum = #BgCfg
	local BgIndex = math.floor(math.random(1, BgNum))
	while BgIndex == self.CurSelectedShieldIndex do
		BgIndex = math.floor(math.random(1, BgNum))
	end
	self.CurSelectedBgIndex = BgIndex
	self.ArmyBadgeItem:SetBadgeData({
		TotemID = self.CurSelectedImpliedID,
		IconID = self.CurSelectedShieldIndex,
		BackgroundID = self.CurSelectedBgIndex,
	})
	if self.CurArmyBadgeType == ArmyBadgeType.Implied then
		self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedImpliedIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedShieldIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedBgIndex)
	end
	--self.BtnSave02:SetIsEnabled(true)
    self:CheckedEdit()
	self.BtnReset:SetIsEnabled(true)
end

--- 重置
function ArmyInfoEditorWinView:OnClickedBadgeReset()
	-- LSTR string:提示
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(910144), LSTR(910190), self.Reset, nil, LSTR(910083), LSTR(910182))
end

function ArmyInfoEditorWinView:Reset()
	self.CurSelectedImpliedID = self.OldSelectedImpliedID
	self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
	self.CurSelectedShieldIndex = self.OldSelectedShieldIndex
	self.CurSelectedBgIndex = self.OldSelectedBgIndex
	self.ArmyBadgeItem:SetBadgeData({
		TotemID = self.CurSelectedImpliedID,
		IconID = self.CurSelectedShieldIndex,
		BackgroundID = self.CurSelectedBgIndex,
	})
	self.BtnSave02:SetIsEnabled(false, true)
	self.BtnReset:SetIsEnabled(false)
	--self.ToggleGroupTabs:SetSelectedIndex(1)
    if self.CurArmyBadgeType == ArmyBadgeType.Implied then
		self.CurSelectedImpliedIndex = self:GetTotemListIndexForTotemID(self.CurSelectedImpliedID)
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedImpliedIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.Shield then
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedShieldIndex)
	elseif self.CurArmyBadgeType == ArmyBadgeType.ShieldBg then
		self.TabsViewAdapter:SetSelectedIndex(self.CurSelectedBgIndex)
	end
end

function ArmyInfoEditorWinView:GetTotemListIndexForTotemID(ID)
	local TotemCfg = GroupEmblemTotemCfg:GetAllEmblemTotemCfg()
	local CurSelected = 0
	for _, Totem in ipairs(TotemCfg) do
		if Totem.CompanyIDs then
			for _, CompanyID in ipairs(Totem.CompanyIDs) do
				if self.CurGrandCompanyType and CompanyID == self.CurGrandCompanyType then
					CurSelected = CurSelected + 1
					if Totem.ID == ID then			
						return CurSelected
					end
				end
			end
		end
	end
end

return ArmyInfoEditorWinView
