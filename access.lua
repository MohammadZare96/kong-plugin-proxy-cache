local storage = require 'kong.plugins.globo-cache.storage'
local validators = require 'kong.plugins.globo-cache.validators'

local _M = {}

function _M.execute(config)
    local cache_key = ngx.var.request_uri
    ngx.ctx.rt_body_chunks = {}
    ngx.ctx.rt_body_chunk_number = 1

    storage:new()
    storage:set_config(config)

    if validators.check_request_method(config.request_method) then
        local cached_value, err = storage:get(cache_key)
        if cached_value and cached_value ~= ngx.null then
            ngx.log(ngx.DEBUG, "hit: ", cache_key)
            ngx.header['X-Cache'] = 'HIT'
            ngx.print(cached_value)
            ngx.exit(200)
        else
            ngx.log(ngx.DEBUG, "miss: ", cache_key)
            ngx.header['X-Cache'] = 'MISS'
        end
    else
        ngx.log(ngx.DEBUG, "request method is not caching: ", ngx.req.get_method())
    end
end

return _M