# frozen_string_literal: true

module API
  module Monitoring
    class Annotations < Grape::API
      desc 'Create a new monitoring dashboard annotation' do
        success Entities::Monitoring::Annotation
      end
      params do
        requires :from, type: DateTime,
                desc: 'Date time indicating starting moment to which the annotation relates.'
        optional :to, type: DateTime,
                desc: 'Date time indicating ending moment to which the annotation relates.'
        requires :dashboard_id, type: String,
                desc: 'The ID of the dashboard on which the annotation should be added'
        optional :panel_id, type: String,
                desc: 'The ID of the panel on which the annotation should be added'
        optional :tags, type: Array[String],
                desc: 'The ID of the panel on which the annotation should be added'
        requires :description, type: String, desc: 'The description of the annotation'
      end
      resource :environments do
        post ':id/metrics_dashboard/annotations' do
          environment = ::Environment.find(params[:id])
          authorize! :maintainer_access, environment

          result = ::Metrics::Dashboard::Annotations::CreateService.new(current_user, params.merge(environment: environment)).execute

          if result[:status] == :success
            present result[:annotation], with: Entities::Monitoring::Annotation
          else
            result
          end
        end
      end

      resource :clusters do
        post ':id/metrics_dashboard/annotations' do
          cluster = ::Cluster.find(params[:id])
          authorize! :maintainer_access, cluster

          result = ::Metrics::Dashboard::Annotations::CreateService.new(current_user, params.merge(cluster: cluster)).execute

          if result[:status] == :success
            present result[:annotation], with: Entities::Monitoring::Annotation
          else
            result
          end
        end
      end
    end
  end
end
