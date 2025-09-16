local LuaClass = require("Core/LuaClass")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")
local MajorUtil = require("Utils/MajorUtil")
local MPPlayData = require("Game/MusicPerformance/MPPlayData")
local ActorUtil = require("Utils/ActorUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

local MPCharacter = LuaClass()

-- @todo:支持和音，长按最后一个按键抬起时才停止播动作
function MPCharacter:Ctor()
end

function MPCharacter:Initialize(Index)
	MusicPerformanceUtil.Log(string.format("MPCharacter:Initialize EntityID : %s", tostring(Index)))
	self.Group = {}
	for i = 0, MPDefines.GroupMax - 1 do
		self.Group[i] = 0
	end

	self.Time = 0
	self.Index = Index
	self.KeyTimeline = ""
	self.Status = MPDefines.PerformCharacterStatus.STS_INVALID
	self.PerformDataID = 0
	self.Timbre = 0
	self.GroupCount = 0
	self.InterruptFlag = false --是否能中断动作的标签
	self.IdleTimelineID = nil
	self.StartTimelineID = nil

	self.KeySet = {}

	self.PlayData = MPPlayData.New()
	self.PlayData:Initialize()

	self.PrevTimelineID = nil
	self.PrevAnimationQueueID = nil
end

function MPCharacter:Start(EntityID, PerformDataID)
	MusicPerformanceUtil.Log(string.format("MPCharacter:Start EntityID : %d PerformDataID : %d", EntityID, PerformDataID))
	if PerformDataID == 0 then
		return
	end

	for i = 0, MPDefines.GroupMax - 1 do
		self.Group[i] = 0
	end
	self.PerformDataID = PerformDataID
	self.Timbre = 0
	self.GroupCount = 0

	local PerformData = self:GetData()
	if nil == PerformData then
		return
	end

	self.PlayData:Set(PerformData, 0)
	if PerformData.InstrumentGroup ~= 0 then
		-- 获取GroupData
		local GroupData = MusicPerformanceUtil.GetPerformGroupData(PerformData.InstrumentGroup)
		if GroupData == nil then
			MusicPerformanceUtil.Log(" MPCharacter:Start GroupId error id = " .. PerformData.InstrumentGroup)
			return
		end

		for i = 0, MPDefines.GroupMax - 1 do
			local PerformId = GroupData["ID" .. tostring(i)]
			if PerformId == 0 then
				break
			end

			-- 获取PerformData
			local PerformDataTmp = MusicPerformanceUtil.GetPerformData(PerformId)
			if PerformDataTmp == nil then
				MusicPerformanceUtil.Log(" MPCharacter:Start Group Perfrom error id = " .. PerformId)
				break
			end

			self.Group[self.GroupCount] = PerformId
			self.GroupCount = self.GroupCount + 1

			if PerformId == self.PerformDataID then
				self.Timbre = i
			end
		end
	end

	local ModelID = PerformData.Model
	local AvatarComp = ActorUtil.GetActorAvatarComponent(EntityID)
	if not string.isnilorempty(ModelID) and AvatarComp then
		-- Change Weapon Model
		--AvatarComp:SetAvatarHiddenInGame(UE.EAvatarPartType.WEAPON_MASTER_HAND, true, false, false)
		local ModelParams = string.split(ModelID, ",")
		if #ModelParams >= 3 then
			local ModelPath = string.format("w%04d", tonumber(ModelParams[1]))
			local SubModelPath = string.format("b%04d", tonumber(ModelParams[2]))
			local ImagechangeID = tonumber(ModelParams[3])
			AvatarComp:ChangeAvatarWeapon(ModelPath, SubModelPath, ImagechangeID, 0, UE.EAvatarPartType.WEAPON_SYSTEM, 0)
		end
	end

	self:PlayMotion(EntityID, PerformData.StartTimeline)
	self.StartTimelineID = PerformData.StartTimeline

	if EntityID == MajorUtil.GetMajorEntityID() then
		-- self.Status = MPDefines.PerformCharacterStatus.STS_LOAD
		-- todo
		self.Status = MPDefines.PerformCharacterStatus.STS_IDLE
		self:SetForcedLODForAll(EntityID, 1)	-- 强制最高LOD
	else
		self.Status = MPDefines.PerformCharacterStatus.STS_IDLE
	end
	self.IdleTimelineID = nil
	TableTools.ClearTable(self.KeySet)

	self:ChangeCameraOffset(EntityID, PerformData, false)
end

--需要LOD强制设置为0时，LODLevel参数传1
function MPCharacter:SetForcedLODForAll(EntityID, LODLevel)
	local AvatarComponent = ActorUtil.GetActorAvatarComponent(EntityID)
	if AvatarComponent == nil then
		return
	end

	AvatarComponent:SetForcedLODForAll(LODLevel)
end

function MPCharacter:End(EntityID)
	MusicPerformanceUtil.Log(string.format("MPCharacter:End EntityID : %d", EntityID))
	local TimbreData = self:GetTimbreData()
	if TimbreData == nil then
		return
	end

	local AvatarComp = ActorUtil.GetActorAvatarComponent(EntityID)
	if TimbreData.Model ~= 0 and AvatarComp then
		-- change weaon model
		--AvatarComp:SetAvatarHiddenInGame(UE.EAvatarPartType.WEAPON_MASTER_HAND, false, false, false)
		AvatarComp:TakeOffAvatarPart(UE.EAvatarPartType.WEAPON_SYSTEM, false)
	end

	self:PlayMotion(EntityID, TimbreData.EndTimeline)
	--AnimationUtil.StopSlotAnimation(nil, EntityID, MPDefines.AnimSlotNames.IdleTimeline)
	self.Status = MPDefines.PerformCharacterStatus.STS_INVALID
	self.PerformDataID = 0
	self.Timbre = 0
	self.Time = 0
	self.StartTimelineID = nil

	if MajorUtil.IsMajor(EntityID) then
		self:SetForcedLODForAll(EntityID, 0)	-- 复原LOD
	end

	self:ChangeCameraOffset(EntityID, TimbreData, true)

	return TimbreData
end

function MPCharacter:ChangeCameraOffset(EntityID, PerformData, IsEnd)
	if MajorUtil.IsMajor(EntityID) and PerformData.CameraOnOff == 1 then
		-- 
		local Major = MajorUtil.GetMajor()
		local CameraMoveParam = _G.LuaCameraMgr:GetDefaultCameraParam()
		local CameraResetType = _G.UE.ECameraResetLocation.RecordLocation
		CameraMoveParam.LagValue = MPDefines.CameraSettings.LagValue
		
		local EIDTransform = _G.UE.FTransform()
		Major:GetEidTransform("EID_CAM_GRD", EIDTransform)
		local ATPCComp = Major.ATPCCameraComp
		local CompTransform = ATPCComp and ATPCComp:GetRelativeTransform() or _G.UE.FTransform()

		local OffsetLoc = EIDTransform:GetLocation() - CompTransform:GetLocation() - Major:FGetActorLocation()
		CameraMoveParam.SocketExternOffset = IsEnd and _G.UE.FVector() or OffsetLoc

		_G.LuaCameraMgr:ResetMajorCameraSpringArmByParam(CameraResetType, CameraMoveParam)
	end
end

function MPCharacter:UpdateIdle(EntityID, IdleTimelineID)
	if IdleTimelineID == self.IdleTimelineID then
		return
	end

	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp == nil then
		return
	end

	self.IdleTimelineID = IdleTimelineID
	if IdleTimelineID == nil then
		return
	end

	MusicPerformanceUtil.Log(string.format("MPCharacter:UpdateIdle %d %s", EntityID, tostring(IdleTimelineID)))
	local IdleDefaultTimeline = AnimComp:GetDefaultTimeline(IdleTimelineID, "", 99999)
	if string.isnilorempty(IdleDefaultTimeline) then
		return
	end

	local SoftPath = _G.UE.FSoftObjectPath()
	SoftPath:SetPath(IdleDefaultTimeline)
	local IdleAnim = ObjectMgr:LoadObjectSync(IdleDefaultTimeline)
	if IdleAnim then
		local LoopMontage = AnimationUtil.CreateLoopDynamicMontage(nil, IdleAnim, MPDefines.AnimSlotNames.IdleTimeline)
		AnimComp:PlayMontage(LoopMontage, nil)
		return true
	end
end

function MPCharacter:IsValid()
	return self.PerformDataID ~= 0
end

function MPCharacter:GetId()
	return self.PerformDataID
end

function MPCharacter:IsPlayLoop()
	return self.Status == MPDefines.PerformCharacterStatus.STS_PLAY_LOOP
end

function MPCharacter:GetGroupCount()
	return self.GroupCount
end

function MPCharacter:GetGroup(Index)
	if Index >= self.GroupCount then
		MusicPerformanceUtil.Log(" GetGroup Index invalid " .. Index)
		return nil
	end
	return self.Group[Index]
end

function MPCharacter:IsGroup()
	return self:GetGroupCount() > 0
end

function MPCharacter:GetTimbre()
	return self.Timbre
end

function MPCharacter:IsReady()
	return self.Status >= MPDefines.PerformCharacterStatus.STS_IDLE
end

function MPCharacter:CopyIdle(EntityID)
	local TimbreData = self:GetTimbreData()
	if TimbreData == nil then
		return
	end

	-- TODO: change weapon and play idle timeline
end

function MPCharacter:Play(EntityID, Key, IsKeyOff)
	if self:IsReady() == false then
		return
	end

	local TimbreData = self:GetTimbreData()
	if nil == TimbreData then
		return
	end

	-- local AnimInst = AnimationUtil.GetAnimInst(EntityID)
	-- -- if AnimationUtil.IsSlotPlayingMontage(AnimInst, MPDefines.AnimSlotNames.StartTimeline) then
	-- -- 	-- 在过渡动作中演奏动作不再生
	-- -- 	return
	-- -- end

	MusicPerformanceUtil.Log(string.format("MPCharacter:Play Key:%s, IsKeyOff:%s, KeySet[Key]:%s, Loop=%s", Key, IsKeyOff, self.KeySet[Key], TimbreData.Loop))
	
	if IsKeyOff or Key == MPDefines.KeyOff then
		if TimbreData.Loop == 1 then
			-- 有在按的任何键时，都应该保持动作直到所有键被抬起
			local IsNoKey = true
			if Key == MPDefines.KeyOff then
				-- 清除所有按键
				TableTools.ClearTable(self.KeySet)
			else
				self.KeySet[Key] = nil
			end
			
			for _, v in pairs(self.KeySet) do
				IsNoKey = false
				break
			end

			print("MPCharacter:Play", IsNoKey)
			if self.Status ~= MPDefines.PerformCharacterStatus.STS_IDLE and IsNoKey then
				self.InterruptFlag = true
			end
		end
		return
	elseif TimbreData.Loop == 1 then
		if self.KeySet[Key] then
			-- 保持
			return
		end
		self.KeySet[Key] = true
	end

	self.InterruptFlag = false
	local TimelineID = MPDefines.KeyAnimMap[Key % MPDefines.KeyDefines.KEY_MAX]
	self.PlayData:Set(TimbreData, TimelineID)
	self.Status = MPDefines.PerformCharacterStatus.STS_PLAY
	MusicPerformanceUtil.Log(string.format("MPCharacter:Play Status:%s, KeyTimeline:%s, KeyLoopTimeline:%s", self.Status, self.PlayData.KeyTimeline, self.PlayData.KeyLoopTimeline))
end

function MPCharacter:Update(DeltaTime, IsReady)
	if self.Status == MPDefines.PerformCharacterStatus.STS_LOAD then
		if IsReady then
			self.Status = MPDefines.PerformCharacterStatus.STS_IDLE
		end
	end
end

function MPCharacter:UpdateMotion(DeltaTime, EntityID)
	if self:IsReady() == false then
		return
	end

	self.Time = self.Time - DeltaTime
	if self.Time > 0 then
		return
	end

	if self.Status == MPDefines.PerformCharacterStatus.STS_IDLE then
		local IsStartTimelinePlaying = self:IsPlayingTimeline(EntityID, self.StartTimelineID)
		-- 不中断开始动作
		if not IsStartTimelinePlaying then
			local IsPrevPlaying, PrevIndex = self:IsPlayingTimeline(EntityID, self.PrevTimelineID)
			-- play动画不能被中断，loop可以被中断
			-- play 和 loop相同时，play就是loop动画，所以可以被中断
			if self.PlayData.KeyTimeline == self.PlayData.KeyLoopTimeline or  not IsPrevPlaying or (PrevIndex and PrevIndex > 0)  then
				if self:PlayMotion(EntityID, self.PlayData.IdleTimeline, nil, nil) == true then
					self.Time = MPDefines.MotionIdleInterval
				end
			end
		end
	elseif self.Status == MPDefines.PerformCharacterStatus.STS_PLAY then
		local IsStartTimelinePlaying = self:IsPlayingTimeline(EntityID, self.StartTimelineID)
		-- 不中断开始动作比如鼓的坐下动作较长，按键不能打断坐下动作）
		if not IsStartTimelinePlaying then
			if self:PlayMotion(EntityID, self.PlayData.KeyTimeline, self.PlayData.KeyLoopTimeline, true) == true then
				if self.PlayData.Loop ~= 1 then
					self.Status = MPDefines.PerformCharacterStatus.STS_IDLE
				else
					self.Status = MPDefines.PerformCharacterStatus.STS_PLAY_LOOP
				end
				self.Time = MPDefines.MotionPlayInterval
			end
		end
	elseif self.Status == MPDefines.PerformCharacterStatus.STS_PLAY_LOOP then
		-- InterruptFlag为true时，表示长按自动[MPDefines.PlayLimit(4秒)]松开了,所以此时可以从loop切换到idle状态了
		if self.InterruptFlag == true then
			self.Status = MPDefines.PerformCharacterStatus.STS_IDLE
			self.InterruptFlag = false
		end
	end
end

function MPCharacter:IsPlayingTimeline(EntityID, TimelineID)
	if self.PrevTimelineID == nil or self.PrevTimelineID ~= TimelineID or not _G.AnimMgr:IsAnimationQueuePlaying(EntityID, self.PrevAnimationQueueID) then
		return false
	end

	local PlayInfo = _G.AnimMgr:GetCurrentQueueAnimation(EntityID, self.PrevAnimationQueueID)
	if PlayInfo == nil then
		return false
	end

	return true, PlayInfo.Index
end

function MPCharacter:StopMotion(EntityID, TimelineID)
	if self:IsPlayingTimeline(EntityID, TimelineID) then
		_G.AnimMgr:StopAnimationMulti(EntityID, self.PrevAnimationQueueID)
	end
end

function MPCharacter:PlayMotion(EntityID, TimelineID, LoopTimelineID, ForceFlag, BlendInTime, BlendOutTime)
	MusicPerformanceUtil.Log(string.format("MPCharacter:PlayMotion EntityID:%d, TimelineID=%s,  ForceFlag=%s", EntityID,TimelineID, ForceFlag))

	ForceFlag = ForceFlag or false
	local AnimInst = AnimationUtil.GetAnimInst(EntityID)
	if ForceFlag == false then
		-- 防止反复播放动作
		local IsPlaying = self:IsPlayingTimeline(EntityID, TimelineID)
		MusicPerformanceUtil.Log(string.format("MPCharacter:PlayMotion EntityID : %d  IsPlaying:%s", EntityID, IsPlaying))
		if IsPlaying then
			return false
		end
	end

	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor then
		local TimelinePath = _G.AnimMgr:GetActionTimeLinePath(TimelineID)
		MusicPerformanceUtil.Log(string.format("NewSlotNodeWeightMPCharacter:PlayMotion %d %s %s", EntityID, tostring(TimelineID), tostring(TimelineID)))
		-- AnimComp:PlayAnimationAsync(TimelinePath, nil, 1, 0.25, 0)

		-- todo action timeline
		
		local Animations = {
			[1] = {AnimPath = TimelinePath, BlendInTime = BlendInTime, BlendOutTime = BlendOutTime},
		}

		if not string.isnilorempty(LoopTimelineID) then
			MusicPerformanceUtil.Log(string.format("NewSlotNodeWeightMPCharacter:PlayMotion Loop Anim %d %s %s", EntityID, tostring(LoopTimelineID), tostring(LoopTimelineID)))
			local LoopTimelinePath = _G.AnimMgr:GetActionTimeLinePath(LoopTimelineID)
			table.insert(Animations, {AnimPath = LoopTimelinePath, BlendInTime = nil})
		end

		self.PrevAnimationQueueID = _G.AnimMgr:PlayAnimationMulti(EntityID, Animations,true)
		self.PrevTimelineID = TimelineID
	end
	return true
end

function MPCharacter:GetData()
	if self.PerformDataID == 0 then
		return nil
	end

	return MusicPerformanceUtil.GetPerformData(self.PerformDataID)
end

function MPCharacter:GetTimbreData()
	local ID = self.PerformDataID
	if self.GroupCount > 0 then
		ID = self.Group[self.Timbre]
	end

	if ID == 0 then
		return nil
	end

	return MusicPerformanceUtil.GetPerformData(ID)
end

function MPCharacter:GetGroupData(Index)
	local ID = self:GetGroup(Index)
	if ID == 0 then
		return nil
	end

	return MusicPerformanceUtil.GetPerformData(ID)
end

function MPCharacter:SetTimbre(EntityID, ID)
	if ID >= self.GroupCount then
		MusicPerformanceUtil.Log(" SetTimbre ID invalid " .. ID)
		return
	end

	if self.Timbre ~= ID then
		self.Timbre = ID
		self:UpdateIdle(EntityID, self.PlayData.IdleTimeline)
	end
end

return MPCharacter