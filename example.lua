#!/usr/bin/lua

-- load module
local graphite = require "graphite"

-- create new graphite instance
local gr_prod = graphite.new{host = "prod.graphite.example.com", port = 6554}

local ok, err = gr_prod:connect()
if ok then
  -- without timestamp
  gr_prod:send_simple("service.name.type.count", 33)

  -- with timestamp
  gr_prod:send_simple("service.name.type.value", "string", 1494582812)

  -- send X metric together
  gr_prod:send{
    {
      key = "service.name.type.count",
      value = 34,
    },
    {
      key = "service.name.type.value",
      value = "stringN",
      timestamp = 1494582812,
    },
  }

  -- disconnect
  gr_prod:close()
else
  print(err)
end
