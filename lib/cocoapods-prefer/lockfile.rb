require 'cocoapods-core'
require 'cocoapods'
require 'singleton'
require 'colored2'
require 'neatjson'

module Pod
  module PreferLockFile
    def lock_file_result
      lock_file = Pod::Lockfile.from_file(Pathname.new('Podfile.lock'))
      result = lock_file.pod_names.map { |pod_name| 
        pod_name.split("/")[0] 
      }.map { |pod_name|
        {pod_name => lock_file.spec_repo(pod_name)}
      }.each_with_object({}){ |i, v| 
        v.merge!(i) 
      }.reject { |pod_name, url| url.nil?  }

      # UI.puts JSON.neat_generate(result, sort:true, wrap:true, after_colon:1)
      result
    end
  end
end

