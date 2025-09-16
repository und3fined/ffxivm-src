local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local SeriesMalmstoneBreakThroughCfg = require("TableCfg/SeriesMalmstoneBreakThroughCfg")
local PVPHonorCfg = require("TableCfg/PVPHonorCfg")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local PVPTypeStatisticsVM = require ("Game/PVP/VM/PVPTypeStatisticsVM")

local UIBindableList = require("UI/UIBindableList")

local GameType = ProtoCS.Game.PvPColosseum.PvPColosseumGameType
local GameMode = ProtoCS.Game.PvPColosseum.PvPColosseumMode
local TimeType = ProtoCS.Game.PvPColosseum.PvpColosseumBtlResultClass
local HonorType = ProtoRes.Game.pvp_badgetype

local EventID
local LSTR
local AchievementMgr

---@class PVPInfoVM : UIViewModel
local PVPInfoVM = LuaClass(UIViewModel)

---Ctor
function PVPInfoVM:Ctor()
	self:ResetData()
end

function PVPInfoVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
end

function PVPInfoVM:OnBegin()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnBegin函数
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	LSTR = _G.LSTR
	EventID = _G.EventID
	AchievementMgr = _G.AchievementMgr
	--为了实现国际化，除日志外的需要翻译的字符串要通过"LSTR"函数获取
	--富文本的标签不用翻译，建议用RichTextUtil中封装的接口获取。
	-- self.LocalString = LSTR("中文")
	-- self.TextColor = "ff0000ff"
	-- self.ProfID = ProfType.PROF_TYPE_PALADIN
end

function PVPInfoVM:OnEnd()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnEnd函数
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
	self:ResetData()
	LSTR = nil
	EventID = nil
	AchievementMgr = nil
end

function PVPInfoVM:OnShutdown()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnShutdown函数
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function PVPInfoVM:ResetData()
	-- 对战资料总览数据
	self.PVPTitleID = 0
	self.PVPLikedCount = 0
	self.CrystallineBattleCount = 0
	self.FrontlineBattleCount = 0
	self.IsSeriesOpening = false
	self.SeriesData = nil
	self.HasSeriesReward = false
	self.NeedBreakThrough = false
	self.HonorData = nil
	self.MostUsedProf = nil

	self.TypeStatistic = {
		[GameType.Crystal] = PVPTypeStatisticsVM.New(GameType.Crystal),
		[GameType.FrontLine] = PVPTypeStatisticsVM.New(GameType.FrontLine),
	}
end

function PVPInfoVM:SetPVPOverviewData(Data)
	self.PVPTitleID = Data.BtlTitleID
	self.CrystallineBattleCount = Data.BtlNum
	self.PVPLikedCount = Data.LikedNum
	self:SetSeriesMalmstoneData(Data.PvpStarRoadSignsResult)
	self:SetHonorData(Data.PvpBadgeResult)
	self.MostUsedProf = Data.UseProfs
end

function PVPInfoVM:SetPVPCrystalData(Data)
	local CrystalVM = self:GetTypeStatistic(GameType.Crystal)
	if CrystalVM then
		CrystalVM:UpdateVM(Data)
	end
end

--- 获取玩法数据
---@param GameType ProtoCS.Game.PvPColosseum.PvPColosseumGameType PVP玩法
---@return Table 数据列表
function PVPInfoVM:GetTypeStatistic(GameType)
	return self.TypeStatistic and self.TypeStatistic[GameType] or {}
end

--- 检查星里路标是否开启中
function PVPInfoVM:CheckSeriesMalmstoneOpening()
	local CurSeasonCfg = _G.PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
	self.IsSeriesOpening =  CurSeasonCfg ~= nil
end

--- 获取星里路标是否开启中
---@return boolean 是否开启中
function PVPInfoVM:GetIsSeriesOpening()
	return self.IsSeriesOpening
end

--- 设置星里路标数据
---@param Data table PvpStarRoadSignsResult
function PVPInfoVM:SetSeriesMalmstoneData(Data)
	self.HasSeriesReward = self:CheckHasReward(Data)
	self.NeedBreakThrough = self:CheckNeedBreakthrough(Data)
	self.SeriesData = Data
end

--- 获取星里路标奖励数据
---@return table<int32, bool> 数据Map
function PVPInfoVM:GetSeriesMalmstoneRewardData()
	return self.SeriesData and self.SeriesData.Reward or nil
end

--- 获取星里路标等级
---@return int32 等级
function PVPInfoVM:GetSeriesMalmstoneLevel()
	return self.SeriesData and self.SeriesData.Level or 0
end

--- 设置荣耀徽章数据
---@param Data table PvpBadgeResult
function PVPInfoVM:SetHonorData(HonorData)
	self.HonorData = HonorData
end

--- 是否拥有某荣耀徽章
---@param HonorID uint32 荣耀徽章ID
---@return boolean 是否拥有
function PVPInfoVM:IsOwnHonor(HonorID)
	if self.HonorData then
		local HonorMap = self.HonorData.BadgeID
		return HonorMap and HonorMap[HonorID] ~= nil or false
	end
	return false
end

--- 获取荣耀徽章获得时间
---@param HonorID uint32 荣耀徽章ID
---@return uint32 获得时间
function PVPInfoVM:GetHonorGetTime(HonorID)
	if self.HonorData then
		local HonorMap = self.HonorData.BadgeID
		return HonorMap and HonorMap[HonorID] or 0
	end
	return 0
end

