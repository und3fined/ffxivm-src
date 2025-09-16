--
-- Author: jianweili
-- Date: 2020-09-03 11:03:50
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local CommonUtil = require("Utils/CommonUtil")
local MapCfg = require("TableCfg/MapCfg")
local PWorldCfg = require("TableCfg/PworldCfg")

local LoadingScreenView = LuaClass(UIView, true)

function LoadingScreenView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingScreenView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingScreenView:OnInit()
	--UIUtil.SetIsVisible(self.Rote, false)
end

function LoadingScreenView:OnDestroy()

end

function LoadingScreenView:OnShow()
	--if PWorldMgr:IsShowLoading() then
	--if WorldMsgMgr:IsSpecial() then
	--    UIUtil.ImageSetColorAndOpacity(self.BG, 1, 1, 1, 1)
	--else
	--    UIUtil.ImageSetColorAndOpacity(self.BG, 0, 0, 0, 1)
	--end

	-- UIUtil.ImageSetColorAndOpacity(self.BG, 0, 0, 0, 1)

	-- if CommonUtil.IsWithEditor() then
	-- 	UIUtil.SetIsVisible(self.Rote, true)
	-- 	self:PlayAnimation(self.Rotation, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, 2.0)
	-- else
	-- 	UIUtil.SetIsVisible(self.Rote, false)
	-- end
end

function LoadingScreenView:OnHide()

end

function LoadingScreenView:OnRegisterUIEvent()

end

function LoadingScreenView:OnRegisterGameEvent()

end

function LoadingScreenView:OnRegisterTimer()

end

function LoadingScreenView:OnRegisterBinder()

end


function LoadingScreenView:ShowMapTips(Params)
	UIUtil.SetIsVisible(self.MapTips, true)
	--local Params = { CurrPWorldResID = PWorldID, MapResID = MapID, AnimInDelayTime = AnimInDelayTime, ShowDuration = ShowDuration }
	print("LoadingScreenview ShowMapTips")
	self.MapTips.Params = Params
	print(Params)
	self.MapTips:OnShow()
end

function LoadingScreenView:HideMapTips()
	self.MapTips:OnHide()
	UIUtil.SetIsVisible(self.MapTips, false)
end

--function LoadingScreenView:PlayLoadingAnim(bLoginToMain)
--	UIUtil.SetIsVisible(self.LoadingRote,not bLoginToMain)
--	UIUtil.SetIsVisible(self.LoadingGIF,bLoginToMain)
--
--	if bLoginToMain then
--		if self.LoadingGIF.AnimLoop ~= nil then
--			self:PlayAnimation(self.LoadingGIF.AnimLoop,0.0,100)
--		end
--	else
--		-- 播放转菊花动效
--		if self.Rotation ~= nil then
--			self:PlayAnimation(self.Rotation)
--		end
--	end
--end
function LoadingScreenView:PlayLoadingAnim(bLoginToMain)
	UIUtil.SetIsVisible(self.LoadingRote,true)
	UIUtil.SetIsVisible(self.LoadingGIF,false)

	if self.Rotation ~= nil then
		self:PlayAnimation(self.Rotation)
	end
end

