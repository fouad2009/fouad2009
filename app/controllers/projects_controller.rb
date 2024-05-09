# frozen_string_literal: true

# Redmine - project management software
# Copyright (C) 2006-2023  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class ProjectsController < ApplicationController
  menu_item :overview
  menu_item :settings, :only => :settings
  menu_item :projects, :only => [:index, :new, :copy, :create]

  before_action :find_project,
                :except => [:index, :autocomplete, :list, :new, :create, :copy, :bulk_destroy]
  before_action :authorize,
                :except => [:index, :autocomplete, :list, :new, :create, :copy,
                            :archive, :unarchive,
                            :destroy, :bulk_destroy, :dot_json]
  before_action :authorize_global, :only => [:new, :create]
  before_action :require_admin, :only => [:copy, :archive, :unarchive, :bulk_destroy]
  accept_atom_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy, :archive, :unarchive, :close, :reopen
  require_sudo_mode :destroy, :bulk_destroy

  helper :custom_fields
  helper :issues
  helper :queries
  include QueriesHelper
  helper :projects_queries
  include ProjectsQueriesHelper
  helper :repositories
  helper :members
  helper :trackers

   # fonctiion API DOT
  def dot_json
    
   
    tracker_name = { 4 => "Canalisation", 6 => "Pose-FO" , 47 => "ODN_Dev",58 => "ODN_Mod"}
     project = Project.find(@project.id)
 
     @dot_json_data = report_do(project,:par_dots)
    
 
    csv_data = CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # Ajoutez les en-têtes de colonnes ici
      # Ajoutez le BOM pour UTF-8
      csv << ["\xEF\xBB\xBF"]

      csv << ['DOT','dot_id', 'Type_action','Nbr sites','Cap prevue',
      'Nbr Etudes non entamées','Cap Etudes non entamées',
      'Nbr Etudes en cours','Cap Etudes en cours',
      'Nbr Etudes finalisées','Cap Etudes finalisées',
      'Nbr en consultation','Cap en consultation',
      'Nbr engagés','Cap engagée',
      'Nbr En cours PA','Cap En cours PA',
      'Nbr En cours RAR','Cap En cours RAR',
      'Nbr Réalisé PA','Cap Réalisé PA',
      'Nbr Réalisé RAR','Cap Réalisé RAR',
      'Nbr actions à arrêt', 'Cap actions à arrêt'] # Ajoutez d'autres en-têtes de colonnes si nécessaire
  
       @dot_json_data.each do |key, value|
        # Ajoutez les valeurs de colonnes ici
        value.each do |k, v|
          if [4,6].include?(v[:tracker_id].to_i)
            csv << [dot_name(v[:project_id]),v[:project_id],tracker_name[v[:tracker_id]],
            v[:prevue][:nbr].to_i,v[:prevue][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:non_entamer][:nbr].to_i,v[:non_entamer][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:etude_en_cours][:nbr].to_i,v[:etude_en_cours][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:etude_finalise][:nbr].to_i,v[:etude_finalise][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:consultation][:nbr].to_i,v[:consultation][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:engager][:nbr].to_i,v[:engager][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:en_cours_pa][:nbr].to_i,v[:en_cours_pa][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:en_cours_rar][:nbr].to_i,v[:en_cours_rar][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:realiser_pa][:nbr].to_i,v[:realiser_pa][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:realiser_rar][:nbr].to_i,v[:realiser_rar][:consistance].to_d.round(2).to_s.gsub('.', ','),
            v[:arret_global][:nbr].to_i,v[:arret_global][:consistance].to_d.round(2).to_s.gsub('.', ',')
            ]
          else
            csv << [dot_name(v[:project_id]),v[:project_id],tracker_name[v[:tracker_id]],
            v[:prevue][:nbr].to_i,v[:prevue][:consistance].to_i,
            v[:non_entamer][:nbr].to_i,v[:non_entamer][:consistance].to_i,
            v[:etude_en_cours][:nbr].to_i,v[:etude_en_cours][:consistance].to_i,
            v[:etude_finalise][:nbr].to_i,v[:etude_finalise][:consistance].to_i,
            v[:consultation][:nbr].to_i,v[:consultation][:consistance].to_i,
            v[:engager][:nbr].to_i,v[:engager][:consistance].to_i,
            v[:en_cours_pa][:nbr].to_i,v[:en_cours_pa][:consistance].to_i,
            v[:en_cours_rar][:nbr].to_i,v[:en_cours_rar][:consistance].to_i,
            v[:realiser_pa][:nbr].to_i,v[:realiser_pa][:consistance].to_i,
            v[:realiser_rar][:nbr].to_i,v[:realiser_rar][:consistance].to_i,
            v[:arret_global][:nbr].to_i,v[:arret_global][:consistance].to_i
            ]
          end
        end
      end
      
    end
  
     send_data csv_data,
     filename: "dot_csv_#{project.id}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
     type: 'text/csv',
     disposition: 'attachment'
 
 
   end



  # Lists visible projects
  def index
    # try to redirect to the requested menu item
    if params[:jump] && redirect_to_menu_item(params[:jump])
      return
    end

    retrieve_default_query
    retrieve_project_query
    scope = project_scope

    respond_to do |format|
      format.html do
        # TODO: see what to do with the board view and pagination
        if @query.display_type == 'board'
          @entries = scope.to_a
        else
          @entry_count = scope.count
          @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
          @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
        end
      end
     format.api do
         @offset, @limit = api_offset_and_limit
         @project_count = scope.count
         @projects = scope.offset(@offset).limit(@limit).to_a
         project = Project.find(277)
         @dot_json = report_do(project,:recp_json)
         reprot_json = {}
 
         @dot_json.each do |key, value|
              value_json = {}
              
              value.each do |k, v|
                  value_json[k] = {total_inscrit:  v[:prevue][:consistance].to_i +  v[:en_cours_rar][:consistance].to_i + v[:realiser_rar][:consistance].to_i,
                                   total_en_cours:  v[:en_cours_rar][:consistance].to_i + v[:en_cours_pa][:consistance].to_i,
                                   total_realiser:  v[:realiser_pa][:consistance].to_i + v[:realiser_rar][:consistance].to_i, arret_global: v[:arret_global][:consistance].to_i

                                   #,prevue: v[:prevue][:consistance].to_i,en_cours_pa: v[:en_cours_pa][:consistance].to_i,
                                   #en_cours_rar: v[:en_cours_rar][:consistance].to_i,realiser_pa: v[:realiser_pa][:consistance].to_i,
                                   #realiser_rar: v[:realiser_rar][:consistance].to_i
                                }
             
              end
             
             reprot_json[dot_name(key)] = value_json
         end
          
        total_values = Hash.new { |hash, key| hash[key] = Hash.new(0) }
        reprot_json.each do |region, sub_hashes|
          sub_hashes.each do |sub_hash_name, sub_hash_values|
             sub_hash_values.each do |key, value|
             total_values[sub_hash_name][key] += value.to_i
            end
          end
        end
        dg_entry = {
         :dg => {
           :ODN_Dev => total_values[:ODN_Dev],
           :ODN_Mod => total_values[:ODN_Mod]}}
        
          reprot_json = dg_entry.merge(reprot_json) 
          render json: reprot_json
       end
       format.atom do
         projects = scope.reorder(:created_on => :desc).limit(Setting.feeds_limit.to_i).to_a
         render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
       end
       format.csv do
         # Export all entries
         @entries = scope.to_a
         send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'projects.csv')
       end
     end
   end
  def autocomplete
    respond_to do |format|
      format.js do
        if params[:q].present?
          @projects = Project.visible.like(params[:q]).to_a
        else
          @projects = User.current.projects.to_a
        end
      end
    end
  end

  def new
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @trackers = Tracker.sorted.to_a
    @project = Project.new
    @project.safe_attributes = params[:project]
  end

  def create
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @trackers = Tracker.sorted.to_a
    @project = Project.new
    @project.safe_attributes = params[:project]

    if @project.save
      unless User.current.admin?
        @project.add_default_member(User.current)
      end
      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_create)
          if params[:continue]
            attrs = {:parent_id => @project.parent_id}.reject {|k,v| v.nil?}
            redirect_to new_project_path(attrs)
          else
            redirect_to settings_project_path(@project)
          end
        end
        format.api do
          render(
            :action => 'show',
            :status => :created,
            :location => url_for(:controller => 'projects',
                                 :action => 'show', :id => @project.id)
          )
        end
      end
    else
      respond_to do |format|
        format.html {render :action => 'new'}
        format.api  {render_validation_errors(@project)}
      end
    end
  end

  def copy
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @trackers = Tracker.sorted.to_a
    @source_project = Project.find(params[:id])
    if request.get?
      @project = Project.copy_from(@source_project)
      @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
    else
      Mailer.with_deliveries(params[:notifications] == '1') do
        @project = Project.new
        @project.safe_attributes = params[:project]
        if @project.copy(@source_project, :only => params[:only])
          flash[:notice] = l(:notice_successful_create)
          redirect_to settings_project_path(@project)
        elsif !@project.new_record?
          # Project was created
          # But some objects were not copied due to validation failures
          # (eg. issues from disabled trackers)
          # TODO: inform about that
          redirect_to settings_project_path(@project)
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    # source_project not found
    render_404
  end

  # Show @project
  def show
    # try to redirect to the requested menu item
    if params[:jump] && redirect_to_project_menu_item(@project, params[:jump])
      return
    end

    respond_to do |format|
      format.html do
        @principals_by_role = @project.principals_by_role
        @subprojects = @project.children.visible.to_a
        @news = @project.news.limit(5).includes(:author, :project).reorder("#{News.table_name}.created_on DESC").to_a
        with_subprojects = Setting.display_subprojects_issues?
        @trackers = @project.rolled_up_trackers(with_subprojects).visible

        cond = @project.project_condition(with_subprojects)
         @process_data_report  = report_do(@project,:total_dots)
         @report_par_dot = report_do(@project,:par_dots)
         @racc_objectif = report_do(@project,:racc_objectif)
         @racc_realiser = report_do(@project,:racc_realiser)
        @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
        @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count

        if User.current.allowed_to_view_all_time_entries?(@project)
          @total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
          @total_estimated_hours = Issue.visible.where(cond).sum(:estimated_hours).to_f
        end

        @key = User.current.atom_key
      end
      format.api
    end
  end

  def settings
    @issue_custom_fields = IssueCustomField.sorted.to_a
    @issue_category ||= IssueCategory.new
    @member ||= @project.members.new
    @trackers = Tracker.sorted.to_a

    @version_status = params[:version_status] || 'open'
    @version_name = params[:version_name]
    @versions = @project.shared_versions.status(@version_status).like(@version_name).sorted
  end

  def edit
  end

  def update
    @project.safe_attributes = params[:project]
    if @project.save
      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_update)
          redirect_to settings_project_path(@project, params[:tab])
        end
        format.api {render_api_ok}
      end
    else
      respond_to do |format|
        format.html do
          settings
          render :action => 'settings'
        end
        format.api {render_validation_errors(@project)}
      end
    end
  end

  def archive
    unless @project.archive
      error = l(:error_can_not_archive_project)
    end
    respond_to do |format|
      format.html do
        flash[:error] = error if error
        redirect_to_referer_or admin_projects_path(:status => params[:status])
      end
      format.api do
        if error
          render_api_errors error
        else
          render_api_ok
        end
      end
    end
  end

  def unarchive
    unless @project.active?
      @project.unarchive
    end
    respond_to do |format|
      format.html{ redirect_to_referer_or admin_projects_path(:status => params[:status]) }
      format.api{ render_api_ok }
    end
  end

  def bookmark
    jump_box = Redmine::ProjectJumpBox.new User.current
    if request.delete?
      jump_box.delete_project_bookmark @project
    elsif request.post?
      jump_box.bookmark_project @project
    end
    respond_to do |format|
      format.js
      format.html {redirect_to project_path(@project)}
    end
  end

  def close
    @project.close
    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      format.api { render_api_ok }
    end
  end

  def reopen
    @project.reopen
    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      format.api { render_api_ok }
    end
  end

  # Delete @project
  def destroy
    unless @project.deletable?
      deny_access
      return
    end

    @project_to_destroy = @project
    if api_request? || params[:confirm] == @project_to_destroy.identifier
      DestroyProjectJob.schedule(@project_to_destroy)
      flash[:notice] = l(:notice_successful_delete)
      respond_to do |format|
        format.html do
          redirect_to(
            User.current.admin? ? admin_projects_path : projects_path
          )
        end
        format.api  {render_api_ok}
      end
    end
    # hide project in layout
    @project = nil
  end

  # Delete selected projects
  def bulk_destroy
    @projects = Project.where(id: params[:ids]).
      where.not(status: Project::STATUS_SCHEDULED_FOR_DELETION).to_a

    if @projects.empty?
      render_404
      return
    end

    if params[:confirm] == I18n.t(:general_text_Yes)
      DestroyProjectsJob.schedule @projects
      flash[:notice] = l(:notice_successful_delete)
      redirect_to admin_projects_path
    end
  end

   #------------------------ fonction de traitement reporting 

