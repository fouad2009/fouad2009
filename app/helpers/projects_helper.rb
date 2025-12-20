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

module ProjectsHelper
  def project_settings_tabs
    tabs =
      [
        {:name => 'info', :action => :edit_project,
         :partial => 'projects/edit', :label => :label_project},
        {:name => 'members', :action => :manage_members,
         :partial => 'projects/settings/members', :label => :label_member_plural},
        {:name => 'issues', :action => :edit_project, :module => :issue_tracking,
         :partial => 'projects/settings/issues', :label => :label_issue_tracking},
        {:name => 'versions', :action => :manage_versions,
         :partial => 'projects/settings/versions', :label => :label_version_plural,
         :url => {:tab => 'versions', :version_status => params[:version_status],
                  :version_name => params[:version_name]}},
        {:name => 'categories', :action => :manage_categories,
         :partial => 'projects/settings/issue_categories',
         :label => :label_issue_category_plural},
        {:name => 'repositories', :action => :manage_repository,
         :partial => 'projects/settings/repositories', :label => :label_repository_plural},
        {:name => 'boards', :action => :manage_boards,
         :partial => 'projects/settings/boards', :label => :label_board_plural},
        {:name => 'activities', :action => :manage_project_activities,
         :partial => 'projects/settings/activities', :label => :label_time_tracking}
      ]
    tabs.
      select {|tab| User.current.allowed_to?(tab[:action], @project)}.
      select {|tab| tab[:module].nil? || @project.module_enabled?(tab[:module])}
  end

  def parent_project_select_tag(project)
    selected = project.parent
    # retrieve the requested parent project
    parent_id = (params[:project] && params[:project][:parent_id]) || params[:parent_id]
    if parent_id
      selected = (parent_id.blank? ? nil : Project.find(parent_id))
    end

    options = +''
    options << "<option value=''>&nbsp;</option>" if project.allowed_parents.include?(nil)
    options << project_tree_options_for_select(project.allowed_parents.compact, :selected => selected)
    content_tag('select', options.html_safe, :name => 'project[parent_id]', :id => 'project_parent_id')
  end

  def render_project_action_links
    links = (+"").html_safe
    if User.current.allowed_to?(:add_project, nil, :global => true)
      links << link_to(l(:label_project_new), new_project_path, :class => 'icon icon-add')
    end
    if User.current.admin?
      links << link_to(l(:label_administration), admin_projects_path, :class => 'icon icon-settings')
    end
    links
  end

  # Renders the projects index
  def render_project_hierarchy(projects)
    bookmarked_project_ids = User.current.bookmarked_project_ids
    render_project_nested_lists(projects) do |project|
      classes = project.css_classes.split
      classes += %w(icon icon-user my-project) if User.current.member_of?(project)
      classes += %w(icon icon-bookmarked-project) if bookmarked_project_ids.include?(project.id)
      s = link_to_project(project, {}, :class => classes.uniq.join(' '))
      if project.description.present?
        s << content_tag('div', textilizable(project.short_description, :project => project), :class => 'wiki description')
      end
      s
    end
  end

  # Returns a set of options for a select field, grouped by project.
  def version_options_for_select(versions, selected=nil)
    grouped = Hash.new {|h, k| h[k] = []}
    versions.each do |version|
      grouped[version.project.name] << [version.name, version.id]
    end

    selected = selected.id if selected.is_a?(Version)
    if grouped.keys.size > 1
      grouped_options_for_select(grouped, selected)
    else
      options_for_select((grouped.values.first || []), selected)
    end
  end

  def project_default_version_options(project)
    versions = project.shared_versions.open.to_a
    if project.default_version && !versions.include?(project.default_version)
      versions << project.default_version
    end
    version_options_for_select(versions, project.default_version)
  end

  def project_default_assigned_to_options(project)
    assignable_users = (project.assignable_users.to_a + [project.default_assigned_to]).uniq.compact
    principals_options_for_select(assignable_users, project.default_assigned_to)
  end

  def project_default_issue_query_options(project)
    public_queries = IssueQuery.only_public
    grouped = {
      l('label_default_queries.for_all_projects')    => public_queries.where(project_id: nil).pluck(:name, :id),
      l('label_default_queries.for_current_project') => public_queries.where(project: project).pluck(:name, :id)
    }
    grouped_options_for_select(grouped, project.default_issue_query_id)
  end

  def format_version_sharing(sharing)
    sharing = 'none' unless Version::VERSION_SHARINGS.include?(sharing)
    l("label_version_sharing_#{sharing}")
  end

  def render_boards_tree(boards, parent=nil, level=0, &block)
    selection = boards.select {|b| b.parent == parent}
    return '' if selection.empty?

    s = ''.html_safe
    selection.each do |board|
      node = capture(board, level, &block)
      node << render_boards_tree(boards, board, level+1, &block)
      s << content_tag('div', node)
    end
    content_tag('div', s, :class => 'sort-level')
  end

  def render_api_includes(project, api)
    api.array :trackers do
      project.rolled_up_trackers(false).visible.each do |tracker|
        api.tracker(:id => tracker.id, :name => tracker.name)
      end
    end if include_in_api_response?('trackers')

    api.array :issue_categories do
      project.issue_categories.each do |category|
        api.issue_category(:id => category.id, :name => category.name)
      end
    end if include_in_api_response?('issue_categories')

    api.array :time_entry_activities do
      project.activities.each do |activity|
        api.time_entry_activity(:id => activity.id, :name => activity.name)
      end
    end if include_in_api_response?('time_entry_activities')

    api.array :enabled_modules do
      project.enabled_modules.each do |enabled_module|
        api.enabled_module(:id => enabled_module.id, :name => enabled_module.name)
      end
    end if include_in_api_response?('enabled_modules')

    api.array :issue_custom_fields do
      project.all_issue_custom_fields.each do |custom_field|
        api.custom_field(:id => custom_field.id, :name => custom_field.name)
      end
    end if include_in_api_response?('issue_custom_fields')
  end

  def bookmark_link(project, user = User.current)
    return '' unless user && user.logged?

    @jump_box ||= Redmine::ProjectJumpBox.new user
    bookmarked = @jump_box.bookmark?(project)
    css = +"icon bookmark "

    if bookmarked
      css << "icon-bookmark"
      method = "delete"
      text = l(:button_project_bookmark_delete)
    else
      css << "icon-bookmark-off"
      method = "post"
      text = l(:button_project_bookmark)
    end

    url = bookmark_project_path(project)
    link_to text, url, remote: true, method: method, class: css
  end

  def grouped_project_list(projects, query, &block)
    ancestors = []
    grouped_query_results(projects, query) do |project, group_name, group_count, group_totals|
      ancestors.pop while ancestors.any? && !project.is_descendant_of?(ancestors.last)
      yield project, ancestors.size, group_name, group_count, group_totals
      ancestors << project unless project.leaf?
    end
  end
