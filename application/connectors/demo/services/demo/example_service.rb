module Demo
  class ExampleService
    def greet
      I18n.t('demo.greeting')
    end
  end
end
