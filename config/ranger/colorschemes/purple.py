"""Purple accents for ranger's browser, title, and status areas."""

import curses

from ranger.colorschemes.default import Default
from ranger.gui.color import bold, default, magenta, normal, white


class Purple(Default):
    def use(self, context):
        fg, bg, attr = super().use(context)
        rich = getattr(curses, "COLORS", 0) >= 256
        violet = 183 if rich else magenta
        border = 141 if rich else magenta
        selection = 60 if rich else magenta

        if context.in_browser:
            if context.border:
                return border, default, normal
            if context.selected:
                return white, selection, bold if context.main_column else normal
            if context.directory:
                return violet, bg, attr | bold
        elif context.in_titlebar:
            if getattr(context, "pill_edge", False):
                return selection, default, normal
            if (getattr(context, "pill_body", False) or context.hostname or context.directory
                    or context.link or context.file):
                return white, selection, attr
            return violet, default, attr
        elif context.in_statusbar and not context.message:
            return border, bg, attr

        return fg, bg, attr


Scheme = Purple