def report_do(project,type_report)
  
  # process_normalisation 
  def process_normalisation(k, v, result_dev, result_mod)


      #  affectation des parametres
       status_id = v[:status_id].to_i  
       exercice = v[6].to_s 
       tracker = k[0].to_i 
       ratio = v[:done_ratio].to_i   || 0
       acces_prevue = v[24].to_i || 0
       acces_en_cours = (v[262].to_i * 8)  || 0
       acces_realisé = v[28].to_i || 0
       km_prevue = v[74].to_f || 0
       km_realise = v[27].to_f || 0
       scenario_dev = v[253].to_i == 291 
       scenario_mod = v[253].to_i == 292
       scenario_tdm = v[253].to_i == 293
       acces_cuivre_prevue = v[288].to_i || 0
       acces_ftth_prevue = v[289].to_i || 0
       acces_cuivre_raccorder = v[241].to_i || 0
       acces_ftth_raccorder = v[242].to_i || 0
       dist_fo_prevue = v[73].to_i || 0
       dist_fo_poser = v[83].to_i || 0



     if tracker == 24

      if ([5,7].include?(status_id) && ratio.between?(20, 90)) || ([5,9,10,11,12,13,61].include?(status_id) && ratio == 100)
        result_dev[:nbr_realiser_pa] += acces_ftth_raccorder
        result_dev[:consistance_realiser_pa] += acces_cuivre_raccorder
      end
      
     end

  if status_id == 7  
  
   if tracker == 60
     if scenario_dev
         result_dev[:nbr_arret_global] += 1
         result_dev[:consistance_arret_global] += acces_en_cours 
     elsif scenario_mod
        result_mod[:nbr_arret_global] += 1
        result_mod[:consistance_arret_global] += acces_en_cours 
     elsif scenario_tdm
        result_mod[:nbr_arret_global] += 1
        result_mod[:consistance_arret_global] += acces_en_cours 
    end
  elsif tracker == 4
         result_dev[:nbr_arret_global] += 1
         result_dev[:consistance_arret_global] +=  km_prevue
  elsif tracker == 6
    result_dev[:nbr_arret_global] += 1
    result_dev[:consistance_arret_global] +=  dist_fo_prevue
  else
      result_dev[:nbr_arret_global] += 1
  end

