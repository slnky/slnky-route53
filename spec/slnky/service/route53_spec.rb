require 'spec_helper'

describe Slnky::Service::Route53 do
  subject { described_class.new("http://localhost:3000", test_config) }
  let(:terminated_event) { event_load('terminated')}
  let(:fake_event) { event_load('fake')}

  # it 'does something useful' do
  #   expect(false).to eq(true)
  # end

  it 'handles terminated' do
    expect(subject.handle_terminated(terminated_event.name, terminated_event.payload)).to eq(true)
  end

  it 'handles terminated with missing instance' do
    expect(subject.handle_terminated(fake_event.name, fake_event.payload)).to eq(true)
  end
end
