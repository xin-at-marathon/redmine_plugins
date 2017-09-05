
# As Rails 5 disabled the autoloading so i have to load manualy
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| load(f) }
Dir["#{File.dirname(__FILE__)}/app/**/*.rb"].each { |f| load(f) }


Redmine::Plugin.register :plantuml do
  name 'PlantUML plugin for Redmine'
  author 'Michael Skrynski'
  description 'This is a plugin for Redmine which renders PlantUML diagrams.'
  version '0.5.1'
  url 'https://github.com/dkd/plantuml'

  requires_redmine version: '2.6'..'3.4'

  settings(partial: 'settings/plantuml',
           default: { 'plantuml_binary' => {}, 'cache_seconds' => '0', 'allow_includes' => false })

  Redmine::WikiFormatting::Macros.register do
    desc <<EOF
      Render PlantUML image.
      <pre>
      {{plantuml(png)
      (Bob -> Alice : hello)
      }}
      </pre>

      Available options are:
      ** (png|svg)
EOF
    macro :plantuml do |obj, args, text|

      raise 'No PlantUML binary set.' if Setting.plugin_plantuml['plantuml_binary_default'].blank?
      raise 'No or bad arguments.' if args.size != 1
      frmt = PlantumlHelper.check_format(args.first)
      image = PlantumlHelper.plantuml(text, args.first)
      content = "<img src=\"#{Setting.protocol}://#{Setting.host_name}/plantuml/#{frmt[:type]}/#{image}#{frmt[:ext]}\" />"
      result = "#{ CGI::unescapeHTML(content) }".html_safe
      return result
    end
  end
end

Rails.configuration.to_prepare do
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks

  unless Redmine::WikiFormatting::Textile::Helper.included_modules.include? PlantumlHelperPatch
    Redmine::WikiFormatting::Textile::Helper.send(:include, PlantumlHelperPatch)
  end
end
