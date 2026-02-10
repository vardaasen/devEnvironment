local home_dir = os.getenv("USERPROFILE") or os.getenv("HOME")

if home_dir then
    os.setenv('STARSHIP_CONFIG', home_dir .. '\\.config\\starship\\starship.toml')
end

os.setenv('STARSHIP_SHELL', 'cmd')

local starship_exe = "starship"

local starship_prompt = clink.promptfilter(5)

function starship_prompt:filter(prompt)
    local command = string.format('"%s" prompt --status=%s', starship_exe, os.geterrorlevel())
    local pipe = io.popen(command)
    if not pipe then return prompt end
    local output = pipe:read("*a")
    pipe:close()
    if output == "" or output == nil then
        return prompt
    end
    return output
end
