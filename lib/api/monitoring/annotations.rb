# frozen_string_literal: true

module API
  module Metrics
    module Dashboards
    class Annotations < Grape::API
      desc 'Create a new monitoring dashboard annotation' do
        success Entities::Monitoring::Annotation
      end

      params do
        requires :starting_at, type: DateTime,
                desc: 'Date time indicating starting moment to which the annotation relates.'
        optional :ending_at, type: DateTime,
                desc: 'Date time indicating ending moment to which the annotation relates.'
        requires :dashboard_path, type: String,
                desc: 'The path to a file defining the dashboard on which the annotation should be added'
        optional :tags, type: Array[String],
                desc: 'The ID of the panel on which the annotation should be added'
        requires :description, type: String, desc: 'The description of the annotation'
      end

      resource :environments do
        post ':id/metrics_dashboard/annotations' do
          environment = ::Environment.find(params[:id])

          forbidden! unless can?(current_user, :create_metrics_dashboard_annotation, environment)

          result = ::Metrics::Dashboard::Annotations::CreateService.new(current_user, params.merge(environment: environment)).execute

          if result[:status] == :success
            present result[:annotation], with: Entities::Monitoring::Annotation
          else
            error!(result, 400)
          end
        end
      end
    end
  end
end
