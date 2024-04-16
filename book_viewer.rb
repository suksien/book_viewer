require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @contents = File.readlines('data/toc.txt')
end

get "/" do
  @title = "Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number]
  @title = @contents[number.to_i - 1]
  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

helpers do
  def in_paragraphs(str)
    id = -1
    str.split("\n\n").map do |paragraph|
      id += 1
      "<p id=#{id}>#{paragraph}</p>" # "<p>" << paragraph << "</p>"
    end.join
  end

  def make_bold(txt, keyword)
    txt.gsub(keyword, "<strong>#{keyword}</strong>")
  end
end

not_found do
  redirect "/"
end

# my solution to "Adding a Search Form"
# def search_words(word, all_titles)
#   all_titles.select.with_index do |title, index|
#     txt = File.read("data/chp#{index + 1}.txt")
#     txt.include?(word)
#   end
# end

# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    if contents.include?(query)
      selected = {}
      contents.split("\n\n").each_with_index do |paragraph, id|
        selected[id] = paragraph if paragraph.include?(query)
      end

      results << { number: number, name: name, paragraphs: selected }
    end
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end