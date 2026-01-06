module ReportProject
  module ApsModule
    class Aps < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
        data = super  #  récupéré les données de la methode parent de la class Base 

      # =========================
      # Methodes de traitement par action 
      # =========================
    
      

    status = STATUSES[data[:status]]
    
    
    unless status
  Rails.logger.error "[APS] Status inconnu: data[:status]=#{data[:status]}"
  return tracker_struct
end

config_aps = RULES_NBR_CONFIG[:actions][:aps]

unless config_aps.key?(status)
  Rails.logger.error "[APS] Configuration manquante pour status=#{status} (tracker_id=#{data[:tracker_id]})"
  return tracker_struct
end
    
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
