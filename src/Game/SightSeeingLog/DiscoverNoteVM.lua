--
-- Author: Alex
-- Date: 2024-02-28 16:06
-- Description:探索笔记
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local DiscoverNoteAreaCfg = require("TableCfg/DiscoverNoteAreaCfg")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local NoteClueCfg = require("TableCfg/DiscoverNoteHintCfg")
local NotePerfectCondCfg = require("TableCfg/DiscoverNotePerfectCondCfg")
local WeatherCfg = require("TableCfg/WeatherCfg")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local DiscoverNoteIconItemVM = require("Game/SightSeeingLog/ItemVM/DiscoverNoteIconItemVM")
local DiscoverNoteCompleteVM = require("Game/SightSeeingLog/DiscoverNoteCompleteVM")
local DiscoverActChooseItemVM = require("Game/SightSeeingLog/ItemVM/DiscoverActChooseItemVM")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local TextureColoredColorParam = DiscoverNoteDefine.TextureColoredColorParam
local TextureGreyColorParam = DiscoverNoteDefine.TextureGreyColorParam
local TextureColoredOpacityParam = DiscoverNoteDefine.TextureColoredOpacityParam
local TextureGreyOpacityParam = DiscoverNoteDefine.TextureGreyOpacityParam
local NoteClueType = DiscoverNoteDefine.NoteClueType
local NoteUnlockType = DiscoverNoteDefine.NoteUnlockType
local NoteClueSrcType = DiscoverNoteDefine.NoteClueSrcType
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR
--local FLinearColor = _G.UE.FLinearColor

---@class DiscoverNoteVM : UIViewModel
---@field NoteIconItems UIBindableList@笔记缩略图列表
---@field LocationImgPath string@主面板地图位置显示图片路径（地图通用/风景相片）
---@field TypeTitle string@展示内容种类标题（风景印象/探索记录）
---@field bShowNoteRecord boolean@是否显示笔记探索记录
---@field bCheckBoxShowRecordVisible boolean@切换风景印象/探索记录CheckBox是否可见
---@field NoteTitle string@笔记记录标题
---@field NoteContentText string@笔记描述文本（风景印象/探索记录）
---@field NoteMapName string@笔记地图名称
---@field RegionName string@地域名称
---@field DiscoverNumAndTotalText string@已探索数/总数
---@field bShowNotCompleted boolean@是否仅显示未完成Item（二期：未完成定义为未完美完成）
---@field bEnterFromGuideMain boolean@是否从图鉴入口界面进入
---@field SelectedRegionID number@当前选中的地域ID
---@field SelectedNoteID number@当前界面选中的笔记ID
local DiscoverNoteVM = LuaClass(UIViewModel)

---Ctor
function DiscoverNoteVM:Ctor()
end

