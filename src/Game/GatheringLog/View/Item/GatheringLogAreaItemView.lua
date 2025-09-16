---
--- Author: Leo
--- DateTime: 2023-03-29 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GatheringLogVM = require("Game/GatheringLog/GatheringLogVM")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local WorldMapMgr = _G.WorldMapMgr
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@class GatheringLogAreaItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArea UFButton
---@field BtnArrow UFButton
---@field BtnGoTo UFButton
---@field FCanvasPanel_37 UFCanvasPanel
---@field HorizontalInfo UFHorizontalBox
---@field IconTime UFImage
---@field ImgArrow UFImage
---@field ImgBg UFImage
---@field ImgLine UFImage
---@field TextArea UFTextBlock
---@field TextTime UFTextBlock
---@field AnimInfoStatus0 UWidgetAnimation
---@field AnimInfoStatus1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogAreaItemView = LuaClass(UIView, true)

function GatheringLogAreaItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArea = nil
	--self.BtnArrow = nil
	--self.BtnGoTo = nil
	--self.FCanvasPanel_37 = nil
	--self.HorizontalInfo = nil
	--self.IconTime = nil
	--self.ImgArrow = nil
	--self.ImgBg = nil
	--self.ImgLine = nil
	--self.TextArea = nil
	--self.TextTime = nil
	--self.AnimInfoStatus0 = nil
	--self.AnimInfoStatus1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogAreaItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogAreaItemView:OnInit()
    self.AdapterCountDownTime =
        UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)

    self.Binders = {
        {"ShowTimeText", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 0.2, true, true)},
        {"Name", UIBinderSetText.New(self, self.TextArea)},
        {"ArrowIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgArrow)}, --限时采集物未解锁也可见箭头，但是地图不显示采集点--story=116479067
        {"ArrowColorOpacity", UIBinderSetColorAndOpacity.New(self, self.ImgArrow)},
        {"bTextTimeVisible", UIBinderSetIsVisible.New(self, self.TextTime)},
        {"bSelect", UIBinderSetIsVisible.New(self, self.ImgSelect)},
        {"bImgLineVisible", UIBinderSetIsVisible.New(self, self.ImgLine)},
        {"bArrowShow", UIBinderSetIsVisible.New(self, self.HorizontalInfo)}, 
        --{"ShowTimeText", UIBinderValueChangedCallback.New(self, nil, self.TimeUpdateCallback)}, ShowTimeText不是TimeUpdateCallback的参数
        {"bGathering", UIBinderValueChangedCallback.New(self, nil, self.SetAnim)},
        {"bTextTimeVisible", UIBinderValueChangedCallback.New(self, nil, self.SetAnim)},

    }
end

function GatheringLogAreaItemView:OnDestroy()
    self.AdapterCountDownTime:UnRegisterAllTimer()
end

function GatheringLogAreaItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    if ViewModel.ShowTimeText == 0 then
        self.AdapterCountDownTime:UnRegisterAllTimer()
    end
end

function GatheringLogAreaItemView:OnHide()
    self.AdapterCountDownTime:UnRegisterAllTimer()
end

function GatheringLogAreaItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnArea, self.OnBtnGoToClicked)
end

function GatheringLogAreaItemView:OnRegisterGameEvent()
end

function GatheringLogAreaItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function GatheringLogAreaItemView:SetAnim()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    if ViewModel.bArrowShow and ViewModel.bGathering and ViewModel.bTextTimeVisible then
        self:StopAnimation(self.AnimInfoStatus0)
        self:PlayAnimation(self.AnimInfoStatus1)
    else
        self:StopAnimation(self.AnimInfoStatus1)
        self:PlayAnimation(self.AnimInfoStatus0)
    end
end

---@type 当倒计时至最后
function GatheringLogAreaItemView:TimeOutCallback()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    local ID = ViewModel.ID
    --时间刷到最后要更新一下
    local PlaceVM = GatheringLogVM:GetPlaceItemByID(ID)
    if nil == PlaceVM then
        return
    end
    local TimeCondition = PlaceVM.TimeCondition
    if table.is_nil_empty(TimeCondition) then
        return
    end
    PlaceVM:SetTimeTextTip(TimeCondition)

    --如果在闹钟页签要刷新一下
    local HorTabsID = GatheringLogMgr.LastFilterState.HorTabsIndex or 1
    local ClockIndex = GatheringLogDefine.HorBarIndex.ClockIndex
    if HorTabsID == ClockIndex  then
        _G.EventMgr:SendEvent(_G.EventID.GatheringLogUpdateHorTabs,ClockIndex)
        _G.EventMgr:SendEvent(_G.EventID.GatheringLogUpdateDropDownFilter,ClockIndex)
    end
end

