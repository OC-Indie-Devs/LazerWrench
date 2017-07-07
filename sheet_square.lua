--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2414103c02de1c72521a9d8d5d14b8fd:f8fe9e22f8705bda9b0d8b4a640eb319:5cdd224c490bd0da6373d0cd14aa0362$
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
            -- spr_square_106
            x=1,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_108
            x=99,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_126
            x=197,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_127
            x=295,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_128
            x=393,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_86
            x=491,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_87
            x=589,
            y=1,
            width=96,
            height=96,

        },
        {
            -- spr_square_88
            x=687,
            y=1,
            width=96,
            height=96,

        },
    },
    
    sheetContentWidth = 784,
    sheetContentHeight = 98
}

SheetInfo.frameIndex =
{

    ["spr_square_106"] = 1,
    ["spr_square_108"] = 2,
    ["spr_square_126"] = 3,
    ["spr_square_127"] = 4,
    ["spr_square_128"] = 5,
    ["spr_square_86"] = 6,
    ["spr_square_87"] = 7,
    ["spr_square_88"] = 8,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
