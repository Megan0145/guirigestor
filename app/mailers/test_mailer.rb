class TestMailer < ApplicationMailer
  default from: 'megan@guirigestor.com'

  def hello
    mail(
      subject: 'Hello from Postmark',
      to: 'megan@guirigestor.com',
      from: 'megan@guirigestor.com',
      html_body: '<strong>Hello</strong> dear Postmark user.',
      track_opens: 'true',
      message_stream: 'outbound')
  end
end
