require 'bitbucket_rest_api'

module ErrbitBitbucketPlugin
  class IssueTracker < ErrbitPlugin::IssueTracker

    LABEL = 'Bitbucket'

    NOTE = 'Please configure your butbucket account.'

    FIELDS = {
      :username => {
        :placeholder => "Your username on bitbucket"
      },
      :password => {
        :placeholder => "Your password on bitbucket"
      },
      :bitbucket_repo => {
        :placeholder => "Your bitbucket repo"
      }
    }

    def self.label
      LABEL
    end

    def self.note
      NOTE
    end

    def self.fields
      FIELDS
    end

    def self.body_template
      @body_template ||= ERB.new(File.read(
        File.join(
          ErrbitBitbucketPlugin.root, 'views', 'bitbucket_issues_body.txt.erb'
        )
      ))
    end

    def configured?
      project_id
    end

    def project_id
      app.bitbucket_repo
    end

    def username
      app.bitbucket_username
    end

    def errors
      errors = []
      if self.class.fields.detect {|f| params[f[0]].blank?}
        errors << [:base, 'You must specify your Bitbucket username and password.']
      end
      errors
    end

    def check_params
      if @params['username']
        {}
      else
        { :username => 'Username must be present' }
      end
    end

    def comments_allowed?
      false
    end

    def bitbucket_client
      BitBucket.new :login => params['username'], :password => params['password']
    end

    def create_issue(problem, reported_by = nil)
      begin
        issue_params = {
          :title => "[#{ problem.environment }][#{ problem.where }] #{problem.message.to_s.truncate(100)}",
          :content => self.class.body_template.result(binding).unpack('C*').pack('U*'),
          :kind => 'bug'
        }
        issue = bitbucket_client.issues.create(
          username,
          project_id,
          issue_params
        )
        @url = "https://bitbucket.com/#{issue.body.resource_uri}"
        problem.update_attributes(
          :issue_link => @url,
          :issue_type => 'bug'
        )

      rescue BitBucket::Error::Unauthorized
        raise ErrbitBitbucketPlugin::AuthenticationError, "Could not authenticate with Bitbucket.  Please check your username and password."
      end
    end

    def url
      "https://www.atlassian.com/software"
    end
  end
end
