namespace :journal  do
  desc "Export historique des changements de statut des tickets (après le 01-01-2024, filtré par tracker_id)"
  task export_status_history: :environment do
    output_file = "status_history.csv"
    max_lines = 100000             # Limite maximale du nombre de lignes à extraire
    filter_date = Date.parse("2024-01-01") # Date minimale de modification
    tracker_ids_filter = [7, 29, 42, 47, 58, 60] # Liste des tracker_id à filtrer

    # Précharger les mappages pour optimiser les performances
    status_map = IssueStatus.pluck(:id, :name).to_h
    project_map = Project.pluck(:id, :name).to_h
    line_count = 0

    CSV.open(output_file, "w", col_sep: ";", encoding: "UTF-8") do |csv|
      # Ajouter une ligne BOM pour forcer l'encodage UTF-8
      csv << ["\xEF\xBB\xBF"]

      # Ajouter les en-têtes
      csv << ["Tracker", "Ticket ID", "Statut", "Date de Modification", "Utilisateur", "Projet"]

      # Initialiser un compteur de lignes

      # Parcourir les journaux des tickets
      Journal.includes(:user, journalized: [:tracker, :project])
             .where("created_on >= ?", filter_date) # Filtrer les journaux après la date donnée
             .find_each do |journal|
        # Vérifier si le tracker_id correspond au filtre
        tracker = journal.journalized.try(:tracker)
        next unless tracker && tracker_ids_filter.include?(tracker.id)

        # Charger les détails du journal depuis la table `journal_details`
        details = JournalDetail.where(journal_id: journal.id, prop_key: "status_id")

        details.each do |detail|
          tracker_name = tracker.name
          issue_id = journal.journalized_id
          change_date = journal.created_on
          user_name = journal.user.try(:login) || "Inconnu"

          # Utiliser les mappages pour obtenir le statut et le projet
          status_name = status_map[detail.value.to_i] || "Inconnu"
          project_name = project_map[journal.journalized.try(:project_id)] || "Inconnu"

          # Ajouter les données à la ligne CSV
          csv << [tracker_name, issue_id, status_name, change_date, user_name, project_name]
          line_count += 1

          # Vérifier si la limite maximale de lignes est atteinte
          break if line_count >= max_lines
        end

        # Interrompre la boucle principale si la limite est atteinte
        break if line_count >= max_lines
      end
    end

    puts "Historique exporté vers #{output_file} (#{line_count} lignes après #{filter_date}, filtré par tracker_id #{tracker_ids_filter})"
  end
end

