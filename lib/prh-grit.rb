require "grit"

class Grit::Tree
  def files(recurse = false)
    o=[]
    self.contents.each do |l|
      if l.class == Grit::Blob
        o << l.name
      elsif l.class == Grit::Tree and recurse == true
        l.rfiles.each {|k| o << l.name+"/"+k}
      end
    end
    o
  end

  # Returns all data for the tree
  #
  def data(recurse = false, blobs = false)
    o={}
    self.contents.each do |l|
      if l.class == Grit::Blob
        o[l.name] = blobs ? l : l.data
      elsif l.class == Grit::Tree and recurse == true
        l.data(recurse,blobs).each {|k,m| o[l.name+"/"+k]=m}
      end
    end
    o
  end

  def rfiles; self.files(true); end
  def rdata; self.data(true); end
  def rblobs; self.data(true,true); end
  def blobs(recurse = false); self.data(recurse,true); end

end

class Grit::Commit
  def files(&args); pp args; self.tree.files(args); end
  def rfiles; self.tree.rfiles; end
  def data(&args); self.tree.data(args); end
  def rdata; self.tree.rdata; end
  def blobs(&args); self.tree.blobs(args); end
  def rblobs; self.tree.rblobs; end
end

class Grit::Index
  # (Lazy) Commit the contents of the index to the head of the named branch
  #   +message+ is the commit message
  #   +branch+ is the named branch
  #
  # Returns a String of the SHA1 of the commit
  def hcommit(message, branch = 'master')
    self.commit(message, [self.repo.commits(branch).first],nil, nil, branch)
  end
end

class Grit::Repo
  def get_head(name)
    self.commits(name).first
  end

  # Very lazy way to get the data for a file in a specific branch

  def data(file,branch = 'master')
    self.get_head(branch).tree./(file).data if self.get_head(branch).tree/(file) if self.get_head(branch)
  end
end
