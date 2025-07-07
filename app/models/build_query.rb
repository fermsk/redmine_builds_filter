class BuildQuery
  attr_reader :project, :filters

  def initialize(project, options={})
    @project = project
    @filters = options[:filters] || {}
  end

  def build_scope
    scope = Build.where(project_id: project_ids)
    
    scope = apply_name_filter(scope)
    scope = apply_date_filters(scope)
    
    scope
  end

  private

  def project_ids
    filters[:only_project] == '1' ? [project.id] : project.self_and_ancestors.map(&:id)
  end

  def apply_name_filter(scope)
    if filters[:name].present?
      scope.where("LOWER(#{Build.table_name}.name) LIKE LOWER(?)", "%#{filters[:name]}%")
    else
      scope
    end
  end

  def apply_date_filters(scope)
    if filters[:created_at_from].present?
      scope = scope.where("#{Build.table_name}.created_at >= ?", Time.zone.parse(filters[:created_at_from]).beginning_of_day)
    end

    if filters[:created_at_to].present?
      scope = scope.where("#{Build.table_name}.created_at <= ?", Time.zone.parse(filters[:created_at_to]).end_of_day)
    end

    if filters[:updated_at_from].present?
      scope = scope.where("#{Build.table_name}.updated_at >= ?", Time.zone.parse(filters[:updated_at_from]).beginning_of_day)
    end

    if filters[:updated_at_to].present?
      scope = scope.where("#{Build.table_name}.updated_at <= ?", Time.zone.parse(filters[:updated_at_to]).end_of_day)
    end

    scope
  end
end