function DiscoverNoteVM:OnInit()
    -- Main Part
    self.NoteIconItems = UIBindableList.New(DiscoverNoteIconItemVM)
    self.LocationImgPath = ""
    self.TypeTitle = ""
    self.NoteTitle = ""
    self.NoteContentText = ""
    self.NoteMapName = ""
    self.RegionName = ""
    self.DiscoverNumAndTotalText = ""
    self.bShowNotCompleted = false

    self.bEnterFromGuideMain = false
    self.NoteItemIdPointed = nil -- 结束界面指定选中的NoteID

    self.SelectedRegionID = 0
    self.SelectedNoteID = nil

    self.DiscoverNoteCompleteVM = DiscoverNoteCompleteVM.New()

    self.bShowRightListEmpty = false

    self.RefreshRightListAnimSwitch = false -- 右侧列表刷新动画开关
    self.NoteListScrollIndex = nil -- 右侧列表通知滚动序号
    self.ScrollToTheHeadSwitch = false -- 是否滚动到列表首开关

    -- 二期内容
    self.bLeftPhotoShow = false -- 是否显示主面板照片内容
    self.bShowPanelRecord = false -- 是否显示整个RecordPanel面板
    self.bPanelHintShow = false -- 是否显示线索面板
    self.bShowNoteRecord = false
    self.bCheckBoxShowRecordVisible = false
    self.bLocationBtnShow = false -- 是否显示探索点定位按钮
    self.IsRealWeatherUnLock = nil -- 是否天气条件线索解锁
    self.IsRealTimeUnLock = nil -- 是否时间条件线索解锁
    self.IsEmotionIDUnLock = nil -- 是否情感动作条件线索解锁
    self.WeatherLockText = "" -- 天气锁定文本
    self.TimeLockText = ""    -- 时间锁定文本
    self.EmotionIDLockText = ""  -- 情感动作锁定文本
    self.ClueSrcState = nil -- 存储线索解锁来源的开启情况

    -- 线索解锁动画
    self.bWeatherUnLockAnimPlay = nil -- 是否天气条件线索解锁动画播放
    self.bTimeUnLockAnimPlay = nil -- 是否时间条件线索解锁动画播放
    self.bEmotionIDUnLockAnimPlay = nil -- 是否情感动作条件线索解锁动画播放
    -- 线索解锁动画 end
    self.bWeatherImgFirstShow = false
    self.bWeatherImgSecondShow = false
    self.WeatherImgFirst = nil
    self.WeatherImgSecond = nil
    self.WeatherName = ""
    self.TimeText = ""
    self.EmotionImg = nil
    self.EmotionName = ""
    -- Texture参数
    self.Color = nil
    self.Opacity = nil
    self.Int = nil
    self.Tint = nil

    -- 情感动作界面
    self.LeftEmotionList = UIBindableList.New(DiscoverActChooseItemVM)
    self.RightEmotionList = UIBindableList.New(DiscoverActChooseItemVM)
    self.ActNoteContentText = ""
    self.ActChooseNoteID = 0
    self.ForceClosePanelByPointChange = false -- 是否因为探索点切换强制隐藏界面

    -- 三期内容
    self.bShowPerfectCondEffect = false -- 是否显示完美条件提示特效
    self.LastSelectedItem = nil
end

function DiscoverNoteVM:OnShutdown()
    self.NoteIconItems = nil
    self.DiscoverNoteCompleteVM = nil
    self.ClueSrcState = nil
end

--- 刷新当前地域笔记列表
function DiscoverNoteVM:UpdateRegionNoteIcons(RegionSevInfos)
    local NoteIconItems = self.NoteIconItems
    if not NoteIconItems then
        return
    end

    NoteIconItems:Clear()
    local ListData = {}
    for _, Value in pairs(RegionSevInfos) do
        local bCompleted = Value.bCompleted
        local bPerfectComplete = Value.bPerfectComplete --（二期：未完成定义为未完美完成）
        if not self.bShowNotCompleted or not bPerfectComplete then
            table.insert(ListData, {
                ItemID = Value.NoteItemID,
                Index = Value.ItemIndex,
                bCompleted = bCompleted,
                bPerfectComplete = bPerfectComplete,
                OffsetAngle = 0,--Index % 2 == 1 and 0 or -10
                bShowPerfectCondEffect = Value.bShowPerfectCondEffect,
            })
        end
    end
    self.bShowRightListEmpty = #ListData <= 0
    table.sort(ListData, function(a, b) return a.Index < b.Index end)
    NoteIconItems:UpdateByValues(ListData, nil)
end

function DiscoverNoteVM:ClearSelectedNoteID()
    self.SelectedNoteID = nil
end

--- 更新左侧面板的默认状态
function DiscoverNoteVM:UpdateLeftPanelDefaultState()
    if self.SelectedNoteID then
        FLOG_ERROR("DiscoverNoteVM:UpdateLeftPanelDefaultState: Panel have the selected note")
        return
    end

    self.bLeftPhotoShow = false
    self.bShowPanelRecord = false
    self.bCheckBoxShowRecordVisible = false
end

