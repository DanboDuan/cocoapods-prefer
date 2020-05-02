require 'cocoapods-core'
require 'cocoapods'
# require 'cocoapods-prefer/config'

module Pod
  # class Installer
  	## record final result
    # alias_method :cocoapods_prefer_specs, :root_specs
    # def root_specs
      # cocoapods_analysis_result = cocoapods_prefer_specs
      # if PreferConfig.instance.installed?
      #   PreferConfig.instance.installed_specs = cocoapods_analysis_result.map { |result|
      #      {result.name.to_s => result.version.to_s}
     	#   }.each_with_object({}){ |i, v| 
      #     v.merge!(i) 
      #   }
      # end
      # cocoapods_analysis_result
    # end
  # end
end