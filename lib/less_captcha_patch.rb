module Less
  module Captcha
    module Helper
      def captcha_field_with_options(object_name, options={}, label_options= {})
        b = rand(10) + 1
        a = b + rand(10)
        op = ['+', '-'][rand(2)]
        question = "What is #{a} #{op} #{b}?"
        answer = a.send(op, b)
        eval("@"+object_name.to_s).setup_captcha(answer)

        returning("") do |result|
          result << ActionView::Helpers::InstanceTag.new(object_name, PREFIX, self).to_label_tag(question, label_options)
          result << ActionView::Helpers::InstanceTag.new(object_name, PREFIX + SUFFIX, self).to_input_field_tag("hidden", {})
          result << ActionView::Helpers::InstanceTag.new(object_name, PREFIX, self).to_input_field_tag("text", options)
        end
      end
    end
  end
end