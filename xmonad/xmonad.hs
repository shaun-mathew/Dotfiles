-- TODO: Add hook to fix wallpaper on monitor hotplug
-- TODO: Add bar (either kde bar or eww bar) Xmonad --replace works with kde, but too many things to change with window overlap etc.. Sometimes items on bar, need multiple clicks to activate. Might have better luck with xfce. Focus across screens not properly working
-- TODO: Make floating layout better (they suck in xmonad, awesome better in this regard, weird behavious with sticky windows and floats)
-- TODO: Copy Windows is limiting. Would like to toggle tags like in awesome. For example, on ws 2. I can toggle tags 6 and bring them to 2.
-- TODO: Pressing Mod-Ctrl-6 toggles them off. Although to be fair, I did not use this too much
--
-- xmonad example config file.
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

  -- Base
import XMonad
import System.Directory
import System.IO (hClose, hPutStr, hPutStrLn)
import System.Exit
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, copy, copyWindow)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen, nextWS, prevWS, toggleWS, toggleOrView, shiftNextScreen, shiftPrevScreen, swapNextScreen, swapPrevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.GroupNavigation
import XMonad.Actions.SinkAll
import XMonad.Actions.TagWindows (addTag)
import XMonad.Actions.ShowText
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust, fromMaybe)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..), dynamicLog)
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.InsertPosition (insertPosition, Focus(Newer), Position(End), Focus(Older))
import XMonad.Hooks.RefocusLast (refocusLastLayoutHook, refocusLastWhen, isFloat, refocusingIsActive)

    -- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Master
import XMonad.Layout.StateFull (focusTracking)
import XMonad.Layout.PerWorkspace
import XMonad.Layout.TrackFloating

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS, FULL))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP, mkNamedKeymap)
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.WindowProperties (getProp32)
import XMonad.Util.WorkspaceCompare
import Control.Monad (liftM2)

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "kitty"


myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myBrowser :: String
myBrowser = "firefox"  -- Sets qutebrowser as browser

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["code","code+www","tiled","www","vms","chat"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#181825"
myFocusedBorderColor = "#cba6f7"

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                ]


    where
    spawnTerm  = myTerminal ++ " --class spad"
    findTerm   = className =? "spad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--


toggleFloat :: Window -> X ()
toggleFloat w =
  windows
    ( \s ->
        if M.member w (W.floating s)
          then W.sink w s
          else (W.float w (W.RationalRect (1 / 3) (1 / 4) (1 / 2) (1 / 2)) s)
    )
subtitle' ::  String -> ((KeyMask, KeySym), NamedAction)
subtitle' x = ((0,0), NamedAction $ map toUpper
                      $ sep ++ "\n-- " ++ x ++ " --\n" ++ sep)
  where
    sep = replicate (6 + length x) '-'

showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
  h <- spawnPipe $ "yad --text-info --fontname=\"SauceCodePro Nerd Font Mono 12\" --fore=#46d9ff back=#282c36 --center --geometry=1200x800 --title \"XMonad keybindings\""
  --hPutStr h (unlines $ showKm x) -- showKM adds ">>" before subtitles
  hPutStr h (unlines $ showKmSimple x) -- showKmSimple doesn't add ">>" to subtitles
  hClose h
  return ()

myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
  let subKeys str ks = subtitle' str: mkNamedKeymap c ks in
  subKeys "Xmonad Essentials"
  [ ("M-C-r", addName "Recompile XMonad"    $ spawn "xmonad --recompile")
  , ("M-S-r", addName "Restart XMonad"         $ spawn "xmonad --restart")
  , ("M-S-q", addName "Quit Xmonad"        $ io (exitWith ExitSuccess))
  , ("M-r",   addName "Run prompt"         $ spawn "ulauncher-toggle" )
  , ("M-S-c", addName "Kill All of Window" $ kill)
  , ("M-c", addName "Kill One Window" $ kill1)
  , ("M-M1-c", addName "Kill All Other Copies" $ killAllOtherCopies)
  , ("M-w", addName "Window switcher" $ spawn "$HOME/.config/rofi/launchers/launcher_switch.sh")
  , ("M-a", addName "Run autorandr" $ spawn "autorandr --change")
  ]

  ^++^ subKeys "Media Keys"
  [

  ("<XF86AudioLowerVolume>", addName "Lower Volume" $ spawn "amixer set Master 5%- unmute"),
  ("<XF86AudioRaiseVolume>", addName "Raise Volume" $ spawn "amixer set Master 5%+ unmute"),
  ("<XF86AudioMute>", addName "Mute Audio" $ spawn "amixer set Master toggle"),
  ("<XF86MonBrightnessDown>", addName "Reduce Brightness" $ spawn "brightnessctl s 10%-"),
  ("<XF86MonBrightnessUp>", addName "Increase Brightness" $ spawn "brightnessctl s 10%+")
  ]

  ^++^ subKeys "Switch to workspace"

  -- windows $ W.greedyView 
 [ ("M-1", addName "Switch to workspace 1"    $ (windows $ W.greedyView $ myWorkspaces !! 0))
  , ("M-2", addName "Switch to workspace 2"    $ (windows $ W.greedyView  $ myWorkspaces !! 1))
  , ("M-3", addName "Switch to workspace 3"    $ (windows $ W.greedyView  $ myWorkspaces !! 2))
  , ("M-4", addName "Switch to workspace 4"    $ (windows $ W.greedyView  $ myWorkspaces !! 3))
  , ("M-5", addName "Switch to workspace 5"    $ (windows $ W.greedyView  $ myWorkspaces !! 4))
  , ("M-6", addName "Switch to workspace 6"    $ (windows $ W.greedyView  $ myWorkspaces !! 5))]

  ^++^ subKeys "Send window to workspace"
  [ ("M-S-1", addName "Send to workspace 1"    $ (windows $ W.shift $ myWorkspaces !! 0))
  , ("M-S-2", addName "Send to workspace 2"    $ (windows $ W.shift $ myWorkspaces !! 1))
  , ("M-S-3", addName "Send to workspace 3"    $ (windows $ W.shift $ myWorkspaces !! 2))
  , ("M-S-4", addName "Send to workspace 4"    $ (windows $ W.shift $ myWorkspaces !! 3))
  , ("M-S-5", addName "Send to workspace 5"    $ (windows $ W.shift $ myWorkspaces !! 4))
  , ("M-S-6", addName "Send to workspace 6"    $ (windows $ W.shift $ myWorkspaces !! 5))]


  ^++^ subKeys "Tag-based management"
  
  [ ("M-M1-1", addName "Add workspace to tag 1"    $ (windows $ copy $ "code"))
  , ("M-M1-2", addName "Add workspace to tag 2"    $ (windows $ copy $ "code+www"))
  , ("M-M1-3", addName "Add workspace to tag 3"    $ (windows $ copy $ "tiled"))
  , ("M-M1-4", addName "Add workspace to tag 4"    $ (windows $ copy $ "www"))
  , ("M-M1-5", addName "Add workspace to tag 5"    $ (windows $ copy $ "vms"))
  , ("M-M1-6", addName "Add workspace to tag 6"    $ (windows $ copy $ "chat"))
  ]

  -- TODO: Doesn't work
  -- , ("M-A-1", addName "Add workspace to tag 1"    $ withFocused (addTag "code"))


 ^++^ subKeys "Window navigation"
  [ ("M-j", addName "Move focus to next window"                $ windows W.focusDown)
   -- ,("M-C-j", addName "Move focus to next window"                $ withFocused (sendMessage . mergeDir id))
  -- , ("M-k", addName "Move focus to prev window"                $ windows W.focusUp)
  , ("M-k", addName "Move focus to prev window"                $ windows W.focusUp)
  -- , ("M-C-j", addName "Move focus to prev window"                $ withFocused (sendMessage . mergeDir W.focusUp'))
  , ("M-<Backspace>", addName "Move focus to master window"              $ windows W.focusMaster)
  , ("M-S-j", addName "Swap focused window with next window"   $ windows W.swapDown)
  , ("M-S-k", addName "Swap focused window with prev window"   $ windows W.swapUp)
  , ("M-S-<Return>", addName "Swap focused window with master window" $ windows W.swapMaster)
  , ("M-S-<Backspace>", addName "Move focused window to master"  $ promote)
  , ("M-S-,", addName "Rotate all windows except master"       $ rotSlavesDown)
  , ("M-S-.", addName "Rotate all windows current stack"       $ rotAllDown)
  , ("M-<Tab>", addName "Focus Last Window" $ myToggle )
  -- , ("M-S-<Tab>", addName "Focus Last Workspace" $ toggleWS)
  ]


  ^++^ subKeys "Monitors"
  [ ("M-i", addName "Switch focus to next monitor" $ nextScreen)
  , ("M-o", addName "Switch focus to prev monitor" $ prevScreen)
  , ("M-S-i", addName "Move focused window to next screen's workspace" $ shiftNextScreen >> nextScreen)
  , ("M-S-o", addName "Move focused window to previous screen's workspace" $ shiftPrevScreen >> prevScreen)
  , ("M-M1-i", addName "Swap current screen with next screen" $ swapNextScreen >> nextScreen)
  , ("M-M1-o", addName "Swap current screen with previous screen" $ swapNextScreen >> prevScreen)
  ]


  ^++^ subKeys "Floating windows"
  [
   -- ("M-t", addName "Sink a floating window"     $ withFocused $ windows . W.sink)
   ("M-S-f", addName "Toggle window floating"     $ withFocused $ toggleFloat)
   ,("M-S-t", addName "Tile all floating windows"     $ sinkAll )
  ]

  ^++^ subKeys "Tag-based window management"
  [
    ("M-s", addName "Make window sticky" $ windows copyToAll),
    ("M-S-s", addName "Make window sticky" $ killAllOtherCopies)
  ]


 -- Increase/decrease windows in the master pane or the stack
  ^++^ subKeys "Increase/decrease windows in master pane or the stack"
  [ ("M-,", addName "Increase clients in master pane"   $ sendMessage (IncMasterN 1))
  , ("M-.", addName "Decrease clients in master pane" $ sendMessage (IncMasterN (-1)))]
  
  ^++^ subKeys "Favorite programs"

  [ ("M-<Return>", addName "Launch terminal"   $ spawn (myTerminal))
  , ("M-b", addName "Launch web browser"       $ spawn (myBrowser))
  , ("M-g", addName "Enable gamemode"       $ spawn "sleep 2 && ~/.local/bin/mousejail")
  -- , ("M-S-g", addName "Disable gamemode"       $ spawn (myBrowser))
  -- , ("M-b", addName "Launch web browser"       $ spawn (myBrowser))
  ]


  -- Window resizing
  ^++^ subKeys "Window resizing"
  [ ("M-h", addName "Shrink window"               $ sendMessage Shrink)
  , ("M-l", addName "Expand window"               $ sendMessage Expand)
  , ("M-M1-j", addName "Shrink window vertically" $ sendMessage MirrorShrink)
  , ("M-M1-k", addName "Expand window vertically" $ sendMessage MirrorExpand)]


  -- Switch layouts
  ^++^ subKeys "Switch layouts"
  [ ("M-<Space>", addName "Switch to next layout"   $ sendMessage NextLayout)
   , ("M-f", addName "Switch to FullScreen" $ sequence_ [sendMessage $ Toggle NBFULL, sendMessage $ ToggleStruts])
   , ("M-t", addName "Switch to Tiled" $ sendMessage $ JumpToLayout "tall")
   , ("M-m", addName "Switch to Monocle" $ sendMessage $ JumpToLayout "monocle")
   , ("M-S-<Space>", addName "Switch to Float" $ sendMessage $ JumpToLayout "floats")
  ]

  ^++^ subKeys "Scratchpads"
  [ ("M-C-<Return>", addName "Toggle scratchpad terminal" $ namedScratchpadAction myScratchPads "terminal")
    
  ]

  where myToggle = windows $ W.view =<< W.tag . head . filter ((\x -> x /= "NSP" && x /= "SP") . W.tag ) . W.hidden
--    --
--    -- mod-[1..9], Switch to workspace N
--    -- mod-shift-[1..9], Move client to workspace N
--    --
--    [((m .|. modm, k), windows $ f i)
--        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
--        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
--    ++
--
--    --
--    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
--    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
--    --
--    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
--        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
--        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True


-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           -- $ smartBorders
           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []

tallMirror = renamed [Replace "tallMirror"]

           $ windowNavigation
           $ subLayout [] (smartBorders Simplest)
           $ spacing 8
           $ Mirror (ResizableTall 1 (3/100) (3/5) [])

monocle = renamed [Replace "monocle"]
           -- $ smartBorders
           -- $ subLayout [] (smartBorders Simplest)
           --
           $ mySpacing 8
           $ Full

floats = renamed [Replace "floats"]
           -- $ smartBorders
           $ mySpacing 8
           $ simplestFloat


grid     = renamed [Replace "grid"]
           -- $ smartBorders
           -- $ subLayout [] (smartBorders Simplest)
           $ spacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)

tabs =  renamed [Replace "tab"]
       $ mySpacing 8
       $ mastered (1/100) (1/2) $ (focusTracking $ tabbedBottom shrinkText myTabTheme)

tabsSimple = renamed [Replace "tabsSimple"]
            $ mySpacing 8
            $ tabbedBottom shrinkText myTabTheme

tallAccordion = renamed [Replace "tallAccordion"]
  $ spacing 8
  $ (focusTracking Accordion)

threeColMid = renamed [Replace "threeColMid"]
           -- $ smartBorders
           -- $ subLayout [] (smartBorders Simplest)
           $ spacing 8
           $ ThreeColMid 1 (3/100) (1/2)


myTabTheme = def {
  fontName = myFont,
  activeColor = "#cba6f7",
  inactiveColor = "#181825",
  activeBorderColor = "#cba6f7",
  inactiveBorderColor = "#181825",
  inactiveTextColor = "#ffffff",
  activeTextColor = "#181825"
}

wwwLayouts = ( tall ||| monocle ||| tabsSimple ||| floats)
vmsLayouts = (floats ||| tall ||| monocle )
codewwwLayouts = (tabs ||| tall)
chatLayouts = (tabsSimple ||| monocle ||| tall)

myLayout = refocusLastLayoutHook . trackFloating $ avoidStruts $ mouseResize $ windowArrange $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ onWorkspace "www" wwwLayouts $ onWorkspace "vms" vmsLayouts $ onWorkspace "code+www" codewwwLayouts $ onWorkspace "chat" chatLayouts $ myDefaultLayout
  where
    myDefaultLayout = withBorder myBorderWidth tall
                    ||| tallMirror
                    ||| monocle
                    ||| threeColMid
                    ||| tabs
                    ||| floats


-- myLayout = tiled ||| Mirror tiled ||| Full
--   where 
--      -- default tiling algorithm partitions the screen into two panes
--      tiled   = Tall nmaster delta ratio
--
--      -- The default number of windows in the master pane
--      nmaster = 1
--
--      -- Default proportion of screen occupied by master pane
--      ratio   = 1/2
--
--      -- Percent of screen to increment by when resizing panes
--      delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
-- stringProperty "WM_WINDOW_ROLE" =? "presentationWidget" --> doFloat
--

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
  { swn_font              = "xft:Ubuntu:bold:size=60"
  , swn_fade              = 0.5
  , swn_bgcolor           = "#181825"
  , swn_color             = "#ffffff"
  }

willFloat :: Query Bool
willFloat = ask >>= \w -> liftX $ withDisplay $ \d -> do
  sh <- io $ getWMNormalHints d w
  let isFixedSize = isJust (sh_min_size sh) && sh_min_size sh == sh_max_size sh
  isTransient <- isJust <$> io (getTransientForHint d w)
  return (isFixedSize || isTransient)

myManageHook = composeAll
    [
      -- isFullscreen --> (doF W.focusDown <+> doFullFloat)
    isFullscreen --> doFullFloat
    , className =? "confirm"         --> doFloat
    , className =? "file_progress"   --> doFloat
    , className =? "dialog"          --> doFloat
    , className =? "download"        --> doFloat
    , className =? "error"           --> doFloat
    , className =? "notification"    --> doFloat
    , className =? "pinentry-gtk-2"  --> doFloat
    , className =? "splash"          --> doFloat
    , className =? "toolbar"         --> doFloat
    , className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , stringProperty "WM_NAME" =? "Ulauncher Preferences" --> hasBorder False
    , className =? "Ulauncher" --> doFloat
    , className =?  "zoom" --> doFloat
    , className =? "gnome-screenshot" --> doFloat
    , stringProperty "WM_WINDOW_ROLE" =? "pop-up" --> doFloat
    ,  stringProperty "WM_WINDOW_ROLE" =? "AlarmWindow" --> doFloat
    ,  stringProperty "WM_WINDOW_ROLE" =? "ConfigManager" --> doFloat
    , stringProperty "WM_WINDOW_ROLE" =? "PictureInPicture" --> doFloat
    , hasNetWMState "_NET_WM_STATE_ABOVE" --> doFloat
    , hasNetWMState "_NET_WM_STATE_STICKY" --> doF copyToAll
    , stringProperty "WM_WINDOW_ROLE" =? "browser" --> checkWorkspace
    , className =? "discord" --> doShift "chat"
    , className =? "thunderbird-default" --> doShift "chat"
    -- , className =? "firefox" --> doF (W.greedyView "www") <+> doF (W.shift "www")
    -- , className =? "Emacs" --> doShifts "1" ["2"]
    -- , className =? "Emacs" --> doShifts "1" ["6"]
    ]


   -- TODO: Figure out how to fix this so that window always copies to second workspace
    -- , className =? "firefox" --> doF (copy "code+www") <+> doF (W.focusDown) <+> <+> doF (W.greedyView "www") <+> doF (W.shift "www")
  <+> namedScratchpadManageHook myScratchPads
    where
  -- doShifts main wss =
  --   let main' = myWorkspaces !! ((read main) - 1)
  --       wss' = map (\ws -> myWorkspaces !! ((read ws) -1)) wss in
  --       (ask >>= doF . \w -> (\ws -> foldr ($) ws (map (copyWindow w) ["3"]))) :: ManageHook

    -- let main' = myWorkspaces !! ((read main) - 1)
    --     wss' = map (\ws -> myWorkspaces !! ((read ws) -1)) wss in
    --     (ask >>= doF . \w -> (\ws -> foldr ($) ws (map (copyWindow w) wss')) . W.shift main' ) :: ManageHook
  -- viewShift = doF . liftM2 (.) W.greedyView W.shift

-- TODO: copyWindow doesn't do anything. Figure out why
  checkWorkspace = do
    fromws <- liftX $ return . W.currentTag . windowset =<< get
    wid    <- ask
    if fromws == "code+www"
      then doShift "code+www" <+> doF (copyWindow wid "www")
    else
      doF (W.greedyView "www") <+> doF (W.shift "www") <+> doF (copyWindow wid "code+www")

  -- W.currentTag $ \c -> case c of 
  --   "code+www" -> doShift "code+www"
  --   otherwise  -> doShift "www"

  getNetWMState :: Window -> X [Atom]
  getNetWMState w = do
    atom <- getAtom "_NET_WM_STATE"
    map fromIntegral . fromMaybe [] <$> getProp32 atom w

  hasNetWMState :: String -> Query Bool
  hasNetWMState state = do
    window  <- ask
    wmstate <- liftX $ getNetWMState window
    atom    <- liftX $ getAtom state
    return $ elem atom wmstate


    -- wss' = map (\ws -> myWorkspaces !! ((read ws) - 1)) wss in 
    -- (ask >>= doF . \w -> (\ws -> foldr ($) ws (map (copyWindow w) wss')) 
    --                       . W.shift main') :: ManageHook
  -- doShift' main = doShift $ myWorkspaces !! ((read main) - 1)
  -- doHideSink = ask >>= \w -> liftX (hide w) >> doF (W.sink w)
  -- doHideSinkShift w = doHideSink <+> doShift w :: ManageHook
  -- doHideSinkShift' w = doHideSinkShift $ myWorkspaces !! ((read w) - 1)
-- myManageHook = composeAll
--     [ className =? "Emacs" --> (ask >>= doF .  \w -> (\ws -> foldr ($) ws (copyToWss ["2","4"] w) ) . W.shift "3" ) :: ManageHook
--     , resource  =? "kdesktop" --> doIgnore
--     ]
--   where copyToWss ids win = map (copyWindow win) ids -- TODO: find method that only calls windows once



-- . doF . W.swapUp 
-- myManageHook = composeAll
--   [
--     insertPosition End Newer
--     , myManageHook'
--
--   ]


------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = refocusLastWhen (refocusingIsActive <||> isFloat)

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
-- myLogHook = dynamicLog

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook =  do
  spawn "rm /tmp/.xmonad-workspace-log"
  spawn "sleep 0.3 && mkfifo /tmp/.xmonad-workspace-log"
  spawn "rm /tmp/.xmonad-layout-log"
  spawn "sleep 0.3 && mkfifo /tmp/.xmonad-layout-log"
  spawnOnce  "picom --experimental-backend --config ~/.config/picom/picom.conf"
  spawnOnce  "dunst"
  spawnOnce  "/usr/libexec/polkit-gnome-authentication-agent-1"
  spawnOnce  "GDK_BACKEND=x11 WEBKIT_DISABLE_COMPOSITING_MODE=1 /usr/bin/ulauncher --hide-window --no-window-shadow"
  spawnOnce "~/.fehbg && ~/.config/polybar/launch.sh"
  spawnOnce "nm-applet"
  spawnOnce "blueman-applet"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = xmonad $ addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) myKeys $ ewmhFullscreen . ewmh $ docks $ defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.

myLogHook = do
  winset <- gets windowset
  let currWs = W.currentTag winset
  let ld = description . W.layout . W.workspace . W.current $ winset
  io $ appendFile "/tmp/.xmonad-layout-log" (ld ++ "\n")
  io $ appendFile "/tmp/.xmonad-workspace-log" (currWs ++ "\n")

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        -- mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = showWName' myShowWNameTheme $ myLayout,
        manageHook         = insertPosition End Newer <> myManageHook,
        handleEventHook    = myEventHook,
        logHook =  dynamicLog <> myLogHook >> historyHook,
        startupHook        = myStartupHook
    }

-- let ld = description . S.layout . S.workspace . S.current $ winset

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
