def io_wtime_calc(bou)
   66.6 * 10 ** 6 / bou
end

p (io_wtime_calc ARGV[0].to_i).to_i.to_s(16)
