require 'cocoapods-core'
require 'cocoapods'
require 'cocoapods-prefer/config'

module Pod
  class Resolver
    include PreferConfig::Mixin
    attr_accessor :prefer_pods
    attr_accessor :prefer_source_urls
    attr_accessor :dislike_pods
    attr_accessor :dislike_source_urls

    def prefer_source_urls
      @prefer_source_urls ||= perfer_config.prefer_source_urls.values
    end

    def prefer_pods
      @prefer_pods ||= perfer_config.prefer_pods()
    end

    def dislike_source_urls
      @dislike_source_urls ||= perfer_config.dislike_source_urls.values
    end

    def dislike_pods
      @dislike_pods ||= perfer_config.dislike_pods()
    end

    def prefer_specifications_filter(pod_name, specifications)
      if perfer_config.installed? && prefer_pods.include?(pod_name)
        filter = specifications.select { |s| 
          s.respond_to?('spec_source') && prefer_source_urls.include?(s.spec_source.url) 
        }

        return filter unless filter.empty?
      end

      specifications
    end

    def dislike_specifications_filter(pod_name, specifications)
      if perfer_config.installed? && dislike_pods.include?(pod_name)
        filter = specifications.reject { |s|
          s.respond_to?('spec_source') && dislike_source_urls.include?(s.spec_source.url)
        }

        return filter unless filter.empty?
      end

      specifications
    end

    def prefer_lock_specifications_filter(pod_name, specifications)
      lock_url = perfer_config.lock_url_for_prefer_pod(pod_name)
      unless lock_url.nil?
        filter = specifications.select { |s| 
          s.respond_to?('spec_source') && lock_url == s.spec_source.url
        }
        return filter unless filter.empty?
      end

      specifications
    end

    def dislike_lock_specifications_filter(pod_name, specifications)
      lock_url = perfer_config.lock_url_for_dislike_pod(pod_name)

      unless lock_url.nil?
        filter = specifications.reject { |s|
          s.respond_to?('spec_source') && lock_url == s.spec_source.url
        }

        return filter unless filter.empty?
      end

      specifications
    end

    alias perfer_search_for search_for
    ## Specification
    ## return preferred source if meet requirement 
    def search_for(dependency)
      # install_script_phases_for_dependency(dependency.root_name)
      specifications = perfer_search_for(dependency)

      pod_name = dependency.root_name
      specifications = dislike_lock_specifications_filter(pod_name, specifications)
      specifications = prefer_lock_specifications_filter(pod_name, specifications)

      specifications = dislike_specifications_filter(pod_name, specifications)
      specifications = prefer_specifications_filter(pod_name, specifications)
      specifications
    end
  end
end


