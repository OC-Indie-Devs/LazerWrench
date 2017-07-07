--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:eb37fae778736a072a5822bc6a8781b7:f682d021633c83512f0bacbf5f5c4bd0:29c8e2251d63336aecadaa22625a871d$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- JUMP_000
            x=1,
            y=1167,
            width=82,
            height=142,

            sourceX = 90,
            sourceY = 66,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- JUMP_002
            x=1,
            y=639,
            width=96,
            height=122,

            sourceX = 86,
            sourceY = 71,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- RUN_000
            x=1,
            y=1,
            width=116,
            height=102,

            sourceX = 74,
            sourceY = 85,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- RUN_001
            x=1,
            y=873,
            width=90,
            height=106,

            sourceX = 87,
            sourceY = 87,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- RUN_002
            x=63,
            y=1931,
            width=64,
            height=106,

            sourceX = 112,
            sourceY = 87,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- RUN_003
            x=1,
            y=105,
            width=116,
            height=102,

            sourceX = 78,
            sourceY = 86,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- RUN_004
            x=1,
            y=763,
            width=92,
            height=108,

            sourceX = 90,
            sourceY = 85,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- RUN_005
            x=1,
            y=1931,
            width=60,
            height=108,

            sourceX = 110,
            sourceY = 85,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- SLIDE_000
            x=1,
            y=513,
            width=102,
            height=124,

            sourceX = 80,
            sourceY = 68,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- STAND_000
            x=1,
            y=1311,
            width=82,
            height=126,

            sourceX = 89,
            sourceY = 66,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- THROW_000
            x=1,
            y=209,
            width=112,
            height=158,

            sourceX = 55,
            sourceY = 34,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- THROW_001
            x=1,
            y=369,
            width=108,
            height=142,

            sourceX = 59,
            sourceY = 50,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- THROW_002
            x=1,
            y=981,
            width=84,
            height=184,

            sourceX = 83,
            sourceY = 8,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- THROW_003
            x=1,
            y=1439,
            width=80,
            height=178,

            sourceX = 87,
            sourceY = 14,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- WALL_000
            x=1,
            y=1799,
            width=78,
            height=130,

            sourceX = 90,
            sourceY = 67,
            sourceWidth = 256,
            sourceHeight = 256
        },
        {
            -- jump_throw
            x=1,
            y=1619,
            width=78,
            height=178,

            sourceX = 90,
            sourceY = 30,
            sourceWidth = 256,
            sourceHeight = 256
        },
    },
    
    sheetContentWidth = 128,
    sheetContentHeight = 2040
}

SheetInfo.frameIndex =
{

    ["JUMP_000"] = 1,
    ["JUMP_002"] = 2,
    ["RUN_000"] = 3,
    ["RUN_001"] = 4,
    ["RUN_002"] = 5,
    ["RUN_003"] = 6,
    ["RUN_004"] = 7,
    ["RUN_005"] = 8,
    ["SLIDE_000"] = 9,
    ["STAND_000"] = 10,
    ["THROW_000"] = 11,
    ["THROW_001"] = 12,
    ["THROW_002"] = 13,
    ["THROW_003"] = 14,
    ["WALL_000"] = 15,
    ["jump_throw"] = 16,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
