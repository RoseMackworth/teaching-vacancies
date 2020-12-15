require "digest/bubblebabble"

##
# Represents events occurring as part of the Rails request lifecycle
#
# This includes additional information in the event that allows us to put the event into the
# context of a user request. This event can only meaningfully be triggered in controllers.
class RequestEvent < Event
  def initialize(request, response, session, ab_tests, current_jobseeker, current_publisher_oid)
    @request = request
    @response = response
    @session = session
    @ab_tests = ab_tests
    @current_jobseeker = current_jobseeker
    @current_publisher_oid = current_publisher_oid
  end

private

  attr_reader :request, :response, :session, :ab_tests, :current_jobseeker, :current_publisher_oid

  def base_data
    @base_data ||= super.merge(
      request_uuid: request.uuid,
      request_ip: request.remote_ip,
      request_user_agent: user_agent,
      request_referer: request.referer,
      request_method: request.method,
      request_path: request.path,
      request_query: request.query_string,
      request_ab_tests: mapped_ab_tests,
      response_content_type: response.content_type,
      response_status: response.status,
      user_anonymised_request_identifier: anonymise([user_agent, request.remote_ip].join),
      user_anonymised_session_id: anonymise(session.id),
      user_anonymised_jobseeker_id: anonymise(current_jobseeker&.id),
      user_anonymised_publisher_id: anonymise(current_publisher_oid),
    )
  end

  def mapped_ab_tests
    ab_tests.map { |k,v| { test: k.to_s, variant: v.to_s } }
  end

  def user_agent
    request.headers["User-Agent"]
  end

  ##
  # Hashes potentially identifiable information. Uses "bubblebabble" algorithm to make the
  # resulting SHA hash more human-readable.
  #
  # @param [#to_s] identifier An item of identifiable information to anonymise
  # @return [String, nil] a human-readable anonymised identifier or nil if the identifier is blank
  def anonymise(identifier)
    Digest::SHA256.bubblebabble(identifier.to_s) if identifier.present?
  end
end
