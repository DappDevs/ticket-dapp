module Jekyll
    class RenderVarTag < Liquid::Tag

        def initialize(tag_name, text, tokens)
            super
            @text = tokens[0]#text.gsub('\"', '')
            @id = @text#.camelize(:lower)
        end

        def render(context)
            return "<var id='#{@id}'>#{@text}</var>"
        end

    end
end

Liquid::Template.register_tag('var', Jekyll::RenderVarTag)
