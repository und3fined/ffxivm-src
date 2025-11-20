local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local SidepopupCfg = require("TableCfg/SidepopupCfg")
local TimeUtil = require("Utils/TimeUtil")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")

local SidePopUpMgr = _G.SidePopUpMgr
local UIType = ProtoRes.side_popup_type.SIDE_POPUP_UNLOCK_FASHION
---@class SidePopUpFashionVM : UIViewModel
local SidePopUpFashionVM = LuaClass(UIViewModel)

---Ctor
function SidePopUpFashionVM:Ctor()
    self.CDProgressPercent = nil
    self.CurrentItemVMList = UIBindableList.New(ItemVM, {IsShowNum = false, IsShowNumProgress = false, IsCanBeSelected = false})
   
end
	
function SidePopUpFashionVM:OnInit()
end

function SidePopUpFashionVM:OnBegin()

end

function SidePopUpFashionVM:OnEnd()

end

function SidePopUpFashionVM:OnShutdown()
end

function SidePopUpFashionVM:UpdateVM(ItemList)
    self.CurrentItemVMList:UpdateByValues(ItemList)
    self.CDProgressPercent = 1
end


function SidePopUpFashionVM:UpdateCDProgressPercent()
    local EndTime = SidePopUpMgr:GetDisplayedEndTime(UIType)
    local CDTime = SidepopupCfg:FindCfgByKey(UIType).ShowTime

    if CDTime == 0 or EndTime == 0 then
        return
    end

    self.CDProgressPercent = (EndTime - TimeUtil.GetServerTime())/CDTime
end

return SidePopUpFashionVM