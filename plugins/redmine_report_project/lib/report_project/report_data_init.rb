module ReportProject
  module ReportDataInit

    # =====================================================
    # Génération optimisée de la structure projet → tracker → issues
    # =====================================================
    # Méthode : calculate_for_project
    # Description : Extrait les données des issues visibles et ouvertes pour un projet parent
    # et les organise par projet → tracker → issue avec leurs champs personnalisés
    # 
    # Paramètres:
    #   - project_parent_id (Integer) : ID du projet parent pour lequel générer le rapport
    #
    # Retour:
    #   - Hash structuré : { project_id => { tracker_id => [issues] } }
    #
    def self.calculate_for_project(project_parent_id)
      # Assure que l'utilisateur courant est un administrateur pour éviter les erreurs de permission
      User.current = User.admin.first if User.current.anonymous?

      # Récupère le projet parent
      project = Project.find(project_parent_id)
      
      # Détermine si les sous-projets doivent être inclus selon les paramètres globaux
      with_subprojects = Setting.display_subprojects_issues?
      
      # Génère la condition SQL pour filtrer les issues du projet (et ses sous-projets si applicable)
      cond = project.project_condition(with_subprojects)
      
      # Récupère les IDs des trackers visibles pour ce projet (et ses sous-projets)
      tracker_ids = project.rolled_up_trackers(with_subprojects).visible.map(&:id)

      # Requête optimisée pour récupérer toutes les données nécessaires en une seule base de données
      # Utilise pluck pour ne charger que les colonnes nécessaires (améliore les performances)
      rows = Issue.visible.open
                  .where(cond)
                  .where(tracker_id: tracker_ids)
                  .joins(:custom_values)
                  .where(custom_values: {
                    custom_field_id: ReportProject::ReportSchema::CUSTOM_FIELDS_LIST
                  })
                  .pluck(
                    :project_id,
                    :id,
                    :tracker_id,
                    :status_id,
                    :done_ratio,
                    :estimated_hours,
                    'custom_values.custom_field_id',
                    'custom_values.value'
                  )

      # Initialise le dictionnaire pour stocker les données structurées
      data = {}

      # Traite chaque ligne retournée de la base de données
      rows.each do |row|
        # Destructure la ligne en variables individuelles
        project_id, issue_id, tracker_id, status_id,
        done_ratio, estimated_hours, cf_id, cf_value = row

        # Crée ou récupère le hash du projet dans la structure de données
        project_hash = (data[project_id] ||= {})
        
        # Crée ou récupère le hash du tracker pour ce projet
        tracker_hash = (project_hash[tracker_id] ||= {})
        
        # Crée ou récupère le hash de l'issue avec ses informations de base
        issue_hash   = (tracker_hash[issue_id] ||= {
          project_id: project_id,
          issue_id: issue_id,
          tracker_id: tracker_id,
          status_id: status_id,
          done_ratio: done_ratio,
          estimated_hours: estimated_hours
        })

        # Ajoute la valeur du champ personnalisé à l'issue
        # (Utilise l'ID du champ personnalisé comme clé et la valeur comme valeur)
        issue_hash[cf_id.to_i] = cf_value
      end

      # Normalisation finale : convertit la structure hiérarchique imbriquée
      # De : { project_id => { tracker_id => { issue_id => {données} } } }
      # À : { project_id => { tracker_id => [{données}, {données}, ...] } }
      data.transform_values! do |trackers|
        trackers.transform_values!(&:values)
      end

      data
    end

    # =====================================================
    # Construction finale de la structure métier
    # =====================================================
    # Méthode : build_report_data
    # Description : Construit la structure finale de rapport en traitant les données brutes
    # Récupère les données brutes du projet, puis traite chaque issue pour enrichir
    # les métriques du tracker (catégorie)
    #
    # Paramètres:
    #   - project_parent_id (Integer) : ID du projet parent pour lequel construire le rapport
    #
    # Retour:
    #   - Hash structuré contenant les métriques calculées par tracker
    #
    def self.build_report_data(project_parent_id)

      # Récupère les données brutes du projet (issues organisées par projet et tracker)
      data_project = calculate_for_project(project_parent_id)

      # Transforme les données brutes en structure de rapport final
      # Pour chaque tracker d'un projet, construit les métriques du rapport
      report_data = data_project.transform_values do |trackers_hash|
        trackers_hash.transform_values do |issues_array|

          # Initialise la structure de métriques pour le tracker courant
          # (contient les champs pour stocker les statistiques du rapport)
          tracker_struct =
            ReportProject::ReportSchema.build_category_metrics

          # Traite chaque issue pour mettre à jour les métriques du tracker
          # Le dispatcher applique la logique métier appropriée selon le type d'issue
          issues_array.each do |issue|
            ReportProject::Dispatcher::Process.process(issue, tracker_struct)
          end

          # Retourne la structure enrichie avec les métriques calculées pour ce tracker
          tracker_struct
        end
      end

      report_data
    end

  end
end
