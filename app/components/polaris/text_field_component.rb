# frozen_string_literal: true

module Polaris
  class TextFieldComponent < Polaris::NewComponent
    OPTIONS = %i[
      form attribute name value type placeholder prefix suffix show_character_count
      maxlength minlength clear_button monospaced align label label_hidden label_action
      disabled required help_text error wrapper_options input_options
    ]

    TYPE_DEFAULT = :text
    TYPE_OPTIONS = %i[
      text email password search tel url date
      datetime_local month time week currency
    ]

    INPUT_DEFAULT = nil
    INPUT_OPTIONS = [nil, :text_area]

    ALIGN_DEFAULT = :default
    ALIGN_MAPPINGS = {
      ALIGN_DEFAULT => "",
      :left => "Polaris-TextField__Input--alignLeft",
      :center => "Polaris-TextField__Input--alignCenter",
      :right => "Polaris-TextField__Input--alignRight",
    }
    ALIGN_OPTIONS = ALIGN_MAPPINGS.keys

    attr_reader :value

    renders_one :connected_left
    renders_one :connected_right

    def initialize(
      form: nil,
      attribute: nil,
      name: nil,
      value: nil,
      type: TYPE_DEFAULT,
      input: INPUT_DEFAULT,
      placeholder: nil,
      maxlength: nil,
      minlength: nil,
      prefix: nil,
      suffix: nil,
      show_character_count: false,
      clear_button: false,
      monospaced: false,
      align: ALIGN_DEFAULT,
      label: nil,
      label_hidden: false,
      label_action: nil,
      disabled: false,
      required: false,
      help_text: nil,
      error: false,
      wrapper_options: {},
      input_options: {},
      **options
    )
      @form = form
      @attribute = attribute
      @name = name
      @value = value
      @type = fetch_or_fallback(TYPE_OPTIONS, type, TYPE_DEFAULT)
      @input = fetch_or_fallback(INPUT_OPTIONS, input, INPUT_DEFAULT)
      @placeholder = placeholder
      @maxlength = maxlength
      @minlength = minlength
      @prefix = prefix
      @suffix = suffix
      @show_character_count = show_character_count
      @clear_button = clear_button
      @monospaced = monospaced
      @align_class = ALIGN_MAPPINGS[fetch_or_fallback(ALIGN_OPTIONS, align, ALIGN_DEFAULT)]
      @label = label
      @label_hidden = label_hidden
      @label_action = label_action
      @disabled = disabled
      @required = required
      @help_text = help_text
      @error = error
      @wrapper_options = wrapper_options
      @input_options = input_options
      @options = options
    end

    def wrapper_options
      {
        form: @form,
        attribute: @attribute,
        name: @name,
        label: @label,
        label_hidden: @label_hidden,
        label_action: @label_action,
        required: @required,
        help_text: @help_text,
        error: @error,
      }.deep_merge(@wrapper_options)
    end

    def options
      {
        tag: "div",
        data: {
          polaris_text_field_has_value_class: "Polaris-TextField--hasValue",
          polaris_text_field_clear_button_hidden_class: "Polaris-TextField__ClearButton--hidden",
        },
      }.deep_merge(@options).tap do |opts|
        opts[:classes] = class_names(
          opts[:classes],
          "Polaris-TextField",
          "Polaris-TextField--disabled": @disabled,
          "Polaris-TextField--error": @error,
          "Polaris-TextField--hasValue": @value.present?,
        )
        prepend_option(opts[:data], :controller, "polaris-text-field")
        if @show_character_count
          opts[:data][:polaris_text_field_label_template_value] = character_count.label_template
          opts[:data][:polaris_text_field_text_template_value] = character_count.text_template
        end
      end
    end

    def input_options
      {
        value: @value,
        disabled: @disabled,
        required: @required,
        placeholder: @placeholder,
        maxlength: @maxlength,
        minlength: @minlength,
        data: { polaris_text_field_target: "input" },
      }.deep_merge(@input_options).tap do |opts|
        opts[:class] = class_names(
          opts[:class],
          "Polaris-TextField__Input",
          @align_class,
          "Polaris-TextField--monospaced": @monospaced,
          "Polaris-TextField__Input--suffixed": @suffix.present?,
        )
        prepend_option(opts[:data], :action, "polaris-text-field#syncValue")
      end
    end

    def input
      @input ||
        case @type
        when :tel then "telephone_field"
        when :currency then "text_field"
        else
          "#{@type}_field"
        end
    end

    def input_tag
      "#{input}_tag"
    end

    def character_count
      @character_count ||= CharacterCount.new(text_field: self, max_length: @maxlength)
    end
  end
end
