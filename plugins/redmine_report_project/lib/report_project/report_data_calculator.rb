# lib/report_project/report_data_calculator.rb
module ReportProject
  module ReportDataCalculator
    def self.synthese_data_issues(issue, tracker_struct)
      tracker_id = issue[:tracker_id]  # récupéré directement depuis l'issue
      # Logique métier selon le tracker
      case tracker_id
        when ReportProject::ReportSchema::TRACKERS[:aps]
        when ReportProject::ReportSchema::TRACKERS[:odn_mod]
        when ReportProject::ReportSchema::TRACKERS[:odn_dev]
    
        when ReportProject::ReportSchema::TRACKERS[:odn_service]
        
        when ReportProject::ReportSchema::TRACKERS[:canalisation]
        # Calcul spécifique Canalisation
        when ReportProject::ReportSchema::TRACKERS[:pose_fo]
        when ReportProject::ReportSchema::TRACKERS[:pa_4g]
	    when ReportProject::ReportSchema::TRACKERS[:olt]
	    when ReportProject::ReportSchema::TRACKERS[:carte_gpon]
	    when ReportProject::ReportSchema::TRACKERS[:corporate]
	    when ReportProject::ReportSchema::TRACKERS[:depose_cable]
      else
        # Calcul générique
      end
      # etc...
  end

  def normalize_aps(

  end

	  
  
end  
end 
