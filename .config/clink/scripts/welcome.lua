local green = "\x1b[92m"
local reset = "\x1b[0m"
local cyan  = "\x1b[96m"
local red   = "\x1b[91m"
local gray  = "\x1b[90m"
local yellow = "\x1b[93m"

local function get_starship_version()
    local handle = io.popen("starship --version")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:match("starship%s+(%S+)") or "Unknown"
    end
    return "Not Found"
end

local function get_console_font()
    if os.getenv("WT_SESSION") or os.getenv("WEZTERM_EXECUTABLE") then
        return "Client Managed"
    end
    local handle = io.popen('reg query "HKCU\\Console" /v FaceName 2>nul')
    if handle then
        local result = handle:read("*a")
        handle:close()
        local font = result:match("FaceName%s+REG_SZ%s+([^\r\n]+)")
        return font or "System Default"
    end
    return "System Default"
end

local host_name = "Windows Console Host"
local renderer  = "GDI (Software)"
local border    = gray

if os.getenv("WT_SESSION") then
    host_name = "Windows Terminal"
    renderer  = "DirectX (GPU)"
    border    = green
elseif os.getenv("WEZTERM_EXECUTABLE") then
    host_name = "WezTerm (GPU)"
    renderer  = "WebGPU / OpenGL"
    border    = "\x1b[35m"
end

print(border.."========================================"..reset)
print("Welcome to your custom terminal session!")
print("Today is "..os.date("%c"))
print("")

local clink_ver = "Unknown"
if clink.version_major and clink.version_minor then
    clink_ver = clink.version_major.."."..clink.version_minor
    if clink.version_build then
        clink_ver = clink_ver.."."..clink.version_build
    end
end

local star_ver = get_starship_version()
local font_name = get_console_font()

print("Environment: Clink "..clink_ver.." | Starship "..star_ver)
print("Host Engine: "..host_name)
print("Renderer:    "..renderer)
print("Target Font: "..yellow..font_name..reset)

if not os.getenv("WT_SESSION") and not os.getenv("WEZTERM_EXECUTABLE") then
     print("")
     if font_name == "System Default (Consolas)" then
         print(red.."[ERROR] No custom font detected in Registry."..reset)
     else
         print(cyan.."[INFO] Legacy Console Detected."..reset)
         print("If you see boxes [] below, Conhost rejected '"..font_name.."'.")
     end
end
print(border.."========================================"..reset)
