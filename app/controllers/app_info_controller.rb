class AppInfoController < ApplicationController
  def deployinfo
    File.open(Rails.root.to_s+"/deploy-info.txt", "r") do |myownfilehandle|
      send_file myownfilehandle, type: 'text/plain; charset=utf-8', status: 200, disposition: 'inline'
    end
  end
end
