from tensor import Tensor

from dainemo.autograd.node import Node
from dainemo.autograd.ops.basics import SUM, SUB, DIV, EXP, MAX, LOG
import dainemo.autograd.ops.mlops

'''Activation functions.'''

# <------------RELU------------>
struct ReLU:
    fn __init__(inout self):
        pass
    
    @staticmethod
    fn forward(input: Node[dtype]) -> Node[dtype]:
        return mlops.RELU.forward(input)

    fn __call__(self, input: Node[dtype]) -> Node[dtype]:
        return self.forward(input)


# <------------SIGMOID------------>
struct Sigmoid:
    fn __init__(inout self):
        pass

    @staticmethod
    fn forward(input: Node[dtype]) -> Node[dtype]:
        return mlops.SIGMOID.forward(input)

    fn __call__(self, input: Node[dtype]) -> Node[dtype]:
        return self.forward(input)


# <------------TANH------------>
struct Tanh:
    fn __init__(inout self):
        pass

    @staticmethod
    fn forward(input: Node[dtype]) -> Node[dtype]:
        return mlops.TANH.forward(input)

    fn __call__(self, input: Node[dtype]) -> Node[dtype]:
        return self.forward(input)


# <------------SOFTMAX------------>
struct Softmax[axis: Int]:
    fn __init__(inout self):
        pass

    @staticmethod
    fn forward(input: Node[dtype]) -> Node[dtype]:
        # softmax: exp(x_i) / sum(exp(x_j))
        # stable softmax: exp(x_i - max(x_j)) / sum(exp(x_j - max(x_j)))

        var max_values = MAX.forward[axis](input)
        var input_minus_max = SUB.forward(input, max_values)
        var exp_values = EXP.forward(input_minus_max)
        var sum_values = SUM.forward[axis](exp_values)

        return DIV.forward(exp_values, sum_values)

    fn __call__(self, input: Node[dtype]) -> Node[dtype]:
        return self.forward(input)


# <------------LOGSOFTMAX------------>
struct LogSoftmax[axis: Int]:
    fn __init__(inout self):
        pass

    @staticmethod
    fn forward(input: Node[dtype]) -> Node[dtype]:
        # stable logsoftmax: log(exp(x_i - max(x_j)) / sum(exp(x_j - max(x_j))))
        # stable logsoftmax: x_i - max(x_j) - log(sum(exp(x_j - max(x_j))))

        var max_values = MAX.forward[axis](input)
        var input_minus_max = SUB.forward(input, max_values)
        var exp_values = EXP.forward(input_minus_max)
        var sum_values = SUM.forward[axis](exp_values)
        var log_values = LOG.forward(sum_values)

        return SUB.forward(input_minus_max, log_values)

    fn __call__(self, input: Node[dtype]) -> Node[dtype]:
        return self.forward(input)


# <------------LEAKYRELU------------>