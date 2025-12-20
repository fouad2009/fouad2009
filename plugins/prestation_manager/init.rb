# plugins/prestation_manager/init.rb
#require_relative 'lib/prestation_manager'
# plugins/mon_plugin/init.rb
require 'logger'  # optionnel, juste pour être sûr

Redmine::Plugin.register :prestation_manager do
  name 'Prestation Manager'
  author 'hakimi'
  description 'Gère la liste des prestataires avec édition inline'
  version '0.0.1'
  url ''
  author_url ''
  requires_redmine version_or_higher: '5.1.0'




# 🔐 Déclaration du module projet + permission
  project_module :prestation_manager do
    permission :view_prestataires, { prestataires: :index }
    permission :edit_prestataires, { prestataires: [:edit_inline, :update_inline] }
  end


  # Ajoute un lien dans le top menu
  menu :project_menu,
     :prestataires,
     { controller: 'prestataires', action: 'index' },
     caption: 'Prestataires',
     permission: :view_prestataires,
     param: :project_id
     

end

