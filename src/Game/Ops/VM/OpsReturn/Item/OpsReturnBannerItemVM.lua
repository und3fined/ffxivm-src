--
-- Author: ZhengJanChuan
-- Date: 2025-07-22 20:12
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")


---@class OpsReturnContentpushBannerItemVM : UIViewModel
local OpsReturnContentpushBannerItemVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnContentpushBannerItemVM:Ctor()
    self.ID = nil
    self.BannerImg = nil
    self.IsSelected = false
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
    self.ID = Value.ID
    self.BannerImg = Value.BannerImg
end

--要返回当前类
return OpsReturnContentpushBannerItemVM