---
--- Author: skysong
--- DateTime: 2025-05-16 10:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


local LSTR = _G.LSTR


---@class HouseWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrameS CommSidebarFrameSView
---@field CountSlider CommCountSliderView
---@field TextNum UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseWinView = LuaClass(UIView, true)

function HouseWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrameS = nil
	--self.CountSlider = nil
	--self.TextNum = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS)
	self:AddSubView(self.CountSlider)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseWinView:OnInit()

end

function HouseWinView:OnDestroy()

end

function HouseWinView:OnShow()
	local function OnValueChange(Value)
		self:OnValueChange(Value)
	end

	self.Parent = self.Params.Parent

	self.CommSidebarFrameS.CommonTitle.TextTitleName:SetText(LSTR(1640061))
	self.TextTitle:SetText(LSTR(1640062))
	UIUtil.SetIsVisible(self.CommSidebarFrameS.CommonTitle.CommInforBtn,false,false)
	self.CountSlider:SetSliderValueMaxMin(5, 0)
	self.CountSlider:SetValueChangedCallback(OnValueChange)
	self.CountSlider:SetSliderValue(_G.HousingMgr:GetLightPower())
	self.TextNum:SetText(tostring(_G.HousingMgr:GetLightPower()))
end

function HouseWinView:OnHide()

end

function HouseWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommSidebarFrameS.BtnClose.Btn_Close, self.OnClickClose)

end

function HouseWinView:OnRegisterGameEvent()

end

function HouseWinView:OnRegisterBinder()

end

--关闭更多面板
function HouseWinView:OnClickClose()
	self.Parent:OnCloseMoreView()
end

function HouseWinView:OnValueChange(Value)
	local SliderVM = self.CountSlider.ViewModel
	Value = math.ceil(Value)
	SliderVM.Percent = Value / 5
	self.TextNum:SetText(tostring(Value))

	if _G.HousingMgr.LightPower ~= Value then
		_G.HousingMgr:SetLightPower(Value)
		_G.HousingMgr:SendHouseSettingOneReq()
	end
end

--是否可以回收所有家具
function HouseWinView:CanRecycleAllFurniture()
	local FurnitureList = _G.HousingMgr:GetFurnitureList(_G.HousingMgr.HouseID,_G.HousingMgr.Region)

	local Depot = _G.HousingMgr:GetCurrentDepot()
	local HouseRegionCfg = _G.HousingMgr:GetHouseRegionCfg()

    if HouseRegionCfg ~= nil and Depot ~= nil then
        if HouseRegionCfg.DepotSize - (#Depot.ItemList + #FurnitureList.Entities) > 0 then
            return true
		end
	end

	return false
end

return HouseWinView