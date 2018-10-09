local Storage = require 'kong.plugins.proxy-cache.storage'
local validators = require 'kong.plugins.proxy-cache.validators'
local Cache = require 'kong.plugins.proxy-cache.cache'

local _M = {}

function _M.execute(config)
    ngx.ctx.rt_body_chunks = {}
    ngx.ctx.rt_body_chunk_number = 1

    local storage = Storage:new()
    local cache = Cache:new()
    
    storage:set_config(config)
    cache:set_config(config)

    if cache:check_no_cache() then
        ngx.log(ngx.DEBUG, "reflesh: no-cache")
        ngx.header['X-Cache-Status'] = 'REFRESH'
        return
    end

    if cache:cache_ttl() == nil then
        ngx.log(ngx.DEBUG, "reflesh: ttl not found")
        ngx.header['X-Cache-Status'] = 'REFRESH'
        return
    end

    local cache_key = cache:generate_cache_key(ngx.req, ngx.var)

    if validators.check_request_method() then
        local cached_value, err = storage:get(cache_key)
        if cache:check_age(storage:ttl(cache_key)) then
            ngx.log(ngx.DEBUG, "reflesh: TTL")
            ngx.header['X-Cache-Status'] = 'REFRESH'
            return
        end
        if cached_value and cached_value ~= ngx.null then
            ngx.log(ngx.DEBUG, "hit: ", cache_key)
            for header, value in pairs(cached_value.headers) do
                if string.upper(header) ~= 'CONNECTION' then
                    ngx.header[header] = value
                end
            end
            ngx.header['X-Cache-Status'] = 'HIT'
            ngx.status = cached_value.status
            ngx.print(cached_value.content)
            ngx.exit(cached_value.status)
        else
            ngx.log(ngx.DEBUG, "miss: ", cache_key)
            ngx.header['X-Cache-Status'] = 'MISS'
        end
    else
        ngx.log(ngx.DEBUG, "bypass: ", cache_key)
        ngx.header['X-Cache-Status'] = 'BYPASS'
        ngx.log(ngx.DEBUG, "request method is not caching: ", ngx.req.get_method())
    end
end

return _M
