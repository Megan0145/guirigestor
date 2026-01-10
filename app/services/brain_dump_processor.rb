class BrainDumpProcessor
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def initialize
    @api_key = ENV['OPENAI_API_KEY']
  end

  def process(raw_text, existing_tags = [])
    return error_response("No API key configured") if @api_key.blank?
    return error_response("No content to process") if raw_text.blank?

    prompt = build_prompt(raw_text, existing_tags)
    
    response = self.class.post(
      "/chat/completions",
      headers: {
        "Authorization" => "Bearer #{@api_key}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: prompt }
        ],
        temperature: 0.3,
        response_format: { type: "json_object" }
      }.to_json
    )

    parse_response(response)
  rescue => e
    Rails.logger.error("[BrainDumpProcessor] Error: #{e.message}")
    error_response("Processing failed: #{e.message}")
  end

  private

  def system_prompt
    <<~PROMPT
      You are a helpful assistant that cleans up voice-transcribed text and suggests relevant tags.
      
      Your job is to:
      1. Fix transcription errors (misheard words, missing punctuation, run-on sentences)
      2. Clean up the text to be readable while preserving the original meaning and voice
      3. Keep it natural - don't make it overly formal or change the tone
      4. Suggest 1-5 relevant tags/topics based on the content
      
      Always respond in JSON format with these fields:
      - cleaned_text: The cleaned up version of the input
      - suggested_tags: An array of lowercase tag strings (1-5 tags)
      - changes_made: Brief description of what was cleaned up (optional)
    PROMPT
  end

  def build_prompt(raw_text, existing_tags)
    prompt = "Please clean up this voice-transcribed text and suggest relevant tags:\n\n"
    prompt += "---\n#{raw_text}\n---\n"
    
    if existing_tags.any?
      prompt += "\nExisting tags in the system (prefer these if relevant): #{existing_tags.join(', ')}"
    end
    
    prompt
  end

  def parse_response(response)
    if response.success?
      body = JSON.parse(response.body)
      content = body.dig("choices", 0, "message", "content")
      
      if content.present?
        result = JSON.parse(content)
        {
          success: true,
          cleaned_text: result["cleaned_text"] || "",
          suggested_tags: (result["suggested_tags"] || []).map(&:downcase).uniq,
          changes_made: result["changes_made"]
        }
      else
        error_response("Empty response from AI")
      end
    else
      Rails.logger.error("[BrainDumpProcessor] API Error: #{response.body}")
      error_response("API error: #{response.code}")
    end
  rescue JSON::ParserError => e
    error_response("Failed to parse AI response")
  end

  def error_response(message)
    {
      success: false,
      error: message,
      cleaned_text: nil,
      suggested_tags: []
    }
  end
end

