require 'colored2'
require 'cocoapods-core'
require 'cocoapods'
require 'cocoapods-prefer/config'

module Pod
  class Podfile
    module DSL
      
      def prefer_source(source_name, url)
        Pod::PreferConfig.instance.prefer_source(source_name, url)
        source(url)
      end

      def dislike_source(source_name, url)
        Pod::PreferConfig.instance.dislike_source(source_name, url)
      end

      def lock_source_with_url(url)
        Pod::PreferConfig.instance.lock_url(url)
        source(url)

        yield if block_given?

        Pod::PreferConfig.instance.unlock_url()
      end

      def prefer_source_pod(name = nil, *requirements)
        pod(name, *requirements)

        Pod::PreferConfig.instance.prefer_pod(name)
      end

      def dislike_source_pod(name = nil, *requirements)
        pod(name, *requirements)

        Pod::PreferConfig.instance.dislike_pod(name)
      end

    end
  end
end

