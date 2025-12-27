Redmine::Plugin.register :redmine_report_project do
  name 'Redmine Report Project plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'


 Dir[File.join(__dir__, 'lib', 'report_project', '*.rb')].each { |file| require file }

end
