#!/usr/bin/ruby

require "./templateTreeBuilder.rb"


path = Dir::pwd+"/"
builder = TreeBuilder.new(path)

print "Project title: "
projectName = gets.chomp
builder.listTemplates
print "Template name: "
templateName = gets.chomp

builder.buildFromTemplate(projectName, templateName)





