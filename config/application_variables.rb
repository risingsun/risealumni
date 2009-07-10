SESSION_KEY = '_risealumni_app'
SECRET = 'aae51a4bbd94b8e836b460230fb285a5e286b00e85584f539a1d3f29017ad81da6918642283e95563e27d7996971a1a25fc491e1c29ac85e91eff05081d70559'

ASSET_HOST = RAILS_ENV == 'production' ? "http://localhost:3000" : "http://localhost:3000"

#DATABASE_CONFIGURATION_FILE = "maass_database.yml"

THEME = "risealumni"

#THEME_DIR = File.join(RAILS_ROOT, 'themes', THEME)
THEME_DIR = File.join(RAILS_ROOT, 'public', THEME)

THEME_WEB_ROOT = "/#{THEME}"
THEME_IMG = "#{THEME_WEB_ROOT}/images"
THEME_STYLE = "#{THEME_WEB_ROOT}/stylesheets"
THEME_JAVASCRIPT = "#{THEME_WEB_ROOT}/javascripts"
