# ==============================================================================
# Ranger Colorscheme: Neon Blue
# Disenado para complementar el tema Azul Neon de Kitty / scripts-basicos-linux
# ==============================================================================

from __future__ import absolute_import, division, print_function

from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import (
    black, blue, cyan, green, magenta, red, white, yellow, default,
    normal, bold, reverse, dim, underline, BRIGHT, default_colors
)


class Scheme(ColorScheme):
    progress_bar_color = cyan

    def use(self, context):
        fg, bg, attr = default_colors

        if context.reset:
            return default_colors

        elif context.in_browser:
            if context.selected:
                attr = reverse | bold
            else:
                attr = normal

            if context.empty or context.error:
                fg = red
                attr |= bold

            if context.border:
                fg = blue

            if context.media:
                if context.image:
                    fg = yellow
                elif context.audio:
                    fg = magenta
                elif context.video:
                    fg = magenta + BRIGHT
                else:
                    fg = magenta

            if context.container:
                fg = red + BRIGHT

            if context.directory:
                attr |= bold
                fg = cyan + BRIGHT
            elif context.executable and not any((
                context.media, context.container, context.fifo, context.socket
            )):
                attr |= bold
                fg = green + BRIGHT

            if context.socket:
                attr |= bold
                fg = magenta

            if context.fifo or context.device:
                fg = yellow
                if context.device:
                    attr |= bold

            if context.link:
                fg = cyan if context.good else red
                attr |= bold

            if context.tag_marker and not context.selected:
                attr |= bold
                if fg in (red, magenta):
                    fg = white
                else:
                    fg = red

            if not context.selected and (context.cut or context.copied):
                attr |= dim
                fg = 8  # Gray

            if context.main_column:
                if context.selected:
                    attr |= bold

            # Soporte Git / VCS
            if context.vcsconflict:
                fg = red
                attr |= bold
            elif context.vcschanged:
                fg = yellow
                attr |= bold
            elif context.vcsuntracked:
                fg = cyan
            elif context.vcsstaged:
                fg = green
                attr |= bold
            elif context.vcssync:
                fg = green
            elif context.vcsignored:
                fg = 8
                attr |= dim

        elif context.in_titlebar:
            attr |= bold
            if context.hostname:
                fg = cyan
            elif context.directory:
                fg = cyan + BRIGHT
            elif context.tab:
                if context.good:
                    bg = blue
                    fg = white
                else:
                    fg = 8
            elif context.link:
                fg = cyan

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = cyan
                elif context.bad:
                    fg = red
            if context.marked:
                attr |= bold | reverse
                fg = yellow
            if context.frozen:
                attr |= bold | reverse
                fg = cyan
            if context.message:
                if context.bad:
                    attr |= bold
                    fg = red
            if context.loaded:
                bg = self.progress_bar_color
            if context.vcsinfo:
                fg = cyan
                attr |= normal
            if context.vcscommit:
                fg = yellow
                attr |= normal
            if context.vcsdate:
                fg = cyan
                attr |= normal

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = cyan
                attr |= bold
            if context.selected:
                attr |= reverse

        return fg, bg, attr