--- 切换选中的笔记
function DiscoverNoteVM:ChangeSelectedNote(NoteItemId)
    if not NoteItemId or type(NoteItemId) ~= "number" then
        return
    end

    local NoteIconItems = self.NoteIconItems
    if not NoteIconItems then
        return
    end

    local SelectedItem
    local LastSelectedItem
    for index = 1, NoteIconItems:Length() do
        local NoteItem = NoteIconItems:Get(index)
        if NoteItem then
            local NoteItemID = NoteItem.ItemID or 0
            local LastSelectedID = self.SelectedNoteID or 0
            local bSelected = NoteItemID == NoteItemId
            if NoteItemID == LastSelectedID then
                LastSelectedItem = NoteItem
            end
            NoteItem.bSelected = bSelected -- 非点击刷新实际状态
            if bSelected then
                SelectedItem = NoteItem
                local NoteItemIdPointed = self.NoteItemIdPointed
                if NoteItemIdPointed then
                    self.NoteListScrollIndex = index
                end
                NoteItem.TextNumberColor = "313131FF"
            else
                NoteItem.TextNumberColor = "D1BA8EFF"
            end
        end
    end

    self.LastSelectedItem = LastSelectedItem
    if SelectedItem and LastSelectedItem and SelectedItem == LastSelectedItem then
        return
    end

    if not SelectedItem then
        self:ClearSelectedNoteID()
        self:UpdateLeftPanelDefaultState()
        return
    end

    self.SelectedNoteID = NoteItemId
    self.bShowPanelRecord = true

    local bCompleted = SelectedItem.bCompleted
    local bPerfectComplete = SelectedItem.bPerfectComplete
    self.bLocationBtnShow = bCompleted and not bPerfectComplete
    --- 选中态的Icon不显示完美特效
    self.bShowPerfectCondEffect = SelectedItem.bUnderPerfectCond
    SelectedItem.bShowPerfectCondEffect = false
    --- 恢复上一个选中Icon实际的选中完美特效状态
    if LastSelectedItem then
        LastSelectedItem.bShowPerfectCondEffect = LastSelectedItem.bUnderPerfectCond
    end

    -- 已完美完成的笔记切换按钮才可见
    self.bCheckBoxShowRecordVisible = bPerfectComplete
    -- 完成过探索的显示照片
    self.bLeftPhotoShow = bCompleted
    -- 完美完成的默认显示探索记录
    self.bShowNoteRecord = bPerfectComplete
    
    self:UpdateHintPanelLockText()
    self:UpdateHintPanelUnlockText()
    self:UpdateNoteDetialContent()
end

function DiscoverNoteVM:UpdateNotePerfectCondPicked(SevInfos)
    if not SevInfos or not next(SevInfos) then
        return
    end
    for _, Info in ipairs(SevInfos) do
        local NoteID = Info.NoteItemID
        local bShowPerfectCondEffect = Info.bShowPerfectCondEffect
        local NoteIconItem = self.NoteIconItems:Find(function(Element)
            return Element.ItemID == NoteID
        end)
        if NoteIconItem then
            NoteIconItem.bUnderPerfectCond = bShowPerfectCondEffect
            if self.SelectedNoteID == NoteID then
                NoteIconItem.bShowPerfectCondEffect = false
                self.bShowPerfectCondEffect = bShowPerfectCondEffect
            else
                NoteIconItem.bShowPerfectCondEffect = bShowPerfectCondEffect
            end
        end
    end
end

function DiscoverNoteVM:UpdateNoteDetialContent()
    local SelectedNoteID = self.SelectedNoteID
    if not SelectedNoteID then
        return
    end

    local bShowNoteRecord = self.bShowNoteRecord
    --local bNotDiscovered = not self.bLeftPhotoShow
    self.bPanelHintShow = not bShowNoteRecord
    --self.bLocationBtnShow = not bNotDiscovered and not bShowNoteRecord
  
    self.TypeTitle = bShowNoteRecord and LSTR(330002) or LSTR(330003)
    
    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(SelectedNoteID)
    if not NoteCfg then
        return
    end

    self.LocationImgPath = NoteCfg.RecordImg

    local MapID = NoteCfg.MapID or 0
    local RegionID = MapUtil.GetMapRegionID(MapID) or 0

    local NoteRegionCfg = DiscoverNoteAreaCfg:FindCfgByKey(RegionID)
    if not NoteRegionCfg then
        FLOG_ERROR("ChangeSelectedNote: NoteRegionCfg is not found")
        return
    end

    local UIMapID = MapUtil.GetUIMapID(MapID) or 0
    local MapName = MapUtil.GetMapName(UIMapID)
    self.NoteMapName = MapName
    self.NoteTitle = NoteCfg.MapName
    self.NoteContentText = bShowNoteRecord and NoteCfg.RecordText or NoteCfg.ImpText
    self:SetLeftPhotoTextureParams(bShowNoteRecord)
    self.RefreshRightListAnimSwitch = not self.RefreshRightListAnimSwitch
