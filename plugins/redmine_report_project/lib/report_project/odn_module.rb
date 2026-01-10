module ReportProject
  module OdnModule
    class Odn < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
         
           data = super  # récupération des données depuis la classe Base

            config_odn = RULES_QTN_CONFIG[:prestation]
            planned_fields = RULES_QTN_CONFIG[:common_fields][:planned_fields]
            completed_fields = RULES_QTN_CONFIG[:common_fields][:completed_fields]

           # =========================
           # Mapping du statut (peut être nil)
           # =========================
             status = STATUSES[data[:status]]
             return tracker_struct if status.nil?

             exercice = data[:exercice]
             scenario = data[:scenario].to_i

             scenario_dev   = scenario == 291
             scenario_mod   = scenario == 292
             scenario_tdm   = scenario == 293

         return tracker_struct unless [60].include?(data[:tracker_id])

         case config_odn

          when Hash

          when Array

          end




      end
    end
  end
end
