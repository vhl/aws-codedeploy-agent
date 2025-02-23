gem_root = File.dirname(File.dirname(File.dirname(__FILE__)))

require 'aws-sdk-core'
require "#{gem_root}/lib/aws/add_service_wrapper"
require "#{gem_root}/lib/aws/plugins/certificate_authority"
require "#{gem_root}/lib/aws/plugins/deploy_control_endpoint"
require "#{gem_root}/lib/aws/plugins/deploy_agent_version"

version = '1.0.0'
SERVICE_CLASS_NAME = 'CodeDeployCommand'

if InstanceAgent::Config.config[:enable_auth_policy]
  bundled_apis = Dir.glob(File.join(gem_root, 'apis', 'CodeDeployCommandSecure.api.json')).group_by do |path|
    File.basename(path).split('.').first
  end
elsif InstanceAgent::Config.config[:use_mock_command_service]
  bundled_apis = Dir.glob(File.join(gem_root, 'apis', 'ApolloDeployControlService_mock.api.json')).group_by do |path|
    File.basename(path).split('.').first
  end
else
  bundled_apis = Dir.glob(File.join(gem_root, 'apis', 'CodeDeployCommand.api.json')).group_by do |path|
    File.basename(path).split('.').first
  end
end

bundled_apis.each do |svc_class_name, api_versions|
  svc_class = Aws.add_service(SERVICE_CLASS_NAME, api: JSON.parse(File.read(api_versions.first), max_nesting: false))
  svc_class.const_set(:VERSION, version)
  Aws::CodeDeployCommand::Client.add_plugin(Aws::Plugins::CertificateAuthority)
  Aws::CodeDeployCommand::Client.add_plugin(Aws::Plugins::DeployControlEndpoint)
  Aws::CodeDeployCommand::Client.add_plugin(Aws::Plugins::DeployAgentVersion)
end
