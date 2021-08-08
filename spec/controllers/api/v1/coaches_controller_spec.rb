require 'rails_helper'

RSpec.describe Api::V1::CoachesController, :type => :controller do
  def construct_resp coach
    {"id"=>coach.id.to_s,
     "type"=>"coaches",
     "links"=>{"self"=>"http://test.host/api/v1/coaches/#{coach.id}"},
     "attributes"=>{"name"=> coach.name},
     "relationships"=>{"courses"=>{"links"=>{"self"=>"http://test.host/api/v1/coaches/#{coach.id}/relationships/courses", "related"=>"http://test.host/api/v1/coaches/#{coach.id}/courses"}}}}
  end

  describe "#create" do 
    let(:headers)  do  {
      'content-type' => 'application/vnd.api+json'
    }
    end
    it "should be able to create coach" do 
      params = 
        {"data": 
         {
          "type":"coaches", 
          "attributes":{ "name":"Sheldon" }
        }
      }
      request.headers['content-type'] = 'application/vnd.api+json'
      post :create, params: params

      resp = JSON.parse(response.body)
      expect(response.status).to eq(201)
      info = {"data" => construct_resp(Coach.last) }
      expect(info.with_indifferent_access).to eq(resp)
    end
  end

  describe "#delete" do
    before(:each) do 
      Course.destroy_all
      Coach.destroy_all
    end
    it "should be able to delete the coach" do
      coach1 = FactoryBot.create(:coach, name: "John")
      request.headers['content-type'] = 'application/vnd.api+json'
      delete :destroy, params: {id: coach1.id }
      expect(Coach.where(id: coach1.id).count).to eq(0)
    end

    it "should be able to map deleted coach courses to other coach" do 
      coach1 = FactoryBot.create(:coach, name: "John")
      coach2 = FactoryBot.create(:coach, name: "James")
      course1 = FactoryBot.create(:course, name: 'DS', coach: coach1)
      course2 = FactoryBot.create(:course, name: 'ADS', coach: coach1)

      expect(Coach.find(coach2.id).courses).to match_array([])
      request.headers['content-type'] = 'application/vnd.api+json'
      delete :destroy, params: {id: coach1.id }
      expect(Coach.where(id: coach1.id).count).to eq(0)
      expect(Coach.find(coach2.id).courses).to match_array([course1,course2])
    end

    it "should be able to raise an error if there are no active coaches while deleting a coach" do
      coach1 = FactoryBot.create(:coach, name: "John")
      course1 = FactoryBot.create(:course, name: 'DS', coach: coach1)
      course2 = FactoryBot.create(:course, name: 'ADS', coach: coach1)

      request.headers['content-type'] = 'application/vnd.api+json'
      delete :destroy, params: {id: coach1.id }
      resp = JSON.parse(response.body)
      expect(resp["errors"].first["meta"]["exception"]).to eq("Coach can't be delete since there are no active coach")
    end
  end

  describe "#index" do 
    before(:all) do 
      Course.destroy_all
      Coach.destroy_all
    end
    it "should get list of coaches" do 
      coach1 = FactoryBot.create(:coach, name: "John")
      coach2 = FactoryBot.create(:coach, name: "James")

      request.headers['content-type'] = 'application/vnd.api+json'
      get :index

      coaches = [coach1,coach2].map do |coach|
        construct_resp(coach)
      end

      expected_resp = { "data" => coaches }
      resp = JSON.parse(response.body)
      expect(expected_resp.with_indifferent_access).to eq(resp)
    end
  end
end
