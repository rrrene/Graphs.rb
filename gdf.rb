#! /usr/bin/ruby1.9.1

module GDF

    class GDF::Graph

        @nodes = []
        @edges = []

        attr_accessor :nodes, :edges

        def initialize(nodes, edges=nil)
            @nodes = nodes || []
            @edges = edges || []
        end
    end

    def self.parse(filename)
        content = File.read(filename).split("\n")

        # lines index of 'nodedef>' and 'edgedef>'
        nodes_def_index = -1
        edges_def_index = -1

        content.each_with_index {|l,i|
            if l.start_with? 'nodedef>'
                nodes_def_index = i
            elsif l.start_with? 'edgedef>'
                edges_def_index = i
            end

            if ((nodes_def_index >= 0) && (edges_def_index >= 0))
                break
            end
        }

        # no edges
        if (edges_def_index == -1)
            edges = []
            edges_def_index = content.length
        else
            edges = content[edges_def_index+1..content.length]
        end

        # only nodes lines
        nodes = content[nodes_def_index+1..[edges_def_index-1, content.length].min] || []

        nodes_def = content[nodes_def_index]
        nodes_def = nodes_def['nodedef>'.length..nodes_def.length].strip.split(',')
        nodes_def.each_index {|i|
            nodes_def[i] = read_def(nodes_def[i])
        }

        nodes.each_with_index {|n,i|
            n2 = {}
            n = n.split(',')
            n.zip(nodes_def).each {|val,label_type|
                label, type = label_type
                n2[label] = parse_field(val, type)
            }
            nodes[i] = n2
        }

        if (edges === [])
            return GDF::Graph.new(nodes)
        end

        # only edges lines
        edges_def = content[edges_def_index]
        edges_def = edges_def['edgedef>'.length..edges_def.length].strip.split(',')
        edges_def.each_index {|i|
            edges_def[i] = read_def(edges_def[i])
        }

        edges.each_with_index {|e,i|
            e2 = {}
            e = e.split(',')
            e.zip(edges_def).each {|val,label_type|
                label, type = label_type
                e2[label] = parse_field(val, type)
            }
            edges[i] = e2
        }

        GDF::Graph.new(nodes, edges)
    end

    private

    # read a (node|edge)def, and return ['label', 'type of value']
    def self.read_def(s)
        *label, value_type = s.split /\s+/
            if /((tiny|small|big)?int|integer)/i.match(value_type)
                value_type = 'int'
            elsif /(float|double)/i.match(value_type)
                value_type = 'float'
            elsif (value_type.downcase === 'boolean')
                value_type = 'boolean'
            end

        [label.join(' '), value_type]
    end

    # read a field and return its value
    def self.parse_field(f, value_type)
        case value_type
        when 'int'     then f.to_i
        when 'float'   then f.to_f
        when 'boolean' then !(/(null|false)/i =~ f)
        else f
        end
    end

end
