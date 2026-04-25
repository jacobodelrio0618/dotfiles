-- Imports
import XMonad
import Data.Monoid
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run (safeSpawn)
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.SpawnOnce 
import XMonad.Actions.Warp

import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders

import qualified XMonad.StackSet as W
import qualified Data.Map       as M

------------------------------------------------------------------------
-- Basic config
myTerminal      = "alacritty"
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False
myClickJustFocuses :: Bool
myClickJustFocuses = True
myBorderWidth   = 1
myModMask       = mod4Mask
myWorkspaces    = ["N","L","A","B","C","6","7","8","9"]
myNormalBorderColor  = "#2a2a2a"
myFocusedBorderColor = "#a9a9a9"

------------------------------------------------------------------------
-- Key bindings
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn (XMonad.terminal conf))
    -- , ((modm, xK_p), spawn "dmenu_run")
    , ((modm, xK_p), spawn "rofi -show drun")
    , ((modm .|. shiftMask, xK_p), spawn "gmrun")
    , ((modm .|. shiftMask, xK_c), kill)
    , ((modm, xK_space), sendMessage NextLayout)
    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    , ((modm, xK_n), refresh)
    , ((modm, xK_Tab), windows W.focusDown)
    , ((modm, xK_j), windows W.focusDown)
    , ((modm, xK_k), windows W.focusUp)
    , ((modm, xK_m), windows W.focusMaster)
    , ((modm, xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_j), windows W.swapDown)
    , ((modm .|. shiftMask, xK_k), windows W.swapUp)
    , ((modm, xK_h), sendMessage Shrink)
    , ((modm, xK_l), sendMessage Expand)
    , ((modm, xK_t), withFocused $ windows . W.sink)
    , ((modm, xK_comma), sendMessage (IncMasterN 1))
    , ((modm, xK_period), sendMessage (IncMasterN (-1)))
    , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))
    , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
    , ((modm .|. shiftMask, xK_slash), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    -- Volume controls
    , ((modm, xK_F1), spawn "amixer set Master toggle")
    , ((modm, xK_F2), spawn "amixer set Master 5%-")
    , ((modm, xK_F3), spawn "amixer set Master 5%+")
    -- Brightness controls
    , ((modm, xK_F5), safeSpawn "sh" ["-c", "sudo brightnessctl --device=amdgpu_bl1 set 10%-"])
    , ((modm, xK_F6), safeSpawn "sh" ["-c", "sudo brightnessctl --device=amdgpu_bl1 set 10%+"])
    -- Keyboard layouts
    , ((mod1Mask, xK_1), spawn "setxkbmap custom-it")
    , ((mod1Mask, xK_2), spawn "setxkbmap custom-it1")
    , ((mod1Mask, xK_3), spawn "setxkbmap it")
    , ((mod1Mask, xK_4), spawn "setxkbmap gb")
    -- GNOME Control Center
    , ((modm, xK_s), spawn "setsid env XDG_CURRENT_DESKTOP=GNOME GDK_BACKEND=x11 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus gnome-control-center")
    ]
    ++
    -- Workspace switching and Screen switching use Xmonad functions, no need for spawn/sigusr1
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
------------------------------------------------------------------------
-- Mouse bindings
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    ]

------------------------------------------------------------------------
-- Layouts with spacing (Picom handles rounded corners)
-- myLayout = avoidStruts $ smartBorders $ smartSpacing 6 (tiled ||| Mirror tiled ||| Full)
--   where
--     tiled   = Tall nmaster delta ratio
--     nmaster = 1
--     ratio   = 1/2
--     delta   = 3/100


myLayout = avoidStruts $ smartBorders $ spacingRaw True           -- smart border (outer) spacing
                                  (Border 4 4 6 4) -- screen border gaps: left top right bottom
                                  True             -- enable screen edge gaps
                                  (Border 4 4 6 4) -- window gaps: left top right bottom
                                  True             -- enable window gaps
                                  (tiled ||| Full)
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100
------------------------------------------------------------------------
-- Window rules
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    ]

------------------------------------------------------------------------
-- Event handling
myEventHook = mempty

------------------------------------------------------------------------
-- Startup hook
myStartupHook = do
    spawn "hsetroot -solid \"#000000\" &"
    spawn "export GTK_THEME=Adwaita:dark"
    -- spawn "killall polybar; sleep 1; polybar -r mainbar &"
    spawn "picom --config ~/.config/picom/picom.conf &"  -- Picom for rounded corners, shadows
    
    spawn "unclutter -idle 5 &"

-- SMART MONITOR & BAR STARTUP
    -- This checks if your MSI is connected. 
    -- If yes: sets up dual screens. If no: resets to laptop only.
    spawn ("xrandr | grep -q 'HDMI-A-0 connected' && " ++
           "xrandr --output HDMI-A-0 --mode 1920x1080 --rate 180 --right-of eDP --auto || " ++
           "xrandr --output HDMI-A-0 --off --output eDP --auto")
           
    -- Run your Polybar launch script (the one with the for-loop)
    spawn "~/.config/polybar/launch.sh"
------------------------------------------------------------------------
-- Main
main :: IO ()
main = xmonad $ docks $ ewmh defaults

------------------------------------------------------------------------
-- Defaults
defaults = def
    { terminal           = myTerminal
    , focusFollowsMouse  = myFocusFollowsMouse
    , clickJustFocuses   = myClickJustFocuses
    , borderWidth        = myBorderWidth
    , modMask            = myModMask
    , workspaces         = myWorkspaces
    , normalBorderColor  = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , keys               = myKeys
    , mouseBindings      = myMouseBindings
    , layoutHook         = myLayout
    , manageHook         = myManageHook
    , handleEventHook    = myEventHook
    , startupHook        = myStartupHook
    }

------------------------------------------------------------------------
-- Help string
help :: String
help = unlines
    [ "mod-Shift-Enter  Launch terminal"
    , "mod-p            Launch dmenu"
    , "mod-Shift-p      Launch gmrun"
    , "mod-Shift-c      Close focused window"
    , "mod-Space        Rotate layouts"
    , "mod-Shift-Space  Reset layout"
    , "mod-n            Refresh windows"
    , "mod-Tab / mod-j / mod-k Move focus"
    , "mod-m            Focus master"
    , "mod-Return       Swap master"
    , "mod-Shift-j/k    Swap windows"
    , "mod-h / mod-l     Resize master area"
    , "mod-t            Sink window"
    , "mod-comma / mod-period Increase/decrease master windows"
    , "mod-Shift-q      Quit Xmonad"
    , "mod-q            Restart Xmonad"
    , "mod-[1..9]       Switch workspace"
    , "mod-Shift-[1..9] Move window to workspace"
    , "mod-{w,e,r}      Switch screen"
    , "mod-Shift-{w,e,r} Move window to screen"
    ]
