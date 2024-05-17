from basalt import Tensor, TensorShape
from basalt import Graph, Symbol, OP
from basalt.autograd.attributes import Attribute, AttributeVector


# '''Activation functions.'''
fn Threshold(
    inout g: Graph,
    input: Symbol,
    threshold: Scalar[dtype],
    value: Scalar[dtype],
) -> Symbol:
    return g.op(
        OP.THRESHOLD,
        input,
        attributes=AttributeVector(
            Attribute("threshold", threshold), Attribute("value", value)
        ),
    )


fn ReLU(inout g: Graph, input: Symbol) -> Symbol:
    return g.op(OP.RELU, input)


fn Sigmoid(inout g: Graph, input: Symbol) -> Symbol:
    return g.op(OP.SIGMOID, input)


fn Tanh(inout g: Graph, input: Symbol) -> Symbol:
    return g.op(OP.TANH, input)


fn Hardtanh(
    inout g: Graph,
    input: Symbol,
    min_val: Scalar[dtype],
    max_val: Scalar[dtype],
) -> Symbol:
    return g.op(
        OP.HARDTANH,
        input,
        attributes=AttributeVector(
            Attribute("min_val", min_val), Attribute("max_val", max_val)
        ),
    )


fn Softmax(inout g: Graph, input: Symbol, axis: Int) -> Symbol:
    # softmax: exp(x_i) / sum(exp(x_j))
    # stable softmax: exp(x_i - max(x_j)) / sum(exp(x_j - max(x_j)))

    var max_values = g.op(
        OP.MAX, input, attributes=AttributeVector(Attribute("axis", axis))
    )
    var input_minus_max = g.op(OP.SUB, input, max_values)
    var exp_values = g.op(OP.EXP, input_minus_max)
    var sum_values = g.op(
        OP.SUM, exp_values, attributes=AttributeVector(Attribute("axis", axis))
    )

    return g.op(OP.DIV, exp_values, sum_values)


fn LogSoftmax(inout g: Graph, input: Symbol, axis: Int) -> Symbol:
    # stable logsoftmax: log(exp(x_i - max(x_j)) / sum(exp(x_j - max(x_j))))
    # stable logsoftmax: x_i - max(x_j) - log(sum(exp(x_j - max(x_j))))

    var max_values = g.op(
        OP.MAX, input, attributes=AttributeVector(Attribute("axis", axis))
    )
    var input_minus_max = g.op(OP.SUB, input, max_values)
    var exp_values = g.op(OP.EXP, input_minus_max)
    var sum_values = g.op(
        OP.SUM, exp_values, attributes=AttributeVector(Attribute("axis", axis))
    )
    var log_values = g.op(OP.LOG, sum_values)

    return g.op(OP.SUB, input_minus_max, log_values)
