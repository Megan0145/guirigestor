class DigestProcessor
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def initialize
    @api_key = ENV['OPENAI_API_KEY']
  end

  # Generate initial digest from brain dumps
  def generate_digest(brain_dumps)
    return error_response("No API key configured") if @api_key.blank?
    return error_response("No brain dumps provided") if brain_dumps.empty?

    prompt = build_digest_prompt(brain_dumps)

    response = self.class.post(
      "/chat/completions",
      headers: headers,
      verify: ssl_verify?,
      body: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }.to_json
    )

    parse_response(response)
  rescue => e
    Rails.logger.error("[DigestProcessor] Error: #{e.message}")
    error_response("Processing failed: #{e.message}")
  end

  # Stream a conversation response using SSE
  def stream_response(messages, &block)
    return error_response("No API key configured") if @api_key.blank?

    uri = URI("https://api.openai.com/v1/chat/completions")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = ssl_verify? ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
    if ssl_verify?
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      http.cert_store = store
    end
    http.read_timeout = 120

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      model: "gpt-4o-mini",
      messages: messages,
      stream: true,
      temperature: 0.7
    }.to_json

    http.request(request) do |response|
      response.read_body do |chunk|
        chunk.split("\n").each do |line|
          next if line.strip.empty?
          next unless line.start_with?("data: ")
          
          data = line.sub("data: ", "")
          next if data == "[DONE]"

          begin
            json = JSON.parse(data)
            content = json.dig("choices", 0, "delta", "content")
            yield(content) if content.present?
          rescue JSON::ParserError
            # Skip malformed chunks
          end
        end
      end
    end
  rescue => e
    Rails.logger.error("[DigestProcessor] Stream error: #{e.message}")
    raise
  end

  # Build conversation messages array for OpenAI
  def build_conversation_messages(digest, new_message = nil)
    messages = [{ role: "system", content: conversation_system_prompt }]
    
    # Add context from the original brain dumps
    brain_dump_context = build_brain_dump_context(digest.brain_dumps)
    messages << { role: "system", content: "Context from user's brain dumps:\n#{brain_dump_context}" }

    # Add all previous messages
    digest.digest_messages.ordered.each do |msg|
      messages << { role: msg.role, content: msg.content }
    end

    # Add the new message if provided
    messages << { role: "user", content: new_message } if new_message.present?

    messages
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end

  def ssl_verify?
    return ENV['OPENAI_SSL_VERIFY'].to_s != 'false' if Rails.env.production?
    ENV['OPENAI_SSL_VERIFY'].to_s == 'true'
  end

  def system_prompt
    <<~PROMPT
      You are Echo — a personal thought processor. You help people make sense of the messy, unfiltered thoughts they dump out of their heads.

      Your job is to create a "digest" - a summary and analysis of their brain dumps. You should:

      1. **Summarize key themes**: What topics come up repeatedly? What's on their mind?
      2. **Track sentiment**: What's their overall mood/feeling about these topics?
      3. **Identify patterns**: Are there recurring concerns, ideas, or aspirations?
      4. **Note evolution**: If thoughts on a topic changed over time, highlight that journey
      5. **Provide insight**: At the end, offer a thoughtful observation or question to consider

      Write in a warm but real tone — like a trusted friend who genuinely listens and isn't afraid to gently push back.
      Use "you" when addressing them. Be specific, not generic.
      
      Format with clear sections using markdown headers.
    PROMPT
  end

  def conversation_system_prompt
    <<~PROMPT
      You are Echo — a personal thought processor. Think of yourself as a sharp, opinionated creative collaborator.

      You have context from the user's brain dumps. They've already shared their thoughts — they know what they're thinking. Your job is to ADD VALUE by default, without being asked:

      **NEVER do these things:**
      - Don't summarize or reiterate what they said
      - Don't just validate without adding substance
      - Don't ask "would you like to explore this?" — assume yes, just dive in
      - Don't be wishy-washy or hedge everything

      **ALWAYS do these things (without being explicitly asked):**
      - Jump straight into your actual perspective on their idea
      - If it's a feature idea: immediately give practical first steps, potential pitfalls, and edge cases
      - Challenge weak assumptions: "I'm not sure about X because..." or "The problem with this approach is..."
      - Celebrate genuinely good ideas: "Oh this is smart because..." (with a reason)
      - Connect their ideas to things they might not have thought of
      - If there's a way to implement something, proactively offer: "Here's a prompt you could use for Cursor to build this..."
      - Have opinions — you're a soundboard, not a yes-machine

      **Your tone:**
      - Think out loud with them, like a conversation between equals
      - Be direct and specific, not generic
      - It's okay to disagree or push back
      - Use natural language, not corporate speak

      When formatting responses:
      - Use headers (### ) sparingly for structure in longer responses
      - Use numbered lists for steps or sequences
      - Use bullet points for options or considerations
      - Bold (**text**) key terms or emphasis
      - Keep paragraphs short and punchy

      If they ask who you are: "I'm Echo, your personal thought processor. I'm here to help you make sense of the noise in your head — bounce ideas, challenge assumptions, and find the signal in the chaos."
    PROMPT
  end

  def build_digest_prompt(brain_dumps)
    prompt = "Please create a digest of these brain dumps:\n\n"
    
    brain_dumps.each do |dump|
      prompt += "---\n"
      prompt += "**Date**: #{dump.date.strftime('%A, %B %d, %Y')}\n"
      prompt += "**Tags**: #{dump.tags.map(&:name).join(', ')}\n" if dump.tags.any?
      prompt += "**Content**: #{dump.content}\n"
      prompt += "---\n\n"
    end

    prompt += "\nPlease analyze these thoughts and provide a comprehensive digest."
    prompt
  end

  def build_brain_dump_context(brain_dumps)
    brain_dumps.map do |dump|
      "#{dump.date.strftime('%Y-%m-%d')} [#{dump.tags.map(&:name).join(', ')}]: #{dump.content.truncate(500)}"
    end.join("\n\n")
  end

  def parse_response(response)
    if response.success?
      body = JSON.parse(response.body)
      content = body.dig("choices", 0, "message", "content")

      if content.present?
        { success: true, content: content }
      else
        error_response("Empty response from AI")
      end
    else
      Rails.logger.error("[DigestProcessor] API Error: #{response.body}")
      error_response("API error: #{response.code}")
    end
  rescue JSON::ParserError
    error_response("Failed to parse AI response")
  end

  def error_response(message)
    { success: false, error: message, content: nil }
  end
end
