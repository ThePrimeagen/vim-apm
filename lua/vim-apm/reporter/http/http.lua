local M = {}

---@param uri string
---@param port number
---@param token string
---@param messages APMStatsJson[]
function M.make_request(uri, port, token, messages)
    local uv = vim.loop
    local client = uv.new_tcp()

    client:connect(uri, port, function(err)
        if err == nil then
            local ok, to_write = pcall(vim.json.encode, messages)
            if ok then
                local http_message = {
                    "POST /api/motions HTTP/1.1",
                    string.format("Authorization: Bearer %s", token),
                    string.format("Host: %s:%d", uri, port),
                    "Content-Type: application/json",
                    string.format("Content-Length: %d", #to_write),
                    "Connection: close",
                    "",
                    to_write,
                }
                client:write(table.concat(http_message, "\r\n"))
            else
                err = "vim-apm failed to encode messages: " .. to_write
            end
        else
            err = "vim-apm failed to connect to the APM server: " .. err
        end

        -- ooops...
        client:close()
        if err ~= nil then
            -- TODO: handle error -- the one thing that has never hurt anyone...
            -- error(err)
        end
    end)
end

return M
