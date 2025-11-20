

local Util = {}

function Util.SetDate(Temp)
    Temp.Date = _G.TimeUtil.GetServerTime()
end

function Util.SetIcon(Temp, IconUrl)
    local BaseInfo = Util.GetBaseInfo(Temp)
    if BaseInfo then
        BaseInfo.Icon = IconUrl
    end
end

function Util.SetID(Temp, ID)
    local BaseInfo = Util.GetBaseInfo(Temp)
    if BaseInfo then
        BaseInfo.ID = ID
    end
end

function Util.SetBaseInfo(Temp, Name, Icon, ID, IsCust)
    Temp.BaseInfo = {
        Name    = Name,
        Icon    = Icon,
        ID      = ID,
        IsCust  = IsCust,
    }
end

function Util.GetBaseInfo(Temp)
    return Temp.BaseInfo
end

function Util.SetMain(Temp, IsFollowFace, IsFollowEye)
    Temp.Main = {
        IsFollowFace    = IsFollowFace,
        IsFollowEye     = IsFollowEye,
    }
end

function Util.GetMain(Temp)
    return Temp.Main
end

---暗边
function Util.SetMask(
    Temp,
    Rad, 
    Asp, 
    Aspect, 
    Power, 
    VignettingA, 
    VignettingG, 
    VignettingB,
    RedValue,
    GreenValue,
    BlueValue
)
    Temp.Mask = {
        Rad = Rad,
        Asp = Asp,
        Aspect = Aspect,
        Power = Power,
        VignettingA = VignettingA,
        VignettingG = VignettingG,
        VignettingB = VignettingB,
        RedValue = RedValue,
        GreenValue = GreenValue,
        BlueValue = BlueValue,
    }
end

function Util.GetMask(Temp)
    return Temp.Mask
end

function Util.SetActOrMove(Temp, Type, Idx, Pct, ID)
    Temp.Act = {
        Type = Type,
        Idx = Idx,
        Pct = Pct,
        ID = ID,
    }
end

function Util.GetActOrMove(Temp)
    return Temp.Act
end

function Util.SetEmojAndMouth(Temp, EmojIdx, MouthIdx, MouthFrames)
    Temp.Emoj = {
        EmojIdx = EmojIdx,
        MouthIdx = MouthIdx,
        MouthFrames = MouthFrames,
    }
end

function Util.GetEmojAndMouth(Temp)
    return Temp.Emoj
end

function Util.SetCam(Temp, FOV, DOF, Rot, OffX, OffY, RelaRot, CamDis)
    Temp.Cam = {
        FOV     = FOV,
        DOF     = DOF,
        Rot     = Rot,
        OffX    = OffX,
        OffY    = OffY,
        RelaRot = RelaRot,
        CamDis  = CamDis
    }
end

function Util.GetCam(Temp)
    return Temp.Cam
end

function Util.SetScene(Temp, WeatherID, Time)
    Temp.Scene = {
        WeatherID     = WeatherID,
        Time          = Time,
    }
end

function Util.GetScene(Temp)
    return Temp.Scene
end

function Util.SetFilter(Temp, ID, FilterPre)
    Temp.Filter = {
        ID     = ID,
        FilterPrecent = FilterPre,
    }
end

function Util.GetFilter(Temp)
    return Temp.Filter
end

-- 昏暗\暗边
function Util.SetDarkFrame(Temp, Power, Aspect, Red, Yellow, Blue)
    Temp.DarkFrame = {
        Power           = Power,
        Aspect          = Aspect,
        Red             = Red,
        Yellow          = Yellow,
        Blue            = Blue,
    }
end

function Util.GetDarkFrame(Temp)
    return Temp.DarkFrame
end

-- 角色
function Util.SetRole(Temp, ActID, EmoID, MoveID, MouthID)
    Temp.Role = {
        ActID           = ActID,
        EmoID           = EmoID,
        MoveID          = MoveID,
        MouthID         = MouthID,
    }
end

function Util.GetRole(Temp)
    return Temp.Role
end


function Util.SetActSettings(Temp, Spin)
    Temp.ActSettings = {
        Spin = Spin,
    }
end

function Util.GetActSettings(Temp)
    return Temp.ActSettings
end

function Util.SetRoleStat(Temp, StatID)
    Temp.RoleStat = {
        StatID = StatID,
    }
end

function Util.GetRoleStat(Temp)
    return Temp.RoleStat
end

return Util