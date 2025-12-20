# lib/tasks/update_issues.rake

namespace :pa_dev do
  desc "Met à jour les issues avec une transaction unique et enregistre les logs dans log/info.log"
  task update_issues: :environment do
    
    # Méthode de log personnalisée (ajoute au fichier log/info.log et affiche dans la console)
    def log_and_puts(message)
      puts message
      File.open('log/info.log', 'a') do |file|
        file.puts("[#{Time.now}] #{message}")
      end
    end

    # Méthode pour construire les champs personnalisés de l'issue principale
    def build_custom_fields(devis_ODN:, devis_cana:, dist_cana:, old_custom_field_6:)
      {
        6   => old_custom_field_6.to_s != "PA-2024_reporté" ? "PA-2025" : "PA-2024_reporté",
        272 => devis_ODN,
        266 => devis_ODN > 1 ? "Budget_en_attend" : "Engagé_par-DO",
        21  => "Développement et extension de réseaux filaire et radio",
        68  => "Action interne DO",
        253 => 291
      }
    end

    # Méthode pour créer une issue CANA
    def create_issue_cana(parent_issue, devis_cana, dist_cana, programme_CANA)
      issue_cana = Issue.new(
        project_id: parent_issue.project_id.to_i,
        tracker_id: 4,
        subject: parent_issue.subject.to_s,
        status_id: 1,
        priority_id: parent_issue.priority_id.to_i,
        parent_id: parent_issue.id.to_i,
        author_id: 1
      )

      issue_cana.custom_field_values = {
        6   => parent_issue.custom_field_value(6),
        21  => "Développement et extension de réseaux filaire et radio",
        68  => "Action interne DO",
        253 => 291,
        272 => devis_cana,
        217 => dist_cana,
        352 => programme_CANA,
        266 => devis_cana > 1 ? "Budget_en_attend" : "Engagé_par-DO"
      }

      issue_cana
    end

    # Sélection des issues à traiter
    issues_mod = Issue.where(project_id: 405..464, status_id: 91, tracker_id: 64)

    # Démarrage de la transaction principale
    ActiveRecord::Base.transaction do
      issues_mod.each do |issue|
        begin
          devis_cana = issue.custom_field_value(297).to_d
          devis_ODN = issue.custom_field_value(296).to_d
          dist_cana = issue.custom_field_value(217).to_d
          programme_ODN = issue.custom_field_value(315).to_i
          programme_CANA = issue.custom_field_value(352).to_i

          # Mise à jour de l'issue principale
          issue.assign_attributes(
            tracker_id: 47,
            status_id: 1,
            custom_field_values: build_custom_fields(
              devis_ODN: devis_ODN,
              devis_cana: devis_cana,
              dist_cana: dist_cana,
              old_custom_field_6: issue.custom_field_value(6)
            )
          )

          if issue.save!
            log_and_puts "Issue #{issue.id} mise à jour avec succès."

            # Création de l'issue Beoin
            issue_beoin = Issue.new(
              project_id: issue.project_id.to_i,
              tracker_id: 66,
              subject: issue.subject.to_s,
              status_id: 1,
              parent_id: issue.id.to_i,
              author_id: 1
            )

            issue_beoin.save!

            # Création de l'issue CANA si la distance de la canalisation est différente de 0
            if dist_cana != 0
              issue_cana = create_issue_cana(issue, devis_cana, dist_cana, programme_CANA)
              if issue_cana.save!
                log_and_puts "Issue CANA #{issue_cana.id} créée avec succès."
              end
            end
          end
        
        rescue ActiveRecord::RecordInvalid => e
          log_and_puts "Échec de la mise à jour de l'issue #{issue.id} : #{e.record.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback, "Échec de la mise à jour de l'issue"
        rescue => e
          log_and_puts "Erreur lors du traitement de l'issue #{issue.id} : #{e.message}"
          raise ActiveRecord::Rollback, "Erreur de transaction"
        end
      end
    end

  puts "--------------- fin task -------------------"
  end
end


