--
-- Author: anypkvcai
-- Date: 2020-10-27 16:41:19
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local TimeUtil = require("Utils/TimeUtil")
local UIViewMgr = require("UI/UIViewMgr")

local FLOG_ERROR = _G.FLOG_ERROR

local CommonTipsView = LuaClass(UIView, true)

---@class CommonTipsView : UIView
function CommonTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Item1 = nil
    --self.Item2 = nil
    --self.Item3 = nil
    --self.Item4 = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Item1)
    self:AddSubView(self.Item2)
    self:AddSubView(self.Item3)
    self:AddSubView(self.Item4)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
    self.TipsItems = nil
    self.LastTime = 0
    self.QueueTips = {}
end

function CommonTipsView:OnInit()
    self.VisibleItems = {}
    self.TipsItems = {self.Item1, self.Item2, self.Item3, self.Item4}
    for _, v in ipairs(self.TipsItems) do
        UIViewMgr:HideSubView(v)
    end
end

function CommonTipsView:OnDestroy()
end

function CommonTipsView:OnShow()
    --if nil ~= self.Text_Desc then
    --	self.Text_Desc:SetText(self.Params.content)
    --end
    --
    --if nil ~= self.Fly then
    --	self:PlayAnimation(self.Fly)
    --end
end

function CommonTipsView:OnHide()
    if self.VisibleItems then
        for i, v in ipairs(self.VisibleItems) do
            UIViewMgr:HideSubView(v)
            table.remove(self.VisibleItems, i)
            table.insert(self.TipsItems, v)
        end
    end
    table.clear(self.QueueTips)
end

function CommonTipsView:OnRegisterUIEvent()
end

function CommonTipsView:OnRegisterGameEvent()
end

function CommonTipsView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
end

function CommonTipsView:OnRegisterBinder()
end

function CommonTipsView:OnTimer()
    --local Content = next(self.QueueTips)
    --if nil == Content then return end

    local QueueTips = self.QueueTips
    local Tips = QueueTips[1]
    if nil == Tips then
        return
    end

    local TimeStamp = TimeUtil.GetLocalTimeMS()
    local LastTime = self.LastTime
    if TimeStamp - LastTime >= 400 then
        self:ShowTipsInternal(Tips)
        self.LastTime = TimeUtil.GetLocalTimeMS()
        table.remove(QueueTips, 1)

        local CheckRepeatedTime = Tips.SubmitTime + Tips.ShowTime
        local RemoveArr = {}
        local TipsCount = #QueueTips
        for i = 1, TipsCount do
            if QueueTips[i].SubmitTime > CheckRepeatedTime then
                break
            end
            if Tips.Content == QueueTips[i].Content then
                table.insert(RemoveArr, i)
            end
        end
        local RemoveCount = #RemoveArr
        for i = RemoveCount, 1, -1 do
            table.remove(QueueTips, RemoveArr[i])
        end
    end
end

function CommonTipsView:ShowTips(Content, SoundName, ShowTime)
    -- 加入队列前判断一下, 如果当前正在播放相同的提示, 不再重复加入队列
    if self:IsSubViewVisible() then
        local VisibleItem = self.VisibleItems[1]
        if VisibleItem and VisibleItem.Params and VisibleItem.Params.Content == Content then
            return
        end 
    end
    table.insert(
        self.QueueTips,
        {Content = Content, SoundName = SoundName, ShowTime = ShowTime, SubmitTime = TimeUtil.GetLocalTimeMS()}
    )
end

function CommonTipsView:ShowTipsInternal(Tips)
    if #self.TipsItems <= 0 then
        FLOG_ERROR("CommonTipsView:AddTips error")
        return
    end

    local Item = table.remove(self.TipsItems, 1)
    table.insert(self.VisibleItems, Item)

    local function callback(InItem)
        for i, v in ipairs(self.VisibleItems) do
            if v == InItem then
                UIViewMgr:HideSubView(InItem)
                table.remove(self.VisibleItems, i)
                table.insert(self.TipsItems, v)
                break
            end
        end
    end

    local Params = {
        Content = Tips.Content,
        SoundName = Tips.SoundName,
        ShowTime = Tips.ShowTime,
        AniCallback = callback
    }

    UIViewMgr:ShowSubView(Item, Params)

    local PrevItem = self.VisibleItems[#self.VisibleItems - 1]

    if (PrevItem ~= nil) then
        PrevItem:PlayOffsetAnimation()
    end
end

function CommonTipsView:IsSubViewVisible()
    return self.VisibleItems and #self.VisibleItems > 0
end

function CommonTipsView:IsTipsComplete()
    return (self.QueueTips[1] == nil) and (not self:IsSubViewVisible())
end

function CommonTipsView:ForceOffline()
    if self:IsSubViewVisible() then 
        local PrevItem = self.VisibleItems[1]
        if (PrevItem ~= nil) then
            PrevItem:PlayOffsetAnimation()
        end
    end
end

return CommonTipsView
