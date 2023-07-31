PRO shock_plotter, best_fit=best_fit, xy=xy, circle_event=circle_event, high_low=high_low, subset=subset, Vm_new=Vm_new, std_Vm_new=std_Vm_new, Vs_new=Vs_new, error_Vs_new=error_Vs_new

; Main structure is 'shocks'
; shocks.ID = event ID number
; shocks.V_multi = mutliple spacecraft MEAN shock speed
; shocks.V_multi_std = multiple spacecraft standard deviation
; shocks.V_single = single spacecraft shock velocity
; shocks.V_single_std = single spacecraft shock velocity stddev
; shocks.V_single_error = single spacecraft shock velocity error

; KEYWORDS:
;
;       best_fit - display the best fit line in blue, toggle
;
;       xy - display the Y = X line in red, toggle
;
;       circle_event - set to the number event to be circled on the
;                      plot with the form circle_event = 796
;
;       high_low - display the upper and lower Y = X bounds, toggle
;
;       subset - plot only a subset of value provided as a list in the
;                form of [694, 721, 976] 
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

if keyword_set(subset) then begin
   ;Set up temporary storage arrays that will build the subset of data
   temp_ID = []
   temp_Vm = []
   temp_Vm_std = []
   temp_Vs = []
   temp_Vs_std = []
   temp_Vs_error = []
   ;Inform user of current events in database file
   print, 'The shock events in this file are:'
   print, ID
   wait, 0.5
   ;Set variables to build list from user input
   event_sub = ''
   events_subset = []
   ;Loop to have user add events until complete
   while (event_sub ne 'd') do begin
      ;grab user input of event number
       read, event_sub, PROMPT='Add datapoint to subset and type d when done: '
       ;add to running list
       if event_sub ne 'd' then events_subset = [events_subset, event_sub]
       ;Print current list to user so they know what they have added
       print, 'Current event subset: '
       print, events_subset
   endwhile
   ;Loop over each event in the subset and grab that data for that
   FOREACH event, events_subset do begin
      ; Get the index of the event being used
      event_index = where(ID eq event)
      if event_index eq -1 then begin
         print, 'Event '+string(event)+' not found in database. Going to next'
         wait, 0.25
         continue
      endif
      ;Grab the values for the correct event and add it to temp arrays
      temp_ID = [temp_ID, ID[event_index]] 
      temp_Vm = [temp_Vm, Vm[event_index]]
      temp_Vm_std = [temp_Vm_std, Vm_std[event_index]]
      temp_Vs = [temp_Vs, Vs[event_index]]
      temp_Vs_std = [temp_Vs_std, Vs_std[event_index]]
      temp_Vs_error = [temp_Vs_error, Vs_error[event_index]]
   endforeach
   ;Set the temporary arrays to be the main arrays for plotting
   ID = temp_ID
   Vm =temp_Vm
   Vm_std = temp_Vm_std
   Vs = temp_Vs
   Vs_std = temp_Vs_std
   Vs_error = temp_Vs_error
endif

;make the inital scatter plot
plot1 = scatterplot(Vm, Vs, symbol='circle', title ='Single Spacecraft vs. Multi-Spacecraft Shock Velocity', xtitle='|V| Multi-spacecraft', ytitle='|V| Single-spacecraft', xrange=[0, 1000], yrange=[0,1000])

;plot the errors
y_error_plot = errorplot(Vm, Vs, Vm_std, Vs_error, /overplot, linestyle='none')

;Get important plotting values
; Max velocity
max_V = max(shocks.V_multi)
;Array of integer X values from 0 to maximum value for plotting
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
   ;Get linear fit parameters using fitexy
   fitexy, Vm, Vs, intercept, slope, X_Sig = Vm_std, Y_sig=Vs_error
   ;Print best fit parameters
   print, 'Intercept: '+string(intercept)
   print, 'Slope    : '+string(slope)
   ; Y = A_intercept + B_slope*x
   line_best_fit = intercept +slope*line_x 
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
