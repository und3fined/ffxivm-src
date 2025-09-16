---
--- Author: muyanli
--- DateTime: 2024-05-17 20:10
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local Json = require("Core/Json")
local LoginMgr = require("Game/Login/LoginMgr")
local CommonUtil = require("Utils/CommonUtil")
local SettingsDefine = require("Game/Settings/SettingsDefine")


---@class GetLevelRecordListPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Block UButton
---@field BtnGetRecord UButton
---@field BtnPlay UButton
---@field BtnPlayByRecordID UButton
---@field BtnRecord UButton
---@field BtnRecordTxt UTextBlock
---@field ButtonExit UButton
---@field CheckBox01 CommCheckBoxView
---@field CheckBox02 CommCheckBoxView
---@field CheckBoxUIRecordClose CommCheckBoxView
---@field CheckBoxUIRecordOpen CommCheckBoxView
---@field CheckBoxUIRecordOpt CommCheckBoxView
---@field ClientRecoreToggleGroup UToggleGroup
---@field DropDownList CommDropDownListView
---@field DropDownList_Culture CommDropDownListView
---@field OpenIDTxt UEditableTextBox
---@field RecordIDTxt UEditableTextBox
---@field ReturnToLoginToggleGroup UToggleGroup
---@field ReturnToLogin_Close CommCheckBoxView
---@field ReturnToLogin_Open CommCheckBoxView
---@field UIRecoreToggleGroup UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GetLevelRecordListPanelView = LuaClass(UIView, true)

function GetLevelRecordListPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnGetRecord = nil
    -- self.BtnPlay = nil
    -- self.DropDownList = nil
    -- self.OpenIDTxt = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GetLevelRecordListPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.DropDownList)
    self:AddSubView(self.DropDownList_Culture)
    self:AddSubView(self.CheckBox01)
    self:AddSubView(self.CheckBox02)
    self:AddSubView(self.CheckBoxUIRecordOpen)
    self:AddSubView(self.CheckBoxUIRecordClose)
    self:AddSubView(self.CheckBoxUIRecordOpt)
    self:AddSubView(self.ReturnToLogin_Open)
    self:AddSubView(self.ReturnToLogin_Close)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GetLevelRecordListPanelView:OnInit()
    self.SelectRecordIndex = -1
    self.CheckBox01:SetText(self.CheckBox01.Content)
    self.CheckBox02:SetText(self.CheckBox02.Content)
    self.CheckBoxUIRecordOpen:SetText(self.CheckBoxUIRecordOpen.Content)
    self.CheckBoxUIRecordClose:SetText(self.CheckBoxUIRecordClose.Content)
    self.CheckBoxUIRecordOpt:SetText(self.CheckBoxUIRecordOpt.Content)
    self.ReturnToLogin_Open:SetText(self.ReturnToLogin_Open.Content)
    self.ReturnToLogin_Close:SetText(self.ReturnToLogin_Close.Content)
    self.Languages = CommonUtil.GetCultureList()
    self.CurLanguageIndex = self:GetCurLanguageIndex()
    if self.CurLanguageIndex == nil then self.CurLanguageIndex = 1 end
    UIUtil.SetIsVisible(self, self.ButtonExit, true,true)
    UIUtil.SetIsVisible(self, self.BtnGetRecord, true,true)
    UIUtil.SetIsVisible(self, self.BtnRecord, true,true)
    UIUtil.SetIsVisible(self, self.BtnPlay, true,true)
    UIUtil.SetIsVisible(self, self.BtnPlayByRecordID, true,true)
end

function GetLevelRecordListPanelView:OnDestroy()

end

function GetLevelRecordListPanelView:OnShow()
    _G.EventMgr:SendEvent(EventID.BlockAllInput, false)
    _G.LevelRecordMgr:ReadLocalRecordFiles()
    self:UpdateBtnRecordStatus()
    self.DropDownList:UpdateItems(_G.LevelRecordMgr.RecordListData, 1)
    if #_G.LevelRecordMgr.RecordListData ==0 then
        self.SelectRecordIndex = -1
        self.DropDownList:CancelSelected()
    end

    self.DropDownList_Culture:UpdateItems(self.Languages, self.CurLanguageIndex,false)

    local Index
    if _G.LevelRecordMgr.bIsOpenClientRecord then
        Index=0
    else
        Index=1
    end
    self.ClientRecoreToggleGroup:SetCheckedIndex(Index, true)

    if UE4.UIRecordMgr:Get().OpenUIRecord then
        if UE4.ULevelRecordMgr:Get().OpenPureUIRecord then
            Index=2
        else
            Index=0
        end
    else
        Index=1
    end
    self.UIRecoreToggleGroup:SetCheckedIndex(Index, true)

    if _G.LevelRecordMgr.ReturnToLogin then
        Index=0
    else
        Index=1
    end
    self.ReturnToLoginToggleGroup:SetCheckedIndex(Index, true)
