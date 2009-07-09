require 'net/smtp'

class TMail::Maildir
  def self.maildir?(path)
    return false unless File.directory?(path)
    File.directory?(path+"/cur") and File.directory?(path+"/tmp") and File.directory?(path+"/new")
  end

  def self.maildirmake(path, folder = nil)
    if folder == true
      fpath = path
    elsif folder.class == String
      fpath = path + "/"+".#{folder}".gsub(/\//,".")
    else
      fpath = path
    end
    [fpath, fpath+"/cur", fpath+"/new", fpath+"/tmp"].each{|d| Dir.mkdir d unless File.directory? d}
    FileUtils.touch fpath+"/maildirfolder" unless File.exists? fpath+"/maildirfolder" or folder.nil?
  end

  def folders
    TMail::Maildir.folders(self.directory)
  end

  def self.folders(path)
    Dir.new(path).each.select{|d| d.match(/../) and maildir?(File.join(path,d))}
  end

  def send
    Net::SMTP.start( 'localhost', 25 ) do |smtpclient|
      smtpclient.send_message(
        self.to_s, self.from, self.to
      )
    end
  end
end

# And add detection for File#
class File
  def self.maildir?(path)
    TMail::Maildir.maildir? path
  end
end


