

# plugins/prestation_manager/app/controllers/prestataires_controller.rb
class PrestatairesController < ApplicationController
  unloadable

  # Avant actions
  before_action :find_prestataire, only: [:edit_inline, :update_inline, :cancel_inline]
  before_action :find_project #, only: [:edit_inline, :update_inline, :cancel_inline]
  before_action :authorize , only: [:edit_inline, :update_inline]
  # GET /prestataires?id=project_identifier
  def index
    # Récupération du projet via l'identifiant passé en param
    raise ActiveRecord::RecordNotFound, "Projet introuvable" unless @project

    # Liste de tous les prestataires (optionnel : filtrer par projet si nécessaire)
    @prestataires = Prestataire.order(:id)
  
  end

  # Actions AJAX
  def edit_inline
    respond_to do |format|
      format.js   # rend app/views/prestataires/edit_inline.js.erb
    end
  end

  def cancel_inline

    respond_to do |format|
      format.js { render 'cancel_inline' }
    end
  end

  def update_inline
    if @prestataire.update(prestataire_params)
      respond_to do |format|
        format.js   # rend app/views/prestataires/update_inline.js.erb
      end
    else
      respond_to do |format|
        format.js { render 'edit_inline' }  # ré-affiche le formulaire avec erreurs
      end
    end
  end

  private

  # Récupère le prestataire depuis params[:id]
  def find_prestataire
    @prestataire = Prestataire.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_403
  end

  # Récupère le projet associé au prestataire
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    #@project = @prestataire.project
  end

  # Strong params
  def prestataire_params
    params.require(:prestataire).permit(:nom, :identifiant, :nif, :etat, :wilaya, :contact)
  end
end

