using CSV, DataFrames
using Plots, Dates, Statistics
cd("/Users/hushixiong/Documents/STAT5125-Project/")
df = CSV.read("HartfordAirport1942_2021.csv", DataFrame)

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

year_mean_PRCP = mean(filter(!isnan, df_yearmean.PRCP))
p = plot(df_yearmean.YEAR, (df_yearmean[!,:PRCP] .- year_mean_PRCP), leg = false)
title!("PRCP-ANOMALY")

#' Introducing Timeserires Package
using TimeSeries 
using Dates
using Statistics

dates = Date(2021,10,21): Day(1) : Date(2021, 10, 29)
data = Vector{Int64}
n1 = findall(x-> x == Date(2021,10,21), df.DATE)[1]
n2 = findall(x-> x == Date(2021,10,29), df.DATE)[1]
data = df.PRCP[n1:n2]
dset_slice = TimeArray(dates, data)
dset_all = TimeArray(df.DATE, df.PRCP)
#' could read CSV into TimeArray Directly
file = TimeArray(CSV.File("HartfordAirport1942_2021.csv"), timestamp = :DATE)
#' when could index the specific date in the timearray such as Monday or the month of October 
when(file, dayofweek, 1)
#' try indexing two months at a time but failed; when function could only indexing one type of month at one time and there is a quarter option 
#' From and to; Could specify the starting date and ending date of the dates 
from(file, Date(2001, 12, 27))
to(file, Date(2001, 12, 27))

dset_PRCP = TimeArray(df.DATE, df.PRCP)
#' collapse could compress data into a larger time frame, for example, could convert daily data into monthly data. And it could also combine with the functions in the Statistics Pkg to apply functions to the TimeArray
collapse(dset_PRCP, month, last, )

df.AWND[findall(x-> x == Date(2021,5,31), df.DATE)[1]]
#' testing whether the mean is right or not
n3 = findall(x-> x == Date(2021,05,01), df.DATE)[1]
n4 = findall(x-> x == Date(2021,05,31), df.DATE)[1]
mean(df.PRCP[n3:n4])
#' works well with the monthly mean
plot(dset_slice)
plot!(size=(1200,800))

#'shortcomings: can not do skipmissing or dropmissing to the TimeArray dataset