#-------------- METHODES POUR LES TABLEAUX DE SUIVI DES PROJETS  ------------------
def display_process_data(process_data, trackers, project, data_chart = {})
  table_content = "".html_safe
  #data_chart = {}

  # =========================
  # THEAD
  # =========================
  table_content += content_tag(:thead) do
    content_tag(:tr) do
      concat content_tag(:th, "Prévisions PA", class: "Previsions", colspan: 2)
      concat content_tag(:th, "Phase Étude PA", class: "phase-etude", colspan: 3)
      concat content_tag(:th, "Phase Réalisation PA", class: "etat-realisation", colspan: 4)
      concat content_tag(:th, "Réalisations RAR", class: "etat-realisation", colspan: 2)
      concat content_tag(:th, "", colspan: 2)
    end +
    content_tag(:tr) do
      content_tag(:th, "Action", class: "action") +
      content_tag(:th, "Objectif", class: "objectf") +
      content_tag(:th, "Non entamé") +
      content_tag(:th, "Étude en cours") +
      content_tag(:th, "Étude finalisée") +
      content_tag(:th, "En consultation") +
      content_tag(:th, "Engagées") +
      content_tag(:th, "En cours PA") +
      content_tag(:th, "Réalisées PA") +
      content_tag(:th, "En cours RAR") +
      content_tag(:th, "Réalisées RAR") +
      content_tag(:th, "À l'arrêt") +
      content_tag(:th, "Clôturé")
    end
  end

  # =========================
  # TBODY + DATA CHART
  # =========================
  process_data
    .select { |_, v| trackers.include?(v[:tracker_id].to_i) }
    .each_with_index do |(key, value), index|
      # ---- Données pour Chart.js
      
      
     
   data_chart[value[:tracker_id]] = {
  prevue: {
    nbr: value[:prevue][:nbr].to_f,
    consistance: value[:prevue][:consistance].to_f
  },

   prevue_hp: {
    nbr: value[:prevue_hp][:nbr].to_f,
    consistance: value[:prevue_hp][:consistance].to_f
  },

  non_entamer: {
    nbr: value[:non_entamer][:nbr].to_i,
    consistance: value[:non_entamer][:consistance].to_f
  },
  etude_en_cours: {
    nbr: value[:etude_en_cours][:nbr].to_i,
    consistance: value[:etude_en_cours][:consistance].to_f
  },
  etude_finalise: {
    nbr: value[:etude_finalise][:nbr].to_i,
    consistance: value[:etude_finalise][:consistance].to_f
  },
  consultation: {
    nbr: value[:consultation][:nbr].to_i,
    consistance: value[:consultation][:consistance].to_f
  },
  engager: {
    nbr: value[:engager][:nbr].to_i,
    consistance: value[:engager][:consistance].to_f
  },
  en_cours_pa: {
    nbr: value[:en_cours_pa][:nbr].to_i,
    consistance: value[:en_cours_pa][:consistance].to_f
  },
   en_cours_hp: {
    nbr: value[:en_cours_hp][:nbr].to_i,
    consistance: value[:en_cours_hp][:consistance].to_f
  },
  realiser_pa: {
    nbr: value[:realiser_pa][:nbr].to_i,
    consistance: value[:realiser_pa][:consistance].to_f
  },
   realiser_hp: {
    nbr: value[:realiser_hp][:nbr].to_i,
    consistance: value[:realiser_hp][:consistance].to_f
  },
  en_cours_rar: {
    nbr: value[:en_cours_rar][:nbr].to_i,
    consistance: value[:en_cours_rar][:consistance].to_f
  },
  realiser_rar: {
    nbr: value[:realiser_rar][:nbr].to_i,
    consistance: value[:realiser_rar][:consistance].to_f
  },
  arret_global: {
    nbr: value[:arret_global][:nbr].to_i,
    consistance: value[:arret_global][:consistance].to_f
  },
  cloturer: {
    nbr: value[:cloturer][:nbr].to_i,
    consistance: value[:cloturer][:consistance].to_f
  }
} if value[:tracker_id] == 6


      # ---- Ligne tableau
      table_content += content_tag(:tbody) do
        content_tag(:tr, class: index.even? ? 'even' : 'odd') do
          content_tag(:td, formatted_key_title(key), class: "action-cell") +
          content_tag(:td, display_data_v(key, value, :prevue, project)) +
          content_tag(:td, display_data_v(key, value, :non_entamer, project)) +
          content_tag(:td, display_data_v(key, value, :etude_en_cours, project)) +
          content_tag(:td, display_data_v(key, value, :etude_finalise, project)) +
          content_tag(:td, display_data_v(key, value, :consultation, project)) +
          content_tag(:td, display_data_v(key, value, :engager, project)) +
          content_tag(:td, display_data_v(key, value, :en_cours_pa, project)) +
          content_tag(:td, display_data_v(key, value, :realiser_pa, project)) +
          content_tag(:td, display_data_v(key, value, :en_cours_rar, project)) +
          content_tag(:td, display_data_v(key, value, :realiser_rar, project)) +
          content_tag(:td, display_data_v(key, value, :arret_global, project)) +
          content_tag(:td, display_data_v(key, value, :cloturer, project))
        end
      end
    end
  # =========================
  # DATA POUR JAVASCRIPT (Redmine 5.1)
  # =========================
  
  # Ajout des données sous forme JSON pour un usage en JavaScript
  
  
 
  table_content
end



#-------------- Fin methode display data----------------------
def process_pa(process_data,trackers,project)
    # Ajouter une ligne pour "Réseau ODN" au début de la table
     table_content = "".html_safe

  
  # Ajouter la partie THEAD
  table_content += content_tag(:thead) do

    
    content_tag(:tr) do
      concat(content_tag(:th, "", class: "Previsions", colspan: 2))
      concat(content_tag(:th, "Phase 1", class: "phase-etude", colspan: 3))
      concat(content_tag(:th, "Phase 2", class: "etat-realisation", colspan: 2))
    end +
    content_tag(:tr) do
      content_tag(:th, "Action", class: "action") +
      content_tag(:th, "Total", class: "objectf") +
      content_tag(:th, "Initialisation", class: "non-entamer") +
      
      content_tag(:th, "Classement_géo", class: "etude-en-cours") +
      content_tag(:th, "Recenssement approuvé", class: "etude-en-cours") +
      
      content_tag(:th, "Estimation", class: "etude-finalise") +
      content_tag(:th, "Validé", class: "en-consultation")
    end
  end
  
    process_data.select { |k, v| trackers.include?(v[:tracker_id].to_i) }
    .each_with_index.map do |(key, value), index|
      table_content += content_tag(:tbody) do
        content_tag(:tr,class: index.even? ? 'even' : 'odd') do
          content_tag(:td, formatted_key_title(key), class: "action-cell", style: "text-align: left;") +
            content_tag(:td, display_data_v(key,value,:prevue,project), class: "objectf-cell") +
            content_tag(:td, display_data_v(key,value,:non_entamer,project), class: "non-entamer-cell") +
             content_tag(:td, display_data_v(key,value,:engager,project), class: "etude-en-cours-cell") +
            content_tag(:td, display_data_v(key,value,:etude_en_cours,project), class: "etude-en-cours-cell") +
            content_tag(:td, display_data_v(key,value,:etude_finalise,project), class: "etude-finalise-cell") +
            content_tag(:td, display_data_v(key,value,:consultation,project), class: "en-consultation-cell")
         end.html_safe 
      end
        # Ajouter une ligne supplémentaire après la 4ème ligne avec un contenu spécifique
        #(index == 3 ? content_tag(:tr, content_tag(:td, "Réseau 4G", class: "action-cell", colspan: 11)) : '').html_safe
    end
  
    return table_content
  end


