--
-- Author: haialexzhou
-- Date: 2021-12-3
-- Description:大世界地图区域染色图
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MapAreaCfg = require("TableCfg/MapAreaCfg")

---@class MapAreaImageMgr : MgrBase
local MapAreaImageMgr = LuaClass(MgrBase)

function MapAreaImageMgr:OnInit()
    self.AreaImageData = nil
    self.AreaImageDataNum = 0
    self.MapAreaCfg = nil
end

function MapAreaImageMgr:Reset()
    self:OnInit()
end

function MapAreaImageMgr:Init(MapResID, ImageData)
    if (MapAreaCfg == nil) then
        return
    end
    self.MapAreaCfg = MapAreaCfg:FindCfgByKey(MapResID)
    self.AreaImageData = ImageData
    if (self.AreaImageData ~= nil) then
        self.AreaImageDataNum = #self.AreaImageData.ImageData
    else
        self.AreaImageDataNum = 0
    end
end

--根据角色位置获取图片当前像素的颜色值
function MapAreaImageMgr:GetAreaIDByPos(Position)
    local AreaID = 0;
    if (self.MapAreaCfg == nil or self.AreaImageData == nil) then
        return AreaID
    end
   local CurrWorld = FWORLD()
    if (CurrWorld and CurrWorld.WorldComposition ~= nil) then
        local WorldOriginPos = _G.PWorldMgr:GetWorldOriginLocation()
        Position = Position + WorldOriginPos
    end

    local ImgPosX = math.abs(Position.X - self.MapAreaCfg.LeftTopX) / self.AreaImageData.UnitPerPixel;
    local ImgPosY = math.abs(Position.Y - self.MapAreaCfg.LeftTopY) / self.AreaImageData.UnitPerPixel;
    ImgPosX = math.floor(ImgPosX)
    ImgPosY = math.floor(ImgPosY)

    if (ImgPosX < 0 or ImgPosX >= self.AreaImageData.ImageWidth or ImgPosY < 0 or ImgPosY >= self.AreaImageData.ImageHeight) then
        return AreaID
    end

    local Index = ImgPosY * self.AreaImageData.ImageWidth + ImgPosX;
    if (Index < 0 or Index > self.AreaImageDataNum) then
        return AreaID
    end
    Index = Index + 1
    local PaletteIndex = self.AreaImageData.ImageData[Index]
    if (PaletteIndex == nil) then
        return AreaID
    end
    PaletteIndex = PaletteIndex + 1
    AreaID = self.AreaImageData.Palette[PaletteIndex]
    if (AreaID == nil) then
        AreaID = 0
    end
	
    return AreaID
end

--根据角色在场景中的位置获取图片对应像素的坐标
function MapAreaImageMgr:GetImagePosByActorPos(Position)
    if (self.MapAreaCfg == nil or self.AreaImageData == nil) then
        return 0, 0
    end
    
    local ImgPosX = math.abs(Position.X - self.MapAreaCfg.LeftTopX) / self.AreaImageData.UnitPerPixel;
    local ImgPosY = math.abs(Position.Y - self.MapAreaCfg.LeftTopY) / self.AreaImageData.UnitPerPixel;
    ImgPosX = math.floor(ImgPosX)
    ImgPosY = math.floor(ImgPosY)
    return ImgPosX, ImgPosY
end

function MapAreaImageMgr:GetAreaImageSize()
    if (self.MapAreaCfg == nil or self.AreaImageData == nil) then
        return _G.UE.FVector2D(0, 0)
    end
    local ImageSize = _G.UE.FVector2D(self.AreaImageData.ImageWidth, self.AreaImageData.ImageHeight)
    return ImageSize
end

function MapAreaImageMgr:GetAreaImagePath()
    if (self.MapAreaCfg == nil or self.AreaImageData == nil) then
        return nil
    end
    return self.MapAreaCfg.MapAreaTexPath
end

return MapAreaImageMgr