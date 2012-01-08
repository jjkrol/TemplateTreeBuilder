#
#
#
#

require 'ptools'

class TreeBuilder

  def initialize(path, args)
    @templates = []
    @templatePath = File.expand_path(File.dirname(__FILE__))+"/templates/"
    Dir.foreach(@templatePath) do |filename|
      if File.directory?(@templatePath+filename) && filename!="." && filename!=".."
        @templates.push(filename)
      end

    end
    @path, @args = path, args
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

  def safeMakeDir(name, path)
    directoryName = path+name
    if FileTest::directory?(directoryName)
      puts "Directory #{directoryName} exists"
      return
    end
    Dir::mkdir(directoryName)
    puts "Directory #{name} created"
  end

  def makeDirBranch(branch, path)
    branch.each do |key, value|
      safeMakeDir(key, path);
      if(value.class == Hash) then
        makeDirBranch(value,path+key+"/")
      end
    end

  end
  def buildTreeBranch(path, templatePath)
    Dir.foreach(templatePath) do |filename|
      next if filename=="." || filename==".."
      if File.directory?(templatePath+filename) then
        # stworz folder i idz wglab
        safeMakeDir(filename, path)
        buildTreeBranch(path+filename+"/", templatePath+filename+"/")
      else
        handleFile(templatePath+filename, path+filename)
        # stworz plik
      end
    end 

  end
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
    source.close
    target.close
  end
  def fillTemplate(templateName, outputName)
    output = File.new(outputName, "w")
    input = File.new(templateName)
    while line = input.gets
      line.scan(/=\+(\w+)\+=/) do |keyword|
        line = substituteKeywordInLine(line, keyword[0]) 
      end
      output.puts line
    end
    output.close
    input.close
  end

  def substituteKeywordInLine(line, keyword)
    if !@args.has_key?(keyword)
      getNewKeyword(keyword)
    end
    value = @args[keyword]
    puts "Podstawienie dla: #{keyword}"
    return line.sub(/=\+(#{keyword})\+=/, value.to_s)
  end

  def getNewKeyword(keyword)
    print "Podstawienie za #{keyword}: "
    result = gets.chomp
    if result==""
      @args[keyword]="=+#{keyword}+="
    else
      @args[keyword]=result
    end

  end
end