# lib/report_project/report_data_calculator.rb
module ReportProject
  module ReportDataCalculator
    def self.synthese_data_issues(issue, tracker_struct)
      tracker_id = issue[:tracker_id]  # récupéré directement depuis l'issue
      # Logique métier selon le tracker
      case tracker_id
        when ReportProject::ReportSchema::TRACKERS[:aps]
          normalize_aps(issue,tracker_struct)
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
        # Calcul génériqu
      end
      # etc...
  end

  def normalize_aps(issue,tracker_struct)
   
    status  = issue[:status]
    ratio = issue[:done_ratio]

    6 #-- Exercice
     24 #-- Capacité accès ODN prévue
     27 #-- Km/alvéole réalisé
     28 #-- Capacité réalisée
     73 #-- Dist- FO prévue KM
     74 #-- Km/alvéole prévue
     83 #-- Distance FO posée /KM
     241 #-- Accès_cuivre_raccordés
     242 #-- Accés_FTTH_raccordés
     253 #-- Scénario
     262 #-- Spliter_1:8_Client_engagé
     267 #-- Budget_notifié
     286 #-- Date_achèvement
     288 #-- Acces_cuivre_prevue
     289 #-- Acces_FTTH_prévue
     293 #-- Commercialisable
    367 #-- Action

  end

	  
  
end  
end 
