module TinyDyno
  module Expected
    extend ActiveSupport::Concern

    # insert Expected clause, which will ensure
    # that INSERTs will only take place
    # if there is no record with that hash key yet
    def request_as_new_record(request)
      request.merge({
                        expected: {
                            "#{ primary_key[:attr] }": {
                                comparison_operator: 'NULL'
                            }
                        }})
    end

  end
end