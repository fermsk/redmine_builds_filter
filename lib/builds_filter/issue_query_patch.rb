module BuildsFilter
  module IssueQueryPatch
    def self.prepended(base)
      base.add_available_column(QueryColumn.new(:build, sortable: "#{Build.table_name}.name", groupable: true))
      base.add_available_column(QueryColumn.new(:build_closed, sortable: "builds_closed.name", groupable: true))
    end

    def initialize_available_filters
      super

      add_available_filter "build_id",
        type: :list_optional,
        values: lambda { project.builds.sorted.map { |b| [b.name, b.id.to_s] } }
      add_available_filter "build_closed_id",
        type: :list_optional,
        values: lambda { project.builds.sorted.map { |b| [b.name, b.id.to_s] } }

      add_available_filter "build_name",
        type: :string,
        name: l(:label_build_name_search)
      add_available_filter "build_closed_name",
        type: :string,
        name: l(:label_build_closed_name_search)
    end

    def sql_for_build_name_field(field, operator, value)
      case operator
      when "~", "!~", "=", "!"
        build_compare = sql_for_field(field, operator, value, Build.table_name, 'name')
        "#{Issue.table_name}.build_id IN (SELECT id FROM #{Build.table_name} WHERE #{build_compare})"
      else
        ""
      end
    end

    def sql_for_build_closed_name_field(field, operator, value)
      case operator
      when "~", "!~", "=", "!"
        build_compare = sql_for_field(field, operator, value, 'builds_closed', 'name')
        "#{Issue.table_name}.build_closed_id IN (SELECT id FROM #{Build.table_name} builds_closed WHERE #{build_compare})"
      else
        ""
      end
    end

    def joins_for_order_statement(order_options)
      joins = super

      if order_options
        if order_options.include?('builds.name')
          joins << " LEFT OUTER JOIN #{Build.table_name} ON #{Build.table_name}.id = #{Issue.table_name}.build_id"
        end
        if order_options.include?('builds_closed.name')
          joins << " LEFT OUTER JOIN #{Build.table_name} builds_closed ON builds_closed.id = #{Issue.table_name}.build_closed_id"
        end
      end

      joins
    end
  end
end

IssueQuery.prepend BuildsFilter::IssueQueryPatch