ccw = c.colors.webpage
ccw.bg = "black"
ccw.darkmode.enabled = True
ccw.darkmode.threshold.background = 100
ccw.darkmode.threshold.text = 256 - ccw.darkmode.threshold.background
ccw.darkmode.policy.images = 'smart'
ccw.prefers_color_scheme_dark = True

QT_AUTO_SCREEN_SCALE_FACTOR = 1

c.zoom.default = 175
c.fonts.default_size = '14pt'

config.bind('zl', 'spawn --userscript qute-bitwarden')
