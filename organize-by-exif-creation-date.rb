require 'exifr/jpeg'
require 'geocoder'
require 'fileutils'

files = Dir.glob("originals/*")
galleries = Hash.new

files.each do |file|
  source_path = file.to_s
  dest_path = source_path
  puts source_path

  begin
    img = EXIFR::JPEG.new(source_path)
    creation_date = img.date_time_original
    #creation_day = creation_date.strftime('%d.%m.%Y')
    creation_day = creation_date.strftime('%Y-%m-%d')

    unless img.gps.nil?
      lat = img.gps.latitude
      lon = img.gps.longitude
      town = nil #Geocoder.search("#{lat},#{lon}").first.town
      puts "Town (#{lat},#{lon}): #{town}"

      unless town.nil? 
        town_name = town.gsub(/\/.*/, '')
        dest_path = source_path.gsub(/\.(.*)$/, " #{town_name}.\\1")
      end
    end

    gallery = creation_day
    unless galleries.include? gallery
      galleries[gallery] = []
    end
    galleries[gallery] << dest_path
  rescue EXIFR::MalformedImage
    puts "INFO '#{source_path}' could not be processed and was skipped."
  end
end

galleries.each do |key, paths|
  dir = "organized/#{key}"
  puts dir unless Dir.exists? dir
  unless Dir.exists?(dir)
    puts "creating #{dir}"
    Dir.mkdir dir
  end
  paths.each do |path|
    puts "copy <#{path}> to <#{dir}/#{File.basename(path)}>"
    FileUtils.cp(path, "#{dir}/#{File.basename(path)}")
  end
end