end

# pour les status clôturé & besoin_exprimé********************************************************
if [13,69].include?(status_id)

  if tracker == 60
    if scenario_dev
        result_dev[:nbr_cloturer] += 1
    else 
        result_mod[:nbr_cloturer] += 1 
    end
  else
       result_dev[:nbr_cloturer] += 1
  end

end

# etat des sites actifs & APS*************************************************************

if [7,8,9,29,32,47,58,59,62].include?(tracker)

     if tracker == 58 || tracker == 59
        result_mod[:nbr_prevue_pa] += 1
        result_mod[:consistance_prevue_pa] += acces_prevue
      elsif tracker == 47 
         result_dev[:nbr_prevue_pa] += 1
         result_dev[:consistance_prevue_pa] += acces_prevue
        elsif tracker == 62
          result_dev[:nbr_prevue_pa] += acces_ftth_prevue
          result_dev[:consistance_prevue_pa] += acces_cuivre_prevue
            
      else
         result_dev[:nbr_prevue_pa] += 1
     end

  #--- PAR PHASE **************************************************
  
  case status_id

    when 1
         if tracker == 58 || tracker == 59
            result_mod[:nbr_non_entamer_pa] += 1
            result_mod[:consistance_non_entamer_pa] += acces_prevue
         elsif tracker == 47 
            result_dev[:nbr_non_entamer_pa] += 1
            result_dev[:consistance_non_entamer_pa] += acces_prevue
         
         else
            result_dev[:nbr_non_entamer_pa] += 1
         end

     when 47,60,66,67,68,70,76,77 

        if tracker == 58 || tracker == 59
           result_mod[:nbr_etude_en_cours] += 1
           result_mod[:consistance_etude_en_cours] += acces_prevue
        elsif tracker == 47
           result_dev[:nbr_etude_en_cours] += 1
           result_dev[:consistance_etude_en_cours] += acces_prevue
        else 
          result_dev[:nbr_etude_en_cours] += 1
       end

