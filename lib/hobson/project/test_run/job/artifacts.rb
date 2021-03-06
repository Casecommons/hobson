class Hobson::Project::TestRun::Job

  def file_namespace
    @file_namespace ||= Pathname.new("/testruns/#{test_run.id}/jobs/#{index}")
  end

  def artifacts
    data.inject({}){ |data, (key, value)|
      key.match(/^artifact:(.*)$/) ? data.update($1 => value) : data
    }
  end

  def save_artifact path, options={}
    path = workspace.root.join(path.to_s)
    name = options.delete(:name) || (path.relative? ? path.relative_path_from(workspace.root) : path.basename)
    options[:key] = file_namespace.join(name).to_s[1..-1]
    options[:content_type] ||= 'text/plain'
    options[:body] ||= path.read
    options[:public] = true unless options.has_key?(:public)
    file = Hobson.files.create(options)
    public_url = CGI::unescape(file.public_url)
    self["artifact:#{name}"] = public_url
    logger.info "saving artifact #{name} -> #{public_url}"
    file
  end

end
