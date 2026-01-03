module ReportProject
  module ApsModule
    class Aps < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
        data = super  #  récupéré les données de la methode parent de la class Base 

      # =========================
      # Methodes de traitement par action 
      # =========================

        config_aps = RULES_NBR_CONFIG[:action][:aps]

        if data[:tracker_id] == 29  # meme deja dispatcher a filtrer l'envoi selon le type tracker_id , appliqué un deuxiem  filtre

              config_aps.each do |status,value|
                value.each do |state,field|
                  if  field == :count 
                   tracker_struct[state][:pa][field] += 1 if data[:exercice_PA]
                   tracker_struct[state][:hp][field] += 1 if data[:exercice_HP]
                   tracker_struct[state][:rar][field]+=1 if data[:exercice_RAR]
                  end
                end
              end

        end


      end
    end
  end
end