#*********** VERIFICATION ETUDE EN COURS**************

    when 56,64,69,78

      if tracker == 58 || tracker == 59
        result_mod[:nbr_etude_finalise] += 1
        result_mod[:consistance_etude_finalise] += acces_prevue
      elsif tracker == 47
       result_dev[:nbr_etude_finalise] += 1
       result_dev[:consistance_etude_finalise] += acces_prevue
     else 
       result_dev[:nbr_etude_finalise] += 1
     end
 


# phase deploiement partie active OLT & FTTB/C
    when 44,48,55,80
       result_dev[:nbr_preparation_site] += 1
    when 49
      result_dev[:nbr_demande_dotaion] += 1
    when 50
      result_dev[:nbr_demande_valider] += 1
    when 39
     result_dev[:nbr_doter] += 1
    when 40
      result_dev[:nbr_installer] += 1
    when 41
      result_dev[:nbr_MES] += 1
    when 57
      result_dev[:nbr_en_exploitation] += 1
  end

end

#************************* Partie 4G ***********************************
if tracker == 10
if ["PA-2023", "PA-2022_reporté","HP-2023"].include?(exercice)
     
  result_dev[:nbr_prevue_pa] += 1

case status_id
  when 1
     result_dev[:nbr_non_entamer_pa] += 1
  when 51,52,53,72
     result_dev[:nbr_etude_en_cours] += 1
   when 54,58,79
     result_dev[:nbr_etude_finalise] += 1    
   when 55
     result_dev[:nbr_preparation_site] += 1
   when 80
     result_dev[:nbr_site_valider] += 1
   when 74
     result_dev[:nbr_demande_installation] += 1
   when 75
     result_dev[:nbr_demande_valider] += 1
   when 40
     result_dev[:nbr_installer] += 1
   when 41
     result_dev[:nbr_MES] += 1
   when 57
     result_dev[:nbr_en_exploitation] += 1
 end


else
result_mod[:nbr_prevue_pa] += 1


 case status_id
    when 1
      result_mod[:nbr_non_entamer_pa] += 1
    when 51,52,53,72
      result_mod[:nbr_etude_en_cours] += 1
    when 54,58,79
      result_mod[:nbr_etude_finalise] += 1    
    when 55
      result_mod[:nbr_preparation_site] += 1
    when 80
      result_mod[:nbr_site_valider] += 1
    when 74
      result_mod[:nbr_demande_installation] += 1
    when 75
      result_mod[:nbr_demande_valider] += 1
    when 40
      result_mod[:nbr_installer] += 1
    when 41
      result_mod[:nbr_MES] += 1
    when 57
      result_mod[:nbr_en_exploitation] += 1
  end

end
end
# ************************* FIN 4G ***********************************
if ![7,8,9,10,24,29,32,47,58,59,62].include?(tracker)
if ["PA-2023", "PA-2022_reporté","HP-2023"].include?(exercice) 

result_dev[:nbr_prevue_pa] += 1
  if tracker == 4
     result_dev[:consistance_prevue_pa] +=  km_prevue 
  elsif tracker == 6
    result_dev[:consistance_prevue_pa] += dist_fo_prevue
  end

case status_id

when 1
 result_dev[:nbr_non_entamer_pa] += 1
   if tracker == 4
     result_dev[:consistance_non_entamer_pa] += km_prevue 
  elsif tracker == 6
     result_dev[:consistance_non_entamer_pa]  += dist_fo_prevue
  end

when 2
 if ratio < 100
    result_dev[:nbr_etude_en_cours] += 1
    if tracker == 4
      result_dev[:consistance_etude_en_cours] += km_prevue 
    elsif tracker == 6
      result_dev[:consistance_etude_en_cours] += dist_fo_prevue
    end
  else
    result_dev[:nbr_etude_finalise] += 1 
      if tracker == 4
        result_dev[:consistance_etude_finalise] += km_prevue 
      elsif tracker == 6
        result_dev[:consistance_etude_finalise] += dist_fo_prevue
      end
 end

when 3
 if tracker == 60
   if scenario_dev
      result_dev[:nbr_consultaton_pa] += 1
      result_dev[:consistance_consultation_pa] += acces_prevue
   else
      result_mod[:nbr_consultaton_pa] += 1
      result_mod[:consistance_consultation_pa] += acces_prevue
   end
  elsif tracker == 4
    result_dev[:nbr_consultaton_pa] += 1
    result_dev[:consistance_consultation_pa] += km_prevue
  elsif tracker == 6
    result_dev[:nbr_consultaton_pa] += 1
    result_dev[:consistance_consultation_pa] += dist_fo_prevue
  else
    result_dev[:nbr_consultaton_pa] += 1 
 end

when 42,58