#  display la partie active *********************************************

  def display_process_actif(process_data,trackers,project)
    # Ajouter une ligne pour "Réseau ODN" au début de la table
     table_content = "".html_safe

  
  # Ajouter la partie THEAD
  table_content += content_tag(:thead) do

    
    content_tag(:tr) do
      concat(content_tag(:th, "Previsions", class: "Previsions", colspan: 2))
      concat(content_tag(:th, "Phase Etude", class: "phase-etude", colspan: 3))
      concat(content_tag(:th, "Phase péparation", class: "etat-realisation", colspan: 2))
      concat(content_tag(:th, "Phase deploiement", class: "etat-realisation", colspan: 7))
     
    end +
    content_tag(:tr) do
      content_tag(:th, "Action", class: "action") +
      content_tag(:th, "Objectf", class: "objectf") +
      content_tag(:th, "Non Entamer", class: "non-entamer") +
      content_tag(:th, "Etude en cours", class: "etude-en-cours") +
      content_tag(:th, "Etude finalisée", class: "etude-finalise") +
      content_tag(:th, "Preparation site", class: "en-consultation") +
      content_tag(:th, "site validé", class: "engagees") +
      content_tag(:th, "Demandes dotation", class: "en-cours-pa") +
      content_tag(:th, "Demandes installation", class: "realisees-pa") +
      content_tag(:th, "Demandes validées", class: "realisees-pa") +
      content_tag(:th, "Doté", class: "en-cours-rar") +
      content_tag(:th, "Installé", class: "realisees-rar") +
      content_tag(:th, "M.E.S", class: "arret")+
      content_tag(:th, "En exploitation", class: "cloture")
    end
  end
  
    process_data.select { |k, v| trackers.include?(v[:tracker_id].to_i) }
    .each_with_index.map do |(key, value), index|
      table_content += content_tag(:tbody) do
        content_tag(:tr,class: index.even? ? 'even' : 'odd') do
          content_tag(:td, key.to_s, class: "action-cell", style: "text-align: left;") +
            content_tag(:td, display_data_v(key,value,:prevue,project), class: "objectf-cell") +
            content_tag(:td, display_data_v(key,value,:non_entamer,project), class: "non-entamer-cell") +
            content_tag(:td, display_data_v(key,value,:etude_en_cours,project), class: "etude-en-cours-cell") +
            content_tag(:td, display_data_v(key,value,:etude_finalise,project), class: "etude-finalise-cell") +
            content_tag(:td, display_data_v(key,value,:preparation_site,project), class: "en-consultation-cell") +
            content_tag(:td, display_data_v(key,value,:site_valider,project), class: "engagees-cell") +
            content_tag(:td, display_data_v(key,value,:demande_dotaion,project), class: "en-cours-pa-cell") +
            content_tag(:td, display_data_v(key,value,:demande_installation,project), class: "realisees-pa-cell") +
            content_tag(:td, display_data_v(key,value,:demande_valider,project), class: "realisees-pa-cell") +
            content_tag(:td, display_data_v(key,value,:doter,project), class: "en-cours-rar-cell") +
            content_tag(:td, display_data_v(key,value,:installer,project), class: "realisees-rar-cell") +
            content_tag(:td, display_data_v(key,value,:mes,project), class: "arret-cell") +
            content_tag(:td, display_data_v(key,value,:en_exploitation,project), class: "cloture-cell")
        end.html_safe 
      end
        # Ajouter une ligne supplémentaire après la 4ème ligne avec un contenu spécifique
        #(index == 3 ? content_tag(:tr, content_tag(:td, "Réseau 4G", class: "action-cell", colspan: 11)) : '').html_safe
    end
  
    return table_content
  end




# methode Display projects centraux

def normalise_data_central(process_data)
  data_projects = process_data.to_h

  # Initialisation des structures de données
  data_tracker = {
    Contrat: {},
    Contrat_gre: {},
    Acquisition: {},
    Acquisition_realisation: {}
  }

   data_projects.each do |key, value|
    case key
    when :Contrat
      data_tracker[:Contrat] = {
        prevu: value.dig(:prevue, :nbr).to_i,
        non_entamer: value.dig(:non_entamer, :nbr).to_i,
        etude_en_cours: value.dig(:etude_en_cours, :nbr).to_i,
        etude_finalise: value.dig(:etude_finalise, :nbr).to_i,
        commission_cdc: value.dig(:preparation_site, :nbr).to_i,
        etablissement_cdc: value.dig(:site_valider, :nbr).to_i,
        cdc_approuve: value.dig(:demande_valider, :nbr).to_i,
        phase_consultation: value.dig(:consultation, :nbr).to_i,
        visa_ccm_accordee: value.dig(:demande_installation, :nbr).to_i,
        en_negociation: value.dig(:prestation_engager, :nbr).to_i,
        contrat_notifie: value.dig(:prestation_execution, :nbr).to_i

      
      }
    when :Contrat_gre
      data_tracker[:Contrat_gre] = {
         prevu: value.dig(:prevue, :nbr).to_i,
        non_entamer: value.dig(:non_entamer, :nbr).to_i,
        etude_en_cours: value.dig(:etude_en_cours, :nbr).to_i,
        etude_finalise: value.dig(:etude_finalise, :nbr).to_i,
        commission_gre_a_gre:  value.dig(:preparation_site, :nbr).to_i,
        etablissement_cdc: value.dig(:site_valider, :nbr).to_i,
        gre_a_gre_approuve: value.dig(:demande_valider, :nbr).to_i,
        phase_consultation: value.dig(:consultation, :nbr).to_i,
        contrat_notifie: value.dig(:prestation_execution, :nbr).to_i}
     
    when :Acquisition
      data_tracker[:Acquisition] =  {
        prevu: value.dig(:prevue, :nbr).to_i,
        non_entamer: value.dig(:non_entamer, :nbr).to_i,
        en_progression: value.dig(:en_cours_pa, :nbr).to_i,
        en_defficulter: value.dig(:en_cours_rar, :nbr).to_i,
        en_preparation: value.dig(:mes, :nbr).to_i,
        pret_au_lancement: value.dig(:engager, :nbr).to_i,
        en_execution: value.dig(:demande_dotaion, :nbr).to_i,
        receptionner: value.dig(:en_exploitation, :nbr).to_i,
        montant_notifier: value.dig(:non_entamer, :consistance).to_d,
        montant_engager: value.dig(:en_cours_pa, :consistance).to_d,
        non_lancer: value.dig(:demande_installation, :consistance).to_i,
        en_cours:  value.dig(:demande_valider, :consistance).to_i,
        achever: value.dig(:doter, :consistance).to_i
      }
    when :Acquisition_realisation
     
   data_tracker[:Acquisition_realisation] = {
  prevu: value.dig(:prevue, :nbr).to_i,
  non_entamer: value.dig(:non_entamer, :nbr).to_i,
  en_progression: value.dig(:en_cours_pa, :nbr).to_i,
  en_defficulter: value.dig(:en_cours_rar, :nbr).to_i,

  montant_notifier: value.dig(:non_entamer, :consistance).to_d,
  montant_engager: value.dig(:en_cours_pa, :consistance).to_d,
  non_lancer: value.dig(:demande_installation, :consistance).to_i,
  en_cours:  value.dig(:demande_valider, :consistance).to_i,
  achever: value.dig(:doter, :consistance).to_i,

  # Partie BC (prefix bc_)
  bc_en_preparation: value.dig(:mes, :nbr).to_i,
  bc_pret_au_lancement: value.dig(:engager, :nbr).to_i,
  bc_en_execution: value.dig(:demande_dotaion, :nbr).to_i,
  bc_receptionner: value.dig(:en_exploitation, :nbr).to_i,
  bc_achever: value.dig(:prestation_achever, :nbr).to_i,

  # Partie Prestation (prefix prestation_)
  prestation_en_preparation: value.dig(:prestation_preparation, :nbr).to_i,
  prestation_pret_au_lancement: value.dig(:prestation_engager, :nbr).to_i,
  prestation_en_execution: value.dig(:prestation_execution, :nbr).to_i,
  prestation_receptionner: value.dig(:en_exploitation, :nbr).to_i,
  prestation_achever: value.dig(:prestation_achever, :nbr).to_i

  
} 
 
      end
  end

  

   return data_tracker
