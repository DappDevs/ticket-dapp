module Jekyll
    class RenderActionTag < Liquid::Tag

        def initialize(tag_name, text, tokens)
            super
            @text = tokens[0]#text.gsub('\"', '')
            @id = @text#.camelize(:lower)
            @args = tokens
        end

        def render(context) 
            @args.each_with_index do |arg, idx|
                case arg
                when 'select'
                    puts "<select id='#{@id}#{idx}'><option>0</option></select>"
                end
            end
            "<var id='#{@id}'>#{@text}</var>"
        end

    end
end

Liquid::Template.register_tag('action', Jekyll::RenderActionTag)