if tracker == 60
   if scenario_dev
      result_dev[:nbr_engager_pa] += 1
      result_dev[:consistance_engager_pa] += acces_prevue
   else
      result_mod[:nbr_engager_pa] += 1
      result_mod[:consistance_engager_pa] += acces_prevue
   end
  elsif tracker == 4
    result_dev[:nbr_engager_pa] += 1
    result_dev[:consistance_engager_pa] += km_prevue
  elsif tracker == 6
    result_dev[:nbr_engager_pa] += 1
    result_dev[:consistance_engager_pa] += dist_fo_prevue
 else
    result_dev[:nbr_engager_pa] += 1
end

when 4,6,7

  if tracker == 60
    if scenario_dev
      result_dev[:nbr_en_cours_pa] += 1
      result_dev[:consistance_en_cours_pa] += acces_en_cours 
    else
      result_mod[:nbr_en_cours_pa] += 1
      result_mod[:consistance_en_cours_pa] += acces_en_cours
    end
  elsif tracker == 4
    result_dev[:nbr_en_cours_pa] += 1
    result_dev[:consistance_en_cours_pa] += km_prevue
  elsif tracker == 6
    result_dev[:nbr_en_cours_pa] += 1
    result_dev[:consistance_en_cours_pa] += dist_fo_prevue
 else
     result_dev[:nbr_en_cours_pa] += 1
  end

when 5
 if ratio < 100
    if tracker == 60
       if scenario_dev
         result_dev[:nbr_en_cours_pa] += 1
         result_dev[:consistance_en_cours_pa] += acces_en_cours 
       else
         result_mod[:nbr_en_cours_pa] += 1
         result_mod[:consistance_en_cours_pa] += acces_en_cours
       end
    elsif tracker == 4
        result_dev[:nbr_en_cours_pa] += 1
        result_dev[:consistance_en_cours_pa] +=  dist_fo_prevue  
    elsif tracker == 6
      result_dev[:nbr_en_cours_pa] += 1
      result_dev[:consistance_en_cours_pa] +=  dist_fo_prevue  
    else
        result_dev[:nbr_en_cours_pa] += 1
     end
 else 

   if tracker == 60
      if scenario_dev
         result_dev[:nbr_realiser_pa] += 1
         result_dev[:consistance_realiser_pa] += acces_realisé
       else
         result_mod[:nbr_realiser_pa] += 1
         result_mod[:consistance_realiser_pa] += acces_realisé
       end
    elsif tracker == 4
        result_dev[:nbr_realiser_pa] += 1
        result_dev[:consistance_realiser_pa] += km_realise   
    elsif tracker == 6
        result_dev[:nbr_realiser_pa] += 1
        result_dev[:consistance_realiser_pa] += dist_fo_poser
   else
        result_dev[:nbr_realiser_pa] += 1 
   end
end

when 9,10,11,12,13,61

 if tracker == 60
    if scenario_dev
        result_dev[:nbr_realiser_pa] += 1
        result_dev[:consistance_realiser_pa] += acces_realisé
    else
        result_mod[:nbr_realiser_pa] += 1
        result_mod[:consistance_realiser_pa] += acces_realisé
    end
  elsif tracker == 4
    result_dev[:nbr_realiser_pa] += 1
    result_dev[:consistance_realiser_pa] += km_realise  
  elsif tracker == 6
    result_dev[:nbr_realiser_pa] += 1
    result_dev[:consistance_realiser_pa] += dist_fo_poser
 else
     result_dev[:nbr_realiser_pa] += 1
end


end   



else


case status_id

when 3,42,58
 
 if tracker == 60
   if scenario_dev
      result_dev[:nbr_en_cours_rar] += 1
      result_dev[:consistance_en_cours_rar] += 0
   else
      result_mod[:nbr_en_cours_rar] += 1
      result_mod[:consistance_en_cours_rar] += 0
   end
elsif tracker == 4
    result_dev[:nbr_en_cours_rar] += 1
    result_dev[:consistance_en_cours_rar] += km_prevue
elsif tracker == 6
    result_dev[:nbr_en_cours_rar] += 1
    result_dev[:consistance_en_cours_rar] += dist_fo_prevue
else
 result_dev[:nbr_en_cours_rar] += 1
end

when 4,6,7

  if tracker == 60
    if scenario_dev
      result_dev[:nbr_en_cours_rar] += 1
      result_dev[:consistance_en_cours_rar] += acces_en_cours 
    else
      result_mod[:nbr_en_cours_rar] += 1
      result_mod[:consistance_en_cours_rar] += acces_en_cours
    end
  elsif tracker == 4
    result_dev[:nbr_en_cours_rar] += 1
    result_dev[:consistance_en_cours_rar] += km_prevue
  elsif tracker == 6
    result_dev[:nbr_en_cours_rar] += 1
    result_dev[:consistance_en_cours_rar] += dist_fo_prevue
 else
     result_dev[:nbr_en_cours_rar] += 1
  end

when 9,10,11,12,13,61

   if tracker == 60
      if scenario_dev
         result_dev[:nbr_réalisé_rar] += 1
         result_dev[:consistance_realiser_rar] += acces_realisé
      else
          result_mod[:nbr_réalisé_rar] += 1
          result_mod[:consistance_realiser_rar] += acces_realisé
      end
    elsif tracker == 4
      result_dev[:nbr_réalisé_rar] += 1
      result_dev[:consistance_realiser_rar] += km_realise  
    elsif tracker == 6
      result_dev[:nbr_réalisé_rar] += 1
      result_dev[:consistance_realiser_rar] += dist_fo_poser
   else
       result_dev[:nbr_réalisé_rar] += 1  
   end