end



def query_link(key, sup_hash, sub_key, project)
    # Table de correspondance pour tracker_id
    tracker_ids = {
      Contrat: 14,
      Contrat_gre: 72,
      Acquisition: 21,
      Acquisition_realisation: {
        default: 68,
        bc_: 69,
        prestation_: 71
      }

    }
  
    # Table de correspondance pour query_id
    query_ids = {
      Contrat: {
        prevu: nil, non_entamer: 2007, etude_en_cours: 2006,
        etude_finalise: 2006, commission_cdc: 2008, etablissement_cdc: 2009,
        cdc_approuve: 2010, phase_consultation: 2011, visa_ccm_accordee: 2012
      },
      Contrat_gre: {
        prevu: 1995, non_entamer: 1995, etude_en_cours: nil,
        etude_finalise: nil, commission_cdc: nil, etablissement_cdc: nil,
        cdc_approuve: nil, phase_consultation: nil, ontrat_notifie: nil
      },
      Acquisition: {
        prevu: 1995, non_entamer: 1995, en_progression: 1995,
        en_defficulter: nil, en_preparation: nil, pret_au_lancement: nil,
        en_execution: nil, receptionner: nil
      },
      Acquisition_realisation: {
        prevu: 1995, non_entamer: 1995, en_progression: 1995, en_defficulter: 100,
        bc_en_preparation: 1995, bc_pret_au_lancement: nil, bc_en_execution: nil, bc_receptionner: nil,
        prestation_en_preparation: 1995, prestation_pret_au_lancement: nil, prestation_en_execution: nil, prestation_achever: nil
      }
    }
  
    # Détermination du tracker_id
    tracker_id = case key
                 when :Acquisition_realisation
                   prefix = sub_key.to_s[/^bc_|^prestation_/] # Récupère 'bc_' ou 'prestation_' si présent
                 
                 tracker_ids[:Acquisition_realisation].fetch(prefix&.to_sym, tracker_ids[:Acquisition_realisation][:default])

                 else
                   tracker_ids[key]
                 end
  
    # Détermination du query_id
    query_id = query_ids.dig(key, sub_key)
  
    # Génération du lien
    link_to sup_hash[sub_key].to_i,
            project_issues_path(project, query_id ? { query_id: query_id } : { set_filter: 1, tracker_id: tracker_id }),
            class: "objectf-cell", target: "_blank"
  end
# methode Display projects centraux
 


  def display_contrat(process_data, project)
    result_data = normalise_data_central(process_data).deep_dup
    table_content = "".html_safe
 
# Définition des colonnes avec leurs classes CSS associées
         sub_headers = [
  { key: :prevu, label: "Prévu", class: "objectf" },
  { key: :non_entamer, label: "Non entamé", class: "non-entamer" },
  { key: :etude_en_cours, label: "Étude en cours", class: "etude-en-cours" },
  { key: :etude_finalise, label: "Étude finalisée", class: "etude-finalise" },
  { key: :commission_cdc, label: "Commission CDC", class: "en-consultation" },
  { key: :etablissement_cdc, label: "Établissement CDC", class: "engagees" },
  { key: :cdc_approuve, label: "CDC approuvé", class: "realisees-pa" },
  { key: :phase_consultation, label: "Phase consultation", class: "realisees-pa" },
  { key: :visa_ccm_accordee, label: "VISA CCM accordée", class: "realisees-pa" },
  { key: :en_negociation, label: "En optimisation", class: "realisees-pa" },
  { key: :contrat_notifie, label: "Contrat notifiée", class: "realisees-pa" }]
       
         # Ajouter le THEAD avec les labels
    table_content += content_tag(:thead) do
      content_tag(:tr) do
        concat(content_tag(:th, "Prévisions", class: "Previsions", colspan: 2))
        concat(content_tag(:th, "Phase étude", class: "Previsions", colspan: 3))
        concat(content_tag(:th, "Phase CDC", class: "phase-etude", colspan: 3))
        concat(content_tag(:th, "Phase Administrative", class: "etat-realisation", colspan: 2))
        concat(content_tag(:th, "Sous action", class: "sous-action", rowspan: 2))
        concat(content_tag(:th, "Phase optimisation", class: "etat-realisation", colspan: 2))

      end +
      content_tag(:tr) do
        row_content = "".html_safe
        row_content += content_tag(:th, "Action", class: "action")
        
        
  
        # Génération automatique des colonnes
        sub_headers.each_with_index do |header, index|
          
          row_content += content_tag(:th, header[:label], class: header[:class])
        end
  
        row_content
      end
    end
  
    # Ajouter le TBODY avec les données
    table_content += content_tag(:tbody) do
      result_data.select { |key| key == :Contrat }.each_with_index.map do |(key, sub_hash), index|
        content_tag(:tr, class: index.even? ? 'even' : 'odd') do
          row_content = "".html_safe
          row_content += content_tag(:td, key.to_s, class: "action-cell", style: "text-align: left;")
  
          # Génération des cellules dynamiquement en utilisant sub_headers
          sub_headers.each_with_index do |header, index|
            row_content += content_tag(:td, "Négociation", class: "sous-action") if index == 9
            row_content += content_tag(:td, query_link(key, sub_hash, header[:key], project), class: "#{header[:class]}-cell")
          end
  
          row_content
        end
      end.join.html_safe
    end
  
    # Ajout des données sous forme JSON pour un usage en JavaScript
    chart_data_json = result_data.to_json
    table_content += content_tag(:div, chart_data_json.html_safe, id: "chart-data", style: "display: none;")
  
    table_content
  end
   # Partie gré a gré 
  def display_contrat_gre(process_data, project)
    result_data = normalise_data_central(process_data).deep_dup
    table_content = "".html_safe
 