function PVPInfoVM:GetHonorParam(HonorID)
	if self.HonorData then
		local Cfg = PVPHonorCfg:FindCfgByKey(HonorID)
		local Type = Cfg and Cfg.Type or HonorType.BadgeType_None
		if Type ~= HonorType.BadgeType_None and Type ~= HonorType.BadgeType_MaxValue then
			if Type ~= HonorType.BadgeType_Terminator and Type ~= HonorType.BadgeType_CrystalTop then
				local ParamMap = self.HonorData.TypeParam
				return ParamMap and ParamMap[Type] or 0
			else
				if Type == HonorType.BadgeType_Terminator then
					local MapWinParam = self.HonorData.MapWinParam
					if MapWinParam then
						local LeastCount = 999
						-- 角力学校
						local PalaistraScenes = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_SCENEID_JLXX) or {}
						local PalaistraCount = 0
						-- 1, 2对应练习赛和段位赛，自定赛不用计算
						for Index = 1, 2 do
							local SceneID = PalaistraScenes.Value[Index]
							local ModeCount = MapWinParam[SceneID] or 0
							PalaistraCount = PalaistraCount + ModeCount
						end
						LeastCount = math.min(LeastCount, PalaistraCount)

						-- 火山之心
						local VolcanicHeartScenes = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_SCENEID_HSZX) or {}
						local VolcanicHeartCount = 0
						-- 1, 2对应练习赛和段位赛，自定赛不用计算
						for Index = 1, 2 do
							local SceneID = VolcanicHeartScenes.Value[Index]
							local ModeCount = MapWinParam[SceneID] or 0
							VolcanicHeartCount = VolcanicHeartCount + ModeCount
						end
						LeastCount = math.min(LeastCount, VolcanicHeartCount)

						-- 九霄云上
						local CloudNineScenes = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_SCENEID_JXYS) or {}
						local CloudNineCount = 0
						-- 1, 2对应练习赛和段位赛，自定赛不用计算
						for Index = 1, 2 do
							local SceneID = CloudNineScenes.Value[Index]
							local ModeCount = MapWinParam[SceneID] or 0
							CloudNineCount = CloudNineCount + ModeCount
						end
						LeastCount = math.min(LeastCount, CloudNineCount)

						return LeastCount
					end
				elseif Type == HonorType.BadgeType_CrystalTop then
					return AchievementMgr:GetAchievementFinishState(Cfg.AchievementID) and 1 or 0
				end
			end
		end
	end
	return 0
end

---@private
--- 检查是否有未领奖励
---@param SeriesData PvpStarRoadSignsResult 星里路标数据，不传就默认用缓存的数据
function PVPInfoVM:CheckHasReward(SeriesData)
	SeriesData = SeriesData or self.SeriesData
	local HasSeriesReward = false
	if SeriesData then
		for ID, IsReceived in pairs(SeriesData.Reward or {}) do
			if ID ~= 0 and IsReceived == false then
				HasSeriesReward = true
				break
			end
		end
	end
	return HasSeriesReward
end

--- 获取是否有未领奖励
function PVPInfoVM:GetHasSeriesReward()
	return self.HasSeriesReward
end

---@private
---@param SeriesData PvpStarRoadSignsResult 星里路标数据，不传就默认用缓存的数据
--- 检查是否要突破
function PVPInfoVM:CheckNeedBreakthrough(SeriesData)
	SeriesData = SeriesData or self.SeriesData
	local NeedBreakThrough = false
	local CurLevel = SeriesData.Level
	local NextLevel = CurLevel + 1
	local NextLevelCfg = _G.PVPInfoMgr:GetCurSeasonSeriesMalmstoneLevelCfg(NextLevel)
	if NextLevelCfg then
		for _, TargetID in pairs(NextLevelCfg.BreakThroughTarget or {}) do
            if TargetID ~= 0 then
                NeedBreakThrough = true
				break
            end
        end
	end
	return NeedBreakThrough
end

--- 获取是否要突破
function PVPInfoVM:GetNeedBreakThrough()
	return self.NeedBreakThrough
end

--- 是否已领取该等级奖励
---@param ID uint32 配置ID
---@return boolean 是否已领取
function PVPInfoVM:IsReceivedReward(ID)
	if self.SeriesData then
		local RewardMap = self.SeriesData.Reward
		return RewardMap and RewardMap[ID] == true or false
	end
	return false
end

--- 该目标是否已突破，只针对【还没突破的等级】，【已突破的等级】服务器会清空【目标】计数
---@param Level uint32 等级
---@return boolean 是否已突破
---@return int32 目标计数
function PVPInfoVM:IsTargetBrokeThrough(TargetID)
	if self.SeriesData then
		local TargetMap = self.SeriesData.TypeParam
		local Cfg = SeriesMalmstoneBreakThroughCfg:FindCfgByKey(TargetID)
		if TargetMap and Cfg then
			local TargetCount = TargetMap[TargetID]
			if TargetCount then
				return TargetCount >= Cfg.ConditionParam, TargetCount
			end
		end
	end
	return false, 0
end

---@private
--- 领取奖励后更新数据
function PVPInfoVM:UpdateSeriesMalmstoneRewardData(IDList)
	if IDList == nil or self.SeriesData == nil then return end
	
	local RewardMap = self.SeriesData.Reward
	if RewardMap then
		for _, ID in pairs(IDList) do
			if RewardMap[ID] ~= nil then
				RewardMap[ID] = true
			end
		end
	end

	self.HasSeriesReward = self:CheckHasReward()
end

--要返回当前类
return PVPInfoVM