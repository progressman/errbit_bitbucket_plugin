require 'bitbucket_rest_api'

module ErrbitBitbucketPlugin
  class IssueTracker < ErrbitPlugin::IssueTracker
    LABEL = 'bitbucket'

    NOTE = 'Please configure your github repository in the <strong>BITBUCKET REPO</strong> field above.  Please enter your username and password.'

    FIELDS = {
      username: {
        placeholder: 'Your username on bitbucket'
      },
      password: {
        placeholder: 'Your password on bitbucket'
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
    
    def self.icons
      @icons ||= {
        create: [ 'image/png', ErrbitBitbucketPlugin.read_static_file('bitbucket_create.png') ],
        goto: [ 'image/png', ErrbitBitbucketPlugin.read_static_file('bitbucket_create.png') ],
        inactive: [ 'image/png', ErrbitBitbucketPlugin.read_static_file('bitbucket_inactive.png') ],
      }
    end

    def configured?
      project_id
    end

    def project_id
      app.bitbucket_repo
    end

    def errors
      errors = []
      if self.class.fields.detect {|f| options[f[0]].blank? }
        errors << [:base, 'You must specify your BitBucket username and password']
      end
      if repo.blank?
        errors << [:base, 'You must specify your BitBucket repository url.']
      end
      errors
    end

    # def check_params
    #   @params['username'] ? {} : { username: 'Username must be present' }
    # end

    def comments_allowed?
      false
    end

    def bitbucket_client
      BitBucket.new login: params['username'], password: params['password']
    end

    def create_issue(problem, reported_by = nil)
      begin
        issue_params = {
          title: "[#{ problem.environment }][#{ problem.where }] #{problem.message.to_s.truncate(100)}",
          content: self.class.body_template.result(binding).unpack('C*').pack('U*'),
          kind: 'bug',
          priority: 'major'
        }
        issue = bitbucket_client.issues.create(
          params['username'],
          project_id,
          issue_params
        )

        problem.update_attributes(
          issue_link: bitbucket_url(issue.body.resource_uri),
          issue_type: 'bug'
        )

      rescue BitBucket::Error::Unauthorized
        raise ErrbitBitbucketPlugin::AuthenticationError, 'Could not authenticate with Bitbucket. Please check your username and password.'
      end
    end

    def bitbucket_url(resource_uri)
      'https://bitbucket.org/' + resource_uri.split('/')[3, 5].join('/').gsub(/issues/, 'issue')
    end

    def url
      'https://www.atlassian.com/software'
    end
  end
end
