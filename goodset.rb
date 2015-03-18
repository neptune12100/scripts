#!/bin/env ruby
#
#Ruby (duh) script to scan a goodset (collection of all the roms for a console with certain naming conventions)
#with each game in a separate folder and get all the "preferred" roms
#either the official US, European or multi-language, or, if none of those are available, an unofficial English translation
#Outputs a big ole list of all the cool roms.
#
#Levi Arnold <arnojla@gmail.com>
#Released to public domain. I don't give a wet slap.

$debug = true
def dmsg str
	if $debug then
		$stderr.puts str
	end
end

def debug (&blk) #Very fancy
	if $debug then
		blk.call
	end
end

preferred = "[!]" #Tag to match a verified good dump
langs = %w:(M (U) (UE) (E) [T+Eng [T-Eng:.reverse #For games which lack a verified dump. Perhaps unofficial translations.
bad = /\[T[+-](?!Eng)/ #Matches non-English translations. I speak English.

def findBest game, preferred, langs, bad
	dmsg "Analyzing #{game}..."
	
	files = Dir.entries(game)
	
	dmsg "Found #{files.count} files."
	
	keep = files.select { |f| #VVVVVV check whether it's SOME sort of english
		f[preferred] and langs.map { |t| not f[t].nil? }.include?(true) and not f[bad] #Quit with the freaking translations!
	} #The easy part. All the [!] files are kept, if they are English!
	
	if keep.empty? then
		dmsg "Found no preferred rom. Trying others..."
	else
		dmsg "Found #{keep.count} preferred rom(s)."
	end
	
	if keep.empty? then #if no [!], then try for European, US and multiple-language roms, then unofficial translations.
		best = ''
		langs.each do |t|
			files.reverse.each do |f|
				if f[t] and not f[bad] then #Quit picking Portugese translations!
					best = f #And only pick the best one.
					dmsg "Possibilty: #{f}"
				end
			end
		end
		if not best.empty? then
			keep << best
		end
	end
	if not keep.empty? then
		dmsg "Using #{keep.join ", "}."
	else
		dmsg "No English version found."
	end
	return keep
end

allfiles = []

Dir.foreach '.' do |game|
	if (not game.start_with? ".") and File.directory? game then
		files = findBest(game, preferred, langs, bad)
		if not files.empty? then
			files.each do |f| allfiles << File.join(game,f) end
		end
	end
end

print allfiles.sort.join "\n"
