--
-- Author: enqingchen
-- Date: 2020-09-14 14:55:43
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local DBMgr = require ("DB/DBMgr")
local GmCfg  = require("TableCfg/GmCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ClientReportType = ProtoCS.ReportType
-- local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")
-- local GMSwitchView = require("Game/GM/GMSwitchView")
local CommonUtil = require("Utils/CommonUtil")
local ObjectGCType = require("Define/ObjectGCType")
local EffectUtil = require("Utils/EffectUtil")
local GMVM = require("Game/GM/GMVM")
-- local ItemVM = require("Game/Item/ItemVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableMultiView = require("UI/Adapter/UIAdapterTableMultiView")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GMMgr = require("Game/GM/GMMgr")
local ActorUtil = require("Utils/ActorUtil")
local CommonDefine = require("Define/CommonDefine")
local MainPanelVM = require("Game/Main/MainPanelVM")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local CfgEntrance = require("Game/SystemConfig/CfgEntrance")
local ProtoRes = require("Protocol/ProtoRes")
-- local GMAdapterClass = require("Game/GM/GMAdapterClass")
-- local ActorMgr = _G.ActorMgr
-- local CS_CMD = ProtoCS.CS_CMD
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR
local table_to_string = _G.table_to_string
local ClientCmdList
local MathedViews
local MatchIndexToGMCmdList
local MaxResults = 7
local MinMatchLen = 4

---@class GMMainView : UIView
local GMMainView = LuaClass(UIView, true)

function GMMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BImg = nil
	--self.BtnClearText = nil
	--self.BtnLastText = nil
	--self.BtnMonsterText = nil
	--self.BtnNextText = nil
	--self.BtnSendText = nil
	--self.ButtonClear = nil
	--self.ButtonClearLine = nil
	--self.ButtonClose = nil
	--self.ButtonLast = nil
	--self.ButtonNext = nil
	--self.ButtonSubmit = nil
	--self.CanvasPanel_0 = nil
	--self.ClearText = nil
	--self.CmdlistText = nil
	--self.CommSearchBar = nil
	--self.Drag = nil
	--self.Drag_btn = nil
	--self.FTextBlock_107 = nil
	--self.FirstClassTableView = nil
	--self.GMHistoryText = nil
	--self.GMItemButton_UIBP = nil
	--self.GMItemButton_UIBP_1 = nil
	--self.GMItemButton_UIBP_2 = nil
	--self.GMPlayAudio_UIBP = nil
	--self.GMText = nil
	--self.HistoryScrollBox = nil
	--self.HorizontalTitle = nil
	--self.InputText = nil
	--self.MinText = nil
	--self.Minimize = nil
	--self.MonsterTest = nil
	--self.SearchOverlay = nil
	--self.SearchScrollBox = nil
	--self.SecondClassTableView = nil
	--self.TextBlock = nil
	--self.TextBlock_107 = nil
	--self.TextBlock_153 = nil
	--self.TextSubTtile = nil
	--self.TextTitle = nil
	--self.ThirdClassTableView = nil
	--self.Title = nil
	--self.AudioEventViewer = nil
	--self.GMDrag = nil
	--self.DragOffset = nil
	--self.DragedWidget = nil
	--self.IsCanDrag = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.GMItemButton_UIBP)
	self:AddSubView(self.GMItemButton_UIBP_1)
	self:AddSubView(self.GMItemButton_UIBP_2)
	self:AddSubView(self.GMPlayAudio_UIBP)
	self:AddSubView(self.InputText)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMMainView:OnInit()
    self.TableViewFirstClassVM = UIAdapterTableView.CreateAdapter(self, self.FirstClassTableView)
    self.TableViewSecondClassVM = UIAdapterTableView.CreateAdapter(self, self.SecondClassTableView)
    self.TableViewThirdClassVM = UIAdapterTableMultiView.CreateAdapter(self, self.ThirdClassTableView)
    -- self.TableViewThirdClassVM:InitCategoryInfo(GMVM2)
	self.CommSearchBar:SetCallback(self, nil, self.SearchCommitted, self.SearchCancel)
-- 此变量用于搜索框
    self.IsSearchItemSelected = false
    self.IsSearchItemHovered = false
    self.IsGMButtonClick = false

    if nil == GMMgr.GMStringList then GMMgr.GMStringList = {} end
    if nil == GMMgr.GMHistoryRecord then GMMgr.GMHistoryRecord = "" end
    self.buttonType = GMMgr.GMEnum[1]
    self.sliderType = GMMgr.GMEnum[2]
    self.switchType = GMMgr.GMEnum[3]
    -- 用于保持首页指令信息
    GMMgr.HomePage = {}
    GMMgr.GMCmdList = {}
    self.ChildrenItem = {}
    self.FirstViewList = {}
    --记录一下上一次显示的数据
    self.LastShowList = {}
    self:ReadGMCmd()
end

function GMMainView:OnDestroy()

end

function GMMainView:OnShow()
    self:SetTitleText()
    MathedViews = {}
    MatchIndexToGMCmdList = {}
    self.IsMinimize = false
    self:CreateHomePageWidget()
    GMMgr.Open = true
    GMMgr:MajorIdle()

    self.GMHistoryText:SetText(GMMgr.GMHistoryRecord)
    self.InputText:SetIsHideNumber(true)
    UIUtil.SetIsVisible(self.GMText, false)
    --self.GMText:SetText(GMMgr.GMStringList[GMMgr.GMIndex])
    self.InputText:SetText(GMMgr.GMStringList[GMMgr.GMIndex])
    local IsOpen = _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)
	if IsOpen then
		UIUtil.SetIsVisible(self.CanvasPanel_0, true, true)
	else
		UIUtil.SetIsVisible(self.CanvasPanel_0, false)
	end
end

function GMMainView:SetTitleText()
    self.TextTitle:SetText(LSTR(1440001))   --GMTitle
    self.TextBlock_107:SetText(LSTR(1440002))   --拖拽关
    self.FTextBlock_107:SetText(LSTR(1440003))   --拖拽
    self.MinText:SetText(LSTR(1440004))   --最小化
    self.BtnMonsterText:SetText(LSTR(1440005))   --怪物测试
    self.TextBlock_153:SetText(LSTR(1440006))   --大类
    self.TextBlock:SetText(LSTR(1440007))   --小类
    self.Title:SetText(LSTR(1440008))   --便携指令区域
    self.CmdlistText:SetText(LSTR(1440009))   --指令输入面板
    self.BtnLastText:SetText(LSTR(1440010))   --上一条
    self.BtnNextText:SetText(LSTR(1440011))   --下一条
    self.BtnClearText:SetText(LSTR(1440012))   --清空面板
    self.BtnSendText:SetText(LSTR(1440013))   --发送
    self.ClearText:SetText(LSTR(1440014))   --X
end

function GMMainView:OnHide()
    UIUtil.SetIsVisible(self.GMPlayAudio_UIBP, false)
    GMMgr.ChoseFist = nil
	GMMgr.ChoseSecond = nil
    self.LastShowList = {}
    if self.TimeID then
        self:UnRegisterTimer(self.TimeID)
        self.TimeID = nil
    end
    -- UIUtil.SetIsVisible(self.GMAudioEventViewer, false)
end

function GMMainView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ButtonSubmit, self.OnSubmitHandle)
    UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnCloseHandle)
    UIUtil.AddOnClickedEvent(self, self.ButtonClearLine, self.OnClearInput)
    UIUtil.AddOnClickedEvent(self, self.ButtonClear, self.OnClearHistory)
    UIUtil.AddOnClickedEvent(self, self.ButtonLast, self.OnLastCmd)
    UIUtil.AddOnClickedEvent(self, self.ButtonNext, self.OnNextCmd)
    UIUtil.AddOnClickedEvent(self, self.MonsterTest, self.OnMonsterTestClicked)
    UIUtil.AddOnClickedEvent(self, self.Minimize, self.OnMinimizeClicked)
    UIUtil.AddOnTextCommittedEvent(self, self.InputText.InputText, self.OnGMTextCommitted)
    UIUtil.AddOnTextChangedEvent(self, self.InputText.InputText, self.OnGMTextChange)

    -- UIUtil.AddOnClickedEvent(self, self.test, self.Ontest) -- test
end


function GMMainView:Ontest()
   _G.UIViewMgr:ShowView(UIViewID.Main2ndPanelView)
end

function GMMainView:OnRegisterGameEvent()
    local EventID = require("Define/EventID")
    self:RegisterGameEvent(EventID.GMSelectFilter,self.UpdateSecondAndThird)
    self:RegisterGameEvent(EventID.GMButtonClick, self.OnGMButtonClick)
    self:RegisterGameEvent(EventID.GMLastRecord, self.OnLastCmd)
    self:RegisterGameEvent(EventID.GMNextRecord, self.OnNextCmd)
    self:RegisterGameEvent(EventID.GMEnterSubmit, self.OnSubmitHandle)
    self:RegisterGameEvent(EventID.GMReceiveRes, self.OnGMReceiveRes)
    self:RegisterGameEvent(EventID.ItemIsHoverd, self.OnItemHoverHandle)
    self:RegisterGameEvent(EventID.ItemSelected, self.OnItemSelected)

end

function GMMainView:OnRegisterTimer()

end

function GMMainView:OnRegisterBinder()
    local Binders =
    {
		{ "BindableVM", UIBinderUpdateBindableList.New(self, self.TableViewThirdClassVM ) },
    }
	self:RegisterBinders(GMVM, Binders)
end

function GMMainView:OnMonsterTestClicked()
    -- local View = UIViewMgr:ShowView(UIViewID.MonsterSkillTest)            View没用到所以注释
    UIViewMgr:ShowView(UIViewID.MonsterSkillTest)
    --View:SetVisibility(_G.UE.ESlateVisibility.Visible)
    UIViewMgr:HideView(UIViewID.GMMain)
end

function GMMainView:OnKeyDown(geometry, keyevent)
    local inputEvent = _G.UE.UWidgetBlueprintLibrary.GetInputEventFromKeyEvent(keyevent)
    local keyName = _G.UE.UKismetInputLibrary.Key_GetDisplayName(_G.UE.UKismetInputLibrary.GetKey(keyevent))

    if _G.UE.UKismetInputLibrary.InputEvent_IsShiftDown(inputEvent) then
        if tostring(keyName) == "G" then
            UIViewMgr:HideView(UIViewID.GMMain)
        end
    end
    return self:ReturnHandle()
end

-- 发送指令到服务器
function GMMainView:ReqGM(CmdList)
    _G.GMMgr:ReqGM0(CmdList)
end

-- 从服务器接受指令
function GMMainView:OnGMReceiveRes(Params)
    if Params == nil then
        return
    end
    local MsgBody = Params
    local result = table_to_string(MsgBody)
    if result then
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\nServer: " .. result
        --这里服务器返回的消息中会带有%字符 导致Crash，先转换一下 只影响输出打印
        result = string.gsub(result, "%%", "-")
        _G.FLOG_WARNING(string.format("------------GM Respond: %s-------------", result))

    else
        _G.FLOG_WARNING(string.format("------------no response-------------"))
    end


    ----拦截 cell test msg 命令的返回结果
    self:OnTestCellMessageReceiveRes(MsgBody)


    self:UpdateGMHistory()

    -- 从服务器接收到纯客户端GM
    if "client" == MsgBody.Svr then
        self:ExecuteByParamsFromSvr(MsgBody.Cmd, MsgBody.Result)
        local RspCmd = string.format("clientrsp %s %s", MsgBody.Cmd, table_to_string(MsgBody))
        self:ReqGM(RspCmd)
    end

    --路网返回路点显示
    self:RoadPathRes(MsgBody.Result)
end

function GMMainView:RoadPathRes(Paths)
    --local find1 = string.match(Paths, "全部路径")
    local Find = string.match(Paths, "path%(0%)")
    if Find == nil then
        return
    end

    _G.FLOG_WARNING("---------paths is ok-----------");
    local PosTable = _G.UE.TArray(_G.UE.FVector)

    local PathArray = string.split(Paths, "\n")
    for i=1, #PathArray do
        local OnePath = PathArray[i];
        _G.FLOG_WARNING(OnePath)

        local ret = string.match(OnePath, "path%(")
        if ret ~= nil then
           local XStart = string.find(OnePath, "%[")
           local XEnd = string.find(OnePath, " ")
           local YEnd = string.find(OnePath, " ", XEnd+1)
           local ZEnd = string.find(OnePath, "%]", YEnd+1)

           local X =  tonumber(string.sub(OnePath, XStart+1, XEnd-1))
           local Y =  tonumber(string.sub(OnePath, XEnd+1, YEnd-1))
           local Z =  tonumber(string.sub(OnePath, YEnd+1, ZEnd-1))

           --local Pos =_G.UE.FVector(X,Y,Z)

           PosTable:Add(_G.UE.FVector(X,Y,Z))
        end
    end

    _G.UE.UPWorldMgr:Get():ShowRoadGraph(PosTable, 100)
