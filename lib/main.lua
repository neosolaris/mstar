#!/usr/bin/env luajit
-- Luajit console memo program
-- first version: 0.1beta ()
-- 검색시 hyg와 dso는 다르다. dso는 m31 했을때 31,m 이런식이다.
-- 이를 잘 고려해서 검색을 해야한다.

-- ## TODO

--## Require
local m = require'mjlib'

--## Var Set
local version = '0.0.1'
local PREFIX = os.getenv('MSTAR')
if not PREFIX then PREFIX = m.prefix(arg[0]) end
local EDITOR = os.getenv('EDITOR')
if not EDITOR then EDITOR = 'vim' end
local PREFIX_DATA = PREFIX..'/data'
--local HOSTNAME = m.gethostname()
--local DBFILE = PREFIX_DATA..'/memo.db'
local progname = m.basename(PREFIX)
--print(MCONF, MCONF_DATA)

local HYG_DB = PREFIX..'/data/hygdata_v3.csv'
local DSO_DB = PREFIX..'/data/dso.csv'

-- get csv colnames from file
local function csvcols(f)
  local cols = m.splits(m.readline(f),',')
  return cols
end

local HYG_COLS = csvcols(HYG_DB)
local DSO_COLS = csvcols(DSO_DB)
--[[
local DSO_SECT = {
  M = 'Messier (bright objects of all types)',
  NGC =  'New General Catalogue (all types)',
  IC = 'Index Catalog (all types)',
  C = 'Caldwell (bright objects of all types)',
  Col =  'Collinder (open clusters and associations)',
  PK =  'Perek + Kohoutek (planetary nebulas)',
  PGC =  'Principal Galaxy Catalog',
  UGC =  'Uppsala Galaxy Catalog',
  ESO =  'European Southern Observatory Catalog (galaxies)',
  Ter =  'Terzian (globular clusters)',
  Pal =  'Palomar (globular clusters)',
}
--]]
--
local DSO_SECT = {'M', 'NGC', 'IC', 'C', 'Col', 'PK', 'PGC', 'UGC', 'ESO', 'Ter', 'Pal'}

--## under functions
local function print_line(str)
  local str = str or ''
  --m.cprint('留 ------------------------------------------------------------')
  m.cprint('  ----------------------------------------------------------- ')
end

-- 출력 마지막에 결과를 표시
local function print_last(title, sub)
  sub = sub or ''
  local icon = nil
  local t = string.lower(title)
  if t == 'search' then
    icon = ''
  elseif t == 'help' then
    icon = ''
  elseif t == 'list' then
    icon = ''
  --elseif t == 'add' then
  --  icon = ''
  --elseif t == 'edit' then
  --  icon = ''
  --elseif t == 'delete' then
  -- icon = ''
  --elseif t == 'view' then
  --  icon = ''
  else
    icon = ''
  end
  --local str = string.format('﮶_%s_%s %s %s ﰲ %s', progname, version, icon, title, sub)
  local lua = m.cstr('','lred')
  local ptitle = m.cstr(progname..'_'..version, 'yellow')
  local mtitle = m.cstr(icon..' '..title..' ﰲ '..sub, 'lcyan')
  --local str = string.format(' _%s_%s %s %s ﰲ %s', progname, version, icon, title, sub)
  print(string.format('%s %s %s', lua, ptitle, mtitle))
end

-- help 도움말
local function do_help(args)
  m.cprint('Usage: '..progname..' "keyword"', 'lyellow')
  print([[
  mstar m31       -- Deep-Skey Object Search (DSO)
  mstar hd220369  -- Star Object Search (HYG)
  ]])
  print_last('help','Star-Object Search Powered by LuaJit')
end

--## do functions

-- list memo from data
local function do_list(args)
  print('do_list()')
end

local function do_view(args)
  print('-> do_view: ')
end

local function get_hygtable(key,val,line)
  local colk,coli = m.incols(key,HYG_COLS)
  if colk then
    --print(line)
    for i,v in pairs(m.splits(line,',')) do
      --print(i,coli,v,val)
      if i == coli and v == val then
        return m.mapdic(HYG_COLS, m.splits(line,','))
      end
    end
  end
end

local function get_dsotable(key,val,line)
  local colk,coli = m.incols(key,DSO_SECT)
  if colk then
    local d = m.mapdic(DSO_COLS, m.splits(line,','))
    if (d.cat1 == colk and d.id1 == val) or
       (d.cat2 == colk and d.id2 == val) then
      return d
    end
  else
    colk,coli = m.incols(key,DSO_COLS)
    if colk then
      for i,v in pairs(m.splits(line,',')) do
        if i == coli and v == val then
          return m.mapdic(DSO_COLS, m.splits(line,','))
        end
      end
    end
  end
end

