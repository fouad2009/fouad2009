# plugins/restrict_cf/app/controllers/issues_controller_patch.rb
module IssuesControllerPatch
  def self.included(base)
    base.class_eval do
      before_action :restrict_custom_fields, only: [:create, :update]
    end
  end

  private

  def restrict_custom_fields
    return unless params[:issue] && params[:issue][:custom_field_values]

    # Détecter automatiquement les champs admin-only
   # admin_only_cf_ids = CustomField.where(is_for_all: true).select { |cf| cf.editable_by_admin_only? }.map(&:id)
    # Si tu préfères mettre des IDs fixes, tu peux remplacer la ligne précédente par :
     admin_only_cf_ids = [6,21,68]
    cf_values = params[:issue][:custom_field_values]
    cf_values.each_key do |cf_id|
      if admin_only_cf_ids.include?(cf_id.to_i) && !User.current.admin?
        Rails.logger.warn "Utilisateur #{User.current.login} a tenté de modifier le champ cf#{cf_id} interdit."
        #params[:issue][:custom_field_values].delete(cf_id)
        cf_values["6"] = ""
      end
    end
  end
end

# Inclure le patch
Rails.configuration.to_prepare do
  IssuesController.include IssuesControllerPatch
end

