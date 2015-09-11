require 'errbit_bitbucket_plugin/version'
require 'errbit_bitbucket_plugin/error'
require 'errbit_bitbucket_plugin/issue_tracker'
require 'errbit_bitbucket_plugin/rails'

module ErrbitBitbucketPlugin
  def self.root
    File.expand_path '../..', __FILE__
  end
  
  def self.read_static_file(file)
    File.read(File.join(self.root, 'static', file))
  end
end

ErrbitPlugin::Registry.add_issue_tracker(ErrbitBitbucketPlugin::IssueTracker)