end

-- ID到按钮的映射，用于从服务器接收GM时根据ID改变对应开关的状态
_G.ButtonMap = {}
-- Cmd字段到CmdID的映射，用于从服务器接收GM时获取对应ID
_G.ClientCmdIDMap = {}

function GMMainView:ReadGMCmd()
    local AllCfg = GmCfg:FindAllCfg("true")
    local CfgL = #AllCfg
    for i = 1, CfgL do
        local data = {
            ID = AllCfg[i].ID,
            TopLevel = AllCfg[i].TopLevel,
            SecondLevel = AllCfg[i].SecondLevel,
            ShowType = AllCfg[i].ShowType,
            Desc = AllCfg[i].Desc,
            DescCN = AllCfg[i].DescCN,
            CmdList = AllCfg[i].CmdList,
            Maximum = AllCfg[i].Maximum,
            Minimum = AllCfg[i].Minimum,
            OnCmdList = AllCfg[i].OnCmdList,
            OffCmdList = AllCfg[i].OffCmdList,
            IsServerCmd = AllCfg[i].IsServerCmd,
            IsAutoSend = AllCfg[i].IsAutoSend,
            RefreshChangeLevel = AllCfg[i].RefreshChangeLevel,
            DefaultValue = AllCfg[i].DefaultValue,
            IsVisibleInHomePage = AllCfg[i].IsVisibleInHomePage,
            TopLevelCN = AllCfg[i].TopLevelCN,
            SecondLevelCN = AllCfg[i].SecondLevelCN,
            ShowTypeCN = AllCfg[i].ShowTypeCN,
        }
        table.insert(GMMgr.GMCmdList, data)
    end

    for i=1, #ClientCmdList do
        local data = {
            TopLevel = ClientCmdList[i].TopLevel or GMMgr.GMEnum[4],
            SecondLevel = ClientCmdList[i].SecondLevel or GMMgr.GMEnum[5],
            ShowType = ClientCmdList[i].ShowType,
            Desc = ClientCmdList[i].Desc,
            DescCN = ClientCmdList[i].Desc,
            CmdList = ClientCmdList[i].CmdList or "",
            IsServerCmd = ClientCmdList[i].IsServerCmd or 0,
            DefaultValue = ClientCmdList[i].DefaultValue,
            Maximum = ClientCmdList[i].Maximum,
            Minimum = ClientCmdList[i].Minimum,
            IsConsoleCmd = ClientCmdList[i].IsConsoleCmd or 0,
            IsAutoSend = ClientCmdList[i].IsAutoSend or 0,
            TopLevelCN = ClientCmdList[i].TopLevelCN or GMMgr.GMEnum[4],
            SecondLevelCN = ClientCmdList[i].SecondLevelCN or GMMgr.GMEnum[5],
            ShowTypeCN = ClientCmdList[i].ShowTypeCN,
        }

        table.insert(GMMgr.GMCmdList, data)
    end

    --chaooren: Init Role Base Skill Cfg
    self:InitRoleBaseSkillTable()

    for i = 1, #GMMgr.GMCmdList do
        GMMgr.GMCmdList[i].ID = i
        -- 调整默认值
        local GMDesc = GMMgr.GMCmdList[i].Desc
        if GMDesc == "PSO采集" then
            GMMgr.GMCmdList[i].DefaultValue = _G.UE.UFlibShaderPipelineCacheHelper.IsEnabledLogPSO() and 1 or 0
        elseif GMDesc == "PSO自动保存" then
            GMMgr.GMCmdList[i].DefaultValue = _G.UE.UFlibShaderPipelineCacheHelper.IsEnabledSaveBoundPSOLog() and 1 or 0
        end
    end

    local count = #GMMgr.GMCmdList
    GMMgr.TopList = {GMMgr.GMEnum[6], GMMgr.GMEnum[7]}
    GMMgr.TopListCN = {GMMgr.GMEnum[6], GMMgr.GMEnum[7]}
    for i = 1, count do
        local findit = false
        for j = 1, #GMMgr.TopList do
            if GMMgr.GMCmdList[i].TopLevelCN == GMMgr.TopListCN[j] then
                findit = true
            end
        end

        if false == findit then
            table.insert(GMMgr.TopList, GMMgr.GMCmdList[i].TopLevel)
            table.insert(GMMgr.TopListCN, GMMgr.GMCmdList[i].TopLevelCN)
        end

        -- 客户端GM指令
        if GMMgr.GMCmdList[i].CmdList == nil or type(GMMgr.GMCmdList[i].CmdList) ~= "string" then
            FLOG_ERROR("CmdList Error = %s", GMMgr.GMCmdList[i].Desc)
            break
        end
        local CmdSplitList = string.split(GMMgr.GMCmdList[i].CmdList, " ")
        if CmdSplitList[1] == "client" then
            _G.ClientCmdIDMap[CmdSplitList[2]] = i
        end
    end

    -- -- 插入第一层
    -- for i = 1, #GMMgr.TopList do
    --     local View = UIViewMgr:CreateView(UIViewID.GMFilterItem, self, true, false)
    --     View:ShowView({Desc = GMMgr.TopList[i], id0 = 1, id1 = 1, TopName = GMMgr.TopList[i], SecondName = "全部"})
    --     --self:AddChildrenItem(View)
    --     self.WrapBoxFilter0:AddChildToWrapBox(View.Object)
    -- end

    -- 插入显示首页内容
    for i = 1, #GMMgr.GMCmdList do
        if GMMgr.GMCmdList[i].IsVisibleInHomePage == 1 then
            -- 插入进度条信息
            if GMMgr.GMCmdList[i].ShowType == self.sliderType then
                table.insert(GMMgr.HomePage, 1, GMMgr.GMCmdList[i])
            end
            -- 按钮信息
            if GMMgr.GMCmdList[i].ShowType == self.buttonType or GMMgr.GMCmdList[i].ShowType == self.switchType then
                table.insert(GMMgr.HomePage, GMMgr.GMCmdList[i])
            end
        end
    end
    GMVM:UpdateVM(GMMgr.HomePage)
    self.LastShowList = GMMgr.HomePage
end

-- 插入第二层和第三层
function GMMainView:UpdateSecondAndThird(TopName, SecondName, bInit)
    self:CreateHomePageWidget()
    local SecondList = {GMMgr.GMEnum[7]}
    local SecondListCN = {GMMgr.GMEnum[7]}
    local ThirdClassGMValues = {}
    local GMCmdList = GMMgr.GMCmdList
    -- 先插入第三层中进度条类型的, 顺便把第二层拿到
    for i = 1, #GMCmdList do
        if GMCmdList[i].TopLevelCN == TopName or GMMgr.GMEnum[7] == TopName then
            -- 拿到第二层
            local findSecond = false
            for j = 1, #SecondList do
                if GMCmdList[i].SecondLevelCN == SecondListCN[j] then
                    findSecond = true
                end
            end

            if false == findSecond then
                table.insert(SecondList, GMCmdList[i].SecondLevel)
                table.insert(SecondListCN, GMCmdList[i].SecondLevelCN)
            end
            -- 插入进度条
            if GMCmdList[i].SecondLevel == SecondName or GMMgr.GMEnum[7] == SecondName or GMCmdList[i].SecondLevelCN == SecondName then
                if GMCmdList[i].ShowType == self.sliderType then
                    table.insert(ThirdClassGMValues, GMCmdList[i])
                end
            end
        end
    end

    -- 第三层中的其他类型
    for i = 1, #GMCmdList do
        if (GMCmdList[i].TopLevel == TopName or GMMgr.GMEnum[7] == TopName or GMCmdList[i].TopLevelCN == TopName) and (GMCmdList[i].SecondLevel == SecondName or GMMgr.GMEnum[7] == SecondName or GMCmdList[i].SecondLevelCN == SecondName) and GMCmdList[i].ShowType ~= self.sliderType then
            table.insert(ThirdClassGMValues, GMCmdList[i])
        end

        --天气面板只有选择天气时才会显示
        if (GMCmdList[i].TopLevel == TopName and GMCmdList[i].SecondLevel == SecondName and SecondName == LSTR("天气")) or (GMCmdList[i].TopLevelCN == TopName and GMCmdList[i].SecondLevelCN == SecondName and SecondName == LSTR("天气")) then
            --天气是面板不在全部中显示
            if GMCmdList[i].ShowType == self.ViewType then
                table.insert(ThirdClassGMValues, GMCmdList[i])
            end
        end
    end

    -- 插入第二层
    local SecondClassGMValues = {}
    for i = 1, #SecondList do
        table.insert(SecondClassGMValues, {Desc = SecondList[i], id0 = 1, id1 = 1, Type = 2, TopName = TopName, SecondName = SecondList[i], TopNameCN = TopName, SecondNameCN = SecondListCN[i]})
    end
    self.TableViewSecondClassVM:UpdateAll(SecondClassGMValues)
    -- 显示首页功能 ScrollBox
    local HomePage = GMMgr.HomePage
    if TopName == GMMgr.GMEnum[6] then
        for i = 1, #HomePage do
            table.insert(ThirdClassGMValues, HomePage[i])
        end
    end
    GMVM:UpdateVM(ThirdClassGMValues)
    self.LastShowList = ThirdClassGMValues
    -- 第三层中的其他类型
    for i = 1, #ThirdClassGMValues do
        if (ThirdClassGMValues[i].TopLevel == TopName or GMMgr.GMEnum[7] == TopName or ThirdClassGMValues[i].TopLevelCN == TopName) and (ThirdClassGMValues[i].SecondLevel == SecondName or GMMgr.GMEnum[7] == SecondName or ThirdClassGMValues[i].SecondLevelCN == SecondName) then
            _G.ButtonMap[i] = GMVM:GetViewByVMIndex(i)
        end
    end
end

function GMMainView:CreateHomePageWidget()
    self.buttonType = GMMgr.GMEnum[1]
    self.sliderType = GMMgr.GMEnum[2]
    self.switchType = GMMgr.GMEnum[3]
    -- 插入第一层
    self.FirstViewList = {}
    local FirstClassGMValues = {}
    for i = 1, #GMMgr.TopList do
        table.insert(FirstClassGMValues, {Desc = GMMgr.TopList[i], id0 = 1, id1 = 1, Type = 1, TopName = GMMgr.TopList[i], TopNameCN = GMMgr.TopListCN[i], SecondName = GMMgr.GMEnum[7], SecondNameCN = GMMgr.GMEnum[7]})
    end

    self.TableViewFirstClassVM:UpdateAll(FirstClassGMValues)
    --GMVM:UpdateVM(GMMgr.HomePage)
end

