---
--- Author: Administrator
--- DateTime: 2024-07-08 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoSceneUtil = require("Game/Photo/Util/PhotoSceneUtil")

local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local FVector2D = _G.UE.FVector2D
local PhotoSceneVM
local FMath = _G.UE.UMathUtil
local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoMgr
local FVector2D = _G.UE.FVector2D
local PhotoVM
local PhotoCamVM
local PhotoFilterVM
local PhotoDarkEdgeVM
local PhotoRoleSettingVM
local PhotoSceneVM
local PhotoTemplateVM
local PhotoActionVM
local PhotoEmojiVM
local PhotoRoleStatVM

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetRenderTransformAngle = require("Binder/UIBinderSetRenderTransformAngle")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")

---@class PhotoTimeWeatherPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPointer UFButton
---@field BtnTime01 UFButton
---@field BtnTime02 UFButton
---@field BtnTime03 UFButton
---@field BtnTime04 UFButton
---@field ImgSelectTime01 UFImage
---@field ImgSelectTime02 UFImage
---@field ImgSelectTime03 UFImage
---@field ImgSelectTime04 UFImage
---@field TableViewWeather UTableView
---@field TextEditTime UFTextBlock
---@field TouchItemTime PhotoTouchItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoTimeWeatherPanelView = LuaClass(UIView, true)

function PhotoTimeWeatherPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPointer = nil
	--self.BtnTime01 = nil
	--self.BtnTime02 = nil
	--self.BtnTime03 = nil
	--self.BtnTime04 = nil
	--self.ImgSelectTime01 = nil
	--self.ImgSelectTime02 = nil
	--self.ImgSelectTime03 = nil
	--self.ImgSelectTime04 = nil
	--self.TableViewWeather = nil
	--self.TextEditTime = nil
	--self.TouchItemTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoTimeWeatherPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TouchItemTime)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoTimeWeatherPanelView:OnInit()
	self.TextEditTime:SetText(_G.LSTR(630056))
	self.TextTime:SetText(_G.LSTR(630055))

	PhotoSceneVM = _G.PhotoSceneVM

	self.AdpWeather 			= UIAdapterTableView.CreateAdapter(self, self.TableViewWeather, self.OnAdpItemWeather)

	self:InitTouchItemTime()

	self.BinderScene = 
	{
		{ "TimeArwAng", 			UIBinderSetRenderTransformAngle.New(self, self.RotateNode) },
		{ "T0", 					UIBinderSetIsVisible.New(self, self.ImgSelectTime01) },
		{ "T6", 					UIBinderSetIsVisible.New(self, self.ImgSelectTime04) },
		{ "T12", 					UIBinderSetIsVisible.New(self, self.ImgSelectTime03) },
		{ "T18", 					UIBinderSetIsVisible.New(self, self.ImgSelectTime02) },
		{ "WeatherTipsOpa", 		UIBinderSetRenderOpacity.New(self, self.TextEditTime) },
		{ "WeatherList",          	UIBinderUpdateBindableList.New(self, self.AdpWeather) },
		{ "WeatherSeltIdx",         UIBinderSetSelectedIndex.New(self, self.AdpWeather)},
		{ "WeatherName", 			UIBinderSetText.New(self, self.TextWeather) },

		{ "IsShowAdjustTips", 		UIBinderSetIsVisible.New(self, self.TextEditTime) },
	}
end

function PhotoTimeWeatherPanelView:OnDestroy()

end

function PhotoTimeWeatherPanelView:OnShow()
	
end

function PhotoTimeWeatherPanelView:OnHide()

end

function PhotoTimeWeatherPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,              self.BtnTime01,    			self.OnBtnWeahterT12)
	UIUtil.AddOnClickedEvent(self,              self.BtnTime04,    			self.OnBtnWeahterT18)
	UIUtil.AddOnClickedEvent(self,              self.BtnTime03,    			self.OnBtnWeahterT00)
	UIUtil.AddOnClickedEvent(self,              self.BtnTime02,    			self.OnBtnWeahterT06)
end

function PhotoTimeWeatherPanelView:OnRegisterGameEvent()

end

function PhotoTimeWeatherPanelView:OnRegisterBinder()
	self:RegisterBinders(PhotoSceneVM, 			self.BinderScene)
end

function PhotoTimeWeatherPanelView:OnBtnWeahterT12()
	PhotoSceneVM:SetTimeArwAngAndPauseWeather(0)
end

function PhotoTimeWeatherPanelView:OnBtnWeahterT18()
	PhotoSceneVM:SetTimeArwAngAndPauseWeather(90)
end

function PhotoTimeWeatherPanelView:OnBtnWeahterT00()
	PhotoSceneVM:SetTimeArwAngAndPauseWeather(180)
end

function PhotoTimeWeatherPanelView:OnBtnWeahterT06()
	PhotoSceneVM:SetTimeArwAngAndPauseWeather(270)
end

function PhotoTimeWeatherPanelView:OnAdpItemWeather(Idx, ItemVM)
	PhotoSceneVM:SetWeatherSeltIdx(Idx)
end

function PhotoTimeWeatherPanelView:InitTouchItemTime()
	self.TouchItemTime.View = self
	self.TouchItemTime.TouchStartCB = self.OnTouchStartTime
	self.TouchItemTime.TouchMoveCB = self.OnTouchMoveTime
	self.TouchItemTime.TouchEndCB = self.OnTouchEndTime

	self.TouchPosTime = nil
	self.TouchPosTimeOri = FVector2D(224, 224)
end

function PhotoTimeWeatherPanelView:OnTouchStartTime(Pos)
	self:UpdTouchPos(Pos)
	PhotoSceneVM.WeatherTipsOpa = 0
	-- _G.FLOG_INFO('Andre.PhotoMainView:OnTouchStart X = ' .. tostring(Pos.X) .. " Y = " .. tostring(Pos.Y))
end

function PhotoTimeWeatherPanelView:OnTouchMoveTime(Pos)
	if not self.TouchPosTime then
		return
	end

	self:UpdTouchPos(Pos)
end

function PhotoTimeWeatherPanelView:OnTouchEndTime(Pos)
	self.TouchPosTime = nil
	PhotoSceneVM.WeatherTipsOpa = 1

end

function PhotoTimeWeatherPanelView:UpdTouchPos(Pos)
	local Offset = FVector2D(Pos.X - self.TouchPosTimeOri.X, Pos.Y - self.TouchPosTimeOri.Y)
	local Rad = FMath.Atan2(Offset.Y, Offset.X)
	local Angle = FMath.RadiansToDegrees(Rad)
	PhotoSceneVM:SetTimeArwAngAndPauseWeather(Angle + 90)
	self.TouchPosTime = Pos
end

function PhotoTimeWeatherPanelView:OnRegisterTimer()
	-- OnTimer, Delay, Inv, Loop
    self:RegisterTimer(self.OnTimer, 0, 5, 0)
end

function PhotoTimeWeatherPanelView:OnTimer()
	if _G.PhotoVM.IsPauseWeather then
		return
	end
    local Now = PhotoSceneUtil.GetOneDaySec()
	local Time = Now
	PhotoSceneVM:SetAngByTimeWithTimeOffset(Time)
end

return PhotoTimeWeatherPanelView