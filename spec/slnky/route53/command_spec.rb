require 'spec_helper'

describe Slnky::Route53::Command do
  subject do
    s = described_class.new
    s.client = Slnky::Route53::Mock.new
    s
  end
  let(:echo) { slnky_command('echo') }
  let(:help) { slnky_command('help') }
  let(:echo_response) { slnky_response('test-route', 'spec') }
  let(:help_response) { slnky_response('test-route', 'spec') }

  # it 'handles echo' do
  #   # make sure the command handler does not raise an error
  #   expect { subject.handle(echo.name, echo.payload, echo_response) }.to_not raise_error
  #   # validate that the correct output is available in the response object
  #   expect(echo_response.trace).to include("test echo")
  # end

  it 'handles help' do
    expect { subject.handle(help.name, help.payload, help_response) }.to_not raise_error
    expect(help_response.trace).to include("route53 has no additional commands")
  end
end
