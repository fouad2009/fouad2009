
module ReportProject
  module ApdModule
    class Apd < ReportProject::BaseClass::Base

      def self.process(issue, tracker_struct)
        data = super  # récupération des données depuis la classe Base

        # =========================
        # Mapping du statut (peut être nil)
        # =========================
        status = status_key(data)
        exercice = exercice(data)
        return tracker_struct if status.nil?

        # =========================
        # Configuration APD
        # =========================
        rules_config = RULES_NBR_CONFIG[:apd]
        action =  RULES_NBR_CONFIG[:actions].include?(TRACKERS_LIST[data[:tracker_id]]) 
        return tracker_struct unless rules_config.key?(status)

        # =========================
        # Filtrage tracker APD
        # =========================
        return tracker_struct unless action

        # =========================
        # Application des règles
        # =========================
        state = rules_config[status][:state]
        field = rules_config[status][:field]

        tracker_struct[:category_1][exercice][:planned][:count] += 1
        tracker_struct[:category_1][exercice][:planned][:quantity] += data[field]

        tracker_struct[:category_1][exercice][state][:count] += 1
        tracker_struct[:category_1][exercice][state][:quantity] += data[field]

        tracker_struct
      end

    end
  end
end
