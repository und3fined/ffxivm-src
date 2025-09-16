---
--- Author: zimuyi
--- DateTime: 2021-08-13 20:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local DialogueUtil = require("Utils/DialogueUtil")
local ObjectGCType = require("Define/ObjectGCType")
local SpeechBubbleMgr = require("Game/Npc/SpeechBubbleMgr")
local UHUDMgr = nil

local HUDMgr = _G.HUDMgr
local DefaultOffsetZ = 15
local HPBarOffsetZ = 20

local BubbleBPPath = {
    [ProtoRes.bubble_style.BUBBLE_STYLE_NORMAL] = "NPCTalk/NPCTextBubbleNormalItem_UIBP",
    [ProtoRes.bubble_style.BUBBLE_STYLE_ACCENT] = "NPCTalk/NPCTextBubbleFocusItem_UIBP",
}

---@class SpeechBubblePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanvasPanel_Main UCanvasPanel
---@field SpeechBubble_UIBP SpeechBubbleView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SpeechBubblePanelView = LuaClass(UIView, true)

function SpeechBubblePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.CanvasPanel_Main = nil
	self.SpeechBubble_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    UHUDMgr = _G.UE.UHUDMgr:Get()
end

function SpeechBubblePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SpeechBubble_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SpeechBubblePanelView:UpdateBubblePos(ActorEntityID)
    local BubbleInfo = self.BubbleList[ActorEntityID]
    if BubbleInfo == nil then
        return
    end

    local BubbleView = BubbleInfo.BubbleView
    if BubbleView == nil then
        return
    end

    local Npc = ActorUtil.GetActorByEntityID(ActorEntityID)
    if Npc == nil or _G.UE.UCommonUtil.IsObjectValid(Npc) == false then
        self:HideBubbleView({EntityID = ActorEntityID}) -- 找不到实体则隐藏气泡
        return
    else
        local BubbleID = BubbleInfo.BubbleID
        if BubbleID and BubbleID > 0 then
            local DistanceToMajor = Npc:GetDistanceToMajor()
            local BubbleInfo = SpeechBubbleMgr:GetBubbleInfoByBubbleID(BubbleID)
            if BubbleInfo then
                if BubbleInfo.MaxDistance < DistanceToMajor then
                    self:HideBubbleView({EntityID = ActorEntityID}) -- 超出气泡显示范围
                    return
                end
            end
        end
    end

    local Actor = ActorUtil.GetActorByEntityID(ActorEntityID)
        if Actor then
        end

    local HeadLocation =  Npc:Cast(_G.UE.ABaseCharacter):GetSocketLocationByName("head_M")
    
    local ActorHudVM = HUDMgr:GetActorVM(ActorEntityID)
    local ActorName = ActorHudVM and ActorHudVM.GetActorName(ActorEntityID) or ""
    local HPBarVisible = ActorHudVM and ActorHudVM.HPBarVisible
    
    local BubbleSize = BubbleView:GetDesiredSize()
    local CorrectScreeLocation = _G.UE.FVector2D()

    -- 如果对象没有名字等头顶信息，则气泡随骨骼运动
    if string.isnilorempty(ActorName) then
        HeadLocation.Z = HeadLocation.Z + DefaultOffsetZ
        if HPBarVisible then
            HeadLocation.Z = HeadLocation.Z + HPBarOffsetZ
        end
        local ScreenLocation = _G.UE.FVector2D()
        UIUtil.ProjectWorldLocationToScreen(HeadLocation, ScreenLocation, false)
        ScreenLocation = ScreenLocation / self.DPIScale
        --气泡以左上角为锚点，所以根据气泡实际尺寸做个偏移至中下方
        CorrectScreeLocation = _G.UE.FVector2D(ScreenLocation.X - BubbleSize.X/2, ScreenLocation.Y - BubbleSize.Y)
    else
        -- 取名字HUD控件的高度
        local HUDActorView = HUDMgr:GetActorView(ActorEntityID)
        if HUDActorView then
            local UHUDMgr = _G.UE.UHUDMgr:Get()
            if UHUDMgr then
                local HUDPosition = UHUDMgr:GetPosition(HUDActorView.Object)
                local HUDSize = UHUDMgr:GetSize(HUDActorView.Object) * self.DPIScale
                if HUDSize and HUDPosition then
                    CorrectScreeLocation = _G.UE.FVector2D(HUDPosition.X , HUDPosition.Y - HUDSize.Y - BubbleSize.Y)
                    CorrectScreeLocation = CorrectScreeLocation / self.DPIScale
                    CorrectScreeLocation.X = CorrectScreeLocation.X - BubbleSize.X/2
                end
            end
        end
    end
    BubbleView.Slot:SetPosition(CorrectScreeLocation)
end

function SpeechBubblePanelView:Tick(_, InDeltaTime)
    for EntityID, SpeechBubble in pairs(self.BubbleList) do
        local BubbleView = SpeechBubble.BubbleView
        if BubbleView and BubbleView:IsVisible()then
            self:UpdateBubblePos(EntityID)
        end
    end
end

