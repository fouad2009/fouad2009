module ReportProject
  module ApsModule
    class Aps < ReportProject::BaseClass::Base

      def self.process(issue, tracker_struct)
        data = super  # récupération des données depuis la classe Base

        # =========================
        # Mapping du statut (peut être nil)
        # =========================
        status = STATUSES[data[:status]]
        return tracker_struct if status.nil?
       
        
        # =========================
        # Configuration APS
        # =========================
        rules_config = RULES_NBR_CONFIG[:aps]
        action =  RULES_NBR_CONFIG[:actions].include?(TRACKERS_LIST[data[:tracker_id]]) 
        
        return tracker_struct unless rules_config.key?(status)

        # =========================
        # Filtrage tracker APS
        # =========================
        return tracker_struct unless action

        # =========================
        # Application des règles
        # =========================
        state = rules_config[status][:state]
        field = rules_config[status][:field]

        tracker_struct[:category_1][:pa][:planned][:count] += 1
        tracker_struct[:category_1][:pa][state][field] += 1 if field == :count

        tracker_struct
      end

    end
  end
end
