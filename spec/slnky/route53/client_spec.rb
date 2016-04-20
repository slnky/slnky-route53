require 'spec_helper'

describe Slnky::Route53::Client, remote: true do
  subject do
    described_class.new
  end
  let(:zone) {subject.get_zones.last} # should be ulive.sh
  let(:id) {'i-165e6b92'}
  let(:ip) {subject.get_ip(id)}

  it 'can get zones' do
    expect(subject.get_zones).not_to be_empty
    expect(subject.get_zones.first.domain).to eq("rgops.com.")
    expect(zone.domain).to eq("ulive.sh.")
  end

  it 'can get ip' do
    expect(ip).to eq('10.49.200.108')
  end

  it 'can get records for zone' do
    expect(subject.get_zone_records(zone.id).count).to be > 0
  end

  it 'can get records for ip' do
    expect(subject.get_records(ip).first.value).to include(ip)
  end

  it 'can remove records for id' do
    expect(subject.remove_records(id).first.value).to include(ip)
  end
end
