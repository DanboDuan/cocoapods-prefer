require 'cocoapods'
require 'cocoapods-core'
require 'cocoapods-prefer/command'
require 'cocoapods-prefer/config'
require 'cocoapods-prefer/hook'

module CocoapodsPrefer
  Pod::HooksManager.register('cocoapods-prefer', :source_provider) do |context, user_options|
    Pod::PreferConfig.instance.prefer_sources().each { |e, source| 
      context.add_source(source)
    }
  end

  Pod::HooksManager.register('cocoapods-prefer', :pre_install) do |context, user_options|
    Pod::PreferConfig.instance.prefer_source_options(user_options)
    # targets = context.podfile.target_definition_list.reject { |e| e.name.include?("Pods")  }
    # targets.each{ |e| puts e.name }
  end

  Pod::HooksManager.register('cocoapods-prefer', :post_install) do |context, user_options|
    Pod::PreferConfig.instance.report()
  end

end

