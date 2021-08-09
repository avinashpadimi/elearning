require 'rails_helper'

describe Api::V1::CoursesController, type: :controller do 
  def construct_resp course
    {"id"=>course.id.to_s,
     "type"=>"courses",
     "links"=>{"self"=>"http://test.host/api/v1/courses/#{course.id}"},
     "attributes"=>{"name"=>course.name, "self_assignable"=> course.self_assignable},
     "relationships"=>{"coach"=>{"links"=>{"self"=>"http://test.host/api/v1/courses/#{course.id}/relationships/coach", "related"=>"http://test.host/api/v1/courses/#{course.id}/coach"}}}}
  end
  describe "#create" do 
    let(:headers)  do  {
      'content-type' => 'application/vnd.api+json'
    }
    end
    it "should be able to create course and map coach to it" do
      coach = FactoryBot.create(:coach, name: "John")

      params = { data: {
        type: "courses",
        attributes: { name: "ADS", self_assignable: true },
        relationships: { coach: { data: { type: "coaches" , id: coach.id }  }  }
      }
      }

      request.headers['content-type'] = 'application/vnd.api+json'
      post :create, params: params

      resp = JSON.parse(response.body)
      expect(response.status).to eq(201)
      course = Course.last
      info = {"data" => construct_resp(course) }
      expect(info.with_indifferent_access).to eq(resp)
      expect(course.coach.name).to eq(coach.name)
    end
  end

  describe "#delete" do
    it "should be able to delete the course" do 

    end
  end

  describe "#index" do 
    before(:all) do 
      Course.destroy_all
      Coach.destroy_all
      @coach1 = FactoryBot.create(:coach, name: "John")
      @coach2 = FactoryBot.create(:coach, name: "James")

      @course1 = FactoryBot.create(:course, name: 'DS', coach: @coach1, self_assignable: true)
      @course2 = FactoryBot.create(:course, name: 'ADS', coach: @coach1, self_assignable: false)
    end


    it "should return list of courses" do 

      request.headers['content-type'] = 'application/vnd.api+json'
      post :index

      courses = [@course1, @course2].map do |course|
        construct_resp(course)
      end

      expected_resp = { "data" => courses}
      resp = JSON.parse(response.body)
      expect(expected_resp.with_indifferent_access).to eq(resp)
    end

    it "should be able to filter course using self_assignable flag as true" do 
      request.headers['content-type'] = 'application/vnd.api+json'
      post :index, params: { filter: { self_assignable: true }}

      courses = [@course1].map do |course|
        construct_resp(course)
      end

      expected_resp = { "data" => courses}
      resp = JSON.parse(response.body)
      expect(expected_resp.with_indifferent_access).to eq(resp)

    end
    it "Should be able to filter course using self_assignable flag as false" do 
      request.headers['content-type'] = 'application/vnd.api+json'
      post :index, params: { filter: { self_assignable: "false" }}

      courses = [@course2].map do |course|
        construct_resp(course)
      end
     

      expected_resp = { "data" => courses}
      resp = JSON.parse(response.body)
      expect(expected_resp.with_indifferent_access).to eq(resp)
    end
  end
end
