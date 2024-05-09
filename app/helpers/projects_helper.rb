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

def display_process_data(process_data,trackers,project)
    # Ajouter une ligne pour "Réseau ODN" au début de la table
     table_content = "".html_safe

  
  # Ajouter la partie THEAD
  table_content += content_tag(:thead) do

    
    content_tag(:tr) do
      concat(content_tag(:th, "Previsions PA", class: "Previsions", colspan: 2))
      concat(content_tag(:th, "Phase Etude PA", class: "phase-etude", colspan: 3))
      concat(content_tag(:th, "Phase Réalisation PA", class: "etat-realisation", colspan: 4))
      concat(content_tag(:th, "Réalisations RAR", class: "etat-realisation", colspan: 2))
      concat(content_tag(:th, "", class: "etat-realisation", colspan: 1))
      concat(content_tag(:th, "", class: "etat-realisation", colspan: 1))
    end +
    content_tag(:tr) do
      content_tag(:th, "Action", class: "action") +
      content_tag(:th, "Objectf", class: "objectf") +
      content_tag(:th, "Non Entamer", class: "non-entamer") +
      content_tag(:th, "Etude en cours", class: "etude-en-cours") +
      content_tag(:th, "Etude finalisée", class: "etude-finalise") +
      content_tag(:th, "En consultation", class: "en-consultation") +
      content_tag(:th, "Engagées", class: "engagees") +
      content_tag(:th, "En cours", class: "en-cours-pa") +
      content_tag(:th, "Realisées", class: "realisees-pa") +
      content_tag(:th, "En cours", class: "en-cours-rar") +
      content_tag(:th, "Realisées", class: "realisees-rar") +
      content_tag(:th, "à l'arrêt", class: "arret")+
      content_tag(:th, "Clôturé", class: "cloture")
    end
  end
  
    process_data.select { |k, v| trackers.include?(v[:tracker_id].to_i) }
    .each_with_index.map do |(key, value), index|
      table_content += content_tag(:tbody) do
        content_tag(:tr,class: index.even? ? 'even' : 'odd') do
          content_tag(:td, formatted_key_title(key), class: "action-cell", style: "text-align: left;") +
            content_tag(:td, display_data_v(key,value,:prevue,project), class: "objectf-cell") +
            content_tag(:td, display_data_v(key,value,:non_entamer,project), class: "non-entamer-cell") +
            content_tag(:td, display_data_v(key,value,:etude_en_cours,project), class: "etude-en-cours-cell") +
            content_tag(:td, display_data_v(key,value,:etude_finalise,project), class: "etude-finalise-cell") +
            content_tag(:td, display_data_v(key,value,:consultation,project), class: "en-consultation-cell") +
            content_tag(:td, display_data_v(key,value,:engager,project), class: "engagees-cell") +
            content_tag(:td, display_data_v(key,value,:en_cours_pa,project), class: "en-cours-pa-cell") +
            content_tag(:td, display_data_v(key,value,:realiser_pa,project), class: "realisees-pa-cell") +
            content_tag(:td, display_data_v(key,value,:en_cours_rar,project), class: "en-cours-rar-cell") +
            content_tag(:td, display_data_v(key,value,:realiser_rar,project), class: "realisees-rar-cell") +
            content_tag(:td, display_data_v(key,value,:arret_global,project), class: "arret-cell") +
            content_tag(:td, display_data_v(key,value,:cloturer,project), class: "cloture-cell")
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
        content_tag(:td, display_data_dot(value[:ODN_Dev],:total), class: "total-cell",id: "col-7",id: "dot_7") +
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



def display_racc_data(data_objectif,data_realiser,type)
   if type == :objectif_racc
        return  "#{number_with_delimiter(data_objectif[0],delimiter: " ", separator: ",")} - #{number_with_delimiter(data_objectif[1],delimiter: " ", separator: ",")}"
   elsif type == :realiser_racc
       return "#{number_with_delimiter(data_realiser[0],delimiter: " ", separator: ",")} - #{number_with_delimiter(data_realiser[1],delimiter: " ", separator: ",")}"

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
   276 => "Adrar",
   278 => "Aïn Defla",
   279 =>  "In Salah",
   280 =>  "Aïn Témouchent",
   281 =>  "Alger centre",
   282 =>  "Alger est",
   283 =>  "Alger ouest",
   284 =>  "Annaba",
   285 =>  "B.B.A",
   287 =>  "B.B.M",
   288 =>  "Batna",
   289 =>  "Béchar",
   290 =>  "Béjaïa",
   291 =>  "Béni Abbès",
   292 =>  "Biskra",
   293 =>  "Blida",
   294 =>  "Bouira",
   295 =>  "Boumerdès",
   296 =>  "Chlef",
   297 =>  "Constantine",
   298 =>  "Djanet",
   299 =>  "Djelfa",
   300 =>  "El Bayadh",
   301 =>  "El Meniaa",
   302 =>  "El M'Ghair",
   303 =>  "El Oued",
   304 =>  "El Tarf",
   305 =>  "Ghardaïa",
   306 =>  "Guelma",
   307 =>  "Illizi",
   308 =>  "In Guezzam",
   309 =>  "Jijel",
   310 =>  "Khenchela",
   311 =>  "Laghouat",
   312 =>  "M'Sila",
   313 =>  "Mascara",
   314 =>  "Médéa",
   315 =>  "Mila",
   316 =>  "Mostaganem",
   317 =>  "Naâma",
   318 =>  "O.E.B",
   319 =>  "Oran",
   320 =>  "Ouargla",
   321 =>  "Ouled Djellal",
   322 =>  "Relizane",
   323 =>  "S.B.A",
   324 =>  "Saïda",
   325 =>  "Sétif",
   326 =>  "Skikda",
   327 =>  "Souk Ahras",
   328 =>  "Tamanrasset",
   329 =>  "Tébessa",
   330 =>  "Tiaret",
   331 =>  "Tindouf",
   332 =>  "Timimoun",
   333 =>  "Tipaza",
   334 =>  "Tissemsilt",
   335 =>  "Tizi Ouzou",
   336 =>  "Tlemcen",
   337 =>  "Touggourt" }
   
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
        :cloturer => 1458


       }

    }
  
    query_value = query_key.dig(key, value_key)
  
    content = case key
              when :ODN_Dev,:ODN_Mod
                "#{number_with_delimiter(value[value_key][:nbr].to_i,delimiter: " ", separator: ",")} - #{number_with_delimiter(value[value_key][:consistance].to_i,delimiter: " ", separator: ",")}"
              when :Canalisation,:Pose_fo
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