# Définition des colonnes avec leurs classes CSS associées
         sub_headers = [
  { key: :prevu, label: "Prévu", class: "objectf" },
  { key: :non_entamer, label: "Non entamé", class: "non-entamer" },
  { key: :etude_en_cours, label: "Étude en cours", class: "etude-en-cours" },
  { key: :etude_finalise, label: "Étude finalisée", class: "etude-finalise" },
  { key: :commission_gre_a_gre, label: "Commission gré à gré", class: "en-consultation" },
  { key: :gre_a_gre_approuve, label: "Gré à gré approuvé", class: "realisees-pa" },
  { key: :etablissement_cdc, label: "Établissement CPT", class: "engagees" },
  { key: :phase_consultation, label: "Phase consultation", class: "realisees-pa" },
   { key: :contrat_notifie, label: "Contrat notifiée", class: "realisees-pa" }]  
         # Ajouter le THEAD avec les labels
    table_content += content_tag(:thead) do
      content_tag(:tr) do
        concat(content_tag(:th, "Prévisions", class: "Previsions", colspan: 2))
        concat(content_tag(:th, "Phase étude", class: "Previsions", colspan: 3))
        concat(content_tag(:th, "Phase CPT", class: "phase-etude", colspan: 3))
        concat(content_tag(:th, "Phase Administrative", class: "etat-realisation", colspan: 2))
       
      end +
      content_tag(:tr) do
        row_content = "".html_safe
        row_content += content_tag(:th, "Action", class: "action")
        
        
  
        # Génération automatique des colonnes
        sub_headers.each_with_index do |header, index|
          
          row_content += content_tag(:th, header[:label], class: header[:class])
        end
  
        row_content
      end
    end
  
    # Ajouter le TBODY avec les données
    table_content += content_tag(:tbody) do
      result_data.select { |key| key == :Contrat_gre }.each_with_index.map do |(key, sub_hash), index|
        content_tag(:tr, class: index.even? ? 'even' : 'odd') do
          row_content = "".html_safe
          row_content += content_tag(:td, key.to_s, class: "action-cell", style: "text-align: left;")
  
          # Génération des cellules dynamiquement en utilisant sub_headers
          sub_headers.each_with_index do |header, index|
            row_content += content_tag(:td, query_link(key, sub_hash, header[:key], project), class: "#{header[:class]}-cell")
          end
  
          row_content
        end
      end.join.html_safe
    end
  
    # Ajout des données sous forme JSON pour un usage en JavaScript
  
    table_content
  end

    
  # partie acquisition
  def display_acquisition(process_data, project)  # methode affichage tableau contrat 
    result_data = normalise_data_central(process_data).deep_dup
    table_content = "".html_safe
 
# Définition des colonnes avec leurs classes CSS associées
sub_headers = [
  { key: :prevu, label: "Prévu", class: "objectf" },
  { key: :non_entamer, label: "Non entamé", class: "non-entamer" },
  { key: :en_progression, label: "En progression", class: "etude-en-cours" },
  { key: :en_defficulter, label: "En difficulté", class: "etude-finalise" },
  { key: :en_preparation, label: "En préparation", class: "en-consultation" },
  { key: :pret_au_lancement, label: "Prêt au lancement", class: "engagees" },
  { key: :en_execution, label: "En exécution", class: "realisees-pa" },
  { key: :receptionner, label: "Réceptionné", class: "realisees-pa" }
]

    # Ajouter le THEAD avec les labels
    table_content += content_tag(:thead) do
      content_tag(:tr) do
        concat(content_tag(:th, "Prévisions", class: "Previsions", colspan: 2))
        concat(content_tag(:th, "Action Acquisition", class: "Previsions", colspan: 3))
        concat(content_tag(:th, "Sous action", class: "sous-action", rowspan: 2))
        concat(content_tag(:th, "Action BC/Lot", class: "bc_lot", colspan: 4))
        
      end +
      content_tag(:tr) do
        row_content = "".html_safe
        row_content += content_tag(:th, "Action", class: "action")
        
        
  
        # Génération automatique des colonnes
        sub_headers.each do |header|
          row_content += content_tag(:th, header[:label], class: header[:class])
        end
  
        row_content
      end
    end
  
    # Ajouter le TBODY avec les données
    table_content += content_tag(:tbody) do
      result_data.select { |key| key == :Acquisition }.each_with_index.map do |(key, sub_hash), index|
        content_tag(:tr, class: index.even? ? 'even' : 'odd') do
          row_content = "".html_safe
          row_content += content_tag(:td, key.to_s, class: "action-cell", style: "text-align: left;")
          
          # Génération des cellules dynamiquement en utilisant sub_headers
          sub_headers.each_with_index do |header, index|
            
            row_content += content_tag(:td, "BC/Lot", class: "sous-action") if index == 4
            row_content += content_tag(:td, query_link(key, sub_hash, header[:key], project), class: "#{header[:class]}-cell")
          end
  
          row_content
        end
      end.join.html_safe
    end

    table_content
  end   

  
 
   def display_acquisition_realisation(process_data, project)
  result_data = normalise_data_central(process_data).deep_dup
  table_content = "".html_safe

  sub_headers = [
     { label: "", class: "prevu" },
    { label: "Prévu", class: "prevu" },
    { label: "Non entamé", class: "non_entame" },
    { label: "En progression", class: "en_progression" },
    { label: "En difficulté", class: "en_difficulte" },
    { label: "En préparation", class: "en_preparation" },
    { label: "Prêt au lancement", class: "pret_au_lancement" },
    { label: "En exécution", class: "en_execution" },
    { label: "Réceptionné", class: "receptionne" },
    { label: "Achevé", class: "achever" }
  ]

  table_content += content_tag(:thead) do
    content_tag(:tr) do
      concat(content_tag(:th, "Action parente", class: "action-parente", colspan: 2))
      concat(content_tag(:th, "Statut parente", class: "statut-parente", colspan: 3))
      concat(content_tag(:th, "Sous action", class: "sous-action", rowspan: 2))
      concat(content_tag(:th, "Statut sous action", class: "statut-sous-action", colspan: 5))
    end +
    content_tag(:tr) do
      sub_headers.map { |header| content_tag(:th, header[:label], class: header[:class]) }.join.html_safe
    end
  end

  table_content += content_tag(:tbody) do
    result_data.select { |key| key == :Acquisition_realisation }.map.with_index do |(key, sub_hash), index|
      row_class = index.even? ? 'even' : 'odd'
      
      # Première ligne avec action principale et BC/Lot
      content_tag(:tr, class: row_class) do
        row = "".html_safe
        row += content_tag(:td, key.to_s, rowspan: 2, class: "action-main")
        row += [:prevu, :non_entamer, :en_progression, :en_difficulte].map do |status|
          content_tag(:td, query_link(key, sub_hash, status, project), rowspan: 2, class: status.to_s)
        end.join.html_safe
        
        row += content_tag(:td, "BC/Lot", class: "sous_action")
        row += [:bc_en_preparation, :bc_pret_au_lancement, :bc_en_execution, :bc_receptionner].map do |status|
          content_tag(:td, query_link(key, sub_hash, status, project), class: status.to_s)
        end.join.html_safe
        row += content_tag(:td, "", class: "achever", style: "background-color: #d3d3d3;")
        row
      end +
      
      # Deuxième ligne avec Prestation
      content_tag(:tr, class: row_class) do
        row = "".html_safe
        row += content_tag(:td, "Prestation", class: "sous_action")
        row += [:prestation_en_preparation, :prestation_pret_au_lancement, :prestation_en_execution].map do |status|
          content_tag(:td, query_link(key, sub_hash, status, project), class: status.to_s)
        end.join.html_safe
        row += content_tag(:td, "", class: "receptionne", style: "background-color: #d3d3d3;")
        row += content_tag(:td, query_link(key, sub_hash, :prestation_receptionner, project), class: "receptionne")
        row
      end
    end.join.html_safe
  end

  content_tag(:table, table_content, class: "custom-table")
end
 
  