end

--- 默认选择第一个Item并滚动到第一个位置
function DiscoverNoteVM:DefaultSelectTheFirstItem()
    local NoteIconItems = self.NoteIconItems
    if not NoteIconItems then
        return
    end
    local FirstItem = NoteIconItems:Get(1)
    if not FirstItem then
        self:ClearSelectedNoteID()
        self:UpdateLeftPanelDefaultState()
        return
    end
    local FirstItemID = FirstItem.ItemID
    self:ChangeSelectedNote(FirstItemID)
    local LastScrollState = self.ScrollToTheHeadSwitch
    self.ScrollToTheHeadSwitch = not LastScrollState
end

--- 播放所有Item的AnimIn动画
function DiscoverNoteVM:PlayAllIconItemAnimIn()
    local NoteIconItems = self.NoteIconItems
    if not NoteIconItems then
        return
    end

    for index = 1, NoteIconItems:Length() do
        local Item = NoteIconItems:Get(index)
        if Item then
            local AnimInSwitch = Item.AnimInSwitch
            Item.AnimInSwitch = not AnimInSwitch
        end
    end
end

--- 切换地域显示
---@param RegionID number@地域id
function DiscoverNoteVM:ChangeTheRegion(RegionInfo)
    if not RegionInfo then
        return
    end
    self.bShowNotCompleted = false -- 初始化地域页签清除checkBox状态
    self.bCheckBoxShowRecordVisible = false -- 初始化隐藏切换印象和记录的Button
    self.SelectedRegionID = RegionInfo.RegionID
    self.RegionName = RegionInfo.Name
    local TotalNum = RegionInfo.TotalNum
    local CompletedNum = RegionInfo.CompletedNum or 0
    self.DiscoverNumAndTotalText = string.format(LSTR(330004), tostring(CompletedNum), tostring(TotalNum))
  
    local RegionSevInfos = RegionInfo.RegionSevInfos
    if not RegionSevInfos or not next(RegionSevInfos) then
        return
    end
    self:UpdateRegionNoteIcons(RegionSevInfos)
    local PointedID = self.NoteItemIdPointed
    if PointedID then
        self:ChangeSelectedNote(PointedID)
        self.NoteItemIdPointed = nil
    else
        self:DefaultSelectTheFirstItem()
    end
    self:PlayAllIconItemAnimIn()
end

--- 切换未完成状态CheckBox显示
---@param RegionSevInfos table@地域下所有探索笔记的服务器信息
function DiscoverNoteVM:ChangeTheCheckBoxCompleteState(RegionSevInfos)
    local bShowNotCompleted = self.bShowNotCompleted
    self.bShowNotCompleted = not bShowNotCompleted
   
    if not RegionSevInfos or not next(RegionSevInfos) then
        return
    end
    self:UpdateRegionNoteIcons(RegionSevInfos)
    self:DefaultSelectTheFirstItem()
    self:PlayAllIconItemAnimIn()
end

