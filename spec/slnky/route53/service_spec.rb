require 'spec_helper'

describe Slnky::Route53::Service do
  subject do
    s = described_class.new
    s.client = Slnky::Route53::Mock.new
    s
  end
  let(:test_event) { slnky_event('test') }
  let(:terminated_event) { slnky_event('terminated') }
  let(:fake_event) { slnky_event('fake') }

  it 'handles event' do
    # test that the handler method receives and responds correctly
    expect(subject.handle_test(test_event.name, test_event.payload)).to eq(true)
  end

  it 'handles terminated' do
    expect(subject.handle_terminated(terminated_event.name, terminated_event.payload)).to eq("remove i-b278d302")
  end

  it 'handles terminated with missing instance' do
    expect(subject.handle_terminated(fake_event.name, fake_event.payload)).to eq("i-12345678 not found")
  end
end
