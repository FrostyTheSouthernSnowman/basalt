from random import rand
from tensor import TensorShape
from testing import assert_equal
from test_tensorutils import assert_tensors_equal
from math import exp, log

from dainemo import Graph, Symbol, OP
import dainemo.nn as nn
from dainemo.autograd.attributes import Attribute, AttributeVector
from dainemo.utils.tensorutils import fill

alias dtype = DType.float32
alias nelts: Int = simdwidthof[dtype]()


# ------ Test Binary Ops ------
fn test_binary_op[
    op: OP, t1_shape: TensorShape, t2_shape: TensorShape
](t1: Tensor[dtype], t2: Tensor[dtype], expected: Tensor[dtype]) raises:
    fn create_graph() -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)
        var t2 = g.input(t2_shape)

        var res = g.op(op, t1, t2)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1, t2)

    assert_tensors_equal(res, expected)


# <------------ADD------------>
fn test_ADD() raises:
    alias t1_shape = TensorShape(2, 3)
    alias t2_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    var t2: Tensor[dtype] = Tensor[dtype](t2_shape)
    fill[dtype, nelts](t1, 1.0)
    fill[dtype, nelts](t2, 1.0)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, 2.0)

    test_binary_op[OP.ADD, t1_shape, t2_shape](t1, t2, expected)


# <------------SUB------------>
fn test_SUB() raises:
    alias t1_shape = TensorShape(2, 3)
    alias t2_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    var t2: Tensor[dtype] = Tensor[dtype](t2_shape)
    fill[dtype, nelts](t1, 2.0)
    fill[dtype, nelts](t2, 1.0)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, 1.0)

    test_binary_op[OP.SUB, t1_shape, t2_shape](t1, t2, expected)


#  <------------MUL------------>
fn test_MUL() raises:
    alias t1_shape = TensorShape(2, 3)
    alias t2_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    var t2: Tensor[dtype] = Tensor[dtype](t2_shape)
    fill[dtype, nelts](t1, 2.0)
    fill[dtype, nelts](t2, 3.0)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, 6.0)

    test_binary_op[OP.MUL, t1_shape, t2_shape](t1, t2, expected)


# <------------DIV------------>
fn test_DIV() raises:
    alias t1_shape = TensorShape(2, 3)
    alias t2_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    var t2: Tensor[dtype] = Tensor[dtype](t2_shape)
    fill[dtype, nelts](t1, 6.0)
    fill[dtype, nelts](t2, 2.0)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, 3.0)

    test_binary_op[OP.DIV, t1_shape, t2_shape](t1, t2, expected)


# <------------DOT------------>
fn test_DOT() raises:
    alias t1_shape = TensorShape(2, 3)
    alias t2_shape = TensorShape(3, 2)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    var t2: Tensor[dtype] = Tensor[dtype](t2_shape)
    fill[dtype, nelts](t1, 1.0)
    fill[dtype, nelts](t2, 2.0)

    var expected = Tensor[dtype](2, 2)
    fill[dtype, nelts](expected, 6.0)

    test_binary_op[OP.DOT, t1_shape, t2_shape](t1, t2, expected)


# ------ Test Unary Ops ------
fn test_unary_op[
    op: OP, t1_shape: TensorShape
](t1: Tensor[dtype], expected: Tensor[dtype]) raises:
    fn create_graph() -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(op, t1)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    assert_tensors_equal(res, expected)


# <------------EXP------------>
fn test_EXP() raises:
    alias t1_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    fill[dtype, nelts](t1, 2.0)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, exp[dtype, 1](2.0))

    test_unary_op[OP.EXP, t1_shape](t1, expected)


# <------------LOG------------>
fn test_LOG() raises:
    alias t1_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    fill[dtype, nelts](t1, 2.0)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, log[dtype, 1](2.0))

    test_unary_op[OP.LOG, t1_shape](t1, expected)


# <------------POW------------>
fn test_POW() raises:
    alias t1_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    fill[dtype, nelts](t1, 2.0)

    fn create_graph() -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(OP.POW, t1, 2)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    var expected = Tensor[dtype](2, 3)
    fill[dtype, nelts](expected, 4.0)
    
    assert_tensors_equal(res, expected)


# <------------SUM------------>
fn test_SUM() raises:
    alias t1_shape = TensorShape(2, 3, 4)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    fill[dtype, nelts](t1, 1.0)

    fn create_graph(attributes: AttributeVector = AttributeVector()) -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(OP.SUM, t1, attributes=attributes)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    var expected = Tensor[dtype](1)
    fill[dtype, nelts](expected, 24.0)
    assert_tensors_equal(res, expected)

    # Test axis 1
    alias graph_axis_1 = create_graph(AttributeVector(Attribute("axis", 1)))
    var model_2 = nn.Model[graph_axis_1]()
    res = model_2.forward(t1)

    expected = Tensor[dtype](2, 1, 4)
    fill[dtype, nelts](expected, 3.0)

    assert_tensors_equal(res, expected)