--- 刷新完成界面的VM数据
function DiscoverNoteVM:UpdateCompletePanelData(NoteInfo)
    if not NoteInfo then
        return
    end

    local NoteID = NoteInfo.NoteItemID

    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteID)
    if not NoteCfg then
        return
    end

    local NoteTitle = ""
    local ItemIndex = NoteInfo.ItemIndex
    local IndexText = ""
    if math.floor(ItemIndex / 10) == 0 then
        IndexText = string.format("0%s", tostring(ItemIndex))
    else
        IndexText = tostring(ItemIndex)
    end

    NoteTitle = string.format("%s %s", IndexText, NoteCfg.MapName)
    local MapID = NoteCfg.MapID or 0
    local RegionID = MapUtil.GetMapRegionID(MapID) or 0
    local UIMapID = MapUtil.GetUIMapID(MapID) or 0
    local MapName = MapUtil.GetMapName(UIMapID)

    local function GetTheNoteUnlockState(NoteInfo)
        if NoteInfo.bPerfectComplete then
            return NoteUnlockType.PerfectUnlock
        elseif NoteInfo.UnlockFail then
            return NoteUnlockType.UnlockFail
        elseif NoteInfo.bCompleted then
            return NoteUnlockType.NormalUnlock
        else
            return NoteUnlockType.Locked
        end
    end

    local ValueToUpdate = {
        NoteItemID = NoteInfo.NoteItemID,
        NoteName = NoteTitle,
        ImgPath = NoteCfg.RecordImg,
        NoteContent = NoteCfg.RecordText,
        RegionName = MapUtil.GetRegionName(RegionID),
        MapName = MapName,
        CompleteState = GetTheNoteUnlockState(NoteInfo),
    }
    local CompleteVM = self.DiscoverNoteCompleteVM
    if not CompleteVM then
        FLOG_ERROR("DiscoverNoteVM:UpdateCompletePanelData DiscoverNoteCompleteVM is not valid")
        return
    end
    CompleteVM:UpdateVM(ValueToUpdate)
end

--- 切换风景印象/探索记录显示
function DiscoverNoteVM:ChangeShowNoteRecord()
    local bShowNoteRecord = self.bShowNoteRecord
    self.bShowNoteRecord = not bShowNoteRecord
    self:UpdateNoteDetialContent()
end

--- 设置左侧照片颜色参数（完美彩色/普通灰态）
function DiscoverNoteVM:SetLeftPhotoTextureParams(bPerfectComplete)
    if bPerfectComplete then
        self.Color = TextureColoredColorParam.Color
        self.Int = TextureColoredColorParam.Int
        self.Tint = TextureColoredColorParam.Tint
        self.Opacity = TextureColoredOpacityParam.Opacity
    else
        self.Color = TextureGreyColorParam.Color
        self.Opacity = TextureGreyOpacityParam.Opacity
        self.Int = TextureGreyColorParam.Int
        self.Tint = TextureGreyColorParam.Tint
    end
end

------ 线索相关 ------
--- 更新线索面板上锁文本内容

--- 根据服务器返回来源实际数据设定客户端显示来源
---@param NoteID number@笔记ID
---@param ClueType NoteClueType@线索类型
---@param ClueSrcType NoteClueSrcType@线索来源类型
function DiscoverNoteVM:SetTheNoteClueSrcStateDisable(NoteID, ClueType, ClueSrcType)
    local ClueSrcState = self.ClueSrcState or {}
    local NoteClueState = ClueSrcState[NoteID] or {}
    local SrcBitState = NoteClueState[ClueType] or 0
    SrcBitState = 1 << ClueSrcType | SrcBitState
    NoteClueState[ClueType] = SrcBitState
    ClueSrcState[NoteID] = NoteClueState
    self.ClueSrcState = ClueSrcState
end

--- 根据服务器返回来源返回客户端实际需要显示的来源
---@param NoteID number@笔记ID
---@param ClueType NoteClueType@线索类型
---@param ClueSrcType NoteClueSrcType@线索来源类型
function DiscoverNoteVM:IsTheNoteClueSrcTypeDisable(NoteID, ClueType, ClueSrcType)
    local ClueSrcState = self.ClueSrcState
    if not ClueSrcState then
        return false
    end

    local NoteClueState = ClueSrcState[NoteID]
    if not NoteClueState then
        return false
    end

    local SrcType = NoteClueState[ClueType]
    if not SrcType then
        return false
    end

    local BitCheck = 1 << ClueSrcType
    return BitCheck & SrcType > 0
end

