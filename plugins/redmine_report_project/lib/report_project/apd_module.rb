module ReportProject
  module ApdModule
    class Apd < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
        data = super  #  récupéré les données de la methode parent de la class Base 

      # =========================
      # Methodes de traitement par action 
      # =========================
      
    status = STATUSES[data[:status]]
    
    config_apd = RULES_NBR_CONFIG[:actions][:apd] 
    
    if [47,58].include?(data[:tracker_id])  # meme deja dispatcher a filtrer l'envoi selon le type tracker_id , appliqué un deuxiem filtre 
       
            state =   config_apd[status][:state] 
            field =   config_apd[status][:field]
          
         tracker_struct[:planned][:pa][:count] += 1
         tracker_struct[:planned][:pa][:quantity] += data[field]
         tracker_struct[state][:pa][:count] += 1 
         tracker_struct[state][:pa][:quantity] += data[field]
    end 


      end
    end
  end
end
