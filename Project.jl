using CSV, DataFrames
using Plots, Dates, Statistics
df = CSV.read("Project/HartfordAirport1942_2021.csv", DataFrame)

#AWND - Average wind speed
#SNOW - Snowfall
#TMAX - Maximum temperature
#TAVG - Average Temperature.
#TMIN - Minimum temperature
#PRCP - Precipitation
#SNWD - Snow depth 

describe(df) #TAVG mostly missing, half of AWND missing, SNWD also bad
df.MONTH = Dates.month.(df.DATE)
df.YEAR = Dates.year.(df.DATE)
df.DAYOFWEEK = Dates.dayofweek.(df.DATE)
df_notmissing = dropmissing(df) #complete data from 2000 on

#best function ever, calculate mean grouped by column
function groupby_mean(dataframe, column)
    numcols = names(dataframe, findall(x -> eltype(x) <: Union{Missing,Number}, eachcol(dataframe)))
    return combine(groupby(dataframe, column), numcols .=> mean∘skipmissing .=> numcols)
end


months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
df_old = df[((df.YEAR .>= 1949) .& (df.YEAR .< 1979)),:] #wind speed, TAVG missing
df_new = df[((df.YEAR .>= 1991) .& (df.YEAR .< 2021)),:] #most SNWD, half TAVG, third SNOW missing
#can compare PRCP, TMAX, TMIN and maybe SNOW
df_yearmean = groupby_mean(df, :YEAR)
df_monthmean = groupby_mean(df, :MONTH)
df_yearmean_old = groupby_mean(df_old, :YEAR)
df_monthmean_old = groupby_mean(df_old, :MONTH)
df_yearmean_new = groupby_mean(df_new, :YEAR)
df_monthmean_new = groupby_mean(df_new, :MONTH)

function comparison_plot(column)
    p = plot(months, df_monthmean_old[!,column], label="old")
    plot!(months, df_monthmean_new[!,column], label = "new")
    title!(column)
    return p
end

function year_plot(dataframe, column)
    p = plot(dataframe.YEAR, dataframe[!,column], leg = false)
    title!(column)
    return p
end

#great way to show data coverage

p1 = year_plot(df_yearmean, "PRCP")
p2 = year_plot(df_yearmean, "TAVG")
p3 = year_plot(df_yearmean, "SNOW")
p4 = year_plot(df_yearmean, "TMAX")
p5 = year_plot(df_yearmean, "SNWD")
p6 = year_plot(df_yearmean, "TMIN")
p7 = year_plot(df_yearmean, "AWND")
l = @layout [a b ; c d ; e f ; g] 
plot(p1,p2,p3,p4,p5,p6,p7, layout = l ,size = (500, 700))


c1 = comparison_plot("PRCP")# really interesting! much more rain in current summer
c2 = comparison_plot("TMAX")# increase in temperature visible
c3 = comparison_plot("SNOW")
c4 = comparison_plot("TMIN")
l = @layout [a b ; c d]
plot(c1,c2,c3,c4, layout = l ,size = (700, 400))

#comparison_plot("SNWD") not useful
#comparison_plot("AWND")
#comparison_plot("TAVG")






