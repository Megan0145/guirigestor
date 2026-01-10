namespace :brain_dumps do
  desc "Enrich existing brain dumps with AI (clean up dictation errors)"
  task enrich_historic: :environment do
    require 'httparty'
    
    processor = BrainDumpProcessor.new
    existing_tags = BrainDumpTag.pluck(:name)
    
    # Find all brain dumps that haven't been enriched yet
    # (raw_content is nil, meaning they were created before this feature)
    dumps_to_process = BrainDump.where(raw_content: nil)
    total = dumps_to_process.count
    
    if total == 0
      puts "✓ No brain dumps to enrich. All dumps already have raw_content."
      exit
    end
    
    puts "Found #{total} brain dumps to enrich..."
    puts "-" * 50
    
    processed = 0
    failed = 0
    
    dumps_to_process.find_each do |dump|
      print "Processing dump ##{dump.id} (#{dump.date})... "
      
      # Store current content as raw_content (original)
      original_content = dump.content
      
      # Process with AI
      result = processor.process(original_content, existing_tags)
      
      if result[:success] && result[:cleaned_text].present?
        # Update with enriched version, preserve original in raw_content
        dump.update!(
          raw_content: original_content,
          content: result[:cleaned_text]
        )
        
        # Add any suggested tags that don't already exist on this dump
        if result[:suggested_tags].any?
          existing_dump_tags = dump.tags.pluck(:name).map(&:downcase)
          new_tags = result[:suggested_tags].reject { |t| existing_dump_tags.include?(t.downcase) }
          
          new_tags.each do |tag_name|
            tag = BrainDumpTag.find_or_create_by(name: tag_name.downcase)
            dump.tags << tag unless dump.tags.include?(tag)
          end
          
          puts "✓ Enriched (#{new_tags.length} new tags)"
        else
          puts "✓ Enriched"
        end
        
        processed += 1
      else
        # AI failed - just set raw_content = content so we don't reprocess
        dump.update!(raw_content: original_content)
        puts "⚠ AI failed, preserved original (#{result[:error]})"
        failed += 1
      end
      
      # Be nice to the API - small delay between requests
      sleep 0.5
    end
    
    puts "-" * 50
    puts "Done! Processed: #{processed}, Failed: #{failed}, Total: #{total}"
  end
  
  desc "Show brain dumps that need enrichment"
  task check_unenriched: :environment do
    count = BrainDump.where(raw_content: nil).count
    puts "Brain dumps without raw_content (need enrichment): #{count}"
    
    if count > 0
      puts "\nTo enrich them, run:"
      puts "  bundle exec rake brain_dumps:enrich_historic"
    end
  end
end

