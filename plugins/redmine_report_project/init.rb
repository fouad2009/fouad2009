Redmine::Plugin.register :redmine_report_project do
  name 'Redmine Report Project plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

plugin_root = File.expand_path(__dir__)

def load_yaml_config(path)
  YAML.safe_load(
    File.read(path),
    permitted_classes: [Symbol],
    aliases: true
  ).with_indifferent_access.freeze
end

CUSTOM_FIELDS_CONFIG =
  load_yaml_config(File.join(plugin_root, 'config', 'custom_fields.yml'))

RULES_NBR_CONFIG =
  load_yaml_config(File.join(plugin_root, 'config', 'rules_nbr.yml'))

RULES_QTN_CONFIG =
  load_yaml_config(File.join(plugin_root, 'config', 'rules_qtn.yml'))