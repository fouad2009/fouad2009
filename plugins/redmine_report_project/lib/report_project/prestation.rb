module ReportProject
  module Calculators
    class Prestation < Base
      def self.process(issue, tracker_struct)
        super  # 🔹 logique commune

        scenario = issue[253] # champ personnalisé
        capacity = issue[24].to_i

        if scenario == 'HP'
          tracker_struct[:planned_hp][:quantity] += capacity
        end
      end
    end
  end
end
