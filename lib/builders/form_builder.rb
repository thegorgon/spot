module Spot
  class FormBuilder < ActionView::Helpers::FormBuilder
    module HelperMethods
      def spot_form_for(record, options={}, &proc)
        options[:builder] ||= Spot::FormBuilder
        display = options.delete(:display)
        ul_id = options.delete(:ul_id)
        (options[:html] ||= {})['data-validate'] ||= "validate" unless options.delete(:validate) == false
        content_tag(:ul, form_for(record, options, &proc).html_safe, :class => "form #{display} accept_focus", :id => ul_id)
      end
    end
    
    (field_helpers - %w(label check_box radio_button fields_for hidden_field file_field select)).each do |selector|
      define_method selector do |method, options={}|
        sanitize_options!(selector, options)
        
        if options.delete(:simple)
          super(method, options)
        else
          li_wrap(method, selector, options) do |method, options|
            @template.send(selector, @object_name, method, objectify_options(options))
          end
        end
      end
    end
    
    def city_select(method, value, options={})
      subscribeable = options.delete(:subscribeable)
      prepend_values = options.delete(:prepend_values)
      append_values = options.delete(:append_values)
      html_options = {
        :class => "chzn-select", 
        :title => "Select your city"
      }.merge!(options.delete(:html) || {})
      options = {
        :validity => false, 
        :prompt => "select your city", 
        :selected => value, 
        :label => "city : "
      }.merge!(options)
      values = City.visible
      values = values.subscriptions_available if subscribeable
      values = values.all.collect { |c| [c.name_and_region, c.id] }
      values = prepend_values + values if prepend_values
      values += append_values if append_values
      
      select(method, values, options, html_options)
    end
    
    def file_field(method, options={})
      sanitize_options!("file_field", options)
      button_class = options.delete(:button_class) || ""
      (button_class << " browse_button").strip!
      browse = options.delete(:browse) || "Choose File"
      
      if options.delete(:simple)
        super(method, options)
      else
        li_wrap(method, "file_field", options) do |method, options|
          @template.content_tag(:div, :class => "file_field") do
            @template.content_tag(:div, '&nbsp;'.html_safe, :class => "filename") +
            @template.content_tag(:div, browse, :class => button_class) +
            super(method, :value => "", :class => "file")
          end
        end                    
      end
    end
        
    def name_fields(options={})
      sanitize_options!("text_field", options)
      value = options[:value] || []
      @template.content_tag(:div, :class => container_class_for(:name, "name li", options)) do
        label_for(:first_name, options.delete(:label)) +
        hint(options.delete(:hint)) +
        text_field(:first_name, options.merge(:container_class => "first_name", :placeholder => "first name", :value => value.first)) + 
        text_field(:last_name, options.merge(:container_class => "last_name", :placeholder => "last name", :value => value.last))
      end
    end
    
    def select(method, choices, options = {}, html_options = {})
      sanitize_options!("select_field", options)
            
      if options.delete(:simple)
        super(method, choices, options, html_options)
      else
        li_wrap(method, "select_field", options) do |method, options|
          @template.select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
        end
      end
    end
        
    def li_wrap(method, tag, options={}, &block)
      ignore_validity = (options.delete(:validity) == false)
      
      @template.content_tag(:li, :class => container_class_for(method, type_class(tag), options), :id => container_id_for(method)) do
        label_for(method, options.delete(:label)) +
        hint(options.delete(:hint)) +
        @template.content_tag(:div, :class => "input_container") do
          extra_content(options, :prepend) + 
          block.call(method, options)
        end +
        (ignore_validity ? ''.html_safe : validity_for(method)) + 
        extra_content(options, :append)
      end
    end
    
    private

    def sanitize_options!(tag, options)
      ((options[:class] ||= "") << " #{type_class(tag)}").strip!
    end
    
    def container_id_for(method)
      "#{@object_name.to_s.gsub(/[\[\]]/, '_').chomp('_')}_#{method}_container"
    end
    
    def extra_content(options, key)
      if options[key].present?
        @template.content_tag(:div, options.delete(key).html_safe, :class => key.to_s)
      else
        "".html_safe
      end
    end
    
    def type_class(tag)
      type = tag.gsub("_field", "")
      type == "text" ? type : "text #{type}"
    end
    
    def container_class_for(method, base, options={})
      base << " accept_focus"
      base << " labelled" if options[:label]      
      base << " #{options[:container_class]}" if options[:container_class].present?
      base << " invalid" if invalid_for?(method)
      base << " valid" if invalid_for?(method)
      base << " hinted" if options[:hint].present?
      base.strip
    end
    
    def label_for(method, label)
      if label.present?
        @template.content_tag(:div, label(method, label), :class => "label")
      else
        "".html_safe
      end
    end
    
    def validity_for(method)
      html_options = {:class => "validity"}
      error = error_messages_on(method)
      html_options["data-jstooltip"] = error if error.present?
      validity = @template.content_tag(:div, '&nbsp;'.html_safe, html_options)
    end
    
    def hint(text)
      if text.present?
        @template.content_tag(:div, text.html_safe, :class => "hint")
      else
        "".html_safe
      end
    end
    
    def invalid_for?(method)
      @object.present? && @object.errors && @object.errors[method].present?
    end
    
    def valid_for?(method)
      @object.present? && @object.errors && @object.errors[method].empty?
    end
    
    def error_messages_on(method)
      if @object && error = @object.errors[method]
        error = error.join(" ") if error.respond_to?(:join)
        error
      end
    end
  end
end

ActionView::Base.send(:include, Spot::FormBuilder::HelperMethods)