function LoadingScreenView:StartLoading(LoadingInfo)
	local PWorldMgr = _G.PWorldMgr
	local WorldMsgMgr = _G.WorldMsgMgr

	-- 黑色背景
	UIUtil.ImageSetColorAndOpacity(self.BG, 0, 0, 0, 1)

	if not (PWorldMgr == nil or WorldMsgMgr == nil or PWorldMgr.BaseInfo == nil) then
		local BaseInfo = PWorldMgr.BaseInfo
		if (BaseInfo == nil) then
			print("LoadingScreenView BaseInfo is nil")
			return
		end
		if (BaseInfo.CurrMapResID == nil or BaseInfo.LastMapResID == nil or BaseInfo.CurrPWorldResID == nil or BaseInfo.LastPWorldResID == nil) then
			print("LoadingScreenView BaseInfo CurrMapResID or LastMapResID or CurrPWorldResID or LastPWorldResID is nil")
			return
		end
		local CurrMapResID = BaseInfo.CurrMapResID --PWorldMgr:GetCurrMapResID()
		local LastMapResID = BaseInfo.LastMapResID
		local CurrPWorldResID = BaseInfo.CurrPWorldResID -- PWorldMgr:GetCurrCurrPWorldResID()
		local LastPWorldResID = BaseInfo.LastPWorldResID
		local LastTransMapResID = BaseInfo.LastTransMapResID

		local bLoginToMain = (LastMapResID == 0) and (not (CurrMapResID == 0));
		local bToLogin = (CurrMapResID == 1047);

		print("LoadingScreenView CurrMapResID:"..CurrMapResID)
		print("LoadingScreenView LastMapResID:"..LastMapResID)
		print("LoadingScreenView LastTransMapResID:"..LastTransMapResID)
		print("LoadingScreenView CurrPWorldResID:"..CurrPWorldResID)
		print("LoadingScreenView LastPWorldResID:"..LastPWorldResID)
		print("LoadingScreenView bLoginToMain:"..tostring(bLoginToMain))
		print("from "..LoadingInfo.OldMap.." to "..LoadingInfo.NewMap)

		local Params = { CurrPWorldResID = CurrPWorldResID, MapResID = CurrMapResID, AnimInDelayTime = 0.0, ShowDuration = 1000.0 }
		-- Loading动效
		self:PlayLoadingAnim(bLoginToMain)

		local bIsTransInSameMap = PWorldMgr:IsTransInSameMap()
		if (not bIsTransInSameMap) then
			local CurrMapCfg = PWorldMgr:GetMapTableCfg(CurrMapResID)
			if CurrMapCfg ~= nil then
				--print(MapCfg.DisplayName)
				--self:ShowMapTips(Params)
				if bLoginToMain or bToLogin then
					-- Login到主城 / 主城到login
					local MapLoadingImagePath = CurrMapCfg.LoadingBGPath
					local bValidImagePath = not (MapLoadingImagePath == "")

					if bValidImagePath then
						print("LoadingScreenView "..CurrMapCfg.DisplayName.." "..MapLoadingImagePath)
						local ImageObject = LoadObject(MapLoadingImagePath)
						if not (ImageObject == nil) then
							self:SetBackgroundImage(ImageObject)
							UIUtil.ImageSetColorAndOpacity(self.BG, 1, 1, 1, 1)
						end
					else
						print("LoadingScreenView MapLoadingImagePath is empty")
					end
				else
					local bChangeMap = false
					if (LastMapResID ~= CurrMapResID) then
						bChangeMap = true
					end

					local bChangeRegion = false
					if (LastPWorldResID ~= CurrPWorldResID) then
						bChangeRegion = true
					end

					local bShowRegionName = CurrMapCfg.ShowRegionName == 1
					print("LoadingScreenView bChangeMap: "..tostring(bChangeMap).." bChangeRegion: "..tostring(bChangeRegion).." ShowRegionName: "..tostring(bShowRegionName))
					if (bChangeMap and bChangeRegion) and bShowRegionName then
						-- 切换副本：主城 -> 副本，显示地图Tips
						self:ShowMapTips(Params)
					end
				end
			else
				print("LoadingScreenView MapLoadingImagePath is empty")
			end
		else
			local bChangeMap = false
			if (LastMapResID ~= CurrMapResID) then
				bChangeMap = true
			end

			--同地图传送
			if (LastTransMapResID == CurrMapResID) then
				bChangeMap = false
			end

			local bChangeRegion = false
			if (LastPWorldResID ~= CurrPWorldResID) then
				bChangeRegion = true
			end

			local bShowRegionName = MapCfg.ShowRegionName == 1
			print("LoadingScreenView bChangeMap: "..tostring(bChangeMap).." bChangeRegion: "..tostring(bChangeRegion).." ShowRegionName: "..tostring(bShowRegionName))
			if (bChangeMap and bChangeRegion) and bShowRegionName then
				-- 切换副本：主城 -> 副本，显示地图Tips
				self:ShowMapTips(Params)
			end
		end
	else
		print("LoadingScreenView PWorldMgr is nil")
	end
end

function LoadingScreenView:StopLoading()
	self:HideMapTips()
end

return LoadingScreenView