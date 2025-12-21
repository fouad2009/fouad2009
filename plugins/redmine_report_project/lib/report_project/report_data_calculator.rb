# lib/report_project/report_data_calculator.rb
module ReportProject
  module ReportDataCalculator
    def self.synthese_data_issues(issue, tracker_struct, tracker_id)
      # Logique métier selon le tracker
      case tracker_id
      when ReportProject::ReportSchema::TRACKERS[:canalisation]
        # Calcul spécifique Canalisation
      when ReportProject::ReportSchema::TRACKERS[:pose_fo]
        # Calcul spécifique Pose FO
      else
        # Calcul générique
      end

      # Mise à jour des métriques dans tracker_struct
      tracker_struct[:planned][:count] += 1 if issue[:status_id] == 1
      tracker_struct[:completed_pa][:quantity] += issue[:done_ratio]
      # etc...
    end
  end
end
