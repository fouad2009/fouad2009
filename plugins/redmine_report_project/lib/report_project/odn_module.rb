module ReportProject
  module OdnModule
    class Odn < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
         
           data = super  # récupération des données depuis la classe Base

            rules_config = RULES_QTN_CONFIG[:prestation]
            planned_fields = RULES_QTN_CONFIG[:common_fields][:planned_fields]
            completed_fields = RULES_QTN_CONFIG[:common_fields][:completed_fields]
            action_type = TRACKERS_LIST[data[:tracker_id]] == :odn_prestation
            action =  RULES_QTN_CONFIG[:actions].include?(TRACKERS_LIST[data[:tracker_id]])

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

         return tracker_struct unless (action && action_type)
         puts "dans la partie ODN"
         case rules_config[status].class
           puts "partie de state: #{rules_config[status].class}"
          when Hash
             
             state = rules_config[status][:state]
             field = rules_config[status][:field_map][TRACKERS_LIST[data[:tracker_id]]]

            if scenario_dev

             tracker_struct[:category_1][exercice][state][:count] += 1
             tracker_struct[:category_1][exercice][state][:quantity] += data[field]

            elsif scenario_mod
              tracker_struct[:category_1][exercice][state][:count] += 1
              tracker_struct[:category_1][exercice][state][:quantity] += data[field]
            end

          when Array

          end




      end
    end
  end
end
