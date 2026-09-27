-- promt by @mopscode
-- language: Lua, file: NodiumUI.lua, target: Roblox executor
-- compact build, always-on-top, tabs + subtabs + widgets

local N = {}
local Plr, UIS, TS = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService")
local CG = game:GetService("CoreGui")
local LP = Plr.LocalPlayer

local C = {
    bg=Color3.fromRGB(10,10,12), card=Color3.fromRGB(18,18,22), row=Color3.fromRGB(24,24,28),
    bd=Color3.fromRGB(34,34,40), bds=Color3.fromRGB(26,26,32), tx=Color3.fromRGB(238,238,242),
    td=Color3.fromRGB(150,150,160), tm=Color3.fromRGB(96,96,106), ac=Color3.fromRGB(255,108,42),
    acd=Color3.fromRGB(120,52,22), dg=Color3.fromRGB(230,80,90), ok=Color3.fromRGB(110,200,140),
    tk=Color3.fromRGB(46,46,52),
}

local function tw(o,t,p) pcall(function() TS:Create(o,TweenInfo.new(t or .12),p):Play() end) end
local function mk(c,p,pa) local o=Instance.new(c) for k,v in pairs(p or {}) do o[k]=v end if pa then o.Parent=pa end return o end
local function rnd(o,r) return mk("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function str(o,col,t,tr) return mk("UIStroke",{Color=col or C.bd,Thickness=t or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
local function root()
    local g=mk("ScreenGui",{Name="NodiumUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=2147483647})
    if gethui then if pcall(function() g.Parent=gethui() end) and g.Parent then return g end end
    if pcall(function() g.Parent=CG end) and g.Parent then return g end
    pcall(function() g.Parent=LP:WaitForChild("PlayerGui",5) end)
    if not g.Parent then g.Parent=CG end
    return g
end
local function vp() local c=workspace.CurrentCamera return c and c.ViewportSize or Vector2.new(1280,720) end
local function drag(f,h)
    h=h or f
    local d,s,p
    h.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            d=true s=i.Position p=f.Position
            local c c=i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then d=false c:Disconnect() end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local m=i.Position-s
            f.Position=UDim2.new(p.X.Scale,p.X.Offset+m.X,p.Y.Scale,p.Y.Offset+m.Y)
        end
    end)
end

local function sec(parent, name)
    local host = parent.frame or parent.def
    local w = mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.card,BorderSizePixel=0,ZIndex=102},host)
    rnd(w,10) str(w,C.bds,1,.3)
    mk("UIPadding",{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},w)
    mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},w)
    local hd = mk("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,ZIndex=103},w)
    local rg = mk("Frame",{Position=UDim2.fromOffset(0,5),Size=UDim2.fromOffset(8,8),BackgroundColor3=C.acd,BorderSizePixel=0,ZIndex=103},hd)
    rnd(rg,4)
    mk("TextLabel",{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-14,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=string.upper(name),TextColor3=C.tm,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=103},hd)
    local S = {}
    local function row(lbl,h)
        local r=mk("Frame",{Size=UDim2.new(1,0,0,h or 26),BackgroundTransparency=1,ZIndex=103},w)
        mk("TextLabel",{Size=UDim2.new(1,-110,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=lbl,TextColor3=C.tx,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=104},r)
        return r
    end
    function S:CreateToggle(n,d,cb)
        local on=d or false
        local r=row(n or "Toggle",26)
        local tr=mk("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(38,20),BackgroundColor3=C.tk,BorderSizePixel=0,ZIndex=104},r)
        rnd(tr,10)
        local kn=mk("Frame",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,2,.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(210,210,216),BorderSizePixel=0,ZIndex=105},tr)
        rnd(kn,8)
        local function rr()
            tw(tr,.12,{BackgroundColor3=on and C.ac or C.tk})
            tw(kn,.12,{Position=on and UDim2.new(1,-18,.5,0) or UDim2.new(0,2,.5,0),BackgroundColor3=on and Color3.new(1,1,1) or Color3.fromRGB(210,210,216)})
        end
        rr()
        local cl=mk("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=106},r)
        cl.MouseButton1Click:Connect(function() on=not on rr() if cb then cb(on) end end)
        return {Set=function(_,v) on=v rr() end, Get=function() return on end}
    end
    function S:CreateSlider(n,mn,mx,d,cb)
        mn,mx=mn or 0,mx or 100
        local v=d or mn
        local r=mk("Frame",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,ZIndex=103},w)
        mk("TextLabel",{Size=UDim2.new(1,-110,0,16),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=n or "Slider",TextColor3=C.tx,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=104},r)
        local vb=mk("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(56,22),BackgroundColor3=C.row,BorderSizePixel=0,ZIndex=104},r)
        rnd(vb,5) str(vb,C.bds,1,.5)
        local vl=mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=tostring(v),TextColor3=C.tx,TextSize=12,ZIndex=105},vb)
        local bar=mk("Frame",{Position=UDim2.new(0,0,1,-8),Size=UDim2.new(1,-70,0,4),BackgroundColor3=C.tk,BorderSizePixel=0,ZIndex=104},r)
        rnd(bar,2)
        local fl=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.ac,BorderSizePixel=0,ZIndex=105},bar)
        rnd(fl,2)
        local dt=mk("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(10,10),BackgroundColor3=Color3.fromRGB(240,240,245),BorderSizePixel=0,ZIndex=106},bar)
        rnd(dt,5)
        local dr=false
        local function set(x)
            local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
            v=math.clamp(math.floor(mn+(mx-mn)*rel+.5),mn,mx)
            local p=(v-mn)/math.max(mx-mn,1e-6)
            fl.Size=UDim2.new(p,0,1,0) dt.Position=UDim2.new(p,0,.5,0) vl.Text=tostring(v)
            if cb then cb(v) end
        end
        bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true set(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then set(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
        return {Set=function(_,x) v=math.clamp(x,mn,mx) end, Get=function() return v end}
    end
    function S:CreateKeybind(n,d,cb)
        local cur=d or Enum.KeyCode.V
        local lis=false
        local r=row(n or "Keybind",26)
        local kb=mk("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(40,22),BackgroundColor3=C.row,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=cur.Name,TextColor3=C.td,TextSize=11,AutoButtonColor=false,ZIndex=104},r)
        rnd(kb,5) str(kb,C.bds,1,.5)
        kb.MouseButton1Click:Connect(function() lis=true kb.Text="..." kb.TextColor3=C.ac end)
        UIS.InputBegan:Connect(function(i,g)
            if g then return end
            if lis and i.UserInputType==Enum.UserInputType.Keyboard then
                cur=i.KeyCode kb.Text=cur.Name kb.TextColor3=C.td lis=false
            elseif not lis and i.KeyCode==cur then if cb then cb() end end
        end)
        return {Set=function(_,k) cur=k kb.Text=k.Name end, Get=function() return cur end}
    end
    function S:CreateButton(n,cb)
        local r=row(n or "Button",26)
        local b=mk("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),Size=UDim2.fromOffset(70,22),BackgroundColor3=C.row,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text="run",TextColor3=C.td,TextSize=11,AutoButtonColor=false,ZIndex=104},r)
        rnd(b,5) str(b,C.bds,1,.5)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        return b
    end
    function S:CreateTextbox(n,d,cb)
        local r=mk("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,ZIndex=103},w)
        mk("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=n or "Input",TextColor3=C.tx,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=104},r)
        local bx=mk("TextBox",{Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,20),BackgroundColor3=C.row,BorderSizePixel=0,Font=Enum.Font.Gotham,Text=d or "",PlaceholderText="...",TextColor3=C.tx,PlaceholderColor3=C.tm,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=104},r)
        rnd(bx,5) str(bx,C.bds,1,.4)
        mk("UIPadding",{PaddingLeft=UDim.new(0,6)},bx)
        bx.FocusLost:Connect(function(e) if cb then cb(bx.Text,e) end end)
        return {Set=function(_,v) bx.Text=v end, Get=function() return bx.Text end}
    end
    return S
end

function N:Window(cfg)
    cfg=cfg or {}
    local title=cfg.title or "NodiumUI"
    local sub=cfg.subtitle or "v1.0"
    local fl=cfg.footerLeft or "Connected"
    local fm=cfg.footerMid or "MM2"
    local top=cfg.alwaysOnTop~=false
    local s=vp()
    local w=math.max(math.min(cfg.width or 860,s.X-40),620)
    local h=math.max(math.min(cfg.height or 520,s.Y-40),380)
    local gui=root()
    if top and protect_gui then pcall(protect_gui,gui) end
    local win={tabs={},gui=gui,visible=true,w=w,h=h}

    local p=mk("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(w,h),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,ZIndex=100},gui)
    rnd(p,12) str(p,C.bd,1,0)
    win.panel=p
    if top then
        game:GetService("RunService").RenderStepped:Connect(function() pcall(function() gui.DisplayOrder=2147483647 end) end)
    end

    local tb=mk("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.bg,BorderSizePixel=0,ZIndex=101},p)
    mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.bds,BorderSizePixel=0,ZIndex=101},tb)
    local tl=mk("TextLabel",{Position=UDim2.fromOffset(18,6),Size=UDim2.new(0,240,0,24),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=title,TextColor3=C.tx,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},tb)
    local sl=mk("TextLabel",{Position=UDim2.fromOffset(80,28),Size=UDim2.new(0,200,0,14),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=sub,TextColor3=C.tm,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},tb)
    task.defer(function() sl.Position=UDim2.new(0,18+tl.TextBounds.X+6,0,28) end)

    local tr=mk("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(0,w-380,1,0),BackgroundTransparency=1,ZIndex=102},tb)
    mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},tr)

    local function cb(g,x,col)
        local b=mk("TextButton",{Position=UDim2.new(1,-x,.5,-13),Size=UDim2.fromOffset(26,26),BackgroundColor3=C.bg,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=g,TextColor3=C.td,TextSize=14,AutoButtonColor=false,ZIndex=103},tb)
        rnd(b,6)
        b.MouseEnter:Connect(function() tw(b,.1,{BackgroundColor3=col,TextColor3=C.tx}) end)
        b.MouseLeave:Connect(function() tw(b,.1,{BackgroundColor3=C.bg,TextColor3=C.td}) end)
        return b
    end
    cb("?",90,C.row)
    local mn=cb("-",56,C.row)
    local cl=cb("x",22,C.dg)

    local bd=mk("Frame",{Position=UDim2.fromOffset(0,46),Size=UDim2.new(1,0,1,-88),BackgroundTransparency=1,ZIndex=101},p)

    local ft=mk("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,42),BackgroundColor3=C.bg,BorderSizePixel=0,ZIndex=101},p)
    mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.bds,BorderSizePixel=0,ZIndex=101},ft)
    local dt=mk("Frame",{Position=UDim2.fromOffset(18,17),Size=UDim2.fromOffset(8,8),BackgroundColor3=C.ok,BorderSizePixel=0,ZIndex=102},ft)
    rnd(dt,4)
    mk("TextLabel",{Position=UDim2.fromOffset(34,0),Size=UDim2.new(0,160,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=fl,TextColor3=C.td,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},ft)
    mk("TextLabel",{Position=UDim2.fromOffset(180,0),Size=UDim2.new(0,200,1,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=fm,TextColor3=C.tm,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},ft)
    local function fb(l,x,bg,fg,cbx)
        local b=mk("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-x,.5,0),Size=UDim2.fromOffset(110,28),BackgroundColor3=bg,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=l,TextColor3=fg,TextSize=12,AutoButtonColor=false,ZIndex=102},ft)
        rnd(b,6) str(b,C.bd,1,.4)
        b.MouseButton1Click:Connect(function() if cbx then cbx() end end)
        return b
    end
    local nb=mk("TextBox",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-250,.5,0),Size=UDim2.fromOffset(140,28),BackgroundColor3=C.row,BorderSizePixel=0,Font=Enum.Font.Gotham,Text="Default",PlaceholderText="Config name",TextColor3=C.tx,PlaceholderColor3=C.tm,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=102},ft)
    rnd(nb,6) str(nb,C.bd,1,.4)
    mk("UIPadding",{PaddingLeft=UDim.new(0,10)},nb)
    fb("Reset",146,C.row,C.td,cfg.onReset)
    fb("Save config",22,C.ac,Color3.fromRGB(20,20,20),cfg.onSave)

    drag(p,tb)
    local mini=false
    mn.MouseButton1Click:Connect(function()
        mini=not mini
        tw(p,.18,{Size=mini and UDim2.fromOffset(w,46) or UDim2.fromOffset(w,h)})
        bd.Visible=not mini ft.Visible=not mini
    end)
    cl.MouseButton1Click:Connect(function()
        local ov=mk("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.4,Text="",AutoButtonColor=false,ZIndex=500},gui)
        local bx=mk("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(300,150),BackgroundColor3=C.card,BorderSizePixel=0,ZIndex=501},ov)
        rnd(bx,12) str(bx,C.bd,1,0)
        mk("TextLabel",{Size=UDim2.new(1,-28,0,22),Position=UDim2.fromOffset(16,18),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="Подтверждение",TextColor3=C.tx,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=502},bx)
        mk("TextLabel",{Size=UDim2.new(1,-28,0,20),Position=UDim2.fromOffset(16,44),BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Точно закрыть окно?",TextColor3=C.td,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=502},bx)
        local nb2=mk("TextButton",{Size=UDim2.new(.5,-20,0,34),Position=UDim2.new(0,14,1,-50),BackgroundColor3=C.row,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text="Отмена",TextColor3=C.tx,TextSize=13,AutoButtonColor=false,ZIndex=502},bx)
        rnd(nb2,6)
        nb2.MouseButton1Click:Connect(function() ov:Destroy() end)
        local yb=mk("TextButton",{Size=UDim2.new(.5,-20,0,34),Position=UDim2.new(.5,14,1,-50),BackgroundColor3=C.ac,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text="Да",TextColor3=Color3.fromRGB(20,20,20),TextSize=13,AutoButtonColor=false,ZIndex=502},bx)
        rnd(yb,6)
        yb.MouseButton1Click:Connect(function() ov:Destroy() gui:Destroy() end)
    end)

    local pgs=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=101},bd)

    function win:CreateTab(name)
        name=name or "Tab"
        local b=mk("TextButton",{Size=UDim2.fromOffset(0,28),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=C.bg,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=name,TextColor3=C.td,TextSize=13,AutoButtonColor=false,ZIndex=103},tr)
        mk("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},b)
        rnd(b,6)
        local pg=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=101},pgs)
        local hd=mk("Frame",{Position=UDim2.fromOffset(18,14),Size=UDim2.new(1,-36,0,40),BackgroundTransparency=1,ZIndex=101},pg)
        mk("TextLabel",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,220,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=name,TextColor3=C.tx,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},hd)
        local pr=mk("Frame",{Position=UDim2.fromOffset(230,0),Size=UDim2.new(1,-230,1,0),BackgroundTransparency=1,ZIndex=102},hd)
        mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},pr)
        local ho=mk("Frame",{Position=UDim2.fromOffset(18,66),Size=UDim2.new(1,-36,1,-80),BackgroundTransparency=1,ZIndex=101},pg)
        local dc=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=101},ho)
        mk("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},dc)
        local function act()
            for _,t in ipairs(win.tabs) do t.pg.Visible=false t.b.TextColor3=C.td t.b.BackgroundColor3=C.bg end
            pg.Visible=true b.TextColor3=C.tx b.BackgroundColor3=C.row
        end
        b.MouseButton1Click:Connect(act)
        if #win.tabs==0 then act() end
        local tab={pg=pg,b=b,win=win,sts={},dc=dc,name=name}
        table.insert(win.tabs,tab)
        function tab:CreateSubTab(sn)
            sn=sn or "Sub"
            local pl=mk("TextButton",{Size=UDim2.fromOffset(0,26),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=C.card,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=sn,TextColor3=C.td,TextSize=12,AutoButtonColor=false,ZIndex=103},pr)
            mk("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},pl)
            rnd(pl,6) str(pl,C.bds,1,.5)
            local sc=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=101},ho)
            mk("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},sc)
            local s={frame=sc,tab=tab,pl=pl,name=sn}
            local function as()
                for _,x in ipairs(tab.sts) do x.frame.Visible=false x.pl.BackgroundColor3=C.card x.pl.TextColor3=C.td end
                dc.Visible=false sc.Visible=true
                pl.BackgroundColor3=C.row pl.TextColor3=C.tx
            end
            pl.MouseButton1Click:Connect(as)
            if #tab.sts==0 then as() end
            table.insert(tab.sts,s)
            function s:CreateSection(n) return sec(s,n or "Section") end
            return s
        end
        function tab:CreateSection(n)
            if #tab.sts>0 then return sec(tab.sts[1],n or "Section") end
            return sec(tab,n or "Section")
        end
        return tab
    end

    UIS.InputBegan:Connect(function(i,g)
        if g then return end
        if i.KeyCode==Enum.KeyCode.RightShift then win.visible=not win.visible p.Visible=win.visible end
    end)
    return setmetatable(win,win)
end

return N
