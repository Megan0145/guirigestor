namespace :services do
  desc "Create defaultservices"
  task create_defaults: :environment do
    services = [
      {
        user_id: 1,
        name: "Canva Pro",
        description: "Software de diseño para sitios web",
        active: true,
        variable_amount: false,
        amount: 12.00,
        currency: "EUR",
      },
      {
        user_id: 1,
        name: "ChatGPT Software",
        description: "Herramienta de IA para aumentar la productividad",
        active: true,
        variable_amount: false,
        amount: 24.20,
        currency: "USD",
      },
      {
        user_id: 1,
        name: "LinkedIn Premium",
        description: "Red social para profesionales",
        active: true,
        variable_amount: false,
        amount: 24.78,
        currency: "EUR",
      },
      {
        user_id: 1,
        name: "MagicPatterns Software",
        description: "Software IA de diseño para sitios web",
        active: true,
        variable_amount: false,
        amount: 19.00,
        currency: "USD",
      },
      {
        user_id: 1,
        name: "Notion Labs",
        description: "Documentos por clientes y proyectos",
        active: true,
        variable_amount: false,
        amount: 13.92,
        currency: "EUR",
      },
      {
        user_id: 1,
        name: "Orange Es",
        description: "Wifi",
        active: true,
        variable_amount: true,
        amount: 0.00,
        currency: "EUR"
      },
      {
        user_id: 1,
        name: "Zoom Software",
        description: "Videollamadas por clientes",
        active: true,
        variable_amount: false,
        amount: 15.99,
        currency: "EUR"
      },
      {
        user_id: 1,
        name: "Squarespace",
        description: "Sitio web con soporte de Google Workspace",
        active: true,
        variable_amount: false,
        amount: 9.68,
        currency: "EUR"
      },
    ]

    services.each do |service|
      s = Service.find_or_initialize_by(name: service[:name])
      s.assign_attributes(service)
      begin
        s.save!
        puts "Service #{service[:name]} created successfully"
      rescue => exception
        puts "Error creating service #{service[:name]}: #{exception.message}"
      end
    end
  end

  desc "Assign existing outgoing invoices to services"
  task assign_outgoing_invoices_to_services: :environment do
    OutgoingReceipt.all.each do |outgoing_receipt|
      service = Service.find_by(user_id: outgoing_receipt.user_id, name: outgoing_receipt.service)
      
      if service.blank?
        puts "Service #{outgoing_receipt.service} not found for user #{outgoing_receipt.user_id}"
        next
      end

      begin 
        outgoing_receipt.service_id = service.id
        outgoing_receipt.save!
        puts "Outgoing invoice #{outgoing_receipt.id} assigned to service #{service.name}"
      rescue => exception
        puts "Error assigning outgoing invoice #{outgoing_receipt.id} to service #{service.name}: #{exception.message}"
      end
    end
  end
end