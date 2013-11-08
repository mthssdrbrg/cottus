# encoding: utf-8

module Cottus
  module Forward
    def forward(*args)
      options = args.pop
      to, through = options.values_at(:to, :through)

      args.each do |verb|
        define_method(verb) do |path, opts={}|
          if to && through
            instance_variable_get(to).send(through, verb, path, opts)
          else
            self.send(to, verb, path, opts)
          end
        end
      end
    end
  end
end
