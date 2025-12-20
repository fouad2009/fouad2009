namespace :journal_user do
  desc "Export historique des changements de statut des tickets (filtré par rôle, date, et projet)"
  task export_status_history: :environment do
    output_file = "status_history.csv"
    role_id_filter = 3 # ID du rôle spécifique à filtrer
      max_lines = 50000  # Limite maximale du nombre de lignes à extraire
    filter_date = Date.parse("2024-01-01") # Date minimale de modification
   line_count = 0 
    CSV.open(output_file, "w", col_sep: ";", encoding: "UTF-8") do |csv|
      # Ajouter une ligne BOM pour forcer l'encodage UTF-8
      csv << ["\xEF\xBB\xBF"]

      # Ajouter les en-têtes
      csv << ["Tracker", "Ticket ID", "Statut", "Date de Modification", "Utilisateur", "Rôle", "Projet"]

      # Initialiser un compteur de lignes
      

      # Parcourir les journaux des tickets
      Journal.includes(:user, journalized: [:tracker, :status, :project])
             .where("created_on >= ?", filter_date) # Filtrer les journaux après la date donnée
             .find_each do |journal|
        # Charger les détails du journal depuis la table `journal_details`
        details = JournalDetail.where(journal_id: journal.id, prop_key: "status_id")

        details.each do |detail|
          tracker_name = journal.journalized.try(:tracker).try(:name)
          issue_id = journal.journalized_id
          change_date = journal.created_on
          user_name = journal.user.try(:login) || "Inconnu"
          status_name = IssueStatus.find_by(id: detail.value).try(:name) || "Inconnu" # Récupérer le statut du ticket
          project_name = journal.journalized.try(:project).try(:name) || "Inconnu" # Récupérer le nom du projet

          # Récupérer les rôles associés à l'utilisateur pour le projet concerné
          role_name = Role.joins(:members)
                          .where(members: { user_id: journal.user_id, project_id: journal.journalized.try(:project_id) })
                          .where(id: role_id_filter) # Appliquer le filtre par rôle
                          .pluck(:name).first

          # Si aucun rôle correspondant n'est trouvé, ignorer cette entrée
          next if role_name.nil?

          # Ajouter les données à la ligne CSV
          csv << [tracker_name, issue_id, status_name, change_date, user_name, role_name, project_name]
          line_count += 1

          # Vérifier si la limite maximale de lignes est atteinte
          break if line_count >= max_lines
        end

        # Interrompre la boucle principale si la limite est atteinte
        break if line_count >= max_lines
      end
    end

    puts "Historique exporté vers #{output_file} (#{line_count} lignes, filtré par rôle ID #{role_id_filter})"
  end
end

