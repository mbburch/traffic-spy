class Messenger

  attr_reader :record, :model

  def initialize(params, model)
    @model = model
    attribute_array = params.to_a.map do |key, value|
      [key.to_s.underscore.to_sym, value]
    end
    attributes = attribute_array.to_h
    @record = eval(model).new(attributes)
    record.save if valid_record
  end

  def message
    if valid_record
      {:identifier => record.identifier}.to_json if model == "Source"
    elsif error == "can't be blank"
      "Missing Parameters: #{specific_error}"
    elsif specific_error == "Sha identifier has already been taken"
      "Payload Has Already Been Received"
    elsif error == "has already been taken"
      "Non-unique Value: #{specific_error}"
    end
  end

  def status
    if valid_record
      "200 OK"
    elsif error == "can't be blank"
      "400 Bad Request"
    elsif error == "has already been taken"
      "403 Forbidden"
    end
  end

  private

  def valid_record
    record.valid?
  end

  def error
    record.errors.messages.values.flatten.first
  end

  def specific_error
    record.errors.full_messages.first
  end

  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

end