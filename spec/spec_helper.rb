$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'slnky'
require 'slnky/service/route53'

def event_load(name)
  @events ||= {}
  @events[name] ||= begin
    file = File.expand_path("../../test/events/#{name}.json", __FILE__)
    raise "file #{file} not found" unless File.exists?(file)
    Slnky::Message.new(JSON.parse(File.read(file)))
  end
end
