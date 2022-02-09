#import Pkg; Pkg.add("Plots")
#import Pkg; Pkg.add("PlotlyJS")
#import Pkg; Pkg.add("Distribution")
using Plots
using Random, Distributions

TARGET_DAY = "2022"

file = "[YOUR_PATH]"

log_data = []

open(file) do f
    for(i, line) in enumerate(eachline(f))
        push!(log_data, line)
    end
end

hour_x = 1:1:24 # index from 1 to 24
hour_list = zeros(Int, 24, 1)

for(i, line) in enumerate(log_data)
    if TARGET_DAY == split(line)[1][1:4]
        idx = parse(Int16, split(line)[2][1:2]) + 1
        hour_list[idx] = hour_list[idx] + 1
    end
end

println(hour_list)

plotlyjs() # for daemon process (back)
p1 = plot(hour_x, hour_list, xlabel="k", ylabel="P(x=k)",
lw=2, marker = ([:circle :d], 3, 0.9, Plots.stroke(3, :gray)))
#color="blue", lw=3, marker = ([:circle :d], 4, 0.9, Plots.stroke(2, :gray)))
#plot!(p, ddd, fff_10, lw=3, marker = ([:circle :d], 4, 0.9, Plots.stroke(2, :gray)))
#plot!(p, ddd, fff_20, lw=3, marker = ([:circle :d], 4, 0.9, Plots.stroke(2, :gray)))

# 2. Pre-define Plot
unknown = zeros(Int, 24, 1)
predefined = zeros(Int, 24, 1)

for(i, line) in enumerate(log_data)
    if TARGET_DAY == split(line)[1][1:4]
        idx = parse(Int16, split(line)[2][1:2]) + 1

        if split(line)[5] == "Unknown"
            unknown[idx] = unknown[idx] + 1
        else
            predefined[idx] = predefined[idx] + 1
        end
    end
end

p2 = plot(hour_x, unknown, xlabel="k", ylabel="P(x=k)",
lw=2, marker = ([:circle :d], 3, 0.9, Plots.stroke(3, :gray)))
plot!(p2, hour_x, predefined, lw=2, marker = ([:circle :d], 3, 0.9,
Plots.stroke(3, :gray)))

# 3. Class-based Plot
classes = zeros(Int, 24, 12)

for(i, line) in enumerate(log_data)
    if TARGET_DAY == split(line)[1][1:4]
        class = parse(Int, split(line)[4]) + 1
        hour = parse(Int16, split(line)[2][1:2]) + 1

        classes[hour, class] = classes[hour, class] + 1
    end
end

p3 = plot(hour_x, classes[:, 1], xlabel="k", ylabel="P(x=k)",
lw=2, marker = ([:circle], 3))
for i in 2:12
    plot!(p3, hour_x, classes[:, i], lw=2, marker = ([:circle], 3))
end

# 5. Poisson Distribution

X = []
for i in 1:24
    push!(X, Poisson(hour_list[i]))
end

poisson_prob_A = []
poisson_prob_B = []
poisson_prob_C = []
poisson_prob_D = []
poisson_prob_E = []

fps = 120 # considering  Measurement Period

for i in 1:length(hour_list)
    A, B, C, D = 0, 0, 0, 0
    for j in 0:4*fps
        A = A + pdf(X[i], j)
        B = B + pdf(X[i], j + 5*fps)
        C = C + pdf(X[i], j + 10*fps)
        D = D + pdf(X[i], j + 15*fps)
    end

    push!(poisson_prob_A, A)
    push!(poisson_prob_B, B)
    push!(poisson_prob_C, C)
    push!(poisson_prob_D, D)
    push!(poisson_prob_E, 1 - (A + B + C + D))
end

p4 = plot(hour_x, poisson_prob_A, xlabel="k", ylabel="P(x=k)",
lw=2, marker = ([:circle :d], 3, 0.9, Plots.stroke(3, :gray)))
plot!(p4, hour_x, poisson_prob_B, lw=2, marker = ([:circle :d], 3, 0.9,
Plots.stroke(3, :gray)))
plot!(p4, hour_x, poisson_prob_C, lw=2, marker = ([:circle :d], 3, 0.9,
Plots.stroke(3, :gray)))
plot!(p4, hour_x, poisson_prob_D, lw=2, marker = ([:circle :d], 3, 0.9,
Plots.stroke(3, :gray)))
plot!(p4, hour_x, poisson_prob_E, lw=2, marker = ([:circle :d], 3, 0.9,
Plots.stroke(3, :gray)))
