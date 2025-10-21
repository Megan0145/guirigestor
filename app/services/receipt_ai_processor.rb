class ReceiptAiProcessor
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def initialize(receipt_file)
    @receipt_file = receipt_file
    @api_key = ENV['OPENAI_API_KEY']
  end

  def extract_details
    # Extract text from PDF using rtesseract
    receipt_text = extract_text_from_file
    
    if receipt_text.blank?
      Rails.logger.error "Failed to extract text from receipt file"
      return default_response
    end
    
    prompt = build_prompt_with_text(receipt_text)
    
    response = self.class.post("/chat/completions",
      headers: {
        "Authorization" => "Bearer #{@api_key}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: "You are an expert at analyzing receipt text and extracting structured data. Match services from the provided list based on the receipt content."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        response_format: { type: "json_object" },
        max_tokens: 1000
      }.to_json
    )

    if response.success?
      result = JSON.parse(response.body)
      content = result.dig("choices", 0, "message", "content")
      
      if content
        parsed_data = JSON.parse(content)
        Rails.logger.info "AI extracted receipt data: #{parsed_data.inspect}"
        return format_response(parsed_data)
      end
    end

    Rails.logger.error "AI receipt processing failed: #{response.body}"
    return default_response
  rescue StandardError => e
    Rails.logger.error "AI receipt processing error: #{e.message}"
    return default_response
  end

  private

  def extract_text_from_file
    # Download file and try to extract text
    temp_file = Tempfile.new(['receipt', File.extname(@receipt_file.filename.to_s)])
    temp_file.binmode
    temp_file.write(@receipt_file.download)
    temp_file.close
    
    begin
      if @receipt_file.content_type == 'application/pdf'
        # Extract text from PDF
        require 'pdf-reader'
        reader = PDF::Reader.new(temp_file.path)
        text = reader.pages.map(&:text).join("\n")
        temp_file.unlink
        return text.strip.presence || @receipt_file.filename.to_s
      elsif @receipt_file.content_type.start_with?('image/')
        # Extract text from image using OCR
        image = RTesseract.new(temp_file.path)
        text = image.to_s
        temp_file.unlink
        return text.strip.presence || @receipt_file.filename.to_s
      else
        # Fallback to filename
        temp_file.unlink
        return @receipt_file.filename.to_s
      end
    rescue => e
      Rails.logger.error "Text extraction failed: #{e.message}"
      temp_file.unlink
      return @receipt_file.filename.to_s
    end
  end

  def build_prompt_with_text(receipt_text)
    <<~PROMPT
      I have extracted the following text from a receipt/invoice file:
      
      ```
      #{receipt_text}
      ```
      
      Analyze this receipt and extract the following information in JSON format:
      
      {
        "service_name": "the company or service provider name (from 'From:', 'Billed by:', or company header)",
        "amount": number (the total amount paid - look for 'Total', 'Amount Due', etc.),
        "currency": "EUR" or "USD",
        "month": number (1-12, extract from the receipt/invoice date),
        "year": number (4-digit year from the date),
        "status": "paid" or "pending",
        "notes": "brief description of what this expense is for based on the service name eg. for Cursor 'AI tool used for coding'",
        "confidence": "high", "medium", or "low"
      }

      Important instructions:
      - Extract the service_name from the company/provider shown on the receipt (look in headers, "From:" section, logos, company names)
      - Use a clean, readable company name (e.g., "Netflix" not "Netflix Inc." or "NETFLIX INTERNATIONAL B.V.")
      - Extract the TOTAL amount paid (not subtotals or individual line items)
      - Determine currency from symbols: € = EUR, $ = USD, USD = USD, EUR = EUR
      - Look for dates in format like "10/15/2025", "October 15, 2025", "15 Oct 2025" etc.
      - Set status to "paid" if it's a receipt/confirmation, "pending" if it's an invoice/bill due
      - Provide a brief note about what the service is for
      - Set confidence to:
        * "high" if all information is clearly visible and unambiguous
        * "medium" if some information is inferred or partially clear
        * "low" if information is unclear or extracted from filename only
      - If text extraction failed and you only have a filename, do your best to extract information from the filename pattern
    PROMPT
  end


  def format_response(data)
    # Find matching service using fuzzy matching or create new one
    service = nil
    service_name = data["service_name"]
    
    if service_name.present?
      # Try exact match first
      service = Service.find_by(name: service_name)
      
      # If no exact match, try fuzzy matching (case-insensitive, partial match)
      if service.nil?
        # Look for services where the name contains the AI-suggested name or vice versa
        service = Service.where("LOWER(name) LIKE ?", "%#{service_name.downcase}%").first ||
                  Service.where(active: true).find { |s| service_name.downcase.include?(s.name.downcase) }
      end
      
      # If still no match, create new service
      if service.nil?
        begin
          service = Service.create!(
            name: service_name,
            description: data["notes"] || "Auto-created from AI receipt processing",
            amount: data["amount"] || 0,
            currency: data["currency"] || "EUR",
            active: true,
            variable_amount: true, # Mark as variable since amount varies per receipt
            user: User.first # Associate with first user
          )
          Rails.logger.info "Auto-created service '#{service.name}' from AI extraction"
        rescue => e
          Rails.logger.error "Failed to auto-create service: #{e.message}"
        end
      else
        Rails.logger.info "Matched AI-extracted service '#{service_name}' to existing service '#{service.name}'"
      end
    end
    
    {
      service_id: service&.id,
      service_name: service_name,
      amount: data["amount"],
      currency: data["currency"] || "EUR",
      month: data["month"],
      year: data["year"],
      status: data["status"] || "paid",
      notes: data["notes"],
      confidence: data["confidence"] || "medium",
      raw_ai_response: data
    }
  end

  def default_response
    {
      service_id: nil,
      service_name: nil,
      amount: nil,
      currency: "EUR",
      month: Date.current.month,
      year: Date.current.year,
      status: "paid",
      notes: "AI processing failed - please fill manually",
      confidence: "low",
      raw_ai_response: {}
    }
  end
end