when 5

 
 if ratio < 100
      if tracker == 60
          if scenario_dev
               result_dev[:nbr_en_cours_rar] += 1
               result_dev[:consistance_en_cours_rar] += acces_en_cours 
          else
               result_mod[:nbr_en_cours_rar] += 1
              result_mod[:consistance_en_cours_rar] += acces_en_cours
          end
        elsif tracker == 4
          result_dev[:nbr_en_cours_rar] += 1
          result_dev[:consistance_en_cours_rar] += km_prevue
        elsif tracker == 6
          result_dev[:nbr_en_cours_pa] += 1
          result_dev[:consistance_en_cours_pa] += dist_fo_prevue
       else
           result_dev[:nbr_en_cours_rar] += 1
     end
 else 

    if tracker == 60
        if scenario_dev
           result_dev[:nbr_réalisé_rar] += 1
           result_dev[:consistance_realiser_rar] += acces_realisé
        else
           result_mod[:nbr_réalisé_rar] += 1
           result_mod[:consistance_realiser_rar] += acces_realisé
       end
    elsif tracker == 4
        result_dev[:nbr_réalisé_rar] += 1
        result_dev[:consistance_realiser_rar] += km_realise
      elsif tracker == 6
        result_dev[:nbr_réalisé_rar] += 1
        result_dev[:consistance_realiser_rar] += dist_fo_poser
    else
        result_dev[:nbr_réalisé_rar] += 1
    end
 end

end


end  

end
   
end
#  end fonction process_normalisation



    #@subprojects = @project.children.visible.to_a
    # @trackers = @project.rolled_up_trackers(with_subprojects).visible
    with_subprojects = Setting.display_subprojects_issues?
    cond = project.project_condition(with_subprojects)
    trackers = project.rolled_up_trackers(with_subprojects).visible


  
  # Define constants
  tbl = []
  tbl_dot = []
  tbl_dot_result = []
  # Define trackers ids
  tracker_ids = trackers.map(&:id)
  
  # Define scopes
  issues = Issue.visible.open.where(cond)
              .where(tracker_id:  tracker_ids)
              .includes(:custom_values)
              .where(custom_values: { custom_field_id:[6,24,74,27,28,73,83,241,242, 286, 262, 253,288,289] })

  data = issues.pluck(:project_id, :id, :tracker_id, :status_id,:done_ratio, 'custom_values.custom_field_id', 'custom_values.value')
              .map do |ligne|
                {
                  project_id: ligne[0],
                  issue_id: ligne[1],
                  tracker_id: ligne[2],
                  status_id: ligne[3],
                  done_ratio: ligne[4],
                  ligne[5].to_i => ligne[6] 
                }
              end
              .group_by { |k| [k[:tracker_id],k[:project_id]] }
              .transform_values do |v| 
                v.group_by { |elm| elm[:issue_id] }
                 .transform_values { |v| v.inject(:merge).except(:project_id, :tracker_id, :issue_id) }
              end

  # -------------------- fonction de calcule-------------------------------------------
  data.each do |key,value|
  
    position =  trackers.select { |t| t.id.to_i == key[0].to_i}.first.position.to_i
  
    common_values = { 
                      project_id: key[1].to_i,
                      tracker_id: key[0].to_i,
                      position: position,
                      nbr_prevue_pa: 0,
                      consistance_prevue_pa: 0, 
                      nbr_non_entamer_pa: 0,
                      consistance_non_entamer_pa: 0, 
                      nbr_etude_en_cours: 0, 
                      consistance_etude_en_cours: 0, 
                      nbr_etude_finalise: 0, 
                      consistance_etude_finalise: 0,
                      nbr_consultaton_pa: 0, 
                      consistance_consultation_pa: 0, 
                      nbr_engager_pa: 0, 
                      consistance_engager_pa: 0,  
                      nbr_en_cours_pa: 0,
                      consistance_en_cours_pa: 0,
                      nbr_en_cours_rar: 0,
                      consistance_en_cours_rar: 0,
                      nbr_réalisé_rar: 0, 
                      consistance_realiser_rar: 0,
                      nbr_realiser_pa: 0, 
                      consistance_realiser_pa: 0, 
                      nbr_arret_global: 0,
                      consistance_arret_global: 0,
                      nbr_cloturer:0,
                      consistance_cloturer:0,
                      nbr_preparation_site: 0,
                      consistance_preparation_site: 0,
                      nbr_site_valider: 0,
                      consistance_site_valider: 0,
                      nbr_demande_dotaion:0,
                      consistance_demande_dotaion:0,
                      #nbr_dotation_valider:0,
                      #consistance_dotation_valider:0,
                      nbr_demande_installation: 0,
                      consistance_demande_installation: 0,
                      nbr_demande_valider:0,
                      consistance_demande_valider:0,
                      nbr_doter: 0,
                      consistance_doter: 0,
                      nbr_installer: 0,
                      consistance_installer: 0,
                      nbr_MES:0,
                      consistance_MES:0,
                      nbr_en_exploitation:0,
                      consistance_en_exploitation:0

                      
                    }
                    
    result_dev = common_values.merge({type: 'dev'})
    result_mod = common_values.merge({type: 'mod'})
         
       # -------------------------- boucle de l'itération ------------------------------
               value.each do |k,v| 
                  process_normalisation(key,v,result_dev,result_mod)         
               end              
     # --------------------------------------------------------------------------------------------------                       
        
     if key[0].to_i  == 60 
      result_dev[:tracker_id] = 47 
      result_dev[:nbr_prevue_pa] = 0
      result_dev[:consistance_prevue_pa] = 0
      result_dev[:nbr_non_entamer_pa] = 0
      result_dev[:consistance_non_entamer_pa] = 0
      result_dev[:nbr_etude_en_cours] = 0
      result_dev[:consistance_etude_en_cours] = 0
      result_dev[:nbr_etude_finalise]  = 0
      result_dev[:consistance_etude_finalise] = 0 
              result_mod[:tracker_id] = 58
              result_mod[:nbr_prevue_pa] = 0
              result_mod[:consistance_prevue_pa] = 0
              result_mod[:nbr_non_entamer_pa] = 0
              result_mod[:consistance_non_entamer_pa] = 0
              result_mod[:nbr_etude_en_cours] = 0
              result_mod[:consistance_etude_en_cours] = 0
              result_mod[:nbr_etude_finalise] = 0
              result_mod[:consistance_etude_finalise] = 0
     
          tbl << {[:ODN_Dev,key[1]] => result_dev.dup}
          tbl << {[:ODN_Mod,key[1]] => result_mod.dup}
     elsif key[0].to_i ==  47
          tbl << {[:ODN_Dev,key[1]] => result_dev.dup}
          
     elsif key[0].to_i == 58
          tbl << {[:ODN_Mod,key[1]] => result_mod.dup}
     elsif key[0].to_i == 59
         result_mod[:tracker_id] = 59
       tbl << { [:ODN_Mod,key[1]] => result_mod.dup}
       
       
     elsif key[0].to_i == 10
             tbl << {[:PA_4G,key[1]] => result_dev.dup}
             tbl << {[:RAR_4G,key[1]] => result_mod.dup} 
      elsif   key[0].to_i == 24
               result_dev[:tracker_id] = 62
               result_dev[:nbr_prevue_pa] = 0
               result_dev[:consistance_prevue_pa] = 0
              tbl << {[:Racc_clients,key[1]] => result_dev.dup}      
     elsif   key[0].to_i == 62
               tbl << {[:Racc_clients,key[1]] => result_dev.dup}
     elsif  key[0].to_i == 4
       tbl << {[:Canalisation,key[1]] => result_dev.dup}
      elsif key[0].to_i == 6
        tbl << {[:Pose_fo,key[1]] => result_dev.dup}
     else #tracker_ids.include?(key[0].to_i)
        tbl << {[trackers.find_by(id:key[0]).name.to_s,key[1]] => result_dev.dup}  if trackers.find_by(id:key[0])
     end
