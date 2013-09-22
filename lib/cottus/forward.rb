# encoding: utf-8

module Cottus
  module Forward
    def forward(*verbs)
      verbs.each do |verb|
        define_method(verb) do |path, options={}, &blk|
          strategy.execute(verb, path, options, &blk)
        end
      end
    end
  end
end
