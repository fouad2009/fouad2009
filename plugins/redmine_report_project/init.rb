Redmine::Plugin.register :redmine_report_project do
  name 'Redmine Report Project plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

plugin_root = File.expand_path(__dir__)
config_file = File.join(plugin_root, 'config', 'custom_fields.yml')

CUSTOM_FIELDS_CONFIG = YAML.load_file(config_file).with_indifferent_access.freeze

 Dir[File.join(__dir__, 'lib', 'report_project', '*.rb')].each { |file| require file }

end
