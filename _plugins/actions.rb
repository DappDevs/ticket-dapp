module Jekyll
    class RenderActionTag < Liquid::Tag

        def initialize(tag_name, text, tokens)
            super
            @text = text
            @id = text.strip('\\"').camelcase(:lower)
            @args = tokens
        end

        def render(context) 
            args = ""
            for i, arg in @args
                case arg
                when 'select'
                    args += "<select id='#{@id}#{i}'><option>0</option></select>"
                end
            end
            return args "<var id='#{@id}'>#{@text}</var>"
        end

    end
end

Liquid::Template.register_tag('action', Jekyll::RenderActionTag)
