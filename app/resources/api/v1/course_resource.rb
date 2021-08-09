module Api
  module V1
    class CourseResource < JSONAPI::Resource
      attributes :name, :self_assignable
      has_one :coach

      filter :self_assignable

      def self.assign_coach(courses, exclude_coaches)
        coach = find_coach exclude_coaches
        courses.each do | course|
          course._model.update_attributes({coach_id: coach.id})
        end
      end

      private
      def self.find_coach exclude_coaches
        Coach.where.not(id: exclude_coaches).first
      end
    end
  end
end
