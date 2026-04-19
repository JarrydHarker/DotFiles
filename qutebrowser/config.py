import os

# 1. Load the base config
config.load_autoconfig()

# 2. Appearance & Behavior
c.tabs.position = 'right'
c.tabs.show = 'always'
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = 'never'

# 3. Search Engines
c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
}

# 4. Theme Loading 
config_dir = os.path.expanduser('~/.config/qutebrowser')
theme_path = os.path.join(config_dir, 'themes', 'tokyonight.py')

if os.path.exists(theme_path):
    config.source(theme_path)