end

function GetLevelRecordListPanelView:OnHide()
    if _G.LevelRecordMgr.bIsInReplaying then
        _G.EventMgr:SendEvent(EventID.BlockAllInput, true)
    end
end


function GetLevelRecordListPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ButtonExit, self.OnClickButtonExit)
    UIUtil.AddOnClickedEvent(self, self.BtnGetRecord, self.OnClickBtnGetRecord)
    UIUtil.AddOnClickedEvent(self, self.BtnRecord, self.OnClickBtnRecord)
    UIUtil.AddOnClickedEvent(self, self.BtnPlay, self.OnClickBtnPlay)
    UIUtil.AddOnClickedEvent(self, self.BtnPlayByRecordID, self.OnClickBtnPlayByRecordID)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)
    UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList_Culture, self.OnDropDownList_CultureSelectionChanged)
    
    UIUtil.AddOnStateChangedEvent(self, self.ClientRecoreToggleGroup, self.OnGroupStateChangedQuest)
    UIUtil.AddOnStateChangedEvent(self, self.UIRecoreToggleGroup, self.OnGroupStateChangedUIRecord)
    UIUtil.AddOnStateChangedEvent(self, self.ReturnToLoginToggleGroup, self.OnGroupStateChangedReturnToLogin)
end

function GetLevelRecordListPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.Update_Recording, self.UpdateBtnRecordStatus)
end

function GetLevelRecordListPanelView:OnRegisterBinder()

end

function GetLevelRecordListPanelView:OnClickButtonExit()
	UIViewMgr:HideView(self.ViewID)
end

function GetLevelRecordListPanelView:OnClickBtnGetRecord()
    if self.OpenIDTxt.Text=="" then
        _G.MsgTipsUtil.ShowTips("请输入OpenID")
        return
    end
    local SendData={open_id=self.OpenIDTxt.Text}
    _G.LevelRecordMgr:GetRecordList(SendData,self.OnGetRecordList,self)
end

function GetLevelRecordListPanelView:OnClickBtnPlay()
    if self.SelectRecordIndex == -1 then
        _G.MsgTipsUtil.ShowTips("请先拉取录像列表并选择一个录像")
        return
    end
    local recordListItem = _G.LevelRecordMgr:GetRecordListData(self.SelectRecordIndex);
    local RecordUrl = recordListItem.RecordFilePath;
    if type(RecordUrl) == "number" then
        _G.LevelRecordMgr:DowmLoadReplayFile(RecordUrl, recordListItem.Name, self.OnGetRecord, self)
    elseif RecordUrl ~= "" then
        _G.LevelRecordMgr:StartPlayRecord(RecordUrl)
    end
end


function GetLevelRecordListPanelView:OnClickBtnPlayByRecordID()
    if self.RecordIDTxt.Text=="" then
        _G.MsgTipsUtil.ShowTips("请输入RecordID")
        return
    end
    local RecordID=self.RecordIDTxt.Text
    _G.LevelRecordMgr:DowmLoadReplayFile(RecordID,"Record_"..RecordID..".rep", self.OnGetRecord, self)
end

function GetLevelRecordListPanelView:UpdateBtnRecordStatus()
    local ReplayStatu=UE4.ULevelRecordMgr:Get():GetReplayStatu()
    local str="开启录像"
    if ReplayStatu==_G.LevelRecordMgr.EReplayStatus.InRecord then
        str="关闭并保存录像"
    end
    self.BtnRecordTxt:SetText(str)
    UIUtil.SetIsVisible(self.BtnRecord,ReplayStatu ~=_G.LevelRecordMgr.EReplayStatus.InRecordPlay)
end

