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
             ratio = data[:ratio]
             exercice = data[:exercice]
             scenario = data[:scenario].to_i

            category = case scenario
                 when 291 then :category_1
                 when 292 then :category_2
                 when 293 then :category_2
              end

        
         return tracker_struct unless rules_config.key?(status)

         return tracker_struct unless (action && action_type)
    
         case rules_config[status]
          when Hash
             
             state = rules_config[status][:state]
             field = rules_config[status][:field_map][TRACKERS_LIST[data[:tracker_id]]]
             puts "Hash state: #{state}, field:#{field}"
      
          when Array

            if ratio < 100
              state = rules_config[status][0][:lower_100][:state]
              field = rules_config[status][0][:lower_100][:field_map][TRACKERS_LIST[data[:tracker_id]]]
            elsif ratio == 100
               state = rules_config[status][1][:equal_100][:state]
               field = rules_config[status][1][:equal_100][:field_map][TRACKERS_LIST[data[:tracker_id]]]
            end
           i = 0
           puts "Array state: #{state}, field:#{field}"
          end

          tracker_struct[category][exercice][state][:count] += 1
          tracker_struct[category][exercice][state][:quantity] += data[field]
       

      end
    end
  end
end