def display_report_central(process_data, trackers, project)
  # Ajouter une ligne pour "Réseau ODN" au début de la table
  table_content = "".html_safe

  # Ajouter la partie THEAD
  table_content += content_tag(:thead) do
    content_tag(:tr) do
      concat(content_tag(:th, "Previsions", class: "Previsions", colspan: 2))
      concat(content_tag(:th, "Phase étude", class: "Previsions", colspan: 3)) if trackers.include?(14)
      concat(content_tag(:th, "Phase CDC", class: "phase-etude", colspan: 3)) if trackers.include?(14)
      concat(content_tag(:th, "Phase Contrat", class: "etat-realisation", colspan: 2)) if trackers.include?(14)
      concat(content_tag(:th, "Action acquisition", class: "etat-realisation", colspan: 2)) if (trackers & [21, 68]).any?
      concat(content_tag(:th, "Suivi BC/Lot", class: "etat-realisation", colspan: 4)) if (trackers & [21, 68]).any?
    end +
    content_tag(:tr) do
      row_content = "".html_safe
      row_content += content_tag(:th, "Action", class: "action")
      row_content += content_tag(:th, "Nbr actions", class: "objectf")
      row_content += content_tag(:th, "Non Entamer", class: "non-entamer")
      row_content += content_tag(:th, "En execution", class: "non-entamer") if (trackers & [21, 68]).any?
      row_content += content_tag(:th, "Etude en cours", class: "etude-en-cours") if trackers.include?(14)
      row_content += content_tag(:th, "Etude finalisée", class: "etude-finalise") if trackers.include?(14)
      row_content += content_tag(:th, "En préparation", class: "engagees") if (trackers & [21, 68]).any?
      row_content += content_tag(:th, "prét au lancement", class: "engagees") if (trackers & [21, 68]).any?
      row_content += content_tag(:th, "En execution", class: "engagees") if (trackers & [21, 68]).any?
      row_content += content_tag(:th, "Réceptioné", class: "engagees") if (trackers & [21, 68]).any?
      row_content += content_tag(:th, "Commision CDC", class: "en-consultation") if trackers.include?(14)
      row_content += content_tag(:th, "Etablissement CDC", class: "engagees") if trackers.include?(14)
      row_content += content_tag(:th, "CDC approuvé", class: "en-cours-pa") if trackers.include?(14)
      row_content += content_tag(:th, "Phase consultation", class: "realisees-pa") if trackers.include?(14)
      row_content += content_tag(:th, "Contrat notifié", class: "realisees-pa") if trackers.include?(14)
      row_content
    end
  end

  # Ajouter les données du TBody
  process_data.select { |_, value| trackers.include?(value[:tracker_id].to_i) }
              .each_with_index do |(key, value), index|
    table_content += content_tag(:tbody) do
      content_tag(:tr, class: index.even? ? 'even' : 'odd') do
        row_content = "".html_safe
        row_content += content_tag(:td, key.to_s, class: "action-cell", style: "text-align: left;")
        row_content += content_tag(:td, display_data_v(key, value, :prevue, project), class: "objectf-cell")
        row_content += content_tag(:td, display_data_v(key, value, :non_entamer, project), class: "non-entamer-cell")
        row_content += content_tag(:td, display_data_v(key, value, :installer, project), class: "realisees-rar-cell") if (trackers & [21, 68]).any?
        row_content += content_tag(:td, display_data_v(key, value, :etude_en_cours, project), class: "etude-en-cours-cell") if trackers.include?(14)
        row_content += content_tag(:td, display_data_v(key, value, :etude_finalise, project), class: "etude-finalise-cell") if trackers.include?(14)
        row_content += content_tag(:td, display_data_v(key, value, :mes, project), class: "arret-cell") if (trackers & [21, 68]).any?
        row_content += content_tag(:td, display_data_v(key, value, :engager, project), class: "engagees-cell") if (trackers & [21, 68]).any?
        row_content += content_tag(:td, display_data_v(key, value, :demande_dotaion, project), class: "en-cours-pa-cell") if (trackers & [21, 68]).any?
        row_content += content_tag(:td, display_data_v(key, value, :en_exploitation, project), class: "cloture-cell") if (trackers & [21, 68]).any?
        row_content += content_tag(:td, display_data_v(key, value, :preparation_site, project), class: "en-consultation-cell") if trackers.include?(14)
        row_content += content_tag(:td, display_data_v(key, value, :site_valider, project), class: "engagees-cell") if trackers.include?(14)
        row_content += content_tag(:td, display_data_v(key, value, :demande_valider, project), class: "realisees-pa-cell") if trackers.include?(14)
        row_content += content_tag(:td, display_data_v(key, value, :consultation, project), class: "en-consultation-cell") if trackers.include?(14)
        row_content += content_tag(:td, display_data_v(key, value, :demande_installation, project), class: "realisees-pa-cell") if trackers.include?(14)
        row_content
      end
    end
  end

  table_content
end


















  #  Display par DOT***************************************
  
 def display_process_dot(process_data_dot)
  # Ajouter une ligne pour "Réseau ODN" au début de la table
   table_content = "".html_safe

   table_content += content_tag(:thead) do

    
    content_tag(:tr) do
     
      concat(content_tag(:th, "", class: "Previsions", colspan: 2))
      concat(content_tag(:th, "ODN Developpement", class: "Previsions", colspan: 7))
      concat(content_tag(:th, "ODN Modernisation", class: "etat-realisation", colspan: 7))
      concat(content_tag(:th, "Evaluation", class: "etat-realisation", colspan: 1))
      
     
    end +
    content_tag(:tr) do
      content_tag(:th, "N°", class: "dot") +
      content_tag(:th, "DOT", class: "dot") +
      content_tag(:th, "Prevue", class: "prevue") +
      content_tag(:th, "Etude finalisée", class: "etude-finalise sortable-header",id: "col-3", data: { sort_direction: "asc" }) +
      content_tag(:th, "En cours PA", class: "en-cours-pa") +
      content_tag(:th, "En cours RAR", class: "en-cours-rar") +
      content_tag(:th, "Realisé PA", class: "realisees-pa sortable-header",id: "col-6", data: { sort_direction: "asc" }) +
      content_tag(:th, "Realisé RAR", class: "realisees-rar sortable-header",id: "col-7", data: { sort_direction: "asc" }) +
      content_tag(:th, "Total Dev", class: "realisees-rar sortable-header",id: "col-8", data: { sort_direction: "asc" }) +
      content_tag(:th, "Prevue", class: "prevue") +
      content_tag(:th, "Etude finalisée", class: "etude-finalise sortable-header",id: "col-10", data: { sort_direction: "asc" }) +
      content_tag(:th, "En cours", class: "en-cours-pa") +
      content_tag(:th, "En cours RAR", class: "en-cours-rar") +
      content_tag(:th, "Realisé PA", class: "realisees-pa sortable-header",id: "col-13", data: { sort_direction: "asc" }) +
      content_tag(:th, "Realisé RAR", class: "realisees-rar sortable-header",id: "col-14", data: { sort_direction: "asc" }) +
      content_tag(:th, "Total Mod", class: "realisees-rar sortable-header",id: "col-15", data: { sort_direction: "asc" })+
      content_tag(:th, class: "evaluation_pa") do
        evaluation_options = [['', ''],['T.PA Dev', 1], ['C.Dev PA', 2],
        ['T.PA Mod', 3],['C.Mod PA', 4], 
        ['T.PA Dev&Mod', 5],['C.Dev&Mod PA', 6], 
        ['T.Total Dev', 7],['C.Total Dev', 8], 
        ['T.Total Mod', 9],['C.Total Mod', 10], 
        ['T.Total', 11],['C.Total Dev&Mod', 12] ]
        select_tag 'evaluation', options_for_select(evaluation_options), class: 'evaluation-dropdown'
      end
      
      
  end
