#!/usr/bin/env bash
# Apply the "Kitty Liquid Glass" blur pipeline to GNOME's Blur my Shell extension.
set -euo pipefail

SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas"

if [[ ! -d "$SCHEMA_DIR" ]]; then
  echo "Blur my Shell schema directory not found: $SCHEMA_DIR" >&2
  echo "Install and enable blur-my-shell@aunetx in GNOME first." >&2
  exit 1
fi

python3 - "$SCHEMA_DIR" <<'EOF'
import sys
import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

schema_dir = sys.argv[1]
source = Gio.SettingsSchemaSource.new_from_directory(
    schema_dir, Gio.SettingsSchemaSource.get_default(), False
)
root_schema = source.lookup("org.gnome.shell.extensions.blur-my-shell", True)
app_schema = source.lookup("org.gnome.shell.extensions.blur-my-shell.applications", True)

if root_schema is None or app_schema is None:
    raise SystemExit("Could not load Blur my Shell GSettings schemas.")

root = Gio.Settings.new_full(root_schema, None, None)
app = Gio.Settings.new_full(app_schema, None, None)

pipelines = root.get_value("pipelines").unpack()
pipelines["pipeline_kitty_blur"] = {
    "name": "Kitty Smooth Blur",
    "effects": [
        {
            "type": "dual_kawase_blur",
            "id": "effect_kitty_smooth_blur",
            "params": {
                "unscaled_radius": 180,
                "brightness": 0.45,
            },
        },
    ],
}


def to_variant(val):
    if isinstance(val, str):
        return GLib.Variant("s", val)
    if isinstance(val, bool):
        return GLib.Variant("b", val)
    if isinstance(val, int):
        return GLib.Variant("i", val)
    if isinstance(val, float):
        return GLib.Variant("d", val)
    if isinstance(val, tuple):
        return GLib.Variant("(dddd)", val)
    if isinstance(val, list):
        return GLib.Variant("av", [to_variant(item) for item in val])
    if isinstance(val, dict):
        return GLib.Variant("a{sv}", {k: to_variant(v) for k, v in val.items()})
    raise TypeError(f"Unsupported GVariant type: {type(val)}")


root_dict = {
    name: {k: to_variant(v) for k, v in data.items()}
    for name, data in pipelines.items()
}

root.set_value("pipelines", GLib.Variant("a{sa{sv}}", root_dict))
root.set_boolean("power-saver", False)

app.set_boolean("blur", True)
app.set_boolean("dynamic-opacity", False)
app.set_boolean("static-blur", False)
app.set_int("opacity", 255)
app.set_strv("whitelist", ["*kitty*"])
app.set_string("pipeline", "pipeline_kitty_blur")
app.set_string("pipeline-dark", "pipeline_kitty_blur")

Gio.Settings.sync()
EOF

if command -v gnome-extensions >/dev/null 2>&1; then
  gnome-extensions disable blur-my-shell@aunetx >/dev/null 2>&1 || true
  gnome-extensions enable blur-my-shell@aunetx >/dev/null 2>&1 || true
fi

echo "Applied Kitty Liquid Glass pipeline to blur-my-shell@aunetx."
