module Spot
  class FormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers - %w(label check_box radio_button fields_for hidden_field file_field)).each do |selector|
      define_method selector do |method, options={}|
        hint = options.delete(:hint)
        type = selector.gsub('_field', '')
        prepend = options.delete(:prepend).try(:html_safe)
        ((options[:class] ||= "") << " text").strip!
        hint = @template.send(:content_tag, :div, hint.html_safe, :class => "hint") if hint.present?
        input = @template.send(selector, @object_name, method, objectify_options(options))
        error = @object.errors[method] if @object
        error = error.join(" ") if error.respond_to?(:join)
        message = @template.send(:content_tag, :div, error, :class => "message")
        validity = @template.content_tag(:div, message.html_safe, :class => "validity")
        @template.content_tag(:li, "#{prepend}#{hint}#{input}#{validity}".html_safe, :class => "#{type}#{error.present?? ' invalid' : nil}")
      end
    end
    
    def select(method, choices, options = {}, html_options = {})
      select_tag = @template.select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
      hint = options.delete(:hint)
      type = "select"
      prepend = options.delete(:prepend).try(:html_safe)
      ((options[:class] ||= "") << " text").strip!
      hint = @template.send(:content_tag, :div, hint.html_safe, :class => "hint") if hint.present?
      error = @object.errors[method] if @object
      error = error.join(" ") if error.respond_to?(:join)
      message = @template.send(:content_tag, :div, error, :class => "message")
      validity = @template.content_tag(:div, message.html_safe, :class => "validity")
      @template.content_tag(:li, "#{prepend}#{hint}#{select_tag}#{validity}".html_safe, :class => "#{type}#{error.present?? ' invalid' : nil}")
    end
  end
end