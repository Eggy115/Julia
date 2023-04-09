

type NeuralNetwork
    hidden::Union{Vector,Int64}
    act::String
    weights::Dict{Integer, Matrix}
    max_iter::Integer
end

function NeuralNetwork(;
                       hidden::Union{Vector,Int64} = [2,2,1],
                       act::String = "sigmoid",
                       weights::Dict{Integer,Matrix} = Dict{Integer,Matrix}(),
                       max_iter::Integer = 500000)
    return NeuralNetwork(hidden, act, weights, max_iter)
end

function train!(model::NeuralNetwork, X::Matrix, y::Vector)
    if typeof(model.hidden) <: Integer
        model.hidden = [size(X, 2), model.hidden, size(y, 2)]
    end
    init_weights(model)
    depth = size(model.hidden,1)
    a::Dict{Integer, Vector} = Dict()
    z::Dict{Integer, Vector} = Dict()
    X = hcat(X,ones(size(X,1)))
    for i = 1:model.max_iter
        #batch
        r = rand(1:size(X,1))
        a[1] = X[r,:]
        for j = 2:(depth)
            z[j] = vec(a[j-1]' * model.weights[j-1])
            a[j] = vec(sigmoid(z[j]))
        end
        delta = Dict{Integer, Vector}()
        error_ = a[depth] - y[r]
        #if i % 1000 == 0
        #    println("$(i) epochs: error $(error_)")
        #end
        delta[depth] = error_ .* sigmoid_prime(z[depth])
        for j = depth-1:-1:2
            delta[j] = vec(delta[j+1]' * model.weights[j]') .* sigmoid_prime(z[j])  
        end
        for j = 1:depth-1
            del = delta[j+1]
            a_temp = a[j]
            model.weights[j] = model.weights[j] - 0.1 * a_temp * del'
        end
    end


end

function init_weights(model::NeuralNetwork)
    depth_ = size(model.hidden,1)
    for i = 1:(depth_-2)
        model.weights[i] = 2*rand(model.hidden[i]+1,model.hidden[i+1]+1)-1
    end
    model.weights[depth_-1] = 2*rand(model.hidden[depth_-1]+1,model.hidden[depth_])-1
end

function predict(model::NeuralNetwork, 
                 x::Matrix)
    n = size(x,1)
    m = model.hidden[end]
    res = zeros(n,m)
    for i = 1:n 
        res[i,:] = predict(model, x[i,:])
    end
    return res
end

function predict(model::NeuralNetwork,
                 x::Vector)
    x = x'
    x = hcat(x,[1])
    for i = 1:length(model.hidden)-1
        x = sigmoid(x * model.weights[i])
    end
    return x
end



## fixed

function test_NeuralNetwork()
    #xor_network
    X_train = [0.1 0.1; 0.1 0.9; 0.9 0.1; 0.9 0.9]
    y_train = [0.1,0.9,0.9,0.1]
    model = NeuralNetwork(hidden=10)
    train!(model,X_train, y_train)
    predictions = predict(model,X_train)
    print("regression msea", mean_squared_error(y_train, predictions))
end













