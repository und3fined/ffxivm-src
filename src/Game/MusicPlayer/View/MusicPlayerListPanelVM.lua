--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MusicPlayerSidebarListItemVM = require("Game/MusicPlayer/View/Item/MusicPlayerSidebarListItemVM")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")


---@class MusicPlayerListPanelVM : UIViewModel
local MusicPlayerListPanelVM = LuaClass(UIViewModel)

---Ctor
function MusicPlayerListPanelVM:Ctor()
	self.RightMusicList = UIBindableList.New(MusicPlayerSidebarListItemVM)
	self.DropListInfo = nil
	self.MusicInfo = {}
end

function MusicPlayerListPanelVM:OnInit()

end

function MusicPlayerListPanelVM:OnBegin()

end

function MusicPlayerListPanelVM:OnEnd()

end

function MusicPlayerListPanelVM:UpdateMusicListInfo(List)
	if List == nil then
		return
	end

	for i = 1, #List do
		--local Index = List[i].MusicID
		--List[i].Time = MusicPlayerCfg:FindCfgByKey(Index).Time
		--List[i].MusicName = MusicPlayerCfg:FindCfgByKey(Index).MusicName
		if not MusicPlayerMgr.PlayerIsSearch then
			List[i].SearchID = nil
		end
		List[i].Index = i
	end

	self.MusicInfo = List
	self.RightMusicList:UpdateByValues(List)
end

function MusicPlayerListPanelVM:UpdateDropList()
	local TabList = {}
	local Info = MusicPlayerMgr:GetMusicTypeInfo(1) 
	local AllMusicInfo = MusicPlayerMgr.AllMusicInfo
	if #AllMusicInfo == 0 then
		for i = 1, #Info do
			Info[i].IconPath = nil
		end
		self.DropListInfo = Info
	else
		for i = 2, #Info do
			Info[i].MusicInfo = {}
			local CurTypeMusicList = MusicPlayerMgr:GetAtlasInfoByType(Info[i].Type)
			for j = 1, #CurTypeMusicList do
				local MusicInfo = MusicPlayerMgr.AllAtlasList[CurTypeMusicList[j].MusicID]
				if MusicInfo then
					local Type = MusicInfo.PlayType
					local Number = CurTypeMusicList[j].Number
					MusicInfo.Number = Number
					MusicInfo.Type = Type
					if Type == Info[i].Type and MusicInfo.OnOff == 1 and CurTypeMusicList[j].IsUnLock then
						table.insert(Info[i].MusicInfo, MusicInfo)
					end
				else
					FLOG_ERROR("MusicInfo = nil ID")
					print(CurTypeMusicList[j].MusicID)
				end
			end
			Info[i].IconPath = nil
		end
	end

	--把最近收录的20首添加到最近收录
	Info[1].MusicInfo = {}
	for i = #AllMusicInfo, 1, -1 do
		if #Info[1].MusicInfo < 20 then
			local MusicInfo = MusicPlayerMgr.AllAtlasList[AllMusicInfo[i].MusicID]
			if MusicInfo then
				local Type = MusicInfo.PlayType
				local Time = MusicInfo.Time
				local MusicName = MusicInfo.MusicName
				AllMusicInfo[i].Type = Type
				AllMusicInfo[i].Time = Time
				AllMusicInfo[i].MusicName = MusicName
				table.insert(Info[1].MusicInfo, AllMusicInfo[i])
			end
		else
			break
		end
	end

	for i = 1, #Info do 
		local MusicList = Info[i] and Info[i].MusicInfo or {}
		if Info[i].ShowType == 1 and #MusicList > 0 then
			table.insert(TabList, Info[i])
		elseif Info[i].ShowType ~= 1 then
			table.insert(TabList, Info[i])
		end
	end

	self.DropListInfo = TabList
end

function MusicPlayerListPanelVM:MatchMusic(Input)
	local matches = {}
	local Params = tonumber(Input)
	if Params ~= nil then
		for k, v in pairs(self.DropListInfo) do
			if v.MusicInfo and k ~= 1 then
				for _, j in pairs(v.MusicInfo) do
					if j.Number == Params then
						j.SearchID = j.Number
						j.Type = k
						table.insert(matches, j)
					end
				end
			end
		end
	else
		_G.JudgeSearchMgr:QueryTextIsLegal(Input, function( IsLegal )
			if not IsLegal then
				_G.MsgTipsUtil.ShowTipsByID(156018)
				return
			end
		end, false)

		for k, v in pairs(self.DropListInfo) do
			if k ~= 1 and v.MusicInfo then
				if v.MusicInfo then
					for _, j in pairs(v.MusicInfo) do
						if j.MusicName:find(Input) then
							j.SearchID = j.Number
							j.Type = k
							table.insert(matches, j)
						end
					end
				end
			end
		end
	end


	return matches
end

function MusicPlayerListPanelVM:Clear()
	self.DropListInfo = nil
end

return MusicPlayerListPanelVM