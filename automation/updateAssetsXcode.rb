require 'xcodeproj'
# link to docs : https://www.rubydoc.info/github/CocoaPods/Xcodeproj/Xcodeproj/Project

# relative path to project
project_path = "./ios/Example.xcodeproj";

# open existing project
$project = Xcodeproj::Project.open(project_path)

#clear out SVGs in assets dir from the project level
def clear_svgs(dirPath)
    Dir.open(dirPath).each do |filename|
        # skip directory entries
        next if File.directory? filename
        # skip non svg entries
        next if !filename.include? "svg"
        # remove all files in xcode that match the svg file in the assets directory
        $project.files.each do |file|
            if file.name == filename
                file.remove_from_project
            end
        end
    end
end
clear_svgs(Dir.pwd + '/assets') 


# remove the SVG Group
$project.groups.each do |group|
    if group.name == 'SVG'
        group.remove_from_project
        puts 'cleared: '+group.name
        break if true
    end
end

# create a new SVG group in xcode project
$SVG_group = $project.main_group.new_group("SVG")
# SVG_group = project.main_group["SVG"] #select an existing Xcode Group

# link svgs into the xcode project
def link_svgs(dirPath, assets)
    Dir.open(dirPath).each do |filename|
        # skip directory entries
        next if File.directory? filename
        # skip non svg entries
        next if !filename.include? "svg"
        
        # add svg relative to .xcodeproj
        file = $SVG_group.new_file('../assets/'+assets+'/'+filename)
        # get ref to the main build target
        main_target = $project.targets.first
        # add to build target
        main_target.add_file_references([file])
        # add the svg file into the resources build phase, the svgs are not included in the app bundle without this
        main_target.resources_build_phase.add_file_reference(file)
    end
end

link_svgs(Dir.pwd + '/assets','assets')

# commit changes to Xcode project
$project.save