---@type 此函数每0.2s调用一次 刷时间
---@param LeftTime number 剩余时间
function GatheringLogAreaItemView:TimeUpdateCallback(LeftTime)
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    --得到选择的地点 来判断要不要显示禁止图片
    -- local SelectPlace = GatheringLogVM:GetSelectPlace()
    -- if SelectPlace == nil or SelectPlace.bBeginGather or #SelectPlace.TimeCondition < 1 then
    --     GatheringLogVM.bCondition1ImgBidVisible = false
    -- elseif not SelectPlace.bBeginGather then
    --     GatheringLogVM.bCondition1ImgBidVisible = true
    -- end

    local bGathering = ViewModel.bGathering
    local TimeFormat = GatheringLogDefine.TimeFormat
    local TimeFormatEnd = _G.LSTR(TimeFormat.End)
    local TimeFormatStart = _G.LSTR(TimeFormat.Start)
    local OneMinSecond = 60
    local OneHourSecond = 3600
    -- local ClockTipMaxSecond = 5*60 + 1
    -- if LeftTime <= ClockTipMaxSecond and self:IsNeedCheck(ViewModel) then
    -- 	local GatherType = ViewModel.GatherType
    -- 	self:CheckShouldShowTip(LeftTime, GatherType)
    -- end
    --超过一小时
    if LeftTime > OneHourSecond then
        if bGathering then
            self.AdapterCountDownTime.StrFormat = TimeFormatEnd
            ViewModel.bBeginGather = true
        else
            self.AdapterCountDownTime.StrFormat = TimeFormatStart
            ViewModel.bBeginGather = false
        end
        return LocalizationUtil.GetCountdownTimeForSimpleTime(LeftTime,"h")
    elseif LeftTime > OneMinSecond then
        local Min = math.floor(LeftTime / OneMinSecond)
        if bGathering then
            self.AdapterCountDownTime.StrFormat = TimeFormatEnd
            ViewModel.bBeginGather = true
        else
            self.AdapterCountDownTime.StrFormat = TimeFormatStart
            ViewModel.bBeginGather = false
        end
        return LocalizationUtil.GetCountdownTimeForSimpleTime(LeftTime,"m")
    elseif LeftTime > 0 then
        if bGathering then
            self.AdapterCountDownTime.StrFormat = TimeFormatEnd
            ViewModel.bBeginGather = true
        else
            self.AdapterCountDownTime.StrFormat = TimeFormatStart
            ViewModel.bBeginGather = false
        end
        return LocalizationUtil.GetCountdownTimeForSimpleTime(LeftTime,"s")
    elseif LeftTime == 0 then
        self.AdapterCountDownTime.StrFormat = nil
    end
end

---@type 检查改采集點所存在的采集物是否設置了⏰，設置了的話則需要Check
---@param ViewModel table VM
function GatheringLogAreaItemView:IsNeedCheck(ViewModel)
    local CommonResourceID = ViewModel.CommonResourceID
    for i = 1, #CommonResourceID do
        local GatherItemID = CommonResourceID[i]
        local Elem = GatheringLogVM:GetItemVMByItemID(GatherItemID)
        if Elem.bSetClock then
            return true
        end
    end
    return false
end

---@type 点击地点按钮
function GatheringLogAreaItemView:OnBtnAreaClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    local ID = ViewModel.ID
    GatheringLogVM:UpdatePlaceSelectTab(ID)
end

---@type 点击前往按钮
function GatheringLogAreaItemView:OnBtnGoToClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    if ViewModel.bArrowShow == false then
        return
    end
    local GatherID = ViewModel.GatherID
    local Item = _G.GatheringLogVM:GetItemDataByID(GatherID)
    GatheringLogVM:UpdatePlaceSelectTab()
    local MapID = ViewModel.MapID
    local GatherPointID = ViewModel.ID
    local IsShowMakers = not ViewModel.bUnknownLoc --bUnknownLoc：未解锁，不显示该采集点位置图标
    local GatherPointList = {}
    --此采集点放第一个
    table.insert(GatherPointList,{GatherPointID = GatherPointID, IsShowMakers = IsShowMakers})
    --如此地图还有这个采集物的其他采集点添加在后面
    local GatherPlaceList = GatheringLogMgr:GetGatherPlaceByItemData(Item)
    if GatherPlaceList ~= nil and #GatherPlaceList > 1 then        
        for _, value in pairs(GatherPlaceList) do
            if value.MapID == MapID and value.ID ~= GatherPointID then
                table.insert(GatherPointList,{GatherPointID = value.ID, IsShowMakers = not value.bUnknownLoc})
            end
        end
    end   
    WorldMapMgr:ShowWorldMapGather(MapID, GatherPointList)
end

return GatheringLogAreaItemView
