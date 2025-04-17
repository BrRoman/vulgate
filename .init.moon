#!/usr/bin/env moonc

-- Copyright (c) 2025 jperon <cataclop@hotmail.com>
-- SPDX-License-Identifier: MIT

EPUB_DIR = "_epub"
:GetPath, :Route, :ServeRedirect, :Slurp, :Barf, :Write, :LaunchBrowser, :ProgramDirectory = _G
:chdir, :mkdir, :opendir, :getcwd, :rmrf, :execve, :nanosleep, :fork, :exit, :DT_DIR = require"unix"
ProgramDirectory getcwd!
html = require"html"
:concat = table

lsr = (ret={})=>
  for entry, kind in opendir @
    if entry ~= "." and entry ~= ".."
      full_path = "#{@}/#{entry}"
      if kind == DT_DIR
        lsr full_path, ret
      else
        ret[#ret+1] = full_path
  ret

textus = Slurp"vulgate_with_accents.txt"

local container
container =
  __call: -> setmetatable {}, container
  __index: (k) =>
    if rawget @, #@ ~= k
      @[#@+1] = k
    @[k] = container!
    @[k]
  __newindex: (k, v) =>
    rawset @, #@+1, k
    rawset @, k, v
setmetatable container, container

vulgata = container!
for liber, capitulum, versus, verba in textus\gmatch"(%w+)%s+(%d+)%s+(%d+)%s+([^\n]+)"
  vulgata[liber][capitulum][versus] = verba

html_liber = => with html
  return .section(
    .h1 @
    [ .div(
      .h2 id: capitulum, capitulum
      .p [ .sup(.small id: "#{capitulum},#{versus}", versus) .. " " .. vulgata[@][capitulum][versus] for versus in *vulgata[@][capitulum] ]
    ) for capitulum in *vulgata[@] ]
  )

make_epub = ->
  mkdir dir for dir in *{EPUB_DIR, "#{EPUB_DIR}/EPUB", "#{EPUB_DIR}/META-INF"}
  chdir EPUB_DIR
  Barf "mimetype", "application/epub+zip"
  Barf "META-INF/container.xml", '<?xml version="1.0" encoding="UTF-8"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="EPUB/content.opf" media-type="application/oebps-package+xml" /></rootfiles></container>'
  for liber in *vulgata
    with html
      Barf "EPUB/#{liber}.xhtml", .html(
        lang: 'lat'
        .head .title liber
        .body html_liber liber
      )
  with html
    Barf "EPUB/content.opf", '<?xml version="1.0" encoding="UTF-8"?>' .. .package(
      xmlns:"http://www.idpf.org/2007/opf", version:"3.0"
      .metadata(
        "xmlns:dc":"http://purl.org/dc/elements/1.1/"
        '<dc:title>Vulgate</dc:title><dc:language>la</dc:language>'
      )
      .manifest(
        .item id:"ncx", href:"toc.ncx", "media-type":"application/x-dtbncx+xml"
        .item id:"nav", href:"nav.xhtml", "media-type":"application/xhtml+xml", properties:"nav"
        [ .item(id:liber, href:"#{liber}.xhtml", "media-type":"application/xhtml+xml") for liber in *vulgata ]
      )
      .spine(
        .itemref idref:"toc"
        [ .itemref(idref:liber) for liber in *vulgata ]
      )
      .guide .reference type:"toc", title:"Index", href:"nav.xhtml"
    )
  with html
    Barf "EPUB/toc.ncx", '<?xml version="1.0" encoding="UTF-8"?>' .. .ncx(
      xmlns:"http://www.daisy.org/z3986/2005/ncx/", version:"2005-1"
      .head(
        .meta name:"dtb:uid", content:"urn:uuid:12345"
        .meta name:"dtb:depth", content:"1"
        .meta name:"dtb:totalPageCount", content:"0"
        .meta name:"dtb:maxPageNumber", content:"0"
      )
      .docTitle .text "Vulgate"
      .navMap [ .navPoint(
        id:"#{liber}"
        .navLabel .text liber
        .content src:"#{liber}.xhtml"
        [ .navPoint(
          id:"#{liber}-#{capitulum}"
          .navLabel .text capitulum
          .content src:"#{liber}.xhtml##{capitulum}"
        ) for capitulum in *vulgata[liber] ]
      ) for liber in *vulgata ]
    )
  with html
    Barf "EPUB/nav.xhtml", '<?xml version="1.0" encoding="UTF-8"?>' .. .html(
      lang: 'lat'
      .head(
        .title "Index"
      )
      .body(
        "epub:type":"frontmatter"
        .nav(
          "epub:type":"toc", id:"toc",
          .h1 id:"toc-title", "Index"
          .ol(
            [ .li(
              .a href: "#{liber}.xhtml", liber
              .ol(
                [ .li(
                  .a href: "#{liber}.xhtml##{capitulum}", capitulum
                ) for capitulum in *vulgata[liber] ]
              )
            ) for liber in *vulgata ]
          )
        )
      )
    )
  if fork! == 0
    rmrf"../vulgata.epub"
    args = {"-r", "../vulgata.epub"}
    args[#args+1] = f for f in *lsr "."
    execve "../zip", args
    exit 0
  chdir".."
  nanosleep 2
  rmrf"_epub"


export OnHttpRequest = ->
  path = GetPath!\match"^/(.*)"

  return Route! if path\sub(-4) == ".css"
  
  if path == "vulgata.epub"
    make_epub!
    return Route! 
  
  with html
    title, content = if path == ''
      "Sacra Scriptura", .h1("Sacra Scriptura", .small .a href:"/vulgata.epub", "(epub)") ..
        concat [ .h2(.a href:"/#{liber}", liber) .. concat(
          [ .a href:"/#{liber}##{capitulum}", capitulum for capitulum in *vulgata[liber] ], " "
        ) for liber in *vulgata when #vulgata[liber] > 0 ]
    else
      liber = path\sub(1,1)\upper! .. path\sub(2)\lower!
      "Sacra Scriptura - #{liber}", #vulgata[liber] > 0 and html_liber(liber) or ServeRedirect 302, "/"
    
    Write .html(
      lang:'lat'
      .head(
        .title title
        .link rel:'stylesheet', type:'text/css', href:'/style.css'
      )
      .body .main content
    )

LaunchBrowser "/"
