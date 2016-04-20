require 'spec_helper'

describe Slnky::Route53::Client, remote: true do
  subject do
    described_class.new
  end
  let(:zone) {subject.get_zones.last} # should be ulive.sh
  let(:ip) {subject.get_ip('i-165e6b92')}

  it 'can get zones' do
    expect(subject.get_zones).not_to be_empty
    expect(subject.get_zones.first.name).to eq("rgops.com.")
    expect(zone.name).to eq("ulive.sh.")
  end

  it 'can get ip' do
    expect(ip).to eq('10.49.200.108')
  end

  it 'can get records for ip' do
    expect(subject.get_zone_records(zone.id)).to eq('blarg')
  end
end