function DiscoverNoteVM:UpdateHintPanelLockText()
    --[[local NoteID = self.SelectedNoteID
    if not NoteID then
        return
    end
    local function GetTheClueSrcText(NoteID, NoteClueType)
        local ClueCfg = NoteClueCfg:FindCfg(string.format("NoteID = %d AND ClueType = %d", NoteID, NoteClueType))
        if not ClueCfg then
            return ""
        end

        local EobjID = ClueCfg.PickEobjId
        local TreasureBoxID = ClueCfg.TreasureBoxID
        local MonsterID = ClueCfg.MonsterID
        local NpcListID = ClueCfg.NpcListID
        if TreasureBoxID and TreasureBoxID > 0 and not self:IsTheNoteClueSrcTypeDisable(NoteID, NoteClueType, NoteClueSrcType.TreasureBox) then
            return LSTR(330006)
        elseif EobjID and EobjID > 0 and not self:IsTheNoteClueSrcTypeDisable(NoteID, NoteClueType, NoteClueSrcType.Loot) then
            return LSTR(330005)
        elseif MonsterID and MonsterID > 0 and not self:IsTheNoteClueSrcTypeDisable(NoteID, NoteClueType, NoteClueSrcType.Monster) then
            return LSTR(330007)
        elseif NpcListID and NpcListID > 0 and not self:IsTheNoteClueSrcTypeDisable(NoteID, NoteClueType, NoteClueSrcType.NpcDialog) then
            return LSTR(330022) -- 对话NPC
        else
            return ""
        end
       
    end

    self.WeatherLockText = GetTheClueSrcText(NoteID, NoteClueType.Weather)
    self.TimeLockText = GetTheClueSrcText(NoteID, NoteClueType.Time)
    self.EmotionIDLockText = GetTheClueSrcText(NoteID, NoteClueType.Emotion)--]]
    self.WeatherLockText = LSTR(330025)
    self.TimeLockText = LSTR(330024)
    self.EmotionIDLockText = LSTR(330026)
end

--- 更新线索面板解锁内容
function DiscoverNoteVM:UpdateHintPanelUnlockText()
    local NoteID = self.SelectedNoteID
    if not NoteID then
        return
    end

    local CondCfg = NotePerfectCondCfg:FindCfgByKey(NoteID)
    if not CondCfg then
        return
    end

    -- 天气
    do
        local FirstShow = false
        local SecondShow = false
        local WetherIDs = CondCfg.WeatherID
        if WetherIDs then
            local TotalWeatherText
            for Index, WeatherID in ipairs(WetherIDs) do
                local Cfg = WeatherCfg:FindCfgByKey(WeatherID)
                if Cfg then
                    if Index == 1 then
                        self.WeatherImgFirst = Cfg.Icon
                        TotalWeatherText = Cfg.Name
                        FirstShow = true
                    elseif Index == 2 then
                        self.WeatherImgSecond = Cfg.Icon
                        TotalWeatherText = string.format(LSTR(330023), TotalWeatherText, Cfg.Name)
                        SecondShow = true
                    else
                        FLOG_WARNING("DiscoverNoteVM:UpdateHintPanelUnlockText Support Max Weather To Show is Two")
                    end
                end
            end
            self.bWeatherImgFirstShow = FirstShow
            self.bWeatherImgSecondShow = SecondShow
            self.WeatherName = TotalWeatherText or ""
        end
    end

    -- 时间
    do
        local StartTime = CondCfg.StartTime or 0
        local EndTime = CondCfg.EndTime or 0
        local TextStartTime = StartTime > 23 and 0 or StartTime
        local TextEndTime = EndTime > 23 and 0 or EndTime
        self.TimeText = string.format("%02d:%02d-%02d:%02d", TextStartTime, 0, TextEndTime, 0)
    end

    -- 情感动作
    do
        local PerfectDiscoveryEmotionID = CondCfg.PerfectDiscoveryEmotionID
        if PerfectDiscoveryEmotionID then
            local Cfg = EmotionCfg:FindCfgByKey(PerfectDiscoveryEmotionID)
            if Cfg then
                self.EmotionImg = EmotionUtils.GetEmoActIconPath(Cfg.IconPath)
                self.EmotionName = Cfg.EmotionName or ""
            end
        end
    end
