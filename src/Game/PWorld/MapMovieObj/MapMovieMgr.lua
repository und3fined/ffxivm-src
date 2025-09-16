
local EventID = require("Define/EventID")

---@class MapMovieMgr
local MapMovieMgr = {}

--播放场景视频资源，暂时没有用到，已废弃
function MapMovieMgr:Init(MapEditCfg)
    ---1: Invalid, 0: 开场动画, >0: 实际Movie id
    self.CurrentPlayingMovieId = -1
    self.MapMovieConfig = {}
    self.MoviePlayer = nil

    self:LoadMapMovieConfig(MapEditCfg)
    self:PlayMovie(0)
end

function MapMovieMgr:Reset()
    if (self.MoviePlayer ~= nil) then
        _G.CommonUtil.DestroyActor(self.MoviePlayer)
        self.MoviePlayer = nil
    end
    
    self.CurrentPlayingMovieId = -1
    self.MapMovieConfig = {}
end

function MapMovieMgr:LoadMapMovieConfig(MapEditCfg)
    if (MapEditCfg == nil) then
        return
    end

    local MovieList = MapEditCfg.MovieList
    for _, Movie in ipairs(MovieList) do
        table.insert(self.MapMovieConfig, Movie)
    end

    self.MoviePlayer =  _G.CommonUtil.SpawnActor(_G.UE.AMapMoviePlayer.StaticClass())
end

--MovieId = 0 => Play Open Movie
function MapMovieMgr:PlayMovie(MovieId)
    print("UMapMovieMgr::PlayMovie id: ", MovieId)
    self.CurrentPlayingMovieId = MovieId
    if (self.MoviePlayer == nil) then
        self:OnMovieStopped()
        return
    end

    if (self.CurrentPlayingMovieId == 0) then
        if (_G.PWorldMgr.EnterMapServerFlag ~= 0) then
            --只有PWorldEnterRsp.Flag为0时表示“准备期间进入”需要播放开场动画，其它（断线重连、中途加入等）跳过开场动画
            self:OnMovieStopped()
            return
        end
        local OpenMovieConfig = nil
        for _, MovieConfig in ipairs(self.MapMovieConfig) do
            if (MovieConfig.IsOpenMovie) then
                OpenMovieConfig = MovieConfig
                break
            end
        end
        if (OpenMovieConfig == nil) then
            print("UMapMovieMgr::PlayMovie: wants to play open movie but NONE configured!")
            self:OnMovieStopped()
            return
        end
        self.CurrentPlayingMovieId = OpenMovieConfig.ID
        print("UMapMovieMgr::PlayMovie: play open movie id ", self.CurrentPlayingMovieId)
    end

    local MovieConfig = self:GetMovieConfigById(self.CurrentPlayingMovieId)
    if (MovieConfig == nil) then
        print("UMapMovieMgr::PlayMovie: no movie config for id ", self.CurrentPlayingMovieId)
        self:OnMovieStopped()
        return
    end

    local function OnMovieStoppedCallback(_)
        self:OnMovieStopped()
    end
    self.MoviePlayer.OnMovieStopped:Add(self.MoviePlayer, OnMovieStoppedCallback)
    local bPlaySuccess = self.MoviePlayer:PlayMovie(MovieConfig.MoviePath, MovieConfig.CanBeSkipped)
    if (bPlaySuccess) then
        local Params = {CanBeSkipped = MovieConfig.CanBeSkipped}
        _G.UIViewMgr:ShowView(_G.UIViewID.PWorldMoviePlayer, Params)
    end
end

function MapMovieMgr:StopMovie()
    print("UMapMovieMgr::StopMovie CurrentPlayingMovieId: ", self.CurrentPlayingMovieId)
    if (self.MoviePlayer == nil) then
        if (self.CurrentPlayingMovieId ~= -1) then
            print("UMapMovieMgr::StopMovie() invalid MoviePlayer but CurrentPlayingMovieId ", self.CurrentPlayingMovieId, " is not -1!")
        end
        return
    end
    local Result = self.MoviePlayer:StopMovie()
    if (Result) then
        _G.UIViewMgr:HideView(_G.UIViewID.PWorldMoviePlayer)
    end

end


function MapMovieMgr:MockConfigIfNeeded()
    if (#self.MapMovieConfig == 0) then
        local MapConfig = {}
        MapConfig.MovieList = {}
        local MovieOne = {}
        MovieOne.ID = 1000
        MovieOne.CanBeSkipped = true
        MovieOne.IsOpenMovie = true
        MovieOne.MoviePath = "FileMediaSource'/Game/Movies/MediaAssets/8r_boss_opening.8r_boss_opening'"
        local MovieTwo = {}
        MovieTwo.ID = 1001
        MovieTwo.CanBeSkipped = true
        MovieTwo.IsOpenMovie = false
        MovieTwo.MoviePath = "FileMediaSource'/Game/Movies/MediaAssets/SparkMore.SparkMore'"
        local MovieThree = {}
        MovieThree.ID = 1002
        MovieThree.CanBeSkipped = true
        MovieThree.IsOpenMovie = false
        MovieThree.MoviePath = "FileMediaSource'/Game/Movies/MediaAssets/8r_boss_die.8r_boss_die'"
        table.insert(MapConfig.MovieList, MovieOne)
        table.insert(MapConfig.MovieList, MovieTwo)
        table.insert(MapConfig.MovieList, MovieThree)
        self:LoadMapMovieConfig(MapConfig)
    end

    if (self.MoviePlayer == nil) then
        self.MoviePlayer =  _G.CommonUtil.SpawnActor(_G.UE.AMapMoviePlayer.StaticClass())
    end
end

function MapMovieMgr:OnMovieStopped()
    if (self.MoviePlayer ~= nil) then
        self.MoviePlayer.OnMovieStopped:Clear()
    end
    if (self.CurrentPlayingMovieId == -1) then
        return
    end
    --send end msg
    if (self.CurrentPlayingMovieId > 0) then
        --CurrentPlayingMovieId == 0意味着请求播放OpenMovie但是没有配置或者配置错误，这种情况下不需要发End 
        _G.PWorldMgr:SendMovieEnd(self.CurrentPlayingMovieId)
    end

    --if open movie, send lua msg
    local bIsOpenMovie = self.CurrentPlayingMovieId == 0
    if (not bIsOpenMovie) then
        local MovieConfig = self:GetMovieConfigById(self.CurrentPlayingMovieId)
        if (MovieConfig ~= nil) then
            bIsOpenMovie = MovieConfig.IsOpenMovie
        end
    end

    -- if (bIsOpenMovie) then
    --     _G.EventMgr:SendEvent(EventID.PWorldOpenMovieEnd)
    -- end

    self.CurrentPlayingMovieId = -1
end

function MapMovieMgr:GetMovieConfigById(MovieId)
    for _, MovieConfig in ipairs(self.MapMovieConfig) do
        if (MovieConfig.ID == MovieId) then
           return MovieConfig
        end
    end
    return nil
end

return MapMovieMgr