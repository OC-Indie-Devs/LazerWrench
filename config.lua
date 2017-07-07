-- =============================================================
-- Your Copyright Statement Goes Here
-- =============================================================
--  config.lua
-- =============================================================
-- https://docs.coronalabs.com/daily/guide/basics/configSettings/index.html
-- =============================================================

application = {
   content = {
      width              = 1080,
      height             = 1920,
      scale              = "letterBox",
      fps                = 60,
      xAlign             = "center",
      yAlign             = "center",
      showRuntimeErrors  = true,
      shaderPrecision    = "highp",
      imageSuffix = {
         ["@2x"]  = 2.0,
         ["@3x"]  = 3.0,
         ["@4x"]  = 4.0,
      },
   },
}