----------------------------------------------------------
-- Summary: Visual effects module.
-- 
-- @author Tony Godfrey (tonygod@sharkappsllc.com)
-- @copyright 2015-2016 shark apps, LLC
-- @license all rights reserved.
----------------------------------------------------------

local effects = {}

function effects.exposureFlash( obj )
    obj.fill.effect = "filter.exposure"
    obj.fill.effect.exposure = 1.25
    timer.performWithDelay( 200, 
        function()
            obj.fill.effect = nil
        end
    )
end


function effects.sparks( options )
    local o = options or {}
    o.num = o.num or 5
    
    for i = 1, o.num do
        local spark = display.newCircle( o.parent, o.x, o.y, 3 )
        spark.name = "spark"
        spark.fill = { 1, 1, 0, 1 }
        physics.addBody( spark, "dynamic", {} )
        spark:applyForce( math.random( -5, 5 ), math.random( -5, 5 ), 0, 0 )
        local destroySelf = function()
            spark:removeSelf()
        end
        spark.tsn = transition.to( spark, { time=2000, alpha=0, onComplete=destroySelf } )
    end
end

return effects

