--
-- Author: ZhengJanChuan
-- Date: 2025-07-22 20:12
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local OpsReturnCfg = require("TableCfg/OpsReturnCfg")

---@class OpsReturnContentpushBannerItemVM : UIViewModel
local OpsReturnContentpushBannerItemVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnContentpushBannerItemVM:Ctor()
    self.IndexPos = 1  --用于定位
    self.BannerID = 0
    self.BannerTitle = ""
    self.IsSelected = false
    self.BannerImg = nil
end

function OpsReturnContentpushBannerItemVM:OnInit()
end

function OpsReturnContentpushBannerItemVM:OnBegin()
end

function OpsReturnContentpushBannerItemVM:OnEnd()
end

function OpsReturnContentpushBannerItemVM:OnShutdown()
end

function OpsReturnContentpushBannerItemVM:UpdateVM(Value)
    self.BannerID = Value.BannerID
    if self.BannerID ~= nil then
        local Cfg = OpsReturnCfg:FindCfgByKey(self.BannerID)
        if Cfg ~= nil then
            self.BannerTitle = Cfg.Title
            self.BannerImg = Cfg.Banner
        end
    end
    self.IsSelected  = Value.IsSelected
    self.IndexPos = Value.IndexPos or 1
end

function OpsReturnContentpushBannerItemVM:IsEqualVM(Value)
    return false
end

function OpsReturnContentpushBannerItemVM:SetSelected(IsSelected)
    self.IsSelected = IsSelected
end

--要返回当前类
return OpsReturnContentpushBannerItemVM