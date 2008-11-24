# This is a small library of "essential" routines

%w(
  net/ssh
  pp
  git
).each {|r| require r}

class Git::Base
  # get_branch is short for "GET ME THAT BRANCH" - ie just do it, trounce
  # anything in the way, make sure config is set to merge from origin and that
  # origin gets merged
  def get_branch(branch,*opts)
    debug 7, "Git::get_branch #{branch} opts=#{opts}"
    local=self.branches.local.map{|l| l.full}.grep(Regexp.new("^#{branch}$"))
    remote=self.branches.remote.map{|l| l.full}.grep(Regexp.new("^origin/#{branch}$"))
    if local.any? and remote.any?
      debug 7, "Git::get_branch just checkout and update"
      self.config("remote.#{branch}.remote", "origin")
      self.config("remote.#{branch}.merge", "refs/heads/#{branch}")
      self.checkout(branch)
      self.pull("origin",branch)
    elsif local.any?
      debug 7, "Git::get_branch get local and push"
      self.push("origin",branch)
    elsif remote.any?
      debug 7, "Git::get_branch get remote"
      self.config("remote.#{branch}.remote", "origin")
      self.config("remote.#{branch}.merge", "refs/heads/#{branch}")
      self.checkout("origin/#{branch}", :new_branch => branch)
      self.pull("origin",branch)
    else
      debug 7, "Git::get_branch new branch"
      self.checkout("zero",:new_branch => branch)
      self.config("remote.#{branch}.remote", "origin")
      self.config("remote.#{branch}.merge", "refs/heads/#{branch}")
      self.push("origin",branch)
    end
  end

  # Now just push everything in this branch and make sure it goes.
  def push_branch(branch = self.current_branch,*opts)
    debug 7, "Git::push_branch #{branch} opts=#{opts}"
    # really want to be able to add :force=>true...
    self.push("origin",branch)
  end
end