function GetLevelRecordListPanelView:OnClickBtnRecord()
    local ReplayStatu = UE4.ULevelRecordMgr:Get():GetReplayStatu()
    if ReplayStatu == _G.LevelRecordMgr.EReplayStatus.None and not _G.LevelRecordMgr:IsCanExecReplayCmd()   then
        return
    end

    if ReplayStatu == _G.LevelRecordMgr.EReplayStatus.InRecord then
        ReplayStatu = _G.LevelRecordMgr.EReplayStatus.None
        if _G.LevelRecordMgr.ReturnToLogin then
            _G.LoginMgr:ReturnToLogin(false)
        end
    elseif ReplayStatu == _G.LevelRecordMgr.EReplayStatus.None then
        ReplayStatu = _G.LevelRecordMgr.EReplayStatus.InRecord
    end
    _G.LevelRecordMgr:UpdateReplayStatu(ReplayStatu)
    self:OnClickButtonExit()
end



function GetLevelRecordListPanelView:OnGetRecordList(RespStr)
    local ResData=Json.decode(RespStr,string.find(RespStr,"{"))
    if ResData.code ~=200 then
        return
    end
    local Utc8TimeDiff=8*3600
    local TempData={}
    local Data=ResData.data
	for i = 1, #Data do
        if Data[i].world_id==nil then
            Data[i].world_id=10
        end
        local FixName="_".. Data[i].only_id.."_"..Data[i].world_id.."_"..LoginMgr:GetMapleNodeName(Data[i].world_id).."_".."server"
        local FileName=UE4.UCommonUtil.GetOutputTime(math.floor(Data[i].timestamp/1000+Utc8TimeDiff),"",0)..FixName
		table.insert(TempData, { Type = i , Name = FileName, RecordFilePath = Data[i].only_id } )
	end
    _G.LevelRecordMgr:SetRecordListData(TempData)

    if self.DropDownList and self.DropDownList.Object:IsValid() and self.DropDownList.OnSelectionChanged ~= nil then
        self.DropDownList:UpdateItems(_G.LevelRecordMgr.RecordListData, 1)
    end
end

function GetLevelRecordListPanelView:OnGetRecord(bSuc,ReplayFilePath)
    if bSuc then
        _G.LevelRecordMgr:StartPlayRecord(ReplayFilePath)
        UIViewMgr:HideView(self.ViewID)
    else
        _G.MsgTipsUtil.ShowTips("下载录像文件失败")
    end
end

function GetLevelRecordListPanelView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if Index ~= nil and _G.LevelRecordMgr.RecordListData[Index] ~= nil then
		self.SelectRecordIndex=Index
	end
    print("选择的录像是："..self.SelectRecordIndex)
end

function GetLevelRecordListPanelView:OnDropDownList_CultureSelectionChanged(Index, ItemData, ItemView, IsByClick)
    if not IsByClick then
            return
    end
    local function Confirm()
        local Languages = table.invert(SettingsDefine.LanguageType)
        local InCultureName = Languages[Index]
        if InCultureName ~= nil then
            CommonUtil.SetCurrentCulture(InCultureName, true)
            self.CurLanguageIndex = Index
            CommonUtil.QuitGame()
        end
    end

    local function Cancle()
        self.DropDownList_Culture:UpdateItems(self.Languages, self.CurLanguageIndex,false)
    end
    
    MsgBoxUtil.ShowMsgBoxTwoOp(nil, "提示",
    "切换语言需要重启游戏，确认切换吗？", Confirm, Cancle,
    "取消", "确认")

end

function GetLevelRecordListPanelView:OnGroupStateChangedQuest(ToggleGroup, ToggleButton, Index, State)
    _G.LevelRecordMgr:SwitchClientRecord(Index==0)
end

function GetLevelRecordListPanelView:OnGroupStateChangedUIRecord(ToggleGroup, ToggleButton, Index, State)
    UE4.UIRecordMgr:Get().OpenUIRecord = Index ~= 1
    _G.LevelRecordMgr:OpenPureUIRecord(Index == 2)
end

function GetLevelRecordListPanelView:OnGroupStateChangedReturnToLogin(ToggleGroup, ToggleButton, Index, State)
    _G.LevelRecordMgr.ReturnToLogin = Index == 0
end


function GetLevelRecordListPanelView:GetCurLanguageIndex()
   local CurLan = CommonUtil.GetCurrentCultureName()
   local CultureIdx = SettingsDefine.LanguageType[CurLan]
   return  CultureIdx
end


return GetLevelRecordListPanelView
