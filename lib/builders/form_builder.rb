module Spot
  class FormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers - %w(label check_box radio_button fields_for hidden_field file_field)).each do |selector|
      define_method selector do |method, options={}|
        hint = options.delete(:hint)
        type = selector.gsub('_field', '')
        ((options[:class] ||= "") << " text").strip!
        hint = @template.send(:content_tag, :div, hint.html_safe, :class => "hint") if hint.present?
        input = @template.send(selector, @object_name, method, objectify_options(options))
        error = @object.errors[method] if @object
        error = error.join(" ") if error.respond_to?(:join)
        message = @template.send(:content_tag, :div, error, :class => "message")
        validity = @template.content_tag(:div, message.html_safe, :class => "validity")
        @template.content_tag(:li, "#{hint}#{input}#{validity}".html_safe, :class => "#{type}#{error.present?? ' invalid' : nil}")
      end
    end
  end
end