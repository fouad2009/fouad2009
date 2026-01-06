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
        config_aps = RULES_NBR_CONFIG[:actions][:aps]
        return tracker_struct unless config_aps.key?(status)

        # =========================
        # Filtrage tracker APS
        # =========================
        return tracker_struct unless data[:tracker_id] == 29

        # =========================
        # Application des règles
        # =========================
        state = config_aps[status][:state]
        field = config_aps[status][:field]

        tracker_struct[:planned][:pa][:count] += 1
        tracker_struct[state][:pa][field] += 1 if field == :count

        tracker_struct
      end

    end
  end
end
