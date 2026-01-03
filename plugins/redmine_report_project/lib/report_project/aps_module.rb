module ReportProject
  module ApsModule
    class Aps < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
        data = super  #  récupéré les données de la methode parent de la class Base 

      # =========================
      # Methodes de traitement par action 
      # =========================
      
    status = STATUSES[data[:status_id]]
    
    config_aps = RULES_NBR_CONFIG[:actions][:aps] 
    
    if data[:tracker_id] == 29 # meme deja dispatcher a filtrer l'envoi selon le type tracker_id , appliqué un deuxiem filtre 
       
            state =   config_aps[status][:state] 
            field =   config_aps[status][:field]
          
         tracker_struct[:planned][:pa][:count] += 1
         tracker_struct[state][:pa][field] += 1 if field == :count 
    end 
       
 
    
    
    
    
      end
    end
  end
end
