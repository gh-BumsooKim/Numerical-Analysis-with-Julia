#import Pkg; Pkg.add("Plots")
#import Pkg; Pkg.add("PlotlyJS")
using Plots

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
