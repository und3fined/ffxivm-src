---
--- Author: michaelyagn_lightpaw
--- DateTime: 2024-08-26 10:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")

local MusicPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Fate_S_Enc.Play_Zingle_Fate_S_Enc'"

---@class InfoFateTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFate UFImage
---@field ImgFateLoser UFImage
---@field ImgFateLoserMask UFImage
---@field ImgFateMask UFImage
---@field PanelFate UFCanvasPanel
---@field PanelFateLoser UFCanvasPanel
---@field TextFateLoserSubTitle UFTextBlock
---@field TextFateLoserTitle UFTextBlock
---@field TextFateSubTitle UFTextBlock
---@field TextFateTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoFateTipsView = LuaClass(UIView, true)

function InfoFateTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgFate = nil
    --self.ImgFateLoser = nil
    --self.ImgFateLoserMask = nil
    --self.ImgFateMask = nil
    --self.PanelFate = nil
    --self.PanelFateLoser = nil
    --self.TextFateLoserSubTitle = nil
    --self.TextFateLoserTitle = nil
    --self.TextFateSubTitle = nil
    --self.TextFateTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoFateTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoFateTipsView:OnInit()
    
end

function InfoFateTipsView:OnDestroy()
end

function InfoFateTipsView:OnShow()
    if (_G.FateMgr:IsCurFateHighRisk()) then
        local Str = string.format(LSTR(190126), LSTR(190116)) -- %s·高危
        self.TextFateTitle:SetText(Str)
    else
        local CurrentFate = _G.FateMgr:GetCurrentFate()
        if (CurrentFate ~= nil) then
            local FateCfg = _G.FateMgr:GetFateCfg(CurrentFate.ID)
            if (FateCfg ~= nil and FateCfg.bHideInArchive ~= nil and FateCfg.bHideInArchive > 0) then
                -- 这里是庆典标题
                self.TextFateTitle:SetText(string.format(LSTR(190130), FateCfg.Title))
            else
                -- 这里是普通的标题
                self.TextFateTitle:SetText(LSTR(190116))
            end
        else
            -- 这里是获取不到数据，提示用的
            _G.FLOG_ERROR("当前FATE不存在，使用默认提示")
            self.TextFateTitle:SetText(LSTR(190116))
        end
    end
    AudioUtil.LoadAndPlayUISound(MusicPath, nil)
end

function InfoFateTipsView:OnHide()
end

function InfoFateTipsView:OnRegisterUIEvent()
end

function InfoFateTipsView:OnRegisterGameEvent()
end

function InfoFateTipsView:OnRegisterBinder()
end

return InfoFateTipsView
