module ServiceHandler
  extend ActiveSupport::Concern

  def find_or_initialize_service(name)
    find_or_initialize_services.find {|service| service.to_param == name}
  end

  def find_or_initialize_services
    services_templates = Service.where(template: true)

    Service.available_services_names.map do |service_name|
      service = find_service(services, service_name)
      if service
        service
      else
        # We should check if template for the service exists
        template = find_service(services_templates, service_name)
        if template.nil?
          service_template = service_name.concat("_service").camelize.constantize
          service_template.where(template: true).first_or_create!
        else
          Service.build_from_template(id, template)
        end
      end
    end
  end

  def find_service(list, name)
    list.find {|service| service.to_param == name}
  end

end