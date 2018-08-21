require "open-uri"
require "fileutils"
require 'net/http'
require 'json'

# ディレクトリ・ファイル名
@search_word_nm = "img"
# 検索ワード
search_word = 'cat'

# 保存先ディレクトリ
@dirName = "#{@search_word_nm}"
# 保存用ディレクトリを作る(ディレクトリがない場合は新たにディレクトリを作成)
FileUtils.mkdir_p(@dirName) unless FileTest.exist?(@dirName)

# 画像URLから指定フォルダに画像を保存する関数
def save_image(url, num)
  filePath = "#{@dirName}/#{@search_word_nm}#{num.to_s}.jpg"
  open(filePath, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
    end
  end
end

#　保存する枚数(APIの仕様上一気に150枚が限界っぽい)
count = 150

# Bing Search API(公式のコードをそのまま使用)
# https://dev.cognitive.microsoft.com/docs/services/56b43f0ccf5ff8098cef3808/operations/571fab09dbe2d933e891028f
uri = URI('https://api.cognitive.microsoft.com/bing/v7.0/images/search')
uri.query = URI.encode_www_form({
    'q' => search_word,
    'count' => count
    # 'offset' => 150(指定した数だけ検索結果をスキップ)
})
request = Net::HTTP::Get.new(uri.request_uri)
request['Content-Type'] = 'multipart/form-data'
request['Ocp-Apim-Subscription-Key'] = 'xxxxx' # Fix Me
request.body = "{body}"
response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  http.request(request)
end

# searchwordの検索画像をcountの枚数だけ保存する
count.times do |i|
  begin
    image_url = JSON.parse(response.body)["value"][i]["thumbnailUrl"]
    save_image(image_url, i)
  rescue => e
    puts "image#{i} is error!"
    puts e
  end
end
