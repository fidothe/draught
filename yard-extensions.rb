class WorldBuilderHandler < YARD::Handlers::Ruby::Base
  handles method_call(:create_builder)
  namespace_only

  process do
    name = statement.parameters.first.jump(:tstring_content, :ident).source
    object = YARD::CodeObjects::MethodObject.new(namespace, name)

    register(object)

    parse_block(statement.last, :owner => object)

    # modify the object
    object.dynamic = true
  end
end
