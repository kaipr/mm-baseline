module ActiveRecordMatchers
  
  class HaveValidAssociations
    def matches?(model)
      @failed_association = nil
      @model_class = model.class
      
      model.class.reflect_on_all_associations.each do |assoc|
        model.send(assoc.name, true) rescue @failed_association = assoc.name
      end
      !@failed_association
    end
  
    def failure_message
      "invalid association \"#{@failed_association}\" on #{@model_class}"
    end
  end
  def have_valid_associations
    HaveValidAssociations.new
  end
  
  class HaveValidatedPresenceOf
    def initialize(field, options={})
      @field=field
      @options = options
    end
    
    def matches?(model)
      validation_reflections = model.reflect_on_validations_for @field
      vpos = validation_reflections.select{|reflection| reflection.macro == :validates_presence_of}
      return false if vpos.empty?
      # only one should be possible...
      @options.empty? ? true : vpos.first.options == @options
    end
    
    def description
      "have validate_presence_of #{@field}"
    end
    
    def failure_message
      "expected to validate_presence_of #{@field} but doesn't"
    end

    def negative_failure_message
      "not expected to validate_presence_of #{@field} but does"
    end
  end
  def have_validated_presence_of(field, options={})
    HaveValidatedPresenceOf.new(field, options)
  end

  class HaveValidatedAsAttachment
    def matches?(model)
      @model=model.new
      if defined?(GetText)
        locale = GetText.locale
        GetText.set_locale('en')

        @model.valid?  
        
        GetText.set_locale(locale)
      else
        @model.valid?  
      end

      [:content_type, :size, :filename].each do |field|
        return false unless field_errors = @model.errors.on(field)
        match = false
        field_errors.each do |e| 
          match = true if e =~ /can't be blank/
          match = true if e =~ /kann nicht leer sein/
        end
        return false unless match
      end
      [:size].each do |field|
        return false unless field_errors = @model.errors.on(field)
        match = false
        field_errors.each do |e| 
          match = true if e =~ /is not included in the list/
          match = true if e =~ /ist nicht in der Liste enthalten/
        end
        return false unless match
      end
      true
    end
    
    def description
      "have validates_as_attachment"
    end
    
    def failure_message
      "expected to validates_as_attachment but doesn't"
    end
  end
  def have_validated_as_attachment
    HaveValidatedAsAttachment.new
  end

end
