#! /usr/bin/env ruby
# -*- coding: UTF-8 -*-

class Node_test < Test::Unit::TestCase
    
    def setup
        @@empty = Graph::Node.new
        @@alice = Graph::Node.new('label' => 'Alice')
    
        # Alice ----> Bob
        #   ↑          ↑
        #   |          |
        # Oscar -------'
        @@sample_graph = Graph.new(
            [
                { 'label' => 'Alice' },
                { 'label' => 'Bob'   },
                { 'label' => 'Oscar' }
            ],
            [
                { 'node1' => 'Alice', 'node2' => 'Bob' },
                { 'node1' => 'Oscar', 'node2' => 'Alice'},
                { 'node1' => 'Oscar', 'node2' => 'Bob'}
            ]
        )
    
    end

    def test_create_graph_with_node_objects
        g1 = Graph.new([
            Graph::Node.new('label' => 'Foo')
        ])

        g2 = Graph.new([
            { 'label' => 'Foo' }
        ])

        assert_equal(g2, g1)
    end

    def test_node_attrs
        a = @@alice

        a['foo'] = 'bar'

        assert_equal('Alice', @@alice['label'])
        assert_equal('bar',   @@alice['foo'])
        assert_equal(nil,     @@alice['fooo'])
    end

    def test_node_degree_by_label
        assert_equal(2, @@sample_graph.degree_of('Alice'))
        assert_equal(2, @@sample_graph.degree_of('Oscar'))
        assert_equal(2, @@sample_graph.degree_of('Bob'))
        assert_equal(0, @@sample_graph.degree_of('not found'))
    end

    def test_node_degree_by_object
        assert_equal(2, @@sample_graph.degree_of(@@alice))
    end

    def test_node_in_degree_by_label
        assert_equal(1, @@sample_graph.in_degree_of('Alice'))
        assert_equal(2, @@sample_graph.in_degree_of('Bob'))
        assert_equal(0, @@sample_graph.in_degree_of('Oscar'))
        assert_equal(0, @@sample_graph.in_degree_of('not found'))
    end

    def test_node_in_degree_by_object
        assert_equal(1, @@sample_graph.in_degree_of(@@alice))
    end

    def test_node_out_degree_by_label
        assert_equal(1, @@sample_graph.out_degree_of('Alice'))
        assert_equal(0, @@sample_graph.out_degree_of('Bob'))
        assert_equal(2, @@sample_graph.out_degree_of('Oscar'))
        assert_equal(0, @@sample_graph.out_degree_of('not found'))
    end

    def test_node_out_degree_by_object
        assert_equal(1, @@sample_graph.out_degree_of(@@alice))
    end

    def test_node_label_attr
        assert_equal('Alice', @@alice.label)
    end

    def test_node_update

        n = Graph::Node.new

        assert_equal(true, n.update({}).is_a?(Graph::Node))
    end

    def test_node_init_with_another_node

        n = Graph::Node.new({ :foo => 'bar' })

        assert_equal( n, Graph::Node.new(n) )

    end

end

class NodeArray_test < Test::Unit::TestCase

    def test_nodearray_push_node

        n = Graph::Node.new({ :foo => 42 })
        na = Graph::NodeArray.new([])

        na.push(n)

        assert_equal(n, na[0])

    end

    def test_nodearray_push_hash

        n = { :foo => 42 }
        na = Graph::NodeArray.new([])

        na.push(n)

        assert_equal(Graph::Node.new(n), na[0])

    end

    def test_nodearray_push_no_node_nor_hash

        na = Graph::NodeArray.new([])

        assert_raise(TypeError) do

            na.push(42)

        end

    end

end
