
 

type LDA
    n_components::Integer
    method::String
    w::Vector
end

function LDA(;
             n_components::Integer = 2,
             method = "svd",
             w::Vector = zeros(10))
    return LDA(n_components, method, w)
end


function calc_Sw_Sb(model::LDA, X::Matrix, y::Vector)
    n_feature = size(X, 2)
    n_sample = size(X, 1)
    labels = unique(y)
    Sw = zeros(n_feature, n_feature)
    for label in labels
        X_ = X[find(y.==label),:]
        Sw += size(X_, 1) * cov(X_)
    end

    total_mean = mean(X, 1)
    Sb = zeros(n_feature , n_feature)
    for label in labels
        X_ = X[find(y .== label),:]
        mean_ = (mean(X_,1) - total_mean)
        Sb += size(X_, 1) * mean_' * mean_
    end
    return Sw, Sb 


end
function transform_(model::LDA, X::Matrix, y::Vector)
    Sw, Sb = calc_Sw_Sb(model, X, y)

    if model.method == "svd"
        U, S, V = svd(Sw)
        S = diagm(S)
        Sw_inverse = V * pinv(S) * U'
        A = Sw_inverse * Sb
    else 
        A = inv(Sw) * Sb
    end

    eigval, eigvec = eig(A)
    eigval = eigval[1:model.n_components]
    eigvec = eigvec[:, 1:model.n_components]
    X_transformed = X * eigvec
    model.w = eigvec[:,1]

    return X_transformed

end


function plot_in_2d(model::LDA, X::Matrix, y::Vector)
    X_transformed = transform_(model, X, y)
    X_transformed = convert(Array{Real,2}, X_transformed)
    x1 = X_transformed[:, 1]
    x2 = X_transformed[:, 2]
    df = DataFrame(x = x1, y = x2, clu = y)
    println("Computing finished")
    println("Drawing the plot.....Please Wait(Actually Gadfly is quite slow in drawing the first plot)")
    Gadfly.plot(df, x = "x", y = "y", color = "clu", Geom.point)
end

function train!(model::LDA, X::Matrix, y::Vector)
    transform_(model, X, y)
end

function predict(model::LDA, X::Matrix)
    temp = X * model.w
    temp = sign(temp)
    return temp
end

function test_LDA()
    X_train, X_test, y_train, y_test = make_cla()
    model = LDA()
    train!(model, X_train, y_train)
    predictions = predict(model, X_test)
    print("classification accuracy", accuracy(y_test, predictions))

    plot_in_2d(model, X_train, y_train)
end

function test_LDA_reduction()
    X_train, X_test, y_train, y_test = make_cla()
    model = LDA()
    plot_in_2d(model, X_train, y_train)
end














