module ReportProject
  module ReportDataInit

    # =====================================================
    # Niveau 3 : récupération optimisée des issues avec custom fields pour MariaDB
    # =====================================================
    def self.calculate_for_project(project_parent_id)
      User.current = User.admin.first if User.current.anonymous?

      project = Project.find(project_parent_id)
      with_subprojects = Setting.display_subprojects_issues?
      cond = project.project_condition(with_subprojects)
      tracker_ids = project.rolled_up_trackers(with_subprojects).visible.map(&:id)

      # ===========================
      # SQL optimisé : GROUP_CONCAT pour custom fields
      # ===========================
      rows = Issue.visible.open
                  .where(cond)
                  .where(tracker_id: tracker_ids)
                  .joins(:custom_values)
                  .where(custom_values: { custom_field_id: ReportProject::ReportSchema::CUSTOM_FIELDS_LIST })
                  .group(:id, :project_id, :tracker_id, :status_id, :done_ratio, :estimated_hours)
                  .pluck(
                    :project_id,
                    :id,
                    :tracker_id,
                    :status_id,
                    :done_ratio,
                    :estimated_hours,
                    Arel.sql("GROUP_CONCAT(CONCAT(custom_values.custom_field_id, ':', custom_values.value) SEPARATOR ',') AS cf_concat")
                  )

      # ===========================
      # Transformation en Hash Ruby
      # Structure : project_id => tracker_id => [issues]
      # ===========================
      data = {}

      rows.each do |project_id, issue_id, tracker_id, status_id, done_ratio, est_hours, cf_concat|
        # Parse custom fields
        cf_hash = {}
        if cf_concat
          cf_concat.split(',').each do |pair|
            k, v = pair.split(':', 2)
            cf_hash[k.to_i] = v
          end
        end

        project_hash = (data[project_id] ||= {})
        tracker_hash = (project_hash[tracker_id] ||= {})
        tracker_hash[issue_id] = {
  project_id: project_id,
  issue_id: issue_id,
  tracker_id: tracker_id.to_i,  # <== IMPORTANT
  status_id: status_id,
  done_ratio: done_ratio,
  estimated_hours: est_hours
}.merge(cf_hash.transform_keys(&:to_i))

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
          tracker_struct = ReportProject::ReportSchema.build_category_metrics

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