end         

   tbl_result =  tbl.each_with_object({}) do |hash, acc|
    key = hash.keys.first
    value = hash[key]
    acc[key] ||= {}


    acc[key].merge!(value) do |k, v1, v2|
       if k == :project_id || k == :type || k== :tracker_id || k == :position
        v1
       else
         v1.to_d + v2.to_d

       end
    end
  end
   
  tbl_result =  tbl_result.map { |k,v|{ k => v}}
  

  
  
  tbl_result.each do |c|
    tmp = {}
   c.each do |key,value|

   tmp[key] = {
     project_id: value[:project_id].to_i,
     tracker_id: value[:tracker_id].to_i,
     position: value[:position],
     prevue: {
       nbr: value[:nbr_prevue_pa],
       consistance: value[:consistance_prevue_pa].to_d
     },
     non_entamer: {
       nbr: value[:nbr_non_entamer_pa].to_i,
       consistance: value[:consistance_non_entamer_pa].to_d
     },
     etude_en_cours: {
       nbr: value[:nbr_etude_en_cours].to_i,
       consistance: value[:consistance_etude_en_cours].to_d
     },
     etude_finalise: {
       nbr: value[:nbr_etude_finalise].to_i,
       consistance: value[:consistance_etude_finalise].to_d
     },
     consultation: {
       nbr: value[:nbr_consultaton_pa].to_i,
       consistance: value[:consistance_consultation_pa].to_d
     },
     engager: {
       nbr: value[:nbr_engager_pa].to_i,
       consistance: value[:consistance_engager_pa].to_d
     },
     en_cours_pa: {
       nbr: value[:nbr_en_cours_pa].to_i,
       consistance: value[:consistance_en_cours_pa].to_d
     },
     en_cours_rar: {
       nbr: value[:nbr_en_cours_rar].to_i,
       consistance: value[:consistance_en_cours_rar].to_d
     },
     realiser_rar: {
       nbr: value[:nbr_réalisé_rar].to_i,
       consistance: value[:consistance_realiser_rar].to_d
     },
     realiser_pa: {
       nbr: value[:nbr_realiser_pa].to_i,
       consistance: value[:consistance_realiser_pa].to_d
     },
     arret_global: {
       nbr: value[:nbr_arret_global].to_i,
       consistance: value[:consistance_arret_global].to_d
     },
       cloturer: { 
         nbr: value[:nbr_cloturer].to_i,
         consistance: value[:consistance_cloturer].to_d
     },
       preparation_site: {
         nbr: value[:nbr_preparation_site].to_i,
         consistance: value[:consistance_preparation_site].to_i
     },
       site_valider: {
         nbr: value[:nbr_site_valider].to_i,
         consistance: value[:consistance_site_valider].to_i
     },

       demande_dotaion: {
          nbr: value[:nbr_demande_dotaion].to_i,
          consistance: value[:consistance_demande_dotaion].to_i
     },
        #dotation_valider: {
          #nbr: value[:nbr_dotation_valider],
          #consistance: value[:consistance_dotation_valider]
    # },
        demande_installation: {
          nbr: value[:nbr_demande_installation].to_i,
          consistance: value[:consistance_demande_installation].to_i
     },
        demande_valider: {
          nbr: value[:nbr_demande_valider].to_i,
          consistance: value[:consistance_demande_valider].to_i
     },
        doter: {
          nbr: value[:nbr_doter].to_i,
          consistance: value[:consistance_doter].to_i
     },
        installer: {
         nbr: value[:nbr_installer].to_i,
         consistance: value[:consistance_installer].to_i
     },
        mes: {
          nbr: value[:nbr_MES].to_i,
          consistance: value[:consistance_MES].to_i
     },
       en_exploitation: {
         nbr: value[:nbr_en_exploitation].to_i,
         consistance: value[:consistance_en_exploitation].to_i
     }
       
   }.compact
   tbl_dot << tmp.deep_dup
 end
  
