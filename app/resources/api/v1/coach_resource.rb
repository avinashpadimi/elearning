module Api
  module V1
    class CoachResource < JSONAPI::Resource
      attributes :name

      has_many :courses

      before_remove :transfer_course_to_another_coach

      def transfer_course_to_another_coach
        raise "Coach can't be delete since there are no active coach" if courses_exists? && !active_coaches_present?
        exclude_coaches = [self.id]
        CourseResource.assign_coach(self.courses, exclude_coaches)
      end

      private

      def active_coaches_present?
        Coach.where.not(id: self.id).exists?
      end

      def courses_exists?
        Course.exists?
      end
    end
  end
end
