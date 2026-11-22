"""Rounded ranger panels and Nerd Font file icons."""

import curses

from ranger.api import LinemodeBase, register_linemode
from ranger.gui.bar import ColoredString
from ranger.gui.widgets.titlebar import TitleBar
from ranger.gui.widgets.view_miller import ViewMiller


ICONS = {
    ".py": "", ".js": "", ".ts": "", ".tsx": "",
    ".jsx": "", ".go": "", ".rs": "", ".sh": "",
    ".lua": "", ".html": "", ".css": "",
    ".md": "", ".txt": "󰈙", ".pdf": "", ".docx": "󰈬",
    ".png": "", ".jpg": "", ".jpeg": "", ".svg": "󰜡",
    ".gif": "", ".webp": "",
    ".mp3": "", ".flac": "", ".wav": "",
    ".mp4": "", ".mkv": "", ".webm": "",
    ".zip": "", ".tar": "", ".gz": "", ".7z": "",
    ".json": "", ".toml": "", ".yaml": "", ".yml": "",
}


@register_linemode
class PurpleIcons(LinemodeBase):
    name = "purple_icons"

    def filetitle(self, fobj, metadata):
        filename = fobj.relative_path
        if fobj.is_link:
            icon = ""
        elif fobj.is_directory:
            icon = ""
        elif fobj.stat and fobj.stat.st_mode & 0o111:
            icon = ""
        else:
            suffix = "." + filename.rsplit(".", 1)[-1].lower() if "." in filename else ""
            icon = ICONS.get(suffix, "")
        return "{}  {}".format(icon, filename)


_original_resize = ViewMiller.resize
_original_borders = ViewMiller._draw_borders


def _spaced_resize(self, y, x, hei=None, wid=None):
    _original_resize(self, y, x, hei, wid)
    if self.settings.draw_borders.lower() not in ("outline", "both", "true"):
        return
    for column in self.columns:
        if column.wid >= 5:
            column.resize(column.y, column.x + 1, column.hei, column.wid - 2)


def _rounded_borders(self, border_types):
    if "outline" not in border_types or self.pager.visible:
        return _original_borders(self, border_types)

    self.color("in_browser", "border")
    for column in self.columns:
        if not column.visible or column.wid < 3:
            continue
        left = column.x - 1
        right = column.x + column.wid
        if left < 0 or right >= self.wid or right - left < 4:
            continue
        width = right - left - 1
        try:
            self.win.addstr(0, left, "╭" + "─" * width + "╮")
            for row in range(1, self.hei - 1):
                self.win.addstr(row, left, "│")
                self.win.addstr(row, right, "│")
            self.win.addstr(self.hei - 1, left, "╰" + "─" * width + "╯")
        except curses.error:
            # Curses can reject the bottom-right cell during a resize.
            pass


ViewMiller.resize = _spaced_resize
ViewMiller._draw_borders = _rounded_borders


_original_title_left = TitleBar._get_left_part


def _title_segment(text, tag):
    segment = ColoredString(text, "in_titlebar", tag)
    segment.fixed = True
    return segment


def _purple_title_left(self, bar):
    _original_title_left(self, bar)
    bar.left.insert(0, _title_segment("", "pill_edge"))
    path_position = 1
    if self.settings.hostname_in_titlebar:
        bar.left.insert(1, _title_segment("  ", "pill_body"))
        path_position = 6
    bar.left.insert(path_position, _title_segment("  ", "pill_body"))
    bar.left.append(_title_segment(" ", "pill_body"))
    bar.left.append(_title_segment("", "pill_edge"))


TitleBar._get_left_part = _purple_title_left
