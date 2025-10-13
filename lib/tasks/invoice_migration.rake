namespace :invoices do
  desc "Export invoices from development to JSON file"
  task export: :environment do
    puts "Exporting invoices from #{Rails.env} environment..."
    
    invoices_data = []
    
    Invoice.includes(:user, :invoice_line_items).each do |invoice|
      invoice_data = {
        # Invoice attributes
        user_email: invoice.user.email,
        frequency: invoice.frequency,
        rate: invoice.rate,
        recipient_company_name: invoice.recipient_company_name,
        recipient_vat_number: invoice.recipient_vat_number,
        recipient_address: invoice.recipient_address,
        recipient_email: invoice.recipient_email,
        sender_company_name: invoice.sender_company_name,
        sender_tax_number: invoice.sender_tax_number,
        sender_address: invoice.sender_address,
        issued_on: invoice.issued_on,
        due_on: invoice.due_on,
        total_amount: invoice.total_amount,
        invoice_number: invoice.invoice_number,
        tax_rate: invoice.tax_rate,
        terms: invoice.terms,
        bank_details: invoice.bank_details,
        notes: invoice.notes,
        currency: invoice.currency,
        created_at: invoice.created_at,
        updated_at: invoice.updated_at,
        
        # Line items
        line_items: invoice.invoice_line_items.map do |item|
          {
            description: item.description,
            rate: item.rate,
            quantity: item.quantity,
            total: item.total,
            created_at: item.created_at,
            updated_at: item.updated_at
          }
        end
      }
      
      invoices_data << invoice_data
    end
    
    # Write to JSON file
    filename = "invoices_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
    File.write(filename, JSON.pretty_generate(invoices_data))
    
    puts "Exported #{invoices_data.count} invoices to #{filename}"
    puts "File size: #{File.size(filename)} bytes"
  end
  
  desc "Import invoices from JSON file to current environment"
  task :import, [:filename] => :environment do |t, args|
    filename = args[:filename]
    
    unless filename && File.exist?(filename)
      puts "Usage: rake invoices:import[filename.json]"
      puts "File not found: #{filename}" if filename
      exit 1
    end
    
    puts "Importing invoices from #{filename} to #{Rails.env} environment..."
    
    begin
      invoices_data = JSON.parse(File.read(filename))
    rescue JSON::ParserError => e
      puts "Error parsing JSON file: #{e.message}"
      exit 1
    end
    
    imported_count = 0
    skipped_count = 0
    errors = []
    
    invoices_data.each_with_index do |invoice_data, index|
      begin
        # Find or create user by email
        user = User.find_by(email: invoice_data['user_email'])
        unless user
          puts "Warning: User #{invoice_data['user_email']} not found. Skipping invoice #{index + 1}"
          skipped_count += 1
          next
        end
        
        # Check if invoice already exists (by invoice_number and user)
        existing_invoice = Invoice.find_by(
          user: user, 
          invoice_number: invoice_data['invoice_number']
        )
        
        if existing_invoice
          puts "Invoice #{invoice_data['invoice_number']} already exists for user #{user.email}. Skipping."
          skipped_count += 1
          next
        end
        
        # Create invoice
        invoice = Invoice.new(
          user: user,
          frequency: invoice_data['frequency'],
          rate: invoice_data['rate'],
          recipient_company_name: invoice_data['recipient_company_name'],
          recipient_vat_number: invoice_data['recipient_vat_number'],
          recipient_address: invoice_data['recipient_address'],
          recipient_email: invoice_data['recipient_email'],
          sender_company_name: invoice_data['sender_company_name'],
          sender_tax_number: invoice_data['sender_tax_number'],
          sender_address: invoice_data['sender_address'],
          issued_on: invoice_data['issued_on'],
          due_on: invoice_data['due_on'],
          total_amount: invoice_data['total_amount'],
          invoice_number: invoice_data['invoice_number'],
          tax_rate: invoice_data['tax_rate'],
          terms: invoice_data['terms'],
          bank_details: invoice_data['bank_details'],
          notes: invoice_data['notes'],
          currency: invoice_data['currency'],
          created_at: invoice_data['created_at'],
          updated_at: invoice_data['updated_at']
        )
        
        if invoice.save
          # Create line items
          invoice_data['line_items'].each do |item_data|
            line_item = invoice.invoice_line_items.build(
              description: item_data['description'],
              rate: item_data['rate'],
              quantity: item_data['quantity'],
              total: item_data['total'],
              created_at: item_data['created_at'],
              updated_at: item_data['updated_at']
            )
            
            unless line_item.save
              errors << "Failed to create line item for invoice #{invoice.invoice_number}: #{line_item.errors.full_messages.join(', ')}"
            end
          end
          
          imported_count += 1
          puts "✓ Imported invoice #{invoice.invoice_number} for #{user.email}"
        else
          errors << "Failed to create invoice #{invoice_data['invoice_number']}: #{invoice.errors.full_messages.join(', ')}"
        end
        
      rescue => e
        errors << "Error processing invoice #{index + 1}: #{e.message}"
      end
    end
    
    puts "\n=== Import Summary ==="
    puts "Total invoices in file: #{invoices_data.count}"
    puts "Successfully imported: #{imported_count}"
    puts "Skipped: #{skipped_count}"
    puts "Errors: #{errors.count}"
    
    if errors.any?
      puts "\nErrors encountered:"
      errors.each { |error| puts "- #{error}" }
    end
  end
  
  desc "Import invoices directly from JSON data string"
  task :import_from_data, [:json_data] => :environment do |t, args|
    json_data = args[:json_data]
    
    unless json_data
      puts "Usage: rake invoices:import_from_data['[{\"user_email\":\"...\"}]']"
      exit 1
    end
    
    puts "Importing invoices from provided JSON data to #{Rails.env} environment..."
    
    begin
      invoices_data = JSON.parse(json_data)
    rescue JSON::ParserError => e
      puts "Error parsing JSON data: #{e.message}"
      exit 1
    end
    
    imported_count = 0
    skipped_count = 0
    errors = []
    
    invoices_data.each_with_index do |invoice_data, index|
      begin
        # Find or create user by email
        user = User.find_by(email: invoice_data['user_email'])
        unless user
          puts "Warning: User #{invoice_data['user_email']} not found. Skipping invoice #{index + 1}"
          skipped_count += 1
          next
        end
        
        # Check if invoice already exists (by invoice_number and user)
        existing_invoice = Invoice.find_by(
          user: user, 
          invoice_number: invoice_data['invoice_number']
        )
        
        if existing_invoice
          puts "Invoice #{invoice_data['invoice_number']} already exists for user #{user.email}. Skipping."
          skipped_count += 1
          next
        end
        
        # Create invoice
        invoice = Invoice.new(
          user: user,
          frequency: invoice_data['frequency'],
          rate: invoice_data['rate'],
          recipient_company_name: invoice_data['recipient_company_name'],
          recipient_vat_number: invoice_data['recipient_vat_number'],
          recipient_address: invoice_data['recipient_address'],
          recipient_email: invoice_data['recipient_email'],
          sender_company_name: invoice_data['sender_company_name'],
          sender_tax_number: invoice_data['sender_tax_number'],
          sender_address: invoice_data['sender_address'],
          issued_on: invoice_data['issued_on'],
          due_on: invoice_data['due_on'],
          total_amount: invoice_data['total_amount'],
          invoice_number: invoice_data['invoice_number'],
          tax_rate: invoice_data['tax_rate'],
          terms: invoice_data['terms'],
          bank_details: invoice_data['bank_details'],
          notes: invoice_data['notes'],
          currency: invoice_data['currency'],
          created_at: invoice_data['created_at'],
          updated_at: invoice_data['updated_at']
        )
        
        if invoice.save
          # Create line items
          invoice_data['line_items'].each do |item_data|
            line_item = invoice.invoice_line_items.build(
              description: item_data['description'],
              rate: item_data['rate'],
              quantity: item_data['quantity'],
              total: item_data['total'],
              created_at: item_data['created_at'],
              updated_at: item_data['updated_at']
            )
            
            unless line_item.save
              errors << "Failed to create line item for invoice #{invoice.invoice_number}: #{line_item.errors.full_messages.join(', ')}"
            end
          end
          
          imported_count += 1
          puts "✓ Imported invoice #{invoice.invoice_number} for #{user.email}"
        else
          errors << "Failed to create invoice #{invoice_data['invoice_number']}: #{invoice.errors.full_messages.join(', ')}"
        end
        
      rescue => e
        errors << "Error processing invoice #{index + 1}: #{e.message}"
      end
    end
    
    puts "\n=== Import Summary ==="
    puts "Total invoices in data: #{invoices_data.count}"
    puts "Successfully imported: #{imported_count}"
    puts "Skipped: #{skipped_count}"
    puts "Errors: #{errors.count}"
    
    if errors.any?
      puts "\nErrors encountered:"
      errors.each { |error| puts "- #{error}" }
    end
  end

  desc "Show invoice statistics for current environment"
  task stats: :environment do
    puts "=== Invoice Statistics for #{Rails.env.upcase} environment ==="
    puts "Total invoices: #{Invoice.count}"
    puts "Total users with invoices: #{User.joins(:invoices).distinct.count}"
    puts "Total line items: #{InvoiceLineItem.count}"
    puts "Total invoice value: #{Invoice.sum(:total_amount)}"
    
    if Invoice.any?
      puts "\nInvoices by user:"
      User.joins(:invoices).group('users.email').count.each do |email, count|
        puts "  #{email}: #{count} invoices"
      end
    end
  end
end
