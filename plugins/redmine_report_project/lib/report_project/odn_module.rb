module ReportProject
  module OdnModule
    class Odn < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
         
           data = super  # récupération des données depuis la classe Base



            rules_config = RULES_QTN_CONFIG[:prestation]
            planned_fields = RULES_QTN_CONFIG[:common_fields][:planned_fields]
            completed_fields = RULES_QTN_CONFIG[:common_fields][:completed_fields]
            #action_type = TRACKERS_LIST[data[:tracker_id]] == :odn_prestation
            action =  RULES_QTN_CONFIG[:actions].include?(tracker)

           # =========================
           # Mapping du statut (peut être nil)
           # =========================
             tracker = tracker_key(data)
             status = status_key(data)
             return tracker_struct if status.nil?
             ratio    = ratio(data)
             exercice = exercice(data)
             scenario = scenario(data)
             category = resolve_category(data)
             state_commercialisable =  :sellable  # Infrastructure vendable / commercialisable
        
         return tracker_struct unless rules_config.key?(status)

         return tracker_struct unless action 
    
         case rules_config[status]
          when Hash
             
             state = rules_config[status][:state]
             field = rules_config[status][:field_map][tracker]

              if COMPLETED_STATUSES.include?(status) && commercialisable?(data)
                tracker_struct[category][exercice][state_commercialisable][:count] += 1
                tracker_struct[category][exercice][state_commercialisable][:quantity] += data[field]

              end
          
      
          when Array

            if ratio < 100
              state = rules_config[status][0][:lower_100][:state]
              field = rules_config[status][0][:lower_100][:field_map][tracker]
            elsif ratio == 100
               state = rules_config[status][1][:equal_100][:state]
               field = rules_config[status][1][:equal_100][:field_map][tracker]
              
               if  commercialisable?(data) && status == :EN_PROGRESSION
                tracker_struct[category][exercice][state_commercialisable][:count] += 1
                tracker_struct[category][exercice][state_commercialisable][:quantity] += data[field]
              end
            end
          
          end

          tracker_struct[category][exercice][state][:count] += 1
          tracker_struct[category][exercice][state][:quantity] += data[field]
       

      end
    end
  end
end
