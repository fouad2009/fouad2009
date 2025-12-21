module ReportProject
  module Calculators
    class Base
      def self.process(issue, tracker_struct)
        status = issue[:status_id]
        ratio  = issue[:done_ratio].to_i

        # Exemple : incrément générique
        tracker_struct[:planned][:count] += 1 if status == 1
      end
    end
  end
end
