module ReportProject
  module Dispatcher
   
      MAP = {
        29 => ReportProject::ApsModule::Aps,
        47 => ReportProject::ApdModule::Apd,
        58 => ReportProject::ApdModule::Apd,
        60 => ReportProject::OdnModule::Odn,
        4 =>  ReportProject::OdnModule::Odn,
        6 => ReportProject::PrestationModule::Prestation,
        7 => ReportProject::OltModule::Olt,
        10 => ReportProject::LteModule::Lte,
        52 => ReportProject::PrestationModule::Prestation, 
        22 => ReportProject::PrestationModule::Prestation 
      }.freeze

    class Process
      def self.process(issue, tracker_struct)
        klass = MAP[issue[:tracker_id]] || ReportProject::BaseClass::Base
        klass.process(issue, tracker_struct)
      end
    end    
  end
end

