local M = {}

M.basename = function(s)
  -- out of file/program path just get the base name
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

M.convert_home_dir = function(path)
  local cwd = path
  local home = os.getenv("HOME")
  cwd = cwd:gsub("^" .. home .. "/", "~/")
  if cwd == "" then
    return path
  end
  return cwd
end

M.convert_useful_path = function(dir)
  local cwd = M.convert_home_dir(dir)
  return M.basename(cwd)
end

return M