function SpeechBubblePanelView:OnInit()
    self.BubbleViewZOrder = 0
    self.BubbleList = {}
    self.BubbleViewCache = {}
    self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
    -- FLOG_ERROR("[SpeechBubbleMgr] OnInit")
end

function SpeechBubblePanelView:OnDestroy()
    self.BubbleViewZOrder = 0
end

function SpeechBubblePanelView:OnShow()
    print("SpeechBubblePanelView:OnShow")
end

function SpeechBubblePanelView:OnHide()

end

function SpeechBubblePanelView:OnRegisterUIEvent()

end

function SpeechBubblePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ShowSpeechBubble, self.ShowBubbleView)
    self:RegisterGameEvent(EventID.HideSpeechBubble, self.HideBubbleView)
    self:RegisterGameEvent(EventID.ShowSpeechBubbleAll, self.OnShowSpeechBubbleAll)
end

function SpeechBubblePanelView:OnRegisterTimer()

end

function SpeechBubblePanelView:OnRegisterBinder()

end

function SpeechBubblePanelView:GetBubble(BubbleStyle, BubbleID)
    local SpeechBubbleView = nil
    local BubbleList = self.BubbleViewCache and self.BubbleViewCache[BubbleStyle]
    if BubbleList and #BubbleList > 0 then
        local BubbleInfo = table.remove(BubbleList, 1)
        if BubbleInfo then
            SpeechBubbleView = BubbleInfo.BubbleView
        end
    end

    if SpeechBubbleView == nil then
        local BPName = BubbleBPPath[BubbleStyle]
        -- 气泡类型为空时，默认用第一个
        if string.isnilorempty(BPName) then
            BPName = BubbleBPPath[ProtoRes.bubble_style.BUBBLE_STYLE_NORMAL]
        end
        SpeechBubbleView = _G.UIViewMgr:CreateViewByName(BPName, ObjectGCType.LRU, self, true, true)
    end

    if SpeechBubbleView == nil then
        return
    end

    self.CanvasPanel_Main:AddChildToCanvas(SpeechBubbleView)
    UIUtil.SetIsVisible(SpeechBubbleView, true, false)
    SpeechBubbleView:PlayAnimIn()
    local SpeechBubbleInfo = {
        BubbleView = SpeechBubbleView,
        BubbleStyle = BubbleStyle,
        BubbleID = BubbleID,
    }
   
    return SpeechBubbleInfo
end

function SpeechBubblePanelView:PushBubbleView(EntityID)
    local SpeechBubble = self.BubbleList[EntityID]
    if (SpeechBubble == nil) then
        return
    end

    local BubbleView = SpeechBubble.BubbleView
    if BubbleView then
        UIUtil.SetIsVisible(BubbleView, false, false)
    end
    
    local BubbleStyle = SpeechBubble.BubbleStyle
    if BubbleStyle then
        if self.BubbleViewCache[BubbleStyle] == nil then
            self.BubbleViewCache[BubbleStyle] = {}
        end
    end

    if self.BubbleViewCache[BubbleStyle] then
        table.insert(self.BubbleViewCache[BubbleStyle], SpeechBubble)
    end

    self.BubbleList[EntityID] = nil
end

function SpeechBubblePanelView:ShowBubbleView(Params)
    if Params == nil then
        return
    end
    local ActorEntityID = Params.EntityID
    local Content = DialogueUtil.ParseLabel(Params.Content)
    local BubbleStyle = Params.BubbleStyle
    local BubbleID = Params.BubbleID

    if string.isnilorempty(Content) then
        return
    end

    if ActorEntityID == nil then
        return
    end

    if (self.BubbleList[ActorEntityID] == nil) then
        self.BubbleList[ActorEntityID] = self:GetBubble(BubbleStyle, BubbleID)
    end

    local BubbleInfo = self.BubbleList[ActorEntityID]
    if BubbleInfo == nil then
        return
    end

    local BubbleView = BubbleInfo.BubbleView
    if BubbleView == nil then
        return
    end

    BubbleView:SetContent(Content)
    self.BubbleViewZOrder = self.BubbleViewZOrder + 1
    UIUtil.CanvasSlotSetZOrder(BubbleView, self.BubbleViewZOrder)
    self:UpdateBubblePos(ActorEntityID)
end

function SpeechBubblePanelView:HideBubbleView(Params)
    if Params == nil then
        return
    end

    local EntityID = Params.EntityID
    local CallBack = Params.CallBack
    if EntityID == nil then
        return
    end
    
    local BubbleInfo = self.BubbleList[EntityID]
    if BubbleInfo == nil then
        return
    end
    
    local BubbleView = BubbleInfo.BubbleView
    if (BubbleView == nil or _G.UE.UCommonUtil.IsObjectValid(BubbleView) == false) then
        return
    end
    
    if (BubbleView:IsVisible()) then
        UIUtil.CanvasSlotSetZOrder(BubbleView, 0)
        self:PushBubbleView(EntityID)
    end

    if (CallBack ~= nil) then
        CallBack()
    end
end

function SpeechBubblePanelView:OnShowSpeechBubbleAll(IsShow)
    UIUtil.SetIsVisible(self.CanvasPanel_Main, IsShow)
end

return SpeechBubblePanelView