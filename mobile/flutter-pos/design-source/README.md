# Design source files

Editable SVG sources for the app's branding, kept separate from `assets/`
(which only needs the final rasterized PNGs Flutter actually loads).

- `app_icon.svg` — square launcher icon artwork (legacy `mipmap-*/ic_launcher.png`).
- `app_icon_foreground.svg` — same maki roll, transparent background, sized to
  survive Android's adaptive icon safe-zone/masking. Paired with the solid
  `ic_launcher_background` color (`android/app/src/main/res/values/ic_launcher_background.xml`,
  matches `AppColors.salmonDark`).
- `app_background.svg` — the full-app background (canvas gradient + color
  blobs + subtle sushi line-art) rendered once to
  `assets/images/app_background.png` and used by `GlassBackground`
  (`lib/shared/widgets/glass_panel.dart`) on every screen.

To regenerate PNGs after editing, e.g. with `cairosvg` or Inkscape:

```bash
# App icon (legacy, 1024px master)
cairosvg app_icon.svg -o app_icon_1024.png -W 1024 -H 1024
# then resize to 48/72/96/144/192px into android/app/src/main/res/mipmap-*/ic_launcher.png

# Adaptive icon foreground (108dp @ each density: 108/162/216/324/432px)
cairosvg app_icon_foreground.svg -o fg.png -W 1024 -H 1024
# then resize into android/app/src/main/res/mipmap-*/ic_launcher_foreground.png

# App background
cairosvg app_background.svg -o ../assets/images/app_background.png -W 2560 -H 1600
```

Colors used match `lib/app/constants/colors.dart` (`AppColors.salmon`,
`salmonDark`, `ink`, canvas gradient stops) so any edits should pull from
that file rather than eyeballing new hex values.
