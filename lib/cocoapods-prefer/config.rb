require 'cocoapods-core'
require 'cocoapods'
require 'singleton'
require 'colored2'
require 'neatjson'
require 'cocoapods-prefer/lock'
require 'cocoapods-prefer/lockfile'
module Pod
  class PreferConfig
    include Singleton
    include PreferLock
    include PreferLockFile
    attr_accessor :prefer_sources
    attr_accessor :prefer_source_urls
    attr_accessor :dislike_source_urls
    attr_accessor :dislike_sources

    def installed?
      !prefer_source_urls.empty? || !dislike_source_urls.empty?
    end
    
    def prefer_sources
      @prefer_sources ||= {}
    end

    def prefer_source_urls
      @prefer_source_urls ||= {}
    end

    def dislike_sources
      @dislike_sources ||= {}
    end

    def dislike_source_urls
      @dislike_source_urls ||= {}
    end


    def prefer_source_options(user_options)
      dislike = user_options[:dislike_sources]
      unless dislike.nil? || dislike.empty? || !dislike.is_a?(Hash)
        dislike.each { |source_name, url|
          dislike_source(source_name, url)
        }
      end

      sources = user_options[:prefer_sources]
      unless sources.nil? || sources.empty? || !sources.is_a?(Hash)
        sources.each { |source_name, url|
          prefer_source(source_name, url)
        }
      end
    end

    def dislike_source(source_name, url)
      preferred = prefer_source_urls.select { |e, u|
        e == source_name || u == url
      }

      unless preferred.empty?
        UI.puts "#{source_name} or #{url} is preferred. Ignored!".red
        return
      end

      UI.puts "dislike #{source_name} with #{url}".green
      add_dislike_source(source_name, url)
    end

    def add_dislike_source(source_name, url)
      unless validate_name_and_url?(source_name, url)
        return
      end

      old = dislike_source_urls.fetch(source_name, nil)

      raise Informative, "#{source_name} already exist and url = #{old}" if !old.nil? && old != url
      
      return if url == old

      dislike_source_urls[source_name] = url
      dislike_sources[source_name] = source_with_name_and_url(source_name, url)
    end

    def prefer_source(source_name, url)
      disliked = dislike_source_urls.select { |e, u|
        e == source_name || u == url
      }

      unless disliked.empty?
        UI.puts "#{source_name} or #{url} is disliked. Ignored!".red
        return
      end

      UI.puts "prefer #{source_name} with #{url}".green
      add_prefer_source(source_name, url)
    end

    def add_prefer_source(source_name, url)
      unless validate_name_and_url?(source_name, url)
        return
      end

      old = prefer_source_urls.fetch(source_name, nil)

      raise Informative, "#{source_name} already exist and url = #{old}" if !old.nil? && old != url
      
      return if url == old

      prefer_source_urls[source_name] = url
      prefer_sources[source_name] = source_with_name_and_url(source_name, url)
    end

    def validate_name_and_url?(source_name, url)
      if source_name.nil? || source_name.empty?
        UI.puts "name for the source is needed".red
        return false
      end

      if url.nil? || url.empty?
        UI.puts "url for the source #{source_name} is needed".red
        return false
      end

      unless url =~ /git@([A-Za-z0-9_\.]+)(:|\/)([A-Za-z0-9_\/]+)(\.git)/
        UI.puts "#{url} is not a git ssh like 'git@github.com:DanboDuan/cocoapods-prefer.git' ".red
        return false
      end

      return true
    end

    def source_with_name_and_url(source_name, url)
      path = File.expand_path(source_name, '~/.cocoapods/repos')
      unless File.directory?(path)
        UI.puts "Adding source repo..."
        File.delete(path) if File.file?(path)
        Pod::Command::Repo::Add.parse([source_name, url]).run
        UI.puts "finish add source repo #{source_name}"
      end
      source = Pod::Source.new(path)
      UI.puts "updating source repo"
      source.update(true)
      source
    end

    def prefer_pods
      return [] if prefer_sources.empty?

      pods = prefer_sources.map { |source_name, source|
        source.pods
      }.flatten.uniq

      # pod_versions = pods.map { |pod|
      #   {pod => prefer_sources.map { |source_name, source|
      #     source.versions(pod).map(&:to_s) 
      #   }.flatten.uniq}
      # }.reduce({}) { |h, v| h.merge v }
      # UI.puts JSON.neat_generate(pod_versions, sort:true, wrap:true, after_colon:1)

      return pods
    end

    def dislike_pods
      return [] if dislike_sources.empty?

      return dislike_sources.map { |source_name, source|
        source.pods
      }.flatten.uniq
    end

    def report
      report_lock_result()
      if installed?
        locked_result_pods = locked_pods()
        result = lock_file_result().reject { |pod_name, url| 
          locked_result_pods.include?(pod_name)
        }

        prefer_urls = prefer_source_urls.values
        prefer_pod_names = prefer_pods()

        result.select { |pod_name, url| 
          prefer_pod_names.include?(pod_name) && !prefer_urls.include?(url)
        }.each do |pod_name, url|
          UI.puts "#{pod_name} using #{url} not in preferred sources".yellow
        end

        dislike_urls = dislike_source_urls.values
        dislike_pod_names = dislike_pods()

        result.select { |pod_name, url| 
          dislike_pod_names.include?(pod_name) && dislike_urls.include?(url)
        }.each do |pod_name, url|
          UI.puts "#{pod_name} using #{url} in disliked sources".yellow
        end
      end
    end

    module Mixin
      def perfer_config
        PreferConfig.instance
      end
    end
    
  end

end