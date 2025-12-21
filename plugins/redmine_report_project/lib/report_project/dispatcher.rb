module ReportProject
  module Calculators
    class Dispatcher
      MAP = {
        ReportProject::ReportSchema::TRACKERS[:aps]          => APS,
        ReportProject::ReportSchema::TRACKERS[:odn_dev]      => ODNDev,
        ReportProject::ReportSchema::TRACKERS[:odn_mod]      => ODNMod,
        ReportProject::ReportSchema::TRACKERS[:canalisation] => Canalisation
      }.freeze

      def self.process(issue, tracker_struct)
        klass = MAP[issue[:tracker_id]] || Base
        klass.process(issue, tracker_struct)
      end
    end
  end
end
