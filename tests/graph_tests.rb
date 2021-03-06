#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

class Graph_test < Test::Unit::TestCase

    def setup
        @@sample_graph = Graph.new(
            [
                {'label'=>'foo', 'id'=>2},
                {'label'=>'bar', 'id'=>1},
                {'label'=>'chuck', 'id'=>3}
            ],
            [
                {'node1'=>'foo', 'node2'=>'bar'},
                {'node1'=>'bar', 'node2'=>'foo'},
                {'node1'=>'bar', 'node2'=>'chuck'},
                {'node1'=>'foo', 'node2'=>'chuck'}
            ]
        )

        @@sample_graph_1 = Graph.new(
            [
                {'label'=>'bar', 'num'=>3},
                {'label'=>'foo', 'num'=>42},
                {'label'=>'chuck', 'num'=>78}
            ],
            [
                {'node1'=>'foo', 'node2'=>'bar', 'time'=>1.0},
                {'node1'=>'bar', 'node2'=>'foo', 'time'=>2.5},
                {'node1'=>'foo', 'node2'=>'chuck', 'time'=>3.1}
            ]
        )

        @@empty = Graph.new

        @@directed = Graph.new(
            [
                {'label' => 'foo'},
                {'label' => 'bar'}
            ],
            [ { 'node1' => 'foo', 'node2' => 'bar' }]
        )

        @@directed.attrs[:directed] = true
    end

    # == Graph#attrs == #

    def test_empty_graph_attrs
        g = @@empty
        assert_equal({:directed => true}, g.attrs)
        assert_equal(true, g.directed?)

        g.attrs['mode'] = 'static'
        g.attrs['defaultedgetype'] = 'directed'

        assert_equal('static', g.attrs['mode'])
        assert_equal('directed', g.attrs['defaultedgetype'])
    end

    # == Graph::intersection == #

    def test_intersection_no_graphs
        assert_equal(nil, Graph::intersection)
        assert_equal(nil, Graph::intersection({:same_fields => true}))
    end

    def test_intersection_2_empty_graphs
        g = @@empty
        h = g.clone

        assert_equal(h, Graph::intersection(g, g))
    end

    def test_intersection_4_empty_graphs_intersection
        g = @@empty
        h = g.clone

        assert_equal(h, Graph::intersection(g, g, g, g))
    end

    def test_intersection_one_node_graph_and_empty_graph
        g = Graph.new([{'label'=>'foo'}])

        assert_equal(@@empty, Graph::intersection(g, @@empty))
    end

    def test_intersection_sample_graph_and_itself_5_times
        g = @@sample_graph
        h = g.clone

        assert_equal(h, Graph::intersection(g, g, g, g, g))
    end

    def test_intersection_sample_graph_and_itself_5_times_and_empty_graph
        g = @@sample_graph

        assert_equal(@@empty, Graph::intersection(g, g, @@empty, g, g, g))
    end

    def test_intersection_one_node_graph_and_one_other_node_graph
        g = Graph.new([{'label'=>'foo'}])
        h = Graph.new([{'label'=>'bar'}])
        
        assert_equal(@@empty, Graph::intersection(g, h))
    end

    def test_intersection_sample_graph_and_no_graph
        g = @@sample_graph

        assert_equal(nil, Graph::intersection(g, 2))
        assert_equal(nil, Graph::intersection(g, true))
        assert_equal(nil, Graph::intersection(g, false))
        assert_equal(nil, Graph::intersection(g, ['foo', 'bar']))
        assert_equal(nil, Graph::intersection(g, 'foo'))
    end

    def test_intersection_2_graphs_same_nodes_different_fields
        g1 = @@sample_graph.clone
        g2 = @@sample_graph_1.clone
        
        assert_equal(@@empty, Graph::intersection(g1, g2))
        # test for side effects
        assert_equal(@@sample_graph, g1)
        assert_equal(@@sample_graph_1, g2)
    end

    def test_intersection_2_graphs_same_nodes_different_fields_same_fields_option
        g1 = @@sample_graph.clone
        g2 = @@sample_graph_1.clone
        
        intersec = Graph.new(
            [
                {'label'=>'foo'},
                {'label'=>'bar'},
                {'label'=>'chuck'}
            ],
            [
                {'node1'=>'foo', 'node2'=>'bar'},
                {'node1'=>'bar', 'node2'=>'foo'},
                {'node1'=>'foo', 'node2'=>'chuck'}
            ]
        )

        assert_equal(intersec, Graph::intersection(g1, g2, :same_fields => true))
        # test for side effects
        assert_equal(@@sample_graph, g1)
        assert_equal(@@sample_graph_1, g2)
    end

    # == Graph#new == #

    def test_new_empty_graph
        g = @@empty

        assert_equal([], g.nodes)
        assert_equal([], g.edges)
    end

    # == Graph#clone == #

    def test_empty_graph_clone
        g = @@empty
        h = g.clone

        assert_equal(g, h)

        h.nodes.push({})

        assert_equal(0, g.nodes.length)
        assert_not_equal(g, h)
    end

    # == Graph#== == #

    def test_equal_graphs
        g1 = @@sample_graph
        g2 = @@sample_graph.clone()

        assert_equal(true, g1==g2)
    end

    def test_equal_graph_and_non_graph

        g = Graph.new

        assert_equal(false, g==[])
        assert_equal(false, g=={})
        assert_equal(false, g==0)
        assert_equal(false, g==false)
        assert_equal(false, g==nil)
        assert_equal(false, g==Graph::Node.new)

    end

    # == Graph::NodeArray#set_default == #

    def test_nodearray_set_default_unexisting_property
        g = Graph.new([{'name'=>'foo'}, {'name'=>'bar'}])
        g.nodes.set_default 'age' => 21

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])
    end

    def test_nodearray_set_default_existing_property
        g = Graph.new([{'name'=>'foo', 'age'=>42}, {'name'=>'bar'}])
        g.nodes.set_default 'age' => 21

        assert_equal(21, g.nodes[0]['age'])
        assert_equal(21, g.nodes[1]['age'])
    end

    def test_nodearray_set_default_unexisting_property_before_push
        g = Graph.new([{'name'=>'foo'}])
        g.nodes.set_default 'city' => 'Paris'
        g.nodes.push({'name' => 'bar'})

        assert_equal('Paris', g.nodes[0]['city'])
        assert_equal('Paris', g.nodes[0]['city'])
    end

    def test_nodearray_set_default_existing_property_before_push
        g = Graph.new([{'name'=>'foo', 'city'=>'London'}])
        g.nodes.set_default 'city' => 'Paris'
        g.nodes.push({'name' => 'bar'})

        assert_equal('Paris', g.nodes[0]['city'])
        assert_equal('Paris', g.nodes[0]['city'])
    end

    # == Graph::edgeArray#set_default == #

    def test_edgearray_set_default_unexisting_property
        g = Graph.new([],[{'node1'=>'foo', 'node2'=>'bar'}])
        g.edges.set_default 'directed' => true

        assert_equal(true, g.edges[0]['directed'])
    end

    def test_edgearray_set_default_existing_property
        g = Graph.new([], [{'node1'=>'foo', 'node2'=>'bar', 'directed'=>true},
                           {'node1'=>'bar', 'node2'=>'foo'}])
        g.edges.set_default 'directed' => false

        assert_equal(false, g.edges[0]['directed'])
        assert_equal(false, g.edges[1]['directed'])
    end

    def test_edgearray_set_default_unexisting_property_before_push
        g = Graph.new([], [{'node1'=>'foo', 'node2'=>'bar'}])
        g.edges.set_default 'directed' => true
        g.edges.push({'node1' => 'bar', 'node2'=>'foo'})

        assert_equal(true, g.edges[0]['directed'])
        assert_equal(true, g.edges[0]['directed'])
    end

    def test_edgearray_set_default_existing_property_before_push
        g = Graph.new([], [{'node1'=>'foo', 'node2'=>'bar', 'directed'=>true}])
        g.edges.set_default 'node2' => 'foo'
        g.edges.push({'node1' => 'bar', 'node2' => 'foo'})

        assert_equal('foo', g.edges[0]['node2'])
        assert_equal('foo', g.edges[0]['node2'])
    end

    # == Graph#& == #

    def test_AND_2_empty_graphs
        g1 = g2 = @@empty

        assert_equal(g1, g1 & g2)
    end

    def test_one_node_graph_AND_empty_graph
        g = Graph.new([{'label'=>'foo'}])
        
        assert_equal(@@empty, g & @@empty)
    end

    def test_empty_graph_AND_one_node_graph
        g = Graph.new([{'label'=>'foo'}])
        
        assert_equal(@@empty, @@empty & g)
    end

    def test_sample_graph_AND_itself
        g = @@sample_graph

        assert_equal(g, g & g)
    end

    def test_one_node_graph_AND_one_other_node_graph
        g = Graph.new([{'label'=>'foo'}])
        h = Graph.new([{'label'=>'bar'}])
        
        assert_equal(@@empty, g & h)
    end

    def test_sample_graph_AND_no_graph
        g = @@sample_graph

        assert_equal(nil, g & 2)
        assert_equal(nil, g & true)
        assert_equal(nil, g & false)
        assert_equal(nil, g & ['foo', 'bar'])
        assert_equal(nil, g & {'foo'=>'bar'})
        assert_equal(nil, g & 'foo')
    end

    def test_AND_2_graphs_same_nodes_different_labels
        g1 = @@sample_graph
        g2 = @@sample_graph_1
        
        assert_equal(@@empty, g1 & g2)
    end

    # == Graph#^ == #

    def test_XOR_2_empty_graphs
        g = @@empty
        assert_equal(g, g ^ g)
    end

    def test_one_node_graph_XOR_empty_graph
        g = Graph.new([{'label'=>'foo'}])
        
        assert_equal(g, g ^ @@empty)
    end

    def test_empty_graph_XOR_one_node_graph
        g = Graph.new([{'label'=>'foo'}])
        
        assert_equal(g, @@empty ^ g)
    end

    def test_sample_graph_XOR_itself
        g = @@sample_graph
        
        assert_equal(@@empty, g ^ g)
    end

    def test_one_node_graph_XOR_one_other_node_graph
        g1 = Graph.new([{'label'=>'foo'}])
        g2 = Graph.new([{'label'=>'bar'}])
        g3 = Graph.new(g1.nodes+g2.nodes)
        g4 = Graph.new(g2.nodes+g1.nodes)

        assert_equal(g3, g1 ^ g2)
        assert_equal(g4, g2 ^ g1)
    end

    def test_sample_graph_XOR_no_graph
        g = @@sample_graph

        assert_equal(nil, g ^ 2)
        assert_equal(nil, g ^ true)
        assert_equal(nil, g ^ false)
        assert_equal(nil, g ^ ['foo', 'bar'])
        assert_equal(nil, g ^ {'foo'=>'bar'})
        assert_equal(nil, g ^ 'foo')
    end

    def test_XOR_2_graphs_same_nodes_different_labels
        g1 = @@sample_graph
        g2 = @@sample_graph_1
        g3 = Graph.new(g1.nodes+g2.nodes, g1.edges+g2.edges)

        assert_equal(g3, g1 ^ g2)
    end

    # == Graph#+ == #
    
    def test_empty_graph_plus_empty_graph
        assert_equal(@@empty, @@empty+@@empty)
    end
    
    def test_empty_graph_plus_sample_graph
        g = @@sample_graph
        
        assert_equal(g, @@empty+g)
        assert_equal(g, g+@@empty)
    end
    
    def test_sample_graph_plus_itself
        g = @@sample_graph
        g2 = Graph.new(g.nodes+g.nodes, g.edges+g.edges)

        assert_equal(g2, g+g)
    end

    def test_graph_plus_non_graph

        g = @@sample_graph

        assert_equal(nil, g+42)
        assert_equal(nil, g+[])
        assert_equal(nil, g+{})
        assert_equal(nil, g+Graph::Node.new)

    end

    # == Graph#| == #
    
    def test_empty_graph_OR_empty_graph
        assert_equal(@@empty, @@empty|@@empty)
    end
    
    def test_empty_graph_OR_sample_graph
        g = @@sample_graph
        
        assert_equal(g, @@empty|g)
        assert_equal(g, g|@@empty)
    end
    
    def test_sample_graph_OR_itself
        g = @@sample_graph

        assert_equal(g, g|g)
    end
    
    def test_sample_graph_OR_other_sample_graph
        g1 = @@sample_graph
        g2 = @@sample_graph_1
        g3 = Graph.new(g1.nodes|g2.nodes, g1.edges|g2.edges)
        g4 = Graph.new(g2.nodes|g1.nodes, g2.edges|g1.edges)

        assert_equal(g3, g1|g2)
        assert_equal(g4, g2|g1)
    end

    def test_graph_OR_non_graph

        g = @@sample_graph

        assert_equal(nil, g|42)
        assert_equal(nil, g|[])
        assert_equal(nil, g|{})
        assert_equal(nil, g|Graph::Node.new)

    end

    # == Graph#- == #
    
    def test_empty_graph_minus_empty_graph
        assert_equal(@@empty, @@empty-@@empty)
    end
    
    def test_empty_graph_minus_sample_graph
        g = @@sample_graph
        
        assert_equal(@@empty, @@empty-g)
    end
    
    def test_sample_graph_minus_empty_graph
        g = @@sample_graph
        
        assert_equal(g, g-@@empty)
    end
    
    def test_sample_graph_minus_itself
        g = @@sample_graph
        
        assert_equal(@@empty, g-g)
    end

    def test_graph_minus_non_graph

        g = @@sample_graph

        assert_equal(nil, g-42)
        assert_equal(nil, g-[])
        assert_equal(nil, g-{})
        assert_equal(nil, g-Graph::Node.new)

    end

    # == Graph#not == #
    
    def test_empty_graph_NOT_empty_graph
        assert_equal(@@empty, @@empty.not(@@empty))
    end
    
    def test_empty_graph_NOT_sample_graph
        g = @@sample_graph
        
        assert_equal(@@empty, @@empty.not(g))
    end
    
    def test_sample_graph_NOT_empty_graph
        g = @@sample_graph
        
        assert_equal(g, g.not(@@empty))
    end
    
    def test_sample_graph_NOT_itself
        g = @@sample_graph
        
        assert_equal(@@empty, g.not(g))
    end

    # == Graph::union == #

    def test_union_one_empty_graph
        assert_equal(@@empty, Graph::union(@@empty))
    end

    def test_union_3_empty_graph
        assert_equal(@@empty, Graph::union(@@empty, @@empty, @@empty))
    end
    
    def test_union_empty_graph_and_sample_graph
        g = @@sample_graph
        
        assert_equal(g, Graph::union(@@empty, g))
        assert_equal(g, Graph::union(g, @@empty))
    end
    
    def test_union_sample_graph_and_itself
        g = @@sample_graph

        assert_equal(g, Graph::union(g, g))
        assert_equal(g, Graph::union(g, g, g, g))
    end
    
    def test_union_sample_graph_and_other_sample_graph
        g1 = @@sample_graph
        g2 = @@sample_graph_1
        g3 = Graph.new(g1.nodes|g2.nodes, g1.edges|g2.edges)
        g4 = Graph.new(g2.nodes|g1.nodes, g2.edges|g1.edges)

        assert_equal(g3, Graph::union(g1, g2))
        assert_equal(g3, Graph::union(g1, g1, g2))
        assert_equal(g3, Graph::union(g1, g2, g2))

        assert_equal(g4, Graph::union(g2, g1))
        assert_equal(g4, Graph::union(g2, g2, g1))
        assert_equal(g4, Graph::union(g2, g1, g1))
    end
    
    # == Graph::xor == #

    def test_xor_one_empty_graph
        assert_equal(@@empty, Graph::xor(@@empty))
    end

    def test_xor_3_empty_graph
        assert_equal(@@empty, Graph::xor(@@empty, @@empty, @@empty))
    end
    
    def test_xor_empty_graph_and_sample_graph
        g = @@sample_graph
        
        assert_equal(g, Graph::xor(@@empty, g))
        assert_equal(g, Graph::xor(g, @@empty))
    end
    
    def test_xor_sample_graph_and_itself
        g = @@sample_graph

        assert_equal(@@empty, Graph::xor(g, g))
        assert_equal(@@empty, Graph::xor(g, g, g, g))
    end
    
    def test_xor_sample_graph_and_other_sample_graph
        g1 = @@sample_graph
        g2 = @@sample_graph_1

        def _xor(g,h)
            [(g.nodes|h.nodes)-(g.nodes&h.nodes),
             (g.edges|h.edges)-(g.edges&h.edges)]
        end

        g_1_2 = Graph.new(*_xor(g1,g2))
        g_2_1 = Graph.new(*_xor(g2,g1))

        assert_equal(g_1_2, Graph::xor(g1, g2))
        assert_equal(g_2_1, Graph::xor(g2, g1))
    end

    # == Graph#write == #

    def test_graph_write_no_ext
        g = @@sample_graph
        f = '/tmp/_graph_test'
        g.write(f)
        assert_equal(true, File.exists?(f))
        
        dict = YAML.load(File.open(f))
        assert_equal(g.nodes, dict['nodes'])
        assert_equal(g.edges, dict['edges'])
    end

    def test_graph_write_unknow_ext
        g = @@sample_graph
        f = '/tmp/_graph_test.foo'
        assert_raise(NoMethodError) do
            g.write(f)
        end
        assert_equal(false, File.exists?(f))
    end

    # == Graph#get_node == #
    
    def test_graph_get_node_unexisting_label

        n = @@sample_graph.get_node 'foobar'

        assert_equal(nil, n)
    end
    
    def test_graph_get_node_existing_label

        g = @@sample_graph;

        n = g.get_node 'foo'

        assert_equal(g.nodes[0], n)
    end

    # == Graph#get_neighbours == #

    def test_graph_get_neighbours_unexisting_node_label

        n = @@sample_graph.get_neighbours 'moo'

        assert_equal([], n)

    end

    def test_graph_get_neighbours_unexisting_node_object

        n = @@sample_graph.get_neighbours Graph::Node.new( :label => 'moo' )

        assert_equal([], n)

    end

    def test_graph_get_neighbours_undirected_graph

        g = @@sample_graph
        g.attrs[:directed] = false

        n1 = g.get_neighbours 'chuck'
        n2 = g.get_neighbours 'foo'

        assert_equal([ 'bar', 'foo' ], n1.map { |m| m.label })
        assert_equal([ 'bar', 'chuck' ], n2.map { |m| m.label })

    end

    def test_graph_get_neighbours_directed_graph

        g = @@directed

        n = g.get_neighbours 'foo'
        assert_equal([ 'bar' ], n.map { |m| m.label })

        n = g.get_neighbours 'bar'
        assert_equal([], n)

    end

    def test_graph_get_neighbours_bad_edges

        g = Graph.new(
            [ { :label => 'foo' },
              { :label => 'bar' },
              { :label => 'moo' }],

            [ { :node1 => 'foo' }, # missing :node2 attr
              { :node1 => 'foo', :node2 => 'moo' }])

        n = g.get_neighbours 'foo'

        assert_equal(1, n.length)
        assert_equal('moo', n[0].label)

    end

end
