module ActiveRecord
  module Validations
    module ClassMethods
      REGEX_VALID = /(^(1300|1800|1900|1902)\d{6}$)|(^([0]?[1|2|3|7|8])?[1-9][0-9]{7}$)|(^13\d{4}$)|(^[0]?4\d{8}$)/

      def validates_as_phone(*args)
        configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid], :on => :save, :with => nil, :area_key => :phone_area_key }
        configuration.update(args.pop) if args.last.is_a?(Hash)

        validates_each(args, configuration) do |record, attr_name, value|
          new_value = value.to_s.gsub(/[^0-9]/, '')
          new_value ||= ''

          unless (configuration[:allow_blank] && new_value.blank?) || new_value =~ REGEX_VALID
            record.errors.add(attr_name, configuration[:message])
          else
            record.send(attr_name.to_s + '=', format_as_phone(new_value, record.send(configuration[:area_key]))) if configuration[:set]
          end
        end
      end

      def format_as_phone(arg, area_key = nil)
        return nil if arg.blank?

        number = arg.gsub(/[^0-9]/, '')

        if number =~ /^(1300|1800|1900|1902)\d{6}$/
          number.insert(4, ' ').insert(8, ' ')
        elsif number =~ /^([0]?[1|2|3|7|8])?[1-9][0-9]{7}$/
          if number =~ /^[1-9][0-9]{7}$/
            number = number.insert(0, area_code_for_key(area_key))
          end
          number = number.insert(0, '0') if number =~ /^[1|2|3|7|8][1-9][0-9]{7}$/

          number.insert(0, '(').insert(3, ') ').insert(9, ' ')
        elsif number =~ /^13\d{4}$/
          number.insert(2, ' ').insert(5, ' ')
        elsif number =~ /^[0]?4\d{8}$/
          number = number.insert(0, '0') if number =~ /^4\d{8}$/

          number.insert(4, ' ').insert(8, ' ')
        else
          number
        end
      end

      def area_code_for_key(key)
        case key
          when 'NSW': '02'
          when 'ACT': '02'
          when 'VIC': '03'
          when 'TAS': '03'
          when 'QLD': '07'
          when 'SA' : '08'
          when 'NT' : '08'
          when 'WA' : '08'
        else
          '02'
        end
      end
    end    
  end
end
