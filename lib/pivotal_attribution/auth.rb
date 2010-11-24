module PivotalAttribution
  class Auth
    def self.instance
      @@instance ||= Auth.new
    end
    def self.retrieve(project_id, username, password)
      instance.retrieve(project_id, username, password)
    end

    def retrieve(project_id, username, password)
      #TODO Secure me!
      auth = `curl -u #{username}:#{password} -X GET https://www.pivotaltracker.com/services/v3/tokens/active`
      @token = auth.match(/<guid>(.*)<\/guid>/)[1]
    end
  end
end
