
module ReportProject
  module ApdModule
    class Apd < ReportProject::BaseClass::Base

      def self.process(issue, tracker_struct)
        data = super  # récupération des données depuis la classe Base

        # =========================
        # Mapping du statut (peut être nil)
        # =========================
        status = STATUSES[data[:status]]
        return tracker_struct if status.nil?

        exercice = data[:exercice]

        # =========================
        # Configuration APD
        # =========================
        config_apd = RULES_NBR_CONFIG[:actions][:apd]
        return tracker_struct unless config_apd.key?(status)

        # =========================
        # Filtrage tracker APD
        # =========================
        return tracker_struct unless [47, 58].include?(data[:tracker_id])

        # =========================
        # Application des règles
        # =========================
        state = config_apd[status][:state]
        field = config_apd[status][:field]

        tracker_struct[exercice][:planned][:count] += 1
        tracker_struct[exercice][:planned][:quantity] += data[field]

        tracker_struct[exercice][state][:count] += 1
        tracker_struct[exercice][state][:quantity] += data[field]

        tracker_struct
      end

    end
  end
end
