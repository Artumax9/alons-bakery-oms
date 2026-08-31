# Common return value for service objects.
#
# Services never raise for *expected* failures (insufficient stock, an invalid
# status transition). They return a ServiceResult and the caller asks
# `result.success?`. Exceptions stay reserved for genuine bugs.
class ServiceResult
  attr_reader :value, :errors

  def self.success(value = nil)
    new(success: true, value: value, errors: [])
  end

  def self.failure(errors)
    new(success: false, value: nil, errors: Array(errors))
  end

  def initialize(success:, value:, errors:)
    @success = success
    @value = value
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !success?
  end
end