# <------------MAX------------>
fn test_MAX() raises:
    alias t1_shape = TensorShape(2, 3, 2)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    
    for i in range(t1_shape.num_elements()):
        t1[i] = i + 1

    fn create_graph(attributes: AttributeVector = AttributeVector()) -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(OP.MAX, t1, attributes=attributes)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    var expected = Tensor[dtype](1)
    fill[dtype, nelts](expected, t1_shape.num_elements())

    assert_tensors_equal(res, expected)

    @parameter
    fn fill_tensor[size: Int](inout tensor: Tensor[dtype], values: StaticIntTuple[size]):
        for i in range(tensor.num_elements()):
            tensor[i] = values[i]

    # Test axis 0
    alias graph_axis_1 = create_graph(AttributeVector(Attribute("axis", 0)))
    var model_2 = nn.Model[graph_axis_1]()
    res = model_2.forward(t1)

    var expected_max_axis_0_temp = StaticIntTuple[6](7, 8, 9, 10, 11, 12)
    expected = Tensor[dtype](1, 3, 2)
    fill_tensor(expected, expected_max_axis_0_temp)
    assert_tensors_equal(res, expected)

    # Test axis 1
    alias graph_axis_2 = create_graph(AttributeVector(Attribute("axis", 1)))
    var model_3 = nn.Model[graph_axis_2]()
    res = model_3.forward(t1)

    var expected_max_axis_1_temp = StaticIntTuple[4](5, 6, 11, 12)
    expected = Tensor[dtype](2, 1, 2)
    fill_tensor(expected, expected_max_axis_1_temp)
    assert_tensors_equal(res, expected)

    # Test axis 2
    alias graph_axis_3 = create_graph(AttributeVector(Attribute("axis", 2)))
    var model_4 = nn.Model[graph_axis_3]()
    res = model_4.forward(t1)

    var expected_max_axis_2_temp = StaticIntTuple[6](2, 4, 6, 8, 10, 12)
    expected = Tensor[dtype](2, 3, 1)
    fill_tensor(expected, expected_max_axis_2_temp)
    assert_tensors_equal(res, expected)


# <------------MEAN------------>
fn test_MEAN() raises:
    alias t1_shape = TensorShape(2, 3)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    fill[dtype, nelts](t1, 5.0)

    fn create_graph(attributes: AttributeVector = AttributeVector()) -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(OP.MEAN, t1, attributes=attributes)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    var expected = Tensor[dtype](1)
    fill[dtype, nelts](expected, 5.0)
    assert_tensors_equal(res, expected)

    # Test axis 0
    alias graph_axis_1 = create_graph(AttributeVector(Attribute("axis", 0)))
    var model_2 = nn.Model[graph_axis_1]()
    res = model_2.forward(t1)

    expected = Tensor[dtype](1, 3)
    fill[dtype, nelts](expected, 5.0)
    assert_tensors_equal(res, expected)

    # Test axis 1
    alias graph_axis_2 = create_graph(AttributeVector(Attribute("axis", 1)))
    var model_3 = nn.Model[graph_axis_2]()
    res = model_3.forward(t1)

    expected = Tensor[dtype](2, 1)
    fill[dtype, nelts](expected, 5.0)
    assert_tensors_equal(res, expected)


# # <------------TRANSPOSE------------>
fn test_TRANSPOSE() raises:
    alias t1_shape = TensorShape(2, 3, 4)
    var t1: Tensor[dtype] = Tensor[dtype](t1_shape)
    for i in range(t1_shape.num_elements()):
        t1[i] = i + 1

    fn create_graph(attributes: AttributeVector = AttributeVector()) -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(OP.TRANSPOSE, t1, attributes=attributes)
    
        _ = g.out(res)
    
        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    var expected = Tensor[dtype](4, 3, 2)
    for i in range(2):
        for j in range(3):
            for k in range(4):
                expected[k * 6 + j * 2 + i] = t1[i, j, k]

    assert_tensors_equal(res, expected)

    # Test tranpose 1, 2, 0
    alias graph_axis_1 = create_graph(AttributeVector(Attribute("axes", TensorShape(1, 2, 0))))

    var model_2 = nn.Model[graph_axis_1]()

    res = model_2.forward(t1)

    var expected_axis_1 = Tensor[dtype](3, 4, 2)

    for i in range(2):
        for j in range(3):
            for k in range(4):
                expected_axis_1[j * 8 + k * 2 + i] = t1[i, j, k]

    assert_tensors_equal(res, expected_axis_1)


# <------------FLATTEN------------>
fn test_FLATTEN() raises:
    alias t1_shape = TensorShape(2, 3, 4)
    var t1 = Tensor[dtype](t1_shape)
    fill[dtype, nelts](t1, 1.0)

    fn create_graph() -> Graph:
        var g = Graph()
        var t1 = g.input(t1_shape)

        var res = g.op(OP.FLATTEN, t1)
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)

    var model = nn.Model[graph]()
    var res = model.forward(t1)

    var expected = Tensor[dtype](24)
    fill[dtype, nelts](expected, 1.0)

    assert_tensors_equal(res, expected)


# <------------RESHAPE------------>
fn test_RESHAPE() raises:
    alias t_shape = TensorShape(2, 2, 5)
    alias new_shape = TensorShape(2, 10)

    var t = Tensor[dtype](t_shape)
    var expected = Tensor[dtype](new_shape)
    for i in range(20):
        t[i] = i + 1
        expected[i] = i + 1

    fn create_graph() -> Graph:
        var g = Graph()
        var t1 = g.input(t_shape)

        var res = g.op(OP.RESHAPE, t1, attributes=AttributeVector(Attribute("shape", new_shape)))
        _ = g.out(res)

        return g ^

    alias graph = create_graph()
    assert_equal(len(graph.nodes), 1)
    var model = nn.Model[graph]()
    var res = model.forward(t)

    assert_tensors_equal(res, expected)


fn main():
    try:
        test_ADD()
        test_SUB()
        test_MUL()
        test_DIV()
        test_DOT()
        test_EXP()
        test_LOG()
        test_POW()
        test_SUM()
        test_MAX()
        test_MEAN()
        test_TRANSPOSE()
        test_FLATTEN()
        test_RESHAPE()
    except e:
        print("[ERROR] Error in ops")
        print(e)
