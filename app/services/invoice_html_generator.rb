class InvoiceHtmlGenerator
  include HTTParty
  base_uri "https://api.openai.com/v1"

  INVOICE_PROMPT = <<~PROMPT
    You are an expert invoice generator. Your job is to generate a beautifully formatted, professional HTML invoice based on the invoice data provided.

    Follow this exact structure and styling:

    - Use clean, modern HTML with inline styles (no external CSS).
    - Use two-column layout for the header: sender info on the left, recipient info on the right.
    - Include the invoice number, issue date, due date, and total amount due, styled cleanly.
    - Below the header, show a full-width table with line items. Columns: "Item", "Quantity", "Rate", "Amount".
    - Format all currency values in EUR (e.g. €3,000.00).
    - Below the table, display a "Total" row with the final amount.
    - Below that, show a "Description" section (brief paragraph form).
    - Lastly, add a "Payment Terms" section, styled subtly, with IBAN and NIF if available.

    Make the layout resemble a standard modern invoice, similar to one from invoice-generator.com.

    Now generate the full HTML based on the invoice data below:
  PROMPT
  
  def initialize(invoice)
    @invoice = invoice
  end

  def call
    api_key = ENV['OPENAI_API_KEY']
    return error_html("Missing OpenAI API key") if api_key.blank?

    prompt = build_prompt
    Rails.logger.info("[OpenAI Invoice] Prompt Length: #{prompt.length} characters")

    body = {
      model: "gpt-4o", # or "gpt-4"
      messages: [
        { role: "system", content: INVOICE_PROMPT },
        { role: "user", content: prompt }
      ],
      temperature: 0.3
    }

    response = self.class.post("/chat/completions",
      headers: {
        "Authorization" => "Bearer #{api_key}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )

    Rails.logger.info("[OpenAI Invoice] Raw Response: #{response.body}")

    raw = response.parsed_response.dig("choices", 0, "message", "content")

    if raw.blank?
      return error_html("OpenAI response was empty or invalid.")
    end

    clean_html(raw)
  rescue => e
    Rails.logger.error("[OpenAI Invoice] Exception: #{e.message}")
    error_html("Error generating invoice HTML: #{e.message}")
  end

  private

  def error_html(message)
    "<p style='color:red;'>#{message}</p>"
  end

  def clean_html(raw)
    # Remove ```html markdown wrappers if they exist
    raw.gsub(/\A```(?:html)?\s*|\s*```\z/, '').strip
  end

  def build_prompt
    line_items = @invoice.invoice_line_items.map do |item|
      "- #{item.description}: €#{'%.2f' % item.rate} x #{item.quantity}"
    end.join("\n")

    <<~PROMPT
      Please generate an HTML invoice with the following data. Use <table> elements with inline CSS. Put the issue and due date on the top-right. Align totals clearly. No external stylesheets.

      FROM:
      #{@invoice.sender_company_name}
      #{@invoice.sender_address}
      Tax ID: #{@invoice.sender_tax_number}

      TO:
      #{@invoice.recipient_company_name}
      #{@invoice.recipient_address}
      VAT: #{@invoice.recipient_vat_number}

      ISSUE DATE: #{@invoice.issued_on}
      DUE DATE: #{@invoice.due_on}

      INVOICE DESCRIPTION:
      #{@invoice.description}

      LINE ITEMS:
      #{line_items}

      TOTAL: €#{'%.2f' % @invoice.total_amount}
    PROMPT
  end
end