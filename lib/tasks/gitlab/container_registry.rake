namespace :gitlab do
  namespace :container_registry do
    desc "GitLab | Container Registry | Configure"
    task configure: :gitlab_environment do
      configure
    end

    def configure
      UpdateContainerRegistryInfoService.new.execute
    end
  end
end
