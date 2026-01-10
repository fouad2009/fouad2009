module ReportProject
  module ReportDataInit

    # =====================================================
    # Génération optimisée de la structure projet → tracker → issues
    # =====================================================
    def self.calculate_for_project(project_parent_id)
      User.current = User.admin.first if User.current.anonymous?

      project = Project.find(project_parent_id)
      with_subprojects = Setting.display_subprojects_issues?
      cond = project.project_condition(with_subprojects)
      tracker_ids = project.rolled_up_trackers(with_subprojects).visible.map(&:id)

      rows = Issue.visible.open
                  .where(cond)
                  .where(tracker_id: tracker_ids)
                  .joins(:custom_values)
                  .where(custom_values: {
                    custom_field_id: ReportProject::ReportSchema::CUSTOM_FIELDS_LIST
                  })
                  .pluck(
                    :project_id,
                    :id,
                    :tracker_id,
                    :status_id,
                    :done_ratio,
                    :estimated_hours,
                    'custom_values.custom_field_id',
                    'custom_values.value'
                  )

      data = {}

      rows.each do |row|
        project_id, issue_id, tracker_id, status_id,
        done_ratio, estimated_hours, cf_id, cf_value = row

        project_hash = (data[project_id] ||= {})
        tracker_hash = (project_hash[tracker_id] ||= {})
        issue_hash   = (tracker_hash[issue_id] ||= {
          project_id: project_id,
          issue_id: issue_id,
          tracker_id: tracker_id,
          status_id: status_id,
          done_ratio: done_ratio,
          estimated_hours: estimated_hours
        })

        issue_hash[cf_id.to_i] = cf_value
      end

      # Normalisation finale : tracker_id => [issues]
      data.transform_values! do |trackers|
        trackers.transform_values!(&:values)
      end

      data
    end

    # =====================================================
    # Construction finale de la structure métier
    # =====================================================
    def self.build_report_data(project_parent_id)

      data_project = calculate_for_project(project_parent_id)

      report_data = data_project.transform_values do |trackers_hash|
        trackers_hash.transform_values do |issues_array|

          tracker_struct =
            ReportProject::ReportSchema.build_category_metrics

          issues_array.each do |issue|
            ReportProject::Dispatcher::Process.process(issue, tracker_struct)
          end

          tracker_struct
        end
      end

      report_data
    end

  end
end
