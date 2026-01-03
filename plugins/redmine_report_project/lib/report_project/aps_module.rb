module ReportProject
  module ApsModule
    class Aps < ReportProject::BaseClass::Base
      def self.process(issue, tracker_struct)
        data = super  #  récupéré les données de la methode parent de la class Base 

      # =========================
      # Methodes de traitement par action 
      # =========================
      
    RULES_NBR_CONFIG[:actions][:aps].each do |action, cfg|
  state = cfg[:state]
  field = cfg[:field]

  [:pa, :hp, :rar].each do |type|
    if tracker_struct[state].nil?
      Rails.logger.error "Ntracker_structtruct_tracker[state] est nil pour state=#{state}, action=#{action}"
      next
    end

    if tracker_struct[state][type].nil?
      Rails.logger.error "Ntracker_structtruct_tracker[state][type] est nil pour state=#{state}, type=#{type}, action=#{action}"
      next
    end

    unless tracker_struct[state][type].key?(field)
      Rails.logger.error "Ntracker_structtruct_tracker[state][type] n'a pas la clé field=#{field} pour action=#{action}"
      next
    end

    # Si tout est OK, incrémente
    tracker_struct[state][type][field] ||= 0
    tracker_struct[state][type][field] += 1
  end
end


      end
    end
  end
end