end
recp_dot = {}
recp_json = {}
 # **********************************************************************
  tbl_dot.select { |h| h.keys.any? { |k| [:ODN_Dev, :ODN_Mod,:Canalisation,:Pose_fo].include?(k[0]) }}.each do |hash|
  
      key = hash.keys.first[0]
     dot_key = hash.keys.first[1]
  
       if recp_dot[dot_key].nil?
         recp_dot[dot_key] = {}
      end
  
  recp_dot[dot_key][key] = hash.values.first
end
   
tbl_dot.select { |h| h.keys.any? { |k| [:ODN_Dev, :ODN_Mod].include?(k[0]) }}.each do |hash|
  
  key = hash.keys.first[0]
  dot_key = hash.keys.first[1]

   if recp_json[dot_key].nil?
    recp_json[dot_key] = {}
  end

  recp_json[dot_key][key] = hash.values.first
end

# totla par action *********************************
new_data = tbl_dot.each_with_object({}) do |hash, acc|
 key = hash.keys.first[0]
 value = hash.values.first

 acc[key] ||= {}


 acc[key].merge!(value) do |k, v1, v2|
  if k == :project_id || k == :type || k == :tracker_id || k == :position
    v1
  else
    {
      nbr: v1[:nbr].to_i + v2[:nbr].to_i,
      consistance: v1[:consistance].to_d + v2[:consistance].to_d
    }
  end
end
end




    


# ***************
    
    
     new_data = new_data.sort_by { |_, v| v[:position] }


 racc = new_data.select { |element| element[0] == :Racc_clients }

 if type_report == :total_dots
  return new_data
 elsif type_report == :par_dots
  return recp_dot
 elsif type_report == :recp_json
   return recp_json
 elsif type_report == :racc_objectif
  return get_valeur_from_tracker(new_data,:Racc_clients,:prevue)
elsif type_report == :racc_realiser
  return get_valeur_from_tracker(new_data,:Racc_clients,:realiser_pa)
 end 
end # fin de la methode report_do(project)
#  declaration fonction
  





  private
   
def dot_name(id) 
      
    id_to_name = { 
        276 => "Adrar",278 => "Aïn Defla",279 =>  "In Salah",280 =>  "Aïn Témouchent",281 =>  "Alger centre",282 =>  "Alger est",283 =>  "Alger ouest",284 =>  "Annaba",285 =>  "B.B.A",
        287 =>  "B.B.M",288 =>  "Batna",289 =>  "Béchar",290 =>  "Béjaïa",291 =>  "Béni Abbès",292 =>  "Biskra",293 =>  "Blida",294 =>  "Bouira",295 =>  "Boumerdès",296 =>  "Chlef",297 =>  "Constantine",
        298 =>  "Djanet",299 =>  "Djelfa", 300 =>  "El Bayadh",301 =>  "El Meniaa",302 =>  "El M'Ghair",303 =>  "El Oued",304 =>  "El Tarf",305 =>  "Ghardaïa",306 =>  "Guelma",307 =>  "Illizi",
        308 =>  "In Guezzam",309 =>  "Jijel",310 =>  "Khenchela",311 =>  "Laghouat",312 =>  "M'Sila",313 =>  "Mascara",314 =>  "Médéa",315 =>  "Mila",316 =>  "Mostaganem",317 =>  "Naâma",318 =>  "O.E.B",
        319 =>  "Oran",320 =>  "Ouargla",321 =>  "Ouled Djellal",322 =>  "Relizane",323 =>  "S.B.A",324 =>  "Saïda",325 =>  "Sétif",326 =>  "Skikda",327 =>  "Souk Ahras",328 =>  "Tamanrasset",
        329 =>  "Tébessa",330 =>  "Tiaret",331 =>  "Tindouf",332 =>  "Timimoun",333 =>  "Tipaza",334 =>  "Tissemsilt",335 =>  "Tizi Ouzou",336 =>  "Tlemcen",337 =>  "Touggourt" }

     return id_to_name[id.to_i]
  end
 
  def get_valeur_from_tracker(tbl, tracker, typ_value)
    sous_tableau = tbl.select { |element| element[0] == tracker }
    
    if sous_tableau.any?
      valeur = sous_tableau[0][1][typ_value]
      return [valeur[:nbr].to_i,valeur[:consistance].to_i]
    else
      return "0-0"
    end
  end


  # Returns the ProjectEntry scope for index
  def project_scope(options={})
    @query.results_scope(options)
  end

  def retrieve_project_query
    retrieve_query(ProjectQuery, false, :defaults => @default_columns_names)
  end

  def retrieve_default_query
    return if params[:query_id].present?
    return if api_request?
    return if params[:set_filter]

    if params[:without_default].present?
      params[:set_filter] = 1
      return
    end

    if default_query = ProjectQuery.default
      params[:query_id] = default_query.id
    end
  end
end
