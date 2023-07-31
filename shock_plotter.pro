PRO shock_plotter, best_fit=best_fit, xy=xy, circle_event=circle_event, high_low=high_low, Vm_new=Vm_new, std_Vm_new=std_Vm_new, Vs_new=Vs_new, error_Vs_new=error_Vs_new

; Main structure is 'shocks'
; shocks.ID = event ID number
; shocks.V_multi = mutliple spacecraft MEAN shock speed
; shocks.V_multi_std = multiple spacecraft standard deviation
; shocks.V_single = single spacecraft shock velocity
; shocks.V_single_std = single spacecraft shock velocity stddev
; shocks.V_single_error = single spacecraft shock velocity error

; KEYWORDS:
;
;       best_fit - display the best fit line in blue
;
;       xy - display the Y = X line in red
;
;       circle_event - set to the number event to be circled on the plot
;
;       high_low - display the upper and lower Y = X boundss
;
;	Vm_new - Same as others, doesn't need to be set, is used by shock_scrapers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restore, 'shock_velocity_data.idl', /verbose

;Get parameters from file to plot
ID = shocks.ID
Vm = shocks.V_multi
Vm_std = shocks.V_multi_std
Vs = shocks.V_single
Vs_std = shocks.V_single_std
Vs_error = shocks.V_single_error
delta = Vm - Vs

;make the inital scatter plot
plot1 = scatterplot(Vm, Vs, symbol='circle', title ='Single Spacecraft vs. Multi-Spacecraft Shock Velocity', xtitle='|V| Multi-spacecraft', ytitle='|V| Single-spacecraft', xrange=[0, 1000], yrange=[0,1000])

;plot the errors
y_error_plot = errorplot(Vm, Vs, Vm_std, Vs_error, /overplot, linestyle='none')

;Get important plotting values
max_V = max(shocks.V_multi)
line_x = findgen(max_V)

;For shock scrapper pop up, add new datapoint
if keyword_set(Vm_new) then begin
   ;Get new point values
   Vm_new = [Vm_new]
   std_Vm_new = [std_Vm_new]
   Vs_new = [Vs_new]
   error_Vs_new = [error_Vs_new]
   ;Plot the new point in red
   new_plot_point = scatterplot(Vm_new, Vs_new, symbol='diamond', sym_color='red', sym_size=2, /overplot)
   ;plot the error of the new point
   new_error_plot = errorplot(Vm_new, Vs_new, std_Vm_new, error_Vs_new, /overplot, linestyle='none', sym_color='red')
   new_error_plot.sym_color='red'

endif

;Circle a particular point
if keyword_set(circle_event) then begin
   circle_event=circle_event
   print, 'Displaying event number: '+string(circle_event)
   circle_point_Vm = Vm[where(ID eq circle_event)]
   circle_point_Vs = Vs[where(ID eq circle_event)]
   circle_plot_point = scatterplot(circle_point_Vm, circle_point_Vs, symbol='circle',sym_size=5, /overplot)
endif

;Create a best fit line
if keyword_set(best_fit) then begin
   ;Get linear fit parameters
   line_fit = linfit(Vm, Vs)
   ; Y = A + Bx
   line_best_fit = line_fit[0] + line_fit[1]*line_x 
   ;Plot the best fit line
   best_fit = plot(line_x, line_best_fit, /overplot)
endif

;plot the X = y line and some parameters above and below
if keyword_set(xy) then begin
   line_y = line_x
   xy_line = plot(line_x, line_y, /overplot, color='blue')
endif

;Add in dashed plus and minus regions (NEEDS BETTER HIGH AND LOW VALUES****)
if keyword_set(high_low) then begin
   line_y = line_x
   y_high= line_y+50
   y_low= line_y -50
   high_line = plot(line_x, y_high, /overplot, color='green', linestyle='dash')
   low_line = plot(line_x, y_low, /overplot, color='green', linestyle='dash')
endif

end
