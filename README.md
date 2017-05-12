graphite.lua
==========

A simple graphite reporter module for Lua

Features:

* Report a vector of metric together in single call
* Report a metric just as key-value pair
* It's platform-agnostic. It has been tested with nginx and openresty.

Status
=====

Under Development

Usage
=====

Here is the complete example of how you can use `graphite.lua`:

``` lua
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
```
Author
=======

**joy4eg**

* <http://github.com/joy4eg>
* <me@ys.lc>

License
=======

MIT license
