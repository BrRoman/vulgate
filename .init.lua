local EPUB_DIR = "_epub"
local GetPath, Route, ServeRedirect, Slurp, Barf, Write, LaunchBrowser, ProgramDirectory
do
  local _obj_0 = _G
  GetPath, Route, ServeRedirect, Slurp, Barf, Write, LaunchBrowser, ProgramDirectory = _obj_0.GetPath, _obj_0.Route, _obj_0.ServeRedirect, _obj_0.Slurp, _obj_0.Barf, _obj_0.Write, _obj_0.LaunchBrowser, _obj_0.ProgramDirectory
end
local chdir, mkdir, opendir, getcwd, rmrf, execve, nanosleep, fork, exit, DT_DIR
do
  local _obj_0 = require("unix")
  chdir, mkdir, opendir, getcwd, rmrf, execve, nanosleep, fork, exit, DT_DIR = _obj_0.chdir, _obj_0.mkdir, _obj_0.opendir, _obj_0.getcwd, _obj_0.rmrf, _obj_0.execve, _obj_0.nanosleep, _obj_0.fork, _obj_0.exit, _obj_0.DT_DIR
end
print(getcwd())
ProgramDirectory(getcwd())
local html = require("html")
local concat
concat = table.concat
local lsr
lsr = function(self, ret)
  if ret == nil then
    ret = { }
  end
  for entry, kind in opendir(self) do
    if entry ~= "." and entry ~= ".." then
      local full_path = tostring(self) .. "/" .. tostring(entry)
      if kind == DT_DIR then
        lsr(full_path, ret)
      else
        ret[#ret + 1] = full_path
      end
    end
  end
  return ret
end
local textus = Slurp("vulgate_with_accents.txt")
local container
container = {
  __call = function()
    return setmetatable({ }, container)
  end,
  __index = function(self, k)
    if rawget(self, #self ~= k) then
      self[#self + 1] = k
    end
    self[k] = container()
    return self[k]
  end,
  __newindex = function(self, k, v)
    rawset(self, #self + 1, k)
    return rawset(self, k, v)
  end
}
setmetatable(container, container)
local vulgata = container()
for liber, capitulum, versus, verba in textus:gmatch("(%w+)%s+(%d+)%s+(%d+)%s+([^\n]+)") do
  vulgata[liber][capitulum][versus] = verba
end
local html_liber
html_liber = function(self)
  do
    return html.section(html.h1(self), (function()
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = vulgata[self]
      for _index_0 = 1, #_list_0 do
        local capitulum = _list_0[_index_0]
        _accum_0[_len_0] = html.div(html.h2({
          id = capitulum
        }, capitulum), html.p((function()
          local _accum_1 = { }
          local _len_1 = 1
          local _list_1 = vulgata[self][capitulum]
          for _index_1 = 1, #_list_1 do
            local versus = _list_1[_index_1]
            _accum_1[_len_1] = html.sup(html.small({
              id = tostring(capitulum) .. "," .. tostring(versus)
            }, versus)) .. " " .. vulgata[self][capitulum][versus]
            _len_1 = _len_1 + 1
          end
          return _accum_1
        end)()))
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)())
  end
end
local make_epub
make_epub = function()
  local _list_0 = {
    EPUB_DIR,
    tostring(EPUB_DIR) .. "/EPUB",
    tostring(EPUB_DIR) .. "/META-INF"
  }
  for _index_0 = 1, #_list_0 do
    local dir = _list_0[_index_0]
    mkdir(dir)
  end
  chdir(EPUB_DIR)
  Barf("mimetype", "application/epub+zip")
  Barf("META-INF/container.xml", '<?xml version="1.0" encoding="UTF-8"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="EPUB/content.opf" media-type="application/oebps-package+xml" /></rootfiles></container>')
  for _index_0 = 1, #vulgata do
    local liber = vulgata[_index_0]
    do
      Barf("EPUB/" .. tostring(liber) .. ".xhtml", html.html({
        lang = 'lat'
      }, html.head(html.title(liber)), html.body(html_liber(liber))))
    end
  end
  do
    Barf("EPUB/content.opf", '<?xml version="1.0" encoding="UTF-8"?>' .. html.package({
      xmlns = "http://www.idpf.org/2007/opf",
      version = "3.0"
    }, html.metadata({
      ["xmlns:dc"] = "http://purl.org/dc/elements/1.1/"
    }, '<dc:title>Vulgate</dc:title><dc:language>la</dc:language>'), html.manifest(html.item({
      id = "ncx",
      href = "toc.ncx",
      ["media-type"] = "application/x-dtbncx+xml"
    }), html.item({
      id = "nav",
      href = "nav.xhtml",
      ["media-type"] = "application/xhtml+xml",
      properties = "nav"
    }), (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #vulgata do
        local liber = vulgata[_index_0]
        _accum_0[_len_0] = html.item({
          id = liber,
          href = tostring(liber) .. ".xhtml",
          ["media-type"] = "application/xhtml+xml"
        })
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()), html.spine(html.itemref({
      idref = "toc"
    }), (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #vulgata do
        local liber = vulgata[_index_0]
        _accum_0[_len_0] = html.itemref({
          idref = liber
        })
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()), html.guide(html.reference({
      type = "toc",
      title = "Index",
      href = "nav.xhtml"
    }))))
  end
  do
    Barf("EPUB/toc.ncx", '<?xml version="1.0" encoding="UTF-8"?>' .. html.ncx({
      xmlns = "http://www.daisy.org/z3986/2005/ncx/",
      version = "2005-1"
    }, html.head(html.meta({
      name = "dtb:uid",
      content = "urn:uuid:12345"
    }), html.meta({
      name = "dtb:depth",
      content = "1"
    }), html.meta({
      name = "dtb:totalPageCount",
      content = "0"
    }), html.meta({
      name = "dtb:maxPageNumber",
      content = "0"
    })), html.docTitle(html.text("Vulgate")), html.navMap((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #vulgata do
        local liber = vulgata[_index_0]
        _accum_0[_len_0] = html.navPoint({
          id = tostring(liber)
        }, html.navLabel(html.text(liber)), html.content({
          src = tostring(liber) .. ".xhtml"
        }), (function()
          local _accum_1 = { }
          local _len_1 = 1
          local _list_1 = vulgata[liber]
          for _index_1 = 1, #_list_1 do
            local capitulum = _list_1[_index_1]
            _accum_1[_len_1] = html.navPoint({
              id = tostring(liber) .. "-" .. tostring(capitulum)
            }, html.navLabel(html.text(capitulum)), html.content({
              src = tostring(liber) .. ".xhtml#" .. tostring(capitulum)
            }))
            _len_1 = _len_1 + 1
          end
          return _accum_1
        end)())
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)())))
  end
  do
    Barf("EPUB/nav.xhtml", '<?xml version="1.0" encoding="UTF-8"?>' .. html.html({
      lang = 'lat'
    }, html.head(html.title("Index")), html.body({
      ["epub:type"] = "frontmatter"
    }, html.nav({
      ["epub:type"] = "toc",
      id = "toc"
    }, html.h1({
      id = "toc-title"
    }, "Index"), html.ol((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #vulgata do
        local liber = vulgata[_index_0]
        _accum_0[_len_0] = html.li(html.a({
          href = tostring(liber) .. ".xhtml"
        }, liber), html.ol((function()
          local _accum_1 = { }
          local _len_1 = 1
          local _list_1 = vulgata[liber]
          for _index_1 = 1, #_list_1 do
            local capitulum = _list_1[_index_1]
            _accum_1[_len_1] = html.li(html.a({
              href = tostring(liber) .. ".xhtml#" .. tostring(capitulum)
            }, capitulum))
            _len_1 = _len_1 + 1
          end
          return _accum_1
        end)()))
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)())))))
  end
  if fork() == 0 then
    rmrf("../vulgata.epub")
    local args = {
      "-r",
      "../vulgata.epub"
    }
    local _list_1 = lsr(".")
    for _index_0 = 1, #_list_1 do
      local f = _list_1[_index_0]
      args[#args + 1] = f
    end
    execve("../zip", args)
    exit(0)
  end
  chdir("..")
  nanosleep(2)
  return rmrf("_epub")
end
OnHttpRequest = function()
  local path = GetPath():match("^/(.*)")
  if path:sub(-4) == ".css" then
    return Route()
  end
  if path == "vulgata.epub" then
    make_epub()
    return Route()
  end
  do
    local title, content
    if path == '' then
      title, content = "Sacra Scriptura", html.h1("Sacra Scriptura", html.small(html.a({
        href = "/vulgata.epub"
      }, "(epub)"))) .. concat((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #vulgata do
          local liber = vulgata[_index_0]
          if #vulgata[liber] > 0 then
            _accum_0[_len_0] = html.h2(html.a({
              href = "/" .. tostring(liber)
            }, liber)) .. concat((function()
              local _accum_1 = { }
              local _len_1 = 1
              local _list_0 = vulgata[liber]
              for _index_1 = 1, #_list_0 do
                local capitulum = _list_0[_index_1]
                _accum_1[_len_1] = html.a({
                  href = "/" .. tostring(liber) .. "#" .. tostring(capitulum)
                }, capitulum)
                _len_1 = _len_1 + 1
              end
              return _accum_1
            end)(), " ")
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)())
    else
      local liber = path:sub(1, 1):upper() .. path:sub(2):lower()
      title, content = "Sacra Scriptura - " .. tostring(liber), #vulgata[liber] > 0 and html_liber(liber) or ServeRedirect(302, "/")
    end
    Write(html.html({
      lang = 'lat'
    }, html.head(html.title(title), html.link({
      rel = 'stylesheet',
      type = 'text/css',
      href = '/style.css'
    })), html.body(html.main(content))))
    return html
  end
end
return LaunchBrowser("/")
