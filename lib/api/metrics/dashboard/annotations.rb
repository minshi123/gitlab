# frozen_string_literal: true

module API
  module Metrics
    module Dashboard
      class Annotations < Grape::API
        desc 'Create a new monitoring dashboard annotation' do
          success Entities::Metrics::Dashboard::Annotation
        end

        params do
          requires :starting_at, type: DateTime,
                  desc: 'Date time indicating starting moment to which the annotation relates.'
          optional :ending_at, type: DateTime,
                  desc: 'Date time indicating ending moment to which the annotation relates.'
          requires :dashboard_path, type: String,
                  desc: 'The path to a file defining the dashboard on which the annotation should be added'
          requires :description, type: String, desc: 'The description of the annotation'
        end

        METRICS_SOURCES = [
          { class: ::Environment, resource: :environments },
          { class: Clusters::Cluster, resource: :clusters }
        ].freeze

        METRICS_SOURCES.each do |metrics_source|
          resource metrics_source[:resource] do
            post ':id/metrics_dashboard/annotations' do
              metrics_source_object = metrics_source[:class].find(params[:id])

              not_found! unless Feature.enabled?(:metrics_dashboard_annotations, metrics_source_object.project)

              forbidden! unless can?(current_user, :create_metrics_dashboard_annotation, metrics_source_object)

              create_service_params = declared(params).merge(Hash[metrics_source[:resource].to_s.singularize, metrics_source_object])

              result = ::Metrics::Dashboard::Annotations::CreateService.new(current_user, create_service_params).execute

              if result[:status] == :success
                present result[:annotation], with: Entities::Metrics::Dashboard::Annotation
              else
                error!(result, 400)
              end
            end
          end
        end
      end
    end
  end
end