end
  

process_data_dot.each_with_index.map do |(key, value), index|
  
  table_content += content_tag(:tbody) do
    content_tag(:tr,class: index.even? ? 'even' : 'odd') do
      content_tag(:td, "" , class: "action-cell") +
      content_tag(:td, dot_name(key), class: "action-cell",id:"dot_0", style: "text-align: left;") +
        content_tag(:td, display_data_dot(value[:ODN_Dev],:prevue), class: "objectf-cell",id:"dot_1") +
        content_tag(:td, progress_bar_dot(display_data_dot(value[:ODN_Dev], :etude_finalise)).html_safe, class: "etude-finalise-cell",id:"dot_2") +
        content_tag(:td, display_data_dot(value[:ODN_Dev],:en_cours_pa), class: "en-cours-pa-cell",id:"dot_3") +
        content_tag(:td, display_data_dot(value[:ODN_Dev],:en_cours_rar), class: "en-cours-rar-cell",id: "dot_4") +
        content_tag(:td, display_data_dot(value[:ODN_Dev],:realiser_pa), class: "realisees-pa-cell",id: "dot_5") +
        content_tag(:td, display_data_dot(value[:ODN_Dev],:realiser_rar), class: "realisees-rar-cell",id: "dot_6") +
        content_tag(:td, display_data_dot(value[:ODN_Dev],:total), class: "total-cell",id: "dot_7") +
        content_tag(:td, display_data_dot(value[:ODN_Mod],:prevue), class: "objectf-cell",id: "dot_8") +
        content_tag(:td, progress_bar_dot(display_data_dot(value[:ODN_Mod], :etude_finalise)).html_safe, class: "etude-finalise-cell",id: "dot_9") +
        content_tag(:td, display_data_dot(value[:ODN_Mod],:en_cours_pa), class: "en-cours-pa-cell",id: "dot_10") +
        content_tag(:td, display_data_dot(value[:ODN_Mod],:en_cours_rar), class: "en-cours-rar-cell",id: "dot_11") +
        content_tag(:td, display_data_dot(value[:ODN_Mod],:realiser_pa), class: "realisees-pa-cell",id: "dot_12") +
        content_tag(:td, display_data_dot(value[:ODN_Mod],:realiser_rar), class: "realisees-rar-cell",id: "dot_13") +
        content_tag(:td, display_data_dot(value[:ODN_Mod],:total), class: "total-cell",id: "dot_14")+
        content_tag(:td, "***", class: "evaluation_cell",id: "dot_15")
       
    end.html_safe 
  end
    
end

return table_content
end




def display_racc_data(data,type)
   if type == :objectif_racc
     return  "#{number_with_delimiter(data[0],delimiter: " ", separator: ",")} (#{number_to_percentage(data[1], precision: 0)})"
 
   elsif type == :realiser_racc
        return  "#{number_with_delimiter(data[2],delimiter: " ", separator: ",")}  (#{number_to_percentage(data[3], precision: 1)})"

    #{(data_objectif[0].to_i == 0 ? 0 : (data_realiser[0] / data_objectif[0]) * 100).to_i}%- #{number_with_delimiter(data_realiser[1],delimiter: " ", separator: ",")} #{(data_objectif[1].to_i == 0 ? 0 : (data_realiser[1] / data_objectif[1]) * 100).to_i}%"
   end  