end

function DiscoverNoteVM:SetTheClueLockState(ClueType, bUnlock)
    if ClueType == NoteClueType.Weather then
        self.IsRealWeatherUnLock = bUnlock
    elseif ClueType == NoteClueType.Time then
        self.IsRealTimeUnLock = bUnlock
    elseif ClueType == NoteClueType.Emotion then
        self.IsEmotionIDUnLock = bUnlock
    else
        FLOG_WARNING("DiscoverNoteVM:SetTheClueLockState ClueType is not exist")
    end
end

function DiscoverNoteVM:UpdateHintPanelInfo(NoteID, HintState)
    if NoteID ~= self.SelectedNoteID then
        return
    end

    local bWeatherUnLockAnimPlay = HintState.bWeatherUnLockAnimPlay
    self.bWeatherUnLockAnimPlay = bWeatherUnLockAnimPlay
    if not bWeatherUnLockAnimPlay then
        self:SetTheClueLockState(NoteClueType.Weather, HintState.IsRealWeatherUnLock)
    end
  
    local bTimeUnLockAnimPlay = HintState.bTimeUnLockAnimPlay
    self.bTimeUnLockAnimPlay = bTimeUnLockAnimPlay
    if not bTimeUnLockAnimPlay then
        self:SetTheClueLockState(NoteClueType.Time, HintState.IsRealTimeUnLock)
    end
  
    local bEmotionIDUnLockAnimPlay = HintState.bEmotionIDUnLockAnimPlay
    self.bEmotionIDUnLockAnimPlay = bEmotionIDUnLockAnimPlay
    if not bEmotionIDUnLockAnimPlay then
        self:SetTheClueLockState(NoteClueType.Emotion, HintState.IsEmotionIDUnLock)
    end
end

------ 线索相关 end ------

--- 更新情感选择界面
function DiscoverNoteVM:UpdateActChooseViewVM(Value)
    local NoteID = Value.NoteID
    if not NoteID then
        return
    end

    self.ActChooseNoteID = NoteID
    self.ForceClosePanelByPointChange = false

    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteID)
    if not NoteCfg then
        return
    end

    self.ActNoteContentText = NoteCfg.ImpText or ""

    local EmotionIDList = Value.EmotionIDList
    if not EmotionIDList or not next(EmotionIDList) then
        return
    end

    local CorrectEmotionID = EmotionIDList[1].ID or 0
    table.sort(EmotionIDList, function(A, B) 
        return A.ID < B.ID
    end)
  
    local bEmotionClueUnlock = Value.bEmotionClueUnlock

    local RightEmotionList = self.RightEmotionList
    if not RightEmotionList then
        return
    end

    local LeftEmotionList = self.LeftEmotionList
    if not LeftEmotionList then
        return
    end
    RightEmotionList:Clear()
    LeftEmotionList:Clear()
    for Index = 1, #EmotionIDList do
        local EmotionInfo = EmotionIDList[Index]
        if EmotionInfo then
            local EmotionID = EmotionInfo.ID or 0
            if Index % 2 == 1 then
                RightEmotionList:AddByValue({
                    EmotionID = EmotionID,
                    bCorrect = bEmotionClueUnlock and EmotionID == CorrectEmotionID,
                    bGot = EmotionInfo.bGot
                })
            else
                LeftEmotionList:AddByValue({
                    EmotionID = EmotionID,
                    bCorrect = bEmotionClueUnlock and EmotionID == CorrectEmotionID,
                    bGot = EmotionInfo.bGot
                })
            end
        end
    end
end

function DiscoverNoteVM:CloseActChoosePanelByPointChangeToNormal(NoteID)
    if not NoteID then
        return
    end

    local CurChooseID = self.ActChooseNoteID
    if CurChooseID ~= NoteID then
        return
    end
    self.ForceClosePanelByPointChange = true
end

return DiscoverNoteVM