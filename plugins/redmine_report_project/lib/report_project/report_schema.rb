module ReportProject
  module ReportSchema

    METRIC_FIELDS = %i[count quantity].freeze

    STATES = %i[
      planned planned_hp
      not_started
      study_in_progress study_completed
      consultation committed
      in_progress_pa in_progress_hp in_progress_rar
      completed_pa completed_hp completed_rar
      odn_completed sellable
      global_stop closed
      site_preparation site_validated
      equipment_request installation_request request_approved
      equipped installed service_activated in_operation
      service_preparation service_committed service_execution service_completed
    ].freeze

  end
end


