require 'spec_helper'

describe MoodleRb::Courses do
  let(:url) { ENV['MOODLE_URL'] || 'localhost' }
  let(:token) { ENV['MOODLE_TOKEN'] || '' }
  let(:course_moodle_rb) { MoodleRb.new(token, url).courses }
  let(:params) do
    {
      :full_name => 'Test Course',
      :short_name => 'TestC1',
      :parent_category => 1,
      :idnumber => 'ExtRef'
    }
  end

  describe '#index', :vcr => {
    :match_requests_on => [:body, :headers], :record => :once
  } do
    let(:result) { course_moodle_rb.index }

    specify do
      expect(result).to be_a Array
      expect(result.first).to have_key 'id'
    end
  end

  describe '#create', :vcr => {
    :match_requests_on => [:headers], :record => :once
  } do
    let(:result) { course_moodle_rb.create(params) }

    specify do
      expect(result).to be_a Hash
      expect(result).to have_key 'id'
      expect(result).to have_key 'shortname'
    end

    context 'when validation fails' do
      before do
        course_moodle_rb.create(params)
      end

      specify do
        expect{ result }.to raise_error(
          MoodleRb::MoodleError,
          'Short name is already used for another course (TestC1)'
        )
      end
    end
  end

  describe '#show', :vcr => {
    :match_requests_on => [:headers], :record => :once
  } do
    let(:id) { 1 }
    let(:result) { course_moodle_rb.show(id) }

    specify do
      expect(result).to be_a Hash
      expect(result['id']).to eq 1
    end
  end

  describe '#destroy', :vcr => {
    :match_requests_on => [:headers], :record => :once
  } do
    let(:id) { course_moodle_rb.create(params)['id'] }
    let(:result) { course_moodle_rb.destroy(id) }

    specify do
      expect(result).to eq true
    end
  end

  describe '#enrolled_users', :vcr => {
    :match_requests_on => [:headers], :record => :once
  } do
    let(:course_id) { 8 }
    let!(:enrolled_user) do
      MoodleRb.new(token, url).enrolments.create(
        :user_id => 3, :course_id => course_id)
    end
    let(:result) { course_moodle_rb.enrolled_users(course_id) }
    let(:enrolment) { result.first }

    specify do
      expect(result).to be_a Array
      expect(enrolment).to have_key 'id'
      expect(enrolment).to have_key 'enrolledcourses'
    end
  end
end
