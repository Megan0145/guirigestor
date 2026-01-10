namespace :brain_dumps do
  desc "Seed production database with brain dumps from development"
  task seed_production: :environment do
    puts "Seeding brain dumps..."
    
    # Brain dumps exported from development on 2026-01-10
    brain_dumps_data = [
      {
        date: "2026-01-10",
        content: "test",
        raw_content: nil,
        tags: ["n"]
      },
      {
        date: "2026-01-10",
        content: <<~CONTENT.strip,
          Future of Brain Dump Feature
          The brain dump evolves into a Thought Processor with digest functionality:
          Digest Cadences:
          Daily digest
          Weekly digest
          Monthly digest
          Annual digest (like Spotify Wrapped)
          Core Concept:
          Track thought evolution on specific topics/tags over time. Example: "Future of AI" - Monday I think it's serious, Tuesday I think we can still move forward with X. The system should capture these shifts.
          AI Integration (when ready):
          Distill raw word vomit into clear insights
          Process messy dictation into readable summaries
          Auto-suggest tags based on content
          "Wrapped" Style Summaries:
          At month/year end, show:
          How many times thinking shifted on a topic
          Where thoughts started
          Where they ended up
          Significant perspective changes
          Overall patterns in decision-making
          Key Insight:
          My mind changes constantly (proven by changing my mind about daily vs weekly digests mid-sentence). The feature should embrace and visualize this rather than hide it.
        CONTENT
        raw_content: nil,
        tags: ["brain dump roadmap", "feature ideas"]
      },
      {
        date: "2026-01-10",
        content: <<~CONTENT.strip,
          Develop this thought for me - unbiased and not prompted to just categorically agree with your opinion - I'm able to word vomit and ai will then go and verify and add to my opinion. Needs to feel conversational like a soundboard. So after word vmitting and submitting the form I can either from the admin panel or else the front end be able to click a button that maybe it doesn't develop with AI but open dialogue or no that's not really it I don't know maybe like a word vomit match where it's like a match between me and AI where I'm word vomiting on ideas AI is coming back to me with oh but have you thought about this and I agree with this I actually disagree with this because of these fac where I'm able to voice my opinions as they come into my head because I have like literally 1 million thoughts every second that's one feature
        CONTENT
        raw_content: nil,
        tags: ["brain dump", "ai soundboard"]
      },
      {
        date: "2026-01-10",
        content: <<~CONTENT.strip,
          Separately before I forget another feature is that I want to be able to maybe on the admin panel actually batch process thoughts where I'm able to like use a batch action to go down through thoughts and select certain ones send it over to AI and get a synopsis for where I started where I came to again unbiased like I really don't want AI to be categorically agreeing with me I want someone to have fights with me basically without like defensiveness or it's more difficult with humans so that's where my top process going and selecting thoughts that are all kind of in the same stream sending over to AI and opening I don't know what you call it but like a back-and-forth yeah I think that's actually the word that I want like back-and-forth actually I would prefer this on the front end so not on the admin panel on the front I'd like a nicely designed page that fits in so obviously on a separate to the one where I bring them but it fits in with the rest of the styling where I'm able to like view in a table and select thoughts send them over to AI and open a dialogue where yeah the first part of that conversation would be the first step for me as a user I'm also only ever gonna be the Singular user on this platform but the first step for me would be to view that table view back select click open dial or open brainstorm yeah actually open brainstorm send it yeah so I click that I submit it a separate which opens a chat based interface so similar to chat CBT but not chatty BT it's gonna be based on at work potentially based on opening IBI where automatically when I land on that page on render it will still be processing the fact that I've just sent over the context I don't know what the prompt will be just yet and I wanna be very careful with the prompt to yeah keep in mind that I almost want A to argue with me I don't really like I still wanted to be neutral but I wanna be very very careful because I think AI is built to agree with you regardless of what you say so I wanna be very careful that doesn't happen and I wanted to feel natural like human language so for example I have an employee that sometimes I'll say he he'll say something to me and then I'll say I'm curious how that person would respond to that thing or should we be accounting for this and it's never like in a defensive way that I'm saying it it's just that I'm trying to anticipate problems when things come up and have like a back-and-forth kind of conversation so that's what I want the conversation to feel like so yeah when you land on this page it should be sending over the context and the prompt to AI realistically when you land on the page you're gonna get those like dots that show that AI is thinking that AI will come back and be like oh that's like an interesting thought have you thought about this actually sorry the very very first message that I sent back should be like really not detailed but like high-level bullet points of okay this is where your top process started this is where you got it in the end like this was the conclusion from what I can see from the messages that you've sent over of all of the various different thoughts I can see on like the third one that you digress a little bit and completely changed your point of view what happened there and to further on have you thought about this thing and it looks like you've decided that the conclusion is this like have you thought about this and et cetera so that's where I'm going with it
        CONTENT
        raw_content: nil,
        tags: ["brain dump", "brain dump roadmap", "feature ideas", "personal software"]
      },
      {
        date: "2026-01-10",
        content: <<~CONTENT.strip,
          other thing that I'm thinking for the random feature is that so like this whole idea of distilling my thoughts and like almost having like not an argument with me but questioning or I don't know what the word it is but like having a back-and-forth with me and I've mentioned that I don't want AI to be combative with me so I don't know how the prompt will look but for scenarios where I'm talking about like personal altercations or interactions with other humans I would like it to gain context overtime of my personality which then gets built into the prompt so I think if like a prompt is persisted in the database then get sent over to AI I want that prompt to be continuously updated based on these brains that I'm doing that you know it will pick up on like personality pattern that like oh maybe I'm too you know submissive or and there's a pattern of yeah so maybe there's like a feature that you can see personality development overtime that like previously like two months ago yo I felt attacked by this thing whereas now you're saying I have an interaction with this person they responded defensively that's not my problem so you can see overtime that your personality has developed where you have shifted your wiring to not look at like this person is attacking me to I recognise as a psychological pattern that how this person responded to me isn't my problem there's probably deep-seated you know traits that they have or wiring that they have on their side that are now affecting how they communicate with me so actually this wasn't personal at all this was to do with their previous history the other thing that I'm thinking now is a potential you can tag like people that you interact with so that you can track overtime is there a pattern of this person being dismissive is there a pattern of this person being you know it needs to be on the positive side so like this person constantly likes you and like once you can tell from their interactions that they're trying to like they're looking out for the best for you and this person is very loyal this person is protective and this person diminishes you so maybe like yeah you can talk like certain people that's yeah that's the end of my top process
        CONTENT
        raw_content: nil,
        tags: ["personality development", "ai soundboard"]
      },
      {
        date: "2026-01-10",
        content: <<~CONTENT.strip,
          last brain done because I realised that I'm actually realising as because I'm on a local host and I realising as I look at this feature how much I actually needed what would be helpful in the history is to see like almost a panel side-by-side of like my brain because I'm dicta are so wordy like they're full of absolute crap and then I eventually by talking get to a point that I'm like oh yeah like that's the point that I was trying to make it would be handy in the history that I'm still developing this sort actually where I can yeah I can see side-by-side like on the left-hand side and I would guess anticipating knowing how my brain works on the left-hand side I'll be able to see all of the words that have been dictated for me brain dumping or word vomiting and I think actually maybe the left-hand side panel should say word vomit and that should be shown by default like to fill up like full width of the container but then there should be the ability to show I don't know what the name would be but like a tab where you're able to click and then which is collapsed by default but you click it which then snaps over with an animation to show side-by-side where my initial brain or word vomit is on the left-hand side which feels like 50% of the full contain work and then on the right hand side it's like distillation of garbage or something that I've input input garbage or trash trash input that's no I don't wanna do that cleaned up top process maybe I don't I also don't want like those distillations though on the right hand side to feel like they're written by AI so yeah I want like points and stuff because that's how my brain works like I see a bunch of bullet points and I'm like okay well I need to do this this this this but I think very often AI can it just doesn't feel human so like yeah the whole idea behind every feature that I'm feeding to you is I wanna have a soundboard basically that will be defensive to the right extent where there is no arguments but well sorry not that there's no arguments there's no arguments for argument sake but won't just you know sugarcoat everything
        CONTENT
        raw_content: nil,
        tags: ["brain dump", "feature ideas"]
      },
      {
        date: "2026-01-10",
        content: <<~CONTENT.strip,
          very last thing it would be very useful if I tagged certain brain dumps that I would be able to connect to an agent so like if it's a feature specific to giddy store which is the name of this code base that I could then like there should be a button to say go build this for me that went clicked goes and actually connects to Cursor which is connected to my giddy historic giddy his throat spelt GUIRIGESTO or code base and will actually build a feature for me and notify or maybe not notify me but like yeah go and build it and then I can go back into the co-pay myself because I think actually when I release this a lot of the brains that I have are about where we can take this prod so brains are useful but yeah I think the more I think about this the most value does come out of being able to send this shit over day I am both to get an opinion and get a sounding board and then also get an AI agent to go and build the shit that I'm talking about for this this product there might be a scenario in the future where and that's why I'm kind of being careful about the wording of that button where I say go build this for me but there might be a scenario in the future where it's like go build this four and then when you click that button it's actually a drop-down and you're able to select multiple different repositories and which will then connect to that RuPaul tree and go build a feature for that repository but yeah I do definitely want to have a button that's like go build this for me that will be scoped to guirigestor
        CONTENT
        raw_content: nil,
        tags: ["brain dump", "feature ideas", "ai agents"]
      }
    ]
    
    created_count = 0
    skipped_count = 0
    
    brain_dumps_data.each_with_index do |data, index|
      # Check if similar content already exists (prevent duplicates)
      existing = BrainDump.find_by("content LIKE ?", data[:content][0..50] + "%")
      
      if existing
        puts "  [#{index + 1}] Skipped - similar content already exists"
        skipped_count += 1
        next
      end
      
      dump = BrainDump.new(
        date: Date.parse(data[:date]),
        content: data[:content],
        raw_content: data[:raw_content]
      )
      
      # Create/find and associate tags
      data[:tags].each do |tag_name|
        tag = BrainDumpTag.find_or_create_by(name: tag_name.downcase)
        dump.tags << tag
      end
      
      if dump.save
        puts "  [#{index + 1}] Created brain dump with #{data[:tags].length} tags"
        created_count += 1
      else
        puts "  [#{index + 1}] ERROR: #{dump.errors.full_messages.join(', ')}"
      end
    end
    
    puts "-" * 50
    puts "Done! Created: #{created_count}, Skipped: #{skipped_count}"
  end
end

