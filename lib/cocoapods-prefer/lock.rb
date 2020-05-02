require 'cocoapods-core'
require 'cocoapods'
require 'singleton'
require 'colored2'
require 'neatjson'
require 'cocoapods-prefer/lock'

module Pod
  module PreferLock

    attr_accessor :lock_prefer_pods
    attr_accessor :lock_dislike_pods

    attr_accessor :current_locked_url

    def current_locked_url
      @current_locked_url ||= ""
    end

    def lock_prefer_pods
      @lock_prefer_pods ||= {}
    end

    def lock_dislike_pods
      @lock_dislike_pods ||= {}
    end

    def lock_url(url)
      unless current_locked_url.empty?
        UI.puts "current locked with url = #{current_locked_url}".yellow
        return
      end

      @current_locked_url = url
      UI.puts "locking source with #{url}".green
    end

    def unlock_url
      @current_locked_url = ""
    end

    def prefer_pod(pod)
      if current_locked_url.empty?
        UI.puts "current locked url is empty ".red
        return
      end

      lock_prefer_pods[pod] = current_locked_url
      UI.puts "#{pod} prefer locked source ".green
    end

    def dislike_pod(pod)
      if current_locked_url.empty?
        UI.puts "current locked url is empty".red
        return
      end

      lock_dislike_pods[pod] = current_locked_url
      UI.puts "#{pod} dislike locked source ".green
    end

    def lock_url_for_prefer_pod(pod)
      return lock_prefer_pods.fetch(pod, nil)
    end

    def lock_url_for_dislike_pod(pod)
      return lock_dislike_pods.fetch(pod, nil)
    end

    def locked_pods
      return lock_prefer_pods.keys + lock_dislike_pods.keys
    end

    def report_lock_result
      result = lock_file_result()

      result.select { |pod_name, url| 
        lock_prefer_pods.key?(pod_name) && lock_prefer_pods[pod_name] != url
      }.each do |pod_name, url|
        UI.puts "#{pod_name} using #{url} is not locked preferred source".yellow
      end

      result.select { |pod_name, url| 
        lock_dislike_pods.key?(pod_name) && lock_dislike_pods[pod_name] == url
      }.each do |pod_name, url|
        UI.puts "#{pod_name} using #{url} is locked disliked source".yellow
      end

    end

  end
end