-- show csv star data: t is mapping table
local function show_data(key,val,line,dbfile)
  local s = '  '
  local info = ''
  local d = {}
  if dbfile == DSO_DB then
    -- 여기서 k,v를 이용해서 t를 매핑해온다.
    d = get_dsotable(key,val,line)
    if d then
      print_line()
      print(s..'id:' .. d.id ..s.. d.name)
      print(s..'dso_source:' .. d.dso_source)
      print(s..d.cat1 .. d.id1 ..s.. d.cat2 .. d.id2 ..s.. d.dupcat .. d.dupid .. 'type:'.. d.type ..s.. 'const:' .. d.const)
      print(s..'ra:' .. d.ra ..' dec:' .. d.dec)
      print(s..'rarad:' .. d.rarad ..s.. 'radec:' .. d.decrad)
      print(s..'angle:' .. d.angle ..s.. 'r1:' .. d.r1 ..s.. 'r2:' .. d.r2)
      print(s..'mag:' .. d.mag ..s.. 'display_mag:' .. d.display_mag)
      print_line()
      info = string.format('[DSO: Deep-Sky] '.. key .. val)
    end
  elseif dbfile == HYG_DB then
    d = get_hygtable(key,val,line)
    --if d then m.tprint(d) end
    if d then
      print_line()
      print(s..'id:' .. d.id ..s..'hip:'.. d.hip ..s..'hd:'.. d.hd ..s..'hr:' .. d.hr ..s..'gl:'.. d.gl)
      print(s..'bf:' .. d.bf ..s.. 'ra:' .. d.ra ..s..'dec:'.. d.dec ..s..'proper:' .. d.proper)
      print(s..'dist:' .. d.dist ..s.. 'pmra:' .. d.pmra ..s.. 'pmdec:' .. d.pmdec ..s.. 'rv:' .. d.rv ..s.. 'mag:' .. d.mag)
      print(s.. 'spect:' .. d.spect ..s.. 'ci:' .. d.ci)
      print(s.. 'x:' .. d.x ..s.. 'y:' .. d.y ..s.. 'z:' .. d.z)
      print(s.. 'vx:' .. d.vx ..s.. 'vy:' .. d.vy ..s.. 'vz:' .. d.vz)
      print(s.. 'rarad:' .. d.rarad ..s.. 'decrad:' .. d.decrad)
      print(s.. 'pmrarad:' .. d.pmrarad ..s.. 'pmdecrad:' .. d.pmdecrad)
      print(s.. 'bayer:' .. d.bayer ..s.. 'flam:' .. d.flam ..s.. 'con:' .. d.con)
      print(s.. 'comp:' .. d.comp ..s.. 'comp_primary:' .. d.comp_primary ..s.. 'base:' .. d.base)
      print(s.. 'lum:' .. d.lum ..s.. 'var:' .. d.var ..s.. 'var_min:' .. d.var_min ..s.. 'var_max:' ..d.var_max)
      print_line()
      info = string.format('[HYG: Star] '.. key .. val)
    end
  else
    print('-> show_data: dbfile is not correct')
  end
  -- show last print
  if d then print_last('Search',info) end
end

local function splitarg(arg)
  return string.match(arg, '(%a+)(%d+)')
end

local function incsv(k,v)
  if k then
    if m.incols(k, DSO_SECT) then
      return v..','..k, DSO_DB
    elseif m.incols(k,DSO_COLS) then
      return v, DSO_DB
    elseif m.incols(k, HYG_COLS) then
      return v, HYG_DB
    end
  end
end

local function findcsv(key,dbfile)
  if key and dbfile then
  -- 여기에서 키워드와 검색파일을 얻는 코드 작성
    --print(key,dbfile)
    local f = assert(io.popen("/usr/bin/grep -iw '"..key.."' "..dbfile))
    --local out = f:read("*a") or ""
    local out = f:read("*a")
    f:close()
    return out
  else
    print('-> findcsv: key or dbfile is nil')
  end
end

local function do_search(args)
  for _,ar in pairs(args) do
    local k,v = splitarg(ar)
    if k then
      local skey,dbfile = incsv(k,v)
      if skey then
        local out = findcsv(skey, dbfile)
        if out then
          for _,line in pairs(m.splits(out,'\n')) do
            if not line:find('^%s?$') then
              --print(line)
              show_data(k,v,line,dbfile)
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------
-- ## Main
-------------------------------------------------------------------------

-- receive opt, args from arg
local args = m.sargs()

-- execute function by select option
--csvcols(HYG_DB)

-- if no args
if #arg == 0 then do_help() os.exit() end

print()
if arg[1] == '-h' or opt == 'help' or opt == 'h' then
  do_help(table.remove(args,1))
elseif arg[1] == '-l' or opt == 'list' or opt == 'l' then
  do_list(table.remove(args,1))
elseif arg[1] == '-s' or opt == 'search' or opt == 's' then
  do_search(table.remove(args,1))
elseif arg[1] == '-v' or opt == 'view' or opt == 'v' then
  print(version)
else
  if tonumber(arg[1]) then
    print(arg[1]..' is number!')
  end
  do_search(args)
end
print()
