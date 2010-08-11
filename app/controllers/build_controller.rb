class BuildController < ApplicationController
def create
  respond_to do |format|
    format.xml { render :xml => {:status => "building", :build_id => 1, :reports_url => "http://aws.amazon.com/1/reports"}}
  end
end

def status
  respond_to do |format|
    format.xml {render :xml => {:status => "building"}}
  end
end

end
