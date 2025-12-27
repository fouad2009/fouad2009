module ReportProject
  module ReportDataInit 
  # Module de generation de la structure de donnée commune pour les projets
  def self.calculate_for_project(project_parent_id)
    User.current = User.admin.first if User.current.anonymous?
    project = Project.find(project_parent_id)
    with_subprojects = Setting.display_subprojects_issues?
    cond = project.project_condition(with_subprojects)
    tracker_ids = project.rolled_up_trackers(with_subprojects).visible.map(&:id)

    # Récupération des issues et custom_values
    issues = Issue.visible.open
                .where(cond)
                .where(tracker_id: tracker_ids)
                .includes(:custom_values)
                .where(custom_values: { custom_field_id: ReportSchema::CUSTOM_FIELDS_LIST})
                .pluck(:project_id, :id, :tracker_id, :status_id, :done_ratio, :estimated_hours,
                       'custom_values.custom_field_id', 'custom_values.value')
                .map do |ligne|
                  {
                    project_id: ligne[0],
                    issue_id: ligne[1],
                    tracker_id: ligne[2],
                    status_id: ligne[3],
                    done_ratio: ligne[4],
                    estimated_hours: ligne[5],
                    ligne[6].to_i => ligne[7]
                  }
                end

    # Regroupement par projet, puis tracker, puis fusion des données par issue_id
    data = issues.group_by { |h| h[:project_id] }
               .transform_values do |proj_issues|
                 proj_issues.group_by { |h| h[:tracker_id] }
                    .transform_values do |tracker_issues|
                      tracker_issues.group_by { |h| h[:issue_id] }
                          .map do |issue_id, issue_hashes|
                              # Fusion de tous les hashes pour la même issue_id
                              issue_hashes.inject(:merge).merge(issue_id: issue_id)
                          end
                    end
               end
    data
  
  end

  def self.build_report_data(project_parent_id)
  
    # Structure de base pour chaque état avec métriques à zéro
    base_struct = ReportProject::ReportSchema.build_state_metrics


    # Récupération des issues déjà regroupées et optimisées
     data_project = calculate_for_project(project_parent_id)
  
    # data_project => { project_id => { tracker_id => [ {issue_hash}, ... ] } }

    # Parcours et transformation pour appliquer la logique métier
   
     report_data = data_project.transform_values do |trackers_hash|
      
       trackers_hash.transform_values do |issues_array|
      
         # Pour chaque tracker, accumuler les données dans un clone de base_struct
      
         tracker_struct = base_struct.deep_dup

         issues_array.each do |issue|
          # Ici on applique la logique métier pour remplir tracker_struct
          # Par exemple, un pseudo-calcul selon status_id, done_ratio, scenario, etc.
        
           ReportProject::Dispatcher::Process.process(issue, tracker_struct)
         end

      tracker_struct
    end
  end

  report_data
end


end
end


