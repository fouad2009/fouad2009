module ReportProject
  module Calculators
   
      MAP = {
        29 => ReportProject::Calculators::APS,
        47 => ReportProject::Calculators::Apd,
        58 => ReportProject::Calculators::Apd,
        60 => ReportProject::Calculators::Odn,
        4 => ReportProject::Calculators::Prestation,
        6 => ReportProject::Calculators::Prestation,
        29 => ReportProject::Calculators::Olt,
        10 => ReportProject::Calculators::Lte,
        52 => ReportProject::Calculators::Prestation }
      }.freeze

    class Dispatcher
      def self.process(issue, tracker_struct)
        klass = MAP[issue[:tracker_id]] || Common
        klass.process(issue, tracker_struct)
      end
    
    
  end
end