-- 点击发送按钮self.GMStringList
function GMMainView:OnSubmitHandle()
    local reqText = tostring(self.InputText:GetText())

    --拦截 cell test msg 命令
    self:TestCellMessage(reqText)

    --以下为原码
    self:ReqGM(reqText)

    if #GMMgr.GMStringList == 0 then
        table.insert(GMMgr.GMStringList, reqText)
    else
        if GMMgr.GMStringList[#GMMgr.GMStringList] ~= reqText then
            table.insert(GMMgr.GMStringList, reqText)
        end
    end
    GMMgr.GMIndex = #GMMgr.GMStringList
    GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\nGM: " .. reqText
    self:UpdateGMHistory()


end

-- 点击关闭按钮
function GMMainView:OnCloseHandle()
    UIViewMgr:HideView(UIViewID.GMMain)
end

-- 页签被选中, 更新便捷指令区域
function GMMainView:OnGMSelectFilter(id0, id1)
    self:UpdateItemList(id0, id1)
end

-- 清空当前指令显示
function GMMainView:OnClearInput()
    self.InputText:SetText("")
end

-- 清空历史指令记录显示
function GMMainView:OnClearHistory()
    self:UpdateGMHistory(true)
end

-- 切换到上一条指令
function GMMainView:OnLastCmd()
    if GMMgr.GMIndex <= 1 then return end
    GMMgr.GMIndex = GMMgr.GMIndex - 1
    self.InputText:SetText(GMMgr.GMStringList[GMMgr.GMIndex])

    -- GMButton按钮被点击置ture
    self.IsGMButtonClick = true
    -- 如果是点击GMButton隐藏
    UIUtil.SetIsVisible(self.SearchOverlay, false, false)
    --self.SearchScrollBox:ClearChildren()
    -- 显示重叠的4个按钮
    UIUtil.SetIsVisible(self.ButtonLast, true, true)
    UIUtil.SetIsVisible(self.ButtonNext, true, true)
    UIUtil.SetIsVisible(self.ButtonClear, true, true)
    UIUtil.SetIsVisible(self.ButtonSubmit, true, true)
end

-- 切换到下一条指令
function GMMainView:OnNextCmd()
    if(GMMgr.GMIndex < #GMMgr.GMStringList) then
        GMMgr.GMIndex = GMMgr.GMIndex + 1
        self.InputText:SetText(GMMgr.GMStringList[GMMgr.GMIndex])
    end

    -- GMButton按钮被点击置ture
    self.IsGMButtonClick = true
    -- 如果是点击GMButton隐藏
    UIUtil.SetIsVisible(self.SearchOverlay, false, false)
    --self.SearchScrollBox:ClearChildren()
    -- 显示重叠的4个按钮
    UIUtil.SetIsVisible(self.ButtonLast, true, true)
    UIUtil.SetIsVisible(self.ButtonNext, true, true)
    UIUtil.SetIsVisible(self.ButtonClear, true, true)
    UIUtil.SetIsVisible(self.ButtonSubmit, true, true)
end

-- 点击便捷指令按钮
function GMMainView:OnGMButtonClick(params)
    _G.FLOG_INFO("GMMainView:OnGMButtonClick Params=%s", params)
    self:ExecuteByParams(params)
    -- GMButton按钮被点击置ture
    self.IsGMButtonClick = true
    -- 如果是点击GMButton隐藏
    UIUtil.SetIsVisible(self.SearchOverlay, false, false)
    --self.SearchScrollBox:ClearChildren()
    -- 显示重叠的4个按钮
    UIUtil.SetIsVisible(self.ButtonLast, true, true)
    UIUtil.SetIsVisible(self.ButtonNext, true, true)
    UIUtil.SetIsVisible(self.ButtonClear, true, true)
    UIUtil.SetIsVisible(self.ButtonSubmit, true, true)
end

function GMMainView:ExecuteByParams(params)
    if params.IsConsoleCmd and params.IsConsoleCmd == 1 then
        _G.UE.UFGameInstance.ExecCmd(params.CmdList)
        return
    end

    --_G.FLOG_INFO("ExecuteByParams!!!!!!!!!!!,params.IsServerCmd = %d,params.IsAutoSend = %d,params.Desc = %s",params.IsServerCmd, params.IsAutoSend,params.Desc)
    if params.IsServerCmd == 1 then
        self.InputText:SetText(params.CmdList)
        if params.IsAutoSend == 1 then
            self:OnSubmitHandle()
        end
    else
        if params.IsAutoSend == 1 then
            self:DoClientClick(params)
        else
            self.InputText:SetText(params.CmdList)
        end
    end

end

-- 搜索框Item被选中执行
function GMMainView:OnItemSelected(cmd)
    self.IsSearchItemSelected = true
    if not self.IsMinimize and not string.isnilorempty(cmd) then
        self.InputText:SetText(cmd)
    end

    self.SearchScrollBox:ClearChildren()
    -- 隐藏搜索框
    self.SearchOverlay:SetVisibility(_G.UE.ESlateVisibility.Hidden)

    -- 显示重叠的4个按钮
    self.ButtonLast:SetVisibility(_G.UE.ESlateVisibility.Visible)
    self.ButtonNext:SetVisibility(_G.UE.ESlateVisibility.Visible)
    self.ButtonClear:SetVisibility(_G.UE.ESlateVisibility.Visible)
    self.ButtonSubmit:SetVisibility(_G.UE.ESlateVisibility.Visible)
end

-- 当搜索框Item被Hover时执行
function GMMainView:OnItemHoverHandle(IsHovered)
    if IsHovered then
        self.IsSearchItemHovered = true
    else
        self.IsSearchItemHovered = false
    end
end

-- 当文本改变执行
function GMMainView:OnGMTextChange(_, Text)
    if GMMgr.Open then
        -- 隐藏搜索框
        UIUtil.SetIsVisible(self.SearchOverlay, false, false)
        GMMgr.Open = false
        return
    end
    if self.IsSearchItemSelected then
        self.IsSearchItemSelected = false
        return
    end
    if self.IsGMButtonClick then
        self.IsGMButtonClick = false
        return
    end

    -- 先清空Item
    self.SearchScrollBox:ClearChildren()
    if #MathedViews > 0 then
        for _, Data in ipairs(MathedViews) do
            if Data.View then
                UIViewMgr:RecycleView(Data.View)
            end
        end
        MathedViews = {}
        MatchIndexToGMCmdList = {}
    end

    -- 匹配所有符合条件的指令
    -- 首先如果Text为空那么不存在符合条件的
    if Text == "" then
        UIUtil.SetIsVisible(self.SearchOverlay, false, false) -- 条件改变时先隐藏
        return
    end

    if type(Text) ~= "string" then
        UIUtil.SetIsVisible(self.SearchOverlay, false, false) -- 条件改变时先隐藏
        return
    end

    UIUtil.SetIsVisible(self.SearchOverlay, false, false) -- 条件改变时先隐藏
    -- 不为空
    --local Pattren = string.format("%s%s",Text, ".*")
    if #Text >= MinMatchLen then
        for i = 1, #GMMgr.GMCmdList do
            if #MatchIndexToGMCmdList >= MaxResults then
                break
            end

            local CmdList = GMMgr.GMCmdList[i].CmdList or ""
            local IsMatch = string.sub(CmdList, 1, #Text) == Text
            if CmdList ~= nil and Text ~= nil and IsMatch then
                local matched = string.find(CmdList, Text, 1, true)
                if matched then
                    table.insert(MatchIndexToGMCmdList, i)
                    local Data = {}
                    Data.Info = GMMgr.GMCmdList[i]
                    table.insert(MathedViews, Data)
                end
            end
        end
    end

    local function DelayShow()
        local ItemLen = self.SearchScrollBox:GetChildrenCount()
        local CurIndex = math.min(ItemLen + 1, MaxResults)
        local Data = MathedViews[CurIndex]
        if Data and ItemLen < MaxResults then
            local View = _G.UIViewMgr:CreateView(UIViewID.ItemButton, self, true, false)
            Data.View = View
            View:ShowView(Data.Info)
            self.SearchScrollBox:AddChild(View)
        else
            if self.TimeID then
                self:UnRegisterTimer(self.TimeID)
                self.TimeID = nil
            end
        end
    end


    if self.TimeID == nil and #MathedViews > 0 then
		self.TimeID = self:RegisterTimer(DelayShow, 0, 0.1, 0)
	end

    if _G.next(MatchIndexToGMCmdList) == nil then --没有匹配内容不显示
        return
    end

    UIUtil.SetIsVisible(self.SearchOverlay, true, true) --匹配内容显示GM
        -- 显示搜索框
    --self.SearchOverlay:SetVisibility(UE.ESlateVisibility.Visible)
end

-- 指令框文本提交
function GMMainView:OnGMTextCommitted(Text, _)
    -- 判断是否搜索框Item被Hover
    if self.IsSearchItemHovered then
        return
    end

    -- 隐藏搜索框
    UIUtil.SetIsVisible(self.SearchOverlay, false, false)

end

-- 点击最小化GM界面
function GMMainView:OnMinimizeClicked()
    self.IsMinimize = true
    UIViewMgr:ShowView(UIViewID.GMMainMinimizationHud)
    UIViewMgr:HideView(UIViewID.GMMain)
    _G.EventMgr:SendEvent(_G.EventID.MinimizationUIShow, self.InputText:GetText())
end

-- 执行从服务器接收的客户端指令
function GMMainView:ExecuteByParamsFromSvr(MsgCmd, MsgResult)
    local CmdID = tonumber(_G.ClientCmdIDMap[MsgCmd])
    local button = _G.ButtonMap[CmdID]
    local params = GMMgr.GMCmdList[CmdID]

    if CmdID == nil then
        _G.FLOG_ERROR("GMMainView ExecuteByParamsFromSvr Cmd = nil")
        return
    end

    if params == nil then
        _G.FLOG_ERROR("GMMainView ExecuteByParamsFromSvr Error ClientCmdIDMap Not Exist CmdID=%d", CmdID)
        return
    end

    if params.ShowType == GMMgr.GMEnum[3] then
        button:ChangeSwitchButtonState(params)
    end

    if params.Desc == "配置RTPC值" then
        local splitList = string.split(params.CmdList, " ")
        params.CmdList = string.format("%s %s %s", splitList[1], splitList[2], MsgResult)
        self.InputText:SetText(params.CmdList)
    end

    self:ExecuteByParams(params)
    _G.FLOG_WARNING(string.format("------------GM Command: %s-------------", params.Desc))
end

-- 更新历史指令记录的显示
function GMMainView:UpdateGMHistory(bClearAll)
    if bClearAll == true then
        GMMgr.GMHistoryRecord = ""
        self.GMHistoryText:SetText("")
    end

    if GMMgr.GMHistoryRecord == nil then
        GMMgr.GMHistoryRecord = ""
    end

    self.GMHistoryText:SetText(GMMgr.GMHistoryRecord)
    self.HistoryScrollBox:ScrollToEnd()
    GMMgr.GMIndex = #(GMMgr.GMStringList)
end

-- 初始化怪物技能信息
function GMMainView:InitRoleBaseSkillTable()
    local RoleBaseSkillCfg = require("TableCfg/RoleBaseSkillCfg")
    local RoleBaseSkillInfo = RoleBaseSkillCfg:FindAllCfg("true")
    local SkillMainCfg = require("TableCfg/SkillMainCfg")
    local MonsterCfg = require("TableCfg/MonsterCfg")
    if RoleBaseSkillInfo == nil then
        return
    end
    for i = 1, #RoleBaseSkillInfo do
        local SingleInfo = RoleBaseSkillInfo[i]
        local Name = MonsterCfg:FindValue(SingleInfo.ResID, "Name")
        if Name then
            local SpawnRole = {
                TopLevel = GMMgr.GMEnum[8],
                SecondLevel = Name,
                TopLevelCN = GMMgr.GMEnum[8],
                SecondLevelCN = Name,
                ShowType = GMMgr.GMEnum[1],
                Desc = GMMgr.GMEnum[9] .. Name,
                CmdList = "cell monster create " .. SingleInfo.ResID,
                IsServerCmd = 1,
                IsAutoSend = 1,
            }
            table.insert(GMMgr.GMCmdList, SpawnRole)
            local Count = SingleInfo.Count
            for j = 1, Count do
                local SkillID = SingleInfo.BaseSkillID + j - 1
                local SkillDesc = SkillMainCfg:FindValue(SkillID, "SkillName")
                if SkillDesc then
                    local SpawnSkill = {
                        TopLevel = GMMgr.GMEnum[8],
                        SecondLevel = Name,
                        TopLevelCN = GMMgr.GMEnum[8],
                        SecondLevelCN = Name,
                        ShowType = GMMgr.GMEnum[1],
                        Desc = SkillDesc .. "(" .. SkillID .. ")",
                        CmdList = "cell skill monster " .. SkillID,
                        IsServerCmd = 1,
                        IsAutoSend = 1,
                    }
                    table.insert(GMMgr.GMCmdList, SpawnSkill)
                end
            end
        end
    end
end

--【客户端同学可以在此处进行添加新的本地GM指令，也可以在GM表格中添加】
-- 在此处添加的本地GM指令只会显示在客户端，在GM表格中添加的指令会同时显示在客户端和服务器web端。
-- 对于硬编码在此处的指令，当 IsServerCmd=0 时：
-- -- 若 IsAutoSend=1，点击执行 self:DoClientClick(Params) 逻辑
-- -- 若 IsAutoSend=0，点击“发送”执行 GMMgr:DoClientInput(cmd) 逻辑，此时命令需要以 client 开头
ClientCmdList =
{
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[15], TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[15], Desc = LSTR("开-圆形交互"), ShowType = GMMgr.GMEnum[1], CmdList = "test.opencirclerange 1", IsServerCmd = 0, IsAutoSend = 0, IsConsoleCmd = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[15], Desc = LSTR("关-圆形交互"), ShowType = GMMgr.GMEnum[1], CmdList = "test.opencirclerange 0", IsServerCmd = 0, IsAutoSend = 0, IsConsoleCmd = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], Desc = LSTR("炼金"), ShowType = GMMgr.GMEnum[1], CmdList = "client crafter" },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], Desc = LSTR("副本任务"), ShowType = GMMgr.GMEnum[1], IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], Desc = LSTR("副本入口"), ShowType = GMMgr.GMEnum[1], IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], Desc = LSTR("挂机测试"), ShowType = GMMgr.GMEnum[1], IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[11], SecondLevelCN = GMMgr.GMEnum[11], Desc = LSTR("天气面板"), ShowType = GMMgr.GMEnum[16], IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[12], SecondLevel= GMMgr.GMEnum[5], Desc = LSTR("幻卡编辑界面"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.MagicCardMgr:SendOpenGameStartReq(false)", IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[12], SecondLevel= GMMgr.GMEnum[5], Desc = LSTR("幻卡图鉴界面"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.MagicCardCollectionMgr:ShowMagicCardCollectionMainPanel()", IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[12], SecondLevel= GMMgr.GMEnum[5], Desc = LSTR("幻卡大赛排名界面"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.MagicCardTourneyMgr:ShowRankView()", IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[12], SecondLevel= GMMgr.GMEnum[5], Desc = LSTR("时尚品鉴主界面"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.FashionEvaluationMgr:OnEnterFashionEvaluation()", IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[12], SecondLevel= GMMgr.GMEnum[5], Desc = LSTR("光之启程主界面"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.DepartOfLightMgr:ShowDepartMainView()", IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[12], SecondLevel= GMMgr.GMEnum[5], Desc = LSTR("光之启程回收界面"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.DepartOfLightMgr:ShowDepartRecycleView()", IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[17], Desc = LSTR("路网显示"), ShowType = GMMgr.GMEnum[1], CmdList = "client showroadgraph", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[17], Desc = LSTR("寻路基建"), ShowType = GMMgr.GMEnum[1], CmdList = "client roadtest", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[17], Desc = LSTR("自动寻路测试"), ShowType = GMMgr.GMEnum[1], CmdList = "client autopathmove", IsServerCmd = 0, IsAutoSend = 0},
    --{ TopLevel = GMMgr.GMEnum[4], SecondLevel= "关卡", Desc = "传送带传送", ShowType = GMMgr.GMEnum[1], CmdList = "client transedge", IsServerCmd = 0, IsAutoSend = 0},
    --{ TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[17], Desc = LSTR("地图自动寻路"), ShowType = GMMgr.GMEnum[3], IsServerCmd = 0, IsAutoSend = 1 },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[17], Desc = LSTR("显示球"), ShowType = GMMgr.GMEnum[1], CmdList = "client showSphere", IsServerCmd = 0, IsAutoSend = 0},

    --自动化测试-录制回放模块
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[14], Desc = LSTR("开始播放"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.AutoTest.StartPlayInput('record.IRF')", IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[14], Desc = LSTR("结束播放"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.AutoTest.StopPlayInput()", IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[14], Desc = LSTR("暂停播放"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.AutoTest.PausePlayInput()", IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[14], Desc = LSTR("继续播放"), ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.AutoTest.ContinuePlayInput()", IsAutoSend = 1},

    { Desc = LSTR("使用艾欧泽亚文字"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], CmdList = "client UseAozyFont", IsServerCmd = 0, IsAutoSend = 1 },
    { Desc = LSTR("使用MainFont"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], CmdList = "client UseMainFont", IsServerCmd = 0, IsAutoSend = 1 },
    { Desc = LSTR("播放音频"), TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[5], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayAudio", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("播放角色动作"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayRoleAnim", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("播放循环动作(ATL)"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayRoleAnimLooping", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("停止循环动作(ATL)"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client StopPlayRoleAnimLooping", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("播放角色TPose"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayRoleTPose", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("停止角色TPose"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client StopPlayRoleTPose", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("角色旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[2], CmdList = "client RotateActorInRPM {}", Minimum = -180, Maximum = 180, DefaultValue = 0.0},
    { Desc = LSTR("停止角色旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client StopActorRotate", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("重置角色旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client ResetActorRotation", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("相机旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[2], CmdList = "client RotateCameraInRPM {}", Minimum = -180, Maximum = 180, DefaultValue = 0.0},
    { Desc = LSTR("停止相机旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client StopCameraRotate", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("重置相机旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client ResetCameraRotation", IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("开始TPose并延迟旋转"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayTPoseDelayRotate", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("播放气泡"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayYell", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("播放Balloon"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[1], CmdList = "client PlayBalloon", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("角色缓存数量"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[4], ShowType = GMMgr.GMEnum[3], DefaultValue = 0, IsAutoSend = 1},
	{ Desc = LSTR("头盔机关"), ShowType = GMMgr.GMEnum[3], IsAutoSend = 1},
    { Desc = LSTR("创建AvatarProfile"), ShowType = GMMgr.GMEnum[1], IsAutoSend = 1 },
    { Desc = LSTR("设置客户端配置值"), ShowType = GMMgr.GMEnum[1], IsAutoSend = 0, CmdList = "client SetClientConfig" },
    { Desc = LSTR("显示音频列表"), ShowType = GMMgr.GMEnum[1], CmdList = "client ShowAudioList", IsServerCmd = 0, IsAutoSend = 1},
    --{ Desc = "幻卡默认开局", ShowType = GMMgr.GMEnum[1], CmdList = "lua MagicCardMgr:SendNpcFantasyCard(29000009)", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("显示音频位置"), ShowType = GMMgr.GMEnum[3], CmdList = "client ShowAudioPos", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("暂停对白Sequence"), ShowType = GMMgr.GMEnum[1], CmdList = "client ShowAudioPos", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("停止对白Sequence"), ShowType = GMMgr.GMEnum[1], CmdList = "client ShowAudioPos", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("切换大世界天气"), ShowType = GMMgr.GMEnum[1], CmdList = "client changeweather", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("锁定时间与天气"), ShowType = GMMgr.GMEnum[1], CmdList = "client setweatherandlocktime time lock", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("暂停或播放天气Sequence"), ShowType = GMMgr.GMEnum[3], DefaultValue = 1, IsAutoSend = 1},
    { Desc = LSTR("关闭BGM"), ShowType = GMMgr.GMEnum[3], DefaultValue = 1, IsAutoSend = 1},
    { Desc = LSTR("钓鱼笔记钓场位置调整"), ShowType = GMMgr.GMEnum[3], DefaultValue = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[19], SecondLevel= LSTR("制作笔记"), Desc = LSTR("制作快捷道具"), ShowType = GMMgr.GMEnum[3], DefaultValue = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[19], SecondLevel= LSTR("采集笔记"), Desc = LSTR("采集笔记设置版本"), ShowType = GMMgr.GMEnum[1],CmdList = "client SetGatherNoteVersion 2.2.0", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("装备测试入口"), ShowType = GMMgr.GMEnum[1], CmdList = "client ShowAudioPos", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("显示染色图"), ShowType = GMMgr.GMEnum[1], CmdList = "client ShowAudioPos", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("天气时间"), ShowType = GMMgr.GMEnum[2], CmdList = "client weather set time {}", IsServerCmd = 0, IsAutoSend = 1, Minimum = 1, Maximum = 1440},
    --[[ { TopLevel = GMMgr.GMEnum[19], SecondLevel = GMMgr.GMEnum[13], Desc = "可视交互范围", ShowType = GMMgr.GMEnum[2], CmdList = "client SetMaxDistance 0 {}", IsServerCmd = 0, IsAutoSend = 1, Minimum = 1, Maximum = 1440},
    { TopLevel = GMMgr.GMEnum[19], SecondLevel = GMMgr.GMEnum[13], Desc = "通用交互范围", ShowType = GMMgr.GMEnum[2], CmdList = "client SetMaxDistance 1 {}", IsServerCmd = 0, IsAutoSend = 1, Minimum = 1, Maximum = 1440},
    { TopLevel = GMMgr.GMEnum[19], SecondLevel = GMMgr.GMEnum[13], Desc = "特殊物件交互范围", ShowType = GMMgr.GMEnum[2], CmdList = "client SetMaxDistance 2 {}", IsServerCmd = 0, IsAutoSend = 1, Minimum = 1, Maximum = 1440},  ]]
    { Desc = LSTR("大水晶传送"), ShowType = GMMgr.GMEnum[1], CmdList = "client CrystalPortalTrans 100301", IsServerCmd = 0, IsAutoSend = 1},
    -- { Desc = "相机前后偏移", TopLevel = "基础", SecondLevel = GMMgr.GMEnum[21], ShowType = GMMgr.GMEnum[2], CmdList = "client Camera Offset X {}", Minimum = -500, Maximum = 500, DefaultValue = 0.0},
    -- { Desc = "相机左右偏移", TopLevel = "基础", SecondLevel = GMMgr.GMEnum[21], ShowType = GMMgr.GMEnum[2], CmdList = "client Camera Offset Y {}", Minimum = -500, Maximum = 500, DefaultValue = 0.0},
    -- { Desc = "相机上下偏移", TopLevel = "基础", SecondLevel = GMMgr.GMEnum[21], ShowType = GMMgr.GMEnum[2], CmdList = "client Camera Offset Z {}", Minimum = -100, Maximum = 500, DefaultValue = 0.0},
    -- { Desc = "重置相机偏移", TopLevel = "基础", SecondLevel = GMMgr.GMEnum[21], ShowType = GMMgr.GMEnum[1], CmdList = "client Camera Reset Offset"},
    { Desc = LSTR("传送至追踪任务目标"), TopLevel = GMMgr.GMEnum[20], SecondLevel = GMMgr.GMEnum[21], ShowType = GMMgr.GMEnum[1], IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("设置ZoomSpeed"), ShowType = GMMgr.GMEnum[1], CmdList = "client SetZoomSpeed ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("设置InterpSpeed"), ShowType = GMMgr.GMEnum[1], CmdList = "client SetInterpSpeed ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("设置InterpSpeedToInterpolation"), ShowType = GMMgr.GMEnum[1], CmdList = "client SetInterpSpeedToInterpolation ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("设置ResetInterpSpeedTolerance"), ShowType = GMMgr.GMEnum[1], CmdList = "client SetResetInterpSpeedTolerance ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("打印怪物动作资源路径"), ShowType = GMMgr.GMEnum[1], CmdList = "client PrintAnimsPath ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("测试定时器崩溃"), ShowType = GMMgr.GMEnum[1], CmdList = "client TestTimer ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("CVM开关"), ShowType = GMMgr.GMEnum[1], CmdList = "client SwitchCVM ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("路径播放Sequence"), ShowType = GMMgr.GMEnum[1], CmdList = "client seqp", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("选中的目标执行指定behavior"), ShowType = GMMgr.GMEnum[1], CmdList = "client behaviorset", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("选中的目标打开behavior日志"), ShowType = GMMgr.GMEnum[1], CmdList = "client behaviorlogopen", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("播放动态物件效果"), ShowType = GMMgr.GMEnum[1], CmdList = "client sharedgroup instanceid state", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("更改NPC对话框风格"), ShowType = GMMgr.GMEnum[1], CmdList = "client switchstyle", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("播放对话内容"), ShowType = GMMgr.GMEnum[1], CmdList = "client playdialog", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("设置怪物动作状态"), ShowType = GMMgr.GMEnum[1], CmdList = "client setModelState", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("上坐骑"), ShowType = GMMgr.GMEnum[1], CmdList = "client SetRide 1", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("申请上他人坐骑"), ShowType = GMMgr.GMEnum[1], CmdList = "client SetOtherRide", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("邀请他人上坐骑"), ShowType = GMMgr.GMEnum[1], CmdList = "client InviteOtherRide", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("测试申请通知"), ShowType = GMMgr.GMEnum[1], CmdList = "client TestInvite", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("下坐骑"), ShowType = GMMgr.GMEnum[1], CmdList = "client CancelRide 0", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("测试FATE更新"), ShowType = GMMgr.GMEnum[1], CmdList = "client fate update", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("测试FATE结束"), ShowType = GMMgr.GMEnum[1], CmdList = "client fate end", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("在线状态设置界面"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], CmdList = "client OnlineStatusShowSettings", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("充值"), TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("查看一等奖号码、期数"), ShowType = GMMgr.GMEnum[1], CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("清空仙人仙彩全部数据"), ShowType = GMMgr.GMEnum[1], CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("仙人仙彩开奖"), ShowType = GMMgr.GMEnum[1], CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("收藏品界面"), ShowType = GMMgr.GMEnum[1],CmdList = "open collectpanel",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("莫古抓球机界面"), ShowType = GMMgr.GMEnum[1],CmdList = "open MooglePawPanel",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("矿脉探索界面"), ShowType = GMMgr.GMEnum[1],CmdList = "open TheFinerMinerPanel",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("孤树无援界面"), ShowType = GMMgr.GMEnum[1],CmdList = "open OutOnALimbPanel",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("旅行笔记界面"), ShowType = GMMgr.GMEnum[1],CmdList = "open TravelLogPanel",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("称号界面"), ShowType = GMMgr.GMEnum[1],  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("添加称号"), ShowType = GMMgr.GMEnum[1],CmdList = "zone titlegm gainTitle ", IsServerCmd = 1, IsAutoSend = 0},
    { Desc = LSTR("新手引导-引导ID"), ShowType = GMMgr.GMEnum[1], CmdList = "client playTutorial", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("新手引导-新手指南"), ShowType = GMMgr.GMEnum[1],  CmdList = "client playTutorialGuide", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("新手引导开关"), ShowType = GMMgr.GMEnum[3], DefaultValue = 1, IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("打开新手指南"), ShowType = GMMgr.GMEnum[1], IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("测试新手引导"), ShowType = GMMgr.GMEnum[10], CmdList = "client TestTutorial",IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("启用新手引导"), ShowType = GMMgr.GMEnum[1], CmdList = "client EnableTutorial", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("推荐任务一键置新"), ShowType = GMMgr.GMEnum[1], IsServerCmd = 0, IsAutoSend = 1},

    { Desc = LSTR("解锁所有系统(表现)"), ShowType = GMMgr.GMEnum[1], CmdList = "open activityui3",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("解锁X系统"), ShowType = GMMgr.GMEnum[1], CmdList = "zone moduleopen open ",  IsServerCmd = 0, IsAutoSend = 0},

    { Desc = LSTR("暂停侧边栏"), ShowType = GMMgr.GMEnum[1], CmdList = "client SidePopup Pause 1",  IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("开启侧边栏"), ShowType = GMMgr.GMEnum[1], CmdList = "client SidePopup Start 1",  IsServerCmd = 0, IsAutoSend = 0},

    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("请求视野"), ShowType = GMMgr.GMEnum[1], CmdList = "client ReqVision", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("PCSS 开关"), ShowType = GMMgr.GMEnum[1], CmdList = "client PcssOpen", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("PCSS 阴影距离"), ShowType = GMMgr.GMEnum[1], CmdList = "client PcssCSMDistance", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("PCSS 衰减指数"), ShowType = GMMgr.GMEnum[1], CmdList = "client PcssCSMDistributionExponente", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = "PCSS Shadow Bias", ShowType = GMMgr.GMEnum[1], CmdList = "client PcssShadowBias", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = "PCSS Shadow Slope Bias", ShowType = GMMgr.GMEnum[1], CmdList = "client PcssShadowSlopeBias", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("CSM数量 最大2"), ShowType = GMMgr.GMEnum[1], CmdList = "client CSMCascadeNum", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("占位"), ShowType = GMMgr.GMEnum[1], CmdList = "client CSMCascadeNum", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("使用简化自阴影"), ShowType = GMMgr.GMEnum[1], CmdList = "client EngineEasyHDShadow", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("使用简化自阴影日志"), ShowType = GMMgr.GMEnum[1], CmdList = "client EngineEasyHDShadowDebug", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("最近距离"), ShowType = GMMgr.GMEnum[1], CmdList = "client EngineNearCamDst", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("最近时一级面积"), ShowType = GMMgr.GMEnum[1], CmdList = "client EngineNearDistribution", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("最远距离"), ShowType = GMMgr.GMEnum[1], CmdList = "client EngineFarCamDst", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("最远时一级面积"), ShowType = GMMgr.GMEnum[1], CmdList = "client EngineFarDistribution", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("监修测试开关"), ShowType = GMMgr.GMEnum[3], IsServerCmd = 0, IsAutoSend = 1 },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("地图参数开关"), ShowType = GMMgr.GMEnum[3], IsServerCmd = 0, IsAutoSend = 1 },
    --{ TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[22], Desc = LSTR("开启特效打印"), ShowType = GMMgr.GMEnum[3], DefaultValue = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("显示副本教学界面"), ShowType = GMMgr.GMEnum[1],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("副本教学引导测试"), ShowType = GMMgr.GMEnum[1],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[5], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("消息队列开关"), ShowType = GMMgr.GMEnum[3],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("显示物理材质"), ShowType = GMMgr.GMEnum[1],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("设置ShadowBias"), ShowType = GMMgr.GMEnum[1],CmdList = "client SetShadowBias",  IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("设置ShadowSlopeBias"), ShowType = GMMgr.GMEnum[1],CmdList = "client SetShadowSlopeBias",  IsServerCmd = 0, IsAutoSend = 0 },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("预览模型到Socket"), ShowType = GMMgr.GMEnum[1],CmdList = "client PreviewMeshToSocket",  IsServerCmd = 0, IsAutoSend = 0 },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("激活时尚配饰"), ShowType = GMMgr.GMEnum[1],CmdList = "client ActiveOrnamentByID",  IsServerCmd = 0, IsAutoSend = 0 },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("设置MExtraShadowBias"), ShowType = GMMgr.GMEnum[1],CmdList = "client SetMobileMobileExtraShadowBias",  IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("设置MExtraShadowSlopeBias"), ShowType = GMMgr.GMEnum[1],CmdList = "client SetMobileMobileExtraShadowSlopeBias",  IsServerCmd = 0, IsAutoSend = 0 },
    { TopLevel = GMMgr.GMEnum[1], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("重置新手引导"), ShowType = GMMgr.GMEnum[1], IsServerCmd = 0, IsAutoSend = 1 },
    { TopLevel = GMMgr.GMEnum[1], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("重置新手指南"), ShowType = GMMgr.GMEnum[1], IsServerCmd = 0, IsAutoSend = 1 },
    { Desc = LSTR("清除Roll奖励列表"), ShowType = GMMgr.GMEnum[1],  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("模拟邮件内打开收礼界面1"), ShowType = GMMgr.GMEnum[1],  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("模拟邮件内打开收礼界面2"), ShowType = GMMgr.GMEnum[1],  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("测试赠礼邮件上限"), ShowType = GMMgr.GMEnum[1], CmdList = "open activityui3",  IsServerCmd = 0, IsAutoSend = 1},

    { Desc = LSTR("邀请新人加入频道"), ShowType = GMMgr.GMEnum[1],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("加入新人频道"), ShowType = GMMgr.GMEnum[1],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("退出新人频道"), ShowType = GMMgr.GMEnum[1], CmdList = "", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("新人频道发言考核"), ShowType = GMMgr.GMEnum[1], CmdList = "", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("移除目标出新人频道"), ShowType = GMMgr.GMEnum[1], CmdList = "", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("机遇-开启1号玩法"), ShowType = GMMgr.GMEnum[1],CmdList = "entertain gate start 1", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("机遇-结束当前轮次"), ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("机遇-结算"), ShowType = GMMgr.GMEnum[1],CmdList = "entertain gate play 1",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("机遇-报名"), ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("机遇-打印后台状态"), ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("打印Str"), ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("初始副本显示UI"), ShowType = GMMgr.GMEnum[1],CmdList = "",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("运输陆行鸟NPC查询"), ShowType = GMMgr.GMEnum[3], DefaultValue = 0, IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("运输陆行鸟地图"), ShowType = GMMgr.GMEnum[1],CmdList = "open ChocoboTrasportMap",  IsServerCmd = 0, IsAutoSend = 1},
    { TopLevel = GMMgr.GMEnum[20], SecondLevel = GMMgr.GMEnum[23], Desc = LSTR("打印起点终点"), ShowType = GMMgr.GMEnum[1],CmdList = "client printnavmesh",  IsServerCmd = 1, IsAutoSend = 1},
    { Desc = LSTR("显示网络延迟"), ShowType = GMMgr.GMEnum[3], SecondLevel = GMMgr.GMEnum[10], DefaultValue = 0, IsAutoSend = 1, CmdList = "client showrtt"},
    { Desc = LSTR("打开示例蓝图"), ShowType = GMMgr.GMEnum[1], SecondLevel = GMMgr.GMEnum[10], IsAutoSend = 1, CmdList = "client showsamplepanel"},
    { Desc = LSTR("模拟断线"), ShowType = GMMgr.GMEnum[1], SecondLevel = GMMgr.GMEnum[10], IsAutoSend = 1, CmdList = "client testdisconnect"},
    { Desc = LSTR("模拟重连"), ShowType = GMMgr.GMEnum[1], SecondLevel = GMMgr.GMEnum[10], IsAutoSend = 1, CmdList = "client testreconnect"},
    { TopLevel = GMMgr.GMEnum[12], Desc = LSTR("显示地图Loading"), ShowType = GMMgr.GMEnum[1], CmdList = "client LoadingMap ", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[12], Desc = LSTR("显示Loading池"), ShowType = GMMgr.GMEnum[1], CmdList = "client LoadingPool ", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[12], Desc = LSTR("显示Loading内容"), ShowType = GMMgr.GMEnum[1], CmdList = "client LoadingView ", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[12], Desc = LSTR("模拟Loading"), ShowType = GMMgr.GMEnum[1], CmdList = "client SimulateLoading ", IsServerCmd = 0, IsAutoSend = 0},
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("新任务道具提交\n界面开关"), ShowType = GMMgr.GMEnum[3], IsServerCmd = 0, IsAutoSend = 1 },
    { TopLevel = GMMgr.GMEnum[4], SecondLevel = GMMgr.GMEnum[10], Desc = LSTR("旅行笔记全解锁"), ShowType = GMMgr.GMEnum[3], IsServerCmd = 0, IsAutoSend = 1 },
    { TopLevel = GMMgr.GMEnum[19], SecondLevel= LSTR("地图"), Desc = LSTR("地图分线列表模拟"), ShowType = GMMgr.GMEnum[1], CmdList = "client pworldlinelist", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("玩法布点可视化"), ShowType = GMMgr.GMEnum[3], DefaultValue = 0, IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("部队署名邀请"), TopLevel = GMMgr.GMEnum[19], SecondLevel = "部队",ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.ArmyMgr:SendGroupSignInvite(RoleID)", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("输出所有红点路径"), TopLevel = GMMgr.GMEnum[19], SecondLevel = "红点",ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.RedDotMgr:PrintAllRedDotName()", IsServerCmd = 0, IsAutoSend = 1},
    { Desc = LSTR("修改战斗信息发送上限"), TopLevel = GMMgr.GMEnum[4], SecondLevel = "测试",ShowType = GMMgr.GMEnum[1], CmdList = "client SysChatMsgBattleLimit [条数]", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = LSTR("测试战斗信息"), TopLevel = GMMgr.GMEnum[4], SecondLevel = "测试",ShowType = GMMgr.GMEnum[1], CmdList = "client AddSysChatMsgBattle [条数] [条数]", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = "release版本调时间", TopLevel = GMMgr.GMEnum[19], SecondLevel = "时间&天气",ShowType = GMMgr.GMEnum[1], CmdList = "lua _G.GMMgr:TimeGM()", IsServerCmd = 0, IsAutoSend = 1},
--[[
    { Desc = "激活在线状态", TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], CmdList = "client OnlineStatusSet ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = "取消在线状态", TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], CmdList = "client OnlineStatusReset ", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = "展示所有在线状态", TopLevel = GMMgr.GMEnum[4], SecondLevel= GMMgr.GMEnum[10], ShowType = GMMgr.GMEnum[1], CmdList = "client OnlineStatusShow", IsServerCmd = 0, IsAutoSend = 0},
    { Desc = "仙人仙彩主界面", ShowType = GMMgr.GMEnum[1],CmdList = "open activityui",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "仙人仙彩兑换界面", ShowType = GMMgr.GMEnum[1],CmdList = "open activityui2",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "仙人仙彩中奖履历界面", ShowType = GMMgr.GMEnum[1],CmdList = "open activityui3",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "查看购买人数奖励", ShowType = GMMgr.GMEnum[1],CmdList = "open activityui4",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "查看一等奖号码、期数", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "清空仙人仙彩全部数据", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "清空本角色当期购买记录", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "查看当前玩法服时间", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "机遇-开启1号玩法", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "机遇-结束当前轮次", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "机遇-报名", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    { Desc = "机遇-打印后台状态", ShowType = GMMgr.GMEnum[1],CmdList = "entertain time now",  IsServerCmd = 0, IsAutoSend = 1},
    --[[
    { Desc = "显示/隐藏UI", ShowType = GMMgr.GMEnum[3], DefaultValue = 1},
    { Desc = "UI性能参数", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "重置相机", ShowType = GMMgr.GMEnum[1]},
    { Desc = "显示/隐藏调试信息", ShowType = GMMgr.GMEnum[3], DefaultValue = 1},
    { Desc = "开启/关闭相机环绕", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "重载DB", ShowType = GMMgr.GMEnum[1]},
    { Desc = "显示客户端坐标", ShowType = GMMgr.GMEnum[1]},
    { Desc = "显示/关闭选中描边", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "显示/关闭四方向角色环绕", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "重载CameraMode配置", ShowType = GMMgr.GMEnum[1]},
    { Desc = "播放音频", ShowType = GMMgr.GMEnum[1]},
    { Desc = "配置RTPC值", ShowType = GMMgr.GMEnum[1], CmdList = "client SetRTPCValue name value", IsServerCmd = 1, IsAutoSend = 0},
    { Desc = "测试开始", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[1]},
    { Desc = "开始挂机", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[1]},
    { Desc = "结束挂机", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[1]},
    { Desc = "开启/关闭特效显示", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 1},
    { Desc = "重置UI", ShowType = GMMgr.GMEnum[1]},
    { Desc = "移动打断预输入", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "特效LOD", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 1},
    { Desc = "特效数据收集", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "特效屏占比收集", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "特效实时LOD信息", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "PSO采集", ShowType = GMMgr.GMEnum[3], DefaultValue = _G.UE.UFlibShaderPipelineCacheHelper.IsEnabledLogPSO() and 1 or 0},
    { Desc = "PSO自动保存", ShowType = GMMgr.GMEnum[3], DefaultValue = _G.UE.UFlibShaderPipelineCacheHelper.IsEnabledSaveBoundPSOLog() and 1 or 0},
    { Desc = "保存PSO数据", ShowType = GMMgr.GMEnum[1]},
    { Desc = "特效屏占比剔除", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "特效测试一点就崩", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "角色LOD", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "角色LOD屏占比", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
    { Desc = "查看特效信息", TopLevel = "性能测试", SecondLevel = "常用1", ShowType = GMMgr.GMEnum[1]},
    { Desc = "服务器ping", ShowType = GMMgr.GMEnum[3], DefaultValue = 0},
--]]
}

local function CreateWwiseViewer(WorldContextObject, TitleText, Position, bShowActorEventOnly)
    local UMG_WWiseEventViewer_C = _G.UE.UClass.Load("/Game/UI/BP/GM/Audio/UMG_WWiseEventViewer.UMG_WWiseEventViewer_C")
    local AudioEventViewer = _G.UE.UWidgetBlueprintLibrary.Create(WorldContextObject, UMG_WWiseEventViewer_C)
    AudioEventViewer:AddToViewport()
    AudioEventViewer.bShowActorEventOnly = bShowActorEventOnly
    AudioEventViewer.TitleText = TitleText
    AudioEventViewer:OnShow()

    if Position then
        UIUtil.CanvasSlotSetPosition(AudioEventViewer.MainPanel, Position)
    end

    return AudioEventViewer
end

local function AudioEventViewerSwitchVisible(AudioEventViewer)
    if UIUtil.IsVisible(AudioEventViewer) then
        UIUtil.SetIsVisible(AudioEventViewer, false)
        AudioEventViewer:OnHide()
    else
        UIUtil.SetIsVisible(AudioEventViewer, true)
        AudioEventViewer:OnShow()
    end
end

function GMMainView:DoClientClick(Params)
    local Desc = Params.DescCN
    local DescSplit = string.split(Desc, " ")
    local CmdSplit = string.split(Params.CmdList, " ")

    _G.FLOG_INFO("DoClientClick!!!!!!!!!!! Desc=%s,CmdSplit[1]=%s", Desc,CmdSplit[1])
    if CmdSplit[1] == "lua" then
        print("CmdList", Params.CmdList)
        GMMgr:ReqGM(Params.CmdList, Params)
        return
    end

    if Desc == nil or Desc == "" then
        return
    end

    if Desc == LSTR("幻卡默认开局") then
        GMMgr:ReqGM("lua MagicCardMgr:SendNpcFantasyCard(29000009)")
    elseif Desc == LSTR("幻卡编辑界面") then
        GMMgr:ReqGM("lua UIViewMgr:ShowView(2212)")
    elseif Desc == "FOV" then
        --BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
        --UIViewMgr:ShowView(UIViewID.SkillButton)
        UIViewMgr:ShowView(UIViewID.FOVView)
        UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("显示/隐藏UI") then
        if UIViewMgr:IsViewVisible(UIViewID.MainPanel) then
            _G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
            UIViewMgr:HideView(UIViewID.SkillButton)
            --UIViewMgr:HideView(UIViewID.PWorldMainPanel)
        else
            _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
            UIViewMgr:ShowView(UIViewID.SkillButton)
        end
    elseif Desc == LSTR("UI性能参数") then
        if UIViewMgr:IsViewVisible(UIViewID.SimplePerf) then
            UIViewMgr:HideView(UIViewID.SimplePerf)
        else
            UIViewMgr:ShowView(UIViewID.SimplePerf)
        end
    elseif Desc == LSTR("重置相机") then
        local Major = MajorUtil.GetMajor();
        Major:GetCameraControllComponent():ResetSpringArm()

    elseif Desc == LSTR("显示/隐藏调试信息") then
        GMMgr:SwitchShowDebugTips()

    elseif Desc == LSTR("开启/关闭相机环绕") then
        local Major = MajorUtil.GetMajor();
        Major:GetCameraControllComponent():SwitchAutoSurround();

    elseif Desc == LSTR("重载DB") then
        DBMgr.ReloadDataBase();

    elseif Desc == LSTR("显示客户端坐标") then
        local Major = MajorUtil.GetMajor();
        local MajorPos = Major:FGetActorLocation();
        local StrPos = "Major Client Pos : (x=" .. MajorPos.X .. ", y=" .. MajorPos.Y .. ", z=" .. MajorPos.Z .. ")";
        local Result = table_to_string(StrPos)
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. Result .. "\n"
        self:UpdateGMHistory()

    elseif Desc == LSTR("显示/关闭选中描边") then
        GMMgr:SwitchShowSelectOutline()

    elseif Desc == LSTR("显示/关闭四方向角色环绕") then
        local MajorController = MajorUtil.GetMajorController();
        MajorController.EnableFourDirMove = not MajorController.EnableFourDirMove;

    elseif Desc == LSTR("重载CameraMode配置") then
        local Major = MajorUtil.GetMajor();
        Major:GetCameraControllComponent():ReloadCameraModeDataAsset();

    elseif Desc == LSTR("播放音频") then
        UIUtil.SetIsVisible(self.GMPlayAudio_UIBP, true)

    elseif Desc == LSTR("显示音频列表") then
        if self.GlobalAudioEventViewer == nil then
            self.GlobalAudioEventViewer = CreateWwiseViewer(self, "Global", nil, false)
            return
        end

        AudioEventViewerSwitchVisible(self.GlobalAudioEventViewer)

    elseif Desc == LSTR("显示选中对象的音频列表") then
        if self.ActorAudioEventViewer == nil then
            self.ActorAudioEventViewer = CreateWwiseViewer(self, "SelectedActor", _G.UE.FVector2D(-340, -390), true)
            return
        end

        AudioEventViewerSwitchVisible(self.ActorAudioEventViewer)

    elseif Desc == LSTR("显示音频位置") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        local UAudioMgr = _G.UE.UAudioMgr.Get()
        if SwitchValue == 1 then
            UAudioMgr:SetDrawDebugPos(true)
        else
            UAudioMgr:SetDrawDebugPos(false)
        end
    elseif Desc == LSTR("配置RTPC值") then
        GMMainView:OnSubmitHandle() -- 默认Text部分已填写

    elseif Desc == LSTR("开始挂机") then
        GMMgr:StartAutoFight()

    elseif Desc == LSTR("结束挂机") then
        GMMgr:EndAutoFight()

    elseif Desc == LSTR("测试开始") then
        GMMgr:CaptainStart()

    elseif Desc == LSTR("重置UI") then
        EventMgr:SendEvent(EventID.ResetDragUI)

    elseif Desc == LSTR("移动打断预输入") then
        _G.SkillPreInputMgr:SetMoveBreak(GMMgr:GetCacheValue(Params.ID))
    elseif Desc == LSTR("PSO采集") then
        _G.UE.UFlibShaderPipelineCacheHelper.EnableLogPSO(GMMgr:GetCacheValue(Params.ID))
    elseif Desc == LSTR("PSO自动保存") then
        _G.UE.UFlibShaderPipelineCacheHelper.EnableSaveBoundPSOLog(GMMgr:GetCacheValue(Params.ID))
    elseif Desc == LSTR("保存PSO数据") then
        _G.UE.UFlibShaderPipelineCacheHelper.SavePipelineFileCache(1)
    elseif Desc == LSTR("角色LOD") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UActorManager:Get().bEnableCharacterLOD = true
        else
            _G.UE.UActorManager:Get().bEnableCharacterLOD = false
        end
    elseif Desc == LSTR("角色LOD屏占比") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UActorManager:Get().bEnableCharacterLODSceneSize = true
        else
            _G.UE.UActorManager:Get().bEnableCharacterLODSceneSize = false
        end
    elseif Desc == LSTR("服务器ping") then
        _G.PING_SHOW = GMMgr:GetCacheValue(Params.ID)
    elseif Desc == LSTR("音效广播同步") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UAudioMgr:Get().bIsPlaySound = true
        else
            _G.UE.UAudioMgr:Get().bIsPlaySound = false
        end
    elseif CmdSplit[1] == "client" and CmdSplit[2] == "switch" and CmdSplit[3] ~= nil then
        local SpecialMaterialTest = require("Game/Test/SpecialMaterialTest")
        local Param1 = CmdSplit[3] or " "
        SpecialMaterialTest.SwitchMaterial(Param1, GMMgr:GetCacheValue(Params.ID))
    elseif Desc == LSTR("播放测试Sequence") then
        _G.UE.UCameraMgr:PlayLevelSequence("MaterialPerformanceTestingSequence")
    elseif Desc == LSTR("技能模块Debug") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.SkillLogicMgr.ShowSkillDebug = true
        else
            _G.SkillLogicMgr.ShowSkillDebug = false
        end
    elseif DescSplit[1] == GMMgr.GMEnum[4] and string.split(Params.CmdList, " ")[2] == "switch" then
        local SpecialMaterialTest = require("Game/Test/SpecialMaterialTest")
        local SplitList = string.split(Params.CmdList, " ")
        if SplitList[1] == "client" and SplitList[2] == "switch" and SplitList[3] == "character" then
            local Param1 = SplitList[4] or " "
            SpecialMaterialTest.SwitchCharacter(Param1)
        end
    elseif Desc == LSTR("系统配置") then
        _G.UIViewMgr:ShowView(UIViewID.CfgMainPanel)
        --_G.UIViewMgr:CreateView(UIViewID.CfgMainPanel)

    elseif Desc == LSTR("暂停对白Sequence") then
        _G.StoryMgr:PauseSequence()

    elseif Desc == LSTR("停止对白Sequence") then
        _G.StoryMgr:StopSequence()

    elseif Desc == LSTR("暂停或播放天气Sequence") then
        local World = FWORLD()
        _G.UE.UTodUtils.ToggleWeatherPlayStatus(World)

    elseif Desc == LSTR("关闭BGM") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        local UAudioMgr = _G.UE.UAudioMgr.Get()
        if SwitchValue == 1 then
            UAudioMgr:SetAudioVolume(_G.UE.EWWiseAudioType.Music, 0)
        else
            UAudioMgr:SetAudioVolume(_G.UE.EWWiseAudioType.Music, 100)
        end


    elseif Params.CmdList == "client create equipment" then
        local SpecialMaterialTest = require("Game/Test/SpecialMaterialTest")
        SpecialMaterialTest.CreateEquipmentCharacter()
    elseif Params.CmdList == "client merge equipment" then
        local SpecialMaterialTest = require("Game/Test/SpecialMaterialTest")
        SpecialMaterialTest.MergeEquipmentCharacter()
    elseif Desc == LSTR("受击表现相关日志") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UActorManager:Get().bSuperArmorLog = true
        else
            _G.UE.UActorManager:Get().bSuperArmorLog = false
        end
    elseif Desc == LSTR("装备测试入口") then
        UIViewMgr:ShowView(UIViewID.EquipmentMainPanel)

    elseif Desc == LSTR("显示染色图") then
         UIViewMgr:ShowView(UIViewID.PWorldAreaImageTest)
         UIViewMgr:HideView(UIViewID.GMMain)

    elseif Desc == LSTR("绘制标尺") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UActorManager:Get().bDrawRuler = true
        else
            _G.UE.UActorManager:Get().bDrawRuler = false
        end
    elseif Desc == LSTR("角色缓存数量") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UTestMgr:Get().bShowCacheNum = true
        else
            _G.UE.UTestMgr:Get().bShowCacheNum = false
        end

    elseif Desc == LSTR("空气墙网格") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UTestMgr:Get().bShowBlockingVolumeMesh = true
        else
            _G.UE.UTestMgr:Get().bShowBlockingVolumeMesh = false
        end
    elseif Desc == LSTR("大水晶传送") then
        local SplitList = string.split(Params.CmdList, " ")
        if SplitList[1] == "client" and SplitList[2] == "CrystalPortalTrans" then
            local Param1 = tonumber(SplitList[3])
            if Param1 then
                _G.PWorldMgr:GetCrystalPortalMgr():TransferByMap(Param1)
            end
        end
    elseif Desc == LSTR("创建ColorCalibrator") then
        local ColorCalibratorPath = "StaticMesh'/Engine/EditorMeshes/ColorCalibrator/SM_ColorCalibrator.SM_ColorCalibrator'"
        local Obj = _G.ObjectMgr:LoadObjectSync(ColorCalibratorPath, ObjectGCType.LRU)
        local Actor = CommonUtil.SpawnActor(_G.UE.AStaticMeshActor.StaticClass(), MajorUtil.GetMajor():FGetActorLocation() + MajorUtil.GetMajor():GetActorForwardVector() * 100)
        Actor.StaticMeshComponent:SetCollisionEnabled(_G.UE.ECollisionEnabled.NoCollision)
        Actor:SetMobility(_G.UE.EComponentMobility.Movable)
        Actor.StaticMeshComponent:SetStaticMesh(Obj)
    elseif Desc == LSTR("TA测试窗口") then
        _G.UIViewMgr:ShowView(UIViewID.TATestPanel)
        self:Hide()
    elseif Desc == LSTR("特效副本重置位置") then
        _G.UE.UTestMgr.Get():ResetMajorPos()
    elseif Desc == LSTR("设置ZoomSpeed") then
        _G.FLOG_ERROR(Params.CmdList)
        local SplitList = string.split(Params.CmdList, " ")
        if SplitList[1] == "client" and SplitList[2] == "SetZoomSpeed" then
            local Param1 = tonumber(SplitList[3])
            if Param1 then
                local Major = MajorUtil.GetMajor()
                local CamCtrComp = Major:GetCameraControllComponent()
                CamCtrComp:SetZoomSpeed(Param1)
            end
        end
    elseif Desc == LSTR("设置InterpSpeed") then
        local SplitList = string.split(Params.CmdList, " ")
        if SplitList[1] == "client" and SplitList[2] == "SetInterpSpeed" then
            local Param1 = tonumber(SplitList[3])
            if Param1 then
                local Major = MajorUtil.GetMajor()
                local CamCtrComp = Major:GetCameraControllComponent()
                CamCtrComp:SetZoomInterpolation_InterpSpeed(Param1)
            end
        end
    elseif Desc == LSTR("设置InterpSpeedToInterpolation") then
        local SplitList = string.split(Params.CmdList, " ")
        if SplitList[1] == "client" and SplitList[2] == "SetInterpSpeedToInterpolation" then
            local Param1 = tonumber(SplitList[3])
            if Param1 then
                local Major = MajorUtil.GetMajor()
                local CamCtrComp = Major:GetCameraControllComponent()
                CamCtrComp:SetZoomInterpolation_InterpSpeedToInterpolation(Param1)
            end
        end
    elseif Desc == LSTR("设置ResetInterpSpeedTolerance") then
        local SplitList = string.split(Params.CmdList, " ")
        if SplitList[1] == "client" and SplitList[2] == "SetResetInterpSpeedTolerance" then
            local Param1 = tonumber(SplitList[3])
            if Param1 then
                local Major = MajorUtil.GetMajor()
                local CamCtrComp = Major:GetCameraControllComponent()
                CamCtrComp:SetZoomInterpolation_ResetInterpSpeedTolerance(Param1)
            end
        end
    elseif Desc == LSTR("强制主角特效LOD0") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        local LOD = 0
        if SwitchValue == 1 then
            LOD = -127
        end
        _G.UE.EffectLODSlover.CommonDefineLOD.MajorEffectLOD = LOD
    elseif LSTR("显示目标ai信息") == Desc then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MainPanel) then
            if _G.UIViewMgr:IsViewVisible(_G.UIViewID.GMMonsterAIInfo) then
                _G.UIViewMgr:HideView(_G.UIViewID.GMMonsterAIInfo)
            else
                _G.UIViewMgr:ShowView(_G.UIViewID.GMMonsterAIInfo)
            end
        end
    elseif LSTR("目标监控") == Desc then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MainPanel) then
            if _G.UIViewMgr:IsViewVisible(_G.UIViewID.GMTargetInfo) then
                _G.UIViewMgr:HideView(_G.UIViewID.GMTargetInfo)
            else
                _G.UIViewMgr:ShowView(_G.UIViewID.GMTargetInfo)
            end
        end
    elseif LSTR("打印技能按钮状态") == Desc then
        local Msg = _G.SkillLogicMgr:PrintMajorButtonState()
        print(Msg)
        table.insert(GMMgr.GMStringList, Desc)
        GMMgr.GMIndex = #GMMgr.GMStringList
        GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\nGM: " .. Desc .. "\n" .. Msg
        self:UpdateGMHistory()
	elseif Desc == LSTR("头盔机关") then
		local SwitchValue = GMMgr:GetCacheValue(Params.ID)
		local Major = MajorUtil.GetMajor()
		if SwitchValue == 1 then
			Major:SwitchHelmet(true)
		else
			Major:SwitchHelmet(false)
		end
    elseif Desc == LSTR("取消LookAt限制") then
        local Major = MajorUtil.GetMajor()
        local AnimComp = Major:GetAnimationComponent()
        if AnimComp then
            AnimComp:SetLookAtLimit()
        end
    elseif Desc == LSTR("LookAt日志开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UActorManager:Get().bLookAtLog = true
        else
            _G.UE.UActorManager:Get().bLookAtLog = false
        end
	elseif Desc == LSTR("充值") then
		_G.RechargingMgr:ShowMainPanel()
    elseif Desc == LSTR("查看一等奖号码、期数") then
        GMMgr:ReqGM("entertain fairycolor shownum")
    elseif Desc == LSTR("清空仙人仙彩全部数据") then
        GMMgr:ReqGM("entertain fairycolor clear")
    elseif Desc == LSTR("仙人仙彩开奖") then
        GMMgr:ReqGM("entertain fairycolor open")
    elseif Desc == LSTR("邀请新人加入频道") then
        local RoleID = ActorUtil.GetRoleIDByEntityID(_G.HUDMgr.TargetEntityID)
        _G.NewbieMgr:InviteJoinNewbieChannelReq(RoleID)
        --_G.ChatMgr:InviteJoinNewbieChannelNtf(nil)
    elseif Desc == LSTR("加入新人频道") then
        _G.NewbieMgr:JoinChannelReq()
    elseif Desc == LSTR("新人频道发言考核") then
        _G.NewbieMgr:StartNewbieSpeakEvaluation()
    elseif Desc == LSTR("移除目标出新人频道") then
        local RoleID = ActorUtil.GetRoleIDByEntityID(_G.HUDMgr.TargetEntityID)
        _G.NewbieMgr:EvictNewbieChannel(RoleID)

    elseif Desc == LSTR("清空本角色当期购买记录") then
        GMMgr:ReqGM("entertain fairycolor delrecord")
    elseif Desc == LSTR("查看当前玩法服时间") then
        GMMgr:ReqGM("entertain time now")
    elseif Desc == LSTR("仙人仙彩开奖") then
        GMMgr:ReqGM("entertain fairycolor open")
    elseif Desc == LSTR("机遇-开启1号玩法") then
        GMMgr:ReqGM("entertain gate start 1")
    elseif Desc == LSTR("机遇-结束当前轮次") then
        GMMgr:ReqGM("entertain gate end")
    elseif Desc == LSTR("机遇-结算") then
        _G.GoldSauserMgr:SendEndGameReq(0, false)
        -- GMMgr:ReqGM("entertain gate play 1")
    elseif Desc == LSTR("机遇-报名") then
        GMMgr:ReqGM("entertain gate signup")
    elseif Desc == LSTR("机遇-发送报名") then
        _G.GoldSauserMgr:SendSignUpGame()
    elseif Desc == LSTR("机遇-打印后台状态") then
        GMMgr:ReqGM("entertain gate show")
    elseif Desc == LSTR("查询时尚品鉴主题") then
        _G.FashionReportMgr:SendFashionCheckQueryThemeReq()
    elseif Desc == LSTR("时尚品鉴评分") then
        _G.FashionReportMgr:SendFashionCheckIsOpenReq()
    elseif Desc == LSTR("时尚评鉴确认最高分") then
        _G.FashionReportMgr:SendFashionConfirmHighScoreEqiu()
    elseif Desc == LSTR("解锁所有系统(表现)") then
		local ModuleopenCfg = require("TableCfg/ModuleopenCfg")
		local ModuleopenAllCfg = ModuleopenCfg:FindAllCfg()
        for i = 1, #ModuleopenAllCfg do
            GMMgr:ReqGM(string.format("%s%d", "zone moduleopen open ", i))
        end
    elseif Desc == LSTR("收藏品界面") then
        _G.UIViewMgr:ShowView(UIViewID.CollectablesMainPanelView)
        UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("莫古抓球机界面") then
        _G.GoldSaucerMiniGameMgr:InteractEnterTheGoldSaucerMiniGame(GoldSaucerMiniGameDefine.MiniGameType.MooglesPaw)
        UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("矿脉探索界面") then
        _G.GoldSaucerMiniGameMgr:InteractEnterTheGoldSaucerMiniGame(GoldSaucerMiniGameDefine.MiniGameType.TheFinerMiner)
        UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("孤树无援界面") then
        _G.GoldSaucerMiniGameMgr:InteractEnterTheGoldSaucerMiniGame(GoldSaucerMiniGameDefine.MiniGameType.OutOnALimb)
        UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("旅行笔记界面") then
        UIViewMgr:ShowView(UIViewID.TravelLogPanel)
    elseif Desc == LSTR("初始副本显示UI") then
        _G.EventMgr:SendEvent(EventID.ShowSubViews)
    elseif Desc == LSTR("运输陆行鸟NPC查询") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.ChocoboTransportMgr:SetQuestNpcQueryEnable(SwitchValue == 1)
    elseif Desc == LSTR("运输陆行鸟地图") then
        UIViewMgr:ShowView(UIViewID.ChocoboTransportPanel)
    elseif Desc == LSTR("新手引导开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 0 then -- 关
            SettingsUtils.SettingsTabUnCategory:SetTutorialState(1, true)
        elseif SwitchValue == 1 then --- 开
            SettingsUtils.SettingsTabUnCategory:SetTutorialState(2, true)
        end
    elseif Desc == LSTR("重置新手引导") then
        _G.NewTutorialMgr:ClearTutorialSchedule()
    elseif Desc == LSTR("重置新手指南") then
        _G.TutorialGuideMgr:ClearTutorialGuide()
    elseif Desc == LSTR("启用新手引导") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.NewTutorialMgr:EnableGMTutorial(SwitchValue)
        _G.TutorialGuideMgr:EnableGMTutorial(SwitchValue)
    elseif Desc == LSTR("钓鱼笔记钓场位置调整") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.FishNotesMgr.FishingholePosAdjustGM = SwitchValue == 1
    elseif Desc == LSTR("制作快捷道具") then
        _G.FLOG_INFO("PreSendEvent%s", EventID.CraftingLogConvenient)
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.EventMgr:SendEvent(EventID.CraftingLogConvenient, SwitchValue)
        _G.FLOG_INFO("AlreadySendEvent(%s, %s)",EventID.CraftingLogConvenient, SwitchValue)
    elseif Desc == LSTR("副本任务") then
        _G.PWorldQuestMgr:ShowPWQuestView()
    elseif Desc == LSTR("副本入口") then
        -- UIViewMgr:ShowView(UIViewID.PWorldEntranceSelectPanel)
    elseif Desc == LSTR("挂机测试") then
        local BeginTime = TimeUtil.GetLocalTime() - 15 * 60
        _G.ClientReportMgr:SendClientReport(ClientReportType.ReportTypeRoleLeave, {Leave = {BeginTime = BeginTime}})
    elseif Desc == LSTR("地图资源检测") then
        UIViewMgr:ShowView(UIViewID.FieldTestPanel)
        self:Hide()
    elseif Desc == LSTR("信息自动化") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.MultiLanguageTestPanel,{ViewType = LSTR("信息自动化")})
    elseif Desc == LSTR("实体创建") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.MultiLanguageTestPanel,{ViewType = LSTR("实体创建")})
    elseif Desc == LSTR("蓝图检查") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.MultiLanguageTestPanel,{ViewType = LSTR("蓝图检查")})        
    elseif Desc == LSTR("传送至追踪任务目标") then
        local Cmd = _G.QuestTrackMgr:MakeGMQuestTeleportCmd()
        if Cmd then
            self.InputText:SetText(Cmd)
            self:OnSubmitHandle()
        end
    elseif Desc == LSTR("推荐任务一键置新") then
        -- _G.EventMgr:SendEvent(EventID.RecommendTaskNewTip)
        _G.AdventureRecommendTaskMgr:DoGM()

    elseif Desc == LSTR("清除Roll奖励列表") then
        _G.TeamRollItemVM.AwardList:Clear()
    elseif Desc == LSTR("打开新手指南") then
        _G.TutorialGuideMgr:OpenGMGuide()
    elseif Desc == "清除Roll奖励列表" then
    elseif Desc == LSTR("称号界面") then
        _G.UIViewMgr:ShowView(UIViewID.TitleMainPanelView)
        UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("监修测试开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        MainPanelVM:OnTestVersionChanged(SwitchValue > 0)
    elseif Desc == LSTR("地图参数开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.WorldMapMgr:ShowDebugInfo(SwitchValue > 0)
        _G.FishNotesMgr:ShowDebugInfo(SwitchValue > 0)
    elseif Params.CmdList == "client pworldlinelist" then
        local LineList = {}
        for i = 1, 20 do
            local Line = { LineID = i, PlayerNum = i, InstID = 0 }
            table.insert(LineList, Line)
        end
        local PWorldLineQueryRsp = { Lines = LineList, PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()  }
        local MsgBody = { LineQuery = PWorldLineQueryRsp }
        _G.PWorldMgr:OnPWorldLineQuery(MsgBody)
        _G.UIViewMgr:ShowView(_G.UIViewID.PWorldBranchPanel)
    elseif Desc == LSTR("消息队列开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.TipsQueueMgr:EnableUseQueue(SwitchValue > 0)
    elseif Desc == LSTR("地图自动寻路") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.WorldMapMgr.OpenMapAutoPath = SwitchValue > 0
    elseif Desc == LSTR("模拟邮件内打开收礼界面1") then
		local Param = {
			FriendID = 6508238788987404920,
			GoodID = 10001,
			GiftMessage = "这里是装饰赠言",
			GiftNum = 1,
			Style = 1
		}
		_G.StoreMainVM:OnShowGiftMailPanel(true, Param)
	elseif Desc == LSTR("模拟邮件内打开收礼界面2") then
		local Param = {
			FriendID = 6508238788987404920,
			GoodID = 40001,
			GiftMessage = "这里是道具赠言",
			GiftNum = 15,
			Style = 1
		}
		_G.StoreMainVM:OnShowGiftMailPanel(true, Param)
    elseif Desc == LSTR("显示副本教学界面") then
        _G.TeachingMgr:OnShowMainWindow()
    elseif Desc == LSTR("副本教学引导测试") then
        --_G.TeachingMgr:OnShowPWorldGuideTip(106)
        _G.EventMgr:SendEvent(_G.EventID.PWorldSkillTip,101)
		--_G.MsgTipsUtil.ShowPWorldTeachingTips(LSTR("观察预警范围，躲避伤害"), 3)
		--_G.MsgTipsUtil.ShowPWorldResultTips(LSTR("挑战失败"), 3, false)
        _G.UIViewMgr:HideView(UIViewID.GMMain)
    elseif Desc == LSTR("显示网络延迟") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.EventMgr:SendEvent(_G.EventID.GMShowRTT, SwitchValue ~= 0)
    elseif Desc == LSTR("打开示例蓝图") then
        UIViewMgr:ShowView(UIViewID.SampleMain)
    elseif Desc == LSTR("模拟断线") then
        _G.NetworkStateMgr.TestDisconnect()
    elseif Desc == LSTR("模拟重连")then
        _G.NetworkStateMgr.TestReconnect()
    elseif Desc == LSTR("测试赠礼邮件上限") then
		local RoleID = MajorUtil.GetMajorRoleID()
		local GMStr = string.format("%s%d%s%d%s%d%s", "zone mail sendMxRoleMail 2 ",RoleID, " ", RoleID, " ", RoleID," 40001 20")
		GMMgr:ReqGM(GMStr)
    elseif Desc == LSTR("显示物理材质") then
        local Major = MajorUtil.GetMajor()
        local CamComp = Major:GetComponentByClass(_G.UE.UActorAudioComponent)
        _G.UE.UTestMgr:Get():PhysicsOnFeetFocusActor(Major);
        _G.UE.UTestMgr:Get():ChangeDisplayPhysicsOnFeet();
        return
    elseif Desc == LSTR("使用艾欧泽亚文字") then
        ---若处于英文环境，则全局替换艾欧泽亚字体，其他语言环境会发生乱码
        if CommonUtil.IsCurCultureEnglish() then
            _G.UIViewMgr:SetUseAzerothFont(true)
            _G.HUDMgr:SetAllHUDFontForAozy(true)
        end
        return
    elseif Desc == LSTR("主角同步点绘制开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UActorManager:Get().bDrawSynPos = true
        else
            _G.UE.UActorManager:Get().bDrawSynPos = false
        end
    elseif Desc == LSTR("主角速度显示开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        if SwitchValue == 1 then
            _G.UE.UTestMgr:Get():GMSetDisplaySpeed(true)
        else
            _G.UE.UTestMgr:Get():GMSetDisplaySpeed(false)
        end
    elseif Desc == LSTR("新任务道具提交\n界面开关") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        local ItemSubmitVM = require("Game/Quest/VM/PanelVM/ItemSubmitVM")
        ItemSubmitVM.IsNewStypeUI = SwitchValue > 0
    elseif Desc == LSTR("旅行笔记全解锁") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.TravelLogMgr.IsTempTest = SwitchValue
    elseif Desc == LSTR("玩法布点可视化") then
        local SwitchValue = GMMgr:GetCacheValue(Params.ID)
        _G.MapMgr:SetGameplayLocationVisible(SwitchValue == 1)
    elseif Desc == LSTR("开启交互日志") then
        _G.InteractiveMgr:SetEnablePrintNormalLog(true)
    elseif Desc == LSTR("关闭交互日志") then
        _G.InteractiveMgr:SetEnablePrintNormalLog(false)
    elseif Desc == LSTR("启动潘多拉组件") then
        _G.PandoraMgr:SetEnableGamelet()
        _G.PandoraMgr:CloseGameletSDK()
        _G.PandoraMgr:InitGamelet(_G.LoginMgr:GetChannelID(), "3903467765502703339", _G.LoginMgr:GetRoleID(), false, true)
    elseif Desc == LSTR("打开拍脸") then
        _G.PandoraMgr:OpenFaceSlapApp()
    elseif Desc == LSTR("打开资讯") then
        _G.PandoraMgr:OpenAnnouncement()
    elseif Desc == LSTR("分享到小程序") then
        _G.ShareMgr:ShareCrystalSummon("", "")
    elseif Desc == LSTR("特效监控") then
        GMMgr:ReqGM(Params.CmdList)
    elseif Desc == LSTR("NPC对话") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.NarrativeTestPanel,{ViewType = LSTR("NPC对话")})
    elseif Desc == LSTR("动画文本") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.NarrativeTestPanel,{ViewType = LSTR("动画文本")})
    elseif Desc == LSTR("任务追踪") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.NarrativeTestPanel,{ViewType = LSTR("任务追踪")})
    elseif Desc == LSTR("CustomTalk") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.NarrativeTestPanel,{ViewType = LSTR("CustomTalk")})
    elseif Desc == LSTR("对话选项") then
        UIViewMgr:HideView(UIViewID.GMMain)
        UIViewMgr:ShowView(UIViewID.NarrativeTestPanel,{ViewType = LSTR("对话选项")})        
    else
        self:OnSubmitHandle()
	end
end

function GMMainView:AddChildrenItem(View)
    --self:AddSubView(View)
    table.insert(self.ChildrenItem, View)
end

function GMMainView:SearchCommitted()
    local AllCmd = GMMgr.GMCmdList
    local SearchText = self.CommSearchBar:GetText()
    local NewList = {}
    for i = 1, #AllCmd do
        local GMName = AllCmd[i].Desc
        local IsSame = GMMgr:SearchByInput(SearchText, GMName)
        if IsSame then
            table.insert(NewList, AllCmd[i])
        end
    end

    self.Title:SetText(LSTR("搜索结果"))
    GMVM:UpdateVM(NewList)
end

function GMMainView:SearchCancel()
    self.Title:SetText(LSTR("便携指令区域"))
    GMVM:UpdateVM(self.LastShowList)
end




--story=117104057 【GM】【新增加GM】需要GM来获取测试所要的信息，便于高效提单
--获取如下信息：
local Celltestmsg = {
    ResultNum = 0,
    DeviceType = "",    --设备类型
    DeviceID = "",      --设备ID
    MobHardware = "",   --终端机型
    MobSystem = "",     --终端系统版本
    ClientVersion = "", --客户端版本号
    ClientIP = "",      --客户端IP
    QualityLevel = "",  --画质等级
    ResVersion = "",    --服务器配置版本
    UserName = "",      --登录账号
    CharID = "",        --角色ID
    CharPos = ""        --角色坐标
}
function GMMainView:RestCelltestmsg()
    Celltestmsg.ResultNum = 0
    Celltestmsg.DeviceType = ""
    Celltestmsg.DeviceID = ""
    Celltestmsg.MobHardware = ""
    Celltestmsg.MobSystem = ""
    Celltestmsg.ClientVersion = ""
    Celltestmsg.ClientIP = ""
    Celltestmsg.QualityLevel = ""
    Celltestmsg.ResVersion = ""
    Celltestmsg.UserName = ""
    Celltestmsg.CharID = ""
    Celltestmsg.CharPos = ""
end

function GMMainView:CelltestmsgResult()
    local StrResult="{"
    .."\n设备类型="..Celltestmsg.DeviceType..","
    .."\n设备ID="..Celltestmsg.DeviceID..","
    .."\n终端机型="..Celltestmsg.MobHardware..","
    .."\n终端系统版本="..Celltestmsg.MobSystem..","
    .."\n客户端IP="..Celltestmsg.ClientIP..","
    .."\n客户端版本号="..Celltestmsg.ClientVersion..","
    .."\n画质等级="..Celltestmsg.QualityLevel..","
    .."\n服务器配置版本="..Celltestmsg.ResVersion..","
    .."\n登录账号="..Celltestmsg.UserName..","
    .."\n角色ID="..Celltestmsg.CharID..","
    .."\n角色坐标="..Celltestmsg.CharPos..","
    .."\n}"
    return StrResult
end

--拦截GM命令行cell test msg
function GMMainView:TestCellMessage(cmdText)
    if cmdText =="cell test msg" then
        self:RestCelltestmsg()
        local newText = "cell pi|cell version res"
        self:ReqGM(newText)

        --获取设备信息
        local dty = CommonUtil.GetDeviceType()                              --设备类型ios 0 android 1  2-windows，3-mac，4-其他
        local dtystr="other"
        if dty == 0 then
            dtystr = "ios"
        elseif dty == 1 then
            dtystr = "android"
        elseif dty == 2 then
            dtystr = "windows"
        elseif dty == 3 then
            dtystr = "mac"
        end
        Celltestmsg.DeviceType = dtystr
        Celltestmsg.DeviceID = _G.UE.UPlatformUtil.GetDeviceID()            -- 设备ID
        Celltestmsg.MobHardware = _G.UE.UPlatformUtil.GetDeviceName()       -- 移动终端机型
        Celltestmsg.MobSystem = _G.UE.UPlatformUtil.GetOSVersion()          -- 移动终端操作系统版本
        Celltestmsg.ClientIP = _G.UE.UPlatformUtil.GetIPAddress(false)      -- 客户端IP
        Celltestmsg.ClientVersion = _G.UE.UVersionMgr.GetAppVersion()    -- 客户端版本号

        Celltestmsg.QualityLevel = CfgEntrance.GetValue(10100)    --获取画质等级

    end
end
--字符串截取
function GMMainView:ResStr_Cut(str,s_begin,s_end)
    local rs = ""
    local s_begin_Len = string.len(s_begin)
    local s_begin_x = string.find(str, s_begin, 1)
    if s_begin_x == nil then
        return rs
    end
    local s_end_x = string.find(str, s_end, s_begin_x+1)
    if s_end_x == nil then
        return rs
    end
    rs=(string.sub(str, s_begin_x+s_begin_Len, s_end_x-1))
    return rs
end
--响应cell test message命令的回调函数，将消息封装好并更新到GMHistoryRecord
function GMMainView:OnTestCellMessageReceiveRes(resParams)

    local result = table_to_string(resParams)
    if resParams.Svr == nil or resParams.Cmd == nil then
        return
    end

    local resultNum = Celltestmsg.resultNum or 0
    if resParams.Svr == "cell" then
        if resParams.Cmd == "version" and Celltestmsg.ResultNum < 2 then
            Celltestmsg.ResVersion = resParams.Result
            Celltestmsg.ResultNum = resultNum + 1
        elseif resParams.Cmd == "pi" and Celltestmsg.ResultNum < 2 then
            local piRes = resParams.Result
            Celltestmsg.UserName = self:ResStr_Cut(piRes,"openid:"," role")
            Celltestmsg.CharID = self:ResStr_Cut(piRes,"name:"," prof")
            Celltestmsg.CharPos = self:ResStr_Cut(piRes,"pos:"," dir")
            Celltestmsg.ResultNum = Celltestmsg.ResultNum + 1
        elseif resParams.Cmd == "test" then
            local strResult = self:CelltestmsgResult()
            GMMgr.GMHistoryRecord = GMMgr.GMHistoryRecord .. "\n返回结果: " .. strResult
            _G.FLOG_WARNING(string.format("返回结果:%s",strResult))
        end
    end
end
return GMMainView