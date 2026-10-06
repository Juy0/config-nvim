local M = {}

-- Récupère le socket de contrôle de Kitty.
-- Kitty peut ajouter un suffixe -PID au chemin (ex: unix:/tmp/kitty.sock-19197),
-- donc on se fie d'abord à KITTY_LISTEN_ON, puis on cherche dans /tmp.
local function get_socket()
  if vim.env.KITTY_LISTEN_ON and vim.env.KITTY_LISTEN_ON ~= "" then
    return vim.env.KITTY_LISTEN_ON
  end
  local socks = vim.fn.glob("/tmp/kitty.sock-*", false, true)
  if #socks > 0 then return "unix:" .. socks[1] end
  return nil
end

local function get_kitty_colors()
  local kitty_bin = vim.fn.exepath("kitty")
  if kitty_bin == "" then kitty_bin = "/opt/homebrew/bin/kitty" end

  local sock = get_socket()
  if not sock then
    return nil, "aucun socket kitty trouvé (KITTY_LISTEN_ON vide et pas de /tmp/kitty.sock-*)"
  end

  local output = vim.fn.system({ kitty_bin, "@", "--to", sock, "get-colors" })
  if vim.v.shell_error ~= 0 or output == "" then
    return nil, output
  end

  local colors = {}
  for line in output:gmatch("[^\n]+") do
    local key, hex = line:match("^(%S+)%s+(#%x+)")
    if key and hex then colors[key] = hex end
  end
  return colors
end

local function kitty_to_base16(c)
  if not c.background or not c.foreground then return nil end
  return {
    base00 = c.background, base01 = c.color0,  base02 = c.color8,
    base03 = c.color8,     base04 = c.color7,  base05 = c.foreground,
    base06 = c.color15,    base07 = c.color15, base08 = c.color1,
    base09 = c.color9,     base0A = c.color3,  base0B = c.color2,
    base0C = c.color6,     base0D = c.color4,  base0E = c.color5,
    base0F = c.color13,
  }
end

-- Fonction de diagnostic : à lancer manuellement avec
--   :lua require("j.theme_sync").debug()
function M.debug()
  print("=== DEBUG theme_sync ===")
  local kitty_bin = vim.fn.exepath("kitty")
  print("kitty bin:", kitty_bin ~= "" and kitty_bin or "<introuvable>")
  print("KITTY_LISTEN_ON:", vim.env.KITTY_LISTEN_ON or "<vide>")
  print("socket résolu:", get_socket() or "<aucun>")

  local sock = get_socket() or "unix:/tmp/invalid"
  local out = vim.fn.system({ kitty_bin, "@", "--to", sock, "get-colors" })
  print("sortie get-colors (5 premières lignes):")
  local n = 0
  for line in out:gmatch("[^\n]+") do
    print("  " .. line); n = n + 1
    if n >= 5 then break end
  end

  local ok_mini = pcall(require, "mini.base16")
  print("mini.base16 chargé:", ok_mini and "OK" or "ECHEC")
end

function M.sync()
  local kitty, err = get_kitty_colors()
  if not kitty then
    vim.notify("theme_sync: kitty injoignable\n" .. (err or ""), vim.log.levels.WARN)
    return
  end

  local palette = kitty_to_base16(kitty)
  if not palette then
    vim.notify("theme_sync: palette incomplète (background/foreground manquant)",
               vim.log.levels.WARN)
    return
  end

  local ok, mini = pcall(require, "mini.base16")
  if not ok then
    vim.notify("theme_sync: mini.base16 introuvable — lance :Lazy sync",
               vim.log.levels.ERROR)
    return
  end

  mini.setup({ palette = palette, use_cterm = true })

  -- Fond transparent pour laisser voir le wallpaper
  vim.api.nvim_set_hl(0, "Normal",      { bg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
end

-- Applique au démarrage (après chargement complet de Lazy)
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = M.sync,
})

-- Réapplique à chaque fois que tu reviens sur Neovim
vim.api.nvim_create_autocmd("FocusGained", {
  callback = M.sync,
})

return M
