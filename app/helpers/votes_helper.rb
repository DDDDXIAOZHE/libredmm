# frozen_string_literal: true

module VotesHelper
  def oneregex(codes)
    groups = {}
    codes.each do |code|
      parts = if code.include? " "
                code.split(" ", 2)
              else
                code.split("-", 2)
              end
      series = parts.first.upcase
      series = "FC2[-_ ]*(PPV)?" if series == "FC2-PPV"
      num = parts.second.gsub(/^0+(\d{2,})/) { |_|
        Regexp.last_match(1)
      }.gsub("-", '\-').downcase
      groups[series] ||= []
      groups[series] << num
    end

    branches = groups.map { |series, nums|
      if series == "S-CUTE"
        nums += nums.map do |num|
          num.split("_").map { |token|
            token.gsub(/^0*(\d+)/) do
              "#?#{Regexp.last_match(1)}"
            end
          }.join(" ")
        end
      end
      "(#{series}[-_ ]*0*(#{nums.join("|")}))"
    }.join("|")

    "(#{branches})(\\b|\\z|\\D)"
  end
end
