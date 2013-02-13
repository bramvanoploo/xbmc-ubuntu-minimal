__author__ = "Bram van Oploo (bram@sudo-systems.com)"
__version__ = "$Revision: 3.0.0 $"
__date__ = "$Date: 2013/02/12 21:57:19 $"
__copyright__ = "Copyright (c) 2013 Bram van Oploo"
__license__ = "Creative Commons"

import apt
import subprocess
import sys
import os
import urwid
import VideoDrivers
import Repositories
import Database
import System
import XbmcAddons

def exit_on_q(key):
    if key in ('q', 'Q'):
        raise urwid.ExitMainLoop()

palette = [
    ('banner', '', '', '', '#ffa', '#888'),
    ('streak', '', '', '', 'g50', '#555'),
    ('inside', '', '', '', 'g38', '#666'),
    ('outside', '', '', '', 'g27', '#444'),
    ('bg', '', '', '', 'g7', '#777'),]

placeholder = urwid.SolidFill()
loop = urwid.MainLoop(placeholder, palette, unhandled_input=exit_on_q)
loop.screen.set_terminal_properties(colors=256)
loop.widget = urwid.AttrMap(placeholder, 'bg')
loop.widget.original_widget = urwid.Filler(urwid.Pile([]))

div = urwid.Divider()
outside = urwid.AttrMap(div, 'outside')
inside = urwid.AttrMap(div, 'inside')
txt = urwid.Text(('banner', u" Ubuntu 13.04 minimal XBMC installation "), align='center')
streak = urwid.AttrMap(txt, 'streak')
pile = loop.widget.base_widget # .base_widget skips the decorations
for item in [outside, inside, streak, inside, outside]:
    pile.contents.append((item, pile.options()))

loop.run()