end

  private
  def progress_bar_dot(value)
    content_tag(:div, class: "progress") do
      content_tag(:div, class: "progress-bar", role: "progressbar", "data-value" => value, "aria-valuemin" => "0", "aria-valuemax" => "100") do
        content_tag(:span, "#{value}%", class: "progress-value")
      end
    end
  end
  
  
  
  def formatted_key_title(key)
    case key.to_s
    when 'ODN_Dev', 'ODN_Mod'
      title = "#{key.to_s+ ' '} (nbr-cap)"
    when 'Canalisation'
      title = "#{key.to_s + ' '} (nbr-Km/al)"
    when 'Racc_clients'
      title = "#{key.to_s+ ' '} (nbr_ftth-cuivre)"
    else
      title = "#{key.to_s+ ' '} (nbr)"
    end

    ("<span>" + key.to_s + "</span><span style='font-size: smaller; color: #777;'>" + title.gsub(key.to_s, '') + "</span>").html_safe
  end

  
  def dot_name(key)
  project = Project.find(key.to_i)
   dot_name = { 
    276 => "Adrar",278 => "Aïn Defla",279 =>  "In Salah",280 =>  "Aïn Témouchent",281 =>  "Alger centre",282 =>  "Alger est",283 =>  "Alger ouest",284 =>  "Annaba",285 =>  "B.B.A",
      287 =>  "B.B.M",288 =>  "Batna",289 =>  "Béchar",290 =>  "Béjaïa",291 =>  "Béni Abbès",292 =>  "Biskra",293 =>  "Blida",294 =>  "Bouira",295 =>  "Boumerdès",296 =>  "Chlef",297 =>  "Constantine",
      298 =>  "Djanet",299 =>  "Djelfa", 300 =>  "El Bayadh",301 =>  "El Meniaa",302 =>  "El M'Ghair",303 =>  "El Oued",304 =>  "El Tarf",305 =>  "Ghardaïa",306 =>  "Guelma",307 =>  "Illizi",
      308 =>  "In Guezzam",309 =>  "Jijel",310 =>  "Khenchela",311 =>  "Laghouat",312 =>  "M'Sila",313 =>  "Mascara",314 =>  "Médéa",315 =>  "Mila",316 =>  "Mostaganem",317 =>  "Naâma",318 =>  "O.E.B",
      319 =>  "Oran",320 =>  "Ouargla",321 =>  "Ouled Djellal",322 =>  "Relizane",323 =>  "S.B.A",324 =>  "Saïda",325 =>  "Sétif",326 =>  "Skikda",327 =>  "Souk Ahras",328 =>  "Tamanrasset",
      329 =>  "Tébessa",330 =>  "Tiaret",331 =>  "Tindouf",332 =>  "Timimoun",333 =>  "Tipaza",334 =>  "Tissemsilt",335 =>  "Tizi Ouzou",336 =>  "Tlemcen",337 =>  "Touggourt" ,
      343 => "Adrar",344 => "Aïn Defla",345 => "Aïn Témouchent",346 => "Alger centre",347 => "Alger est",348 => "Alger ouest",349 => "Annaba",350 => "B.B.A",351 => "B.B.M",352 => "Batna",
      353 => "Béchar",354 => "Béjaïa",355 => "Béni Abbès",356 => "Biskra",357 => "Blida",358 => "Bouira",360 => "Boumerdès",361 => "Chlef",362 => "Constantine",363 => "Djanet",364 => "Djelfa",
      365 => "El Bayadh",366 => "El M'Ghair",367 => "El Meniaa",368 => "El Oued",369 => "El Tarf",370 => "Ghardaïa",371 => "Guelma",372 => "Illizi",373 => "In Guezzam",374 => "In Salah",375 => "Jijel",
      376 => "Khenchela",377 => "Laghouat",378 => "M'Sila",379 => "Mascara",380 => "Médéa",381 => "Mila",382 => "Mostaganem",383 => "Naâma",384 => "O.E.B",385 => "Oran",386 => "Ouargla",387 => "Ouled Djellal",
      388 => "Relizane",389 => "S.B.A",390 => "Saïda",391 => "Sétif",392 => "Skikda",393 => "Souk Ahras",394 => "Tamanrasset",395 => "Tébessa",396 => "Tiaret",397 => "Timimoun",398 => "Tindouf",399 => "Tipaza",
      400 => "Tissemsilt",401 => "Tizi Ouzou",402 => "Tlemcen",403 => "Touggourt",405 => "Adrar",
  406 => "Ain Defla",407 => "Ain Témouchent",408 => "Alger centre",
  409 => "Alger est",
  410 => "Alger ouest",
  411 => "Annaba",
  412 => "B.B.A",
  413 => "B.B.M",
  414 => "Batna",
  415 => "Béchar",
  416 => "Béjaia",
  417 => "Béni Abbas",
  418 => "Biskra",
  419 => "Blida",
  420 => "Bouira",
  421 => "Boumerdés",
  422 => "Chlef",
  423 => "Constantine",
  424 => "Djanet",
  425 => "Djelfa",
  426 => "El Bayadh",
  427 => "El M'Ghair",
  428 => "El Meniaa",
  429 => "El Oued",
  430 => "El Tarf",
  431 => "Ghardaia",
  432 => "Guelma",
  433 => "Illizi",
  434 => "In Guezzam",
  435 => "In Salah",
  436 => "Jijel",
  437 => "Khenchela",
  438 => "Laghouat",
  439 => "M'sila",
  440 => "Mascara",
  441 => "Médéa",
  442 => "Mila",
  443 => "Mostaganem",
  444 => "Naâma",
  445 => "O.E.B",
  446 => "Oran",
  447 => "Ouargla",
  448 => "Ouled Djellal",
  449 => "Relizane",
  450 => "S.B.A",
  451 => "Saïda",
  452 => "Sétif",
  453 => "Skikda",
  454 => "Souk Ahras",
  455 => "Tamanrasset",
  456 => "Tébessa",
  457 => "Tiaret",
  458 => "Timimoun",
  459 => "Tindouf",
  460 => "Tipaza",
  461 => "Tissemsilt",
  462 => "Tizi Ouzou",
  463 => "Tlemcen",
  464 => "Touggourt"}
   if project

     return link_to dot_name[key.to_i],project_path(project),target: "_blank"
   else 
    return  dot_name[key.to_i]

   end

  
  end

  def display_data_dot(hash, value)
    if hash.is_a?(Hash)
      
      
      if value ==  :etude_finalise
          hash[:prevue][:nbr].to_i == 0 ? "-" : "#{(hash[value][:nbr].to_i * 100 / hash[:prevue][:nbr].to_i).round(1)}"
      elsif value == :total
          "#{number_with_delimiter((hash[:realiser_pa][:consistance].to_i + hash[:realiser_rar][:consistance].to_i),delimiter: " ", separator: ",")}"
      else
        "#{number_with_delimiter(hash[value][:consistance].to_i,delimiter: " ", separator: ",")}"
      end
            

    end
  end
  
  def display_data(key,value)
    if value.is_a?(Hash) && [:ODN_Dev,:ODN_Mod].include?(key)
      "#{number_with_delimiter(value[:nbr].to_i,delimiter: " ", separator: ",")} - #{number_with_delimiter(value[:consistance].to_i,delimiter: " ", separator: ",")}"
    else
      number_with_delimiter(value[:nbr].to_i,delimiter: " ", separator: ",")
    end
  end

  
  def display_data_v(key, value, value_key, project)
    return unless value[value_key].is_a?(Hash)
  
    query_key = {
      "Etude_FTTx_APS" => {
        :prevue => 1372,
        :non_entamer => 1373,
        :etude_en_cours => 1374,
        :etude_finalise => 1375,
        :cloturer => 1376
      },
      :ODN_Dev => {
        :prevue => 1378,
        :non_entamer => 1379,
        :etude_en_cours => 1384,
        :etude_finalise => 1398,
        :consultation => 1386,
        :engager => 1387,
        :en_cours_pa => 1390,
        :en_cours_rar => 1401,
        :realiser_pa => 1391,
        :realiser_rar => 1402,
        :arret_global => 1392,
        :cloturer => 1393
      },
      :ODN_Mod => {
        :prevue => 1395,
        :non_entamer => 1396,
        :etude_en_cours => 1397,
        :etude_finalise => 1385,
        :consultation => 1399,
        :engager => 1400,
        :en_cours_pa => 1403,
        :en_cours_rar => 1404,
        :realiser_pa => 1405,
        :realiser_rar => 1406,
        :arret_global => 1407,
        :cloturer => 1408
      },
      :Canalisation => {
        :prevue => 1409,
        :non_entamer => 1410,
        :etude_en_cours => 1411,
        :etude_finalise => 1412,
        :consultation => 1413,
        :engager => 1415,
        :en_cours_pa => 1416,
        :en_cours_rar => 1417,
        :realiser_pa => 1418,
        :realiser_rar => 1419,
        :arret_global => 1420,
        :cloturer => 1421
      },
      :Pose_fo => {
        :prevue => 1444,
        :non_entamer => 1447,
        :etude_en_cours => 1448,
        :etude_finalise => 1449,
        :consultation => 1451,
        :engager => 1452,
        :en_cours_pa => 1453,
        :en_cours_rar => 1454,
        :realiser_pa => 1455,
        :realiser_rar => 1456,
        :arret_global => 1457,
        :cloturer => 1458},

      "PA_Mod" => {
         :prevue => 1527,
        :non_entamer => 1793,
        :etude_en_cours => 1792,
        :etude_finalise => 1530,
        :consultation => 1532 },

        "PA_Dev" => {
         :prevue => 1804,
        :non_entamer => 1546,
        :etude_en_cours => 1549,
        :etude_finalise => 1550,
        :consultation => 1552, 
        :engager => 2158},

        "PA_FO" => {
         :prevue => 1822,
        :non_entamer => 1823,
        :etude_finalise => 1824,
        :consultation => 1825 }


    }
  
    query_value = query_key.dig(key, value_key)
  
    content = case key
              when :ODN_Dev,:ODN_Mod,"PA_Mod","PA_Dev"

                "#{number_with_delimiter(value[value_key][:nbr].to_i,delimiter: " ", separator: ",")} - #{number_with_delimiter(value[value_key][:consistance].to_i,delimiter: " ", separator: ",")}"
              when :Canalisation,:Pose_fo, "PA_FO"
                "#{number_with_delimiter(value[value_key][:nbr].to_i,delimiter: " ", separator: ",")} - #{number_with_delimiter(number_with_precision(value[value_key][:consistance].to_d, precision: 2), delimiter: " ", separator: ",")}"
              
                           
              else
                "#{number_with_delimiter(value[value_key][:nbr].to_i,delimiter: " ", separator: ",")}"
              end
  
    if query_value
      return link_to content, project_issues_path(project, :query_id => query_value.to_i), class: "objectf-cell", target: "_blank" if query_value.to_i.nonzero?
    else
       if value_key == :prevue
         return link_to content ,project_issues_path(project, :set_filter => 1, :tracker_id => value[:tracker_id]),target: "_blank"
       else
            return content
       end
   
    end
  
end





end
