from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import black, blue, cyan, green, magenta, red, white, yellow, normal, bold, default, underline


class Scheme(ColorScheme):
    progress_bar_color = blue

    def use(self, context):
        foreground, background, attribute = white, default, normal
        if context.reset:
            return foreground, background, attribute
        if context.in_browser:
            if context.directory:
                foreground, attribute = blue, bold
            elif context.executable:
                foreground = green
            elif context.media:
                foreground = magenta
            elif context.container:
                foreground = yellow
            if context.link:
                foreground = cyan if context.good else red
            if context.border:
                foreground = cyan
            if context.marked:
                foreground, attribute = yellow, bold
            if context.cut or context.copied:
                foreground = cyan
            if context.selected:
                foreground, background, attribute = blue + 8, default, bold | underline
            if context.empty or context.error or context.badinfo:
                foreground = red
        elif context.in_titlebar:
            foreground = blue if context.directory else white
            if context.hostname:
                foreground = cyan
            attribute = bold
        elif context.in_statusbar:
            foreground = cyan
            if context.bad:
                foreground = red
            elif context.marked:
                foreground, attribute = yellow, bold
        elif context.in_taskview:
            foreground = blue
            if context.selected:
                foreground, background, attribute = blue + 8, default, bold | underline
        return foreground, background, attribute
