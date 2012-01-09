#
# 
#
#

require 'ptools'

class TreeBuilder

  def initialize(path, keywords = {}, templatePath = "" )
    @templates = []
    @templatePath = (templatePath=="")?File.expand_path(File.dirname(__FILE__))+"/templates/":templatePath
    Dir.foreach(@templatePath) do |filename|
      if File.directory?(@templatePath+filename) && filename!="." && filename!=".."
        @templates.push(filename)
      end

    end
    @path, @keywords = path, keywords
  end

  def buildFromTemplate(name, templateName)
    if !File.exists?(@templatePath+templateName) 
      puts "Template doesn't exist in #{@templatePath}"
      return
    end
    puts "Creating #{name} from template #{templateName}"
    safeMakeDir(name, @path)
    buildTreeBranch(@path+name+"/", @templatePath+templateName+"/")
  end

  def listTemplates()
    puts @templates
  end
  
private
###             Main crawling functions              ###  
  def safeMakeDir(name, path)
    directoryName = path+name
    if FileTest::directory?(directoryName)
      puts "Directory #{directoryName} exists"
      return
    end
    Dir::mkdir(directoryName)
    puts "Directory #{name} created"
  end
  
  def buildTreeBranch(path, templatePath)
    Dir.foreach(templatePath) do |filename|
      #skip current and parent directory
      next if filename=="." || filename==".." 
      if File.directory?(templatePath+filename) then
        safeMakeDir(filename, path)
        # go deeper
        buildTreeBranch(path+filename+"/", templatePath+filename+"/")
      else
        handleFile(templatePath+filename, path+filename)
      end
    end 
  end
  
###             Files                     ###  
  def handleFile(sourceName, targetName)
    if File.binary?(sourceName)
      copyFile(sourceName, targetName)
    else  
      fillTemplate(sourceName, targetName)
    end
    
    if File.extname(sourceName) == ".tex"
      system("pdflatex --output-directory "+File.dirname(targetName) +" "+targetName+" > /dev/null")
      system("rm -f "+File.dirname(targetName)+"/{*.aux,*.log}")
    end
  end
  
  def copyFile(sourceName, targetName)
    source = File.open(sourceName)
    target = File.open(targetName, "w")
    target.write(source.read(64)) while not source.eof?
    target.close
    source.close
  end

###             Templates                       ###
  def fillTemplate(templateName, outputName)
    output = File.new(outputName, "w")
    input = File.new(templateName)
    while line = input.gets
      line.scan(/=\+(\w+)\+=/) do |keyword|
        line = substituteKeywordInLine(line, keyword[0]) 
      end
      output.puts line
    end
    input.close
    output.close
  end

  def substituteKeywordInLine(line, keyword)
    if !@keywords.has_key?(keyword)
      getNewKeyword(keyword)
    end
    value = @keywords[keyword]
    puts "Podstawienie dla: #{keyword}"
    return line.sub(/=\+(#{keyword})\+=/, value.to_s)
  end

  def getNewKeyword(keyword)
    print "Podstawienie za #{keyword}: "
    result = gets.chomp
    if result==""
      @keywords[keyword]="=+#{keyword}+="
    else
      @keywords[keyword]=result
    end
  end
  
end