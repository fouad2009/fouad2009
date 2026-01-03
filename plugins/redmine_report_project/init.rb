# -*- encoding: utf-8 -*-

Redmine::Plugin.register :redmine_report_project do
  name 'Redmine Report Project plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

plugin_root = File.expand_path(__dir__)

# --------------------------
# Méthode pour charger YAML
# --------------------------
def load_yaml_config(path)
  yaml = YAML.safe_load(
    File.read(path),
    permitted_classes: [Symbol],
    aliases: true
  )

  # Convertir toutes les clés récursivement en symboles
  deep_symbolize_keys(yaml).freeze
end

# --------------------------
# Méthode récursive de conversion
# --------------------------
def deep_symbolize_keys(obj)
  case obj
  when Hash
    obj.each_with_object({}) do |(k, v), h|
      key = k.is_a?(String) ? k.to_sym : k
      h[key] = deep_symbolize_keys(v)
    end
  when Array
    obj.map { |v| deep_symbolize_keys(v) }
  when String
    obj.to_sym
  else
    obj
  end
end

# --------------------------
# Chargement des configurations
# --------------------------
CUSTOM_FIELDS_CONFIG = load_yaml_config(File.join(plugin_root, 'config', 'custom_fields.yml'))
RULES_NBR_CONFIG    = load_yaml_config(File.join(plugin_root, 'config', 'rules_nbr.yml'))
RULES_QTN_CONFIG    = load_yaml_config(File.join(plugin_root, 'config', 'rules_qtn.yml'))
